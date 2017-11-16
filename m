Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3970F6B027B
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 20:45:49 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r68so1538805wmr.4
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 17:45:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s67sor61297wme.57.2017.11.15.17.45.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Nov 2017 17:45:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171104224312.145616-1-shakeelb@google.com>
References: <20171104224312.145616-1-shakeelb@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 15 Nov 2017 17:45:45 -0800
Message-ID: <CALvZod52Y0qROhdC6LwL9ic_XMibZG1+qGy1EYXhRnYHM3Fh3Q@mail.gmail.com>
Subject: Re: [PATCH] mm, mlock, vmscan: no more skipping pagevecs
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, Nicholas Piggin <npiggin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Shakeel Butt <shakeelb@google.com>

Ping, really appreciate comments on this patch.

On Sat, Nov 4, 2017 at 3:43 PM, Shakeel Butt <shakeelb@google.com> wrote:
> When a thread mlocks an address space backed by file, a new
> page is allocated (assuming file page is not in memory), added
> to the local pagevec (lru_add_pvec), I/O is triggered and the
> thread then sleeps on the page. On I/O completion, the thread
> can wake on a different CPU, the mlock syscall will then sets
> the PageMlocked() bit of the page but will not be able to put
> that page in unevictable LRU as the page is on the pagevec of
> a different CPU. Even on drain, that page will go to evictable
> LRU because the PageMlocked() bit is not checked on pagevec
> drain.
>
> The page will eventually go to right LRU on reclaim but the
> LRU stats will remain skewed for a long time.
>
> However, this issue does not happen for anon pages on swap
> because unlike file pages, anon pages are not added to pagevec
> until they have been fully swapped in. Also the fault handler
> uses vm_flags to set the PageMlocked() bit of such anon pages
> even before returning to mlock() syscall and mlocked pages will
> skip pagevecs and directly be put into unevictable LRU. No such
> luck for file pages.
>
> One way to resolve this issue, is to somehow plumb vm_flags from
> filemap_fault() to add_to_page_cache_lru() which will then skip
> the pagevec for pages of VM_LOCKED vma and directly put them to
> unevictable LRU. However this patch took a different approach.
>
> All the pages, even unevictable, will be added to the pagevecs
> and on the drain, the pages will be added on their LRUs correctly
> by checking their evictability. This resolves the mlocked file
> pages on pagevec of other CPUs issue because when those pagevecs
> will be drained, the mlocked file pages will go to unevictable
> LRU. Also this makes the race with munlock easier to resolve
> because the pagevec drains happen in LRU lock.
>
> There is one (good) side effect though. Without this patch, the
> pages allocated for System V shared memory segment are added to
> evictable LRUs even after shmctl(SHM_LOCK) on that segment. This
> patch will correctly put such pages to unevictable LRU.
>
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
>  include/linux/swap.h |  2 --
>  mm/swap.c            | 68 +++++++++++++++++++++++++---------------------------
>  mm/vmscan.c          | 59 +--------------------------------------------
>  3 files changed, 34 insertions(+), 95 deletions(-)
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index f02fb5db8914..9b31d04914eb 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -326,8 +326,6 @@ extern void deactivate_file_page(struct page *page);
>  extern void mark_page_lazyfree(struct page *page);
>  extern void swap_setup(void);
>
> -extern void add_page_to_unevictable_list(struct page *page);
> -
>  extern void lru_cache_add_active_or_unevictable(struct page *page,
>                                                 struct vm_area_struct *vma);
>
> diff --git a/mm/swap.c b/mm/swap.c
> index a77d68f2c1b6..776fb33e81d3 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -445,30 +445,6 @@ void lru_cache_add(struct page *page)
>         __lru_cache_add(page);
>  }
>
> -/**
> - * add_page_to_unevictable_list - add a page to the unevictable list
> - * @page:  the page to be added to the unevictable list
> - *
> - * Add page directly to its zone's unevictable list.  To avoid races with
> - * tasks that might be making the page evictable, through eg. munlock,
> - * munmap or exit, while it's not on the lru, we want to add the page
> - * while it's locked or otherwise "invisible" to other tasks.  This is
> - * difficult to do when using the pagevec cache, so bypass that.
> - */
> -void add_page_to_unevictable_list(struct page *page)
> -{
> -       struct pglist_data *pgdat = page_pgdat(page);
> -       struct lruvec *lruvec;
> -
> -       spin_lock_irq(&pgdat->lru_lock);
> -       lruvec = mem_cgroup_page_lruvec(page, pgdat);
> -       ClearPageActive(page);
> -       SetPageUnevictable(page);
> -       SetPageLRU(page);
> -       add_page_to_lru_list(page, lruvec, LRU_UNEVICTABLE);
> -       spin_unlock_irq(&pgdat->lru_lock);
> -}
> -
>  /**
>   * lru_cache_add_active_or_unevictable
>   * @page:  the page to be added to LRU
> @@ -484,13 +460,9 @@ void lru_cache_add_active_or_unevictable(struct page *page,
>  {
>         VM_BUG_ON_PAGE(PageLRU(page), page);
>
> -       if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED)) {
> +       if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
>                 SetPageActive(page);
> -               lru_cache_add(page);
> -               return;
> -       }
> -
> -       if (!TestSetPageMlocked(page)) {
> +       else if (!TestSetPageMlocked(page)) {
>                 /*
>                  * We use the irq-unsafe __mod_zone_page_stat because this
>                  * counter is not modified from interrupt context, and the pte
> @@ -500,7 +472,7 @@ void lru_cache_add_active_or_unevictable(struct page *page,
>                                     hpage_nr_pages(page));
>                 count_vm_event(UNEVICTABLE_PGMLOCKED);
>         }
> -       add_page_to_unevictable_list(page);
> +       lru_cache_add(page);
>  }
>
>  /*
> @@ -883,15 +855,41 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
>  static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
>                                  void *arg)
>  {
> -       int file = page_is_file_cache(page);
> -       int active = PageActive(page);
> -       enum lru_list lru = page_lru(page);
> +       enum lru_list lru;
> +       int was_unevictable = TestClearPageUnevictable(page);
>
>         VM_BUG_ON_PAGE(PageLRU(page), page);
>
>         SetPageLRU(page);
> +       /*
> +        * Page becomes evictable in two ways:
> +        * 1) Within LRU lock [munlock_vma_pages() and __munlock_pagevec()].
> +        * 2) Before acquiring LRU lock to put the page to correct LRU and then
> +        *   a) do PageLRU check with lock [check_move_unevictable_pages]
> +        *   b) do PageLRU check before lock [isolate_lru_page]
> +        *
> +        * (1) & (2a) are ok as LRU lock will serialize them. For (2b), if the
> +        * other thread does not observe our setting of PG_lru and fails
> +        * isolation, the following page_evictable() check will make us put
> +        * the page in correct LRU.
> +        */
> +       smp_mb();
> +
> +       if (page_evictable(page)) {
> +               lru = page_lru(page);
> +               update_page_reclaim_stat(lruvec, page_is_file_cache(page),
> +                                        PageActive(page));
> +               if (was_unevictable)
> +                       count_vm_event(UNEVICTABLE_PGRESCUED);
> +       } else {
> +               lru = LRU_UNEVICTABLE;
> +               ClearPageActive(page);
> +               SetPageUnevictable(page);
> +               if (!was_unevictable)
> +                       count_vm_event(UNEVICTABLE_PGCULLED);
> +       }
> +
>         add_page_to_lru_list(page, lruvec, lru);
> -       update_page_reclaim_stat(lruvec, file, active);
>         trace_mm_lru_insertion(page, lru);
>  }
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index eb2f0315b8c0..b171da71eadf 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -787,64 +787,7 @@ int remove_mapping(struct address_space *mapping, struct page *page)
>   */
>  void putback_lru_page(struct page *page)
>  {
> -       bool is_unevictable;
> -       int was_unevictable = PageUnevictable(page);
> -
> -       VM_BUG_ON_PAGE(PageLRU(page), page);
> -
> -redo:
> -       ClearPageUnevictable(page);
> -
> -       if (page_evictable(page)) {
> -               /*
> -                * For evictable pages, we can use the cache.
> -                * In event of a race, worst case is we end up with an
> -                * unevictable page on [in]active list.
> -                * We know how to handle that.
> -                */
> -               is_unevictable = false;
> -               lru_cache_add(page);
> -       } else {
> -               /*
> -                * Put unevictable pages directly on zone's unevictable
> -                * list.
> -                */
> -               is_unevictable = true;
> -               add_page_to_unevictable_list(page);
> -               /*
> -                * When racing with an mlock or AS_UNEVICTABLE clearing
> -                * (page is unlocked) make sure that if the other thread
> -                * does not observe our setting of PG_lru and fails
> -                * isolation/check_move_unevictable_pages,
> -                * we see PG_mlocked/AS_UNEVICTABLE cleared below and move
> -                * the page back to the evictable list.
> -                *
> -                * The other side is TestClearPageMlocked() or shmem_lock().
> -                */
> -               smp_mb();
> -       }
> -
> -       /*
> -        * page's status can change while we move it among lru. If an evictable
> -        * page is on unevictable list, it never be freed. To avoid that,
> -        * check after we added it to the list, again.
> -        */
> -       if (is_unevictable && page_evictable(page)) {
> -               if (!isolate_lru_page(page)) {
> -                       put_page(page);
> -                       goto redo;
> -               }
> -               /* This means someone else dropped this page from LRU
> -                * So, it will be freed or putback to LRU again. There is
> -                * nothing to do here.
> -                */
> -       }
> -
> -       if (was_unevictable && !is_unevictable)
> -               count_vm_event(UNEVICTABLE_PGRESCUED);
> -       else if (!was_unevictable && is_unevictable)
> -               count_vm_event(UNEVICTABLE_PGCULLED);
> -
> +       lru_cache_add(page);
>         put_page(page);         /* drop ref from isolate */
>  }
>
> --
> 2.15.0.403.gc27cc4dac6-goog
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
