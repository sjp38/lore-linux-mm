Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f45.google.com (mail-oa0-f45.google.com [209.85.219.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0566B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 20:14:34 -0400 (EDT)
Received: by mail-oa0-f45.google.com with SMTP id i7so409537oag.18
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 17:14:33 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id os18si4842732oeb.23.2014.08.13.17.14.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 17:14:33 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 13 Aug 2014 18:14:32 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTPS id 4E33D19D8041
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 18:14:18 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s7E0ETKd23199858
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 02:14:29 +0200
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s7E0ESve010446
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 18:14:29 -0600
Date: Wed, 13 Aug 2014 17:14:22 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 1/4] topology: add support for node_to_mem_node() to
 determine the fallback node
Message-ID: <20140814001422.GJ11121@linux.vnet.ibm.com>
References: <20140814001301.GI11121@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140814001301.GI11121@linux.vnet.ibm.com>
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
Cc: David Rientjes <rientjes@google.com>
Cc: Han Pingtian <hanpt@linux.vnet.ibm.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Anton Blanchard <anton@samba.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Linux Memory Management List <linux-mm@kvack.org>
Cc: linuxppc-dev@lists.ozlabs.org

---
v2 -> v3 (Nishanth):
  Fix declaration and definition of _node_numa_mem_.
  s/node_numa_mem/node_to_mem_node/ as suggested by David Rientjes.

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
