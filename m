Subject: mm: call into direct reclaim without PF_MEMALLOC set
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Content-Type: text/plain
Date: Wed, 15 Nov 2006 20:25:03 +0100
Message-Id: <1163618703.5968.50.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

PF_MEMALLOC keeps direct reclaim from recursing into itself, I noticed this
call to try_to_free_pages didn't set it thus opening the floodgates.

/me wonders why this never triggered...

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/buffer.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

Index: linux-2.6-git/fs/buffer.c
===================================================================
--- linux-2.6-git.orig/fs/buffer.c	2006-11-15 20:14:58.000000000 +0100
+++ linux-2.6-git/fs/buffer.c	2006-11-15 20:19:22.000000000 +0100
@@ -360,8 +360,18 @@ static void free_more_memory(void)
 
 	for_each_online_pgdat(pgdat) {
 		zones = pgdat->node_zonelists[gfp_zone(GFP_NOFS)].zones;
-		if (*zones)
+		if (*zones) {
+			struct task_struct *p = current;
+			struct reclaim_state reclaim_state;
+			reclaim_state.reclaim_slab = 0;
+			p->flags |= PF_MEMALLOC;
+			p->reclaim_state = &reclaim_state;
+
 			try_to_free_pages(zones, GFP_NOFS);
+
+			p->reclaim_state = NULL;
+			p->flags &= ~PF_MEMALLOC;
+		}
 	}
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
