Date: Tue, 18 Sep 2007 13:23:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 5/4] oom: rename serialization helper functions
In-Reply-To: <alpine.DEB.0.9999.0709181302490.22984@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709181323080.25339@chino.kir.corp.google.com>
References: <871b7a4fd566de081120.1187786931@v2.random> <alpine.DEB.0.9999.0709131139340.30279@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131152400.9999@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131732330.21805@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709131923410.12159@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709132010050.30494@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180007420.4624@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180245170.21326@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180246350.21326@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180246580.21326@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180247250.21326@chino.kir.corp.google.com> <Pine.LNX.4.64.0709181253280.3953@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709181255320.22517@chino.kir.corp.google.com> <Pine.LNX.4.64.0709181258570.3953@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709181302490.22984@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Sep 2007, David Rientjes wrote:

> Yes, but this would require a change in oom_killer_trylock() since it is 
> coded to return non-zero if the OOM killer has already been invoked for at 
> least one of the zones.  The use of "trylock" here is being abused anyway 
> since there's actually no locks involved, so maybe the function pair 
> should simply be renamed to zone_in_oom() and zonelist_clear_oom().  I'll 
> make the change, thanks for keeping it consistent.
> 

oom: rename serialization helper functions

Rename oom_killer_trylock() and oom_killer_unlock() to zone_in_oom() and
zonelist_clear_oom(), respectively.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/oom.h |    4 ++--
 mm/oom_kill.c       |    4 ++--
 mm/page_alloc.c     |    8 ++++----
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -20,8 +20,8 @@ enum oom_constraint {
 	CONSTRAINT_MEMORY_POLICY,
 };
 
-extern int oom_killer_trylock(struct zonelist *zonelist);
-extern void oom_killer_unlock(const struct zonelist *zonelist);
+extern int zone_in_oom(struct zonelist *zonelist);
+extern void zonelist_clear_oom(const struct zonelist *zonelist);
 
 extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order);
 extern int register_oom_notifier(struct notifier_block *nb);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -408,7 +408,7 @@ static int is_zone_locked(const struct zone *zone)
  * non-zero if a parallel OOM killing is already taking place that includes a
  * zone in the zonelist.
  */
-int oom_killer_trylock(struct zonelist *zonelist)
+int zone_in_oom(struct zonelist *zonelist)
 {
 	struct oom_zonelist *oom_zl;
 	int ret = 0;
@@ -436,7 +436,7 @@ out:
  * Removes the zonelist from the list so that future allocations that include
  * its zones can successfully call the OOM killer.
  */
-void oom_killer_unlock(const struct zonelist *zonelist)
+void zonelist_clear_oom(const struct zonelist *zonelist)
 {
 	struct oom_zonelist *oom_zl;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1353,7 +1353,7 @@ nofail_alloc:
 		if (page)
 			goto got_pg;
 	} else if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
-		if (oom_killer_trylock(zonelist)) {
+		if (zone_in_oom(zonelist)) {
 			schedule_timeout_uninterruptible(1);
 			goto restart;
 		}
@@ -1367,18 +1367,18 @@ nofail_alloc:
 		page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
 				zonelist, ALLOC_WMARK_HIGH|ALLOC_CPUSET);
 		if (page) {
-			oom_killer_unlock(zonelist);
+			zonelist_clear_oom(zonelist);
 			goto got_pg;
 		}
 
 		/* The OOM killer will not help higher order allocs so fail */
 		if (order > PAGE_ALLOC_COSTLY_ORDER) {
-			oom_killer_unlock(zonelist);
+			zonelist_clear_oom(zonelist);
 			goto nopage;
 		}
 
 		out_of_memory(zonelist, gfp_mask, order);
-		oom_killer_unlock(zonelist);
+		zonelist_clear_oom(zonelist);
 		goto restart;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
