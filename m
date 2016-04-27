Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B4066B025E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:57:29 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r12so42228814wme.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 07:57:29 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id it2si4863518wjb.129.2016.04.27.07.57.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 07:57:25 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id BF8EC1C158D
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 15:57:24 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 5/6] mm, page_alloc: pull out side effects from free_pages_check
Date: Wed, 27 Apr 2016 15:57:22 +0100
Message-Id: <1461769043-28337-6-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1461769043-28337-1-git-send-email-mgorman@techsingularity.net>
References: <1461769043-28337-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Check without side-effects should be easier to maintain. It also removes the
duplicated cpupid and flags reset done in !DEBUG_VM variant of both
free_pcp_prepare() and then bulkfree_pcp_prepare(). Finally, it enables
the next patch.

It shouldn't result in new branches, thanks to inlining of the check.

!DEBUG_VM bloat-o-meter:

add/remove: 0/0 grow/shrink: 0/2 up/down: 0/-27 (-27)
function                                     old     new   delta
__free_pages_ok                              748     739      -9
free_pcppages_bulk                          1403    1385     -18

DEBUG_VM:

add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-28 (-28)
function                                     old     new   delta
free_pages_prepare                           806     778     -28

This is also slightly faster because cpupid information is not set on tail
pages so we can avoid resets there.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 97894cbe2fa3..b823f00c275b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -932,11 +932,8 @@ static void free_pages_check_bad(struct page *page)
 }
 static inline int free_pages_check(struct page *page)
 {
-	if (likely(page_expected_state(page, PAGE_FLAGS_CHECK_AT_FREE))) {
-		page_cpupid_reset_last(page);
-		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
+	if (likely(page_expected_state(page, PAGE_FLAGS_CHECK_AT_FREE)))
 		return 0;
-	}
 
 	/* Something has gone sideways, find it */
 	free_pages_check_bad(page);
@@ -1016,7 +1013,11 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 		for (i = 1; i < (1 << order); i++) {
 			if (compound)
 				bad += free_tail_pages_check(page, page + i);
-			bad += free_pages_check(page + i);
+			if (unlikely(free_pages_check(page + i))) {
+				bad++;
+				continue;
+			}
+			(page + i)->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 		}
 	}
 	if (PageAnonHead(page))
@@ -1025,6 +1026,8 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 	if (bad)
 		return false;
 
+	page_cpupid_reset_last(page);
+	page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	reset_page_owner(page, order);
 
 	if (!PageHighMem(page)) {
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
