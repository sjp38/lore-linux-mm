Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 56C136B006E
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 00:00:46 -0500 (EST)
Received: by padfa1 with SMTP id fa1so24102874pad.3
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 21:00:46 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id lh9si3445275pbc.175.2015.03.03.21.00.41
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 21:00:43 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 4/7] zsmalloc: adjust ZS_ALMOST_FULL
Date: Wed,  4 Mar 2015 14:01:29 +0900
Message-Id: <1425445292-29061-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1425445292-29061-1-git-send-email-minchan@kernel.org>
References: <1425445292-29061-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, opensource.ganesh@gmail.com, Minchan Kim <minchan@kernel.org>

Curretly, zsmalloc regards a zspage as ZS_ALMOST_EMPTY if the zspage
has under 1/4 used objects(ie, fullness_threshold_frac).
It could make result in loose packing since zsmalloc migrates
only ZS_ALMOST_EMPTY zspage out.

This patch changes the rule so that zsmalloc makes zspage which has
above 3/4 used object ZS_ALMOST_FULL so it could make tight packing.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 24a581c48aea..36dcc268720e 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -479,7 +479,7 @@ static enum fullness_group get_fullness_group(struct page *page)
 		fg = ZS_EMPTY;
 	else if (inuse == max_objects)
 		fg = ZS_FULL;
-	else if (inuse <= max_objects / fullness_threshold_frac)
+	else if (inuse <= 3 * max_objects / fullness_threshold_frac)
 		fg = ZS_ALMOST_EMPTY;
 	else
 		fg = ZS_ALMOST_FULL;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
