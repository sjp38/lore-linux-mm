Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 489336B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 07:16:58 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w63so13750179wrc.5
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 04:16:58 -0700 (PDT)
Received: from mout.web.de (mout.web.de. [212.227.17.12])
        by mx.google.com with ESMTPS id p1si3697266wmf.186.2017.08.14.04.16.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 04:16:57 -0700 (PDT)
Subject: [PATCH 2/2] zpool: Use common error handling code in
 zpool_create_pool()
From: SF Markus Elfring <elfring@users.sourceforge.net>
References: <0fec59a9-ac68-33f6-533a-adfb5fa3c380@users.sourceforge.net>
Message-ID: <54351127-7222-c578-10f7-ee0dbf8f7879@users.sourceforge.net>
Date: Mon, 14 Aug 2017 13:16:55 +0200
MIME-Version: 1.0
In-Reply-To: <0fec59a9-ac68-33f6-533a-adfb5fa3c380@users.sourceforge.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 14 Aug 2017 13:04:33 +0200

Add a jump target so that a bit of exception handling can be better reused
in this function.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 mm/zpool.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/zpool.c b/mm/zpool.c
index fe1943f7d844..e4634edef86d 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -171,10 +171,8 @@ struct zpool *zpool_create_pool(const char *type, const char *name, gfp_t gfp,
 	}
 
 	zpool = kmalloc(sizeof(*zpool), gfp);
-	if (!zpool) {
-		zpool_put_driver(driver);
-		return NULL;
-	}
+	if (!zpool)
+		goto put_driver;
 
 	zpool->driver = driver;
 	zpool->pool = driver->create(name, gfp, ops, zpool);
@@ -182,8 +180,9 @@ struct zpool *zpool_create_pool(const char *type, const char *name, gfp_t gfp,
 
 	if (!zpool->pool) {
 		pr_err("couldn't create %s pool\n", type);
-		zpool_put_driver(driver);
 		kfree(zpool);
+put_driver:
+		zpool_put_driver(driver);
 		return NULL;
 	}
 
-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
