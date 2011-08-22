Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C80E06B016C
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 12:27:28 -0400 (EDT)
Received: by ywm13 with SMTP id 13so4845150ywm.14
        for <linux-mm@kvack.org>; Mon, 22 Aug 2011 09:27:26 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 3/4] string: introduce memchr_inv
Date: Tue, 23 Aug 2011 01:29:07 +0900
Message-Id: <1314030548-21082-4-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1314030548-21082-1-git-send-email-akinobu.mita@gmail.com>
References: <1314030548-21082-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Joern Engel <joern@logfs.org>, logfs@logfs.org, Marcin Slusarz <marcin.slusarz@gmail.com>, Eric Dumazet <eric.dumazet@gmail.com>

memchr_inv() is mainly used to check whether the whole buffer is filled
with just a specified byte.

The function name and prototype are stolen from logfs and the
implementation is from SLUB.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: linux-mm@kvack.org
Cc: Joern Engel <joern@logfs.org>
Cc: logfs@logfs.org
Cc: Marcin Slusarz <marcin.slusarz@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 fs/logfs/logfs.h       |    1 -
 fs/logfs/super.c       |   22 -------------------
 include/linux/string.h |    1 +
 lib/string.c           |   54 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/slub.c              |   47 +----------------------------------------
 5 files changed, 57 insertions(+), 68 deletions(-)

diff --git a/fs/logfs/logfs.h b/fs/logfs/logfs.h
index f22d108..398ecff 100644
--- a/fs/logfs/logfs.h
+++ b/fs/logfs/logfs.h
@@ -618,7 +618,6 @@ static inline int logfs_buf_recover(struct logfs_area *area, u64 ofs,
 struct page *emergency_read_begin(struct address_space *mapping, pgoff_t index);
 void emergency_read_end(struct page *page);
 void logfs_crash_dump(struct super_block *sb);
-void *memchr_inv(const void *s, int c, size_t n);
 int logfs_statfs(struct dentry *dentry, struct kstatfs *stats);
 int logfs_check_ds(struct logfs_disk_super *ds);
 int logfs_write_sb(struct super_block *sb);
diff --git a/fs/logfs/super.c b/fs/logfs/super.c
index ce03a18..f2697e4 100644
--- a/fs/logfs/super.c
+++ b/fs/logfs/super.c
@@ -91,28 +91,6 @@ void logfs_crash_dump(struct super_block *sb)
 }
 
 /*
- * TODO: move to lib/string.c
- */
-/**
- * memchr_inv - Find a character in an area of memory.
- * @s: The memory area
- * @c: The byte to search for
- * @n: The size of the area.
- *
- * returns the address of the first character other than @c, or %NULL
- * if the whole buffer contains just @c.
- */
-void *memchr_inv(const void *s, int c, size_t n)
-{
-	const unsigned char *p = s;
-	while (n-- != 0)
-		if ((unsigned char)c != *p++)
-			return (void *)(p - 1);
-
-	return NULL;
-}
-
-/*
  * FIXME: There should be a reserve for root, similar to ext2.
  */
 int logfs_statfs(struct dentry *dentry, struct kstatfs *stats)
diff --git a/include/linux/string.h b/include/linux/string.h
index a176db2..e033564 100644
--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -114,6 +114,7 @@ extern int memcmp(const void *,const void *,__kernel_size_t);
 #ifndef __HAVE_ARCH_MEMCHR
 extern void * memchr(const void *,int,__kernel_size_t);
 #endif
+void *memchr_inv(const void *s, int c, size_t n);
 
 extern char *kstrdup(const char *s, gfp_t gfp);
 extern char *kstrndup(const char *s, size_t len, gfp_t gfp);
diff --git a/lib/string.c b/lib/string.c
index 01fad9b..18f5111 100644
--- a/lib/string.c
+++ b/lib/string.c
@@ -756,3 +756,57 @@ void *memchr(const void *s, int c, size_t n)
 }
 EXPORT_SYMBOL(memchr);
 #endif
+
+static void *check_bytes8(const u8 *start, u8 value, unsigned int bytes)
+{
+	while (bytes) {
+		if (*start != value)
+			return (void *)start;
+		start++;
+		bytes--;
+	}
+	return NULL;
+}
+
+/**
+ * memchr_inv - Find a character in an area of memory.
+ * @s: The memory area
+ * @c: The byte to search for
+ * @n: The size of the area.
+ *
+ * returns the address of the first character other than @c, or %NULL
+ * if the whole buffer contains just @c.
+ */
+void *memchr_inv(const void *start, int c, size_t bytes)
+{
+	u8 value = c;
+	u64 value64;
+	unsigned int words, prefix;
+
+	if (bytes <= 16)
+		return check_bytes8(start, value, bytes);
+
+	value64 = value | value << 8 | value << 16 | value << 24;
+	value64 = (value64 & 0xffffffff) | value64 << 32;
+	prefix = 8 - ((unsigned long)start) % 8;
+
+	if (prefix) {
+		u8 *r = check_bytes8(start, value, prefix);
+		if (r)
+			return r;
+		start += prefix;
+		bytes -= prefix;
+	}
+
+	words = bytes / 8;
+
+	while (words) {
+		if (*(u64 *)start != value64)
+			return check_bytes8(start, value, 8);
+		start += 8;
+		words--;
+	}
+
+	return check_bytes8(start, value, bytes % 8);
+}
+EXPORT_SYMBOL(memchr_inv);
diff --git a/mm/slub.c b/mm/slub.c
index 9f662d7..692fe34 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -681,49 +681,6 @@ static void init_object(struct kmem_cache *s, void *object, u8 val)
 		memset(p + s->objsize, val, s->inuse - s->objsize);
 }
 
-static u8 *check_bytes8(u8 *start, u8 value, unsigned int bytes)
-{
-	while (bytes) {
-		if (*start != value)
-			return start;
-		start++;
-		bytes--;
-	}
-	return NULL;
-}
-
-static u8 *check_bytes(u8 *start, u8 value, unsigned int bytes)
-{
-	u64 value64;
-	unsigned int words, prefix;
-
-	if (bytes <= 16)
-		return check_bytes8(start, value, bytes);
-
-	value64 = value | value << 8 | value << 16 | value << 24;
-	value64 = (value64 & 0xffffffff) | value64 << 32;
-	prefix = 8 - ((unsigned long)start) % 8;
-
-	if (prefix) {
-		u8 *r = check_bytes8(start, value, prefix);
-		if (r)
-			return r;
-		start += prefix;
-		bytes -= prefix;
-	}
-
-	words = bytes / 8;
-
-	while (words) {
-		if (*(u64 *)start != value64)
-			return check_bytes8(start, value, 8);
-		start += 8;
-		words--;
-	}
-
-	return check_bytes8(start, value, bytes % 8);
-}
-
 static void restore_bytes(struct kmem_cache *s, char *message, u8 data,
 						void *from, void *to)
 {
@@ -738,7 +695,7 @@ static int check_bytes_and_report(struct kmem_cache *s, struct page *page,
 	u8 *fault;
 	u8 *end;
 
-	fault = check_bytes(start, value, bytes);
+	fault = memchr_inv(start, value, bytes);
 	if (!fault)
 		return 1;
 
@@ -831,7 +788,7 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
 	if (!remainder)
 		return 1;
 
-	fault = check_bytes(end - remainder, POISON_INUSE, remainder);
+	fault = memchr_inv(end - remainder, POISON_INUSE, remainder);
 	if (!fault)
 		return 1;
 	while (end > fault && end[-1] == POISON_INUSE)
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
