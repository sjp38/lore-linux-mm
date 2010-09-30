Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0FAB96B007B
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 23:50:36 -0400 (EDT)
Received: by mail-iw0-f169.google.com with SMTP id 33so2614800iwn.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 20:50:35 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 02/12] mm: add casts to/from gfp_t in gfp_to_alloc_flags()
Date: Thu, 30 Sep 2010 12:50:11 +0900
Message-Id: <1285818621-29890-3-git-send-email-namhyung@gmail.com>
In-Reply-To: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
References: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This removes following warning from sparse:

 mm/page_alloc.c:1934:9: warning: restricted gfp_t degrades to integer

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/page_alloc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a8cfa9c..7c4e5b1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1931,7 +1931,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 
 	/* __GFP_HIGH is assumed to be the same as ALLOC_HIGH to save a branch. */
-	BUILD_BUG_ON(__GFP_HIGH != ALLOC_HIGH);
+	BUILD_BUG_ON(__GFP_HIGH != (__force gfp_t) ALLOC_HIGH);
 
 	/*
 	 * The caller may dip into page reserves a bit more if the caller
@@ -1939,7 +1939,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
 	 * set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH).
 	 */
-	alloc_flags |= (gfp_mask & __GFP_HIGH);
+	alloc_flags |= (__force int) (gfp_mask & __GFP_HIGH);
 
 	if (!wait) {
 		alloc_flags |= ALLOC_HARDER;
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
