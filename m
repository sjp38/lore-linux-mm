Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2582E6B0098
	for <linux-mm@kvack.org>; Fri, 29 May 2015 11:06:50 -0400 (EDT)
Received: by pacux9 with SMTP id ux9so20957822pac.3
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:49 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id t9si133491pas.59.2015.05.29.08.06.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 08:06:49 -0700 (PDT)
Received: by pacrp13 with SMTP id rp13so16103629pac.2
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:49 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH 10/10] zsmalloc: lower ZS_ALMOST_FULL waterline
Date: Sat, 30 May 2015 00:05:28 +0900
Message-Id: <1432911928-14654-11-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

get_fullness_group() considers 3/4 full pages as almost empty.
that, unfortunately, marks as ALMOST_EMPTY pages that we would
probably like to keep in ALMOST_FULL list.

ALMOST_EMPTY:
[..]
  inuse: 3 max_objexts: 4
  inuse: 5 max_objexts: 7
  inuse: 5 max_objexts: 7
  inuse: 2 max_objexts: 3
[..]

so, for "inuse: 5 max_objexts: 7" ALMOST_EMPTY page, for example,
it'll take 2 obj_malloc to make the page FULL and 5 obj_free to
make it EMPTY. compaction selects ALMOST_EMPTY pages as source
pages, which can result in extra object moves.

iow, in terms of compaction, it makes more sense to fill this
page, rather than drain it.

decrease ALMOST_FULL waterline to 2/3 of max capacity; which is,
of course, still imperfect.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 0524c4a..a8a3eae 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -196,7 +196,7 @@ static int zs_size_classes;
  *
  * (see: fix_fullness_group())
  */
-static const int fullness_threshold_frac = 4;
+static const int fullness_threshold_frac = 3;
 
 struct size_class {
 	spinlock_t		lock;
@@ -612,7 +612,7 @@ static enum fullness_group get_fullness_group(struct page *page)
 		fg = ZS_EMPTY;
 	else if (inuse == max_objects)
 		fg = ZS_FULL;
-	else if (inuse <= 3 * max_objects / fullness_threshold_frac)
+	else if (inuse <= 2 * max_objects / fullness_threshold_frac)
 		fg = ZS_ALMOST_EMPTY;
 	else
 		fg = ZS_ALMOST_FULL;
-- 
2.4.2.337.gfae46aa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
