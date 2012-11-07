Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id AE8A96B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 22:06:33 -0500 (EST)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v11 0/7] make balloon pages movable by compaction
Date: Wed,  7 Nov 2012 01:05:47 -0200
Message-Id: <cover.1352256081.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, aquini@redhat.com

Memory fragmentation introduced by ballooning might reduce significantly
the number of 2MB contiguous memory blocks that can be used within a guest,
thus imposing performance penalties associated with the reduced number of
transparent huge pages that could be used by the guest workload.

This patch-set follows the main idea discussed at 2012 LSFMMS session:
"Ballooning for transparent huge pages" -- http://lwn.net/Articles/490114/
to introduce the required changes to the virtio_balloon driver, as well as
the changes to the core compaction & migration bits, in order to make those
subsystems aware of ballooned pages and allow memory balloon pages become
movable within a guest, thus avoiding the aforementioned fragmentation issue

Following are numbers that prove this patch benefits on allowing compaction
to be more effective at memory ballooned guests.

Results for STRESS-HIGHALLOC benchmark, from Mel Gorman's mmtests suite,
running on a 4gB RAM KVM guest which was ballooning 512mB RAM in 64mB chunks,
at every minute (inflating/deflating), while test was running:

===BEGIN stress-highalloc

STRESS-HIGHALLOC
                 highalloc-3.7     highalloc-3.7
                     rc4-clean         rc4-patch
Pass 1          55.00 ( 0.00%)    62.00 ( 7.00%)
Pass 2          54.00 ( 0.00%)    62.00 ( 8.00%)
while Rested    75.00 ( 0.00%)    80.00 ( 5.00%)

MMTests Statistics: duration
                 3.7         3.7
           rc4-clean   rc4-patch
User         1207.59     1207.46
System       1300.55     1299.61
Elapsed      2273.72     2157.06

MMTests Statistics: vmstat
                                3.7         3.7
                          rc4-clean   rc4-patch
Page Ins                    3581516     2374368
Page Outs                  11148692    10410332
Swap Ins                         80          47
Swap Outs                      3641         476
Direct pages scanned          37978       33826
Kswapd pages scanned        1828245     1342869
Kswapd pages reclaimed      1710236     1304099
Direct pages reclaimed        32207       31005
Kswapd efficiency               93%         97%
Kswapd velocity             804.077     622.546
Direct efficiency               84%         91%
Direct velocity              16.703      15.682
Percentage direct scans          2%          2%
Page writes by reclaim        79252        9704
Page writes file              75611        9228
Page writes anon               3641         476
Page reclaim immediate        16764       11014
Page rescued immediate            0           0
Slabs scanned               2171904     2152448
Direct inode steals             385        2261
Kswapd inode steals          659137      609670
Kswapd skipped wait               1          69
THP fault alloc                 546         631
THP collapse alloc              361         339
THP splits                      259         263
THP fault fallback               98          50
THP collapse fail                20          17
Compaction stalls               747         499
Compaction success              244         145
Compaction failures             503         354
Compaction pages moved       370888      474837
Compaction move failure       77378       65259

===END stress-highalloc

Rafael Aquini (7):
  mm: adjust address_space_operations.migratepage() return code
  mm: redefine address_space.assoc_mapping
  mm: introduce a common interface for balloon pages mobility
  mm: introduce compaction and migration for ballooned pages
  virtio_balloon: introduce migration primitives to balloon pages
  mm: introduce putback_movable_pages()
  mm: add vm event counters for balloon pages compaction

 drivers/virtio/virtio_balloon.c    | 136 +++++++++++++++++--
 fs/buffer.c                        |  12 +-
 fs/gfs2/glock.c                    |   2 +-
 fs/hugetlbfs/inode.c               |   4 +-
 fs/inode.c                         |   2 +-
 fs/nilfs2/page.c                   |   2 +-
 include/linux/balloon_compaction.h | 220 ++++++++++++++++++++++++++++++
 include/linux/fs.h                 |   2 +-
 include/linux/migrate.h            |  19 +++
 include/linux/pagemap.h            |  16 +++
 include/linux/vm_event_item.h      |   8 +-
 mm/Kconfig                         |  15 ++
 mm/Makefile                        |   1 +
 mm/balloon_compaction.c            | 271 +++++++++++++++++++++++++++++++++++++
 mm/compaction.c                    |  27 +++-
 mm/migrate.c                       |  77 +++++++++--
 mm/page_alloc.c                    |   2 +-
 mm/vmstat.c                        |  10 +-
 18 files changed, 782 insertions(+), 44 deletions(-)
 create mode 100644 include/linux/balloon_compaction.h
 create mode 100644 mm/balloon_compaction.c

Change log:
v11:
 * Address AKPM's last review suggestions;
 * Extend the balloon compaction common API and simplify its usage at driver;
 * Minor nitpicks on code commentary;
v10:
 * Adjust leak_balloon() wait_event logic to make a clear locking scheme (MST);
 * Drop the RCU protection approach for dereferencing balloon's page->mapping;
 * Minor nitpitcks on code commentaries (MST);
v9:
 * Adjust rcu_dereference usage to leverage page lock protection  (Paul, Peter);
 * Enhance doc on compaction interface introduced to balloon driver   (Michael);
 * Fix issue with isolated pages breaking leak_balloon() logics       (Michael);
v8:
 * introduce a common MM interface for balloon driver page compaction (Michael);
 * remove the global state preventing multiple balloon device support (Michael);
 * introduce RCU protection/syncrhonization to balloon page->mapping  (Michael);
v7:
 * fix a potential page leak case at 'putback_balloon_page'               (Mel);
 * adjust vm-events-counter patch and remove its drop-on-merge message    (Rik);
 * add 'putback_movable_pages' to avoid hacks on 'putback_lru_pages'  (Minchan);
v6:
 * rename 'is_balloon_page()' to 'movable_balloon_page()'                 (Rik);
v5:
 * address Andrew Morton's review comments on the patch series;
 * address a couple extra nitpick suggestions on PATCH 01             (Minchan);
v4:
 * address Rusty Russel's review comments on PATCH 02;
 * re-base virtio_balloon patch on 9c378abc5c0c6fc8e3acf5968924d274503819b3;
V3:
 * address reviewers nitpick suggestions on PATCH 01             (Mel, Minchan);
V2:
 * address Mel Gorman's review comments on PATCH 01;

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
