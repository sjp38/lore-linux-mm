Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 00AF06B0007
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 03:13:35 -0500 (EST)
Received: by mail-ie0-f172.google.com with SMTP id c10so10900026ieb.17
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 00:13:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130221021710.GA32580@kernel.org>
References: <20130221021710.GA32580@kernel.org>
Date: Thu, 21 Feb 2013 17:13:35 +0900
Message-ID: <CAH9JG2XmbeNgVmd1gMkOxsa3v6J9pOZed6CYXUeSaiyLhTnMJg@mail.gmail.com>
Subject: Re: [patch 1/4 v3]swap: change block allocation algorithm for SSD
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, minchan@kernel.org

Hi,

It's not related topic with this patch, but now I'm integrating with
zswap with this patch but zswap uses each own writeback codes so it
can't use this cluster concept.

I'm still can't find proper approaches to integrate zswap (+writeback)
with this concept.

Do you have any ideas or plan to work with zswap?

Thank you,
Kyungmin Park

On Thu, Feb 21, 2013 at 11:17 AM, Shaohua Li <shli@kernel.org> wrote:
> I'm using a fast SSD to do swap. scan_swap_map() sometimes uses up to 20~30%
> CPU time (when cluster is hard to find, the CPU time can be up to 80%), which
> becomes a bottleneck.  scan_swap_map() scans a byte array to search a 256 page
> cluster, which is very slow.
>
> Here I introduced a simple algorithm to search cluster. Since we only care
> about 256 pages cluster, we can just use a counter to track if a cluster is
> free. Every 256 pages use one int to store the counter. If the counter of a
> cluster is 0, the cluster is free. All free clusters will be added to a list,
> so searching cluster is very efficient. With this, scap_swap_map() overhead
> disappears.
>
> Since searching cluster with a list is easy, we can easily implement a per-cpu
> cluster algorithm to do block allocation, which can make swapout more
> efficient. This is in my TODO list.
>
> This might help low end SD card swap too. Because if the cluster is aligned, SD
> firmware can do flash erase more efficiently.
>
> We only enable the algorithm for SSD. Hard disk swap isn't fast enough and has
> downside with the algorithm which might introduce regression (see below).
>
> The patch slightly changes which cluster is choosen. It always adds free
> cluster to list tail. This can help wear leveling for low end SSD too. And if
> no cluster found, the scan_swap_map() will do search from the end of last
> cluster. So if no cluster found, the scan_swap_map() will do search from the
> end of last free cluster, which is random. For SSD, this isn't a problem at
> all.
>
> Another downside is the cluster must be aligned to 256 pages, which will reduce
> the chance to find a cluster. I would expect this isn't a big problem for SSD
> because of the non-seek penality. (And this is the reason I only enable the
> algorithm for SSD).
>
> V2 -> V3:
> rebase to latest linux-next
>
> V1 -> V2:
> 1. free cluster is added to a list, which makes searching cluster more efficient
> 2. only enable the algorithm for SSD.
>
> Signed-off-by: Shaohua Li <shli@fusionio.com>
> ---
>  include/linux/swap.h |    3
>  mm/swapfile.c        |  181 +++++++++++++++++++++++++++++++++++++++++++++++----
>  2 files changed, 172 insertions(+), 12 deletions(-)
>
> Index: linux/include/linux/swap.h
> ===================================================================
> --- linux.orig/include/linux/swap.h     2013-02-18 15:06:06.000000000 +0800
> +++ linux/include/linux/swap.h  2013-02-18 15:21:09.285317914 +0800
> @@ -185,6 +185,9 @@ struct swap_info_struct {
>         signed char     next;           /* next type on the swap list */
>         unsigned int    max;            /* extent of the swap_map */
>         unsigned char *swap_map;        /* vmalloc'ed array of usage counts */
> +       unsigned int *cluster_info;     /* cluster info. Only for SSD */
> +       unsigned int free_cluster_head;
> +       unsigned int free_cluster_tail;
>         unsigned int lowest_bit;        /* index of first free in swap_map */
>         unsigned int highest_bit;       /* index of last free in swap_map */
>         unsigned int pages;             /* total of usable pages of swap */
> Index: linux/mm/swapfile.c
> ===================================================================
> --- linux.orig/mm/swapfile.c    2013-02-18 15:06:06.000000000 +0800
> +++ linux/mm/swapfile.c 2013-02-18 15:21:09.285317914 +0800
> @@ -184,6 +184,85 @@ static int wait_for_discard(void *word)
>  #define SWAPFILE_CLUSTER       256
>  #define LATENCY_LIMIT          256
>
> +/*
> + * cluster info is a unsigned int, the highest 8 bits stores flags, the low 24
> + * bits stores next cluster if the cluster is free or cluster counter otherwise
> + */
> +#define CLUSTER_FLAG_FREE (1 << 0)
> +#define CLUSTER_FLAG_NEXT_NULL (1 << 1)
> +#define CLUSTER_NULL (CLUSTER_FLAG_NEXT_NULL << 24)
> +#define cluster_flag(info) ((info) >> 24)
> +#define cluster_set_flag(info, flag) \
> +       do { info = ((info) & 0xffffff) | ((flag) << 24); } while (0)
> +#define cluster_count(info) ((info) & 0xffffff)
> +#define cluster_set_count(info, c) \
> +       do { info = (cluster_flag(info) << 24) | (c); } while (0)
> +#define cluster_next(info) ((info) & 0xffffff)
> +#define cluster_set_next(info, n) \
> +       do { info = (cluster_flag(info) << 24) | (n); } while (0)
> +#define cluster_is_free(info) (cluster_flag(info) & CLUSTER_FLAG_FREE)
> +
> +static inline void inc_cluster_info_page(struct swap_info_struct *p,
> +       unsigned int *cluster_info, unsigned long page_nr)
> +{
> +       unsigned long idx = page_nr / SWAPFILE_CLUSTER;
> +
> +       if (!cluster_info)
> +               return;
> +       if (cluster_is_free(cluster_info[idx])) {
> +               VM_BUG_ON(p->free_cluster_head != idx);
> +               p->free_cluster_head = cluster_next(cluster_info[idx]);
> +               if (p->free_cluster_tail == idx) {
> +                       p->free_cluster_tail = CLUSTER_NULL;
> +                       p->free_cluster_head = CLUSTER_NULL;
> +               }
> +               cluster_set_flag(cluster_info[idx], 0);
> +               cluster_set_count(cluster_info[idx], 0);
> +       }
> +
> +       VM_BUG_ON(cluster_count(cluster_info[idx]) >= SWAPFILE_CLUSTER);
> +       cluster_set_count(cluster_info[idx],
> +               cluster_count(cluster_info[idx]) + 1);
> +}
> +
> +static inline void dec_cluster_info_page(struct swap_info_struct *p,
> +       unsigned int *cluster_info, unsigned long page_nr)
> +{
> +       unsigned long idx = page_nr / SWAPFILE_CLUSTER;
> +
> +       if (!cluster_info)
> +               return;
> +
> +       VM_BUG_ON(cluster_count(cluster_info[idx]) == 0);
> +       cluster_set_count(cluster_info[idx],
> +               cluster_count(cluster_info[idx]) - 1);
> +
> +       if (cluster_count(cluster_info[idx]) == 0) {
> +               cluster_set_flag(cluster_info[idx], CLUSTER_FLAG_FREE);
> +               if (p->free_cluster_head == CLUSTER_NULL) {
> +                       p->free_cluster_head = idx;
> +                       p->free_cluster_tail = idx;
> +               } else {
> +                       cluster_set_next(cluster_info[p->free_cluster_tail],
> +                               idx);
> +                       p->free_cluster_tail = idx;
> +               }
> +       }
> +}
> +
> +/*
> + * It's possible scan_swap_map() uses a free cluster in the middle of free
> + * cluster list. Avoiding such abuse to avoid list corruption.
> + */
> +static inline bool scan_swap_map_recheck_cluster(struct swap_info_struct *si,
> +       unsigned long offset)
> +{
> +       offset /= SWAPFILE_CLUSTER;
> +       return si->free_cluster_head != CLUSTER_NULL &&
> +               offset != si->free_cluster_head &&
> +               cluster_is_free(si->cluster_info[offset]);
> +}
> +
>  static unsigned long scan_swap_map(struct swap_info_struct *si,
>                                    unsigned char usage)
>  {
> @@ -225,6 +304,24 @@ static unsigned long scan_swap_map(struc
>                         si->lowest_alloc = si->max;
>                         si->highest_alloc = 0;
>                 }
> +check_cluster:
> +               if (si->free_cluster_head != CLUSTER_NULL) {
> +                       offset = si->free_cluster_head * SWAPFILE_CLUSTER;
> +                       last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
> +                       si->cluster_next = offset;
> +                       si->cluster_nr = SWAPFILE_CLUSTER - 1;
> +                       found_free_cluster = 1;
> +                       goto checks;
> +               } else if (si->cluster_info) {
> +                       /*
> +                        * Checking free cluster is fast enough, we can do the
> +                        * check every time
> +                        */
> +                       si->cluster_nr = 0;
> +                       si->lowest_alloc = 0;
> +                       goto checks;
> +               }
> +
>                 spin_unlock(&si->lock);
>
>                 /*
> @@ -285,6 +382,8 @@ static unsigned long scan_swap_map(struc
>         }
>
>  checks:
> +       if (scan_swap_map_recheck_cluster(si, offset))
> +               goto check_cluster;
>         if (!(si->flags & SWP_WRITEOK))
>                 goto no_page;
>         if (!si->highest_bit)
> @@ -317,6 +416,7 @@ checks:
>                 si->highest_bit = 0;
>         }
>         si->swap_map[offset] = usage;
> +       inc_cluster_info_page(si, si->cluster_info, offset);
>         si->cluster_next = offset + 1;
>         si->flags -= SWP_SCANNING;
>
> @@ -600,6 +700,7 @@ static unsigned char swap_entry_free(str
>
>         /* free if no reference */
>         if (!usage) {
> +               dec_cluster_info_page(p, p->cluster_info, offset);
>                 if (offset < p->lowest_bit)
>                         p->lowest_bit = offset;
>                 if (offset > p->highest_bit)
> @@ -1497,6 +1598,7 @@ static int setup_swap_extents(struct swa
>
>  static void _enable_swap_info(struct swap_info_struct *p, int prio,
>                                 unsigned char *swap_map,
> +                               unsigned int *cluster_info,
>                                 unsigned long *frontswap_map)
>  {
>         int i, prev;
> @@ -1506,6 +1608,7 @@ static void _enable_swap_info(struct swa
>         else
>                 p->prio = --least_priority;
>         p->swap_map = swap_map;
> +       p->cluster_info = cluster_info;
>         frontswap_map_set(p, frontswap_map);
>         p->flags |= SWP_WRITEOK;
>         atomic_long_add(p->pages, &nr_swap_pages);
> @@ -1527,11 +1630,12 @@ static void _enable_swap_info(struct swa
>
>  static void enable_swap_info(struct swap_info_struct *p, int prio,
>                                 unsigned char *swap_map,
> +                               unsigned int *cluster_info,
>                                 unsigned long *frontswap_map)
>  {
>         spin_lock(&swap_lock);
>         spin_lock(&p->lock);
> -       _enable_swap_info(p, prio, swap_map, frontswap_map);
> +       _enable_swap_info(p, prio, swap_map, cluster_info, frontswap_map);
>         frontswap_init(p->type);
>         spin_unlock(&p->lock);
>         spin_unlock(&swap_lock);
> @@ -1541,7 +1645,8 @@ static void reinsert_swap_info(struct sw
>  {
>         spin_lock(&swap_lock);
>         spin_lock(&p->lock);
> -       _enable_swap_info(p, p->prio, p->swap_map, frontswap_map_get(p));
> +       _enable_swap_info(p, p->prio, p->swap_map, p->cluster_info,
> +                                       frontswap_map_get(p));
>         spin_unlock(&p->lock);
>         spin_unlock(&swap_lock);
>  }
> @@ -1550,6 +1655,7 @@ SYSCALL_DEFINE1(swapoff, const char __us
>  {
>         struct swap_info_struct *p = NULL;
>         unsigned char *swap_map;
> +       unsigned int *cluster_info;
>         struct file *swap_file, *victim;
>         struct address_space *mapping;
>         struct inode *inode;
> @@ -1648,12 +1754,15 @@ SYSCALL_DEFINE1(swapoff, const char __us
>         p->max = 0;
>         swap_map = p->swap_map;
>         p->swap_map = NULL;
> +       cluster_info = p->cluster_info;
> +       p->cluster_info = NULL;
>         p->flags = 0;
>         frontswap_invalidate_area(type);
>         spin_unlock(&p->lock);
>         spin_unlock(&swap_lock);
>         mutex_unlock(&swapon_mutex);
>         vfree(swap_map);
> +       vfree(cluster_info);
>         vfree(frontswap_map_get(p));
>         /* Destroy swap account informatin */
>         swap_cgroup_swapoff(type);
> @@ -1966,15 +2075,21 @@ static unsigned long read_swap_header(st
>  static int setup_swap_map_and_extents(struct swap_info_struct *p,
>                                         union swap_header *swap_header,
>                                         unsigned char *swap_map,
> +                                       unsigned int *cluster_info,
>                                         unsigned long maxpages,
>                                         sector_t *span)
>  {
>         int i;
>         unsigned int nr_good_pages;
>         int nr_extents;
> +       unsigned long nr_clusters = DIV_ROUND_UP(maxpages, SWAPFILE_CLUSTER);
> +       unsigned long idx = p->cluster_next / SWAPFILE_CLUSTER;
>
>         nr_good_pages = maxpages - 1;   /* omit header page */
>
> +       p->free_cluster_head = CLUSTER_NULL;
> +       p->free_cluster_tail = CLUSTER_NULL;
> +
>         for (i = 0; i < swap_header->info.nr_badpages; i++) {
>                 unsigned int page_nr = swap_header->info.badpages[i];
>                 if (page_nr == 0 || page_nr > swap_header->info.last_page)
> @@ -1982,11 +2097,25 @@ static int setup_swap_map_and_extents(st
>                 if (page_nr < maxpages) {
>                         swap_map[page_nr] = SWAP_MAP_BAD;
>                         nr_good_pages--;
> +                       /*
> +                        * Not mark the cluster free yet, no list
> +                        * operation involved
> +                        */
> +                       inc_cluster_info_page(p, cluster_info, page_nr);
>                 }
>         }
>
> +       /* Not mark the cluster free yet, no list operation involved */
> +       for (i = maxpages; i < round_up(maxpages, SWAPFILE_CLUSTER); i++)
> +               inc_cluster_info_page(p, cluster_info, i);
> +
>         if (nr_good_pages) {
>                 swap_map[0] = SWAP_MAP_BAD;
> +               /*
> +                * Not mark the cluster free yet, no list
> +                * operation involved
> +                */
> +               inc_cluster_info_page(p, cluster_info, 0);
>                 p->max = maxpages;
>                 p->pages = nr_good_pages;
>                 nr_extents = setup_swap_extents(p, span);
> @@ -1999,6 +2128,27 @@ static int setup_swap_map_and_extents(st
>                 return -EINVAL;
>         }
>
> +       if (!cluster_info)
> +               return nr_extents;
> +
> +       for (i = 0; i < nr_clusters; i++) {
> +               if (!cluster_count(cluster_info[idx])) {
> +                       cluster_set_flag(cluster_info[idx], CLUSTER_FLAG_FREE);
> +                       if (p->free_cluster_head == CLUSTER_NULL) {
> +                               p->free_cluster_head = idx;
> +                               p->free_cluster_tail = idx;
> +                       } else {
> +                               cluster_set_next(
> +                                       cluster_info[p->free_cluster_tail],
> +                                       idx);
> +                               p->free_cluster_tail = idx;
> +                       }
> +               }
> +               idx++;
> +               if (idx == nr_clusters)
> +                       idx = 0;
> +       }
> +
>         return nr_extents;
>  }
>
> @@ -2016,6 +2166,7 @@ SYSCALL_DEFINE2(swapon, const char __use
>         sector_t span;
>         unsigned long maxpages;
>         unsigned char *swap_map = NULL;
> +       unsigned int *cluster_info = NULL;
>         unsigned long *frontswap_map = NULL;
>         struct page *page = NULL;
>         struct inode *inode = NULL;
> @@ -2089,13 +2240,24 @@ SYSCALL_DEFINE2(swapon, const char __use
>                 error = -ENOMEM;
>                 goto bad_swap;
>         }
> +       if (p->bdev && blk_queue_nonrot(bdev_get_queue(p->bdev))) {
> +               p->flags |= SWP_SOLIDSTATE;
> +               p->cluster_next = 1 + (random32() % p->highest_bit);
> +
> +               cluster_info = vzalloc(DIV_ROUND_UP(maxpages,
> +                       SWAPFILE_CLUSTER) * sizeof(*cluster_info));
> +               if (!cluster_info) {
> +                       error = -ENOMEM;
> +                       goto bad_swap;
> +               }
> +       }
>
>         error = swap_cgroup_swapon(p->type, maxpages);
>         if (error)
>                 goto bad_swap;
>
>         nr_extents = setup_swap_map_and_extents(p, swap_header, swap_map,
> -               maxpages, &span);
> +               cluster_info, maxpages, &span);
>         if (unlikely(nr_extents < 0)) {
>                 error = nr_extents;
>                 goto bad_swap;
> @@ -2104,21 +2266,15 @@ SYSCALL_DEFINE2(swapon, const char __use
>         if (frontswap_enabled)
>                 frontswap_map = vzalloc(maxpages / sizeof(long));
>
> -       if (p->bdev) {
> -               if (blk_queue_nonrot(bdev_get_queue(p->bdev))) {
> -                       p->flags |= SWP_SOLIDSTATE;
> -                       p->cluster_next = 1 + (random32() % p->highest_bit);
> -               }
> -               if ((swap_flags & SWAP_FLAG_DISCARD) && discard_swap(p) == 0)
> -                       p->flags |= SWP_DISCARDABLE;
> -       }
> +       if (p->bdev && (swap_flags & SWAP_FLAG_DISCARD) && discard_swap(p) == 0)
> +               p->flags |= SWP_DISCARDABLE;
>
>         mutex_lock(&swapon_mutex);
>         prio = -1;
>         if (swap_flags & SWAP_FLAG_PREFER)
>                 prio =
>                   (swap_flags & SWAP_FLAG_PRIO_MASK) >> SWAP_FLAG_PRIO_SHIFT;
> -       enable_swap_info(p, prio, swap_map, frontswap_map);
> +       enable_swap_info(p, prio, swap_map, cluster_info, frontswap_map);
>
>         printk(KERN_INFO "Adding %uk swap on %s.  "
>                         "Priority:%d extents:%d across:%lluk %s%s%s\n",
> @@ -2148,6 +2304,7 @@ bad_swap:
>         p->flags = 0;
>         spin_unlock(&swap_lock);
>         vfree(swap_map);
> +       vfree(cluster_info);
>         if (swap_file) {
>                 if (inode && S_ISREG(inode->i_mode)) {
>                         mutex_unlock(&inode->i_mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
