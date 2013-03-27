Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id D9C336B0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 01:03:27 -0400 (EDT)
Received: by mail-ia0-f170.google.com with SMTP id h8so7199227iaa.29
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 22:03:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1364350932-12853-1-git-send-email-minchan@kernel.org>
References: <1364350932-12853-1-git-send-email-minchan@kernel.org>
Date: Wed, 27 Mar 2013 14:03:27 +0900
Message-ID: <CAH9JG2U5LPo4e75-kTAtmzwRdtvmPUzCkO=Esc6H89tF4+vEuw@mail.gmail.com>
Subject: Re: [RFC] mm: remove swapcache page early
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>, kw46.nam@samsung.com

Hi,

On Wed, Mar 27, 2013 at 11:22 AM, Minchan Kim <minchan@kernel.org> wrote:
> Swap subsystem does lazy swap slot free with expecting the page
> would be swapped out again so we can't avoid unnecessary write.
>
> But the problem in in-memory swap is that it consumes memory space
> until vm_swap_full(ie, used half of all of swap device) condition
> meet. It could be bad if we use multiple swap device, small in-memory swap
> and big storage swap or in-memory swap alone.
>
> This patch changes vm_swap_full logic slightly so it could free
> swap slot early if the backed device is really fast.
> For it, I used SWP_SOLIDSTATE but It might be controversial.
> So let's add Ccing Shaohua and Hugh.
> If it's a problem for SSD, I'd like to create new type SWP_INMEMORY
> or something for z* family.
I perfer to add new SWP_INMEMORY for z* family. as you know SSD and
memory is different characteristics.
and if new type is added, it doesn't need to modify lots of codes.

Do you have any data for it? do you get meaningful performance gain or
efficiency of z* family? If yes, please share it.

Thank you,
Kyungmin Park

>
> Other problem is zram is block device so that it can set SWP_INMEMORY
> or SWP_SOLIDSTATE easily(ie, actually, zram is already done) but
> I have no idea to use it for frontswap.
>
> Any idea?
>
> Other optimize point is we remove it unconditionally when we
> found it's exclusive when swap in happen.
> It could help frontswap family, too.
> What do you think about it?
>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
> Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>
> Cc: Shaohua Li <shli@kernel.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  include/linux/swap.h | 11 ++++++++---
>  mm/memory.c          |  3 ++-
>  mm/swapfile.c        | 11 +++++++----
>  mm/vmscan.c          |  2 +-
>  4 files changed, 18 insertions(+), 9 deletions(-)
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 2818a12..1f4df66 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -359,9 +359,14 @@ extern struct page *swapin_readahead(swp_entry_t, gfp_t,
>  extern atomic_long_t nr_swap_pages;
>  extern long total_swap_pages;
>
> -/* Swap 50% full? Release swapcache more aggressively.. */
> -static inline bool vm_swap_full(void)
> +/*
> + * Swap 50% full or fast backed device?
> + * Release swapcache more aggressively.
> + */
> +static inline bool vm_swap_full(struct swap_info_struct *si)
>  {
> +       if (si->flags & SWP_SOLIDSTATE)
> +               return true;
>         return atomic_long_read(&nr_swap_pages) * 2 < total_swap_pages;
>  }
>
> @@ -405,7 +410,7 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
>  #define get_nr_swap_pages()                    0L
>  #define total_swap_pages                       0L
>  #define total_swapcache_pages()                        0UL
> -#define vm_swap_full()                         0
> +#define vm_swap_full(si)                       0
>
>  #define si_swapinfo(val) \
>         do { (val)->freeswap = (val)->totalswap = 0; } while (0)
> diff --git a/mm/memory.c b/mm/memory.c
> index 705473a..1ca21a9 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3084,7 +3084,8 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
>         mem_cgroup_commit_charge_swapin(page, ptr);
>
>         swap_free(entry);
> -       if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
> +       if (likely(PageSwapCache(page)) && (vm_swap_full(page_swap_info(page))
> +                       || (vma->vm_flags & VM_LOCKED) || PageMlocked(page)))
>                 try_to_free_swap(page);
>         unlock_page(page);
>         if (page != swapcache) {
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 1bee6fa..f9cc701 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -293,7 +293,7 @@ checks:
>                 scan_base = offset = si->lowest_bit;
>
>         /* reuse swap entry of cache-only swap if not busy. */
> -       if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
> +       if (vm_swap_full(si) && si->swap_map[offset] == SWAP_HAS_CACHE) {
>                 int swap_was_freed;
>                 spin_unlock(&si->lock);
>                 swap_was_freed = __try_to_reclaim_swap(si, offset);
> @@ -382,7 +382,8 @@ scan:
>                         spin_lock(&si->lock);
>                         goto checks;
>                 }
> -               if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
> +               if (vm_swap_full(si) &&
> +                       si->swap_map[offset] == SWAP_HAS_CACHE) {
>                         spin_lock(&si->lock);
>                         goto checks;
>                 }
> @@ -397,7 +398,8 @@ scan:
>                         spin_lock(&si->lock);
>                         goto checks;
>                 }
> -               if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
> +               if (vm_swap_full(si) &&
> +                       si->swap_map[offset] == SWAP_HAS_CACHE) {
>                         spin_lock(&si->lock);
>                         goto checks;
>                 }
> @@ -763,7 +765,8 @@ int free_swap_and_cache(swp_entry_t entry)
>                  * Also recheck PageSwapCache now page is locked (above).
>                  */
>                 if (PageSwapCache(page) && !PageWriteback(page) &&
> -                               (!page_mapped(page) || vm_swap_full())) {
> +                               (!page_mapped(page) ||
> +                                 vm_swap_full(page_swap_info(page)))) {
>                         delete_from_swap_cache(page);
>                         SetPageDirty(page);
>                 }
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index df78d17..145c59c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -933,7 +933,7 @@ cull_mlocked:
>
>  activate_locked:
>                 /* Not a candidate for swapping, so reclaim swap space. */
> -               if (PageSwapCache(page) && vm_swap_full())
> +               if (PageSwapCache(page) && vm_swap_full(page_swap_info(page)))
>                         try_to_free_swap(page);
>                 VM_BUG_ON(PageActive(page));
>                 SetPageActive(page);
> --
> 1.8.2
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
