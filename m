Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B580E6B0106
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 04:49:46 -0500 (EST)
Message-ID: <49B0F1B9.1080903@cn.fujitsu.com>
Date: Fri, 06 Mar 2009 17:49:45 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH -v2] memdup_user(): introduce
References: <49B0CAEC.80801@cn.fujitsu.com>	<20090306082056.GB3450@x200.localdomain>	<49B0DE89.9000401@cn.fujitsu.com>	<20090306003900.a031a914.akpm@linux-foundation.org>	<49B0E67C.2090404@cn.fujitsu.com> <20090306011548.ffdf9cbc.akpm@linux-foundation.org>
In-Reply-To: <20090306011548.ffdf9cbc.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
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

memdup_user() is a wrapper of the above code. With this new function,
we don't have to write 'len' twice, which can lead to typos/mistakes.
It also produces smaller code and kernel text.

A quick grep shows 250+ places where memdup_user() *may* be used. I'll
prepare a patchset to do this conversion.

v1 -> v2: change the name from kmemdup_from_user to memdup_user.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---

Can this get into 2.6.29, so I can prepare patches based on linux-next?
And this won't cause regression, since no one uses it yet. :)

---
 include/linux/string.h |    1 +
 mm/util.c              |   26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/include/linux/string.h b/include/linux/string.h
index 76ec218..79f30f3 100644
--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -12,6 +12,7 @@
 #include <linux/stddef.h>	/* for NULL */
 
 extern char *strndup_user(const char __user *, long);
+extern void *memdup_user(const void __user *, size_t, gfp_t);
 
 /*
  * Include machine specific inline routines
diff --git a/mm/util.c b/mm/util.c
index 37eaccd..3d21c21 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -70,6 +70,32 @@ void *kmemdup(const void *src, size_t len, gfp_t gfp)
 EXPORT_SYMBOL(kmemdup);
 
 /**
+ * memdup_user - duplicate memory region from user space
+ *
+ * @src: source address in user space
+ * @len: number of bytes to copy
+ * @gfp: GFP mask to use
+ *
+ * Returns an ERR_PTR() on failure.
+ */
+void *memdup_user(const void __user *src, size_t len, gfp_t gfp)
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
+EXPORT_SYMBOL(memdup_user);
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
