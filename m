From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 2/3] vmscan: make mapped executable pages the first class citizen
Date: Mon, 08 Jun 2009 17:10:46 +0800
Message-ID: <20090608091201.953724007@intel.com>
References: <20090608091044.880249722@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 626996B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 04:06:28 -0400 (EDT)
Content-Disposition: inline; filename=mm-vmscan-protect-exec-referenced.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-Id: linux-mm.kvack.org

Protect referenced PROT_EXEC mapped pages from being deactivated.

PROT_EXEC(or its internal presentation VM_EXEC) pages normally belong to some
currently running executables and their linked libraries, they shall really be
cached aggressively to provide good user experiences.

Thanks to Johannes Weiner for the advice to reuse the VMA walk in
page_referenced() to get the PROT_EXEC bit.


[more details]

( The consequences of this patch will have to be discussed together with
  Rik van Riel's recent patch "vmscan: evict use-once pages first". )

( Some of the good points and insights are taken into this changelog.
  Thanks to all the involved people for the great LKML discussions. )

the problem
-----------

For a typical desktop, the most precious working set is composed of
*actively accessed*
	(1) memory mapped executables
	(2) and their anonymous pages
	(3) and other files
	(4) and the dcache/icache/.. slabs
while the least important data are
	(5) infrequently used or use-once files

For a typical desktop, one major problem is busty and large amount of (5)
use-once files flushing out the working set.

Inside the working set, (4) dcache/icache have already been too sticky ;-)
So we only have to care (2) anonymous and (1)(3) file pages.

anonymous pages
---------------
Anonymous pages are effectively immune to the streaming IO attack, because we
now have separate file/anon LRU lists. When the use-once files crowd into the
file LRU, the list's "quality" is significantly lowered. Therefore the scan
balance policy in get_scan_ratio() will choose to scan the (low quality) file
LRU much more frequently than the anon LRU.

file pages
----------
Rik proposed to *not* scan the active file LRU when the inactive list grows
larger than active list. This guarantees that when there are use-once streaming
IO, and the working set is not too large(so that active_size < inactive_size),
the active file LRU will *not* be scanned at all. So the not-too-large working
set can be well protected.

But there are also situations where the file working set is a bit large so that
(active_size >= inactive_size), or the streaming IOs are not purely use-once.
In these cases, the active list will be scanned slowly. Because the current
shrink_active_list() policy is to deactivate active pages regardless of their
referenced bits. The deactivated pages become susceptible to the streaming IO
attack: the inactive list could be scanned fast (500MB / 50MBps = 10s) so that
the deactivated pages don't have enough time to get re-referenced. Because a
user tend to switch between windows in intervals from seconds to minutes.

This patch holds mapped executable pages in the active list as long as they
are referenced during each full scan of the active list.  Because the active
list is normally scanned much slower, they get longer grace time (eg. 100s)
for further references, which better matches the pace of user operations.

Therefore this patch greatly prolongs the in-cache time of executable code,
when there are moderate memory pressures.

	before patch: guaranteed to be cached if reference intervals < I
	after  patch: guaranteed to be cached if reference intervals < I+A
		      (except when randomly reclaimed by the lumpy reclaim)
where
	A = time to fully scan the   active file LRU
	I = time to fully scan the inactive file LRU

Note that normally A >> I.

side effects
------------

This patch is safe in general, it restores the pre-2.6.28 mmap() behavior
but in a much smaller and well targeted scope.

One may worry about some one to abuse the PROT_EXEC heuristic.  But as
Andrew Morton stated, there are other tricks to getting that sort of boost.

Another concern is the PROT_EXEC mapped pages growing large in rare cases,
and therefore hurting reclaim efficiency. But a sane application targeted for
large audience will never use PROT_EXEC for data mappings. If some home made
application tries to abuse that bit, it shall be aware of the consequences.
If it is abused to scale of 2/3 total memory, it gains nothing but overheads.

benchmarks
----------

1) memory tight desktop

1.1) brief summary

- clock time and major faults are reduced by 50%;
- pswpin numbers are reduced to ~1/3.

That means X desktop responsiveness is doubled under high memory/swap pressure.

1.2) test scenario

- nfsroot gnome desktop with 512M physical memory
- run some programs, and switch between the existing windows
  after starting each new program.

