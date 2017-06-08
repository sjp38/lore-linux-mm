Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 157826B02B4
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 00:03:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h76so10855522pfh.15
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 21:03:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 88sor2904523ple.5.2017.06.07.21.03.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Jun 2017 21:03:39 -0700 (PDT)
Date: Wed, 7 Jun 2017 21:03:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, hugetlb: schedule when potentially allocating many
 hugepages
Message-ID: <alpine.DEB.2.10.1706072102560.29060@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

A few hugetlb allocators loop while calling the page allocator and can
potentially prevent rescheduling if the page allocator slowpath is not
utilized.

Conditionally schedule when large numbers of hugepages can be allocated.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Based on -mm only to prevent merge conflicts with
 "mm/hugetlb.c: warn the user when issues arise on boot due to hugepages"

 mm/hugetlb.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1754,6 +1754,7 @@ static int gather_surplus_pages(struct hstate *h, int delta)
 			break;
 		}
 		list_add(&page->lru, &surplus_list);
+		cond_resched();
 	}
 	allocated += i;
 
@@ -2222,6 +2223,7 @@ static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
 		} else if (!alloc_fresh_huge_page(h,
 					 &node_states[N_MEMORY]))
 			break;
+		cond_resched();
 	}
 	if (i < h->max_huge_pages) {
 		char buf[32];
@@ -2364,6 +2366,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 			ret = alloc_fresh_gigantic_page(h, nodes_allowed);
 		else
 			ret = alloc_fresh_huge_page(h, nodes_allowed);
+		cond_resched();
 		spin_lock(&hugetlb_lock);
 		if (!ret)
 			goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
