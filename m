Date: Tue, 18 Sep 2007 09:44:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 4/4] oom: serialize out of memory calls
In-Reply-To: <alpine.DEB.0.9999.0709180246580.21326@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709180247250.21326@chino.kir.corp.google.com>
References: <871b7a4fd566de081120.1187786931@v2.random> <Pine.LNX.4.64.0709121658450.4489@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131126370.27997@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131136560.9590@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709131139340.30279@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131152400.9999@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131732330.21805@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131923410.12159@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709132010050.30494@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180007420.4624@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180245170.21326@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180246350.21326@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180246580.21326@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Before invoking the OOM killer, a final allocation attempt with a very
high watermark is attempted.  Serialization needs to occur at this point
or it may be possible that the allocation could succeed after acquiring
the lock.  If the lock is contended, the task is put to sleep and the
allocation attempt is retried when rescheduled.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1353,6 +1353,11 @@ nofail_alloc:
 		if (page)
 			goto got_pg;
 	} else if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
+		if (oom_killer_trylock(zonelist)) {
+			schedule_timeout_uninterruptible(1);
+			goto restart;
+		}
+
 		/*
 		 * Go through the zonelist yet one more time, keep
 		 * very high watermark here, this is only to catch
@@ -1361,14 +1366,19 @@ nofail_alloc:
 		 */
 		page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
 				zonelist, ALLOC_WMARK_HIGH|ALLOC_CPUSET);
-		if (page)
+		if (page) {
+			oom_killer_unlock(zonelist);
 			goto got_pg;
+		}
 
 		/* The OOM killer will not help higher order allocs so fail */
-		if (order > PAGE_ALLOC_COSTLY_ORDER)
+		if (order > PAGE_ALLOC_COSTLY_ORDER) {
+			oom_killer_unlock(zonelist);
 			goto nopage;
+		}
 
 		out_of_memory(zonelist, gfp_mask, order);
+		oom_killer_unlock(zonelist);
 		goto restart;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
