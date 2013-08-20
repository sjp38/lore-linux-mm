Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 2E6386B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 18:16:33 -0400 (EDT)
Date: Tue, 20 Aug 2013 15:16:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [resend] [PATCH V3] mm: vmscan: fix do_try_to_free_pages()
 livelock
Message-Id: <20130820151630.2a61ae9d88ea34a69e9d04bf@linux-foundation.org>
In-Reply-To: <89813612683626448B837EE5A0B6A7CB3B631767D7@SC-VEXCH4.marvell.com>
References: <89813612683626448B837EE5A0B6A7CB3B630BE80B@SC-VEXCH4.marvell.com>
	<20130805074146.GD10146@dhcp22.suse.cz>
	<89813612683626448B837EE5A0B6A7CB3B630BED6B@SC-VEXCH4.marvell.com>
	<20130806103543.GA31138@dhcp22.suse.cz>
	<89813612683626448B837EE5A0B6A7CB3B63175BCA@SC-VEXCH4.marvell.com>
	<20130808181426.GI715@cmpxchg.org>
	<89813612683626448B837EE5A0B6A7CB3B631767D7@SC-VEXCH4.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Bob Liu <lliubbo@gmail.com>, Neil Zhang <zhangwm@marvell.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, "yinghan@google.com" <yinghan@google.com>, "npiggin@gmail.com" <npiggin@gmail.com>, "riel@redhat.com" <riel@redhat.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>

On Sun, 11 Aug 2013 18:46:08 -0700 Lisa Du <cldu@marvell.com> wrote:

> In this version:
> Reorder the check in pgdat_balanced according Johannes's comment.
> 
> >From 66a98566792b954e187dca251fbe3819aeb977b9 Mon Sep 17 00:00:00 2001
> From: Lisa Du <cldu@marvell.com>
> Date: Mon, 5 Aug 2013 09:26:57 +0800
> Subject: [PATCH] mm: vmscan: fix do_try_to_free_pages() livelock
> 
> This patch is based on KOSAKI's work and I add a little more
> description, please refer https://lkml.org/lkml/2012/6/14/74.
> 
> Currently, I found system can enter a state that there are lots
> of free pages in a zone but only order-0 and order-1 pages which
> means the zone is heavily fragmented, then high order allocation
> could make direct reclaim path's long stall(ex, 60 seconds)
> especially in no swap and no compaciton enviroment. This problem
> happened on v3.4, but it seems issue still lives in current tree,
> the reason is do_try_to_free_pages enter live lock:
> 
> kswapd will go to sleep if the zones have been fully scanned
> and are still not balanced. As kswapd thinks there's little point
> trying all over again to avoid infinite loop. Instead it changes
> order from high-order to 0-order because kswapd think order-0 is the
> most important. Look at 73ce02e9 in detail. If watermarks are ok,
> kswapd will go back to sleep and may leave zone->all_unreclaimable = 0.
> It assume high-order users can still perform direct reclaim if they wish.
> 
> Direct reclaim continue to reclaim for a high order which is not a
> COSTLY_ORDER without oom-killer until kswapd turn on zone->all_unreclaimble.
> This is because to avoid too early oom-kill. So it means direct_reclaim
> depends on kswapd to break this loop.
> 
> In worst case, direct-reclaim may continue to page reclaim forever
> when kswapd sleeps forever until someone like watchdog detect and finally
> kill the process. As described in:
> http://thread.gmane.org/gmane.linux.kernel.mm/103737
> 
> We can't turn on zone->all_unreclaimable from direct reclaim path
> because direct reclaim path don't take any lock and this way is racy.

I don't see that this is correct.  Page reclaim does racy things quite
often, in the knowledge that the effects of a race are recoverable and
small.

> Thus this patch removes zone->all_unreclaimable field completely and
> recalculates zone reclaimable state every time.
> 
> Note: we can't take the idea that direct-reclaim see zone->pages_scanned
> directly and kswapd continue to use zone->all_unreclaimable. Because, it
> is racy. commit 929bea7c71 (vmscan: all_unreclaimable() use
> zone->all_unreclaimable as a name) describes the detail.
> 
> @@ -99,4 +100,23 @@ static __always_inline enum lru_list page_lru(struct page *page)
>  	return lru;
>  }
>  
> +static inline unsigned long zone_reclaimable_pages(struct zone *zone)
> +{
> +	int nr;
> +
> +	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
> +	     zone_page_state(zone, NR_INACTIVE_FILE);
> +
> +	if (get_nr_swap_pages() > 0)
> +		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
> +		      zone_page_state(zone, NR_INACTIVE_ANON);
> +
> +	return nr;
> +}
> +
> +static inline bool zone_reclaimable(struct zone *zone)
> +{
> +	return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
> +}

Inlining is often wrong.  Uninlining just these two funtions saves
several hundred bytes of text in mm/.  That's three of someone else's
cachelines which we didn't need to evict.

And what the heck is up with that magical "6"?  Why not "7"?  "42"?

