Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3A16B0009
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 11:07:57 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z3-v6so3344042pln.23
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 08:07:57 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id o129si3895239pfo.209.2018.03.15.08.07.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 08:07:56 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm/thp: Do not wait for lock_page() in deferred_split_scan()
Date: Thu, 15 Mar 2018 18:07:47 +0300
Message-Id: <20180315150747.31945-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

deferred_split_scan() gets called from reclaim path. Waiting for page
lock may lead to deadlock there.

Replace lock_page() with trylock_page() and skip the page if we failed
to lock it. We will get to the page on the next scan.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 87ab9b8f56b5..529cf36b7edb 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2783,11 +2783,13 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 
 	list_for_each_safe(pos, next, &list) {
 		page = list_entry((void *)pos, struct page, mapping);
-		lock_page(page);
+		if (!trylock_page(page))
+			goto next;
 		/* split_huge_page() removes page from list on success */
 		if (!split_huge_page(page))
 			split++;
 		unlock_page(page);
+next:
 		put_page(page);
 	}
 
-- 
2.16.1