1.3) progress timing (seconds)

  before       after    programs
    0.02        0.02    N xeyes
    0.75        0.76    N firefox
    2.02        1.88    N nautilus
    3.36        3.17    N nautilus --browser
    5.26        4.89    N gthumb
    7.12        6.47    N gedit
    9.22        8.16    N xpdf /usr/share/doc/shared-mime-info/shared-mime-info-spec.pdf
   13.58       12.55    N xterm
   15.87       14.57    N mlterm
   18.63       17.06    N gnome-terminal
   21.16       18.90    N urxvt
   26.24       23.48    N gnome-system-monitor
   28.72       26.52    N gnome-help
   32.15       29.65    N gnome-dictionary
   39.66       36.12    N /usr/games/sol
   43.16       39.27    N /usr/games/gnometris
   48.65       42.56    N /usr/games/gnect
   53.31       47.03    N /usr/games/gtali
   58.60       52.05    N /usr/games/iagno
   65.77       55.42    N /usr/games/gnotravex
   70.76       61.47    N /usr/games/mahjongg
   76.15       67.11    N /usr/games/gnome-sudoku
   86.32       75.15    N /usr/games/glines
   92.21       79.70    N /usr/games/glchess
  103.79       88.48    N /usr/games/gnomine
  113.84       96.51    N /usr/games/gnotski
  124.40      102.19    N /usr/games/gnibbles
  137.41      114.93    N /usr/games/gnobots2
  155.53      125.02    N /usr/games/blackjack
  179.85      135.11    N /usr/games/same-gnome
  224.49      154.50    N /usr/bin/gnome-window-properties
  248.44      162.09    N /usr/bin/gnome-default-applications-properties
  282.62      173.29    N /usr/bin/gnome-at-properties
  323.72      188.21    N /usr/bin/gnome-typing-monitor
  363.99      199.93    N /usr/bin/gnome-at-visual
  394.21      206.95    N /usr/bin/gnome-sound-properties
  435.14      224.49    N /usr/bin/gnome-at-mobility
  463.05      234.11    N /usr/bin/gnome-keybinding-properties
  503.75      248.59    N /usr/bin/gnome-about-me
  554.00      276.27    N /usr/bin/gnome-display-properties
  615.48      304.39    N /usr/bin/gnome-network-preferences
  693.03      342.01    N /usr/bin/gnome-mouse-properties
  759.90      388.58    N /usr/bin/gnome-appearance-properties
  937.90      508.47    N /usr/bin/gnome-control-center
 1109.75      587.57    N /usr/bin/gnome-keyboard-properties
 1399.05      758.16    N : oocalc
 1524.64      830.03    N : oodraw
 1684.31      900.03    N : ooimpress
 1874.04      993.91    N : oomath
 2115.12     1081.89    N : ooweb
 2369.02     1161.99    N : oowriter

Note that the last ": oo*" commands are actually commented out.

1.4) vmstat numbers (some relevant ones are marked with *)

                            before    after
 nr_free_pages              1293      3898
 nr_inactive_anon           59956     53460
 nr_active_anon             26815     30026
 nr_inactive_file           2657      3218
 nr_active_file             2019      2806
 nr_unevictable             4         4
 nr_mlock                   4         4
 nr_anon_pages              26706     27859
*nr_mapped                  3542      4469
 nr_file_pages              72232     67681
 nr_dirty                   1         0
 nr_writeback               123       19
 nr_slab_reclaimable        3375      3534
 nr_slab_unreclaimable      11405     10665
 nr_page_table_pages        8106      7864
 nr_unstable                0         0
 nr_bounce                  0         0
*nr_vmscan_write            394776    230839
 nr_writeback_temp          0         0
 numa_hit                   6843353   3318676
 numa_miss                  0         0
 numa_foreign               0         0
 numa_interleave            1719      1719
 numa_local                 6843353   3318676
 numa_other                 0         0
*pgpgin                     5954683   2057175
*pgpgout                    1578276   922744
*pswpin                     1486615   512238
*pswpout                    394568    230685
 pgalloc_dma                277432    56602
 pgalloc_dma32              6769477   3310348
 pgalloc_normal             0         0
 pgalloc_movable            0         0
 pgfree                     7048396   3371118
 pgactivate                 2036343   1471492
 pgdeactivate               2189691   1612829
 pgfault                    3702176   3100702
