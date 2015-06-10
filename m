Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id A9CB56B0073
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 05:21:54 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so33837902pdj.3
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:21:54 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id h4si13015666pdi.136.2015.06.10.02.21.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 02:21:53 -0700 (PDT)
From: Mauro Carvalho Chehab <mchehab@osg.samsung.com>
Subject: [PATCH 1/9] mm: Provide new get_vaddr_frames() helper
Date: Wed, 10 Jun 2015 06:20:44 -0300
Message-Id: <f8d212d88c005564f3faedf1c7d6f089fcb3126d.1433927458.git.mchehab@osg.samsung.com>
In-Reply-To: <cover.1433927458.git.mchehab@osg.samsung.com>
References: <cover.1433927458.git.mchehab@osg.samsung.com>
In-Reply-To: <cover.1433927458.git.mchehab@osg.samsung.com>
References: <cover.1433927458.git.mchehab@osg.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Linux Media Mailing List <linux-media@vger.kernel.org>, Mauro Carvalho Chehab <mchehab@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Christian Borntraeger <borntraeger@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Hans Verkuil <hans.verkuil@cisco.com>, Paul Cassella <cassella@cray.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, Mauro Carvalho Chehab <mchehab@osg.samsung.com>

From: Jan Kara <jack@suse.cz>

Provide new function get_vaddr_frames().  This function maps virtual
addresses from given start and fills given array with page frame numbers of
the corresponding pages. If given start belongs to a normal vma, the function
grabs reference to each of the pages to pin them in memory. If start
belongs to VM_IO | VM_PFNMAP vma, we don't touch page structures. Caller
must make sure pfns aren't reused for anything else while he is using
them.

This function is created for various drivers to simplify handling of
their buffers.

Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Jan Kara <jack@suse.cz>
Signed-off-by: Hans Verkuil <hans.verkuil@cisco.com>
Signed-off-by: Mauro Carvalho Chehab <mchehab@osg.samsung.com>

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0755b9fd03a7..dcd1f02a78e9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -20,6 +20,7 @@
 #include <linux/shrinker.h>
 #include <linux/resource.h>
 #include <linux/page_ext.h>
+#include <linux/err.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -1197,6 +1198,49 @@ long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
 		    int write, int force, struct page **pages);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
+
+/* Container for pinned pfns / pages */
+struct frame_vector {
+	unsigned int nr_allocated;	/* Number of frames we have space for */
+	unsigned int nr_frames;	/* Number of frames stored in ptrs array */
+	bool got_ref;		/* Did we pin pages by getting page ref? */
+	bool is_pfns;		/* Does array contain pages or pfns? */
+	void *ptrs[0];		/* Array of pinned pfns / pages. Use
+				 * pfns_vector_pages() or pfns_vector_pfns()
+				 * for access */
+};
+
+struct frame_vector *frame_vector_create(unsigned int nr_frames);
+void frame_vector_destroy(struct frame_vector *vec);
+int get_vaddr_frames(unsigned long start, unsigned int nr_pfns,
+		     bool write, bool force, struct frame_vector *vec);
+void put_vaddr_frames(struct frame_vector *vec);
+int frame_vector_to_pages(struct frame_vector *vec);
+void frame_vector_to_pfns(struct frame_vector *vec);
+
+static inline unsigned int frame_vector_count(struct frame_vector *vec)
+{
+	return vec->nr_frames;
+}
+
+static inline struct page **frame_vector_pages(struct frame_vector *vec)
+{
+	if (vec->is_pfns) {
+		int err = frame_vector_to_pages(vec);
+
+		if (err)
+			return ERR_PTR(err);
+	}
+	return (struct page **)(vec->ptrs);
+}
+
+static inline unsigned long *frame_vector_pfns(struct frame_vector *vec)
+{
+	if (!vec->is_pfns)
+		frame_vector_to_pfns(vec);
+	return (unsigned long *)(vec->ptrs);
+}
+
 struct kvec;
 int get_kernel_pages(const struct kvec *iov, int nr_pages, int write,
 			struct page **pages);
diff --git a/mm/gup.c b/mm/gup.c
index 6297f6bccfb1..9d7f4fde30cb 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -8,6 +8,7 @@
 #include <linux/rmap.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/vmalloc.h>
 
 #include <linux/sched.h>
 #include <linux/rwsem.h>
@@ -936,6 +937,231 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 	return ret;	/* 0 or negative error code */
 }
 
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
+
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
