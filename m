Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0EE6B007D
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 15:54:07 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <20100211953.850854588@firstfloor.org>
In-Reply-To: <20100211953.850854588@firstfloor.org>
Subject: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
Message-Id: <20100211205404.085FEB1978@basil.firstfloor.org>
Date: Thu, 11 Feb 2010 21:54:04 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>


cache_reap can run before the node is set up and then reference a NULL 
l3 list. Check for this explicitely and just continue. The node
will be eventually set up.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/slab.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6.32-memhotadd/mm/slab.c
===================================================================
--- linux-2.6.32-memhotadd.orig/mm/slab.c
+++ linux-2.6.32-memhotadd/mm/slab.c
@@ -4093,6 +4093,9 @@ static void cache_reap(struct work_struc
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
