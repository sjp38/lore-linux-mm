Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 588806B003A
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 16:54:54 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id y20so3965062ier.30
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 13:54:54 -0700 (PDT)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id i5si2484179igi.56.2014.09.11.13.54.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 13:54:53 -0700 (PDT)
Received: by mail-ie0-f169.google.com with SMTP id rl12so8951014iec.0
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 13:54:53 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 03/10] zsmalloc: always update lru ordering of each zspage
Date: Thu, 11 Sep 2014 16:53:54 -0400
Message-Id: <1410468841-320-4-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
References: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>

Update ordering of a changed zspage in its fullness group LRU list,
even if it has not moved to a different fullness group.

This is needed by zsmalloc shrinking, which partially relies on each
class fullness group list to be kept in LRU order, so the oldest can
be reclaimed first.  Currently, LRU ordering is only updated when
a zspage changes fullness groups.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index fedb70f..51db622 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -467,16 +467,14 @@ static enum fullness_group fix_fullness_group(struct zs_pool *pool,
 	BUG_ON(!is_first_page(page));
 
 	get_zspage_mapping(page, &class_idx, &currfg);
-	newfg = get_fullness_group(page);
-	if (newfg == currfg)
-		goto out;
-
 	class = &pool->size_class[class_idx];
+	newfg = get_fullness_group(page);
+	/* Need to do this even if currfg == newfg, to update lru */
 	remove_zspage(page, class, currfg);
 	insert_zspage(page, class, newfg);
-	set_zspage_mapping(page, class_idx, newfg);
+	if (currfg != newfg)
+		set_zspage_mapping(page, class_idx, newfg);
 
-out:
 	return newfg;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
