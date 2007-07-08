From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 05/12] Slab defragmentation: Log information to the syslog to show defrag operations
Date: Sat, 07 Jul 2007 20:05:43 -0700
Message-ID: <20070708030844.569230197@sgi.com>
References: <20070708030538.729027694@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756138AbXGHDI5@vger.kernel.org>
Content-Disposition: inline; filename=slub_defrag_tracing
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com
List-Id: linux-mm.kvack.org

Dump information into the syslog during defragmentation actions to show that
something is occurring and what effect it has.

This is likely only useful in mm for testing and verification.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

Index: linux-2.6.22-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/slub.c	2007-07-06 20:04:54.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/slub.c	2007-07-06 20:06:45.000000000 -0700
@@ -2599,6 +2599,8 @@ static unsigned long sort_partial_list(s
 	return freed;
 }
 
+#define NR_INUSE 40
+
 /*
  * Shrink the slab cache on a particular node of the cache
  */
@@ -2610,6 +2612,8 @@ static unsigned long __kmem_cache_shrink
 	LIST_HEAD(zaplist);
 	int freed;
 	int inuse;
+	int nr[NR_INUSE] = { 0, };
+	int i;
 
 	spin_lock_irqsave(&n->list_lock, flags);
 	freed = sort_partial_list(s, n, scratch);
@@ -2646,6 +2650,8 @@ static unsigned long __kmem_cache_shrink
 		n->nr_partial--;
 		SetSlabFrozen(page);
 		slab_unlock(page);
+		if (inuse < NR_INUSE)
+			nr[inuse]++;
 	}
 
 	spin_unlock_irqrestore(&n->list_lock, flags);
@@ -2659,6 +2665,13 @@ static unsigned long __kmem_cache_shrink
 		if (__kmem_cache_vacate(s, page, flags, scratch) == 0)
 			freed++;
 	}
+	printk(KERN_INFO "Slab %s: Defrag freed %d pages. PartSlab config=",
+			s->name, freed << s->order);
+
+	for (i = 0; i < NR_INUSE; i++)
+		if (nr[i])
+			printk(" %d=%d", i, nr[i]);
+	printk("\n");
 	return freed;
 }
 

-- 
