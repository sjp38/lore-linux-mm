Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9FC4D6B0078
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 22:09:33 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBG39UL5031840
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 12:09:30 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5752B45DE52
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:09:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 311B545DE50
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:09:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 13DDE1DB803A
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:09:30 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AFE951DB8040
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:09:29 +0900 (JST)
Date: Wed, 16 Dec 2009 12:06:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mm][RFC][PATCH 6/11] mm accessor for driver/gpu
Message-Id: <20091216120624.acd9fd30.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, andi@firstfloor.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

Replacing mmap_sem with mm_accessor, for GPU drivers.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 drivers/gpu/drm/drm_bufs.c        |    8 ++++----
 drivers/gpu/drm/i810/i810_dma.c   |    8 ++++----
 drivers/gpu/drm/i830/i830_dma.c   |    8 ++++----
 drivers/gpu/drm/i915/i915_gem.c   |   16 ++++++++--------
 drivers/gpu/drm/ttm/ttm_tt.c      |    4 ++--
 drivers/gpu/drm/via/via_dmablit.c |    4 ++--
 6 files changed, 24 insertions(+), 24 deletions(-)

Index: mmotm-mm-accessor/drivers/gpu/drm/drm_bufs.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/gpu/drm/drm_bufs.c
+++ mmotm-mm-accessor/drivers/gpu/drm/drm_bufs.c
@@ -1574,18 +1574,18 @@ int drm_mapbufs(struct drm_device *dev, 
 				retcode = -EINVAL;
 				goto done;
 			}
-			down_write(&current->mm->mmap_sem);
+			mm_write_lock(current->mm);
 			virtual = do_mmap(file_priv->filp, 0, map->size,
 					  PROT_READ | PROT_WRITE,
 					  MAP_SHARED,
 					  token);
