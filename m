Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id A9C326B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:01:31 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 68so34569347lfq.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:01:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i143si8706002wmd.97.2016.04.27.05.01.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 05:01:25 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/3] mm, page_alloc: un-inline the bad part of free_pages_check
Date: Wed, 27 Apr 2016 14:01:14 +0200
Message-Id: <1461758476-450-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <5720A987.7060507@suse.cz>
References: <5720A987.7060507@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

!DEBUG_VM bloat-o-meter:

add/remove: 1/0 grow/shrink: 0/2 up/down: 124/-383 (-259)
function                                     old     new   delta
free_pages_check_bad                           -     124    +124
free_pcppages_bulk                          1509    1403    -106
__free_pages_ok                             1025     748    -277

DEBUG_VM:

add/remove: 1/0 grow/shrink: 0/1 up/down: 124/-242 (-118)
function                                     old     new   delta
free_pages_check_bad                           -     124    +124
free_pages_prepare                          1048     806    -242

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fe78c4dbfa8d..12c03a8509a0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -906,18 +906,11 @@ static inline bool page_expected_state(struct page *page,
 	return true;
 }
 
-static inline int free_pages_check(struct page *page)
+static void free_pages_check_bad(struct page *page)
 {
 	const char *bad_reason;
 	unsigned long bad_flags;
 
-	if (page_expected_state(page, PAGE_FLAGS_CHECK_AT_FREE)) {
-		page_cpupid_reset_last(page);
-		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
-		return 0;
-	}
-
-	/* Something has gone sideways, find it */
 	bad_reason = NULL;
 	bad_flags = 0;
 
@@ -936,6 +929,17 @@ static inline int free_pages_check(struct page *page)
 		bad_reason = "page still charged to cgroup";
 #endif
 	bad_page(page, bad_reason, bad_flags);
+}
+static inline int free_pages_check(struct page *page)
+{
+	if (likely(page_expected_state(page, PAGE_FLAGS_CHECK_AT_FREE))) {
+		page_cpupid_reset_last(page);
+		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
+		return 0;
+	}
+
+	/* Something has gone sideways, find it */
+	free_pages_check_bad(page);
 	return 1;
 }
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
