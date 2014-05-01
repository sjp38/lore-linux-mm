Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id E64AC6B006E
	for <linux-mm@kvack.org>; Thu,  1 May 2014 04:45:06 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so915506eek.21
        for <linux-mm@kvack.org>; Thu, 01 May 2014 01:45:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x44si33475689eep.300.2014.05.01.01.45.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 01:45:05 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 15/17] mm: Do not use unnecessary atomic operations when adding pages to the LRU
Date: Thu,  1 May 2014 09:44:46 +0100
Message-Id: <1398933888-4940-16-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-1-git-send-email-mgorman@suse.de>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>

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
index da8a250..395dcab 100644
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
