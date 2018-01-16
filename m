Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 08DED28024A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 16:38:35 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id v25so12609182pfg.14
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:38:35 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id r5si2868520plj.687.2018.01.16.13.38.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Jan 2018 13:38:33 -0800 (PST)
Date: Tue, 16 Jan 2018 13:38:33 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: [RFC] kvzalloc_hdr_arr()
Message-ID: <20180116213833.GB7791@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: keithp@keithp.com


I'd like to thank Keith Packard for offering suggestions on this version.
I've included a couple of conversions, just so you can see how it looks
from a user point of view.

diff --git a/drivers/media/v4l2-core/v4l2-event.c b/drivers/media/v4l2-core/v4l2-event.c
index 968c2eb08b5a..1dc4d2185a7a 100644
--- a/drivers/media/v4l2-core/v4l2-event.c
+++ b/drivers/media/v4l2-core/v4l2-event.c
@@ -215,8 +215,7 @@ int v4l2_event_subscribe(struct v4l2_fh *fh,
 	if (elems < 1)
 		elems = 1;
 
-	sev = kvzalloc(sizeof(*sev) + sizeof(struct v4l2_kevent) * elems,
-		       GFP_KERNEL);
+	sev = kvzalloc_hdr_arr(sev, events, elems, GFP_KERNEL);
 	if (!sev)
 		return -ENOMEM;
 	for (i = 0; i < elems; i++)
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 33ac2b186b85..c6c5e839fca4 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1292,7 +1292,7 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
 		return -EOPNOTSUPP;
 	if (mem.nregions > max_mem_regions)
 		return -E2BIG;
-	newmem = kvzalloc(size + mem.nregions * sizeof(*m->regions), GFP_KERNEL);
+	newmem = kvzalloc_hdr_arr(newmem, regions, mem.nregions, GFP_KERNEL);
 	if (!newmem)
 		return -ENOMEM;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index fe1ee4313add..46ee6bac61a0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -557,6 +557,31 @@ static inline void *kvmalloc_array(size_t n, size_t size, gfp_t flags)
 	return kvmalloc(n * size, flags);
 }
 
+static inline void *kvzalloc_ab_c(size_t n, size_t size, size_t c, gfp_t flags)
+{
+	if (size != 0 && n > (SIZE_MAX - c) / size)
+		return NULL;
+
+	return kvzalloc(n * size + c, flags);
+}
+
+/**
+ * kvzalloc_hdr_arr() - Allocate a zero-filled array with a header.
+ * @p: Pointer to the header.
+ * @member: Name of the array member.
+ * @n: Number of elements in the array.
+ * @gfp: Memory allocation flags.
+ *
+ * Allocate (and zero-fill) enough memory for a structure with an array
+ * of @n elements.
+ *
+ * Return: Zero-filled memory or a NULL pointer.
+ */
+#define kvzalloc_hdr_arr(p, member, n, gfp)				\
+	(typeof(p))kvzalloc_ab_c(n,					\
+		sizeof(*(p)->member) + __must_be_array((p)->member),	\
+		offsetof(typeof(*(p)), member), gfp)
+
 extern void kvfree(const void *addr);
 
 static inline atomic_t *compound_mapcount_ptr(struct page *page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
