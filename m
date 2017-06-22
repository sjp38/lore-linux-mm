Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02D7283292
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 15:30:48 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id f49so7184697wrf.5
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 12:30:47 -0700 (PDT)
Received: from mail-wr0-f193.google.com (mail-wr0-f193.google.com. [209.85.128.193])
        by mx.google.com with ESMTPS id e74si2036335wmi.174.2017.06.22.12.30.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 12:30:46 -0700 (PDT)
Received: by mail-wr0-f193.google.com with SMTP id k67so7002765wrc.1
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 12:30:46 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/3] mm, hugetlb, soft_offline: use new_page_nodemask for soft offline migration
Date: Thu, 22 Jun 2017 21:30:34 +0200
Message-Id: <20170622193034.28972-4-mhocko@kernel.org>
In-Reply-To: <20170622193034.28972-1-mhocko@kernel.org>
References: <20170622193034.28972-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

new_page is yet another duplication of the migration callback which has
to handle hugetlb migration specially. We can safely use the generic
new_page_nodemask for the same purpose.

Please note that gigantic hugetlb pages do not need any special handling
because alloc_huge_page_nodemask will make sure to check pages in all
per node pools. The reason this was done previously was that
alloc_huge_page_node treated NO_NUMA_NODE and a specific node
differently and so alloc_huge_page_node(nid) would check on this
specific node.

Noticed-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory-failure.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 3615bffbd269..7040f60ecb71 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1487,16 +1487,8 @@ EXPORT_SYMBOL(unpoison_memory);
 static struct page *new_page(struct page *p, unsigned long private, int **x)
 {
 	int nid = page_to_nid(p);
-	if (PageHuge(p)) {
-		struct hstate *hstate = page_hstate(compound_head(p));
 
-		if (hstate_is_gigantic(hstate))
-			return alloc_huge_page_node(hstate, NUMA_NO_NODE);
-
-		return alloc_huge_page_node(hstate, nid);
-	} else {
-		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
-	}
+	return new_page_nodemask(p, nid, &node_states[N_MEMORY]);
 }
 
 /*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
