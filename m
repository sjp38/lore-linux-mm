Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 76ECC6B0072
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 05:21:50 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so33962224pdb.2
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:21:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.9])
        by mx.google.com with ESMTPS id fj8si13033746pdb.93.2015.06.10.02.21.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 02:21:49 -0700 (PDT)
From: Mauro Carvalho Chehab <mchehab@osg.samsung.com>
Subject: [PATCH 9/9] [media] mm: Move get_vaddr_frames() behind a config option
Date: Wed, 10 Jun 2015 06:20:52 -0300
Message-Id: <3ca4b53f5bcf016d98c875e22cd9cf02a3495f3e.1433927458.git.mchehab@osg.samsung.com>
In-Reply-To: <cover.1433927458.git.mchehab@osg.samsung.com>
References: <cover.1433927458.git.mchehab@osg.samsung.com>
In-Reply-To: <cover.1433927458.git.mchehab@osg.samsung.com>
References: <cover.1433927458.git.mchehab@osg.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Linux Media Mailing List <linux-media@vger.kernel.org>, Mauro Carvalho Chehab <mchehab@infradead.org>, Inki Dae <inki.dae@samsung.com>, Joonyoung Shim <jy0922.shim@samsung.com>, Seung-Woo Kim <sw0312.kim@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, David Airlie <airlied@linux.ie>, Kukjin Kim <kgene@kernel.org>, Hans Verkuil <hans.verkuil@cisco.com>, Paul Bolle <pebolle@tiscali.nl>, Randy Dunlap <rdunlap@infradead.org>, Jiri Kosina <jkosina@suse.cz>, Geert Uytterhoeven <geert@linux-m68k.org>, Mark Brown <broonie@kernel.org>, Dan Streetman <ddstreet@ieee.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Christoph Jaeger <cj@linux.com>, Michal Hocko <mhocko@suse.cz>, Josh Triplett <josh@joshtriplett.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrey Ryabinin <a.ryabinin@samsung.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Paul Cassella <cassella@cray.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, dri-devel@lists.freedesktop.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-mm@kvack.org, Mauro Carvalho Chehab <mchehab@osg.samsung.com>

From: Jan Kara <jack@suse.cz>

get_vaddr_frames() is used by relatively rare drivers so hide it and the
related functions behind a config option that is selected only by
drivers that need the infrastructure.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Jan Kara <jack@suse.cz>
Signed-off-by: Hans Verkuil <hans.verkuil@cisco.com>
Signed-off-by: Mauro Carvalho Chehab <mchehab@osg.samsung.com>

 create mode 100644 mm/frame_vector.c

diff --git a/drivers/gpu/drm/exynos/Kconfig b/drivers/gpu/drm/exynos/Kconfig
index 0a6780367d28..fc678289cf79 100644
--- a/drivers/gpu/drm/exynos/Kconfig
+++ b/drivers/gpu/drm/exynos/Kconfig
@@ -71,6 +71,7 @@ config DRM_EXYNOS_VIDI
 config DRM_EXYNOS_G2D
 	bool "Exynos DRM G2D"
 	depends on DRM_EXYNOS && !VIDEO_SAMSUNG_S5P_G2D
+	select FRAME_VECTOR
 	help
 	  Choose this option if you want to use Exynos G2D for DRM.
 
diff --git a/drivers/media/platform/omap/Kconfig b/drivers/media/platform/omap/Kconfig
index dc2aaab54aef..217d613b0fe7 100644
--- a/drivers/media/platform/omap/Kconfig
+++ b/drivers/media/platform/omap/Kconfig
@@ -10,6 +10,7 @@ config VIDEO_OMAP2_VOUT
 	select OMAP2_DSS if HAS_IOMEM && ARCH_OMAP2PLUS
 	select OMAP2_VRFB if ARCH_OMAP2 || ARCH_OMAP3
 	select VIDEO_OMAP2_VOUT_VRFB if VIDEO_OMAP2_VOUT && OMAP2_VRFB
+	select FRAME_VECTOR
 	default n
 	---help---
 	  V4L2 Display driver support for OMAP2/3 based boards.
diff --git a/drivers/media/v4l2-core/Kconfig b/drivers/media/v4l2-core/Kconfig
index f7a01a72eb9e..f38f6e387f04 100644
--- a/drivers/media/v4l2-core/Kconfig
+++ b/drivers/media/v4l2-core/Kconfig
@@ -73,6 +73,7 @@ config VIDEOBUF2_CORE
 
 config VIDEOBUF2_MEMOPS
 	tristate
