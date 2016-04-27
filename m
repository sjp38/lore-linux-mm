Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3ACB36B025E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:24:51 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r12so37272655wme.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:24:51 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id hc5si4104196wjb.226.2016.04.27.05.24.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 05:24:46 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 65F4F98970
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 12:24:46 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/4] mm, page_alloc: Only check PageCompound for high-order pages -fix
Date: Wed, 27 Apr 2016 13:24:42 +0100
Message-Id: <1461759885-17163-2-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1461759885-17163-1-git-send-email-mgorman@techsingularity.net>
References: <1461759885-17163-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Vlastimil Babka pointed out that an unlikely annotation in free_pages_prepare
shrinks stack usage by moving compound handling to the end of the function.

add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-30 (-30)
function                                     old     new   delta
free_pages_prepare                           771     741     -30

It's also consistent with the buffered_rmqueue path.

This is a fix to the mmotm patch
mm-page_alloc-only-check-pagecompound-for-high-order-pages.patch.

Suggested-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1da56779f8fa..d8383750bd43 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1003,7 +1003,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 	 * Check tail pages before head page information is cleared to
 	 * avoid checking PageCompound for order-0 pages.
 	 */
-	if (order) {
+	if (unlikely(order)) {
 		bool compound = PageCompound(page);
 		int i;
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
