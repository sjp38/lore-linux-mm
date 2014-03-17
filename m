Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7FD636B00B5
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 15:49:45 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q58so4870084wes.26
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 12:49:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bg4si10562500wjc.52.2014.03.17.12.49.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 12:49:43 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 1/9] mm: Provide new get_vaddr_pfns() helper
Date: Mon, 17 Mar 2014 20:49:28 +0100
Message-Id: <1395085776-8626-2-git-send-email-jack@suse.cz>
In-Reply-To: <1395085776-8626-1-git-send-email-jack@suse.cz>
References: <1395085776-8626-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-media@vger.kernel.org, Jan Kara <jack@suse.cz>

Provide new function get_vaddr_pfns().  This function maps virtual
addresses from given start and fills given array with page frame numbers of
the corresponding pages. If given start belongs to a normal vma, the function
grabs reference to each of the pages to pin them in memory. If start
belongs to VM_IO | VM_PFNMAP vma, we don't touch page structures. Caller
should make sure pfns aren't reused for anything else while he is using
them.

This function is created for various drivers to simplify handling of
their buffers.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/mm.h |  46 +++++++++++++++
 mm/memory.c        | 165 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 211 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index da8ad480bea7..b3bd29cc40dd 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -18,6 +18,8 @@
 #include <linux/pfn.h>
 #include <linux/bit_spinlock.h>
 #include <linux/shrinker.h>
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -1180,6 +1182,50 @@ get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
 	return ret;
 }
 
+/* Container for pinned pfns / pages */
+struct pinned_pfns {
+	unsigned int nr_allocated_pfns;	/* Number of pfns we have space for */
+	unsigned int nr_pfns;		/* Number of pfns stored in pfns array */
+	unsigned int got_ref:1;		/* Did we pin pfns by getting page ref? */
+	unsigned int is_pages:1;	/* Does array contain pages or pfns? */
+	void *ptrs[0];			/* Array of pinned pfns / pages.
+					 * Use pfns_vector_pages() or
+					 * pfns_vector_pfns() for access */
+};
+
+struct pinned_pfns *pfns_vector_create(int nr_pfns);
+static inline void pfns_vector_destroy(struct pinned_pfns *pfns)
+{
+	if (!is_vmalloc_addr(pfns))
+		kfree(pfns);
+	else
+		vfree(pfns);
+}
+int get_vaddr_pfns(unsigned long start, int nr_pfns, int write, int force,
+		   struct pinned_pfns *pfns);
+void put_vaddr_pfns(struct pinned_pfns *pfns);
+int pfns_vector_to_pages(struct pinned_pfns *pfns);
+
+static inline int pfns_vector_count(struct pinned_pfns *pfns)
+{
+	return pfns->nr_pfns;
+}
+
+static inline struct page **pfns_vector_pages(struct pinned_pfns *pfns)
+{
+	if (!pfns->is_pages)
+		return NULL;
+	return (struct page **)(pfns->ptrs);
+}
+
+static inline unsigned long *pfns_vector_pfns(struct pinned_pfns *pfns)
+{
+	if (pfns->is_pages)
+		return NULL;
+	return (unsigned long *)(pfns->ptrs);
+}
+
+
 struct kvec;
 int get_kernel_pages(const struct kvec *iov, int nr_pages, int write,
 			struct page **pages);
