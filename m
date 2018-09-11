Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E7E28E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 01:36:22 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bg5-v6so11050549plb.20
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 22:36:22 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c19-v6si20646945pfc.18.2018.09.10.22.36.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 22:36:20 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC PATCH 0/9] Improve zone lock scalability using Daniel Jordan's list work
Date: Tue, 11 Sep 2018 13:36:07 +0800
Message-Id: <20180911053616.6894-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Yosef Lev <levyossi@icloud.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Daniel Jordan and others proposed an innovative technique to make
multiple threads concurrently use list_del() at any position of the
list and list_add() at head position of the list without taking a lock
in this year's MM summit[0].

People think this technique may be useful to improve zone lock
scalability so here is my try. This series is based on Daniel Jordan's
most recent patchset[1]. To make this series self contained, 2 of his
patches are extracted here.

Scalability comes best when multiple threads are operating at different
positions of the list. Since free path will access (buddy) pages
randomly on free list during merging, it is a good fit to make use of
this technique. This patchset makes free path run concurrently.

Patch 1 is for testing purpose only, it removes LRU lock from the
picture so we can get a better understanding of how much improvement
this patchset has on zone lock.

Patch 2-3 are Daniel's work to realize concurrent list_del() and
list_add(), these new APIs are called smp_list_del() and
smp_list_splice().

Patch 4-7 makes free path run concurrently by converting the zone lock
from spinlock to rwlock and has free path taking the zone lock in read
mode. To avoid complexity and problems, all other code paths take zone
lock in write mode.

Patch 8 is an optimization that reduces free list head access to avoid
severe cache bouncing. It also comes with a side effect: with this
patch, there will be mergable pages unmerged in Buddy.

Patch 9 improves fragmentation issues introduced in patch 8 by doing
pre-merges before pages are sent to merge under zone lock.

This patchset is based on v4.19-rc2.

Performance wise on 56 cores/112 threads Intel Skylake 2 sockets server
using will-it-scale/page_fault1 process mode(higher is better):

kernel        performance      zone lock contention
patch1         9219349         76.99%
patch7         2461133 -73.3%  54.46%(another 34.66% on smp_list_add())
patch8        11712766 +27.0%  68.14%
patch9        11386980 +23.5%  67.18%

Though lock contention reduced a lot for patch7, the performance dropped
considerably due to severe cache bouncing on free list head among
multiple threads doing page free at the same time, because every page free
will need to add the page to the free list head.

Patch8 is meant to solve this cache bouncing problem and has good result,
except the above mentioned side effect of having mergable pages unmerged
in Buddy. Patch9 reduced the fragmentation problem to some extent while
caused slightly performance drop.

As a comparison to the no_merge+cluster_alloc approach I posted before[2]:

kernel                 performance      zone lock contention
patch1                  9219349         76.99%
no_merge               11733153 +27.3%  69.18%
no_merge+cluster_alloc 12094893 +31.2%   0.73%

no_merge(skip merging for order0 page on free path) has similar
performance and zone lock contention as patch8/9, while with
cluster_alloc that also improves allocation side, zone lock contention
for this workload is almost gone.

To get an idea of how fragmentation are affected by patch8 and how much
improvement patch9 has, this is the result of /proc/buddyinfo after
running will-it-scale/page_fault1 for 3 minutes:

With patch7:
Node 0, zone      DMA      0      2      1      1      3      2      2      1      0      1      3
Node 0, zone    DMA32      7      3      6      5      5     10      6      7      6     10    410
Node 0, zone   Normal  17820  16819  14645  12969  11367   9229   6365   3062    756     69   5646
Node 1, zone   Normal  44789  60354  52331  37532  22071   9604   2750    241     32     11   6378

With patch8:
Node 0, zone      DMA      0      2      1      1      3      2      2      1      0      1      3
Node 0, zone    DMA32      7      9      5      4      5     10      6      7      6     10    410
Node 0, zone   Normal 404917 119614  79446  58303  20679   3106    222     89     28      9   5615
Node 1, zone   Normal 507659 127355  64470  53549  14104   1288     30      4      1      1   6078

With patch9:
Node 0, zone      DMA      0      3      0      1      3      0      1      0      1      1      3
Node 0, zone    DMA32     11    423    621    705    726    702     60     14      5      6    296
Node 0, zone   Normal  20407  21016  18731  16195  13697  10483   6873   3148    735     39   5637
Node 1, zone   Normal  79738  76963  59313  35996  18626   9743   3947    750     21      2   6080

A lot more pages stayed in order0 in patch8 than patch7, consequently,
for order5 and above pages, there are fewer with patch8 than patch7,
suggesting that some pages are not properly merged into high order pages
with patch8 applied. Patch9 has far fewer pages stayed in order0 than
patch8, which is a good sign but still not as good as patch7.

As a comparison, this is the result of no_merge(think of it as a worst
case result regarding fragmentation):

With no_merge:
Node 0, zone      DMA      0      2      1      1      3      2      2      1      0      1      3
Node 0, zone    DMA32      7      3      6      5      5     10      6      7      6     10    410
Node 0, zone   Normal 1895199      5      1      1      4      2      2      1      1      1   5614
Node 1, zone   Normal 1718733      4      1     13     10      3      2      0      1      1   6008

Conclusion: The approach I proposed here caused performance drop due to
free list head cache bouncing. If we can bear the result of some
mergable pages becoming unmerged in Buddy, zone lock scalability can be
improved: performance increase 20%+, lock contention drop 8%.
no_merge+cluster_alloc on the other hand, can eiminate zone lock
contention entirely, but has worse fragmentation issue.

[0] https://lwn.net/Articles/753058/
[1] https://lkml.kernel.org/r/20180911004240.4758-1-daniel.m.jordan@oracle.com
[2] https://lkml.kernel.org/r/20180509085450.3524-1-aaron.lu@intel.com

Aaron Lu (7):
  mm: do not add anon pages to LRU
  mm: convert zone lock from spinlock to rwlock
  mm/page_alloc: use helper functions to add/remove a page to/from buddy
  use atomic for free_area[order].nr_free
  mm: use read_lock for free path
  mm: use smp_list_splice() on free path
  mm: page_alloc: merge before sending pages to global pool

Daniel Jordan (2):
  mm: introduce smp_list_del for concurrent list entry removals
  mm: introduce smp_list_splice to prepare for concurrent LRU adds

 include/linux/list.h   |   4 +
 include/linux/mm.h     |   1 +
 include/linux/mmzone.h |   4 +-
 init/main.c            |   1 +
 lib/Makefile           |   2 +-
 lib/list.c             | 227 ++++++++++++++++++++++++++++
 mm/compaction.c        |  90 +++++------
 mm/hugetlb.c           |   8 +-
 mm/memory.c            |   2 +-
 mm/page_alloc.c        | 332 ++++++++++++++++++++++++++++-------------
 mm/page_isolation.c    |  12 +-
 mm/vmstat.c            |   8 +-
 12 files changed, 526 insertions(+), 165 deletions(-)
 create mode 100644 lib/list.c

-- 
2.17.1
