Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id CD3C56B0068
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 03:57:39 -0400 (EDT)
Date: Sun, 26 Aug 2012 10:58:40 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v9 0/5] make balloon pages movable by compaction
Message-ID: <20120826075840.GE19551@redhat.com>
References: <cover.1345869378.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1345869378.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Sat, Aug 25, 2012 at 02:24:55AM -0300, Rafael Aquini wrote:
> Memory fragmentation introduced by ballooning might reduce significantly
> the number of 2MB contiguous memory blocks that can be used within a guest,
> thus imposing performance penalties associated with the reduced number of
> transparent huge pages that could be used by the guest workload.
> 
> This patch-set follows the main idea discussed at 2012 LSFMMS session:
> "Ballooning for transparent huge pages" -- http://lwn.net/Articles/490114/
> to introduce the required changes to the virtio_balloon driver, as well as
> the changes to the core compaction & migration bits, in order to make those
> subsystems aware of ballooned pages and allow memory balloon pages become
> movable within a guest, thus avoiding the aforementioned fragmentation issue

Meta-question: are there any numbers showing gain from this patchset?

The reason I ask, on migration we notify host about each page
individually.  If this is rare maybe the patchset does not help much.
If this is common we would be better off building up a list of multiple
pages and passing them in one go.

> Rafael Aquini (5):
>   mm: introduce a common interface for balloon pages mobility
>   mm: introduce compaction and migration for ballooned pages
>   virtio_balloon: introduce migration primitives to balloon pages
>   mm: introduce putback_movable_pages()
>   mm: add vm event counters for balloon pages compaction
> 
>  drivers/virtio/virtio_balloon.c    | 287 ++++++++++++++++++++++++++++++++++---
>  include/linux/balloon_compaction.h | 137 ++++++++++++++++++
>  include/linux/migrate.h            |   2 +
>  include/linux/pagemap.h            |  18 +++
>  include/linux/vm_event_item.h      |   8 +-
>  mm/Kconfig                         |  15 ++
>  mm/Makefile                        |   2 +-
>  mm/balloon_compaction.c            | 174 ++++++++++++++++++++++
>  mm/compaction.c                    |  51 ++++---
>  mm/migrate.c                       |  57 +++++++-
>  mm/page_alloc.c                    |   2 +-
>  mm/vmstat.c                        |  10 +-
>  12 files changed, 715 insertions(+), 48 deletions(-)
>  create mode 100644 include/linux/balloon_compaction.h
>  create mode 100644 mm/balloon_compaction.c
> 
> 
> Change log:
> v9:
>  * Adjust rcu_dereference usage to leverage page lock protection  (Paul, Peter);
>  * Enhance doc on compaction interface introduced to balloon driver   (Michael);
>  * Fix issue with isolated pages breaking leak_balloon() logics       (Michael);
> v8:
>  * introduce a common MM interface for balloon driver page compaction (Michael);
>  * remove the global state preventing multiple balloon device support (Michael);
>  * introduce RCU protection/syncrhonization to balloon page->mapping  (Michael);
> v7:
>  * fix a potential page leak case at 'putback_balloon_page'               (Mel);
>  * adjust vm-events-counter patch and remove its drop-on-merge message    (Rik);
>  * add 'putback_movable_pages' to avoid hacks on 'putback_lru_pages'  (Minchan);
> v6:
>  * rename 'is_balloon_page()' to 'movable_balloon_page()' 		  (Rik);
> v5:
>  * address Andrew Morton's review comments on the patch series;
>  * address a couple extra nitpick suggestions on PATCH 01 	      (Minchan);
> v4: 
>  * address Rusty Russel's review comments on PATCH 02;
>  * re-base virtio_balloon patch on 9c378abc5c0c6fc8e3acf5968924d274503819b3;
> V3: 
>  * address reviewers nitpick suggestions on PATCH 01		 (Mel, Minchan);
> V2: 
>  * address Mel Gorman's review comments on PATCH 01;
> 
> 
> Preliminary test results:
> (2 VCPU 2048mB RAM KVM guest running 3.6.0_rc3+ -- after a reboot)
> 
> * 64mB balloon:
> [root@localhost ~]# awk '/compact/ {print}' /proc/vmstat
> compact_blocks_moved 0
> compact_pages_moved 0
> compact_pagemigrate_failed 0
> compact_stall 0
> compact_fail 0
> compact_success 0
> compact_balloon_isolated 0
> compact_balloon_migrated 0
> compact_balloon_released 0
> compact_balloon_returned 0
> [root@localhost ~]# 
> [root@localhost ~]# for i in $(seq 1 6); do echo 1 > /proc/sys/vm/compact_memory & done &>/dev/null 
> [1]   Done                    echo 1 > /proc/sys/vm/compact_memory
> [2]   Done                    echo 1 > /proc/sys/vm/compact_memory
> [3]   Done                    echo 1 > /proc/sys/vm/compact_memory
> [4]   Done                    echo 1 > /proc/sys/vm/compact_memory
> [5]-  Done                    echo 1 > /proc/sys/vm/compact_memory
> [6]+  Done                    echo 1 > /proc/sys/vm/compact_memory
> [root@localhost ~]# 
> [root@localhost ~]# awk '/compact/ {print}' /proc/vmstat
> compact_blocks_moved 3108
> compact_pages_moved 43169
> compact_pagemigrate_failed 95
> compact_stall 0
> compact_fail 0
> compact_success 0
> compact_balloon_isolated 16384
> compact_balloon_migrated 16384
> compact_balloon_released 16384
> compact_balloon_returned 0
> 
> 
> * 128 mB balloon:
> [root@localhost ~]# awk '/compact/ {print}' /proc/vmstat
> compact_blocks_moved 0
> compact_pages_moved 0
> compact_pagemigrate_failed 0
> compact_stall 0
> compact_fail 0
> compact_success 0
> compact_balloon_isolated 0
> compact_balloon_migrated 0
> compact_balloon_released 0
> compact_balloon_returned 0
> [root@localhost ~]# 
> [root@localhost ~]# for i in $(seq 1 6); do echo 1 > /proc/sys/vm/compact_memory & done &>/dev/null  
> [1]   Done                    echo 1 > /proc/sys/vm/compact_memory
> [2]   Done                    echo 1 > /proc/sys/vm/compact_memory
> [3]   Done                    echo 1 > /proc/sys/vm/compact_memory
> [4]   Done                    echo 1 > /proc/sys/vm/compact_memory
> [5]-  Done                    echo 1 > /proc/sys/vm/compact_memory
> [6]+  Done                    echo 1 > /proc/sys/vm/compact_memory
> [root@localhost ~]# 
> [root@localhost ~]# awk '/compact/ {print}' /proc/vmstat
> compact_blocks_moved 3062
> compact_pages_moved 49774
> compact_pagemigrate_failed 129
> compact_stall 0
> compact_fail 0
> compact_success 0
> compact_balloon_isolated 26076
> compact_balloon_migrated 25957
> compact_balloon_released 25957
> compact_balloon_returned 119
> 
> -- 
> 1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
