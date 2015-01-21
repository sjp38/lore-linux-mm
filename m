Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id EFEA66B0078
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 01:14:56 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id v10so26407613pde.3
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 22:14:56 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ti8si7293107pbc.26.2015.01.20.22.14.36
        for <linux-mm@kvack.org>;
        Tue, 20 Jan 2015 22:14:38 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 07/10] zsmalloc: adjust ZS_ALMOST_FULL
Date: Wed, 21 Jan 2015 15:14:23 +0900
Message-Id: <1421820866-26521-8-git-send-email-minchan@kernel.org>
In-Reply-To: <1421820866-26521-1-git-send-email-minchan@kernel.org>
References: <1421820866-26521-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>

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
index 99bf5bd..8217e8e 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -477,7 +477,7 @@ static enum fullness_group get_fullness_group(struct page *page)
 		fg = ZS_EMPTY;
 	else if (inuse == max_objects)
 		fg = ZS_FULL;
-	else if (inuse <= max_objects / fullness_threshold_frac)
+	else if (inuse <= 3 * max_objects / fullness_threshold_frac)
 		fg = ZS_ALMOST_EMPTY;
 	else
 		fg = ZS_ALMOST_FULL;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