+	select FRAME_VECTOR
 
 config VIDEOBUF2_DMA_CONTIG
 	tristate
diff --git a/mm/Kconfig b/mm/Kconfig
index 390214da4546..2ca52e9986f0 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -635,3 +635,6 @@ config MAX_STACK_SIZE_MB
 	  changed to a smaller value in which case that is used.
 
 	  A sane initial value is 80 MB.
+
+config FRAME_VECTOR
+	bool
diff --git a/mm/Makefile b/mm/Makefile
index 98c4eaeabdcb..be5d5c866305 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -78,3 +78,4 @@ obj-$(CONFIG_CMA)	+= cma.o
 obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
 obj-$(CONFIG_PAGE_EXTENSION) += page_ext.o
 obj-$(CONFIG_CMA_DEBUGFS) += cma_debug.o
+obj-$(CONFIG_FRAME_VECTOR) += frame_vector.o
diff --git a/mm/frame_vector.c b/mm/frame_vector.c
new file mode 100644
index 000000000000..31a2bd5f41d5
--- /dev/null
+++ b/mm/frame_vector.c
@@ -0,0 +1,232 @@
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/err.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/pagemap.h>
+#include <linux/sched.h>
+
+/*
+ * get_vaddr_frames() - map virtual addresses to pfns
+ * @start:	starting user address
+ * @nr_frames:	number of pages / pfns from start to map
+ * @write:	whether pages will be written to by the caller
+ * @force:	whether to force write access even if user mapping is
+ *		readonly. See description of the same argument of
+		get_user_pages().
+ * @vec:	structure which receives pages / pfns of the addresses mapped.
+ *		It should have space for at least nr_frames entries.
+ *
+ * This function maps virtual addresses from @start and fills @vec structure
+ * with page frame numbers or page pointers to corresponding pages (choice
+ * depends on the type of the vma underlying the virtual address). If @start
+ * belongs to a normal vma, the function grabs reference to each of the pages
+ * to pin them in memory. If @start belongs to VM_IO | VM_PFNMAP vma, we don't
+ * touch page structures and the caller must make sure pfns aren't reused for
+ * anything else while he is using them.
+ *
+ * The function returns number of pages mapped which may be less than
+ * @nr_frames. In particular we stop mapping if there are more vmas of
+ * different type underlying the specified range of virtual addresses.
+ * When the function isn't able to map a single page, it returns error.
+ *
+ * This function takes care of grabbing mmap_sem as necessary.
+ */
+int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
+		     bool write, bool force, struct frame_vector *vec)
+{
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+	int ret = 0;
+	int err;
+	int locked;
+
+	if (nr_frames == 0)
+		return 0;
+
+	if (WARN_ON_ONCE(nr_frames > vec->nr_allocated))
+		nr_frames = vec->nr_allocated;
+
+	down_read(&mm->mmap_sem);
+	locked = 1;
+	vma = find_vma_intersection(mm, start, start + 1);
+	if (!vma) {
+		ret = -EFAULT;
+		goto out;
+	}
+	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP))) {
+		vec->got_ref = true;
+		vec->is_pfns = false;
+		ret = get_user_pages_locked(current, mm, start, nr_frames,
+			write, force, (struct page **)(vec->ptrs), &locked);
+		goto out;
+	}
+
+	vec->got_ref = false;
+	vec->is_pfns = true;
+	do {
+		unsigned long *nums = frame_vector_pfns(vec);
+
+		while (ret < nr_frames && start + PAGE_SIZE <= vma->vm_end) {
+			err = follow_pfn(vma, start, &nums[ret]);
+			if (err) {
+				if (ret == 0)
+					ret = err;
+				goto out;
+			}
+			start += PAGE_SIZE;
+			ret++;
+		}
+		/*
+		 * We stop if we have enough pages or if VMA doesn't completely
+		 * cover the tail page.
+		 */
+		if (ret >= nr_frames || start < vma->vm_end)
+			break;
+		vma = find_vma_intersection(mm, start, start + 1);
+	} while (vma && vma->vm_flags & (VM_IO | VM_PFNMAP));
+out:
+	if (locked)
+		up_read(&mm->mmap_sem);
+	if (!ret)
+		ret = -EFAULT;
+	if (ret > 0)
+		vec->nr_frames = ret;
+	return ret;
+}
+EXPORT_SYMBOL(get_vaddr_frames);
+
+/**
+ * put_vaddr_frames() - drop references to pages if get_vaddr_frames() acquired
+ *			them
+ * @vec:	frame vector to put
+ *
+ * Drop references to pages if get_vaddr_frames() acquired them. We also
+ * invalidate the frame vector so that it is prepared for the next call into
+ * get_vaddr_frames().
+ */
+void put_vaddr_frames(struct frame_vector *vec)
+{
+	int i;
+	struct page **pages;
+
+	if (!vec->got_ref)
+		goto out;
+	pages = frame_vector_pages(vec);
+	/*
+	 * frame_vector_pages() might needed to do a conversion when
+	 * get_vaddr_frames() got pages but vec was later converted to pfns.
+	 * But it shouldn't really fail to convert pfns back...
+	 */
+	if (WARN_ON(IS_ERR(pages)))
+		goto out;
+	for (i = 0; i < vec->nr_frames; i++)
+		put_page(pages[i]);
+	vec->got_ref = false;
+out:
+	vec->nr_frames = 0;
+}
+EXPORT_SYMBOL(put_vaddr_frames);
+
+/**
+ * frame_vector_to_pages - convert frame vector to contain page pointers
+ * @vec:	frame vector to convert
+ *
+ * Convert @vec to contain array of page pointers.  If the conversion is
+ * successful, return 0. Otherwise return an error. Note that we do not grab
+ * page references for the page structures.
+ */
+int frame_vector_to_pages(struct frame_vector *vec)
+{
+	int i;
+	unsigned long *nums;
+	struct page **pages;
+
+	if (!vec->is_pfns)
+		return 0;
+	nums = frame_vector_pfns(vec);
+	for (i = 0; i < vec->nr_frames; i++)
+		if (!pfn_valid(nums[i]))
+			return -EINVAL;
+	pages = (struct page **)nums;
+	for (i = 0; i < vec->nr_frames; i++)
+		pages[i] = pfn_to_page(nums[i]);
+	vec->is_pfns = false;
+	return 0;
+}
+EXPORT_SYMBOL(frame_vector_to_pages);
+
+/**
+ * frame_vector_to_pfns - convert frame vector to contain pfns
+ * @vec:	frame vector to convert
+ *
+ * Convert @vec to contain array of pfns.
+ */
+void frame_vector_to_pfns(struct frame_vector *vec)
+{
+	int i;
+	unsigned long *nums;
+	struct page **pages;
+
+	if (vec->is_pfns)
+		return;
+	pages = (struct page **)(vec->ptrs);
+	nums = (unsigned long *)pages;
+	for (i = 0; i < vec->nr_frames; i++)
+		nums[i] = page_to_pfn(pages[i]);
+	vec->is_pfns = true;
+}
+EXPORT_SYMBOL(frame_vector_to_pfns);
+
+/**
+ * frame_vector_create() - allocate & initialize structure for pinned pfns
+ * @nr_frames:	number of pfns slots we should reserve
+ *
+ * Allocate and initialize struct pinned_pfns to be able to hold @nr_pfns
+ * pfns.
+ */
+struct frame_vector *frame_vector_create(unsigned int nr_frames)
+{
+	struct frame_vector *vec;
+	int size = sizeof(struct frame_vector) + sizeof(void *) * nr_frames;
+
+	if (WARN_ON_ONCE(nr_frames == 0))
+		return NULL;
+	/*
+	 * This is absurdly high. It's here just to avoid strange effects when
+	 * arithmetics overflows.
+	 */
+	if (WARN_ON_ONCE(nr_frames > INT_MAX / sizeof(void *) / 2))
+		return NULL;
+	/*
+	 * Avoid higher order allocations, use vmalloc instead. It should
+	 * be rare anyway.
+	 */
+	if (size <= PAGE_SIZE)
+		vec = kmalloc(size, GFP_KERNEL);
+	else
+		vec = vmalloc(size);
+	if (!vec)
+		return NULL;
+	vec->nr_allocated = nr_frames;
+	vec->nr_frames = 0;
+	return vec;
+}
+EXPORT_SYMBOL(frame_vector_create);
+
+/**
+ * frame_vector_destroy() - free memory allocated to carry frame vector
+ * @vec:	Frame vector to free
+ *
+ * Free structure allocated by frame_vector_create() to carry frames.
+ */
+void frame_vector_destroy(struct frame_vector *vec)
+{
+	/* Make sure put_vaddr_frames() got called properly... */
+	VM_BUG_ON(vec->nr_frames > 0);
+	if (!is_vmalloc_addr(vec))
+		kfree(vec);
+	else
+		vfree(vec);
+}
+EXPORT_SYMBOL(frame_vector_destroy);
diff --git a/mm/gup.c b/mm/gup.c
index 9d7f4fde30cb..222d57e335f9 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -937,231 +937,6 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 	return ret;	/* 0 or negative error code */
 }
 
