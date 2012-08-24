Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 85E246B002B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 10:34:12 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sat, 25 Aug 2012 00:32:53 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7OEPIlh18022592
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 00:25:21 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7OEY3LK017493
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 00:34:03 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 1/5] mm/memblock: truncate memblock if necessary
Date: Fri, 24 Aug 2012 22:33:36 +0800
Message-Id: <1345818820-12102-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

From: Gavin Shan <shangw@linux.vnet.ibm.com>

While enforcing memory limit on current memblock layout, it is
possible that we don't have to change the current memblock layout.
For example, the enforced limited size is bigger than the maximal
address of memory regions. Also, we don't have to change the memory
layout while the enforced limited size is more than the accumulative
size of all memory regions.

The patch checks them and won't change current memblock layout for
those cases, thus to reduce some overhead.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memblock.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 4d9393c..c1fbb12 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -844,14 +844,14 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
 	unsigned long i;
 	phys_addr_t max_addr = (phys_addr_t)ULLONG_MAX;
 
-	if (!limit)
+	if (!limit || limit >= memblock_end_of_DRAM())
 		return;
 
 	/* find out max address */
 	for (i = 0; i < memblock.memory.cnt; i++) {
 		struct memblock_region *r = &memblock.memory.regions[i];
 
-		if (limit <= r->size) {
+		if (limit < r->size) {
 			max_addr = r->base + limit;
 			break;
 		}
@@ -859,8 +859,12 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
 	}
 
 	/* truncate both memory and reserved regions */
-	__memblock_remove(&memblock.memory, max_addr, (phys_addr_t)ULLONG_MAX);
-	__memblock_remove(&memblock.reserved, max_addr, (phys_addr_t)ULLONG_MAX);
+	if (max_addr < (phys_addr_t)ULLONG_MAX) {
+		__memblock_remove(&memblock.memory, max_addr,
+						(phys_addr_t)ULLONG_MAX);
+		__memblock_remove(&memblock.reserved, max_addr,
+						(phys_addr_t)ULLONG_MAX);
+	}
 }
 
 static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
