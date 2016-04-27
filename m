Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6ADC96B0253
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:57:26 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k200so43813538lfg.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 07:57:26 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id f142si31174068wmf.54.2016.04.27.07.57.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 07:57:24 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 987F21C149D
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 15:57:24 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 4/6] mm, page_alloc: un-inline the bad part of free_pages_check
Date: Wed, 27 Apr 2016 15:57:21 +0100
Message-Id: <1461769043-28337-5-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1461769043-28337-1-git-send-email-mgorman@techsingularity.net>
References: <1461769043-28337-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

From: Vlastimil Babka <vbabka@suse.cz>

!DEBUG_VM size and bloat-o-meter:

add/remove: 1/0 grow/shrink: 0/2 up/down: 124/-370 (-246)
function                                     old     new   delta
free_pages_check_bad                           -     124    +124
free_pcppages_bulk                          1288    1171    -117
__free_pages_ok                              948     695    -253

DEBUG_VM:

add/remove: 1/0 grow/shrink: 0/1 up/down: 124/-214 (-90)
function                                     old     new   delta
free_pages_check_bad                           -     124    +124
free_pages_prepare                          1112     898    -214

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c63e5e7e4864..97894cbe2fa3 100644
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
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
