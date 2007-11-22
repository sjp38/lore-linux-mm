Received: by nz-out-0506.google.com with SMTP id i11so2577080nzh
        for <linux-mm@kvack.org>; Thu, 22 Nov 2007 03:23:56 -0800 (PST)
Message-ID: <cfd9edbf0711220323v71c1dc84v1d10bda0de93fe51@mail.gmail.com>
Date: Thu, 22 Nov 2007 12:23:55 +0100
From: "=?ISO-8859-1?Q?Daniel_Sp=E5ng?=" <daniel.spang@gmail.com>
Subject: Re: [PATCH] mem notifications v2
In-Reply-To: <20071121195316.GA21481@dmt>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071121195316.GA21481@dmt>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On 11/21/07, Marcelo Tosatti <marcelo@kvack.org> wrote:
> Hi,
>
> Following is an update of the mem notifications patch.
>
> It allows detection of low pressure scenarios (eg. fat browser on
> desktop) by checking if the total amount of anonymous pages is growing
> and if the VM is unmapping pages. This formula also works with swapless
> devices, where the timer on previous versions failed to.
>
> The check for low memory watermarks is retained for cases which kswapd
> can't keep up with the pressure.
>
>
> --- linux-2.6.24-rc2-mm1.orig/Documentation/devices.txt 2007-11-14 23:51:12.000000000 -0200
> +++ linux-2.6.24-rc2-mm1/Documentation/devices.txt      2007-11-15 15:37:22.000000000 -0200
> @@ -96,6 +96,7 @@
>                  11 = /dev/kmsg         Writes to this come out as printk's
>                  12 = /dev/oldmem       Used by crashdump kernels to access
>                                         the memory of the kernel that crashed.
> +                13 = /dev/mem_notify   Low memory notification.
>
>    1 block      RAM disk
>                   0 = /dev/ram0         First RAM disk
> --- linux-2.6.24-rc2-mm1.orig/drivers/char/mem.c        2007-11-14 23:50:47.000000000 -0200
> +++ linux-2.6.24-rc2-mm1/drivers/char/mem.c     2007-11-20 15:16:32.000000000 -0200
> @@ -34,6 +34,8 @@
>  # include <linux/efi.h>
>  #endif
>
> +extern struct file_operations mem_notify_fops;
> +
>  /*
>   * Architectures vary in how they handle caching for addresses
>   * outside of main memory.
> @@ -854,6 +856,9 @@
>                         filp->f_op = &oldmem_fops;
>                         break;
>  #endif
> +               case 13:
> +                       filp->f_op = &mem_notify_fops;
> +                       break;
>                 default:
>                         return -ENXIO;
>         }
> @@ -886,6 +891,7 @@
>  #ifdef CONFIG_CRASH_DUMP
>         {12,"oldmem",    S_IRUSR | S_IWUSR | S_IRGRP, &oldmem_fops},
>  #endif
> +       {13,"mem_notify", S_IRUGO, &mem_notify_fops},
>  };
>
>  static struct class *mem_class;
> --- linux-2.6.24-rc2-mm1.orig/include/linux/swap.h      2007-11-14 23:51:28.000000000 -0200
> +++ linux-2.6.24-rc2-mm1/include/linux/swap.h   2007-11-21 15:40:23.000000000 -0200
> @@ -169,6 +169,8 @@
>  /* Definition of global_page_state not available yet */
>  #define nr_free_pages() global_page_state(NR_FREE_PAGES)
>
> +#define total_anon_pages() (global_page_state(NR_ANON_PAGES) \
> +                           + total_swap_pages - total_swapcache_pages)
>
>  /* linux/mm/swap.c */
>  extern void FASTCALL(lru_cache_add(struct page *));
> @@ -213,6 +215,9 @@
>
>  extern void swap_unplug_io_fn(struct backing_dev_info *, struct page *);
>
> +/* linux/mm/mem_notify.c */
> +void mem_notify_userspace(void);
> +
>  #ifdef CONFIG_SWAP
>  /* linux/mm/page_io.c */
>  extern int swap_readpage(struct file *, struct page *);
> diff -Nur --exclude-from=linux-2.6.24-rc2-mm1/Documentation/dontdiff linux-2.6.24-rc2-mm1.orig/mm/Makefile linux-2.6.24-rc2-mm1/mm/Makefile
> --- linux-2.6.24-rc2-mm1.orig/mm/Makefile       2007-11-14 23:51:07.000000000 -0200
> +++ linux-2.6.24-rc2-mm1/mm/Makefile    2007-11-15 15:38:01.000000000 -0200
> @@ -11,7 +11,7 @@
>                            page_alloc.o page-writeback.o pdflush.o \
>                            readahead.o swap.o truncate.o vmscan.o \
>                            prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
> -                          page_isolation.o $(mmu-y)
> +                          page_isolation.o mem_notify.o $(mmu-y)
>
>  obj-$(CONFIG_PROC_PAGE_MONITOR) += pagewalk.o
>  obj-$(CONFIG_BOUNCE)   += bounce.o
> --- linux-2.6.24-rc2-mm1.orig/mm/mem_notify.c   1969-12-31 21:00:00.000000000 -0300
> +++ linux-2.6.24-rc2-mm1/mm/mem_notify.c        2007-11-21 03:22:39.000000000 -0200
> @@ -0,0 +1,68 @@
> +/*
> + * Notify applications of memory pressure via /dev/mem_notify
> + */
> +
> +#include <linux/module.h>
> +#include <linux/fs.h>
> +#include <linux/wait.h>
> +#include <linux/poll.h>
> +#include <linux/timer.h>
> +#include <linux/spinlock.h>
> +#include <linux/mm.h>
> +#include <linux/vmstat.h>
> +
> +static unsigned long mem_notify_status = 0;
> +
> +DECLARE_WAIT_QUEUE_HEAD(mem_wait);
> +
> +void mem_notify_userspace(void)
> +{
> +       mem_notify_status = 1;

Shouldn't it be a wake_up(&mem_wait) call here? It did not work in
qemu emulator without it.

> +}
> +
> +static int mem_notify_open(struct inode *inode, struct file *file)
> +{
> +       return 0;
> +}
> +
> +static int  (struct inode *inode, struct file *file)
> +{
> +       return 0;
> +}

