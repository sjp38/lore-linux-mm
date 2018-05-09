Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 598076B02F3
	for <linux-mm@kvack.org>; Tue,  8 May 2018 20:42:44 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id a12-v6so3672915pgu.20
        for <linux-mm@kvack.org>; Tue, 08 May 2018 17:42:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g16sor8356979pfd.116.2018.05.08.17.42.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 17:42:43 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 03/13] overflow.h: Add allocation size calculation helpers
Date: Tue,  8 May 2018 17:42:19 -0700
Message-Id: <20180509004229.36341-4-keescook@chromium.org>
In-Reply-To: <20180509004229.36341-1-keescook@chromium.org>
References: <20180509004229.36341-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

In preparation for replacing unchecked overflows for memory allocations,
this creates helpers for the 3 most common calculations:

array_size(a, b): 2-dimensional array
array3_size(a, b, c): 2-dimensional array
struct_size(ptr, member, n): struct followed by n-many trailing members

Each of these return SIZE_MAX on overflow instead of wrapping around.

(Additionally renames a variable named "array_size" to avoid future
collision.)

Co-developed-by: Matthew Wilcox <mawilcox@microsoft.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/md/dm-table.c    | 10 +++---
 include/linux/overflow.h | 74 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 79 insertions(+), 5 deletions(-)

diff --git a/drivers/md/dm-table.c b/drivers/md/dm-table.c
index 0589a4da12bb..caa51dd351b6 100644
--- a/drivers/md/dm-table.c
+++ b/drivers/md/dm-table.c
@@ -548,14 +548,14 @@ static int adjoin(struct dm_table *table, struct dm_target *ti)
  * On the other hand, dm-switch needs to process bulk data using messages and
  * excessive use of GFP_NOIO could cause trouble.
  */
-static char **realloc_argv(unsigned *array_size, char **old_argv)
+static char **realloc_argv(unsigned *size, char **old_argv)
 {
 	char **argv;
 	unsigned new_size;
 	gfp_t gfp;
 
-	if (*array_size) {
-		new_size = *array_size * 2;
+	if (*size) {
+		new_size = *size * 2;
 		gfp = GFP_KERNEL;
 	} else {
 		new_size = 8;
@@ -563,8 +563,8 @@ static char **realloc_argv(unsigned *array_size, char **old_argv)
 	}
 	argv = kmalloc(new_size * sizeof(*argv), gfp);
 	if (argv) {
-		memcpy(argv, old_argv, *array_size * sizeof(*argv));
-		*array_size = new_size;
+		memcpy(argv, old_argv, *size * sizeof(*argv));
+		*size = new_size;
 	}
 
 	kfree(old_argv);
diff --git a/include/linux/overflow.h b/include/linux/overflow.h
index c8890ec358a7..76ff298e97b7 100644
--- a/include/linux/overflow.h
+++ b/include/linux/overflow.h
@@ -202,4 +202,78 @@
 
 #endif /* COMPILER_HAS_GENERIC_BUILTIN_OVERFLOW */
 
+/**
+ * array_size() - Calculate size of 2-dimensional array.
+ *
+ * @a: dimension one
+ * @b: dimension two
+ *
+ * Calculates size of 2-dimensional array: @a * @b.
+ *
+ * Returns: number of bytes needed to represent the array or SIZE_MAX on
+ * overflow.
+ */
+static inline __must_check size_t array_size(size_t a, size_t b)
+{
+	size_t bytes;
+
+	if (check_mul_overflow(a, b, &bytes))
+		return SIZE_MAX;
+
+	return bytes;
+}
+
+/**
+ * array3_size() - Calculate size of 3-dimensional array.
+ *
+ * @a: dimension one
+ * @b: dimension two
+ * @c: dimension three
+ *
+ * Calculates size of 3-dimensional array: @a * @b * @c.
+ *
+ * Returns: number of bytes needed to represent the array or SIZE_MAX on
+ * overflow.
+ */
+static inline __must_check size_t array3_size(size_t a, size_t b, size_t c)
+{
+	size_t bytes;
+
+	if (check_mul_overflow(a, b, &bytes))
+		return SIZE_MAX;
+	if (check_mul_overflow(bytes, c, &bytes))
+		return SIZE_MAX;
+
+	return bytes;
+}
+
+static inline __must_check size_t __ab_c_size(size_t n, size_t size, size_t c)
+{
+	size_t bytes;
+
+	if (check_mul_overflow(n, size, &bytes))
+		return SIZE_MAX;
+	if (check_add_overflow(bytes, c, &bytes))
+		return SIZE_MAX;
+
+	return bytes;
+}
+
+/**
+ * struct_size() - Calculate size of structure with trailing array.
+ * @p: Pointer to the structure.
+ * @member: Name of the array member.
+ * @n: Number of elements in the array.
+ *
+ * Calculates size of memory needed for structure @p followed by an
+ * array of @n @member elements.
+ *
+ * Return: number of bytes needed or SIZE_MAX on overflow.
+ */
+#define struct_size(p, member, n)					\
+	__ab_c_size(n,							\
+		    sizeof(*(p)->member) + __must_be_array((p)->member),\
+		    offsetof(typeof(*(p)), member))
+
+
 #endif /* __LINUX_OVERFLOW_H */
-- 
2.17.0
