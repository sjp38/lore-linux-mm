Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 113756B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 15:19:36 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id pp5so93768852pac.3
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 12:19:36 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id l29si6376871pfk.67.2016.08.19.12.19.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 12:19:35 -0700 (PDT)
Received: by mail-pa0-x22b.google.com with SMTP id hb8so166646pac.2
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 12:19:35 -0700 (PDT)
From: Eric Biggers <ebiggers@google.com>
Subject: [PATCH] mm: avoid undefined behavior in hardened usercopy check
Date: Fri, 19 Aug 2016 12:15:22 -0700
Message-Id: <1471634122-31789-1-git-send-email-ebiggers@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eric Biggers <ebiggers@google.com>

check_bogus_address() checked for pointer overflow using this expression,
where 'ptr' has type 'const void *':

	ptr + n < ptr

Since pointer wraparound is undefined behavior, gcc at -O2 by default
treats it like the following, which would not behave as intended:

	(long)n < 0

Fortunately, this doesn't currently happen for kernel code because kernel
code is compiled with -fno-strict-overflow.  But the expression should be
fixed anyway to use well-defined integer arithmetic, since it could be
treated differently by different compilers in the future or could be
reported by tools checking for undefined behavior.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 mm/usercopy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/usercopy.c b/mm/usercopy.c
index 8ebae91..82f81df 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -124,7 +124,7 @@ static inline const char *check_kernel_text_object(const void *ptr,
 static inline const char *check_bogus_address(const void *ptr, unsigned long n)
 {
 	/* Reject if object wraps past end of memory. */
-	if (ptr + n < ptr)
+	if ((unsigned long)ptr + n < (unsigned long)ptr)
 		return "<wrapped address>";
 
 	/* Reject if NULL or ZERO-allocation. */
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
