Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A72A6B0260
	for <linux-mm@kvack.org>; Tue, 10 May 2016 03:37:22 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id y84so3936616lfc.3
        for <linux-mm@kvack.org>; Tue, 10 May 2016 00:37:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q19si1560351wmb.32.2016.05.10.00.37.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 00:37:08 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 03/13] mm, page_alloc: don't retry initial attempt in slowpath
Date: Tue, 10 May 2016 09:35:53 +0200
Message-Id: <1462865763-22084-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

After __alloc_pages_slowpath() sets up new alloc_flags and wakes up kswapd, it
first tries get_page_from_freelist() with the new alloc_flags, as it may
succeed e.g. due to using min watermark instead of low watermark. This attempt
does not have to be retried on each loop, since direct reclaim, direct
compaction and oom call get_page_from_freelist() themselves.

This patch therefore moves the initial attempt above the retry label. The
ALLOC_NO_WATERMARKS attempt is kept under retry label as it's special and
should be retried after each loop. Kswapd wakeups are also done on each retry
to be safe from potential races resulting in kswapd going to sleep while a
process (that may not be able to reclaim by itself) is still looping.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 91fbf6f95403..7249949d65ca 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3586,16 +3586,23 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 */
 	alloc_flags = gfp_to_alloc_flags(gfp_mask);
 
-retry:
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
 		wake_all_kswapds(order, ac);
 
-	/* This is the last chance, in general, before the goto nopage. */
+	/*
+	 * The adjusted alloc_flags might result in immediate success, so try
+	 * that first
+	 */
 	page = get_page_from_freelist(gfp_mask, order,
 				alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
 	if (page)
 		goto got_pg;
 
+retry:
+	/* Ensure kswapd doesn't accidentaly go to sleep as long as we loop */
+	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
+		wake_all_kswapds(order, ac);
+
 	/* Allocate without watermarks if the context allows */
 	if (alloc_flags & ALLOC_NO_WATERMARKS) {
 		/*
-- 
2.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
