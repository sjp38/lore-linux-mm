Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0C582A8B
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 03:36:55 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id eu11so1003588pac.11
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 00:36:54 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id cf5si1579350pbc.10.2014.07.11.00.36.53
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 00:36:54 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [RFC Patch V1 22/30] mm, of: Use cpu_to_mem()/numa_mem_id() to support memoryless node
Date: Fri, 11 Jul 2014 15:37:39 +0800
Message-Id: <1405064267-11678-23-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Grant Likely <grant.likely@linaro.org>, Rob Herring <robh+dt@kernel.org>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, devicetree@vger.kernel.org

When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
may return a node without memory, and later cause system failure/panic
when calling kmalloc_node() and friends with returned node id.
So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
memory for the/current cpu.

If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
is the same as cpu_to_node()/numa_node_id().

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 drivers/of/base.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/of/base.c b/drivers/of/base.c
index b9864806e9b8..40d4772973ad 100644
--- a/drivers/of/base.c
+++ b/drivers/of/base.c
@@ -85,7 +85,7 @@ EXPORT_SYMBOL(of_n_size_cells);
 #ifdef CONFIG_NUMA
 int __weak of_node_to_nid(struct device_node *np)
 {
-	return numa_node_id();
+	return numa_mem_id();
 }
 #endif
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
