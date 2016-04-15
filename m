Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1FBD46B007E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:08:18 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l6so13203076wml.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:08:18 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id wl1si49448425wjc.217.2016.04.15.02.08.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 02:08:17 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id A45BCF42DB
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:08:16 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 14/28] mm, page_alloc: Simplify last cpupid reset
Date: Fri, 15 Apr 2016 10:07:41 +0100
Message-Id: <1460711275-1130-2-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The current reset unnecessarily clears flags and makes pointless calculations.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mm.h | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ffcff53e3b2b..60656db00abd 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -837,10 +837,7 @@ extern int page_cpupid_xchg_last(struct page *page, int cpupid);
 
 static inline void page_cpupid_reset_last(struct page *page)
 {
-	int cpupid = (1 << LAST_CPUPID_SHIFT) - 1;
-
-	page->flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
-	page->flags |= (cpupid & LAST_CPUPID_MASK) << LAST_CPUPID_PGSHIFT;
+	page->flags |= LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT;
 }
 #endif /* LAST_CPUPID_NOT_IN_PAGE_FLAGS */
 #else /* !CONFIG_NUMA_BALANCING */
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
