Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 6866A6B0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 15:25:54 -0500 (EST)
Date: Fri, 8 Feb 2013 21:25:51 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v2 3/3] mm: accelerate munlock() treatment of THP pages
Message-ID: <20130208202550.GB9817@redhat.com>
References: <1359962232-20811-1-git-send-email-walken@google.com>
 <1359962232-20811-4-git-send-email-walken@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359962232-20811-4-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Michel,

On Sun, Feb 03, 2013 at 11:17:12PM -0800, Michel Lespinasse wrote:
> munlock_vma_pages_range() was always incrementing addresses by PAGE_SIZE
> at a time. When munlocking THP pages (or the huge zero page), this resulted
> in taking the mm->page_table_lock 512 times in a row.
> 
> We can do better by making use of the page_mask returned by follow_page_mask
> (for the huge zero page case), or the size of the page munlock_vma_page()
> operated on (for the true THP page case).
> 
> Note - I am sending this as RFC only for now as I can't currently put
> my finger on what if anything prevents split_huge_page() from operating
> concurrently on the same page as munlock_vma_page(), which would mess
> up our NR_MLOCK statistics. Is this a latent bug or is there a subtle
> point I missed here ?

I agree something looks fishy: nor mmap_sem for writing, nor the page
lock can stop split_huge_page_refcount.

Now the mlock side was intended to be safe because mlock_vma_page is
called within follow_page while holding the PT lock or the
page_table_lock (so split_huge_page_refcount will have to wait for it
to be released before it can run). See follow_trans_huge_pmd
assert_spin_locked and the pte_unmap_unlock after mlock_vma_page
returns.

Problem is, the lock side dependen on the TestSetPageMlocked below to
be always repeated on the head page (follow_trans_huge_pmd will always
pass the head page to mlock_vma_page).

void mlock_vma_page(struct page *page)
{
	BUG_ON(!PageLocked(page));

	if (!TestSetPageMlocked(page)) {

But what if the head page was split in between two different
follow_page calls? The second call wouldn't take the pmd_trans_huge
path anymore and the stats would be increased too much.

The problem on the munlock side is even more apparent as you pointed
out above but now I think the mlock side was problematic too.

The good thing is, your accelleration code for the mlock side should
have fixed the mlock race already: not ever risking to end up calling
mlock_vma_page twice on the head page is not an "accelleration" only,
it should also be a natural fix for the race.

To fix the munlock side, which is still present, I think one way would
be to do mlock and unlock within get_user_pages, so they run in the
same place protected by the PT lock or page_table_lock.

There are few things that stop split_huge_page_refcount:
page_table_lock, lru_lock, compound_lock, anon_vma lock. So if we keep
calling munlock_vma_page outside of get_user_pages (so outside of the
page_table_lock) the other way would be to use the compound_lock.

NOTE: this a purely aesthetical issue in /proc/meminfo, there's
nothing functional (at least in the kernel) connected to it, so no
panic :).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
