Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 052A16B0068
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 16:55:14 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id uq10so1864699igb.14
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 13:55:14 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id oq6si6196064igb.48.2014.09.11.13.55.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 13:55:14 -0700 (PDT)
Received: by mail-ie0-f170.google.com with SMTP id tp5so10706526ieb.15
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 13:55:14 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 10/10] zsmalloc: implement zs_zpool_shrink() with zs_shrink()
Date: Thu, 11 Sep 2014 16:54:01 -0400
Message-Id: <1410468841-320-11-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
References: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>

Implement the zs_zpool_shrink() function, which previously just returned
EINVAL, by calling the zs_shrink() function to shrink the zs_pool by one
zspage.  The zs_shrink() function is called in a loop until the requested
number of pages have been reclaimed, or an error occurs.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index f769c21..4937b2b 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -292,7 +292,20 @@ static void zs_zpool_free(void *pool, unsigned long handle)
 static int zs_zpool_shrink(void *pool, unsigned int pages,
 			unsigned int *reclaimed)
 {
-	return -EINVAL;
+	int total = 0, ret = 0;
+
+	while (total < pages) {
+		ret = zs_shrink(pool);
+		WARN_ON(!ret);
+		if (ret <= 0)
+			break;
+		total += ret;
+		ret = 0;
+	}
+
+	if (reclaimed)
+		*reclaimed = total;
+	return ret;
 }
 
 static void *zs_zpool_map(void *pool, unsigned long handle,
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
