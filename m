Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2JK6aWr010940
	for <linux-mm@kvack.org>; Mon, 19 Mar 2007 16:06:36 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2JK5FvW210168
	for <linux-mm@kvack.org>; Mon, 19 Mar 2007 16:05:15 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2JK5FYA003715
	for <linux-mm@kvack.org>; Mon, 19 Mar 2007 16:05:15 -0400
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 1/7] Introduce the pagetable_operations and associated helper macros.
Date: Mon, 19 Mar 2007 13:05:13 -0700
Message-Id: <20070319200513.17168.52238.stgit@localhost.localdomain>
In-Reply-To: <20070319200502.17168.17175.stgit@localhost.localdomain>
References: <20070319200502.17168.17175.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Adam Litke <agl@us.ibm.com>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 include/linux/mm.h |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 60e0e4a..7089323 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -98,6 +98,7 @@ struct vm_area_struct {
 
 	/* Function pointers to deal with this struct. */
 	struct vm_operations_struct * vm_ops;
+	const struct pagetable_operations_struct * pagetable_ops;
 
 	/* Information about our backing store: */
 	unsigned long vm_pgoff;		/* Offset (within vm_file) in PAGE_SIZE
@@ -218,6 +219,30 @@ struct vm_operations_struct {
 };
 
 struct mmu_gather;
+
+struct pagetable_operations_struct {
+	int (*fault)(struct mm_struct *mm,
+		struct vm_area_struct *vma,
+		unsigned long address, int write_access);
+	int (*copy_vma)(struct mm_struct *dst, struct mm_struct *src,
+		struct vm_area_struct *vma);
+	int (*pin_pages)(struct mm_struct *mm, struct vm_area_struct *vma,
+		struct page **pages, struct vm_area_struct **vmas,
+		unsigned long *position, int *length, int i);
+	void (*change_protection)(struct vm_area_struct *vma,
+		unsigned long address, unsigned long end, pgprot_t newprot);
+	unsigned long (*unmap_page_range)(struct vm_area_struct *vma,
+		unsigned long address, unsigned long end, long *zap_work);
+	void (*free_pgtable_range)(struct mmu_gather **tlb,
+		unsigned long addr, unsigned long end,
+		unsigned long floor, unsigned long ceiling);
+};
+
+#define has_pt_op(vma, op) \
+	((vma)->pagetable_ops && (vma)->pagetable_ops->op)
+#define pt_op(vma, call) \
+	((vma)->pagetable_ops->call)
+
 struct inode;
 
 #define page_private(page)		((page)->private)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
