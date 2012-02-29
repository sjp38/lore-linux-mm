Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id B2DD46B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 09:07:06 -0500 (EST)
Received: by werj55 with SMTP id j55so2567103wer.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 06:07:05 -0800 (PST)
MIME-Version: 1.0
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH] mm: extend prefault helpers to fault in more than PAGE_SIZE
Date: Wed, 29 Feb 2012 15:03:31 +0100
Message-Id: <1330524211-2698-1-git-send-email-daniel.vetter@ffwll.ch>
In-Reply-To: <20120224124003.93780408.akpm@linux-foundation.org>
References: <20120224124003.93780408.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Daniel Vetter <daniel.vetter@ffwll.ch>

drm/i915 wants to read/write more than one page in its fastpath
and hence needs to prefault more than PAGE_SIZE bytes.

I've checked the callsites and they all already clamp size when
calling fault_in_pages_* to the same as for the subsequent
__copy_to|from_user and hence don't rely on the implicit clamping
to PAGE_SIZE.

Also kill a copy&pasted spurious space in both functions while at it.

v2: As suggested by Andrew Morton, add a multipage parameter to both
functions to avoid the additional branch for the pagemap.c hotpath.
My gcc 4.6 here seems to dtrt and indeed reap these branches where not
needed.

Cc: linux-mm@kvack.org
Signed-off-by: Daniel Vetter <daniel.vetter@ffwll.ch>
---
 drivers/gpu/drm/i915/i915_gem.c            |    4 +-
 drivers/gpu/drm/i915/i915_gem_execbuffer.c |    2 +-
 fs/pipe.c                                  |    4 +-
 fs/splice.c                                |    2 +-
 include/linux/pagemap.h                    |   39 ++++++++++++++++++---------
 mm/filemap.c                               |    4 +-
 6 files changed, 34 insertions(+), 21 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 544e528..9b200f4e 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -436,7 +436,7 @@ i915_gem_shmem_pread(struct drm_device *dev,
 		mutex_unlock(&dev->struct_mutex);
 
 		if (!prefaulted) {
-			ret = fault_in_pages_writeable(user_data, remain);
+			ret = fault_in_pages_writeable(user_data, remain, true);
 			/* Userspace is tricking us, but we've already clobbered
 			 * its pages with the prefault and promised to write the
 			 * data up to the first fault. Hence ignore any errors
@@ -823,7 +823,7 @@ i915_gem_pwrite_ioctl(struct drm_device *dev, void *data,
 		return -EFAULT;
 
 	ret = fault_in_pages_readable((char __user *)(uintptr_t)args->data_ptr,
-				      args->size);
+				      args->size, true);
 	if (ret)
 		return -EFAULT;
 
diff --git a/drivers/gpu/drm/i915/i915_gem_execbuffer.c b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
index 81687af..5f0b685 100644
--- a/drivers/gpu/drm/i915/i915_gem_execbuffer.c
+++ b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
@@ -955,7 +955,7 @@ validate_exec_list(struct drm_i915_gem_exec_object2 *exec,
 		if (!access_ok(VERIFY_WRITE, ptr, length))
 			return -EFAULT;
 
-		if (fault_in_pages_readable(ptr, length))
+		if (fault_in_pages_readable(ptr, length, true))
 			return -EFAULT;
 	}
 
diff --git a/fs/pipe.c b/fs/pipe.c
index a932ced..b29f71c 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -167,7 +167,7 @@ static int iov_fault_in_pages_write(struct iovec *iov, unsigned long len)
 		unsigned long this_len;
 
 		this_len = min_t(unsigned long, len, iov->iov_len);
-		if (fault_in_pages_writeable(iov->iov_base, this_len))
+		if (fault_in_pages_writeable(iov->iov_base, this_len, false))
 			break;
 
 		len -= this_len;
@@ -189,7 +189,7 @@ static void iov_fault_in_pages_read(struct iovec *iov, unsigned long len)
 		unsigned long this_len;
 
 		this_len = min_t(unsigned long, len, iov->iov_len);
-		fault_in_pages_readable(iov->iov_base, this_len);
+		fault_in_pages_readable(iov->iov_base, this_len, false);
 		len -= this_len;
 		iov++;
 	}
diff --git a/fs/splice.c b/fs/splice.c
index 1ec0493..e919d78 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1491,7 +1491,7 @@ static int pipe_to_user(struct pipe_inode_info *pipe, struct pipe_buffer *buf,
 	 * See if we can use the atomic maps, by prefaulting in the
 	 * pages and doing an atomic copy
 	 */
-	if (!fault_in_pages_writeable(sd->u.userptr, sd->len)) {
+	if (!fault_in_pages_writeable(sd->u.userptr, sd->len, false)) {
 		src = buf->ops->map(pipe, buf, 1);
 		ret = __copy_to_user_inatomic(sd->u.userptr, src + buf->offset,
 							sd->len);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index cfaaa69..60ac5c5 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -403,11 +403,14 @@ extern void add_page_wait_queue(struct page *page, wait_queue_t *waiter);
  * Fault a userspace page into pagetables.  Return non-zero on a fault.
  *
  * This assumes that two userspace pages are always sufficient.  That's
- * not true if PAGE_CACHE_SIZE > PAGE_SIZE.
+ * not true if PAGE_CACHE_SIZE > PAGE_SIZE. If more than PAGE_SIZE needs to be
+ * prefaulted, set multipage to true.
  */
-static inline int fault_in_pages_writeable(char __user *uaddr, int size)
+static inline int fault_in_pages_writeable(char __user *uaddr, int size,
+					   bool multipage)
 {
 	int ret;
+	char __user *end = uaddr + size - 1;
 
 	if (unlikely(size == 0))
 		return 0;
@@ -416,36 +419,46 @@ static inline int fault_in_pages_writeable(char __user *uaddr, int size)
 	 * Writing zeroes into userspace here is OK, because we know that if
 	 * the zero gets there, we'll be overwriting it.
 	 */
-	ret = __put_user(0, uaddr);
-	if (ret == 0) {
-		char __user *end = uaddr + size - 1;
+	do {
+		ret = __put_user(0, uaddr);
+		if (ret != 0)
+			return ret;
+		uaddr += PAGE_SIZE;
+	} while (multipage && uaddr <= end);
 
+	if (ret == 0) {
 		/*
 		 * If the page was already mapped, this will get a cache miss
 		 * for sure, so try to avoid doing it.
 		 */
-		if (((unsigned long)uaddr & PAGE_MASK) !=
+		if (((unsigned long)uaddr & PAGE_MASK) ==
 				((unsigned long)end & PAGE_MASK))
-		 	ret = __put_user(0, end);
+			ret = __put_user(0, end);
 	}
 	return ret;
 }
 
-static inline int fault_in_pages_readable(const char __user *uaddr, int size)
+static inline int fault_in_pages_readable(const char __user *uaddr, int size,
+					  bool multipage)
 {
 	volatile char c;
 	int ret;
+	const char __user *end = uaddr + size - 1;
 
 	if (unlikely(size == 0))
 		return 0;
 
-	ret = __get_user(c, uaddr);
-	if (ret == 0) {
-		const char __user *end = uaddr + size - 1;
+	do {
+		ret = __get_user(c, uaddr);
+		if (ret != 0)
+			return ret;
+		uaddr += PAGE_SIZE;
+	} while (multipage && uaddr <= end);
 
-		if (((unsigned long)uaddr & PAGE_MASK) !=
+	if (ret == 0) {
+		if (((unsigned long)uaddr & PAGE_MASK) ==
 				((unsigned long)end & PAGE_MASK)) {
-		 	ret = __get_user(c, end);
+			ret = __get_user(c, end);
 			(void)c;
 		}
 	}
diff --git a/mm/filemap.c b/mm/filemap.c
index 97f49ed..af2cad5 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1317,7 +1317,7 @@ int file_read_actor(read_descriptor_t *desc, struct page *page,
 	 * Faults on the destination of a read are common, so do it before
 	 * taking the kmap.
 	 */
-	if (!fault_in_pages_writeable(desc->arg.buf, size)) {
+	if (!fault_in_pages_writeable(desc->arg.buf, size, false)) {
 		kaddr = kmap_atomic(page, KM_USER0);
 		left = __copy_to_user_inatomic(desc->arg.buf,
 						kaddr + offset, size);
@@ -2138,7 +2138,7 @@ int iov_iter_fault_in_readable(struct iov_iter *i, size_t bytes)
 {
 	char __user *buf = i->iov->iov_base + i->iov_offset;
 	bytes = min(bytes, i->iov->iov_len - i->iov_offset);
-	return fault_in_pages_readable(buf, bytes);
+	return fault_in_pages_readable(buf, bytes, false);
 }
 EXPORT_SYMBOL(iov_iter_fault_in_readable);
 
-- 
1.7.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
