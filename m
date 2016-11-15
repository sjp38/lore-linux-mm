Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id D2B426B0294
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 11:00:39 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id b123so6300853itb.3
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 08:00:39 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id 21si16162835iol.180.2016.11.15.08.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 08:00:36 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id 3so12154678pgd.0
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 08:00:36 -0800 (PST)
Date: Tue, 15 Nov 2016 17:00:30 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH 2/3] z3fold: don't fail kernel build if z3fold_header is too
 big
Message-Id: <20161115170030.f0396011fa00423ff711a3b4@gmail.com>
In-Reply-To: <20161115165538.878698352bd45e212751b57a@gmail.com>
References: <20161115165538.878698352bd45e212751b57a@gmail.com>
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
test/debug builds so let's remove that and just fail the z3fold
initialization in such case instead.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 7ad70fa..ffd9353 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -870,10 +870,15 @@ MODULE_ALIAS("zpool-z3fold");
 
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
