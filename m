Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 0DB5C6B005A
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 04:35:37 -0500 (EST)
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [RFC PATCH] mm: memblock: optimize memblock_find_in_range_node() to minimize the search work
Date: Fri, 4 Jan 2013 17:24:53 +0800
Message-Id: <1357291493-25773-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, tj@kernel.org
Cc: mingo@kernel.org, yinghai@kernel.org, liwanp@linux.vnet.ibm.com, benh@kernel.crashing.org, tangchen@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lin Feng <linfeng@cn.fujitsu.com>

The memblock array is in ascending order and we traverse the memblock array in
reverse order so we can add some simple check to reduce the search work.

Tejun fix a underflow bug in 5d53cb27d8, but I think we could break there for
the same reason.

Cc: Tejun Heo <tj@kernel.org>
Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 mm/memblock.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 6259055..a710557 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -111,11 +111,18 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
 	end = max(start, end);
 
 	for_each_free_mem_range_reverse(i, nid, &this_start, &this_end, NULL) {
+		/*
+		 * exclude the regions out of the candidate range, since it's
+		 * likely to find a suitable range, we ignore the worst case.
+		 */
+		if (this_start >= end)
+			continue;
+
 		this_start = clamp(this_start, start, end);
 		this_end = clamp(this_end, start, end);
 
 		if (this_end < size)
-			continue;
+			break;
 
 		cand = round_down(this_end - size, align);
 		if (cand >= this_start)
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