diff --git a/mm/memory.c b/mm/memory.c
index 22dfa617bddb..87bebcfb8911 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2024,6 +2024,171 @@ long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 EXPORT_SYMBOL(get_user_pages);
 
 /**
+ * get_vaddr_pfns() - map virtual addresses to pfns
+ * @start:	starting user address
+ * @nr_pfns:	number of pfns from start to map
+ * @write:	whether pages will be written to by the caller
+ * @force:	whether to force write access even if user mapping is
+ *		readonly. This will result in the page being COWed even
+ *		in MAP_SHARED mappings. You do not want this.
+ * @pfns:	structure which receives pfns of the pages mapped.
+ *		It should have space for at least nr_pfns pfns. 
+ *
+ * This function maps virtual addresses from @start and fills @pfns structure
+ * with page frame numbers of corresponding pages. If @start belongs to a
+ * normal vma, the function grabs reference to each of the pages to pin them in
+ * memory. If @start belongs to VM_IO | VM_PFNMAP vma, we don't touch page
+ * structures. Caller should make sure pfns aren't reused for anything else
+ * while he is using them.
+ *
+ * This function takes care of grabbing mmap_sem as necessary.
+ */
+int get_vaddr_pfns(unsigned long start, int nr_pfns, int write, int force,
+		   struct pinned_pfns *pfns)
+{
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+	int ret = 0;
+	int err;
+
+	if (nr_pfns <= 0)
+		return 0;
+
+	if (nr_pfns > pfns->nr_allocated_pfns)
+		nr_pfns = pfns->nr_allocated_pfns;
+
+	down_read(&mm->mmap_sem);
+	vma = find_vma_intersection(mm, start, start + 1);
+	if (!vma) {
+		ret = -EFAULT;
+		goto out;
+	}
+	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP))) {
+		pfns->got_ref = 1;
+		pfns->is_pages = 1;
+		ret = get_user_pages(current, mm, start, nr_pfns, write, force,
+				     pfns_vector_pages(pfns), NULL);
+		goto out;
+	}
+
+	pfns->got_ref = 0;
+	pfns->is_pages = 0;
+	do {
+		unsigned long *nums = pfns_vector_pfns(pfns);
+
+		while (ret < nr_pfns && start + PAGE_SIZE <= vma->vm_end) {
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
+		if (ret >= nr_pfns || start < vma->vm_end)
+			break;
+		vma = find_vma_intersection(mm, start, start + 1);
+	} while (vma && vma->vm_flags & (VM_IO | VM_PFNMAP));
+out:
+	up_read(&mm->mmap_sem);
+	if (!ret)
+		ret = -EFAULT;
+	if (ret > 0)
+		pfns->nr_pfns = ret;
+	return ret;
+}
+EXPORT_SYMBOL(get_vaddr_pfns);
+
+/**
+ * put_vaddr_pfns() - drop references to pages if get_vaddr_pfns() acquired them
+ * @pfns:     structure with pfns we pinned
+ *
+ * Drop references to pages if get_vaddr_pfns() acquired them. We also
+ * invalidate the array of pfns so that it is prepared for the next call into
+ * get_vaddr_pfns().
+ */
+void put_vaddr_pfns(struct pinned_pfns *pfns)
+{
+	int i;
+
+	if (!pfns->got_ref)
+		goto out;
+	if (pfns->is_pages) {
+		struct page **pages = pfns_vector_pages(pfns);
+
+		for (i = 0; i < pfns->nr_pfns; i++)
+			put_page(pages[i]);
+	} else {
+		unsigned long *nums = pfns_vector_pfns(pfns);
+
+		for (i = 0; i < pfns->nr_pfns; i++)
+			put_page(pfn_to_page(nums[i]));
+	}
+	pfns->got_ref = 0;
+out:
+	pfns->nr_pfns = 0;
+}
+EXPORT_SYMBOL(put_vaddr_pfns);
+
+/**
+ * pfns_vector_to_pages - convert vector of pfns to vector of page pointers
+ * @pfns:	structure with pinned pfns
+ *
+ * Convert @pfns to not contain array of pfns but array of page pointers.
+ * If the conversion is successful, return 0. Otherwise return an error.
+ */
+int pfns_vector_to_pages(struct pinned_pfns *pfns)
+{
+	int i;
+	unsigned long *nums;
+	struct page **pages;
+
+	if (pfns->is_pages)
+		return 0;
+	nums = pfns_vector_pfns(pfns);
+	for (i = 0; i < pfns->nr_pfns; i++)
+		if (!pfn_valid(nums[i]))
+			return -EINVAL;
+	pages = (struct page **)nums;
+	for (i = 0; i < pfns->nr_pfns; i++)
+		pages[i] = pfn_to_page(nums[i]);
+	pfns->is_pages = 1;
+	return 0;
+}
+EXPORT_SYMBOL(pfns_vector_to_pages);
+
+/**
+ * pfns_vector_create() - allocate & initialize structure for pinned pfns
+ * @nr_pfns:	number of pfns slots we should reserve
+ *
+ * Allocate and initialize struct pinned_pfns to be able to hold @nr_pfns
+ * pfns.
+ */
+struct pinned_pfns *pfns_vector_create(int nr_pfns)
+{
+	struct pinned_pfns *pfns;
+	int size = sizeof(struct pinned_pfns) + sizeof(unsigned long) * nr_pfns;
+
+	if (WARN_ON_ONCE(nr_pfns <= 0))
+		return NULL;
+	if (size <= PAGE_SIZE)
+		pfns = kmalloc(size, GFP_KERNEL);
+	else
+		pfns = vmalloc(size);
+	if (!pfns)
+		return NULL;
+	pfns->nr_allocated_pfns = nr_pfns;
+	pfns->nr_pfns = 0;
+	return 0;
+}
+EXPORT_SYMBOL(pfns_vector_create);
+
+/**
  * get_dump_page() - pin user page in memory while writing it to core dump
  * @addr: user address
  *
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
