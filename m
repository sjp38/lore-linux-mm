Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7FM1V2C031215
	for <linux-mm@kvack.org>; Fri, 15 Aug 2008 18:01:31 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7FM1UUs171116
	for <linux-mm@kvack.org>; Fri, 15 Aug 2008 16:01:31 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7FM1TaY002466
	for <linux-mm@kvack.org>; Fri, 15 Aug 2008 16:01:30 -0600
Subject: [BUG] __GFP_THISNODE is not always honored
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Fri, 15 Aug 2008 17:01:25 -0500
Message-Id: <1218837685.12953.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, nacc <nacc@linux.vnet.ibm.com>, mel@csn.ul.ie, apw <apw@shadowen.org>, agl <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

While running the libhugetlbfs test suite on a NUMA machine with 2.6.27-rc3, I
discovered some strange behavior with __GFP_THISNODE.  The hugetlb function
alloc_fresh_huge_page_node() calls alloc_pages_node() with __GFP_THISNODE but
occasionally a page that is not on the requested node is returned.  Since the
hugetlb code assumes that the page will be on the requested node, badness follows
when the page is added to the wrong node's free_list.

There is clearly something wrong with the buddy allocator since __GFP_THISNODE
cannot be trusted.  Until that is fixed, the hugetlb code should not assume
that the newly allocated page is on the node asked for.  This patch prevents
the hugetlb pool counters from being corrupted and allows the code to cope with
unbalanced numa allocations.

So far my debugging has led me to get_page_from_freelist() inside the
for_each_zone_zonelist() loop.  When buffered_rmqueue() returns a page I
compare the value of page_to_nid(page), zone->node and the node that the
hugetlb code requested with __GFP_THISNODE.  These all match -- except when the
problem triggers.  In that case, zone->node matches the node we asked for but
page_to_nid() does not.

Workaround patch:
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 67a7119..7a30a61 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -568,7 +568,7 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 			__free_pages(page, huge_page_order(h));
 			return NULL;
 		}
-		prep_new_huge_page(h, page, nid);
+		prep_new_huge_page(h, page, page_to_nid(page));
 	}
 
 	return page;

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
