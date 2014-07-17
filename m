Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6968A6B0036
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 19:10:10 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id tr6so3815609ieb.4
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 16:10:10 -0700 (PDT)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id d4si8605470igc.38.2014.07.17.16.10.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 16:10:09 -0700 (PDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 17 Jul 2014 17:10:08 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id D4B573E4003F
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 17:10:05 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6HN8rdd3342776
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 01:08:53 +0200
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6HNA5tB023522
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 17:10:05 -0600
Date: Thu, 17 Jul 2014 16:09:58 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [RFC 1/2] workqueue: use the nearest NUMA node, not the local one
Message-ID: <20140717230958.GB32660@linux.vnet.ibm.com>
References: <20140717230923.GA32660@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140717230923.GA32660@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

In the presence of memoryless nodes, the workqueue code incorrectly uses
cpu_to_node() to determine what node to prefer memory allocations come
from. cpu_to_mem() should be used instead, which will use the nearest
NUMA node with memory.

Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 35974ac..0bba022 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -3547,7 +3547,12 @@ static struct worker_pool *get_unbound_pool(const struct workqueue_attrs *attrs)
 		for_each_node(node) {
 			if (cpumask_subset(pool->attrs->cpumask,
 					   wq_numa_possible_cpumask[node])) {
-				pool->node = node;
+				/*
+				 * We could use local_memory_node(node) here,
+				 * but it is expensive and the following caches
+				 * the same value.
+				 */
+				pool->node = cpu_to_mem(cpumask_first(pool->attrs->cpumask));
 				break;
 			}
 		}
@@ -4921,7 +4926,7 @@ static int __init init_workqueues(void)
 			pool->cpu = cpu;
 			cpumask_copy(pool->attrs->cpumask, cpumask_of(cpu));
 			pool->attrs->nice = std_nice[i++];
-			pool->node = cpu_to_node(cpu);
+			pool->node = cpu_to_mem(cpu);
 
 			/* alloc pool ID */
 			mutex_lock(&wq_pool_mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
