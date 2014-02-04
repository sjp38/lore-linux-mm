Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id C62E86B0036
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 15:43:56 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so8937140pbb.20
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 12:43:56 -0800 (PST)
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
        by mx.google.com with ESMTPS id gx4si26076915pbc.51.2014.02.04.12.43.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 12:43:55 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so9022275pab.32
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 12:43:55 -0800 (PST)
From: Sebastian Capella <sebastian.capella@linaro.org>
Subject: [PATCH v7 1/3] mm: add kstrdup_trimnl function
Date: Tue,  4 Feb 2014 12:43:49 -0800
Message-Id: <1391546631-7715-2-git-send-email-sebastian.capella@linaro.org>
In-Reply-To: <1391546631-7715-1-git-send-email-sebastian.capella@linaro.org>
References: <1391546631-7715-1-git-send-email-sebastian.capella@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org
Cc: Sebastian Capella <sebastian.capella@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joe Perches <joe@perches.com>, David Rientjes <rientjes@google.com>, Alexey Dobriyan <adobriyan@gmail.com>

kstrdup_trimnl creates a duplicate of the passed in
null-terminated string.  If a trailing newline is found, it
is removed before duplicating.  This is useful for strings
coming from sysfs that often include trailing whitespace due to
user input.

Signed-off-by: Sebastian Capella <sebastian.capella@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com> (commit_signer:5/10=50%)
Cc: Michel Lespinasse <walken@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Jerome Marchand <jmarchan@redhat.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Joe Perches <joe@perches.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/string.h |    1 +
 mm/util.c              |   29 +++++++++++++++++++++++++++++
 2 files changed, 30 insertions(+)

diff --git a/include/linux/string.h b/include/linux/string.h
index ac889c5..e7ec8c0 100644
--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -114,6 +114,7 @@ void *memchr_inv(const void *s, int c, size_t n);
 
 extern char *kstrdup(const char *s, gfp_t gfp);
 extern char *kstrndup(const char *s, size_t len, gfp_t gfp);
+extern char *kstrdup_trimnl(const char *s, gfp_t gfp);
 extern void *kmemdup(const void *src, size_t len, gfp_t gfp);
 
 extern char **argv_split(gfp_t gfp, const char *str, int *argcp);
diff --git a/mm/util.c b/mm/util.c
index 808f375..0bab867 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -1,6 +1,7 @@
 #include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/string.h>
+#include <linux/ctype.h>
 #include <linux/export.h>
 #include <linux/err.h>
 #include <linux/sched.h>
@@ -63,6 +64,34 @@ char *kstrndup(const char *s, size_t max, gfp_t gfp)
 EXPORT_SYMBOL(kstrndup);
 
 /**
+ * kstrdup_trimnl - Copy a %NUL terminated string, removing one trailing
+ * newline if present.
+ * @s: the string to duplicate
+ * @gfp: the GFP mask used in the kmalloc() call when allocating memory
+ *
+ * Returns an address, which the caller must kfree, containing
+ * a duplicate of the passed string with a single trailing newline
+ * removed if present.
+ */
+char *kstrdup_trimnl(const char *s, gfp_t gfp)
+{
+	char *buf;
+	size_t len = strlen(s);
+	if (len >= 1 && s[len - 1] == '\n')
+		len--;
+
+	buf = kmalloc_track_caller(len + 1, gfp);
+	if (!buf)
+		return NULL;
+
+	memcpy(buf, s, len);
+	buf[len] = '\0';
+
+	return buf;
+}
+EXPORT_SYMBOL(kstrdup_trimnl);
+
+/**
  * kmemdup - duplicate region of memory
  *
  * @src: memory region to duplicate
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
