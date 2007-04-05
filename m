Date: Thu, 5 Apr 2007 14:07:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: missing madvise functionality
Message-Id: <20070405140723.8477e314.akpm@linux-foundation.org>
In-Reply-To: <46154226.6080300@redhat.com>
References: <46128051.9000609@redhat.com>
	<461357C4.4010403@yahoo.com.au>
	<46154226.6080300@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ulrich Drepper <drepper@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Jakub Jelinek <jakub@redhat.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 05 Apr 2007 14:38:30 -0400
Rik van Riel <riel@redhat.com> wrote:

> Nick Piggin wrote:
> 
> > Oh, also: something like this patch would help out MADV_DONTNEED, as it
> > means it can run concurrently with page faults. I think the locking will
> > work (but needs forward porting).
> 
> Ironically, your patch decreases throughput on my quad core
> test system, with Jakub's test case.
> 
> MADV_DONTNEED, my patch, 10000 loops  (14k context switches/second)
> 
> real    0m34.890s
> user    0m17.256s
> sys     0m29.797s
> 
> 
> MADV_DONTNEED, my patch & your patch, 10000 loops  (50 context 
> switches/second)
> 
> real    1m8.321s
> user    0m20.840s
> sys     1m55.677s
> 
> I suspect it's moving the contention onto the page table lock,
> in zap_pte_range().  I guess that the thread private memory
> areas must be living right next to each other, in the same
> page table lock regions :)

Remember that we have two different ways of doing that locking:


#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
/*
 * We tuck a spinlock to guard each pagetable page into its struct page,
 * at page->private, with BUILD_BUG_ON to make sure that this will not
 * overflow into the next struct page (as it might with DEBUG_SPINLOCK).
 * When freeing, reset page->mapping so free_pages_check won't complain.
 */
#define __pte_lockptr(page)	&((page)->ptl)
#define pte_lock_init(_page)	do {					\
	spin_lock_init(__pte_lockptr(_page));				\
} while (0)
#define pte_lock_deinit(page)	((page)->mapping = NULL)
#define pte_lockptr(mm, pmd)	({(void)(mm); __pte_lockptr(pmd_page(*(pmd)));})
#else
/*
 * We use mm->page_table_lock to guard all pagetable pages of the mm.
 */
#define pte_lock_init(page)	do {} while (0)
#define pte_lock_deinit(page)	do {} while (0)
#define pte_lockptr(mm, pmd)	({(void)(pmd); &(mm)->page_table_lock;})
#endif /* NR_CPUS < CONFIG_SPLIT_PTLOCK_CPUS */


I wonder which way you're using, and whether using the other way changes
things.


> For more real world workloads, like the MySQL sysbench one,
> I still suspect that your patch would improve things.
> 
> Time to move back to debugging other stuff, though.
> 
> Andrew, it would be nice if our patches could cook in -mm
> for a while.  Want me to change anything before submitting?

umm.  I took a quick squint at a patch from you this morning and it looked
OK to me.  Please send the finalish thing when it is fully baked and
performance-tested in the various regions of operation, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