*pgmajfault                 452116    201343
 pgrefill_dma               12185     7127
 pgrefill_dma32             334384    653703
 pgrefill_normal            0         0
 pgrefill_movable           0         0
 pgsteal_dma                74214     22179
 pgsteal_dma32              3334164   1638029
 pgsteal_normal             0         0
 pgsteal_movable            0         0
 pgscan_kswapd_dma          1081421   1216199
 pgscan_kswapd_dma32        58979118  46002810
 pgscan_kswapd_normal       0         0
 pgscan_kswapd_movable      0         0
 pgscan_direct_dma          2015438   1086109
 pgscan_direct_dma32        55787823  36101597
 pgscan_direct_normal       0         0
 pgscan_direct_movable      0         0
 pginodesteal               3461      7281
 slabs_scanned              564864    527616
 kswapd_steal               2889797   1448082
 kswapd_inodesteal          14827     14835
 pageoutrun                 43459     21562
 allocstall                 9653      4032
 pgrotated                  384216    228631

1.5) free numbers at the end of the tests

before patch:
                             total       used       free     shared    buffers     cached
                Mem:           474        467          7          0          0        236
                -/+ buffers/cache:        230        243
                Swap:         1023        418        605

after patch:
                             total       used       free     shared    buffers     cached
                Mem:           474        457         16          0          0        236
                -/+ buffers/cache:        221        253
                Swap:         1023        404        619


2) memory flushing in a file server

2.1) brief summary

The number of major faults from 50 to 3 during 10% cache hot reads.

That means this patch successfully stops major faults when the active file list
is slowly scanned when there are partially cache hot streaming IO.

2.2) test scenario

Do 100000 pread(size=110 pages, offset=(i*100) pages), where 10% of the pages
will be activated:

        for i in `seq 0 100 10000000`; do echo $i 110;  done > pattern-hot-10
        iotrace.rb --load pattern-hot-10 --play /b/sparse
	vmmon  nr_mapped nr_active_file nr_inactive_file   pgmajfault pgdeactivate pgfree

and monitor /proc/vmstat during the time. The test box has 2G memory.

I carried out tests on fresh booted console as well as X desktop,
and fetched the vmstat numbers on

(1) begin:     shortly after the big read IO starts;
(2) end:       just before the big read IO stops;
(3) restore:   the big read IO stops and the zsh working set restored
(4) restore X: after IO, switch back and forth between the urxvt and firefox
               windows to restore their working set.

2.3) console mode results

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree

2.6.29 VM_EXEC protection ON:
begin:       2481             2237             8694              630                0           574299
end:          275           231976           233914              633           776271         20933042
restore:      370           232154           234524              691           777183         20958453

2.6.29 VM_EXEC protection ON (second run):
begin:       2434             2237             8493              629                0           574195
end:          284           231970           233536              632           771918         20896129
restore:      399           232218           234789              690           774526         20957909

2.6.30-rc4-mm VM_EXEC protection OFF:
begin:       2479             2344             9659              210                0           579643
end:          284           232010           234142              260           772776         20917184
restore:      379           232159           234371              301           774888         20967849

The above console numbers show that

- The startup pgmajfault of 2.6.30-rc4-mm is merely 1/3 that of 2.6.29.
  I'd attribute that improvement to the mmap readahead improvements :-)

- The pgmajfault increment during the file copy is 633-630=3 vs 260-210=50.
  That's a huge improvement - which means with the VM_EXEC protection logic,
  active mmap pages is pretty safe even under partially cache hot streaming IO.

- when active:inactive file lru size reaches 1:1, their scan rates is 1:20.8
  under 10% cache hot IO. (computed with formula Dpgdeactivate:Dpgfree)
  That roughly means the active mmap pages get 20.8 more chances to get
  re-referenced to stay in memory.

- The absolute nr_mapped drops considerably to 1/9 during the big IO, and the
  dropped pages are mostly inactive ones. The patch has almost no impact in
  this aspect, that means it won't unnecessarily increase memory pressure.
  (In contrast, your 20% mmap protection ratio will keep them all, and
  therefore eliminate the extra 41 major faults to restore working set
  of zsh etc.)

The iotrace.rb read throughput is
	151.194384MB/s 284.198252s 100001x 450560b --load pattern-hot-10 --play /b/sparse
which means the inactive list is rotated at the speed of 250MB/s,
so a full scan of which takes about 3.5 seconds, while a full scan
of active file list takes about 77 seconds.

2.4) X mode results

We can reach roughly the same conclusions for X desktop:

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree

