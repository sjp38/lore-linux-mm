Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 802C36B004D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 16:39:15 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <201002031039.710275915@firstfloor.org>
In-Reply-To: <201002031039.710275915@firstfloor.org>
Subject: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
Message-Id: <20100203213915.DB0EBB1620@basil.firstfloor.org>
Date: Wed,  3 Feb 2010 22:39:15 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, penberg@cs.helsinki.fi, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


cache_reap can run before the node is set up and then reference a NULL 
l3 list. Check for this explicitely and just continue. The node
will be eventually set up.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/slab.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6.33-rc3-ak/mm/slab.c
===================================================================
--- linux-2.6.33-rc3-ak.orig/mm/slab.c
+++ linux-2.6.33-rc3-ak/mm/slab.c
@@ -4112,6 +4112,9 @@ static void cache_reap(struct work_struc
 		 * we can do some work if the lock was obtained.
 		 */
 		l3 = searchp->nodelists[node];
+		/* Note node yet set up */
+		if (!l3)
+			break;
 
 		reap_alien(searchp, l3);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
