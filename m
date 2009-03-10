Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3F1BF6B004D
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 21:47:17 -0400 (EDT)
Message-ID: <49B5C69F.3010409@cn.fujitsu.com>
Date: Tue, 10 Mar 2009 09:47:11 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] memdup_user: introduce, fix
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Americo Wang <xiyou.wangcong@gmail.com>, Alexey Dobriyan <adobriyan@gmail.com>, Arjan van de Ven <arjan@infradead.org>, Roland Dreier <rdreier@cisco.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Always use GFP_KERNEL in kmalloc(), since copy_from_user() can sleep and
cause pagefault, thus it's pointless to use GFP_NOFS or GFP_ATOMIC here.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---

Against memdup_user-introduce.patch

---
 include/linux/string.h |    2 +-
 mm/util.c              |   10 +++++++---
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/linux/string.h b/include/linux/string.h
index 79f30f3..0863885 100644
--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -12,7 +12,7 @@
 #include <linux/stddef.h>	/* for NULL */
 
 extern char *strndup_user(const char __user *, long);
-extern void *memdup_user(const void __user *, size_t, gfp_t);
+extern void *memdup_user(const void __user *, size_t);
 
 /*
  * Include machine specific inline routines
diff --git a/mm/util.c b/mm/util.c
index 3d21c21..7c122e4 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -74,15 +74,19 @@ EXPORT_SYMBOL(kmemdup);
  *
  * @src: source address in user space
  * @len: number of bytes to copy
- * @gfp: GFP mask to use
  *
  * Returns an ERR_PTR() on failure.
  */
-void *memdup_user(const void __user *src, size_t len, gfp_t gfp)
+void *memdup_user(const void __user *src, size_t len)
 {
 	void *p;
 
-	p = kmalloc_track_caller(len, gfp);
+	/*
+	 * Always use GFP_KERNEL, since copy_from_user() can sleep and
+	 * cause pagefault, which makes it pointless to use GFP_NOFS
+	 * or GFP_ATOMIC.
+	 */
+	p = kmalloc_track_caller(len, GFP_KERNEL);
 	if (!p)
 		return ERR_PTR(-ENOMEM);
 
-- 
1.5.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
