Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 144616B007E
	for <linux-mm@kvack.org>; Sat, 18 Jun 2016 05:35:13 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id f10so12544219obr.3
        for <linux-mm@kvack.org>; Sat, 18 Jun 2016 02:35:13 -0700 (PDT)
Received: from m12-15.163.com (m12-15.163.com. [220.181.12.15])
        by mx.google.com with ESMTP id i71si1410348ita.35.2016.06.18.02.35.11
        for <linux-mm@kvack.org>;
        Sat, 18 Jun 2016 02:35:12 -0700 (PDT)
From: Wenwei Tao <wwtao0320@163.com>
Subject: [RFC PATCH 1/3] mm, page_alloc: free HIGHATOMIC page directly to the allocator
Date: Sat, 18 Jun 2016 17:34:15 +0800
Message-Id: <1466242457-2440-1-git-send-email-wwtao0320@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, vbabka@suse.cz, rientjes@google.com, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ww.tao0320@gmail.com

From: Wenwei Tao <ww.tao0320@gmail.com>

Some pages might have already been allocated before reserve
the pageblock as HIGHATOMIC. When free these pages, put them
directly to the allocator instead of the pcp lists since they
might have the chance to be merged to high order pages.

Signed-off-by: Wenwei Tao <ww.tao0320@gmail.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6903b69..19f9e76 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2412,7 +2412,8 @@ void free_hot_cold_page(struct page *page, bool cold)
 	 * excessively into the page allocator
 	 */
 	if (migratetype >= MIGRATE_PCPTYPES) {
-		if (unlikely(is_migrate_isolate(migratetype))) {
+		if (unlikely(is_migrate_isolate(migratetype) ||
+				migratetype == MIGRATE_HIGHATOMIC)) {
 			free_one_page(zone, page, pfn, 0, migratetype);
 			goto out;
 		}
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
