Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id F088B6B005A
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 12:38:48 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v10 0/5] make balloon pages movable by compaction
Date: Mon, 17 Sep 2012 13:38:15 -0300
Message-Id: <cover.1347897793.git.aquini@redhat.com>
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
running on a 4gB RAM KVM guest which was ballooning 1gB RAM in 256mB chunks,
at every minute (inflating/deflating), while test was running:

===BEGIN stress-highalloc

STRESS-HIGHALLOC
              stress-highalloc   highalloc-3.6.0
                     3.6.0-rc5         rc5-patch
Pass 1          47.00 ( 0.00%)    85.00 (38.00%)
Pass 2          52.00 ( 0.00%)    87.00 (35.00%)
while Rested    77.00 ( 0.00%)    99.00 (22.00%)

MMTests Statistics: duration
               3.6.0       3.6.0
                 rc5   rc5-patch
User         1566.87     1066.77
System        948.78      713.19
Elapsed      2008.95     1650.72

MMTests Statistics: vmstat
                              3.6.0       3.6.0
                                rc5   rc5-patch
Page Ins                    5037962     3458106
Page Outs                  10779728     8969512
Swap Ins                      34282        5565
Swap Outs                     63027       19717
Direct pages scanned         481017      166920
Kswapd pages scanned        2083130     1537202
Kswapd pages reclaimed      1838615     1459932
Direct pages reclaimed       337487      120613
Kswapd efficiency               88%         94%
Kswapd velocity            1036.925     931.231
Direct efficiency               70%         72%
Direct velocity             239.437     101.120
Percentage direct scans         18%          9%
Page writes by reclaim       157305       19855
Page writes file              94278         138
Page writes anon              63027       19717
Page reclaim immediate       111205       64510
Page rescued immediate            0           0
Slabs scanned               3362816     2375680
Direct inode steals           12411        2022
Kswapd inode steals          753789      524457
Kswapd skipped wait             136           7
THP fault alloc                 688         739
THP collapse alloc              378         481
THP splits                      279         317
THP fault fallback              172          45
THP collapse fail                12           5
Compaction stalls              1378         968
Compaction success              406         595
Compaction failures             972         373
Compaction pages moved      3104073     1790932
Compaction move failure       92713       41252

===END stress-highalloc

Rafael Aquini (5):
  mm: introduce a common interface for balloon pages mobility
  mm: introduce compaction and migration for ballooned pages
  virtio_balloon: introduce migration primitives to balloon pages
  mm: introduce putback_movable_pages()
  mm: add vm event counters for balloon pages compaction

 drivers/virtio/virtio_balloon.c    | 306 ++++++++++++++++++++++++++++++++++---
 include/linux/balloon_compaction.h | 147 ++++++++++++++++++
 include/linux/migrate.h            |   2 +
 include/linux/pagemap.h            |  18 +++
 include/linux/vm_event_item.h      |   8 +-
 mm/Kconfig                         |  15 ++
 mm/Makefile                        |   1 +
 mm/balloon_compaction.c            | 154 +++++++++++++++++++
 mm/compaction.c                    |  51 ++++---
 mm/migrate.c                       |  57 ++++++-
 mm/page_alloc.c                    |   2 +-
 mm/vmstat.c                        |  10 +-
 12 files changed, 726 insertions(+), 45 deletions(-)
 create mode 100644 include/linux/balloon_compaction.h
 create mode 100644 mm/balloon_compaction.c

Change log:
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
 * rename 'is_balloon_page()' to 'movable_balloon_page()' 		  (Rik);
v5:
 * address Andrew Morton's review comments on the patch series;
 * address a couple extra nitpick suggestions on PATCH 01 	      (Minchan);
v4: 
 * address Rusty Russel's review comments on PATCH 02;
 * re-base virtio_balloon patch on 9c378abc5c0c6fc8e3acf5968924d274503819b3;
V3: 
 * address reviewers nitpick suggestions on PATCH 01		 (Mel, Minchan);
V2: 
 * address Mel Gorman's review comments on PATCH 01;
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
