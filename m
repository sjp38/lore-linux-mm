Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5966B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 16:37:47 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id b6so2323445pgu.16
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 13:37:47 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t6si465140pgt.130.2018.02.08.13.37.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Feb 2018 13:37:45 -0800 (PST)
Date: Thu, 8 Feb 2018 13:37:43 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: [RFC] Limit mappings to ten per page per process
Message-ID: <20180208213743.GC3424@bombadil.infradead.org>
References: <20180208021112.GB14918@bombadil.infradead.org>
 <CAG48ez2-MTJ2YrS5fPZi19RY6P_6NWuK1U5CcQpJ25=xrGSy_A@mail.gmail.com>
 <CA+DvKQLHDR0s=6r4uiHL8kw2_PnfJcwYfPxgQOmuLbc=5k39+g@mail.gmail.com>
 <20180208185648.GB9524@bombadil.infradead.org>
 <CA+DvKQLHcFc3+kW_SnD6hs53yyD5Zi+uAeSgDMm1tRzxqy-Opg@mail.gmail.com>
 <20180208194235.GA3424@bombadil.infradead.org>
 <CA+DvKQKba0iU+tydbmGkAJsxCxazORDnuoe32sy-2nggyagUxQ@mail.gmail.com>
 <20180208202100.GB3424@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180208202100.GB3424@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Jann Horn <jannh@google.com>, linux-mm@kvack.org, Kernel Hardening <kernel-hardening@lists.openwall.com>, kernel list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Feb 08, 2018 at 12:21:00PM -0800, Matthew Wilcox wrote:
> Now that I think about it, though, perhaps the simplest solution is not
> to worry about checking whether _mapcount has saturated, and instead when
> adding a new mmap, check whether this task already has it mapped 10 times.
> If so, refuse the mapping.

That turns out to be quite easy.  Comments on this approach?

diff --git a/mm/mmap.c b/mm/mmap.c
index 9efdc021ad22..fd64ff662117 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1615,6 +1615,34 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 	return (vm_flags & (VM_NORESERVE | VM_SHARED | VM_WRITE)) == VM_WRITE;
 }
 
+/**
+ * mmap_max_overlaps - Check the process has not exceeded its quota of mappings.
+ * @mm: The memory map for the process creating the mapping.
+ * @file: The file the mapping is coming from.
+ * @pgoff: The start of the mapping in the file.
+ * @count: The number of pages to map.
+ *
+ * Return: %true if this region of the file has too many overlapping mappings
+ *         by this process.
+ */
+bool mmap_max_overlaps(struct mm_struct *mm, struct file *file,
+			pgoff_t pgoff, pgoff_t count)
+{
+	unsigned int overlaps = 0;
+	struct vm_area_struct *vma;
+
+	if (!file)
+		return false;
+
+	vma_interval_tree_foreach(vma, &file->f_mapping->i_mmap,
+				  pgoff, pgoff + count) {
+		if (vma->vm_mm == mm)
+			overlaps++;
+	}
+
+	return overlaps > 9;
+}
+
 unsigned long mmap_region(struct file *file, unsigned long addr,
 		unsigned long len, vm_flags_t vm_flags, unsigned long pgoff,
 		struct list_head *uf)
@@ -1640,6 +1668,9 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 			return -ENOMEM;
 	}
 
+	if (mmap_max_overlaps(mm, file, pgoff, len >> PAGE_SHIFT))
+		return -ENOMEM;
+
 	/* Clear old maps */
 	while (find_vma_links(mm, addr, addr + len, &prev, &rb_link,
 			      &rb_parent)) {
diff --git a/mm/mremap.c b/mm/mremap.c
index 049470aa1e3e..27cf5cf9fc0f 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -430,6 +430,10 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 				(new_len - old_len) >> PAGE_SHIFT))
 		return ERR_PTR(-ENOMEM);
 
+	if (mmap_max_overlaps(mm, vma->vm_file, pgoff,
+				(new_len - old_len) >> PAGE_SHIFT))
+		return ERR_PTR(-ENOMEM);
+
 	if (vma->vm_flags & VM_ACCOUNT) {
 		unsigned long charged = (new_len - old_len) >> PAGE_SHIFT;
 		if (security_vm_enough_memory_mm(mm, charged))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
