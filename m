Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id EB6296B002C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 14:26:35 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so91504wgb.26
        for <linux-mm@kvack.org>; Thu, 01 Mar 2012 11:26:34 -0800 (PST)
MIME-Version: 1.0
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH] mm: extend prefault helpers to fault in more than PAGE_SIZE
Date: Thu,  1 Mar 2012 20:22:59 +0100
Message-Id: <1330629779-1449-1-git-send-email-daniel.vetter@ffwll.ch>
In-Reply-To: <20120229153216.8c3ae31d.akpm@linux-foundation.org>
References: <20120229153216.8c3ae31d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Daniel Vetter <daniel.vetter@ffwll.ch>

drm/i915 wants to read/write more than one page in its fastpath
and hence needs to prefault more than PAGE_SIZE bytes.

Add new functions in filemap.h to make that possible.

Also kill a copy&pasted spurious space in both functions while at it.

v2: As suggested by Andrew Morton, add a multipage parameter to both
functions to avoid the additional branch for the pagemap.c hotpath.
My gcc 4.6 here seems to dtrt and indeed reap these branches where not
needed.

v3: Becaus I couldn't find a way around adding a uaddr += PAGE_SIZE to
the filemap.c hotpaths (that the compiler couldn't remove again),
let's go with separate new functions for the multipage use-case.

Cc: linux-mm@kvack.org
Signed-off-by: Daniel Vetter <daniel.vetter@ffwll.ch>
---
 drivers/gpu/drm/i915/i915_gem.c            |    6 +-
 drivers/gpu/drm/i915/i915_gem_execbuffer.c |    2 +-
 include/linux/pagemap.h                    |   62 +++++++++++++++++++++++++++-
 3 files changed, 64 insertions(+), 6 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 544e528..3e631fc 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -436,7 +436,7 @@ i915_gem_shmem_pread(struct drm_device *dev,
 		mutex_unlock(&dev->struct_mutex);
 
 		if (!prefaulted) {
-			ret = fault_in_pages_writeable(user_data, remain);
+			ret = fault_in_multipages_writeable(user_data, remain);
 			/* Userspace is tricking us, but we've already clobbered
 			 * its pages with the prefault and promised to write the
 			 * data up to the first fault. Hence ignore any errors
@@ -822,8 +822,8 @@ i915_gem_pwrite_ioctl(struct drm_device *dev, void *data,
 		       args->size))
 		return -EFAULT;
 
-	ret = fault_in_pages_readable((char __user *)(uintptr_t)args->data_ptr,
-				      args->size);
+	ret = fault_in_multipages_readable((char __user *)(uintptr_t)args->data_ptr,
+					   args->size);
 	if (ret)
 		return -EFAULT;
 
diff --git a/drivers/gpu/drm/i915/i915_gem_execbuffer.c b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
index 81687af..ef87f52 100644
--- a/drivers/gpu/drm/i915/i915_gem_execbuffer.c
+++ b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
@@ -955,7 +955,7 @@ validate_exec_list(struct drm_i915_gem_exec_object2 *exec,
 		if (!access_ok(VERIFY_WRITE, ptr, length))
 			return -EFAULT;
 
-		if (fault_in_pages_readable(ptr, length))
+		if (fault_in_multipages_readable(ptr, length))
 			return -EFAULT;
 	}
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index cfaaa69..0a91375 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -426,7 +426,7 @@ static inline int fault_in_pages_writeable(char __user *uaddr, int size)
 		 */
 		if (((unsigned long)uaddr & PAGE_MASK) !=
 				((unsigned long)end & PAGE_MASK))
-		 	ret = __put_user(0, end);
+			ret = __put_user(0, end);
 	}
 	return ret;
 }
@@ -445,13 +445,71 @@ static inline int fault_in_pages_readable(const char __user *uaddr, int size)
 
 		if (((unsigned long)uaddr & PAGE_MASK) !=
 				((unsigned long)end & PAGE_MASK)) {
-		 	ret = __get_user(c, end);
+			ret = __get_user(c, end);
 			(void)c;
 		}
 	}
 	return ret;
 }
 
+/* Multipage variants of the above prefault helpers, useful if more than
+ * PAGE_SIZE of date needs to be prefaulted. These are separate from the above
+ * functions (which only handle up to PAGE_SIZE) to avoid clobbering the
+ * filemap.c hotpaths. */
+static inline int fault_in_multipages_writeable(char __user *uaddr, int size)
+{
+	int ret;
+	const char __user *end = uaddr + size - 1;
+
+	if (unlikely(size == 0))
+		return 0;
+
+	/*
+	 * Writing zeroes into userspace here is OK, because we know that if
+	 * the zero gets there, we'll be overwriting it.
+	 */
+	while (uaddr <= end) {
+		ret = __put_user(0, uaddr);
+		if (ret != 0)
+			return ret;
+		uaddr += PAGE_SIZE;
+	}
+
+	/* Check whether the range spilled into the next page. */
+	if (((unsigned long)uaddr & PAGE_MASK) ==
+			((unsigned long)end & PAGE_MASK))
+		ret = __put_user(0, end);
+
+	return ret;
+}
+
+static inline int fault_in_multipages_readable(const char __user *uaddr,
+					       int size)
+{
+	volatile char c;
+	int ret;
+	const char __user *end = uaddr + size - 1;
+
+	if (unlikely(size == 0))
+		return 0;
+
+	while (uaddr <= end) {
+		ret = __get_user(c, uaddr);
+		if (ret != 0)
+			return ret;
+		uaddr += PAGE_SIZE;
+	}
+
+	/* Check whether the range spilled into the next page. */
+	if (((unsigned long)uaddr & PAGE_MASK) ==
+			((unsigned long)end & PAGE_MASK)) {
+		ret = __get_user(c, end);
+		(void)c;
+	}
+
+	return ret;
+}
+
 int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
