Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 64A616B0253
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 02:49:18 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id t56so141269588qte.3
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 23:49:18 -0800 (PST)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id o37si12610407qtf.38.2017.01.23.23.49.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 23:49:17 -0800 (PST)
Received: by mail-qt0-x244.google.com with SMTP id f4so23189655qte.2
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 23:49:17 -0800 (PST)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH RFC 1/3] mm/hugetlb: split alloc_fresh_huge_page_node into fast and slow path
Date: Tue, 24 Jan 2017 15:49:02 +0800
Message-Id: <1485244144-13487-2-git-send-email-hejianet@gmail.com>
In-Reply-To: <1485244144-13487-1-git-send-email-hejianet@gmail.com>
References: <1485244144-13487-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, zhong jiang <zhongjiang@huawei.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vaishali Thakkar <vaishali.thakkar@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Jia He <hejianet@gmail.com>

This patch split alloc_fresh_huge_page_node into 2 parts:
- fast path without __GFP_REPEAT flag
- slow path with __GFP_REPEAT flag

Thus, if there is a server with uneven numa memory layout:
available: 7 nodes (0-6)
node 0 cpus: 0 1 2 3 4 5 6 7
node 0 size: 6603 MB
node 0 free: 91 MB
node 1 cpus:
node 1 size: 12527 MB
node 1 free: 157 MB
node 2 cpus:
node 2 size: 15087 MB
node 2 free: 189 MB
node 3 cpus:
node 3 size: 16111 MB
node 3 free: 205 MB
node 4 cpus: 8 9 10 11 12 13 14 15
node 4 size: 24815 MB
node 4 free: 310 MB
node 5 cpus:
node 5 size: 4095 MB
node 5 free: 61 MB
node 6 cpus:
node 6 size: 22750 MB
node 6 free: 283 MB
node distances:
node   0   1   2   3   4   5   6
  0:  10  20  40  40  40  40  40
  1:  20  10  40  40  40  40  40
  2:  40  40  10  20  40  40  40
  3:  40  40  20  10  40  40  40
  4:  40  40  40  40  10  20  40
  5:  40  40  40  40  20  10  40
  6:  40  40  40  40  40  40  10

In this case node 5 has less memory and we will alloc the hugepages
from these nodes one by one.
After this patch, we will not trigger too early direct memory/kswap
reclaim for node 5 if there are enough memory in other nodes.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 mm/hugetlb.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c7025c1..f2415ce 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1364,10 +1364,19 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 {
 	struct page *page;
 
+	/* fast path without __GFP_REPEAT */
 	page = __alloc_pages_node(nid,
 		htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
 						__GFP_REPEAT|__GFP_NOWARN,
 		huge_page_order(h));
+
+	/* slow path with __GFP_REPEAT*/
+	if (!page)
+		page = __alloc_pages_node(nid,
+			htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
+					__GFP_NOWARN,
+			huge_page_order(h));
+
 	if (page) {
 		prep_new_huge_page(h, page, nid);
 	}
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
