Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 96F7B6B006E
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 06:00:49 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so1024117pad.22
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 03:00:49 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id pt9si15344757pdb.130.2014.10.15.03.00.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 15 Oct 2014 03:00:48 -0700 (PDT)
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDH00F37D5AXC40@mailout2.samsung.com> for linux-mm@kvack.org;
 Wed, 15 Oct 2014 19:00:46 +0900 (KST)
From: Heesub Shin <heesub.shin@samsung.com>
Subject: [PATCH] mm/zbud: init user ops only when it is needed
Date: Wed, 15 Oct 2014 19:00:43 +0900
Message-id: <1413367243-23524-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sunae Seo <sunae.seo@samsung.com>, Heesub Shin <heesub.shin@samsung.com>

When zbud is initialized through the zpool wrapper, pool->ops which
points to user-defined operations is always set regardless of whether it
is specified from the upper layer. This causes zbud_reclaim_page() to
iterate its loop for evicting pool pages out without any gain.

This patch sets the user-defined ops only when it is needed, so that
zbud_reclaim_page() can bail out the reclamation loop earlier if there
is no user-defined operations specified.

Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
---
 mm/zbud.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index ecf1dbe..db8de74 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -132,7 +132,7 @@ static struct zbud_ops zbud_zpool_ops = {
 
 static void *zbud_zpool_create(gfp_t gfp, struct zpool_ops *zpool_ops)
 {
-	return zbud_create_pool(gfp, &zbud_zpool_ops);
+	return zbud_create_pool(gfp, zpool_ops ? &zbud_zpool_ops : NULL);
 }
 
 static void zbud_zpool_destroy(void *pool)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
