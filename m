Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id BACEA6B00A3
	for <linux-mm@kvack.org>; Sat,  8 Sep 2012 16:50:10 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so248154ghr.14
        for <linux-mm@kvack.org>; Sat, 08 Sep 2012 13:50:09 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH 05/10] mm, util: Use dup_user to duplicate user memory
Date: Sat,  8 Sep 2012 17:47:54 -0300
Message-Id: <1347137279-17568-5-git-send-email-elezegarcia@gmail.com>
In-Reply-To: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
References: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Pekka Enberg <penberg@kernel.org>

Previously the strndup_user allocation was being done through memdup_user,
and the caller was wrongly traced as being strndup_user
(the correct trace must report the caller of strndup_user).

This is a common problem: in order to get accurate callsite tracing,
a utils function can't allocate through another utils function,
but instead do the allocation himself (or inlined).

Here we fix this by creating an always inlined dup_user() function to
performed the real allocation and to be used by memdup_user and strndup_user.

Cc: Pekka Enberg <penberg@kernel.org>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
 mm/util.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/util.c b/mm/util.c
index dc3036c..48d3ff8b 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -76,14 +76,14 @@ void *kmemdup(const void *src, size_t len, gfp_t gfp)
 EXPORT_SYMBOL(kmemdup);
 
 /**
- * memdup_user - duplicate memory region from user space
+ * dup_user - duplicate memory region from user space
  *
  * @src: source address in user space
  * @len: number of bytes to copy
  *
  * Returns an ERR_PTR() on failure.
  */
-void *memdup_user(const void __user *src, size_t len)
+static __always_inline void *dup_user(const void __user *src, size_t len)
 {
 	void *p;
 
@@ -103,6 +103,11 @@ void *memdup_user(const void __user *src, size_t len)
 
 	return p;
 }
+
+void *memdup_user(const void __user *src, size_t len)
+{
+	return dup_user(src, len);
+}
 EXPORT_SYMBOL(memdup_user);
 
 static __always_inline void *__do_krealloc(const void *p, size_t new_size,
@@ -214,7 +219,7 @@ char *strndup_user(const char __user *s, long n)
 	if (length > n)
 		return ERR_PTR(-EINVAL);
 
-	p = memdup_user(s, length);
+	p = dup_user(s, length);
 
 	if (IS_ERR(p))
 		return p;
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
