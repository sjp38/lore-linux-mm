Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id A8DD16B0092
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 05:29:28 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so1494120bkw.14
        for <linux-mm@kvack.org>; Sat, 31 Mar 2012 02:29:28 -0700 (PDT)
Subject: [PATCH 5/7] mm, drm/udl: fixup vma flags on mmap
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 31 Mar 2012 13:29:25 +0400
Message-ID: <20120331092924.19920.4931.stgit@zurg>
In-Reply-To: <20120331091049.19373.28994.stgit@zurg>
References: <20120331091049.19373.28994.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Dave Airlie <airlied@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, dri-devel@lists.freedesktop.org

There should be VM_MIXEDMAP, not VM_PFNMAP, because udl_gem_fault() inserts
pages via vm_insert_page(). Other drm/gem drivers already do this.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Dave Airlie <airlied@redhat.com>
Cc: dri-devel@lists.freedesktop.org
---
 drivers/gpu/drm/udl/udl_drv.c |    2 +-
 drivers/gpu/drm/udl/udl_drv.h |    1 +
 drivers/gpu/drm/udl/udl_gem.c |   14 ++++++++++++++
 3 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/drivers/gpu/drm/udl/udl_drv.c b/drivers/gpu/drm/udl/udl_drv.c
index 5340c5f..5367390 100644
--- a/drivers/gpu/drm/udl/udl_drv.c
+++ b/drivers/gpu/drm/udl/udl_drv.c
@@ -47,7 +47,7 @@ static struct vm_operations_struct udl_gem_vm_ops = {
 static const struct file_operations udl_driver_fops = {
 	.owner = THIS_MODULE,
 	.open = drm_open,
-	.mmap = drm_gem_mmap,
+	.mmap = udl_drm_gem_mmap,
 	.poll = drm_poll,
 	.read = drm_read,
 	.unlocked_ioctl	= drm_ioctl,
diff --git a/drivers/gpu/drm/udl/udl_drv.h b/drivers/gpu/drm/udl/udl_drv.h
index 1612954..96820d0 100644
--- a/drivers/gpu/drm/udl/udl_drv.h
+++ b/drivers/gpu/drm/udl/udl_drv.h
@@ -121,6 +121,7 @@ struct udl_gem_object *udl_gem_alloc_object(struct drm_device *dev,
 
 int udl_gem_vmap(struct udl_gem_object *obj);
 void udl_gem_vunmap(struct udl_gem_object *obj);
+int udl_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma);
 int udl_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf);
 
 int udl_handle_damage(struct udl_framebuffer *fb, int x, int y,
diff --git a/drivers/gpu/drm/udl/udl_gem.c b/drivers/gpu/drm/udl/udl_gem.c
index 852642d..92f19ef 100644
--- a/drivers/gpu/drm/udl/udl_gem.c
+++ b/drivers/gpu/drm/udl/udl_gem.c
@@ -71,6 +71,20 @@ int udl_dumb_destroy(struct drm_file *file, struct drm_device *dev,
 	return drm_gem_handle_delete(file, handle);
 }
 
+int udl_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
+{
+	int ret;
+
+	ret = drm_gem_mmap(filp, vma);
+	if (ret)
+		return ret;
+
+	vma->vm_flags &= ~VM_PFNMAP;
+	vma->vm_flags |= VM_MIXEDMAP;
+
+	return ret;
+}
+
 int udl_gem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct udl_gem_object *obj = to_udl_bo(vma->vm_private_data);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
