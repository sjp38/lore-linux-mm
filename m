Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 991C56B003C
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 19:45:19 -0400 (EDT)
Received: by mail-ob0-f170.google.com with SMTP id uz6so4973495obc.1
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 16:45:19 -0700 (PDT)
Received: from mail-oa0-x232.google.com (mail-oa0-x232.google.com [2607:f8b0:4003:c02::232])
        by mx.google.com with ESMTPS id pp9si16060271obc.155.2014.03.23.16.45.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 23 Mar 2014 16:45:18 -0700 (PDT)
Received: by mail-oa0-f50.google.com with SMTP id i7so5099431oag.9
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 16:45:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1395436655-21670-4-git-send-email-john.stultz@linaro.org>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <1395436655-21670-4-git-send-email-john.stultz@linaro.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sun, 23 Mar 2014 16:44:58 -0700
Message-ID: <CAHGf_=q_1ZxDOdA7HCVUh2LYK9wwKbLsru__nXrXEQ2WEdjguQ@mail.gmail.com>
Subject: Re: [PATCH 3/5] vrange: Add page purging logic & SIGBUS trap
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Mar 21, 2014 at 2:17 PM, John Stultz <john.stultz@linaro.org> wrote:
> This patch adds the hooks in the vmscan logic to discard volatile pages
> and mark their pte as purged. With this, volatile pages will be purged
> under pressure, and their ptes swap entry's marked. If the purged pages
> are accessed before being marked non-volatile, we catch this and send a
> SIGBUS.
>
> This is a simplified implementation that uses logic from Minchan's earlier
> efforts, so credit to Minchan for his work.
>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Android Kernel Team <kernel-team@android.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Robert Love <rlove@google.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Dave Hansen <dave@sr71.net>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
> Cc: Neil Brown <neilb@suse.de>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Mike Hommey <mh@glandium.org>
> Cc: Taras Glek <tglek@mozilla.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: linux-mm@kvack.org <linux-mm@kvack.org>
> Signed-off-by: John Stultz <john.stultz@linaro.org>
> ---
>  include/linux/vrange.h |   2 +
>  mm/internal.h          |   2 -
>  mm/memory.c            |  21 +++++++++
>  mm/rmap.c              |   5 +++
>  mm/vmscan.c            |  12 ++++++
>  mm/vrange.c            | 114 +++++++++++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 154 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/vrange.h b/include/linux/vrange.h
> index 986fa85..d93ad21 100644
> --- a/include/linux/vrange.h
> +++ b/include/linux/vrange.h
> @@ -8,4 +8,6 @@
>  #define VRANGE_VOLATILE 1
>  #define VRANGE_VALID_FLAGS (0) /* Don't yet support any flags */
>
> +extern int discard_vpage(struct page *page);
> +
>  #endif /* _LINUX_VRANGE_H */
> diff --git a/mm/internal.h b/mm/internal.h
> index 29e1e76..ea66bf9 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -225,10 +225,8 @@ static inline void mlock_migrate_page(struct page *newpage, struct page *page)
>
>  extern pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma);
>
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  extern unsigned long vma_address(struct page *page,
>                                  struct vm_area_struct *vma);
> -#endif
>  #else /* !CONFIG_MMU */
>  static inline int mlocked_vma_newpage(struct vm_area_struct *v, struct page *p)
>  {
> diff --git a/mm/memory.c b/mm/memory.c
> index 22dfa61..db5f4da 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -60,6 +60,7 @@
>  #include <linux/migrate.h>
>  #include <linux/string.h>
>  #include <linux/dma-debug.h>
> +#include <linux/vrange.h>
>
>  #include <asm/io.h>
>  #include <asm/pgalloc.h>
> @@ -3643,6 +3644,8 @@ static int handle_pte_fault(struct mm_struct *mm,
>
>         entry = *pte;
>         if (!pte_present(entry)) {
> +               swp_entry_t vrange_entry;
> +retry:
>                 if (pte_none(entry)) {
>                         if (vma->vm_ops) {
>                                 if (likely(vma->vm_ops->fault))
> @@ -3652,6 +3655,24 @@ static int handle_pte_fault(struct mm_struct *mm,
>                         return do_anonymous_page(mm, vma, address,
>                                                  pte, pmd, flags);
>                 }
> +
> +               vrange_entry = pte_to_swp_entry(entry);
> +               if (unlikely(is_vpurged_entry(vrange_entry))) {
> +                       if (vma->vm_flags & VM_VOLATILE)
> +                               return VM_FAULT_SIGBUS;
> +
> +                       /* zap pte */
> +                       ptl = pte_lockptr(mm, pmd);
> +                       spin_lock(ptl);
> +                       if (unlikely(!pte_same(*pte, entry)))
> +                               goto unlock;
> +                       flush_cache_page(vma, address, pte_pfn(*pte));
> +                       ptep_clear_flush(vma, address, pte);
> +                       pte_unmap_unlock(pte, ptl);
> +                       goto retry;

This looks strange why we need zap pte here?

> +               }
> +
> +
>                 if (pte_file(entry))
>                         return do_nonlinear_fault(mm, vma, address,
>                                         pte, pmd, flags, entry);
> diff --git a/mm/rmap.c b/mm/rmap.c
> index d9d4231..2b6f079 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -728,6 +728,11 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
>                                 referenced++;
>                 }
>                 pte_unmap_unlock(pte, ptl);
> +               if (vma->vm_flags & VM_VOLATILE) {
> +                       pra->mapcount = 0;
> +                       pra->vm_flags |= VM_VOLATILE;
> +                       return SWAP_FAIL;
> +               }
>         }
>
>         if (referenced) {
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a9c74b4..34f159a 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -43,6 +43,7 @@
>  #include <linux/sysctl.h>
>  #include <linux/oom.h>
>  #include <linux/prefetch.h>
> +#include <linux/vrange.h>
>
>  #include <asm/tlbflush.h>
>  #include <asm/div64.h>
> @@ -683,6 +684,7 @@ enum page_references {
>         PAGEREF_RECLAIM,
>         PAGEREF_RECLAIM_CLEAN,
>         PAGEREF_KEEP,
> +       PAGEREF_DISCARD,

"discard" is alread used in various place for another meanings.
another name is better.

>         PAGEREF_ACTIVATE,
>  };
>
> @@ -703,6 +705,13 @@ static enum page_references page_check_references(struct page *page,
>         if (vm_flags & VM_LOCKED)
>                 return PAGEREF_RECLAIM;
>
> +       /*
> +        * If volatile page is reached on LRU's tail, we discard the
> +        * page without considering recycle the page.
> +        */
> +       if (vm_flags & VM_VOLATILE)
> +               return PAGEREF_DISCARD;
> +
>         if (referenced_ptes) {
>                 if (PageSwapBacked(page))
>                         return PAGEREF_ACTIVATE;
> @@ -930,6 +939,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>                 switch (references) {
>                 case PAGEREF_ACTIVATE:
>                         goto activate_locked;
> +               case PAGEREF_DISCARD:
> +                       if (may_enter_fs && !discard_vpage(page))

Wny may-enter-fs is needed? discard_vpage never enter FS.


> +                               goto free_it;
>                 case PAGEREF_KEEP:
>                         goto keep_locked;
>                 case PAGEREF_RECLAIM:
> diff --git a/mm/vrange.c b/mm/vrange.c
> index 1ff3cbd..28ceb6f 100644
> --- a/mm/vrange.c
> +++ b/mm/vrange.c
> @@ -246,3 +246,117 @@ SYSCALL_DEFINE5(vrange, unsigned long, start, size_t, len, unsigned long, mode,
>  out:
>         return ret;
>  }
> +
> +
> +/**
> + * try_to_discard_one - Purge a volatile page from a vma
> + *
> + * Finds the pte for a page in a vma, marks the pte as purged
> + * and release the page.
> + */
> +static void try_to_discard_one(struct page *page, struct vm_area_struct *vma)
> +{
> +       struct mm_struct *mm = vma->vm_mm;
> +       pte_t *pte;
> +       pte_t pteval;
> +       spinlock_t *ptl;
> +       unsigned long addr;
> +
> +       VM_BUG_ON(!PageLocked(page));
> +
> +       addr = vma_address(page, vma);
> +       pte = page_check_address(page, mm, addr, &ptl, 0);
> +       if (!pte)
> +               return;
> +
> +       BUG_ON(vma->vm_flags & (VM_SPECIAL|VM_LOCKED|VM_MIXEDMAP|VM_HUGETLB));
> +
> +       flush_cache_page(vma, addr, page_to_pfn(page));
> +       pteval = ptep_clear_flush(vma, addr, pte);
> +
> +       update_hiwater_rss(mm);
> +       if (PageAnon(page))
> +               dec_mm_counter(mm, MM_ANONPAGES);
> +       else
> +               dec_mm_counter(mm, MM_FILEPAGES);
> +
> +       page_remove_rmap(page);
> +       page_cache_release(page);
> +
> +       set_pte_at(mm, addr, pte,
> +                               swp_entry_to_pte(make_vpurged_entry()));
> +
> +       pte_unmap_unlock(pte, ptl);
> +       mmu_notifier_invalidate_page(mm, addr);
> +
> +}
> +
> +/**
> + * try_to_discard_vpage - check vma chain and discard from vmas marked volatile
> + *
> + * Goes over all the vmas that hold a page, and where the vmas are volatile,
> + * purge the page from the vma.
> + *
> + * Returns 0 on success, -1 on error.
> + */
> +static int try_to_discard_vpage(struct page *page)
> +{
> +       struct anon_vma *anon_vma;
> +       struct anon_vma_chain *avc;
> +       pgoff_t pgoff;
> +
> +       anon_vma = page_lock_anon_vma_read(page);
> +       if (!anon_vma)
> +               return -1;
> +
> +       pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> +       /*
> +        * During interating the loop, some processes could see a page as
> +        * purged while others could see a page as not-purged because we have
> +        * no global lock between parent and child for protecting vrange system
> +        * call during this loop. But it's not a problem because the page is
> +        * not *SHARED* page but *COW* page so parent and child can see other
> +        * data anytime. The worst case by this race is a page was purged
> +        * but couldn't be discarded so it makes unnecessary page fault but
> +        * it wouldn't be severe.
> +        */
> +       anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
> +               struct vm_area_struct *vma = avc->vma;
> +
> +               if (!(vma->vm_flags & VM_VOLATILE))
> +                       continue;

When you find !VM_VOLATILE vma, we have no reason to continue pte zapping.
Isn't it?


> +               try_to_discard_one(page, vma);
> +       }
> +       page_unlock_anon_vma_read(anon_vma);
> +       return 0;
> +}
> +
> +
> +/**
> + * discard_vpage - If possible, discard the specified volatile page
> + *
> + * Attempts to discard a volatile page, and if needed frees the swap page
> + *
> + * Returns 0 on success, -1 on error.
> + */
> +int discard_vpage(struct page *page)
> +{
> +       VM_BUG_ON(!PageLocked(page));
> +       VM_BUG_ON(PageLRU(page));
> +
> +       /* XXX - for now we only support anonymous volatile pages */
> +       if (!PageAnon(page))
> +               return -1;
> +
> +       if (!try_to_discard_vpage(page)) {
> +               if (PageSwapCache(page))
> +                       try_to_free_swap(page);

This looks strange. try_to_free_swap can't handle vpurge pseudo entry.


> +
> +               if (page_freeze_refs(page, 1)) {

Where is page_unfreeze_refs() for the pair of this?

> +                       unlock_page(page);
> +                       return 0;
> +               }
> +       }
> +
> +       return -1;
> +}
> --
> 1.8.3.2
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
