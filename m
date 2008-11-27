Date: Thu, 27 Nov 2008 18:36:10 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [rfc] vmscan: serialize aggressive reclaimers
Message-ID: <20081127173610.GA1781@cmpxchg.org>
References: <20081124145057.4211bd46@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081124145057.4211bd46@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Since we have to pull through a reclaim cycle once we commited to it,
what do you think about serializing the lower priority levels
completely?

The idea is that when one reclaimer has done a low priority level
iteration with a huge reclaim target, chances are that succeeding
reclaimers don't even need to drop to lower levels at all because
enough memory has already been freed.

My testprogram maps and faults in a file that is about as large as my
physical memory.  Then it spawns off n processes that try allocate
1/2n of total memory in anon pages, i.e. half of it in sum.  After it
ran, I check how much memory has been reclaimed.  But my zone sizes
are too small to induce enormous reclaim targets so I don't see vast
over-reclaims.

I have measured the time of other tests on an SMP machine with 4 cores
and the following patch applied.  I couldn't see any performance
degradation.  But since the bug is not triggerable here, I can not
prove it helps the original problem, either.

The level where it starts serializing is chosen pretty arbitrarily.
Suggestions welcome :)

	Hannes

---

Prevent over-reclaiming by serializing direct reclaimers below a
certain priority level.

Over-reclaiming happens when the sum of the reclaim targets of all
reclaiming processes is larger than the sum of the needed free pages,
thus leading to excessive eviction of more cache and anonymous pages
than required.

A scan iteration over all zones can not be aborted intermittently when
enough pages are reclaimed because that would mess up the scan balance
between the zones.  Instead, prevent that too many processes
simultaneously commit themselves to lower priority level scans in the
first place.

Chances are that after the exclusive reclaimer has finished, enough
memory has been freed that succeeding scanners don't need to drop to
lower priority levels at all anymore.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---
 mm/vmscan.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -35,6 +35,7 @@
 #include <linux/notifier.h>
 #include <linux/rwsem.h>
 #include <linux/delay.h>
+#include <linux/wait.h>
 #include <linux/kthread.h>
 #include <linux/freezer.h>
 #include <linux/memcontrol.h>
@@ -42,6 +43,7 @@
 #include <linux/sysctl.h>
 
 #include <asm/tlbflush.h>
+#include <asm/atomic.h>
 #include <asm/div64.h>
 
 #include <linux/swapops.h>
@@ -1546,10 +1548,15 @@ static unsigned long shrink_zones(int pr
  * returns:	0, if no pages reclaimed
  * 		else, the number of pages reclaimed
  */
+
+static DECLARE_WAIT_QUEUE_HEAD(reclaim_wait);
+static atomic_t reclaim_exclusive = ATOMIC_INIT(0);
+
 static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 					struct scan_control *sc)
 {
 	int priority;
+	int exclusive = 0;
 	unsigned long ret = 0;
 	unsigned long total_scanned = 0;
 	unsigned long nr_reclaimed = 0;
@@ -1580,6 +1587,14 @@ static unsigned long do_try_to_free_page
 		sc->nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();
+		/*
+		 * Serialize aggressive reclaimers
+		 */
+		if (priority <= DEF_PRIORITY / 2 && !exclusive) {
+			wait_event(reclaim_wait,
+				!atomic_cmpxchg(&reclaim_exclusive, 0, 1));
+			exclusive = 1;
+		}
 		nr_reclaimed += shrink_zones(priority, zonelist, sc);
 		/*
 		 * Don't shrink slabs when reclaiming memory from
@@ -1629,6 +1644,11 @@ out:
 	if (priority < 0)
 		priority = 0;
 
+	if (exclusive) {
+		atomic_set(&reclaim_exclusive, 0);
+		wake_up(&reclaim_wait);
+	}
+
 	if (scan_global_lru(sc)) {
 		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
