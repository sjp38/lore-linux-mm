Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 175516B00A6
	for <linux-mm@kvack.org>; Mon,  5 May 2014 11:51:21 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u56so7817530wes.28
        for <linux-mm@kvack.org>; Mon, 05 May 2014 08:51:21 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id ej2si3286041wib.118.2014.05.05.08.51.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 May 2014 08:51:20 -0700 (PDT)
Received: by mail-wi0-f179.google.com with SMTP id bs8so5790170wib.0
        for <linux-mm@kvack.org>; Mon, 05 May 2014 08:51:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1399057350-16300-5-git-send-email-ddstreet@ieee.org>
References: <1397336454-13855-1-git-send-email-ddstreet@ieee.org>
 <1399057350-16300-1-git-send-email-ddstreet@ieee.org> <1399057350-16300-5-git-send-email-ddstreet@ieee.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 5 May 2014 11:51:00 -0400
Message-ID: <CALZtONDMJiQVQDKAnLNt2tyLo6d9EaEtSog9RQELNEN6hjVUdA@mail.gmail.com>
Subject: Re: [PATCH 4/4] swap: change swap_list_head to plist, add swap_avail_head
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Dan Streetman <ddstreet@ieee.org>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Weijie Yang <weijieut@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Shaohua Li <shli@fusionio.com>

