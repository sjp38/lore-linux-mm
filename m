Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 968CF6B0032
	for <linux-mm@kvack.org>; Sat, 24 Jan 2015 08:50:15 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so2761564pad.10
        for <linux-mm@kvack.org>; Sat, 24 Jan 2015 05:50:15 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id ff5si5532285pad.179.2015.01.24.05.50.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 24 Jan 2015 05:50:14 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so2797416pac.2
        for <linux-mm@kvack.org>; Sat, 24 Jan 2015 05:50:14 -0800 (PST)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH] mm/zsmalloc: avoid unnecessary iteration when freeing
 size_class
Date: Sat, 24 Jan 2015 21:50:03 +0800
Message-Id: <1422107403-10071-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

The pool->size_class[i] is assigned with the i from (zs_size_classes - 1) to 0.
So if we failed in zs_create_pool(), we only need to iterate from (zs_size_classes - 1)
to i, instead of from 0 to (zs_size_classes - 1)

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 16617e9..e6fa3da 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1433,12 +1433,12 @@ void zs_destroy_pool(struct zs_pool *pool)
 
 	zs_pool_stat_destroy(pool);
 
-	for (i = 0; i < zs_size_classes; i++) {
+	for (i = zs_size_classes - 1; i >= 0; i--) {
 		int fg;
 		struct size_class *class = pool->size_class[i];
 
 		if (!class)
-			continue;
+			break;
 
 		if (class->index != i)
 			continue;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
