Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2QLcQX5025733
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 17:38:26 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2QLdvWu193936
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 15:39:57 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2QLduw2019568
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 15:39:57 -0600
Date: Wed, 26 Mar 2008 14:40:20 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH 2/2] hugetlb: fix potential livelock in
	return_unused_surplus_hugepages()
Message-ID: <20080326214020.GF14331@us.ibm.com>
References: <20080326213753.GE14331@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080326213753.GE14331@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org, agl@us.ibm.com, apw@shadowen.org, mel@csn.ul.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Running the counters testcase from libhugetlbfs results in on 2.6.25-rc5
and 2.6.25-rc5-mm1:

    BUG: soft lockup - CPU#3 stuck for 61s! [counters:10531]
    NIP: c0000000000d1f3c LR: c0000000000d1f2c CTR: c0000000001b5088
    REGS: c000005db12cb360 TRAP: 0901   Not tainted  (2.6.25-rc5-autokern1)
    MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 48008448  XER: 20000000
    TASK = c000005dbf3d6000[10531] 'counters' THREAD: c000005db12c8000 CPU: 3
    GPR00: 0000000000000004 c000005db12cb5e0 c000000000879228 0000000000000004
    GPR04: 0000000000000010 0000000000000000 0000000000200200 0000000000100100
    GPR08: c0000000008aba10 000000000000ffff 0000000000000004 0000000000000000
    GPR12: 0000000028000442 c000000000770080
    NIP [c0000000000d1f3c] .return_unused_surplus_pages+0x84/0x18c
    LR [c0000000000d1f2c] .return_unused_surplus_pages+0x74/0x18c
    Call Trace:
    [c000005db12cb5e0] [c000005db12cb670] 0xc000005db12cb670 (unreliable)
    [c000005db12cb670] [c0000000000d24c4] .hugetlb_acct_memory+0x2e0/0x354
    [c000005db12cb740] [c0000000001b5048] .truncate_hugepages+0x1d4/0x214
    [c000005db12cb890] [c0000000001b50a4] .hugetlbfs_delete_inode+0x1c/0x3c
    [c000005db12cb920] [c000000000103fd8] .generic_delete_inode+0xf8/0x1c0
    [c000005db12cb9b0] [c0000000001b5100] .hugetlbfs_drop_inode+0x3c/0x24c
    [c000005db12cba50] [c00000000010287c] .iput+0xdc/0xf8
    [c000005db12cbad0] [c0000000000fee54] .dentry_iput+0x12c/0x194
    [c000005db12cbb60] [c0000000000ff050] .d_kill+0x6c/0xa4
    [c000005db12cbbf0] [c0000000000ffb74] .dput+0x18c/0x1b0
    [c000005db12cbc70] [c0000000000e9e98] .__fput+0x1a4/0x1e8
    [c000005db12cbd10] [c0000000000e61ec] .filp_close+0xb8/0xe0
    [c000005db12cbda0] [c0000000000e62d0] .sys_close+0xbc/0x134
    [c000005db12cbe30] [c00000000000872c] syscall_exit+0x0/0x40
    Instruction dump:
    ebbe8038 38800010 e8bf0002 3bbd0008 7fa3eb78 38a50001 7ca507b4 4818df25
    60000000 38800010 38a00000 7c601b78 <7fa3eb78> 2f800010 409d0008 38000010

This was tracked down to a potential livelock in
return_unused_surplus_hugepages().  In the case where we have surplus
pages on some node, but no free pages on the same node, we may never
break out of the loop. To avoid this livelock, terminate the search if
we iterate a number of times equal to the number of online nodes without
freeing a page.

Thanks to Andy Whitcroft and Adam Litke for helping with debugging and
the patch.
 
Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---
This is a bugfix for 2.6.25.

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 548a75d..0c3212f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -436,12 +436,20 @@ static void return_unused_surplus_pages(unsigned long unused_resv_pages)
 	struct page *page;
 	unsigned long nr_pages;
 
+	/*
+	 * We want to release as many surplus pages as possible, spread
+	 * evenly across all nodes. Iterate across all nodes until we
+	 * can no longer free unreserved surplus pages. This occurs when
+	 * the nodes with surplus pages have no free pages.
+	 */
+	unsigned long remaining_iterations = num_online_nodes();
+
 	/* Uncommit the reservation */
 	resv_huge_pages -= unused_resv_pages;
 
 	nr_pages = min(unused_resv_pages, surplus_huge_pages);
 
-	while (nr_pages) {
+	while (remaining_iterations-- && nr_pages) {
 		nid = next_node(nid, node_online_map);
 		if (nid == MAX_NUMNODES)
 			nid = first_node(node_online_map);
@@ -459,6 +467,7 @@ static void return_unused_surplus_pages(unsigned long unused_resv_pages)
 			surplus_huge_pages--;
 			surplus_huge_pages_node[nid]--;
 			nr_pages--;
+			remaining_iterations = num_online_nodes();
 		}
 	}
 }

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
