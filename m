Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 0167B6B0037
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 05:18:24 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [RESEND PATCH part1 1/9] x86: get pg_data_t's memory from other node
Date: Thu, 21 Mar 2013 17:20:47 +0800
Message-Id: <1363857655-30658-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1363857655-30658-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1363857655-30658-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, mgorman@suse.de, walken@google.com, riel@redhat.com, khlebnikov@openvz.org, tj@kernel.org, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, kosaki.motohiro@jp.fujitsu.com, guz.fnst@cn.fujitsu.com
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
---
 arch/x86/mm/numa.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 11acdf6..4f754e6 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -214,10 +214,9 @@ static void __init setup_node_data(int nid, u64 start, u64 end)
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
