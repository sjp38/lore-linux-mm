Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0F1CD6B005C
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:50:51 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so1698085eei.33
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 07:50:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q5si40538969eem.291.2014.04.18.07.50.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 07:50:50 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 14/16] mm: Do not use unnecessary atomic operations when adding pages to the LRU
Date: Fri, 18 Apr 2014 15:50:41 +0100
Message-Id: <1397832643-14275-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1397832643-14275-1-git-send-email-mgorman@suse.de>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>

When adding pages to the LRU we clear the active bit unconditionally. As the
page could be reachable from other paths we cannot use unlocked operations
without risk of corruption such as a parallel mark_page_accessed. This
patch test if is necessary to clear the atomic flag before using an atomic
operation. In the unlikely even this races with mark_page_accesssed the
consequences are simply that the page may be promoted to the active list
that might have been left on the inactive list before the patch. This is
a marginal consequence.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/swap.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 3507115..4a9ac85 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -329,13 +329,15 @@ extern void add_page_to_unevictable_list(struct page *page);
  */
 static inline void lru_cache_add_anon(struct page *page)
 {
-	ClearPageActive(page);
+	if (PageActive(page))
+		ClearPageActive(page);
 	__lru_cache_add(page);
 }
 
 static inline void lru_cache_add_file(struct page *page)
 {
-	ClearPageActive(page);
+	if (PageActive(page))
+		ClearPageActive(page);
 	__lru_cache_add(page);
 }
 
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
