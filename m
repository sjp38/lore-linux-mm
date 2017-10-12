Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 212E76B025F
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 21:46:37 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k69so2862686ioi.13
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 18:46:37 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b83si11221525ioj.386.2017.10.11.18.46.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 18:46:35 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Date: Wed, 11 Oct 2017 18:46:11 -0700
Message-Id: <20171012014611.18725-4-mike.kravetz@oracle.com>
In-Reply-To: <20171012014611.18725-1-mike.kravetz@oracle.com>
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
 <20171012014611.18725-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Christoph Lameter <cl@linux.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>

Add new MAP_CONTIG flag to mmap system call.  Check for flag in normal
mmap flag processing.  If present, pre-allocate a contiguous set of
pages to back the mapping.  These pages will be used a fault time, and
the MAP_CONTIG flag implies populating the mapping at the mmap time.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/uapi/asm-generic/mman.h |  1 +
 mm/mmap.c                       | 94 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 95 insertions(+)

diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
index 7162cd4cca73..e8046b4c4ac4 100644
--- a/include/uapi/asm-generic/mman.h
+++ b/include/uapi/asm-generic/mman.h
@@ -12,6 +12,7 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define MAP_CONTIG	0x80000		/* back with contiguous pages */
 
 /* Bits [26:31] are reserved, see mman-common.h for MAP_HUGETLB usage */
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 680506faceae..aee7917ee073 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -167,6 +167,16 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 {
 	struct vm_area_struct *next = vma->vm_next;
 
+	if (vma->vm_flags & VM_CONTIG) {
+		/*
+		 * Do any necessary clean up when freeing a vma backed
+		 * by a contiguous allocation.
+		 *
+		 * Not very useful in it's present form.
+		 */
+		VM_BUG_ON(!vma->vm_private_data);
+		vma->vm_private_data = NULL;
+	}
 	might_sleep();
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
@@ -1378,6 +1388,18 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 	vm_flags |= calc_vm_prot_bits(prot, pkey) | calc_vm_flag_bits(flags) |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
+	/*
+	 * MAP_CONTIG has some restrictions,
+	 * and also implies additional mmap and vma flags.
+	 */
+	if (flags & MAP_CONTIG) {
+		if (!(flags & MAP_ANONYMOUS))
+			return -EINVAL;
+
+		flags |= MAP_POPULATE | MAP_LOCKED;
+		vm_flags |= (VM_CONTIG | VM_LOCKED | VM_DONTEXPAND);
+	}
+
 	if (flags & MAP_LOCKED)
 		if (!can_do_mlock())
 			return -EPERM;
@@ -1547,6 +1569,71 @@ SYSCALL_DEFINE1(old_mmap, struct mmap_arg_struct __user *, arg)
 #endif /* __ARCH_WANT_SYS_OLD_MMAP */
 
 /*
+ * Attempt to allocate a contiguous range of pages to back the
+ * specified vma.  vm_private_data is used as a 'pointer' to the
+ * allocated pages.  Larger requests and more fragmented memory
+ * make the allocation more likely to fail.  So, caller must deal
+ * with this situation.
+ */
+static long __alloc_vma_contig_range(struct vm_area_struct *vma)
+{
+	gfp_t gfp = GFP_HIGHUSER | __GFP_ZERO;
+	unsigned long order;
+
+	VM_BUG_ON_VMA(vma->vm_private_data != NULL, vma);
+	order = get_order(vma->vm_end - vma->vm_start);
+
+	/*
+	 * FIXME - Incomplete implementation.  For now, just handle
+	 * allocations < MAX_ORDER in size.  However, this should really
+	 * handle arbitrary size allocations.
+	 */
+	if (order >= MAX_ORDER)
+		return -ENOMEM;
+
+	vma->vm_private_data = alloc_pages_vma(gfp, order, vma, vma->vm_start,
+						numa_node_id(), false);
+	if (!vma->vm_private_data)
+		return -ENOMEM;
+
+	/*
+	 * split large allocation so it can be treated as individual
+	 * pages when populating the mapping and at unmap time.
+	 */
+	if (order) {
+		unsigned long vma_pages = (vma->vm_end - vma->vm_start) /
+								PAGE_SIZE;
+		unsigned long order_pages = 1 << order;
+		unsigned long i;
+		struct page *page = vma->vm_private_data;
+
+		split_page((struct page *)vma->vm_private_data, order);
+
+		/*
+		 * 'order' rounds up size of vma to next power of 2.  We
+		 * will not need/use the extra pages so free them now.
+		 */
+		for (i = vma_pages; i < order_pages; i++)
+			put_page(page + i);
+	}
+
+	return 0;
+}
+
+static void __free_vma_contig_range(struct vm_area_struct *vma)
+{
+	struct page *page = vma->vm_private_data;
+	unsigned long n_pages = (vma->vm_end - vma->vm_start) / PAGE_SIZE;
+	unsigned long i;
+
+	if (!page)
+		return;
+
+	for (i = 0; i < n_pages; i++)
+		put_page(page + i);
+}
+
+/*
  * Some shared mappigns will want the pages marked read-only
  * to track write events. If so, we'll downgrade vm_page_prot
  * to the private version (using protection_map[] without the
@@ -1669,6 +1756,12 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	vma->vm_pgoff = pgoff;
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
 
+	if (vm_flags & VM_CONTIG) {
+		error = __alloc_vma_contig_range(vma);
+		if (error)
+			goto free_vma;
+	}
+
 	if (file) {
 		if (vm_flags & VM_DENYWRITE) {
 			error = deny_write_access(file);
@@ -1758,6 +1851,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	if (vm_flags & VM_DENYWRITE)
 		allow_write_access(file);
 free_vma:
+	__free_vma_contig_range(vma);
 	kmem_cache_free(vm_area_cachep, vma);
 unacct_error:
 	if (charged)
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
