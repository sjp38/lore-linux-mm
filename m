Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5D19003C7
	for <linux-mm@kvack.org>; Sun, 19 Jul 2015 19:17:53 -0400 (EDT)
Received: by lbbzr7 with SMTP id zr7so86175313lbb.1
        for <linux-mm@kvack.org>; Sun, 19 Jul 2015 16:17:52 -0700 (PDT)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com. [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id 6si16317343lai.40.2015.07.19.16.17.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Jul 2015 16:17:51 -0700 (PDT)
Received: by lbbzr7 with SMTP id zr7so86175054lbb.1
        for <linux-mm@kvack.org>; Sun, 19 Jul 2015 16:17:50 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [RFC 3/3] slab.h: use check_mul_overflow in kmalloc_array
Date: Mon, 20 Jul 2015 01:17:32 +0200
Message-Id: <1437347852-24921-3-git-send-email-linux@rasmusvillemoes.dk>
In-Reply-To: <1437347852-24921-1-git-send-email-linux@rasmusvillemoes.dk>
References: <1437347852-24921-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org, akpm@linux-foundation.org, Sasha Levin <sasha.levin@oracle.com>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

For recent enough gcc, check_mul_overflow maps to
__builtin_mul_overflow, which on e.g. x86 allows gcc to do the
multiplication and then check the overflow flag, instead of doing a
separate comparison (which may even involve an expensive division, in
the cases where size is not a compile-time constant).

Unfortunately, it's not necessarily always a performance improvement:
For example, when size is a compile-time constant power-of-2, gcc will
now do the multiplication using the mul instruction instead of doing a
comparison against an immediate and then a left shift for the
multiplication. However, I think the compiler should be trusted to
optimize the code - nothing prevents it from doing the overflow check
the old way.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 include/linux/slab.h | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index a99f0e5243e1..82e49dee938d 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -14,6 +14,7 @@
 #include <linux/gfp.h>
 #include <linux/types.h>
 #include <linux/workqueue.h>
+#include <linux/overflow.h>
 
 
 /*
@@ -524,9 +525,11 @@ int memcg_update_all_caches(int num_memcgs);
  */
 static inline void *kmalloc_array(size_t n, size_t size, gfp_t flags)
 {
-	if (size != 0 && n > SIZE_MAX / size)
+	size_t prod;
+
+	if (check_mul_overflow(n, size, &prod))
 		return NULL;
-	return __kmalloc(n * size, flags);
+	return __kmalloc(prod, flags);
 }
 
 /**
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