On Fri, May 2, 2014 at 3:02 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> Originally get_swap_page() started iterating through the singly-linked
> list of swap_info_structs using swap_list.next or highest_priority_index,
> which both were intended to point to the highest priority active swap
> target that was not full.  The first patch in this series changed the
> singly-linked list to a doubly-linked list, and removed the logic to start
> at the highest priority non-full entry; it starts scanning at the highest
> priority entry each time, even if the entry is full.
>
> Replace the manually ordered swap_list_head with a plist, renamed to
> swap_active_head for clarity.  Add a new plist, swap_avail_head.
> The original swap_active_head plist contains all active swap_info_structs,
> as before, while the new swap_avail_head plist contains only
> swap_info_structs that are active and available, i.e. not full.
> Add a new spinlock, swap_avail_lock, to protect the swap_avail_head list.
>
> Mel Gorman suggested using plists since they internally handle ordering
> the list entries based on priority, which is exactly what swap was doing
> manually.  All the ordering code is now removed, and swap_info_struct
> entries and simply added to their corresponding plist and automatically
> ordered correctly.
>
> Using a new plist for available swap_info_structs simplifies and
> optimizes get_swap_page(), which no longer has to iterate over full
> swap_info_structs.  Using a new spinlock for swap_avail_head plist
> allows each swap_info_struct to add or remove themselves from the
> plist when they become full or not-full; previously they could not
> do so because the swap_info_struct->lock is held when they change
> from full<->not-full, and the swap_lock protecting the main
> swap_active_head must be ordered before any swap_info_struct->lock.
>
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Shaohua Li <shli@fusionio.com>
>
> ---
>
> Mel, I tried moving the ordering and rotating code into common list functions
> and I also tried plists, and you were right, using plists is much simpler and
> more maintainable.  The only required update to plist is the plist_rotate()
> function, which is even simpler to use in get_swap_page() than the
> list_rotate_left() function.
>
> After looking more closely at plists, I don't see how they would reduce
> performance, so I don't think there is any concern there, although Shaohua if
> you have time it might be nice to check this updated patch set's performance.
> I will note that if CONFIG_DEBUG_PI_LIST is set, there's quite a lot of list
> checking going on for each list modification including rotate; that config is
> set if "RT Mutex debugging, deadlock detection" is set, so I assume in that
> case overall system performance is expected to be less than optimal.
>
> Also, I might have over-commented in this patch; if so I can remove/reduce
> some of it. :)
>
> Changelog since v1 https://lkml.org/lkml/2014/4/12/73
>   -use plists instead of regular lists
>   -update/add comments
>
>  include/linux/swap.h     |   3 +-
>  include/linux/swapfile.h |   2 +-
>  mm/frontswap.c           |   6 +-
>  mm/swapfile.c            | 142 +++++++++++++++++++++++++++++------------------
>  4 files changed, 94 insertions(+), 59 deletions(-)
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 8bb85d6..9155bcd 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -214,7 +214,8 @@ struct percpu_cluster {
>  struct swap_info_struct {
>         unsigned long   flags;          /* SWP_USED etc: see above */
>         signed short    prio;           /* swap priority of this type */
> -       struct list_head list;          /* entry in swap list */
> +       struct plist_node list;         /* entry in swap_active_head */
> +       struct plist_node avail_list;   /* entry in swap_avail_head */
>         signed char     type;           /* strange name for an index */
>         unsigned int    max;            /* extent of the swap_map */
>         unsigned char *swap_map;        /* vmalloc'ed array of usage counts */
> diff --git a/include/linux/swapfile.h b/include/linux/swapfile.h
> index 2eab382..388293a 100644
> --- a/include/linux/swapfile.h
> +++ b/include/linux/swapfile.h
> @@ -6,7 +6,7 @@
>   * want to expose them to the dozens of source files that include swap.h
>   */
>  extern spinlock_t swap_lock;
> -extern struct list_head swap_list_head;
> +extern struct plist_head swap_active_head;
>  extern struct swap_info_struct *swap_info[];
>  extern int try_to_unuse(unsigned int, bool, unsigned long);
>
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index fae1160..c30eec5 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -331,7 +331,7 @@ static unsigned long __frontswap_curr_pages(void)
>         struct swap_info_struct *si = NULL;
>
>         assert_spin_locked(&swap_lock);
> -       list_for_each_entry(si, &swap_list_head, list)
> +       plist_for_each_entry(si, &swap_active_head, list)
>                 totalpages += atomic_read(&si->frontswap_pages);
>         return totalpages;
>  }
> @@ -346,7 +346,7 @@ static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
>         unsigned long pages = 0, pages_to_unuse = 0;
>
>         assert_spin_locked(&swap_lock);
> -       list_for_each_entry(si, &swap_list_head, list) {
> +       plist_for_each_entry(si, &swap_active_head, list) {
>                 si_frontswap_pages = atomic_read(&si->frontswap_pages);
>                 if (total_pages_to_unuse < si_frontswap_pages) {
>                         pages = pages_to_unuse = total_pages_to_unuse;
> @@ -408,7 +408,7 @@ void frontswap_shrink(unsigned long target_pages)
>         /*
>          * we don't want to hold swap_lock while doing a very
>          * lengthy try_to_unuse, but swap_list may change
> -        * so restart scan from swap_list_head each time
> +        * so restart scan from swap_active_head each time
>          */
>         spin_lock(&swap_lock);
>         ret = __frontswap_shrink(target_pages, &pages_to_unuse, &type);
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 6c95a8c..ec230e3 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -61,7 +61,22 @@ static const char Unused_offset[] = "Unused swap offset entry ";
>   * all active swap_info_structs
>   * protected with swap_lock, and ordered by priority.
>   */
> -LIST_HEAD(swap_list_head);
> +PLIST_HEAD(swap_active_head);
> +
> +/*
> + * all available (active, not full) swap_info_structs
> + * protected with swap_avail_lock, ordered by priority.
> + * This is used by get_swap_page() instead of swap_active_head
> + * because swap_active_head includes all swap_info_structs,
> + * but get_swap_page() doesn't need to look at full ones.
> + * This uses its own lock instead of swap_lock because when a
> + * swap_info_struct changes between not-full/full, it needs to
> + * add/remove itself to/from this list, but the swap_info_struct->lock
> + * is held and the locking order requires swap_lock to be taken
> + * before any swap_info_struct->lock.
> + */
> +static PLIST_HEAD(swap_avail_head);
> +static DEFINE_SPINLOCK(swap_avail_lock);
>
>  struct swap_info_struct *swap_info[MAX_SWAPFILES];
>
> @@ -594,6 +609,9 @@ checks:
>         if (si->inuse_pages == si->pages) {
>                 si->lowest_bit = si->max;
>                 si->highest_bit = 0;
> +               spin_lock(&swap_avail_lock);
> +               plist_del(&si->avail_list, &swap_avail_head);
> +               spin_unlock(&swap_avail_lock);
>         }
>         si->swap_map[offset] = usage;
>         inc_cluster_info_page(si, si->cluster_info, offset);
> @@ -645,57 +663,60 @@ swp_entry_t get_swap_page(void)
>  {
>         struct swap_info_struct *si, *next;
>         pgoff_t offset;
> -       struct list_head *tmp;
>
> -       spin_lock(&swap_lock);
>         if (atomic_long_read(&nr_swap_pages) <= 0)
>                 goto noswap;
>         atomic_long_dec(&nr_swap_pages);
>
> -       list_for_each(tmp, &swap_list_head) {
> -               si = list_entry(tmp, typeof(*si), list);
> +       spin_lock(&swap_avail_lock);
> +start_over:
> +       plist_for_each_entry_safe(si, next, &swap_avail_head, avail_list) {
> +               /* rotate si to tail of same-priority siblings */
> +               plist_rotate(&si->avail_list, &swap_avail_head);
> +               spin_unlock(&swap_avail_lock);
>                 spin_lock(&si->lock);
>                 if (!si->highest_bit || !(si->flags & SWP_WRITEOK)) {
> +                       spin_lock(&swap_avail_lock);
> +                       if (plist_node_empty(&si->avail_list)) {
> +                               spin_unlock(&si->lock);
> +                               goto nextsi;
> +                       }
> +                       WARN(!si->highest_bit,
> +                            "swap_info %d in list but !highest_bit\n",
> +                            si->type);
> +                       WARN(!(si->flags & SWP_WRITEOK),
> +                            "swap_info %d in list but !SWP_WRITEOK\n",
> +                            si->type);
> +                       plist_del(&si->avail_list, &swap_avail_head);
>                         spin_unlock(&si->lock);
> -                       continue;
> +                       goto nextsi;
>                 }
>
> -               /*
> -                * rotate the current swap_info that we're going to use
> -                * to after any other swap_info that have the same prio,
> -                * so that all equal-priority swap_info get used equally
> -                */
> -               next = si;
> -               list_for_each_entry_continue(next, &swap_list_head, list) {
> -                       if (si->prio != next->prio)
> -                               break;
> -                       list_rotate_left(&si->list);
> -                       next = si;
> -               }
> -
> -               spin_unlock(&swap_lock);
>                 /* This is called for allocating swap entry for cache */
>                 offset = scan_swap_map(si, SWAP_HAS_CACHE);
>                 spin_unlock(&si->lock);
>                 if (offset)
>                         return swp_entry(si->type, offset);
> -               spin_lock(&swap_lock);
> +               pr_debug("scan_swap_map of si %d failed to find offset\n",
> +                      si->type);

I forgot to mention I changed this from printk(KERN_DEBUG to pr_debug
between v1 and v2.  Not sure if a scan_swap_map() failure should be
always printed or only during debug...

> +               spin_lock(&swap_avail_lock);
> +nextsi:
>                 /*
>                  * if we got here, it's likely that si was almost full before,
>                  * and since scan_swap_map() can drop the si->lock, multiple
>                  * callers probably all tried to get a page from the same si
> -                * and it filled up before we could get one.  So we need to
> -                * try again.  Since we dropped the swap_lock, there may now
> -                * be non-full higher priority swap_infos, and this si may have
> -                * even been removed from the list (although very unlikely).
> -                * Let's start over.
> +                * and it filled up before we could get one; or, the si filled
> +                * up between us dropping swap_avail_lock and taking si->lock.
> +                * Since we dropped the swap_avail_lock, the swap_avail_head
> +                * list may have been modified; so if next is still in the
> +                * swap_avail_head list then try it, otherwise start over.
>                  */
> -               tmp = &swap_list_head;
> +               if (plist_node_empty(&next->avail_list))
> +                       goto start_over;

One note I want to point out...if we get here, we tried the highest
priority swap_info_struct, and it filled up; so the options are
either:
1. start over at the beginning
2. continue at next

Under most circumstances, the beginning == next.  But, a higher
priority swap_info_struct may have freed page(s) and been added back
into the list.

The danger of continuing with next, if it's still in the list, appears
(to me) to be if next was the last swap_info_struct in the list, and
it also fills up and fails, then get_swap_page() will fail, even
though there may be higher priority swap_info_struct(s) that became
available.

However the danger of starting over in every case, I think, is
continuing to fail repeatedly in scan_swap_map() - for example under
heavy swap, if swap_info_struct(s) are bouncing between full and
not-full (I don't know how likely/common this is).  Especially if
there are lower priority swap_info_struct(s) with plenty of room, that
may unnecessarily delay threads trying to get a swap page.

So I'm not sure if doing it this way, continuing with next, is better
than just always starting over.

One option may be to continue at next, but also after the
plist_for_each_safe loop (i.e. complete failure), do:

if (!plist_head_empty(&swap_avail_head))
  goto start_over;

so as to prevent a get_swap_page() failure when there actually are
still some pages available...of course, that probably would only ever
get reached if the system is very, very close to completely filling up
swap, so will it really matter if get_swap_page() fails slightly
before all swap is full or if threads battle until the bitter end when
there is actually no swap left...


>         }
>
>         atomic_long_inc(&nr_swap_pages);
>  noswap:
> -       spin_unlock(&swap_lock);
>         return (swp_entry_t) {0};
>  }
>
> @@ -798,8 +819,18 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
>                 dec_cluster_info_page(p, p->cluster_info, offset);
>                 if (offset < p->lowest_bit)
>                         p->lowest_bit = offset;
> -               if (offset > p->highest_bit)
> +               if (offset > p->highest_bit) {
> +                       bool was_full = !p->highest_bit;
>                         p->highest_bit = offset;
> +                       if (was_full && (p->flags & SWP_WRITEOK)) {
> +                               spin_lock(&swap_avail_lock);
> +                               WARN_ON(!plist_node_empty(&p->avail_list));
> +                               if (plist_node_empty(&p->avail_list))
> +                                       plist_add(&p->avail_list,
> +                                                 &swap_avail_head);
> +                               spin_unlock(&swap_avail_lock);
> +                       }
> +               }
>                 atomic_long_inc(&nr_swap_pages);
>                 p->inuse_pages--;
>                 frontswap_invalidate_page(p->type, offset);
> @@ -1734,12 +1765,16 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
>                                 unsigned char *swap_map,
>                                 struct swap_cluster_info *cluster_info)
>  {
> -       struct swap_info_struct *si;
> -
>         if (prio >= 0)
>                 p->prio = prio;
>         else
>                 p->prio = --least_priority;
> +       /*
> +        * the plist prio is negated because plist ordering is
> +        * low-to-high, while swap ordering is high-to-low
> +        */
> +       p->list.prio = -p->prio;
> +       p->avail_list.prio = -p->prio;
>         p->swap_map = swap_map;
>         p->cluster_info = cluster_info;
>         p->flags |= SWP_WRITEOK;
> @@ -1747,27 +1782,20 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
>         total_swap_pages += p->pages;
>
>         assert_spin_locked(&swap_lock);
> -       BUG_ON(!list_empty(&p->list));
> -       /*
> -        * insert into swap list; the list is in priority order,
> -        * so that get_swap_page() can get a page from the highest
> -        * priority swap_info_struct with available page(s), and
> -        * swapoff can adjust the auto-assigned (i.e. negative) prio
> -        * values for any lower-priority swap_info_structs when
> -        * removing a negative-prio swap_info_struct
> -        */
> -       list_for_each_entry(si, &swap_list_head, list) {
> -               if (p->prio >= si->prio) {
> -                       list_add_tail(&p->list, &si->list);
> -                       return;
> -               }
> -       }
>         /*
> -        * this covers two cases:
> -        * 1) p->prio is less than all existing prio
> -        * 2) the swap list is empty
> +        * both lists are plists, and thus priority ordered.
> +        * swap_active_head needs to be priority ordered for swapoff(),
> +        * which on removal of any swap_info_struct with an auto-assigned
> +        * (i.e. negative) priority increments the auto-assigned priority
> +        * of any lower-priority swap_info_structs.
> +        * swap_avail_head needs to be priority ordered for get_swap_page(),
> +        * which allocates swap pages from the highest available priority
> +        * swap_info_struct.
>          */
> -       list_add_tail(&p->list, &swap_list_head);
> +       plist_add(&p->list, &swap_active_head);
> +       spin_lock(&swap_avail_lock);
> +       plist_add(&p->avail_list, &swap_avail_head);
> +       spin_unlock(&swap_avail_lock);
>  }
>
>  static void enable_swap_info(struct swap_info_struct *p, int prio,
> @@ -1821,7 +1849,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>
>         mapping = victim->f_mapping;
>         spin_lock(&swap_lock);
> -       list_for_each_entry(p, &swap_list_head, list) {
> +       plist_for_each_entry(p, &swap_active_head, list) {
>                 if (p->flags & SWP_WRITEOK) {
>                         if (p->swap_file->f_mapping == mapping) {
>                                 found = 1;
> @@ -1841,16 +1869,21 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>                 spin_unlock(&swap_lock);
>                 goto out_dput;
>         }
> +       spin_lock(&swap_avail_lock);
> +       plist_del(&p->avail_list, &swap_avail_head);
> +       spin_unlock(&swap_avail_lock);
>         spin_lock(&p->lock);
>         if (p->prio < 0) {
>                 struct swap_info_struct *si = p;
>
> -               list_for_each_entry_continue(si, &swap_list_head, list) {
> +               plist_for_each_entry_continue(si, &swap_active_head, list) {
>                         si->prio++;
> +                       si->list.prio--;
> +                       si->avail_list.prio--;
>                 }
>                 least_priority++;
>         }
> -       list_del_init(&p->list);
> +       plist_del(&p->list, &swap_active_head);
>         atomic_long_sub(p->pages, &nr_swap_pages);
>         total_swap_pages -= p->pages;
>         p->flags &= ~SWP_WRITEOK;
> @@ -2115,7 +2148,8 @@ static struct swap_info_struct *alloc_swap_info(void)
>                  */
>         }
>         INIT_LIST_HEAD(&p->first_swap_extent.list);
> -       INIT_LIST_HEAD(&p->list);
> +       plist_node_init(&p->list, 0);
> +       plist_node_init(&p->avail_list, 0);
>         p->flags = SWP_USED;
>         spin_unlock(&swap_lock);
>         spin_lock_init(&p->lock);
> --
> 1.8.3.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
