Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C0B296B005A
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 06:56:03 -0400 (EDT)
Received: by pxi40 with SMTP id 40so544140pxi.12
        for <linux-mm@kvack.org>; Wed, 24 Jun 2009 03:57:49 -0700 (PDT)
From: Magnus Damm <magnus.damm@gmail.com>
Date: Wed, 24 Jun 2009 19:54:13 +0900
Message-Id: <20090624105413.13925.65192.sendpatchset@rx1.opensource.se>
Subject: [PATCH] video: arch specific page protection support for deferred io
Sender: owner-linux-mm@kvack.org
To: linux-fbdev-devel@lists.sourceforge.net
Cc: adaplas@gmail.com, arnd@arndb.de, linux-mm@kvack.org, lethal@linux-sh.org, Magnus Damm <magnus.damm@gmail.com>, jayakumar.lkml@gmail.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

From: Magnus Damm <damm@igel.co.jp>

This patch adds arch specific page protection support to deferred io.

Instead of overwriting the info->fbops->mmap pointer with the
deferred io specific mmap callback, modify fb_mmap() to include
a #ifdef wrapped call to fb_deferred_io_mmap().  The function
fb_deferred_io_mmap() is extended to call fb_pgprotect() in the
case of non-vmalloc() frame buffers.

With this patch uncached deferred io can be used together with
the sh_mobile_lcdcfb driver. Without this patch arch specific
page protection code in fb_pgprotect() never gets invoked with
deferred io.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 For proper runtime operation with uncached vmas make sure
 "[PATCH][RFC] mm: uncached vma support with writenotify"
 is applied. There are no merge order dependencies.

 drivers/video/fb_defio.c |   10 +++++++---
 drivers/video/fbmem.c    |    6 ++++++
 include/linux/fb.h       |    2 ++
 3 files changed, 15 insertions(+), 3 deletions(-)

--- 0001/drivers/video/fb_defio.c
+++ work/drivers/video/fb_defio.c	2009-06-24 19:07:11.000000000 +0900
@@ -19,6 +19,7 @@
 #include <linux/interrupt.h>
 #include <linux/fb.h>
 #include <linux/list.h>
+#include <asm/fb.h>
 
 /* to support deferred IO */
 #include <linux/rmap.h>
@@ -141,11 +142,16 @@ static const struct address_space_operat
 	.set_page_dirty = fb_deferred_io_set_page_dirty,
 };
 
-static int fb_deferred_io_mmap(struct fb_info *info, struct vm_area_struct *vma)
+int fb_deferred_io_mmap(struct file *file, struct fb_info *info,
+			struct vm_area_struct *vma, unsigned long off)
 {
 	vma->vm_ops = &fb_deferred_io_vm_ops;
 	vma->vm_flags |= ( VM_IO | VM_RESERVED | VM_DONTEXPAND );
 	vma->vm_private_data = info;
+
+	if (!is_vmalloc_addr(info->screen_base))
+		fb_pgprotect(file, vma, off);
+
 	return 0;
 }
 
@@ -182,7 +188,6 @@ void fb_deferred_io_init(struct fb_info 
 
 	BUG_ON(!fbdefio);
 	mutex_init(&fbdefio->lock);
-	info->fbops->fb_mmap = fb_deferred_io_mmap;
 	INIT_DELAYED_WORK(&info->deferred_work, fb_deferred_io_work);
 	INIT_LIST_HEAD(&fbdefio->pagelist);
 	if (fbdefio->delay == 0) /* set a default of 1 s */
@@ -214,7 +219,6 @@ void fb_deferred_io_cleanup(struct fb_in
 		page->mapping = NULL;
 	}
 
-	info->fbops->fb_mmap = NULL;
 	mutex_destroy(&fbdefio->lock);
 }
 EXPORT_SYMBOL_GPL(fb_deferred_io_cleanup);
--- 0001/drivers/video/fbmem.c
+++ work/drivers/video/fbmem.c	2009-06-24 19:12:29.000000000 +0900
@@ -1325,6 +1325,12 @@ __releases(&info->lock)
 	off = vma->vm_pgoff << PAGE_SHIFT;
 	if (!fb)
 		return -ENODEV;
+
+#ifdef CONFIG_FB_DEFERRED_IO
+	if (info->fbdefio)
+		return fb_deferred_io_mmap(file, info, vma, off);
+#endif
+
 	if (fb->fb_mmap) {
 		int res;
 		mutex_lock(&info->lock);
--- 0001/include/linux/fb.h
+++ work/include/linux/fb.h	2009-06-24 19:04:49.000000000 +0900
@@ -1005,6 +1005,8 @@ extern void fb_deferred_io_open(struct f
 extern void fb_deferred_io_cleanup(struct fb_info *info);
 extern int fb_deferred_io_fsync(struct file *file, struct dentry *dentry,
 				int datasync);
+extern int fb_deferred_io_mmap(struct file *file, struct fb_info *info,
+			       struct vm_area_struct *vma, unsigned long off);
 
 static inline bool fb_be_math(struct fb_info *info)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
