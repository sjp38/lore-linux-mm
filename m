Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 631AA6B0075
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 05:16:02 -0400 (EDT)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PART5 Patch 5/5] memblock: compare current_limit with end variable at memblock_find_in_range_node()
Date: Wed, 31 Oct 2012 17:21:43 +0800
Message-Id: <1351675303-11786-6-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1351675303-11786-1-git-send-email-wency@cn.fujitsu.com>
References: <1351675303-11786-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

memblock_find_in_range_node() does not compare memblock.current_limit
with end variable. Thus even if memblock.current_limit is smaller than
end variable, the function allocates memory address that is bigger than
memblock.current_limit.

The patch adds the check to "memblock_find_in_range_node()"

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 mm/memblock.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

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
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
