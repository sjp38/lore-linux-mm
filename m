Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8C3586B00DB
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 02:04:08 -0500 (EST)
Message-ID: <49B0CAEC.80801@cn.fujitsu.com>
Date: Fri, 06 Mar 2009 15:04:12 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH] kmemdup_from_user(): introduce
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I notice there are many places doing copy_from_user() which follows
kmalloc():

        dst = kmalloc(len, GFP_KERNEL);
        if (!dst)
                return -ENOMEM;
        if (copy_from_user(dst, src, len)) {
		kfree(dst);
		return -EFAULT
	}

kmemdup_from_user() is a wrapper of the above code. With this new
function, we don't have to write 'len' twice, which can lead to
typos/mistakes. It also produces smaller code.

A qucik grep shows 250+ places where kmemdup_from_user() *may* be
used. I'll prepare a patchset to do this conversion.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 include/linux/string.h |    1 +
 mm/util.c              |   24 ++++++++++++++++++++++++
 2 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/linux/string.h b/include/linux/string.h
index 76ec218..397e622 100644
--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -105,6 +105,7 @@ extern void * memchr(const void *,int,__kernel_size_t);
 extern char *kstrdup(const char *s, gfp_t gfp);
 extern char *kstrndup(const char *s, size_t len, gfp_t gfp);
 extern void *kmemdup(const void *src, size_t len, gfp_t gfp);
+extern void *kmemdup_from_user(const void __user *src, size_t len, gfp_t gfp);
 
 extern char **argv_split(gfp_t gfp, const char *str, int *argcp);
 extern void argv_free(char **argv);
diff --git a/mm/util.c b/mm/util.c
index 37eaccd..a608ebb 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -70,6 +70,30 @@ void *kmemdup(const void *src, size_t len, gfp_t gfp)
 EXPORT_SYMBOL(kmemdup);
 
 /**
+ * kmemdup_from_user - duplicate memory region from user space
+ *
+ * @src: source address in user space
+ * @len: number of bytes to copy
+ * @gfp: GFP mask to use
+ */
+void *kmemdup_from_user(const void __user *src, size_t len, gfp_t gfp)
+{
+	void *p;
+
+	p = kmalloc_track_caller(len, gfp);
+	if (!p)
+		return ERR_PTR(-ENOMEM);
+
+	if (copy_from_user(p, src, len)) {
+		kfree(p);
+		return ERR_PTR(-EFAULT);
+	}
+
+	return p;
+}
+EXPORT_SYMBOL(kmemdup_from_user);
+
+/**
  * __krealloc - like krealloc() but don't free @p.
  * @p: object to reallocate memory for.
  * @new_size: how many bytes of memory are required.
-- 
1.5.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
