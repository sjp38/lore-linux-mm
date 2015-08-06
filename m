Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 019886B0258
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 13:54:43 -0400 (EDT)
Received: by qged69 with SMTP id d69so58360655qge.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 10:54:42 -0700 (PDT)
Received: from mail-qk0-x229.google.com (mail-qk0-x229.google.com. [2607:f8b0:400d:c09::229])
        by mx.google.com with ESMTPS id k140si13186049qhk.19.2015.08.06.10.54.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 10:54:42 -0700 (PDT)
Received: by qkbm65 with SMTP id m65so28953324qkb.2
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 10:54:41 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] zpool: clarification comment for zpool_has_pool
Date: Thu,  6 Aug 2015 13:54:33 -0400
Message-Id: <1438883673-7791-1-git-send-email-ddstreet@ieee.org>
In-Reply-To: <CALZtONDNYyKEdk2fc40ePH4Y+vOcUE-D7OG1DRekgSxLgVYKeA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <ddstreet@ieee.org>

Add clarification in the documentation comment for zpool_has_pool() to
explain the caller should assume the requested driver is or is not
available, depending on return value.  If true is returned, the caller
should assume zpool_create_pool() will succeed, but still must be
prepared to handle failure.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 mm/zpool.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/zpool.c b/mm/zpool.c
index aafcf8f..d8cf7cd 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -103,7 +103,15 @@ static void zpool_put_driver(struct zpool_driver *driver)
  * zpool_has_pool() - Check if the pool driver is available
  * @type	The type of the zpool to check (e.g. zbud, zsmalloc)
  *
- * This checks if the @type pool driver is available.
+ * This checks if the @type pool driver is available.  This will try to load
+ * the requested module, if needed, but there is no guarantee the module will
+ * still be loaded and available immediately after calling.  If this returns
+ * true, the caller should assume the pool is available, but must be prepared
+ * to handle the @zpool_create_pool() returning failure.  However if this
+ * returns false, the caller should assume the requested pool type is not
+ * available; either the requested pool type module does not exist, or could
+ * not be loaded, and calling @zpool_create_pool() with the pool type will
+ * fail.
  *
  * Returns: true if @type pool is available, false if not
  */
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
