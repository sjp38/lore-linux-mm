Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 461C06B0253
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:43:37 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q186so3940255pga.23
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:43:37 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j89si3138674pfa.108.2017.12.14.03.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 03:43:35 -0800 (PST)
Message-Id: <20171214113851.897611055@infradead.org>
Date: Thu, 14 Dec 2017 12:27:42 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH v2 16/17] x86/ldt: Add VMA management code
References: <20171214112726.742649793@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=x86-ldt--Add-VMA-management-code.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

Add the VMA management code to LDT which allows to install the LDT as a
special mapping, like VDSO and uprobes. The mapping is in the user address
space, but without the usr bit set and read only. Split out for ease of
review.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/kernel/ldt.c |  103 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 102 insertions(+), 1 deletion(-)

--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -31,6 +31,7 @@
 struct ldt_mapping {
 	struct ldt_struct		ldts[2];
 	unsigned int			ldt_index;
+	unsigned int			ldt_mapped;
 };
 
 /* After calling this, the LDT is immutable. */
@@ -177,6 +178,105 @@ static void cleanup_ldt_struct(struct ld
 	ldt->nr_entries = 0;
 }
 
+static int ldt_fault(const struct vm_special_mapping *sm,
+		     struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	struct ldt_mapping *lmap = vma->vm_mm->context.ldt_mapping;
+	struct ldt_struct *ldt = lmap->ldts;
+	pgoff_t pgo = vmf->pgoff;
+	struct page *page;
+
+	if (pgo >= LDT_ENTRIES_PAGES) {
+		pgo -= LDT_ENTRIES_PAGES;
+		ldt++;
+	}
+	if (pgo >= LDT_ENTRIES_PAGES)
+		return VM_FAULT_SIGBUS;
+
+	page = ldt->pages[pgo];
+	if (!page)
+		return VM_FAULT_SIGBUS;
+	get_page(page);
+	vmf->page = page;
+	return 0;
+}
+
+static int ldt_mremap(const struct vm_special_mapping *sm,
+		      struct vm_area_struct *new_vma)
+{
+	return -EINVAL;
+}
+
+static void ldt_close(const struct vm_special_mapping *sm,
+		      struct vm_area_struct *vma)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct ldt_struct *ldt;
+
+	/*
+	 * Orders against ldt_install().
+	 */
+	mutex_lock(&mm->context.lock);
+	ldt = mm->context.ldt;
+	ldt_install_mm(mm, NULL);
+	cleanup_ldt_struct(ldt);
+	mm->context.ldt_mapping->ldt_mapped = 0;
+	mutex_unlock(&mm->context.lock);
+}
+
+static const struct vm_special_mapping ldt_special_mapping = {
+	.name	= "[ldt]",
+	.fault	= ldt_fault,
+	.mremap	= ldt_mremap,
+	.close	= ldt_close,
+};
+
+static struct vm_area_struct *ldt_alloc_vma(struct mm_struct *mm,
+					    struct ldt_mapping *lmap)
+{
+	unsigned long vm_flags, size;
+	struct vm_area_struct *vma;
+	unsigned long addr;
+
+	size = 2 * LDT_ENTRIES_MAP_SIZE;
+	addr = get_unmapped_area(NULL, TASK_SIZE - PAGE_SIZE, size, 0, 0);
+	if (IS_ERR_VALUE(addr))
+		return ERR_PTR(addr);
+
+	vm_flags = VM_READ | VM_WIPEONFORK | VM_NOUSER | VM_SHARED;
+	vma = _install_special_mapping(mm, addr, size, vm_flags,
+				       &ldt_special_mapping);
+	if (IS_ERR(vma))
+		return vma;
+
+	lmap->ldts[0].entries = (struct desc_struct *) addr;
+	addr += LDT_ENTRIES_MAP_SIZE;
+	lmap->ldts[1].entries = (struct desc_struct *) addr;
+	return vma;
+}
+
+static int ldt_mmap(struct mm_struct *mm, struct ldt_mapping *lmap)
+{
+	struct vm_area_struct *vma;
+	int ret = 0;
+
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
+	vma = ldt_alloc_vma(mm, lmap);
+	if (IS_ERR(vma)) {
+		ret = PTR_ERR(vma);
+	} else {
+		/*
+		 * The moment mmap_sem() is released munmap() can observe
+		 * the mapping and make it go away through ldt_close(). But
+		 * for now there is mapping.
+		 */
+		lmap->ldt_mapped = 1;
+	}
+	up_write(&mm->mmap_sem);
+	return ret;
+}
+
 /* The caller must call finalize_ldt_struct on the result. LDT starts zeroed. */
 static struct ldt_struct *alloc_ldt_struct(unsigned int num_entries)
 {
@@ -289,7 +389,8 @@ static int read_ldt(void __user *ptr, un
 
 	down_read(&mm->context.ldt_usr_sem);
 
-	ldt = mm->context.ldt;
+	/* Might race against vm_unmap, which installs a NULL LDT */
+	ldt = READ_ONCE(mm->context.ldt);
 	if (!ldt)
 		goto out_unlock;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