I think we need to reset mem_notify_status in either mem_notify_open
and/or mem_notify_release. If a process is killed (e.g., by the oom
killer) we could be left with mem_notify_status = 1, causing a new
listening application to get the notification direct when started.

> +
> +static unsigned int mem_notify_poll(struct file *file, poll_table *wait)
> +{
> +       unsigned int val = 0;
> +       struct zone *zone;
> +       int tpages_low, tpages_free, tpages_reserve;
> +
> +       tpages_low = tpages_free = tpages_reserve = 0;
> +
> +       poll_wait(file, &mem_wait, wait);
> +
> +       for_each_zone(zone) {
> +               if (!populated_zone(zone))
> +                       continue;
> +               tpages_low += zone->pages_low;
> +               tpages_free += zone_page_state(zone, NR_FREE_PAGES);
> +               /* always use the reserve of the highest allocation type */
> +               tpages_reserve += zone->lowmem_reserve[MAX_NR_ZONES-1];
> +       }
> +
> +       if ((tpages_free <= tpages_low + tpages_reserve))
> +               val = POLLIN;
> +
> +       if (mem_notify_status) {
> +               mem_notify_status = 0;
> +               val = POLLIN;
> +       }
> +
> +       return val;
> +}
> +
> +struct file_operations mem_notify_fops = {
> +       .open = mem_notify_open,
> +       .release = mem_notify_release,
> +       .poll = mem_notify_poll,
> +};
> +EXPORT_SYMBOL(mem_notify_fops);
> --- linux-2.6.24-rc2-mm1.orig/mm/vmscan.c       2007-11-14 23:51:07.000000000 -0200
> +++ linux-2.6.24-rc2-mm1/mm/vmscan.c    2007-11-21 15:41:24.000000000 -0200
> @@ -943,34 +943,9 @@
>                                 + zone_page_state(zone, NR_INACTIVE))*3;
>  }
>
> -/*
> - * This moves pages from the active list to the inactive list.
> - *
> - * We move them the other way if the page is referenced by one or more
> - * processes, from rmap.
> - *
> - * If the pages are mostly unmapped, the processing is fast and it is
> - * appropriate to hold zone->lru_lock across the whole operation.  But if
> - * the pages are mapped, the processing is slow (page_referenced()) so we
> - * should drop zone->lru_lock around each page.  It's impossible to balance
> - * this, so instead we remove the pages from the LRU while processing them.
> - * It is safe to rely on PG_active against the non-LRU pages in here because
> - * nobody will play with that bit on a non-LRU page.
> - *
> - * The downside is that we have to touch page->_count against each page.
> - * But we had to alter page->flags anyway.
> - */
> -static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> -                               struct scan_control *sc, int priority)
> +static int should_reclaim_mapped(struct zone *zone,
> +                                       struct scan_control *sc, int priority)
>  {
> -       unsigned long pgmoved;
> -       int pgdeactivate = 0;
> -       unsigned long pgscanned;
> -       LIST_HEAD(l_hold);      /* The pages which were snipped off */
> -       LIST_HEAD(l_inactive);  /* Pages to go onto the inactive_list */
> -       LIST_HEAD(l_active);    /* Pages to go onto the active_list */
> -       struct page *page;
> -       struct pagevec pvec;
>         int reclaim_mapped = 0;
>
>         if (sc->may_swap) {
> @@ -1060,6 +1035,40 @@
>  force_reclaim_mapped:
>                         reclaim_mapped = 1;
>         }
> +       return reclaim_mapped;
> +}
> +
> +/*
> + * This moves pages from the active list to the inactive list.
> + *
> + * We move them the other way if the page is referenced by one or more
> + * processes, from rmap.
> + *
> + * If the pages are mostly unmapped, the processing is fast and it is
> + * appropriate to hold zone->lru_lock across the whole operation.  But if
> + * the pages are mapped, the processing is slow (page_referenced()) so we
> + * should drop zone->lru_lock around each page.  It's impossible to balance
> + * this, so instead we remove the pages from the LRU while processing them.
> + * It is safe to rely on PG_active against the non-LRU pages in here because
> + * nobody will play with that bit on a non-LRU page.
> + *
> + * The downside is that we have to touch page->_count against each page.
> + * But we had to alter page->flags anyway.
> + */
> +static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> +                               struct scan_control *sc, int priority)
> +{
> +       unsigned long pgmoved;
> +       int pgdeactivate = 0;
> +       unsigned long pgscanned;
> +       LIST_HEAD(l_hold);      /* The pages which were snipped off */
> +       LIST_HEAD(l_inactive);  /* Pages to go onto the inactive_list */
> +       LIST_HEAD(l_active);    /* Pages to go onto the active_list */
> +       struct page *page;
> +       struct pagevec pvec;
> +       int reclaim_mapped;
> +
> +       reclaim_mapped = should_reclaim_mapped(zone, sc, priority);
>
>         lru_add_drain();
>         spin_lock_irq(&zone->lru_lock);
> @@ -1199,7 +1208,7 @@
>         throttle_vm_writeout(sc->gfp_mask);
>         return nr_reclaimed;
>  }
> -
> +
>  /*
>   * This is the direct reclaim path, for page-allocating processes.  We only
>   * try to reclaim pages from zones which will satisfy the caller's allocation
> @@ -1243,7 +1252,7 @@
>         }
>         return nr_reclaimed;
>  }
> -
> +
>  /*
>   * This is the main entry point to direct page reclaim.
>   *
> @@ -1414,6 +1423,7 @@
>         int i;
>         unsigned long total_scanned;
>         unsigned long nr_reclaimed;
> +       unsigned long nr_anon_pages = 0;
>         struct reclaim_state *reclaim_state = current->reclaim_state;
>         struct scan_control sc = {
>                 .gfp_mask = GFP_KERNEL,
> @@ -1518,6 +1528,21 @@
>                                                 lru_pages);
>                         nr_reclaimed += reclaim_state->reclaimed_slab;
>                         total_scanned += sc.nr_scanned;
> +
> +                       /*
> +                        * If the total number of anonymous pages is growing,
> +                        * and the pressure is enough to unmap active pages,
> +                        * notify userspace.
> +                        */
> +                       if (should_reclaim_mapped(zone, &sc, priority)) {
> +                               unsigned long anon_pages = 0;
> +                               anon_pages = nr_anon_pages;
> +
> +                               if (total_anon_pages() > anon_pages)
> +                                       mem_notify_userspace();
> +
> +                               nr_anon_pages = total_anon_pages();
> +                       }
>                         if (zone_is_all_unreclaimable(zone))
>                                 continue;
>                         if (nr_slab == 0 && zone->pages_scanned >=
>
>

When the page cache is filled, the notification is a bit early as the
following example shows on a small system with 64 MB ram and no swap.
On the first run the application can use 58 MB of anonymous pages
before notification is sent. Then after the page cache is filled the
test application is runned again and is only able to use 49 MB before
being notified.

# cat /proc/meminfo
MemTotal:        63020 kB
MemFree:         59592 kB
Buffers:           116 kB
Cached:           2088 kB
SwapCached:          0 kB
Active:           1088 kB
Inactive:         1432 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:              12 kB
Writeback:           0 kB
AnonPages:         348 kB
Mapped:            680 kB
Slab:              560 kB
SReclaimable:       56 kB
SUnreclaim:        504 kB
PageTables:         60 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:     31508 kB
Committed_AS:     1684 kB
VmallocTotal:   974820 kB
VmallocUsed:      4100 kB
VmallocChunk:   970720 kB
# ./oomtest -t1 -s1024 -w1 -r0 -f /dev/mem_notify &
# cat /proc/meminfo
MemTotal:        63020 kB
MemFree:          1656 kB
Buffers:            76 kB
Cached:           1476 kB
SwapCached:          0 kB
Active:          59660 kB
Inactive:          660 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:              12 kB
Writeback:           0 kB
AnonPages:       58804 kB
Mapped:            888 kB
Slab:              584 kB
SReclaimable:       64 kB
SUnreclaim:        520 kB
PageTables:        148 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:     31508 kB
Committed_AS:    84496 kB
VmallocTotal:   974820 kB
VmallocUsed:      4100 kB
VmallocChunk:   970720 kB
# killall oomtest
# cat /dev/hda > /dev/null
# cat /proc/meminfo
MemTotal:        63020 kB
MemFree:          1720 kB
Buffers:         55928 kB
Cached:            972 kB
SwapCached:          0 kB
Active:            944 kB
Inactive:        56288 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:              12 kB
Writeback:           0 kB
AnonPages:         364 kB
Mapped:            616 kB
Slab:             3716 kB
SReclaimable:     3128 kB
SUnreclaim:        588 kB
PageTables:         60 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:     31508 kB
Committed_AS:     1684 kB
VmallocTotal:   974820 kB
VmallocUsed:      4100 kB
VmallocChunk:   970720 kB
# ./oomtest -t1 -s1024 -w1 -r0 -f /dev/mem_notify &
# cat /proc/meminfo
MemTotal:        63020 kB
MemFree:          1760 kB
Buffers:          9012 kB
Cached:           1056 kB
SwapCached:          0 kB
Active:          50216 kB
Inactive:         9404 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:              16 kB
Writeback:           0 kB
AnonPages:       49584 kB
Mapped:            824 kB
Slab:             1180 kB
SReclaimable:      624 kB
SUnreclaim:        556 kB
PageTables:        140 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:     31508 kB
Committed_AS:    75280 kB
VmallocTotal:   974820 kB
VmallocUsed:      4100 kB
VmallocChunk:   970720 kB

I see it as a feature to be able to throw out inactive binaries and
mmaped files before getting notified about low memory. I suggest we
add both this notification and my priority threshold based approach,
then the users can chose which one to use.

/Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
