Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 3EB4A6B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 19:20:39 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kp1so1093650pab.17
        for <linux-mm@kvack.org>; Wed, 06 Feb 2013 16:20:38 -0800 (PST)
Date: Wed, 6 Feb 2013 16:20:40 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] s390/mm: implement software dirty bits
In-Reply-To: <1360087925-8456-3-git-send-email-schwidefsky@de.ibm.com>
Message-ID: <alpine.LNX.2.00.1302061504340.7256@eggly.anvils>
References: <1360087925-8456-1-git-send-email-schwidefsky@de.ibm.com> <1360087925-8456-3-git-send-email-schwidefsky@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, linux-s390@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>

On Tue, 5 Feb 2013, Martin Schwidefsky wrote:

> The s390 architecture is unique in respect to dirty page detection,
> it uses the change bit in the per-page storage key to track page
> modifications. All other architectures track dirty bits by means
> of page table entries. This property of s390 has caused numerous
> problems in the past, e.g. see git commit ef5d437f71afdf4a
> "mm: fix XFS oops due to dirty pages without buffers on s390".
> 
> To avoid future issues in regard to per-page dirty bits convert
> s390 to a fault based software dirty bit detection mechanism. All
> user page table entries which are marked as clean will be hardware
> read-only, even if the pte is supposed to be writable. A write by
> the user process will trigger a protection fault which will cause
> the user pte to be marked as dirty and the hardware read-only bit
> is removed.
> 
> With this change the dirty bit in the storage key is irrelevant
> for Linux as a host, but the storage key is still required for
> KVM guests. The effect is that page_test_and_clear_dirty and the
> related code can be removed. The referenced bit in the storage
> key is still used by the page_test_and_clear_young primitive to
> provide page age information.
> 
> For page cache pages of mappings with mapping_cap_account_dirty
> there will not be any change in behavior as the dirty bit tracking
> already uses read-only ptes to control the amount of dirty pages.
> Only for swap cache pages and pages of mappings without
> mapping_cap_account_dirty there can be additional protection faults.
> To avoid an excessive number of additional faults the mk_pte
> primitive checks for PageDirty if the pgprot value allows for writes
> and pre-dirties the pte. That avoids all additional faults for
> tmpfs and shmem pages until these pages are added to the swap cache.
> 
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> ---
>  arch/s390/include/asm/page.h    |   22 -------
>  arch/s390/include/asm/pgtable.h |  131 ++++++++++++++++++++++++++-------------
>  arch/s390/include/asm/sclp.h    |    1 -
>  arch/s390/include/asm/setup.h   |   16 ++---
>  arch/s390/kvm/kvm-s390.c        |    2 +-
>  arch/s390/lib/uaccess_pt.c      |    2 +-
>  arch/s390/mm/pageattr.c         |    2 +-
>  arch/s390/mm/vmem.c             |   24 +++----
>  drivers/s390/char/sclp_cmd.c    |   10 +--
>  include/asm-generic/pgtable.h   |   10 ---
>  include/linux/page-flags.h      |    8 ---
>  mm/rmap.c                       |   24 -------
>  12 files changed, 112 insertions(+), 140 deletions(-)

Martin, I'd like to say Applauded-by: Hugh Dickins <hughd@google.com>
but I do have one reservation: the PageDirty business you helpfully
draw attention to in your description above.

That makes me nervous, having a PageDirty test buried down there in
one architecture's mk_pte().  Particularly since I know the PageDirty
handling on anon/swap pages is rather odd: it works, but it's hard to
justify some of the SetPageDirtys (when we add to swap, AND when we
remove from swap): partly a leftover from 2.4 days, when vmscan worked
differently, and we had to be more careful about freeing modified pages.

I did a patch a year or two ago, mainly for debugging some particular
issue by announcing "Bad page state" if ever a dirty page is freed, in
which I had to tidy that up.  Now, I don't have any immediate intention
to resurrect that patch, but I'm afraid that if I did, I might interfere
with your optimization in s390's mk_pte() without realizing it.

> --- a/arch/s390/include/asm/page.h
> +++ b/arch/s390/include/asm/page.h
> ...
> @@ -1152,8 +1190,13
>  static inline pte_t mk_pte(struct page *page, pgprot_t pgprot)
>  {
>  	unsigned long physpage = page_to_phys(page);
> +	pte_t __pte = mk_pte_phys(physpage, pgprot);
>  
> -	return mk_pte_phys(physpage, pgprot);
> +	if ((pte_val(__pte) & _PAGE_SWW) && PageDirty(page)) {
> +		pte_val(__pte) |= _PAGE_SWC;
> +		pte_val(__pte) &= ~_PAGE_RO;
> +	}
> +	return __pte;
>  }

Am I right to think that, once you examine the mk_pte() callsites,
this actually would not be affecting anon pages, nor accounted file
pages, just tmpfs/shmem or ramfs pages read-faulted into a read-write
shared vma?  (That fits with what you say above.)  That it amounts to
the patch below - which I think I would prefer, because it's explicit?
(There might be one or two other places it makes a difference e.g.
replacing a writable migration entry, but those too uncommon to matter.)

--- 3.8-rc6/mm/memory.c	2013-01-09 19:25:05.028321379 -0800
+++ linux/mm/memory.c	2013-02-06 15:01:17.904387877 -0800
@@ -3338,6 +3338,10 @@ static int __do_fault(struct mm_struct *
 				dirty_page = page;
 				get_page(dirty_page);
 			}
+#ifdef CONFIG_S390
+			else if (pte_write(entry) && PageDirty(page))
+				pte_mkdirty(entry);
+#endif
 		}
 		set_pte_at(mm, address, page_table, entry);
 
And then I wonder, is that something we should do on all architectures?
On the one hand, it would save a hardware fault when and if the pte is
dirtied later; on the other hand, it seems wrong to claim pte dirty when
not (though I didn't find anywhere that would care).

Thoughts?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