-			up_write(&current->mm->mmap_sem);
+			mm_write_unlock(current->mm);
 		} else {
-			down_write(&current->mm->mmap_sem);
+			mm_write_lock(current->mm);
 			virtual = do_mmap(file_priv->filp, 0, dma->byte_count,
 					  PROT_READ | PROT_WRITE,
 					  MAP_SHARED, 0);
-			up_write(&current->mm->mmap_sem);
+			mm_write_unlock(current->mm);
 		}
 		if (virtual > -1024UL) {
 			/* Real error */
Index: mmotm-mm-accessor/drivers/gpu/drm/i810/i810_dma.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/gpu/drm/i810/i810_dma.c
+++ mmotm-mm-accessor/drivers/gpu/drm/i810/i810_dma.c
@@ -131,7 +131,7 @@ static int i810_map_buffer(struct drm_bu
 	if (buf_priv->currently_mapped == I810_BUF_MAPPED)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	old_fops = file_priv->filp->f_op;
 	file_priv->filp->f_op = &i810_buffer_fops;
 	dev_priv->mmap_buffer = buf;
@@ -146,7 +146,7 @@ static int i810_map_buffer(struct drm_bu
 		retcode = PTR_ERR(buf_priv->virtual);
 		buf_priv->virtual = NULL;
 	}
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 
 	return retcode;
 }
@@ -159,11 +159,11 @@ static int i810_unmap_buffer(struct drm_
 	if (buf_priv->currently_mapped != I810_BUF_MAPPED)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	retcode = do_munmap(current->mm,
 			    (unsigned long)buf_priv->virtual,
 			    (size_t) buf->total);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 
 	buf_priv->currently_mapped = I810_BUF_UNMAPPED;
 	buf_priv->virtual = NULL;
Index: mmotm-mm-accessor/drivers/gpu/drm/ttm/ttm_tt.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/gpu/drm/ttm/ttm_tt.c
+++ mmotm-mm-accessor/drivers/gpu/drm/ttm/ttm_tt.c
@@ -359,10 +359,10 @@ int ttm_tt_set_user(struct ttm_tt *ttm,
 	if (unlikely(ret != 0))
 		return ret;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	ret = get_user_pages(tsk, mm, start, num_pages,
 			     write, 0, ttm->pages, NULL);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 
 	if (ret != num_pages && write) {
 		ttm_tt_free_user_pages(ttm);
Index: mmotm-mm-accessor/drivers/gpu/drm/i915/i915_gem.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/gpu/drm/i915/i915_gem.c
+++ mmotm-mm-accessor/drivers/gpu/drm/i915/i915_gem.c
@@ -398,10 +398,10 @@ i915_gem_shmem_pread_slow(struct drm_dev
 	if (user_pages == NULL)
 		return -ENOMEM;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	pinned_pages = get_user_pages(current, mm, (uintptr_t)args->data_ptr,
 				      num_pages, 1, 0, user_pages, NULL);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	if (pinned_pages < num_pages) {
 		ret = -EFAULT;
 		goto fail_put_user_pages;
@@ -698,10 +698,10 @@ i915_gem_gtt_pwrite_slow(struct drm_devi
 	if (user_pages == NULL)
 		return -ENOMEM;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	pinned_pages = get_user_pages(current, mm, (uintptr_t)args->data_ptr,
 				      num_pages, 0, 0, user_pages, NULL);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	if (pinned_pages < num_pages) {
 		ret = -EFAULT;
 		goto out_unpin_pages;
@@ -873,10 +873,10 @@ i915_gem_shmem_pwrite_slow(struct drm_de
 	if (user_pages == NULL)
 		return -ENOMEM;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	pinned_pages = get_user_pages(current, mm, (uintptr_t)args->data_ptr,
 				      num_pages, 0, 0, user_pages, NULL);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	if (pinned_pages < num_pages) {
 		ret = -EFAULT;
 		goto fail_put_user_pages;
@@ -1149,11 +1149,11 @@ i915_gem_mmap_ioctl(struct drm_device *d
 
 	offset = args->offset;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	addr = do_mmap(obj->filp, 0, args->size,
 		       PROT_READ | PROT_WRITE, MAP_SHARED,
 		       args->offset);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 	mutex_lock(&dev->struct_mutex);
 	drm_gem_object_unreference(obj);
 	mutex_unlock(&dev->struct_mutex);
Index: mmotm-mm-accessor/drivers/gpu/drm/i830/i830_dma.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/gpu/drm/i830/i830_dma.c
+++ mmotm-mm-accessor/drivers/gpu/drm/i830/i830_dma.c
@@ -134,7 +134,7 @@ static int i830_map_buffer(struct drm_bu
 	if (buf_priv->currently_mapped == I830_BUF_MAPPED)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	old_fops = file_priv->filp->f_op;
 	file_priv->filp->f_op = &i830_buffer_fops;
 	dev_priv->mmap_buffer = buf;
@@ -150,7 +150,7 @@ static int i830_map_buffer(struct drm_bu
 	} else {
 		buf_priv->virtual = (void __user *)virtual;
 	}
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 
 	return retcode;
 }
@@ -163,11 +163,11 @@ static int i830_unmap_buffer(struct drm_
 	if (buf_priv->currently_mapped != I830_BUF_MAPPED)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	retcode = do_munmap(current->mm,
 			    (unsigned long)buf_priv->virtual,
 			    (size_t) buf->total);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 
 	buf_priv->currently_mapped = I830_BUF_UNMAPPED;
 	buf_priv->virtual = NULL;
Index: mmotm-mm-accessor/drivers/gpu/drm/via/via_dmablit.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/gpu/drm/via/via_dmablit.c
+++ mmotm-mm-accessor/drivers/gpu/drm/via/via_dmablit.c
@@ -237,14 +237,14 @@ via_lock_all_dma_pages(drm_via_sg_info_t
 	if (NULL == (vsg->pages = vmalloc(sizeof(struct page *) * vsg->num_pages)))
 		return -ENOMEM;
 	memset(vsg->pages, 0, sizeof(struct page *) * vsg->num_pages);
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
 	ret = get_user_pages(current, current->mm,
 			     (unsigned long)xfer->mem_addr,
 			     vsg->num_pages,
 			     (vsg->direction == DMA_FROM_DEVICE),
 			     0, vsg->pages, NULL);
 
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 	if (ret != vsg->num_pages) {
 		if (ret < 0)
 			return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
