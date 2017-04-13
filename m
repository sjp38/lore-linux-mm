Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6AB816B0390
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 20:17:15 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id f5so23464429pff.13
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 17:17:15 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 64si12091319plk.272.2017.04.12.17.17.13
        for <linux-mm@kvack.org>;
        Wed, 12 Apr 2017 17:17:14 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 3/3] zsmalloc: expand class bit
Date: Thu, 13 Apr 2017 09:17:02 +0900
Message-ID: <1492042622-12074-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1492042622-12074-1-git-send-email-minchan@kernel.org>
References: <1492042622-12074-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, kernel-team@lge.com, Minchan Kim <minchan@kernel.org>, stable@vger.kernel.org, linux-mm@kvack.org

Now 64K page system, zsamlloc has 257 classes so 8 class bit
is not enough. With that, it corrupts the system when zsmalloc
stores 65536byte data(ie, index number 256) so that this patch
increases class bit for simple fix for stable backport.
We should clean up this mess soon.

index	size
0	32
1	288
..
..
204	52256
256	65536

Cc: linux-mm@kvack.org
Fixes: 3783689a1 ("zsmalloc: introduce zspage structure")
Cc: stable@vger.kernel.org
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b7b1fb6c8c21..9feadf4fc3d5 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -275,7 +275,7 @@ struct zs_pool {
 struct zspage {
 	struct {
 		unsigned int fullness:FULLNESS_BITS;
-		unsigned int class:CLASS_BITS;
+		unsigned int class:CLASS_BITS + 1;
 		unsigned int isolated:ISOLATED_BITS;
 		unsigned int magic:MAGIC_VAL_BITS;
 	};
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
