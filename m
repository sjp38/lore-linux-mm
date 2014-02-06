Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id BE7C56B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 03:07:00 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id x10so1406466pdj.11
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 00:07:00 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id l8si150020pao.152.2014.02.06.00.06.58
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 00:06:59 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 2/3] topology: support node_numa_mem() for determining the fallback node
Date: Thu,  6 Feb 2014 17:07:05 +0900
Message-Id: <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <20140206020757.GC5433@linux.vnet.ibm.com>
 <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/topology.h b/include/linux/topology.h
index 12ae6ce..a6d5438 100644
--- a/include/linux/topology.h
+++ b/include/linux/topology.h
@@ -233,11 +233,20 @@ static inline int numa_node_id(void)
  * Use the accessor functions set_numa_mem(), numa_mem_id() and cpu_to_mem().
  */
 DECLARE_PER_CPU(int, _numa_mem_);
+int _node_numa_mem_[MAX_NUMNODES];
 
 #ifndef set_numa_mem
 static inline void set_numa_mem(int node)
 {
 	this_cpu_write(_numa_mem_, node);
+	_node_numa_mem_[numa_node_id()] = node;
+}
+#endif
+
+#ifndef get_numa_mem
+static inline int get_numa_mem(int node)
+{
+	return _node_numa_mem_[node];
 }
 #endif
 
@@ -260,6 +269,7 @@ static inline int cpu_to_mem(int cpu)
 static inline void set_cpu_numa_mem(int cpu, int node)
 {
 	per_cpu(_numa_mem_, cpu) = node;
+	_node_numa_mem_[numa_node_id()] = node;
 }
 #endif
 
@@ -273,6 +283,13 @@ static inline int numa_mem_id(void)
 }
 #endif
 
+#ifndef get_numa_mem
+static inline int get_numa_mem(int node)
+{
+	return node;
+}
+#endif
+
 #ifndef cpu_to_mem
 static inline int cpu_to_mem(int cpu)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
