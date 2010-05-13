Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 700DE6B0206
	for <linux-mm@kvack.org>; Thu, 13 May 2010 05:52:01 -0400 (EDT)
Received: by pzk28 with SMTP id 28so1203229pzk.11
        for <linux-mm@kvack.org>; Thu, 13 May 2010 02:51:59 -0700 (PDT)
From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 1/9] mm: add generic adaptive large memory allocation APIs
Date: Thu, 13 May 2010 17:51:25 +0800
Message-Id: <1273744285-8128-1-git-send-email-xiaosuo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Hoang-Nam Nguyen <hnguyen@de.ibm.com>, Christoph Raisch <raisch@de.ibm.com>, Roland Dreier <rolandd@cisco.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Divy Le Ray <divy@chelsio.com>, "James E.J. Bottomley" <James.Bottomley@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@sun.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, Eric Dumazet <eric.dumazet@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Peter Zijlstra <peterz@infradead.org>, Changli Gao <xiaosuo@gmail.com>
List-ID: <linux-mm.kvack.org>

generic adaptive large memory allocation APIs

kv*alloc are used to allocate large contiguous memory and the users don't mind
whether the memory is physically or virtually contiguous. The allocator always
try its best to allocate physically contiguous memory first.

In this patch set, some APIs are introduced: kvmalloc(), kvzalloc(), kvcalloc(),
kvrealloc(), kvfree() and kvfree_inatomic().

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/linux/mm.h      |   31 ++++++++++++++
 include/linux/vmalloc.h |    1 
 mm/nommu.c              |    6 ++
 mm/util.c               |  104 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/vmalloc.c            |   14 ++++++
 5 files changed, 156 insertions(+)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 462acaf..0ece978 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1467,5 +1467,36 @@ extern int soft_offline_page(struct page *page, int flags);
 
 extern void dump_page(struct page *page);
 
+void *__kvmalloc(size_t size, gfp_t flags);
+
+static inline void *kvmalloc(size_t size)
+{
+	return __kvmalloc(size, 0);
+}
+
+static inline void *kvzalloc(size_t size)
+{
+	return __kvmalloc(size, __GFP_ZERO);
+}
+
+static inline void *kvcalloc(size_t n, size_t size)
+{
+	return __kvmalloc(n * size, __GFP_ZERO);
+}
+
+void __kvfree(void *ptr, bool inatomic);
+
+static inline void kvfree(void *ptr)
+{
+	__kvfree(ptr, false);
+}
+
+static inline void kvfree_inatomic(void *ptr)
+{
+	__kvfree(ptr, true);
+}
+
+void *kvrealloc(void *ptr, size_t newsize);
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 227c2a5..33ec828 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -60,6 +60,7 @@ extern void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot);
 extern void *__vmalloc_area(struct vm_struct *area, gfp_t gfp_mask,
 				pgprot_t prot);
 extern void vfree(const void *addr);
+extern unsigned long vsize(const void *addr);
 
 extern void *vmap(struct page **pages, unsigned int count,
 			unsigned long flags, pgprot_t prot);
diff --git a/mm/nommu.c b/mm/nommu.c
index 63fa17d..1ddf3fe 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -223,6 +223,12 @@ void vfree(const void *addr)
 }
 EXPORT_SYMBOL(vfree);
 
