Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id E98296B0036
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:27:56 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part2 PATCH v4 01/15] x86: get pg_data_t's memory from other node
Date: Thu, 13 Jun 2013 21:03:25 +0800
Message-Id: <1371128619-8987-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128619-8987-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128619-8987-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

If system can create movable node which all memory of the
node is allocated as ZONE_MOVABLE, setup_node_data() cannot
allocate memory for the node's pg_data_t.
So, use memblock_alloc_try_nid() instead of memblock_alloc_nid()
to retry when the first allocation fails.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 arch/x86/mm/numa.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 5adf803..bea597a 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -211,10 +211,9 @@ static void __init setup_node_data(int nid, u64 start, u64 end)
 	 * Allocate node data.  Try node-local memory and then any node.
 	 * Never allocate in DMA zone.
 	 */
-	nd_pa = memblock_alloc_nid(nd_size, SMP_CACHE_BYTES, nid);
+	nd_pa = memblock_alloc_try_nid(nd_size, SMP_CACHE_BYTES, nid);
 	if (!nd_pa) {
-		pr_err("Cannot find %zu bytes in node %d\n",
-		       nd_size, nid);
+		pr_err("Cannot find %zu bytes in any node\n", nd_size);
 		return;
 	}
 	nd = __va(nd_pa);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
