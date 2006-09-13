Date: Wed, 13 Sep 2006 16:12:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Fix kmalloc_node applying memory policies if nodeid == numa_node_id()
Message-ID: <Pine.LNX.4.64.0609131601220.20677@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Ravikiran Thirumalai <kiran@scalex86.org>
List-ID: <linux-mm.kvack.org>

kmalloc_node falls back to ___cache_alloc() under certain conditions and 
at that point memory policies may be applied redirecting the allocation 
away from the current node. Therefore kmalloc_node(...,numa_node_id()) or
kmalloc_node(...,-1) may not return memory from the local node.

Fix this by doing the policy check in __cache_alloc() instead of
____cache_alloc().

This version here is a cleanup of Kiran's patch.

- Tested on ia64.
- Extra material removed.
- Consolidate the exit path if alternate_node_alloc() returned an object.

Signed-off-by: Alok N Kataria <alok.kataria@calsoftinc.com>
Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
Signed-off-by: Shai Fultheim <shai@scalex86.org>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm2/mm/slab.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/mm/slab.c	2006-09-13 17:45:36.000000000 -0500
+++ linux-2.6.18-rc6-mm2/mm/slab.c	2006-09-13 18:04:57.889185988 -0500
@@ -3052,14 +3052,6 @@
 	void *objp;
 	struct array_cache *ac;
 
-#ifdef CONFIG_NUMA
-	if (unlikely(current->flags & (PF_SPREAD_SLAB | PF_MEMPOLICY))) {
-		objp = alternate_node_alloc(cachep, flags);
-		if (objp != NULL)
-			return objp;
-	}
-#endif
-
 	check_irq_off();
 	ac = cpu_cache_get(cachep);
 	if (likely(ac->avail)) {
@@ -3082,7 +3074,17 @@
 	cache_alloc_debugcheck_before(cachep, flags);
 
 	local_irq_save(save_flags);
+
+#ifdef CONFIG_NUMA
+	if (unlikely(current->flags & (PF_SPREAD_SLAB | PF_MEMPOLICY))) {
+		objp = alternate_node_alloc(cachep, flags);
+		if (objp != NULL)
+			goto out;
+	}
+#endif
+
 	objp = ____cache_alloc(cachep, flags);
+out:
 	local_irq_restore(save_flags);
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp,
 					    caller);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