-/*
- * get_vaddr_frames() - map virtual addresses to pfns
- * @start:	starting user address
- * @nr_frames:	number of pages / pfns from start to map
- * @write:	whether pages will be written to by the caller
- * @force:	whether to force write access even if user mapping is
- *		readonly. See description of the same argument of
-		get_user_pages().
- * @vec:	structure which receives pages / pfns of the addresses mapped.
- *		It should have space for at least nr_frames entries.
- *
- * This function maps virtual addresses from @start and fills @vec structure
- * with page frame numbers or page pointers to corresponding pages (choice
- * depends on the type of the vma underlying the virtual address). If @start
- * belongs to a normal vma, the function grabs reference to each of the pages
- * to pin them in memory. If @start belongs to VM_IO | VM_PFNMAP vma, we don't
- * touch page structures and the caller must make sure pfns aren't reused for
- * anything else while he is using them.
- *
- * The function returns number of pages mapped which may be less than
- * @nr_frames. In particular we stop mapping if there are more vmas of
- * different type underlying the specified range of virtual addresses.
- * When the function isn't able to map a single page, it returns error.
- *
- * This function takes care of grabbing mmap_sem as necessary.
- */
-int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
-		     bool write, bool force, struct frame_vector *vec)
-{
-	struct mm_struct *mm = current->mm;
-	struct vm_area_struct *vma;
-	int ret = 0;
-	int err;
-	int locked;
-
-	if (nr_frames == 0)
-		return 0;
-
-	if (WARN_ON_ONCE(nr_frames > vec->nr_allocated))
-		nr_frames = vec->nr_allocated;
-
-	down_read(&mm->mmap_sem);
-	locked = 1;
-	vma = find_vma_intersection(mm, start, start + 1);
-	if (!vma) {
-		ret = -EFAULT;
-		goto out;
-	}
-	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP))) {
-		vec->got_ref = true;
-		vec->is_pfns = false;
-		ret = get_user_pages_locked(current, mm, start, nr_frames,
-			write, force, (struct page **)(vec->ptrs), &locked);
-		goto out;
-	}
-
-	vec->got_ref = false;
-	vec->is_pfns = true;
-	do {
-		unsigned long *nums = frame_vector_pfns(vec);
-
-		while (ret < nr_frames && start + PAGE_SIZE <= vma->vm_end) {
-			err = follow_pfn(vma, start, &nums[ret]);
-			if (err) {
-				if (ret == 0)
-					ret = err;
-				goto out;
-			}
-			start += PAGE_SIZE;
-			ret++;
-		}
-		/*
-		 * We stop if we have enough pages or if VMA doesn't completely
-		 * cover the tail page.
-		 */
-		if (ret >= nr_frames || start < vma->vm_end)
-			break;
-		vma = find_vma_intersection(mm, start, start + 1);
-	} while (vma && vma->vm_flags & (VM_IO | VM_PFNMAP));
-out:
-	if (locked)
-		up_read(&mm->mmap_sem);
-	if (!ret)
-		ret = -EFAULT;
-	if (ret > 0)
-		vec->nr_frames = ret;
-	return ret;
-}
-EXPORT_SYMBOL(get_vaddr_frames);
-
-/**
- * put_vaddr_frames() - drop references to pages if get_vaddr_frames() acquired
- *			them
- * @vec:	frame vector to put
- *
- * Drop references to pages if get_vaddr_frames() acquired them. We also
- * invalidate the frame vector so that it is prepared for the next call into
- * get_vaddr_frames().
- */
-void put_vaddr_frames(struct frame_vector *vec)
-{
-	int i;
-	struct page **pages;
-
-	if (!vec->got_ref)
-		goto out;
-	pages = frame_vector_pages(vec);
-	/*
-	 * frame_vector_pages() might needed to do a conversion when
-	 * get_vaddr_frames() got pages but vec was later converted to pfns.
-	 * But it shouldn't really fail to convert pfns back...
-	 */
-	if (WARN_ON(IS_ERR(pages)))
-		goto out;
-	for (i = 0; i < vec->nr_frames; i++)
-		put_page(pages[i]);
-	vec->got_ref = false;
-out:
-	vec->nr_frames = 0;
-}
-EXPORT_SYMBOL(put_vaddr_frames);
-
-/**
- * frame_vector_to_pages - convert frame vector to contain page pointers
- * @vec:	frame vector to convert
- *
- * Convert @vec to contain array of page pointers.  If the conversion is
- * successful, return 0. Otherwise return an error. Note that we do not grab
- * page references for the page structures.
- */
-int frame_vector_to_pages(struct frame_vector *vec)
-{
-	int i;
-	unsigned long *nums;
-	struct page **pages;
-
-	if (!vec->is_pfns)
-		return 0;
-	nums = frame_vector_pfns(vec);
-	for (i = 0; i < vec->nr_frames; i++)
-		if (!pfn_valid(nums[i]))
-			return -EINVAL;
-	pages = (struct page **)nums;
-	for (i = 0; i < vec->nr_frames; i++)
-		pages[i] = pfn_to_page(nums[i]);
-	vec->is_pfns = false;
-	return 0;
-}
-EXPORT_SYMBOL(frame_vector_to_pages);
-
-/**
- * frame_vector_to_pfns - convert frame vector to contain pfns
- * @vec:	frame vector to convert
- *
- * Convert @vec to contain array of pfns.
- */
-void frame_vector_to_pfns(struct frame_vector *vec)
-{
-	int i;
-	unsigned long *nums;
-	struct page **pages;
-
-	if (vec->is_pfns)
-		return;
-	pages = (struct page **)(vec->ptrs);
-	nums = (unsigned long *)pages;
-	for (i = 0; i < vec->nr_frames; i++)
-		nums[i] = page_to_pfn(pages[i]);
-	vec->is_pfns = true;
-}
-EXPORT_SYMBOL(frame_vector_to_pfns);
-
-/**
- * frame_vector_create() - allocate & initialize structure for pinned pfns
- * @nr_frames:	number of pfns slots we should reserve
- *
- * Allocate and initialize struct pinned_pfns to be able to hold @nr_pfns
- * pfns.
- */
-struct frame_vector *frame_vector_create(unsigned int nr_frames)
-{
-	struct frame_vector *vec;
-	int size = sizeof(struct frame_vector) + sizeof(void *) * nr_frames;
-
-	if (WARN_ON_ONCE(nr_frames == 0))
-		return NULL;
-	/*
-	 * This is absurdly high. It's here just to avoid strange effects when
-	 * arithmetics overflows.
-	 */
-	if (WARN_ON_ONCE(nr_frames > INT_MAX / sizeof(void *) / 2))
-		return NULL;
-	/*
-	 * Avoid higher order allocations, use vmalloc instead. It should
-	 * be rare anyway.
-	 */
-	if (size <= PAGE_SIZE)
-		vec = kmalloc(size, GFP_KERNEL);
-	else
-		vec = vmalloc(size);
-	if (!vec)
-		return NULL;
-	vec->nr_allocated = nr_frames;
-	vec->nr_frames = 0;
-	return vec;
-}
-EXPORT_SYMBOL(frame_vector_create);
-
-/**
- * frame_vector_destroy() - free memory allocated to carry frame vector
- * @vec:	Frame vector to free
- *
- * Free structure allocated by frame_vector_create() to carry frames.
- */
-void frame_vector_destroy(struct frame_vector *vec)
-{
-	/* Make sure put_vaddr_frames() got called properly... */
-	VM_BUG_ON(vec->nr_frames > 0);
-	if (!is_vmalloc_addr(vec))
-		kfree(vec);
-	else
-		vfree(vec);
-}
-EXPORT_SYMBOL(frame_vector_destroy);
-
 /**
  * get_dump_page() - pin user page in memory while writing it to core dump
  * @addr: user address
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
