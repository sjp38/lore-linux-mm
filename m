Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C69208D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 00:10:35 -0400 (EDT)
Message-ID: <4D82DBA3.5020306@cn.fujitsu.com>
Date: Fri, 18 Mar 2011 12:12:19 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 33/36] vmalloc,rcu: convert call_rcu(rcu_free_va) to kfree_rcu()
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Namhyung Kim <namhyung@gmail.com>, Pekka Enberg <penberg@kernel.org>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



The rcu callback rcu_free_va() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(rcu_free_va).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 mm/vmalloc.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index f9b1667..fe38e30 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -416,13 +416,6 @@ overflow:
 	return va;
 }
 
-static void rcu_free_va(struct rcu_head *head)
-{
-	struct vmap_area *va = container_of(head, struct vmap_area, rcu_head);
-
-	kfree(va);
-}
-
 static void __free_vmap_area(struct vmap_area *va)
 {
 	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
@@ -439,7 +432,7 @@ static void __free_vmap_area(struct vmap_area *va)
 	if (va->va_end > VMALLOC_START && va->va_end <= VMALLOC_END)
 		vmap_area_pcpu_hole = max(vmap_area_pcpu_hole, va->va_end);
 
-	call_rcu(&va->rcu_head, rcu_free_va);
+	kfree_rcu(va, rcu_head);
 }
 
 /*
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