2.6.30-rc4-mm VM_EXEC protection ON:
begin:       9740             8920            64075              561                0           678360
end:          768           218254           220029              565           798953         21057006
restore:      857           218543           220987              606           799462         21075710
restore X:   2414           218560           225344              797           799462         21080795

2.6.30-rc4-mm VM_EXEC protection OFF:
begin:       9368             5035            26389              554                0           633391
end:          770           218449           221230              661           646472         17832500
restore:     1113           218466           220978              710           649881         17905235
restore X:   2687           218650           225484              947           802700         21083584

- the absolute nr_mapped drops considerably (to 1/13 of the original size)
  during the streaming IO.
- the delta of pgmajfault is 3 vs 107 during IO, or 236 vs 393
  during the whole process.


CC: Elladan <elladan@eskimo.com>
CC: Nick Piggin <npiggin@suse.de>
CC: Andi Kleen <andi@firstfloor.org>
CC: Christoph Lameter <cl@linux-foundation.org>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Peter Zijlstra <peterz@infradead.org>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |   52 +++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 45 insertions(+), 7 deletions(-)

--- linux.orig/mm/vmscan.c
+++ linux/mm/vmscan.c
@@ -1219,6 +1219,7 @@ static void shrink_active_list(unsigned 
 	unsigned long pgscanned;
 	unsigned long vm_flags;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
+	LIST_HEAD(l_active);
 	LIST_HEAD(l_inactive);
 	struct page *page;
 	struct pagevec pvec;
@@ -1258,28 +1259,42 @@ static void shrink_active_list(unsigned 
 
 		/* page_referenced clears PageReferenced */
 		if (page_mapping_inuse(page) &&
-		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags))
+		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
 			pgmoved++;
+			/*
+			 * Identify referenced, file-backed active pages and
+			 * give them one more trip around the active list. So
+			 * that executable code get better chances to stay in
+			 * memory under moderate memory pressure.  Anon pages
+			 * are not likely to be evicted by use-once streaming
+			 * IO, plus JVM can create lots of anon VM_EXEC pages,
+			 * so we ignore them here.
+			 */
+			if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
+				list_add(&page->lru, &l_active);
+				continue;
+			}
+		}
 
 		list_add(&page->lru, &l_inactive);
 	}
 
 	/*
-	 * Move the pages to the [file or anon] inactive list.
+	 * Move pages back to the lru list.
 	 */
 	pagevec_init(&pvec, 1);
-	lru = LRU_BASE + file * LRU_FILE;
 
 	spin_lock_irq(&zone->lru_lock);
 	/*
-	 * Count referenced pages from currently used mappings as
-	 * rotated, even though they are moved to the inactive list.
-	 * This helps balance scan pressure between file and anonymous
-	 * pages in get_scan_ratio.
+	 * Count referenced pages from currently used mappings as rotated,
+	 * even though only some of them are actually re-activated.  This
+	 * helps balance scan pressure between file and anonymous pages in
+	 * get_scan_ratio.
 	 */
 	reclaim_stat->recent_rotated[!!file] += pgmoved;
 
 	pgmoved = 0;  /* count pages moved to inactive list */
+	lru = LRU_BASE + file * LRU_FILE;
 	while (!list_empty(&l_inactive)) {
 		page = lru_to_page(&l_inactive);
 		prefetchw_prev_lru_page(page, &l_inactive, flags);
@@ -1302,6 +1317,29 @@ static void shrink_active_list(unsigned 
 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
 	__count_vm_events(PGDEACTIVATE, pgmoved);
+
+	pgmoved = 0;  /* count pages moved back to active list */
+	lru = LRU_ACTIVE + file * LRU_FILE;
+	while (!list_empty(&l_active)) {
+		page = lru_to_page(&l_active);
+		prefetchw_prev_lru_page(page, &l_active, flags);
+		VM_BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		VM_BUG_ON(!PageActive(page));
+
+		list_move(&page->lru, &zone->lru[lru].list);
+		mem_cgroup_add_lru_list(page, lru);
+		pgmoved++;
+		if (!pagevec_add(&pvec, page)) {
+			spin_unlock_irq(&zone->lru_lock);
+			if (buffer_heads_over_limit)
+				pagevec_strip(&pvec);
+			__pagevec_release(&pvec);
+			spin_lock_irq(&zone->lru_lock);
+		}
+	}
+	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
+
 	spin_unlock_irq(&zone->lru_lock);
 	if (buffer_heads_over_limit)
 		pagevec_strip(&pvec);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
