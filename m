Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2656B02B4
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 18:36:29 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k71so30626995pgd.6
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 15:36:29 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 88sor1792250ple.5.2017.06.09.15.36.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Jun 2017 15:36:28 -0700 (PDT)
Date: Fri, 9 Jun 2017 15:36:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2 -mm] mm, hugetlb: schedule when potentially allocating
 many hugepages
In-Reply-To: <alpine.DEB.2.10.1706091534580.66176@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1706091535300.66176@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1706072102560.29060@chino.kir.corp.google.com> <52ee0233-c3cd-d33a-a33b-50d49e050d5c@oracle.com> <alpine.DEB.2.10.1706091534580.66176@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

A few hugetlb allocators loop while calling the page allocator and can
potentially prevent rescheduling if the page allocator slowpath is not
utilized.

Conditionally schedule when large numbers of hugepages can be allocated.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Based on -mm only to prevent merge conflicts with
 "mm/hugetlb.c: warn the user when issues arise on boot due to hugepages"

 v2: removed redundant cond_resched() per Mike

 mm/hugetlb.c | 2 ++
 1 file changed, 2 insertions(+)

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
