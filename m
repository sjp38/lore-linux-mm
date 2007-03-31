From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Subject: [PATCH 05/11] RFP prot support: introduce FAULT_SIGSEGV for
	protection checking
Date: Sat, 31 Mar 2007 02:35:36 +0200
Message-ID: <20070331003536.3415.65070.stgit@americanbeauty.home.lan>
In-Reply-To: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
References: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>,
	Ingo Molnar <mingo@elte.hu>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

This is the more intrusive patch, but it couldn't be reduced a lot, not even if
I limited the protection support to the bare minimum for Uml (and thus I left
the interface generic).

The arch handler used to check itself protection flags.

But when the found VMA is non-uniform, vma->vm_flags protection flags do not matter
(except for pages not yet faulted in), so this case is handled by do_file_page()
by checking page tables.

So, we change the prototype of __handle_mm_fault() to inform it of the access
kind (read/write/exec).

handle_mm_fault() keeps its API, but has the new VM_FAULT_SIGSEGV return value.

=== Issue (trivial changes to do in every arch):

This value should be handled in every arch-specific fault handlers.

But we can get spurious BUG/oom killings _only_ when the new functionality is
used.

=== Implementation and tradeoff notes:

FIXME:
* I've made sure do_no_page to fault in pages with their *exact* permissions
  for non-uniform VMAs. The change was here, in do_no_page():

 -		if (write_access)
 +		if (write_access || (vma->vm_flags & VM_MANYPROTS))
			entry = maybe_mkwrite(pte_mkdirty(entry), vma);

  Actually, the code already works so for shared vmas, since vma->vm_page_prot
  is (supposed to be) already writable when the VMA is. Hope this holds across
  all arches.
  NOTE: I've just discovered this does not hold when vma_wants_writenotify(),
  i.e. on file mappings (at least on my system, since backing_device_info is
  involved I'm not sure it holds everywhere).
  However: this does not matter for my uses because the default protection is
  MAP_NONE for UML, and because we only need this for tmpfs.
  It doesn't matter for Oracle, because when VM_MANYPROTS is not set,
  maybe_mkwrite_file() will still set the page r/w.
  So, currently, the above change is not applied.

  However, for future possible handling of private mappings, this may be
  needed again.

* For checking, we simply reuse the standard protection_map, by creating a
  pte_t value with the vma->vm_page_prot protection and testing directly
  pte_{read,write,exec} on it.

  I use the physical frame number "0" to create the PTE. I assume that pfn_pte()
  and the access macros will work anyway. If this is invalid for any arch, let
  me know.

Changes are included for the i386, x86_64 and UML handler.

This breaks get_user_pages(force = 1) (i.e. PTRACE_POKETEXT, access_process_vm())
on VM_MANYPROTS write-protected. Next patch fixes that.

Signed-off-by: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
---

 arch/i386/mm/fault.c   |   10 +++++++
 arch/um/kernel/trap.c  |   10 ++++++-
 arch/x86_64/mm/fault.c |   13 ++++++++-
 include/linux/mm.h     |   36 ++++++++++++++++++++----
 mm/memory.c            |   71 +++++++++++++++++++++++++++++++++++++++++++++---
 5 files changed, 127 insertions(+), 13 deletions(-)

diff --git a/arch/i386/mm/fault.c b/arch/i386/mm/fault.c
index 2368a77..8c02945 100644
--- a/arch/i386/mm/fault.c
+++ b/arch/i386/mm/fault.c
@@ -400,6 +400,14 @@ fastcall void __kprobes do_page_fault(struct pt_regs *regs,
 good_area:
 	si_code = SEGV_ACCERR;
 	write = 0;
+
+	/* If the PTE is not present, the vma protection are not accurate if
+	 * VM_MANYPROTS; present PTE's are correct for VM_MANYPROTS. */
+	if (unlikely(vma->vm_flags & VM_MANYPROTS)) {
+		write = error_code & 2;
+		goto survive;
+	}
+
 	switch (error_code & 3) {
 		default:	/* 3: write, present */
 				/* fall through */
@@ -432,6 +440,8 @@ good_area:
 			goto do_sigbus;
 		case VM_FAULT_OOM:
 			goto out_of_memory;
+		case VM_FAULT_SIGSEGV:
+			goto bad_area;
 		default:
 			BUG();
 	}
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index 2de81d4..cb7eb33 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -68,6 +68,11 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 
 good_area:
 	*code_out = SEGV_ACCERR;
+	/* If the PTE is not present, the vma protection are not accurate if
+	 * VM_MANYPROTS; present PTE's are correct for VM_MANYPROTS. */
+	if (unlikely(vma->vm_flags & VM_MANYPROTS))
+		goto survive;
+
 	if(is_write && !(vma->vm_flags & VM_WRITE))
 		goto out;
 
@@ -77,7 +82,7 @@ good_area:
 
 	do {
 survive:
-		switch (handle_mm_fault(mm, vma, address, is_write)){
+		switch (handle_mm_fault(mm, vma, address, is_write)) {
 		case VM_FAULT_MINOR:
 			current->min_flt++;
 			break;
@@ -87,6 +92,9 @@ survive:
 		case VM_FAULT_SIGBUS:
 			err = -EACCES;
 			goto out;
+		case VM_FAULT_SIGSEGV:
+			err = -EFAULT;
+			goto out;
 		case VM_FAULT_OOM:
 			err = -ENOMEM;
 			goto out_of_memory;
diff --git a/arch/x86_64/mm/fault.c b/arch/x86_64/mm/fault.c
index 2728a50..e3a0906 100644
--- a/arch/x86_64/mm/fault.c
+++ b/arch/x86_64/mm/fault.c
@@ -429,6 +429,12 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 good_area:
 	info.si_code = SEGV_ACCERR;
 	write = 0;
+
+	if (unlikely(vma->vm_flags & VM_MANYPROTS)) {
+		write = error_code & PF_WRITE;
+		goto handle_fault;
+	}
+
 	switch (error_code & (PF_PROT|PF_WRITE)) {
 		default:	/* 3: write, present */
 			/* fall through */
@@ -444,6 +450,7 @@ good_area:
 				goto bad_area;
 	}
 
+handle_fault:
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
@@ -458,8 +465,12 @@ good_area:
 		break;
 	case VM_FAULT_SIGBUS:
 		goto do_sigbus;
-	default:
+	case VM_FAULT_OOM:
 		goto out_of_memory;
+	case VM_FAULT_SIGSEGV:
+		goto bad_area;
+	default:
+		BUG();
 	}
 
 	up_read(&mm->mmap_sem);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1959d9b..53a7793 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -673,10 +673,11 @@ static inline int page_mapped(struct page *page)
  * Used to decide whether a process gets delivered SIGBUS or
  * just gets major/minor fault counters bumped up.
  */
-#define VM_FAULT_OOM	0x00
-#define VM_FAULT_SIGBUS	0x01
-#define VM_FAULT_MINOR	0x02
-#define VM_FAULT_MAJOR	0x03
+#define VM_FAULT_OOM		0x00
+#define VM_FAULT_SIGBUS		0x01
+#define VM_FAULT_MINOR		0x02
+#define VM_FAULT_MAJOR		0x03
+#define VM_FAULT_SIGSEGV	0x04
 
 /* 
  * Special case for get_user_pages.
@@ -774,15 +775,38 @@ static inline void unmap_shared_mapping_range(struct address_space *mapping,
 extern int vmtruncate(struct inode * inode, loff_t offset);
 extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
 
+/* Fault Types: give information on the needed protection. */
+#define FT_READ		1
+#define FT_WRITE	2
+#define FT_EXEC		4
+#define FT_FORCE	8
+#define FT_MASK		(FT_READ|FT_WRITE|FT_EXEC|FT_FORCE)
+
 #ifdef CONFIG_MMU
+
+/* We use FT_READ, FT_WRITE and (optionally) FT_EXEC for the @access_mask, to
+ * report the kind of access we request for permission checking, in case the VMA
+ * is VM_MANYPROTS.
+ *
+ * get_user_pages( force == 1 ) is a special case. It's allowed to override
+ * protection checks, even on VM_MANYPROTS vma.
+ *
+ * To express that, you must add FT_FORCE to the FT_READ / FT_WRITE flags.
+ * You (get_user_pages) are expected to check yourself for the presence of
+ * VM_MAYREAD/VM_MAYWRITE flags on the vma itself.
+ *
+ * This allows to force copying COW pages to break sharing even on read-only
+ * page table entries.
+ */
+
 extern int __handle_mm_fault(struct mm_struct *mm,struct vm_area_struct *vma,
-			unsigned long address, int write_access);
+			unsigned long address, unsigned int access_mask);
 
 static inline int handle_mm_fault(struct mm_struct *mm,
 			struct vm_area_struct *vma, unsigned long address,
 			int write_access)
 {
-	return __handle_mm_fault(mm, vma, address, write_access) &
+	return __handle_mm_fault(mm, vma, address, write_access ? FT_WRITE : FT_READ) &
 				(~VM_FAULT_WRITE);
 }
 #else
diff --git a/mm/memory.c b/mm/memory.c
index 577b8bc..d66c8ca 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -977,6 +977,7 @@ no_page_table:
 	return page;
 }
 
+/* Return number of faulted-in pages. */
 int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, int len, int write, int force,
 		struct page **pages, struct vm_area_struct **vmas)
@@ -1080,6 +1081,7 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 				case VM_FAULT_MAJOR:
 					tsk->maj_flt++;
 					break;
+				case VM_FAULT_SIGSEGV:
 				case VM_FAULT_SIGBUS:
 					return i ? i : -EFAULT;
 				case VM_FAULT_OOM:
@@ -2312,6 +2314,8 @@ static int __do_fault_pgprot(struct mm_struct *mm, struct vm_area_struct *vma,
 	/* Only go through if we didn't race with anybody else... */
 	if (likely(pte_same(*page_table, orig_pte))) {
 		flush_icache_page(vma, page);
+		/* This already sets the PTE to be rw if appropriate, except for
+		 * private COW pages. */
 		entry = mk_pte(page, pgprot);
 		if (flags & FAULT_FLAG_WRITE)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -2374,7 +2378,6 @@ static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 							flags, orig_pte);
 }
 
-
 /*
  * Fault of a previously existing named mapping. Repopulate the pte
  * from the encoded file_pte if possible. This enables swappable
@@ -2413,6 +2416,40 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 						pgprot, flags, orig_pte);
 }
 
+/* Are the permissions of this PTE insufficient to satisfy the fault described
+ * in access_mask? */
+static inline int insufficient_perms(pte_t pte, int access_mask)
+{
+	if (unlikely(access_mask & FT_FORCE))
+		return 0;
+
+	if ((access_mask & FT_WRITE) && !pte_write(pte))
+		goto err;
+	if ((access_mask & FT_READ)  && !pte_read(pte))
+		goto err;
+	if ((access_mask & FT_EXEC)  && !pte_exec(pte))
+		goto err;
+	return 0;
+err:
+	return 1;
+}
+
+static inline int insufficient_vma_perms(struct vm_area_struct * vma, int access_mask)
+{
+	if (unlikely(vma->vm_flags & VM_MANYPROTS)) {
+		/*
+		 * we used to check protections in arch handler, but with
+		 * VM_MANYPROTS, and only with it, the check is skipped.
+		 * access_mask contains the type of the access, vm_flags are the
+		 * declared protections, pte has the protection which will be
+		 * given to the PTE's in that area.
+		 */
+		pte_t pte = pfn_pte(0UL, vma->vm_page_prot);
+		return insufficient_perms(pte, access_mask);
+	}
+	return 0;
+}
+
 /*
  * These routines also need to handle stuff like marking pages dirty
  * and/or accessed for architectures that don't do it in hardware (most
@@ -2428,14 +2465,21 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
  */
 static inline int handle_pte_fault(struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long address,
-		pte_t *pte, pmd_t *pmd, int write_access)
+		pte_t *pte, pmd_t *pmd, int access_mask)
 {
 	pte_t entry;
 	pte_t old_entry;
 	spinlock_t *ptl;
+	int write_access = access_mask & FT_WRITE;
 
 	old_entry = entry = *pte;
 	if (!pte_present(entry)) {
+		/* when pte_file(), the VMA protections are useless.  Otherwise,
+		 * we need to check VM_MANYPROTS, because in that case the arch
+		 * fault handler skips the VMA protection check. */
+		if (!pte_file(entry) && unlikely(insufficient_vma_perms(vma, access_mask)))
+			goto segv;
+
 		if (pte_none(entry)) {
 			if (vma->vm_ops) {
 				if (vma->vm_ops->fault || vma->vm_ops->nopage)
@@ -2456,6 +2500,16 @@ static inline int handle_pte_fault(struct mm_struct *mm,
 	spin_lock(ptl);
 	if (unlikely(!pte_same(*pte, entry)))
 		goto unlock;
+
+	/* VM_MANYPROTS vma's have PTE's always installed with the correct
+	 * protection, so if we got a fault on a present PTE we're in trouble.
+	 * However, the pte_present() may simply be the result of a race
+	 * condition with another thread having already fixed the fault. So go
+	 * the slow way. */
+	if (unlikely(vma->vm_flags & VM_MANYPROTS) &&
+ 		unlikely(insufficient_perms(entry, access_mask)))
+			goto segv_unlock;
+
 	if (write_access) {
 		if (!pte_write(entry))
 			return do_wp_page(mm, vma, address,
@@ -2480,13 +2534,18 @@ static inline int handle_pte_fault(struct mm_struct *mm,
 unlock:
 	pte_unmap_unlock(pte, ptl);
 	return VM_FAULT_MINOR;
+
+segv_unlock:
+	pte_unmap_unlock(pte, ptl);
+segv:
+	return VM_FAULT_SIGSEGV;
 }
 
 /*
  * By the time we get here, we already hold the mm semaphore
  */
 int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, int write_access)
+		unsigned long address, unsigned int access_mask)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -2497,8 +2556,10 @@ int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	count_vm_event(PGFAULT);
 
+	WARN_ON(access_mask & ~FT_MASK);
+
 	if (unlikely(is_vm_hugetlb_page(vma)))
-		return hugetlb_fault(mm, vma, address, write_access);
+		return hugetlb_fault(mm, vma, address, access_mask & FT_WRITE);
 
 	if (unlikely(vma->vm_flags & VM_REVOKED))
 		return VM_FAULT_SIGBUS;
@@ -2514,7 +2575,7 @@ int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!pte)
 		return VM_FAULT_OOM;
 
-	return handle_pte_fault(mm, vma, address, pte, pmd, write_access);
+	return handle_pte_fault(mm, vma, address, pte, pmd, access_mask);
 }
 
 EXPORT_SYMBOL_GPL(__handle_mm_fault);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
