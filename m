Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 55B236B0256
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 11:10:12 -0400 (EDT)
Received: by qkbp125 with SMTP id p125so141780088qkb.2
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 08:10:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j130si25190280qhc.51.2015.07.07.08.10.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 08:10:11 -0700 (PDT)
Date: Tue, 7 Jul 2015 11:10:09 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH 2/7] mm: introduce kvmalloc and kvmalloc_node
In-Reply-To: <alpine.LRH.2.02.1507071058350.23387@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.LRH.2.02.1507071109490.23387@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1507071058350.23387@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <msnitzer@redhat.com>
Cc: "Alasdair G. Kergon" <agk@redhat.com>, Edward Thornber <thornber@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Vivek Goyal <vgoyal@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com

Introduce the functions kvmalloc and kvmalloc_node. These functions
provide reliable allocation of object of arbitrary size. They attempt to
do allocation with kmalloc and if it fails, use vmalloc. Memory allocated
with these functions should be freed with kvfree.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 include/linux/mm.h |    2 ++
 mm/util.c          |   37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+)

Index: linux-4.2-rc1/include/linux/mm.h
===================================================================
--- linux-4.2-rc1.orig/include/linux/mm.h	2015-07-07 15:54:36.000000000 +0200
+++ linux-4.2-rc1/include/linux/mm.h	2015-07-07 15:54:58.000000000 +0200
@@ -400,6 +400,8 @@ static inline int is_vmalloc_or_module_a
 }
 #endif
 
+extern void *kvmalloc_node(size_t size, gfp_t gfp, int node);
+extern void *kvmalloc(size_t size, gfp_t gfp);
 extern void kvfree(const void *addr);
 
 static inline void compound_lock(struct page *page)
Index: linux-4.2-rc1/mm/util.c
===================================================================
--- linux-4.2-rc1.orig/mm/util.c	2015-07-07 15:52:37.000000000 +0200
+++ linux-4.2-rc1/mm/util.c	2015-07-07 15:54:06.000000000 +0200
@@ -316,6 +316,43 @@ unsigned long vm_mmap(struct file *file,
 }
 EXPORT_SYMBOL(vm_mmap);
 
+void *kvmalloc_node(size_t size, gfp_t gfp, int node)
+{
+	void *p;
+	unsigned uninitialized_var(noio_flag);
+
+	/* vmalloc doesn't support no-wait allocations */
+	WARN_ON(!(gfp & __GFP_WAIT));
+
+	if (likely(size <= KMALLOC_MAX_SIZE)) {
+		p = kmalloc_node(size, gfp | __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN, node);
+		if (likely(p != NULL))
+			return p;
+	}
+	if ((gfp & (__GFP_IO | __GFP_FS)) != (__GFP_IO | __GFP_FS)) {
+		/*
+		 * vmalloc allocates page tables with GFP_KERNEL, regardless
+		 * of GFP flags passed to it. If we are no GFP_NOIO context,
+		 * we call memalloc_noio_save, so that all allocations are
+		 * implicitly done with GFP_NOIO.
+		 */
+		noio_flag = memalloc_noio_save();
+		gfp |= __GFP_HIGH;
+	}
+	p = __vmalloc_node_flags(size, node, gfp | __GFP_REPEAT | __GFP_HIGHMEM);
+	if ((gfp & (__GFP_IO | __GFP_FS)) != (__GFP_IO | __GFP_FS)) {
+		memalloc_noio_restore(noio_flag);
+	}
+	return p;
+}
+EXPORT_SYMBOL(kvmalloc_node);
+
+void *kvmalloc(size_t size, gfp_t gfp)
+{
+	return kvmalloc_node(size, gfp, NUMA_NO_NODE);
+}
+EXPORT_SYMBOL(kvmalloc);
+
 void kvfree(const void *addr)
 {
 	if (is_vmalloc_addr(addr))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
