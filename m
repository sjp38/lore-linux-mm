Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id CF43B6B0039
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 19:54:30 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fa1so3822456pad.13
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:54:30 -0800 (PST)
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
        by mx.google.com with ESMTPS id xu6si8421058pab.80.2014.01.30.16.54.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 16:54:29 -0800 (PST)
Received: by mail-pb0-f46.google.com with SMTP id um1so3794150pbc.19
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:54:23 -0800 (PST)
From: Sebastian Capella <sebastian.capella@linaro.org>
Subject: [PATCH v6 1/2] mm: add kstrimdup function
Date: Thu, 30 Jan 2014 16:54:13 -0800
Message-Id: <1391129654-12854-2-git-send-email-sebastian.capella@linaro.org>
In-Reply-To: <1391129654-12854-1-git-send-email-sebastian.capella@linaro.org>
References: <1391129654-12854-1-git-send-email-sebastian.capella@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org
Cc: Sebastian Capella <sebastian.capella@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Mikulas Patocka <mpatocka@redhat.com>, David Rientjes <rientjes@google.com>, Michel Lespinasse <walken@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

kstrimdup creates a whitespace-trimmed duplicate of the passed
in null-terminated string.  This is useful for strings coming
from sysfs that often include trailing whitespace due to user
input.

Thanks to Joe Perches for this implementation.

Signed-off-by: Sebastian Capella <sebastian.capella@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Joe Perches <joe@perches.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com> (commit_signer:5/10=50%)
Cc: Michel Lespinasse <walken@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Jerome Marchand <jmarchan@redhat.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/string.h |    1 +
 mm/util.c              |   30 ++++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+)

diff --git a/include/linux/string.h b/include/linux/string.h
index ac889c5..f29f9a0 100644
--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -114,6 +114,7 @@ void *memchr_inv(const void *s, int c, size_t n);
 
 extern char *kstrdup(const char *s, gfp_t gfp);
 extern char *kstrndup(const char *s, size_t len, gfp_t gfp);
+extern char *kstrimdup(const char *s, gfp_t gfp);
 extern void *kmemdup(const void *src, size_t len, gfp_t gfp);
 
 extern char **argv_split(gfp_t gfp, const char *str, int *argcp);
diff --git a/mm/util.c b/mm/util.c
index 808f375..a8b731c 100644
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
@@ -63,6 +64,35 @@ char *kstrndup(const char *s, size_t max, gfp_t gfp)
 EXPORT_SYMBOL(kstrndup);
 
 /**
+ * kstrimdup - Trim and copy a %NUL terminated string.
+ * @s: the string to trim and duplicate
+ * @gfp: the GFP mask used in the kmalloc() call when allocating memory
+ *
+ * Returns an address, which the caller must kfree, containing
+ * a duplicate of the passed string with leading and/or trailing
+ * whitespace (as defined by isspace) removed.
+ */
+char *kstrimdup(const char *s, gfp_t gfp)
+{
+	char *buf;
+	char *begin = skip_spaces(s);
+	size_t len = strlen(begin);
+
+	while (len && isspace(begin[len - 1]))
+		len--;
+
+	buf = kmalloc_track_caller(len + 1, gfp);
+	if (!buf)
+		return NULL;
+
+	memcpy(buf, begin, len);
+	buf[len] = '\0';
+
+	return buf;
+}
+EXPORT_SYMBOL(kstrimdup);
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
