Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id A56636B0085
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 11:48:17 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [V5 PATCH 25/26] memblock: compare current_limit with end variable at memblock_find_in_range_node()
Date: Mon, 29 Oct 2012 23:21:15 +0800
Message-Id: <1351524078-20363-24-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1351523301-20048-1-git-send-email-laijs@cn.fujitsu.com>
References: <1351523301-20048-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, x86 maintainers <x86@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, Rusty Russell <rusty@rustcorp.com.au>, Yinghai Lu <yinghai@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

memblock_find_in_range_node() does not compare memblock.current_limit
with end variable. Thus even if memblock.current_limit is smaller than
end variable, the function allocates memory address that is bigger than
memblock.current_limit.

The patch adds the check to "memblock_find_in_range_node()"

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 mm/memblock.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index ee2e307..50ab53c 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -100,11 +100,12 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 					phys_addr_t align, int nid)
 {
 	phys_addr_t this_start, this_end, cand;
+	phys_addr_t current_limit = memblock.current_limit;
 	u64 i;
 
 	/* pump up @end */
-	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
-		end = memblock.current_limit;
+	if ((end == MEMBLOCK_ALLOC_ACCESSIBLE) || (end > current_limit))
+		end = current_limit;
 
 	/* avoid allocating the first page */
 	start = max_t(phys_addr_t, start, PAGE_SIZE);
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
