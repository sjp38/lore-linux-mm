Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 54D856B0074
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 07:59:59 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fb1so7807160pad.11
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 04:59:58 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id hh5si4219864pbc.151.2014.10.14.04.59.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 14 Oct 2014 04:59:56 -0700 (PDT)
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDF00FUYNZTACD0@mailout4.samsung.com> for linux-mm@kvack.org;
 Tue, 14 Oct 2014 20:59:53 +0900 (KST)
From: Heesub Shin <heesub.shin@samsung.com>
Subject: [RFC PATCH 9/9] mm/zswap: use highmem pages for compressed pool
Date: Tue, 14 Oct 2014 20:59:28 +0900
Message-id: <1413287968-13940-10-git-send-email-heesub.shin@samsung.com>
In-reply-to: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
References: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjennings@variantweb.net>
Cc: Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sunae Seo <sunae.seo@samsung.com>, Heesub Shin <heesub.shin@samsung.com>

Now that the zbud supports highmem, storing compressed anonymous pages
on highmem looks more reasonble. So, pass __GFP_HIGHMEM flag to zpool
when zswap allocates memory from it.

Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
---
 mm/zswap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index ea064c1..eaabe95 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -684,8 +684,8 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 	/* store */
 	len = dlen + sizeof(struct zswap_header);
-	ret = zpool_malloc(zswap_pool, len, __GFP_NORETRY | __GFP_NOWARN,
-		&handle);
+	ret = zpool_malloc(zswap_pool, len,
+			__GFP_NORETRY | __GFP_NOWARN | __GFP_HIGHMEM, &handle);
 	if (ret == -ENOSPC) {
 		zswap_reject_compress_poor++;
 		goto freepage;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
