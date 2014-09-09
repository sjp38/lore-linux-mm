Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 78DF76B009D
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 15:03:40 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id cm18so15918833qab.2
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 12:03:40 -0700 (PDT)
Received: from e7.ny.us.ibm.com (e7.ny.us.ibm.com. [32.97.182.137])
        by mx.google.com with ESMTPS id z51si16237069qgd.105.2014.09.09.12.03.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 12:03:39 -0700 (PDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 9 Sep 2014 15:03:39 -0400
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 52292C90067
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 15:03:27 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s89J3Zm510224084
	for <linux-mm@kvack.org>; Tue, 9 Sep 2014 19:03:35 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s89J3YCj005429
	for <linux-mm@kvack.org>; Tue, 9 Sep 2014 15:03:35 -0400
Date: Tue, 9 Sep 2014 12:03:27 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [PATCH v3] topology: add support for node_to_mem_node() to determine
 the fallback node
Message-ID: <20140909190326.GD22906@linux.vnet.ibm.com>
References: <20140909190154.GC22906@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140909190154.GC22906@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

We need to determine the fallback node in slub allocator if the
allocation target node is memoryless node. Without it, the SLUB wrongly
select the node which has no memory and can't use a partial slab,
because of node mismatch. Introduced function, node_to_mem_node(X), will
return a node Y with memory that has the nearest distance. If X is
memoryless node, it will return nearest distance node, but, if X is
normal node, it will return itself.

We will use this function in following patch to determine the fallback
node.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

---
v2 -> v3 (Nishanth):
  Fix declaration and definition of _node_numa_mem_.
  s/node_numa_mem/node_to_mem_node/ as suggested by David Rientjes.

Andrew, I decided to leave the definition of the variables as-is. I
followed-up with Christoph, but didn't hear back on what he actually
wanted. I think the naming can be changed in a future patch if it's
urgent.

diff --git a/include/linux/topology.h b/include/linux/topology.h
index dda6ee521e74..909b6e43b694 100644
--- a/include/linux/topology.h
+++ b/include/linux/topology.h
@@ -119,11 +119,20 @@ static inline int numa_node_id(void)
  * Use the accessor functions set_numa_mem(), numa_mem_id() and cpu_to_mem().
  */
 DECLARE_PER_CPU(int, _numa_mem_);
+extern int _node_numa_mem_[MAX_NUMNODES];
 
 #ifndef set_numa_mem
 static inline void set_numa_mem(int node)
 {
 	this_cpu_write(_numa_mem_, node);
+	_node_numa_mem_[numa_node_id()] = node;
+}
+#endif
+
+#ifndef node_to_mem_node
+static inline int node_to_mem_node(int node)
+{
+	return _node_numa_mem_[node];
 }
 #endif
 
@@ -146,6 +155,7 @@ static inline int cpu_to_mem(int cpu)
 static inline void set_cpu_numa_mem(int cpu, int node)
 {
 	per_cpu(_numa_mem_, cpu) = node;
+	_node_numa_mem_[cpu_to_node(cpu)] = node;
 }
 #endif
 
@@ -159,6 +169,13 @@ static inline int numa_mem_id(void)
 }
 #endif
 
+#ifndef node_to_mem_node
+static inline int node_to_mem_node(int node)
+{
+	return node;
+}
+#endif
+
 #ifndef cpu_to_mem
 static inline int cpu_to_mem(int cpu)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 18cee0d4c8a2..0883c42936d4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -85,6 +85,7 @@ EXPORT_PER_CPU_SYMBOL(numa_node);
  */
 DEFINE_PER_CPU(int, _numa_mem_);		/* Kernel "local memory" node */
 EXPORT_PER_CPU_SYMBOL(_numa_mem_);
+int _node_numa_mem_[MAX_NUMNODES];
 #endif
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
