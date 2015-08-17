Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5D637280244
	for <linux-mm@kvack.org>; Sun, 16 Aug 2015 23:16:07 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so98426307pab.0
        for <linux-mm@kvack.org>; Sun, 16 Aug 2015 20:16:07 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id dn2si22343750pdb.103.2015.08.16.20.16.06
        for <linux-mm@kvack.org>;
        Sun, 16 Aug 2015 20:16:06 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [Patch V3 3/9] sgi-xp: Replace cpu_to_node() with cpu_to_mem() to support memoryless node
Date: Mon, 17 Aug 2015 11:19:00 +0800
Message-Id: <1439781546-7217-4-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Cliff Whickman <cpw@sgi.com>, Robin Holt <robinmholt@gmail.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

Function xpc_create_gru_mq_uv() allocates memory with __GFP_THISNODE
flag set, which may cause permanent memory allocation failure on
memoryless node. So replace cpu_to_node() with cpu_to_mem() to better
support memoryless node. For node with memory, cpu_to_mem() is the same
as cpu_to_node().

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 drivers/misc/sgi-xp/xpc_uv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/misc/sgi-xp/xpc_uv.c b/drivers/misc/sgi-xp/xpc_uv.c
index 95c894482fdd..9210981c0d5b 100644
--- a/drivers/misc/sgi-xp/xpc_uv.c
+++ b/drivers/misc/sgi-xp/xpc_uv.c
@@ -238,7 +238,7 @@ xpc_create_gru_mq_uv(unsigned int mq_size, int cpu, char *irq_name,
 
 	mq->mmr_blade = uv_cpu_to_blade_id(cpu);
 
-	nid = cpu_to_node(cpu);
+	nid = cpu_to_mem(cpu);
 	page = alloc_pages_exact_node(nid,
 				      GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
 				      pg_order);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
