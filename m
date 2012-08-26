Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 32CA16B006C
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 05:00:50 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 26 Aug 2012 14:30:46 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7Q90jxg53411842
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 14:30:45 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7Q90iN7012105
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 19:00:45 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 1/4] mm/memblock: reduce overhead in binary search
Date: Sun, 26 Aug 2012 17:00:23 +0800
Message-Id: <1345971626-17090-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

"v1 -> v2": 
* move check from memblock_search to memblock_is_memory
* modify changelog

When checking the indicated address belongs to the memory region, the 
memory regions are checked one by one through binary search, which would 
be a little time consuming. If the indicated address isn't in memory 
region, then we needn't do the time-sonsuming search. The patch adds
more check on the indicated address for that purpose.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memblock.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 4d9393c..258e81d 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -888,6 +888,11 @@ int __init memblock_is_reserved(phys_addr_t addr)
 
 int __init_memblock memblock_is_memory(phys_addr_t addr)
 {
+
+	if (unlikely(addr < memblock_start_of_DRAM() ||
+		addr >= memblock_end_of_DRAM()))
+		return 0;
+
 	return memblock_search(&memblock.memory, addr) != -1;
 }
 
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
