Received: from verein.lst.de (localhost [127.0.0.1])
	by mail.lst.de (8.12.3/8.12.3/Debian-7.1) with ESMTP id k74FGLRT029598
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <linux-mm@kvack.org>; Fri, 4 Aug 2006 17:16:21 +0200
Received: (from hch@localhost)
	by verein.lst.de (8.12.3/8.12.3/Debian-6.6) id k74FGLfg029596
	for linux-mm@kvack.org; Fri, 4 Aug 2006 17:16:21 +0200
Date: Fri, 4 Aug 2006 17:16:21 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [hch: [PATCH 1/3] slab: clean up leak tracking ifdefs a little bit]
Message-ID: <20060804151621.GD29422@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

----- Forwarded message from Christoph Hellwig <hch> -----

Date: Fri, 4 Aug 2006 17:15:30 +0200
From: Christoph Hellwig <hch>
Subject: [PATCH 1/3] slab: clean up leak tracking ifdefs a little bit
To: akpm@osdl.org, viro@zeniv.linux.org.uk
Cc: linux-mm@vger.kernel.org

 - rename ____kmalloc to kmalloc_track_caller so that people have
   a chance to guess what it does just from it's name.  Add a comment
   describing it for those who don't.  Also move it after kmalloc in
   slab.h so people get less confused when they are just looking for
   kmalloc
 - move things around in slab.c a little to reduce the ifdef mess.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2006-07-26 15:24:10.000000000 +0200
+++ linux-2.6/include/linux/slab.h	2006-07-26 15:30:49.000000000 +0200
@@ -78,13 +78,6 @@
 extern struct cache_sizes malloc_sizes[];
 
 extern void *__kmalloc(size_t, gfp_t);
-#ifndef CONFIG_DEBUG_SLAB
-#define ____kmalloc(size, flags) __kmalloc(size, flags)
-#else
-extern void *__kmalloc_track_caller(size_t, gfp_t, void*);
-#define ____kmalloc(size, flags) \
-    __kmalloc_track_caller(size, flags, __builtin_return_address(0))
-#endif
 
 /**
  * kmalloc - allocate memory
@@ -154,6 +147,23 @@
 	return __kmalloc(size, flags);
 }
 
+/*
+ * kmalloc_track_caller is a special version of kmalloc that records the
+ * calling function of the routine calling it for slab leak tracking instead
+ * of just the calling function (confusing, eh?).
+ * It's useful when the call to kmalloc comes from a widely-used standard
+ * allocator where we care about the real place the memory allocation
+ * request comes from.
+ */
+#ifndef CONFIG_DEBUG_SLAB
+#define kmalloc_track_caller(size, flags) \
+	__kmalloc(size, flags)
+#else
+extern void *__kmalloc_track_caller(size_t, gfp_t, void*);
+#define kmalloc_track_caller(size, flags) \
+	__kmalloc_track_caller(size, flags, __builtin_return_address(0))
+#endif
+
 extern void *__kzalloc(size_t, gfp_t);
 
 /**
@@ -250,7 +260,7 @@
 #define kmem_cache_alloc_node(c, f, n) kmem_cache_alloc(c, f)
 #define kmalloc_node(s, f, n) kmalloc(s, f)
 #define kzalloc(s, f) __kzalloc(s, f)
-#define ____kmalloc kmalloc
+#define kmalloc_track_caller kmalloc
 
 #endif /* CONFIG_SLOB */
 
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2006-07-26 15:24:10.000000000 +0200
+++ linux-2.6/mm/slab.c	2006-07-26 15:25:28.000000000 +0200
@@ -3352,22 +3352,25 @@
 }
 
 
+#ifndef CONFIG_DEBUG_SLAB
 void *__kmalloc(size_t size, gfp_t flags)
 {
-#ifndef CONFIG_DEBUG_SLAB
-	return __do_kmalloc(size, flags, NULL);
-#else
 	return __do_kmalloc(size, flags, __builtin_return_address(0));
-#endif
 }
 EXPORT_SYMBOL(__kmalloc);
 
-#ifdef CONFIG_DEBUG_SLAB
 void *__kmalloc_track_caller(size_t size, gfp_t flags, void *caller)
 {
 	return __do_kmalloc(size, flags, caller);
 }
 EXPORT_SYMBOL(__kmalloc_track_caller);
+
+#else
+void *__kmalloc(size_t size, gfp_t flags)
+{
+	return __do_kmalloc(size, flags, NULL);
+}
+EXPORT_SYMBOL(__kmalloc);
 #endif
 
 #ifdef CONFIG_SMP
Index: linux-2.6/mm/util.c
===================================================================
--- linux-2.6.orig/mm/util.c	2006-04-04 16:50:13.000000000 +0200
+++ linux-2.6/mm/util.c	2006-07-26 15:25:55.000000000 +0200
@@ -11,7 +11,7 @@
  */
 void *__kzalloc(size_t size, gfp_t flags)
 {
-	void *ret = ____kmalloc(size, flags);
+	void *ret = kmalloc_track_caller(size, flags);
 	if (ret)
 		memset(ret, 0, size);
 	return ret;
@@ -33,7 +33,7 @@
 		return NULL;
 
 	len = strlen(s) + 1;
-	buf = ____kmalloc(len, gfp);
+	buf = kmalloc_track_caller(len, gfp);
 	if (buf)
 		memcpy(buf, s, len);
 	return buf;
Index: linux-2.6/net/core/skbuff.c
===================================================================
--- linux-2.6.orig/net/core/skbuff.c	2006-07-26 13:27:21.000000000 +0200
+++ linux-2.6/net/core/skbuff.c	2006-07-26 15:37:11.000000000 +0200
@@ -163,7 +163,8 @@
 
 	/* Get the DATA. Size must match skb_add_mtu(). */
 	size = SKB_DATA_ALIGN(size);
-	data = ____kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
+	data = kmalloc_track_caller(size + sizeof(struct skb_shared_info),
+			gfp_mask);
 	if (!data)
 		goto nodata;
 

----- End forwarded message -----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
