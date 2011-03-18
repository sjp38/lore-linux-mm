Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DF3458D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 00:11:25 -0400 (EDT)
Message-ID: <4D82DBD4.8040407@cn.fujitsu.com>
Date: Fri, 18 Mar 2011 12:13:08 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 34/36] vmalloc,rcu: convert call_rcu(rcu_free_vb) to kfree_rcu()
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Namhyung Kim <namhyung@gmail.com>, Pekka Enberg <penberg@kernel.org>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



The rcu callback rcu_free_vb() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(rcu_free_vb).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 mm/vmalloc.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index fe38e30..2f3c614 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -778,13 +778,6 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
 	return vb;
 }
 
-static void rcu_free_vb(struct rcu_head *head)
-{
-	struct vmap_block *vb = container_of(head, struct vmap_block, rcu_head);
-
-	kfree(vb);
-}
-
 static void free_vmap_block(struct vmap_block *vb)
 {
 	struct vmap_block *tmp;
@@ -797,7 +790,7 @@ static void free_vmap_block(struct vmap_block *vb)
 	BUG_ON(tmp != vb);
 
 	free_vmap_area_noflush(vb->va);
-	call_rcu(&vb->rcu_head, rcu_free_vb);
+	kfree_rcu(vb, rcu_head);
 }
 
 static void purge_fragmented_blocks(int cpu)
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
