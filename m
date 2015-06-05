Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id E8FE1900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 08:04:56 -0400 (EDT)
Received: by padj3 with SMTP id j3so49622266pad.0
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 05:04:56 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id av1si10599158pbd.182.2015.06.05.05.04.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jun 2015 05:04:56 -0700 (PDT)
Received: by padj3 with SMTP id j3so49622059pad.0
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 05:04:56 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCHv2 3/8] zsmalloc: lower ZS_ALMOST_FULL waterline
Date: Fri,  5 Jun 2015 21:03:53 +0900
Message-Id: <1433505838-23058-4-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

get_fullness_group() considers 3/4 full pages as almost empty.
That, unfortunately, marks as ALMOST_EMPTY pages that we would
probably like to keep in ALMOST_FULL lists.

ALMOST_EMPTY:
[..]
  inuse: 3 max_objects: 4
  inuse: 5 max_objects: 7
  inuse: 5 max_objects: 7
  inuse: 2 max_objects: 3
[..]

For "inuse: 5 max_objexts: 7" ALMOST_EMPTY page, for example,
it'll take 2 obj_malloc to make the page FULL and 5 obj_free to
make it EMPTY. Compaction selects ALMOST_EMPTY pages as source
pages, which can result in extra object moves.

In other words, from compaction point of view, it makes more
sense to fill this page, rather than drain it.

Decrease ALMOST_FULL waterline to 2/3 of max capacity; which is,
of course, still imperfect, but can shorten compaction
execution time.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index cd37bda..b94e281 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -198,7 +198,7 @@ static int zs_size_classes;
  *
  * (see: fix_fullness_group())
  */
-static const int fullness_threshold_frac = 4;
+static const int fullness_threshold_frac = 3;
 
 struct size_class {
 	/*
@@ -633,7 +633,7 @@ static enum fullness_group get_fullness_group(struct page *page)
 		fg = ZS_EMPTY;
 	else if (inuse == max_objects)
 		fg = ZS_FULL;
-	else if (inuse <= 3 * max_objects / fullness_threshold_frac)
+	else if (inuse <= 2 * max_objects / fullness_threshold_frac)
 		fg = ZS_ALMOST_EMPTY;
 	else
 		fg = ZS_ALMOST_FULL;
-- 
2.4.2.387.gf86f31a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
