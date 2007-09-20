Date: Thu, 20 Sep 2007 13:23:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 5/9] oom: serialize out of memory calls
In-Reply-To: <alpine.DEB.0.9999.0709201321070.25753@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709201321220.25753@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201321070.25753@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
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
+		if (!try_set_zone_oom(zonelist)) {
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
+			clear_zonelist_oom(zonelist);
 			goto got_pg;
+		}
 
 		/* The OOM killer will not help higher order allocs so fail */
-		if (order > PAGE_ALLOC_COSTLY_ORDER)
+		if (order > PAGE_ALLOC_COSTLY_ORDER) {
+			clear_zonelist_oom(zonelist);
 			goto nopage;
+		}
 
 		out_of_memory(zonelist, gfp_mask, order);
+		clear_zonelist_oom(zonelist);
 		goto restart;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