At a minimum it needs extensive documentation which describes why "6"
is the optimum value for all machines and workloads (good luck with
that) and which describes the effects of altering this number and which
helps people understand why we didn't make it a runtime tunable.

I'll merge it for some testing (the lack of Tested-by's is conspicuous)
but I don't want to put that random "6" into Linux core MM in its
current state.


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-vmscan-fix-do_try_to_free_pages-livelock-fix

uninline zone_reclaimable_pages() and zone_reclaimable().

Cc: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Cc: Bob Liu <lliubbo@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lisa Du <cldu@marvell.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Neil Zhang <zhangwm@marvell.com>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Ying Han <yinghan@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/mm_inline.h |   19 -------------------
 mm/internal.h             |    2 ++
 mm/page-writeback.c       |    2 ++
 mm/vmscan.c               |   19 +++++++++++++++++++
 mm/vmstat.c               |    2 ++
 5 files changed, 25 insertions(+), 19 deletions(-)

diff -puN include/linux/mm_inline.h~mm-vmscan-fix-do_try_to_free_pages-livelock-fix include/linux/mm_inline.h
--- a/include/linux/mm_inline.h~mm-vmscan-fix-do_try_to_free_pages-livelock-fix
+++ a/include/linux/mm_inline.h
@@ -100,23 +100,4 @@ static __always_inline enum lru_list pag
 	return lru;
 }
 
-static inline unsigned long zone_reclaimable_pages(struct zone *zone)
-{
-	int nr;
-
-	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
-	     zone_page_state(zone, NR_INACTIVE_FILE);
-
-	if (get_nr_swap_pages() > 0)
-		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
-		      zone_page_state(zone, NR_INACTIVE_ANON);
-
-	return nr;
-}
-
-static inline bool zone_reclaimable(struct zone *zone)
-{
-	return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
-}
-
 #endif
diff -puN include/linux/mmzone.h~mm-vmscan-fix-do_try_to_free_pages-livelock-fix include/linux/mmzone.h
diff -puN include/linux/vmstat.h~mm-vmscan-fix-do_try_to_free_pages-livelock-fix include/linux/vmstat.h
diff -puN mm/page-writeback.c~mm-vmscan-fix-do_try_to_free_pages-livelock-fix mm/page-writeback.c
--- a/mm/page-writeback.c~mm-vmscan-fix-do_try_to_free_pages-livelock-fix
+++ a/mm/page-writeback.c
@@ -39,6 +39,8 @@
 #include <linux/mm_inline.h>
 #include <trace/events/writeback.h>
 
+#include "internal.h"
+
 /*
  * Sleep at most 200ms at a time in balance_dirty_pages().
  */
diff -puN mm/page_alloc.c~mm-vmscan-fix-do_try_to_free_pages-livelock-fix mm/page_alloc.c
diff -puN mm/vmscan.c~mm-vmscan-fix-do_try_to_free_pages-livelock-fix mm/vmscan.c
--- a/mm/vmscan.c~mm-vmscan-fix-do_try_to_free_pages-livelock-fix
+++ a/mm/vmscan.c
@@ -146,6 +146,25 @@ static bool global_reclaim(struct scan_c
 }
 #endif
 
+unsigned long zone_reclaimable_pages(struct zone *zone)
+{
+	int nr;
+
+	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
+	     zone_page_state(zone, NR_INACTIVE_FILE);
+
+	if (get_nr_swap_pages() > 0)
+		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
+		      zone_page_state(zone, NR_INACTIVE_ANON);
+
+	return nr;
+}
+
+bool zone_reclaimable(struct zone *zone)
+{
+	return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
+}
+
 static unsigned long get_lru_size(struct lruvec *lruvec, enum lru_list lru)
 {
 	if (!mem_cgroup_disabled())
diff -puN mm/vmstat.c~mm-vmscan-fix-do_try_to_free_pages-livelock-fix mm/vmstat.c
--- a/mm/vmstat.c~mm-vmscan-fix-do_try_to_free_pages-livelock-fix
+++ a/mm/vmstat.c
@@ -21,6 +21,8 @@
 #include <linux/compaction.h>
 #include <linux/mm_inline.h>
 
+#include "internal.h"
+
 #ifdef CONFIG_VM_EVENT_COUNTERS
 DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
 EXPORT_PER_CPU_SYMBOL(vm_event_states);
diff -puN mm/internal.h~mm-vmscan-fix-do_try_to_free_pages-livelock-fix mm/internal.h
--- a/mm/internal.h~mm-vmscan-fix-do_try_to_free_pages-livelock-fix
+++ a/mm/internal.h
@@ -85,6 +85,8 @@ extern unsigned long highest_memmap_pfn;
  */
 extern int isolate_lru_page(struct page *page);
 extern void putback_lru_page(struct page *page);
+extern unsigned long zone_reclaimable_pages(struct zone *zone);
+extern bool zone_reclaimable(struct zone *zone);
 
 /*
  * in mm/rmap.c:
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
