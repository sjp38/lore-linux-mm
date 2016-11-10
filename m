Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4ABD56B026D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 02:55:06 -0500 (EST)
Received: by mail-pa0-f72.google.com with SMTP id ro13so88306347pac.7
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 23:55:06 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id p70si3468791pfd.221.2016.11.09.23.55.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 23:55:05 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id i88so3241384pfk.2
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 23:55:05 -0800 (PST)
Date: Thu, 10 Nov 2016 08:54:58 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH] z3fold: don't fail kernel build if z3fold_header is too big
Message-Id: <20161110085458.53273e9b1c3e0f09bb0e9655@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

Currently the whole kernel build will be stopped if the size of
struct z3fold_header is greater than the size of one chunk, which
is 64 bytes by default. This may stand in the way of automated
test/debug builds so let's remove that and fail the z3fold
initialization in such case instead.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index cd3713d..5fe2652 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -866,10 +866,15 @@ MODULE_ALIAS("zpool-z3fold");
 
 static int __init init_z3fold(void)
 {
-	/* Make sure the z3fold header will fit in one chunk */
-	BUILD_BUG_ON(sizeof(struct z3fold_header) > ZHDR_SIZE_ALIGNED);
-	zpool_register_driver(&z3fold_zpool_driver);
+	/* Fail the initialization if z3fold header won't fit in one chunk */
+	if (sizeof(struct z3fold_header) > ZHDR_SIZE_ALIGNED) {
+		pr_err("z3fold: z3fold_header size (%d) is bigger than "
+			"the chunk size (%d), can't proceed\n",
+			sizeof(struct z3fold_header) , ZHDR_SIZE_ALIGNED);
+		return -E2BIG;
+	}
 
+	zpool_register_driver(&z3fold_zpool_driver);
 	return 0;
 }
 
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
