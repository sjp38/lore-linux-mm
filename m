Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 5446C6B002B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 10:34:54 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 24 Aug 2012 20:04:50 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7OEYlIw6029758
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 20:04:47 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7OEYkSn004833
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 00:34:47 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 3/5] mm/memblock: reduce overhead in binary search
Date: Fri, 24 Aug 2012 22:33:38 +0800
Message-Id: <1345818820-12102-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1345818820-12102-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1345818820-12102-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

From: Wanpeng Li <liwanp@linux.vnet.ibm.com>

When checking the indicated address belongs to the memory
or reserved region, the memory or reserved regions are checked
one by one through binary search, which would be a little
time consuming. If the indicated address isn't in memory
region, then we needn't do the time-sonsuming search. The
patch adds more check on the indicated address for that purpose.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memblock.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 2feff8d..880e461 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -871,6 +871,10 @@ static int __init_memblock memblock_search(struct memblock_type *type, phys_addr
 {
 	unsigned int left = 0, right = type->cnt;
 
+	if (unlikely(addr < memblock_start_of_DRAM() ||
+		addr >= memblock_end_of_DRAM()))
+			return 0;
+
 	do {
 		unsigned int mid = (right + left) / 2;
 
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