+unsigned long vsize(const void *addr)
+{
+	return ksize(addr);
+}
+EXPORT_SYMBOL(vsize);
+
 void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
 {
 	/*
diff --git a/mm/util.c b/mm/util.c
index f5712e8..7cc364a 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -5,6 +5,7 @@
 #include <linux/err.h>
 #include <linux/sched.h>
 #include <asm/uaccess.h>
+#include <linux/vmalloc.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/kmem.h>
@@ -289,6 +290,109 @@ int __attribute__((weak)) get_user_pages_fast(unsigned long start,
 }
 EXPORT_SYMBOL_GPL(get_user_pages_fast);
 
+void *__kvmalloc(size_t size, gfp_t flags)
+{
+	void *ptr;
+
+	if (size < PAGE_SIZE)
+		return kmalloc(size, GFP_KERNEL | flags);
+	size = PAGE_ALIGN(size);
+	if (is_power_of_2(size))
+		ptr = (void *)__get_free_pages(GFP_KERNEL | flags |
+					       __GFP_NOWARN, get_order(size));
+	else
+		ptr = alloc_pages_exact(size, GFP_KERNEL | flags |
+					      __GFP_NOWARN);
+	if (ptr != NULL) {
+		virt_to_head_page(ptr)->private = size;
+		return ptr;
+	}
+
+	ptr = vmalloc(size);
+	if (ptr != NULL && (flags & __GFP_ZERO))
+		memset(ptr, 0, size);
+
+	return ptr;
+}
+EXPORT_SYMBOL(__kvmalloc);
+
+static void kvfree_work(struct work_struct *work)
+{
+	vfree(work);
+}
+
+void __kvfree(void *ptr, bool inatomic)
+{
+	if (unlikely(ZERO_OR_NULL_PTR(ptr)))
+		return;
+	if (is_vmalloc_addr(ptr)) {
+		if (inatomic) {
+			struct work_struct *work;
+
+			work = ptr;
+			BUILD_BUG_ON(sizeof(struct work_struct) > PAGE_SIZE);
+			INIT_WORK(work, kvfree_work);
+			schedule_work(work);
+		} else {
+			vfree(ptr);
+		}
+	} else {
+		struct page *page;
+
+		page = virt_to_head_page(ptr);
+		if (PageSlab(page) || PageCompound(page))
+			kfree(ptr);
+		else if (is_power_of_2(page->private))
+			free_pages((unsigned long)ptr,
+				   get_order(page->private));
+		else
+			free_pages_exact(ptr, page->private);
+	}
+}
+EXPORT_SYMBOL(__kvfree);
+
+void *kvrealloc(void *ptr, size_t newsize)
+{
+	void *nptr;
+	size_t oldsize;
+
+	if (unlikely(!newsize)) {
+		kvfree(ptr);
+		return ZERO_SIZE_PTR;
+	}
+
+	if (unlikely(ZERO_OR_NULL_PTR(ptr)))
+		return kvmalloc(newsize);
+
+	if (is_vmalloc_addr(ptr)) {
+		oldsize = vsize(ptr);
+		if (newsize <= oldsize)
+			return ptr;
+	} else {
+		struct page *page;
+
+		page = virt_to_head_page(ptr);
+		if (PageSlab(page) || PageCompound(page)) {
+			if (newsize < PAGE_SIZE)
+				return krealloc(ptr, newsize, GFP_KERNEL);
+			oldsize = ksize(ptr);
+		} else {
+			oldsize = page->private;
+			if (newsize <= oldsize)
+				return ptr;
+		}
+	}
+
+	nptr = kvmalloc(newsize);
+	if (nptr != NULL) {
+		memcpy(nptr, ptr, oldsize);
+		kvfree(ptr);
+	}
+
+	return nptr;
+}
+EXPORT_SYMBOL(kvrealloc);
+
 /* Tracepoints definitions. */
 EXPORT_TRACEPOINT_SYMBOL(kmalloc);
 EXPORT_TRACEPOINT_SYMBOL(kmem_cache_alloc);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ae00746..93552a8 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1413,6 +1413,20 @@ void vfree(const void *addr)
 EXPORT_SYMBOL(vfree);
 
 /**
+ *	vsize  -  get the actual amount of memory allocated by vmalloc()
+ *	@addr:		memory base address
+ */
+unsigned long vsize(const void *addr)
+{
+	struct vmap_area *va;
+
+	va = find_vmap_area((unsigned long)addr);
+
+	return va->va_end - va->va_start - PAGE_SIZE;
+}
+EXPORT_SYMBOL(vsize);
+
+/**
  *	vunmap  -  release virtual mapping obtained by vmap()
  *	@addr:		memory base address
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
