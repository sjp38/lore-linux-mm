Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 78C146B0268
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:34:54 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id k104so12677930wrc.19
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 09:34:54 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id t123si53763wmd.53.2017.12.12.09.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 09:34:53 -0800 (PST)
Message-Id: <20171212173334.591406219@linutronix.de>
Date: Tue, 12 Dec 2017 18:32:37 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 16/16] x86/ldt: Make it read only VMA mapped
References: <20171212173221.496222173@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=x86-ldt--Make-it-VMA-mapped.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org

From: Thomas Gleixner <tglx@linutronix.de>

Replace the existing LDT allocation and installation code by the new VMA
based mapping code. The mapping is exposed read only to user space so it is
accessible when the CPU executes in ring 3. The access to the backing pages
is not a linear VA space to avoid an extra alias mapping or the allocation
of higher order pages.

The special write fault handler and the touch mechanism on exit to user
space makes sure that the expectations of the CPU are met.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/kernel/ldt.c |  282 +++++++++++++++++++++++++++++---------------------
 1 file changed, 165 insertions(+), 117 deletions(-)

--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -67,25 +67,49 @@ static void __ldt_install(void *__mm)
 
 	if (this_cpu_read(cpu_tlbstate.loaded_mm) == mm &&
 	    !(current->flags & PF_KTHREAD)) {
-		unsigned int nentries = ldt ? ldt->nr_entries : 0;
-
-		set_ldt(ldt->entries, nentries);
-		refresh_ldt_segments();
-		set_tsk_thread_flag(current, TIF_LDT);
+		if (ldt) {
+			set_ldt(ldt->entries, ldt->nr_entries);
+			refresh_ldt_segments();
+			set_tsk_thread_flag(current, TIF_LDT);
+		} else {
+			set_ldt(NULL, 0);
+		}
 	}
 }
 
 static void ldt_install_mm(struct mm_struct *mm, struct ldt_struct *ldt)
 {
-	mutex_lock(&mm->context.lock);
+	lockdep_assert_held(&mm->context.lock);
 
 	/* Synchronizes with READ_ONCE in load_mm_ldt. */
 	smp_store_release(&mm->context.ldt, ldt);
 
 	/* Activate the LDT for all CPUs using currents mm. */
 	on_each_cpu_mask(mm_cpumask(mm), __ldt_install, mm, true);
+}
 
-	mutex_unlock(&mm->context.lock);
+static int ldt_populate(struct ldt_struct *ldt)
+{
+	unsigned long len, start = (unsigned long)ldt->entries;
+
+	len = round_up(ldt->nr_entries * LDT_ENTRY_SIZE, PAGE_SIZE);
+	return __mm_populate(start, len, 0);
+}
+
+/* Install the new LDT after populating the user space mapping. */
+static int ldt_install(struct mm_struct *mm, struct ldt_struct *ldt)
+{
+	int ret = ldt ? ldt_populate(ldt) : 0;
+
+	if (!ret) {
+		mutex_lock(&mm->context.lock);
+		if (mm->context.ldt_mapping->ldt_mapped)
+			ldt_install_mm(mm, ldt);
+		else
+			ret = -EINVAL;
+		mutex_unlock(&mm->context.lock);
+	}
+	return ret;
 }
 
 static void ldt_free_pages(struct ldt_struct *ldt)
@@ -193,9 +217,11 @@ static void cleanup_ldt_struct(struct ld
  */
 bool __ldt_write_fault(unsigned long address)
 {
-	struct ldt_struct *ldt = current->mm->context.ldt;
+	struct ldt_mapping *lmap = current->mm->context.ldt_mapping;
+	struct ldt_struct *ldt = lmap->ldts;
 	unsigned long start, end, entry;
 	struct desc_struct *desc;
+	struct page *page;
 
 	start = (unsigned long) ldt->entries;
 	end = start + ldt->nr_entries * LDT_ENTRY_SIZE;
@@ -203,8 +229,12 @@ bool __ldt_write_fault(unsigned long add
 	if (address < start || address >= end)
 		return false;
 
-	desc = (struct desc_struct *) ldt->entries;
-	entry = (address - start) / LDT_ENTRY_SIZE;
+	page = ldt->pages[(address - start) / PAGE_SIZE];
+	if (!page)
+		return false;
+
+	desc = page_address(page);
+	entry = ((address - start) % PAGE_SIZE) / LDT_ENTRY_SIZE;
 	desc[entry].type |= 0x01;
 	return true;
 }
@@ -308,107 +338,69 @@ static int ldt_mmap(struct mm_struct *mm
 	return ret;
 }
 
-/* The caller must call finalize_ldt_struct on the result. LDT starts zeroed. */
-static struct ldt_struct *alloc_ldt_struct(unsigned int num_entries)
-{
-	struct ldt_struct *new_ldt;
-	unsigned int alloc_size;
-
-	if (num_entries > LDT_ENTRIES)
-		return NULL;
-
-	new_ldt = kmalloc(sizeof(struct ldt_struct), GFP_KERNEL);
-	if (!new_ldt)
-		return NULL;
-
-	BUILD_BUG_ON(LDT_ENTRY_SIZE != sizeof(struct desc_struct));
-	alloc_size = num_entries * LDT_ENTRY_SIZE;
-
-	/*
-	 * Xen is very picky: it requires a page-aligned LDT that has no
-	 * trailing nonzero bytes in any page that contains LDT descriptors.
-	 * Keep it simple: zero the whole allocation and never allocate less
-	 * than PAGE_SIZE.
-	 */
-	if (alloc_size > PAGE_SIZE)
-		new_ldt->entries = vzalloc(alloc_size);
-	else
-		new_ldt->entries = (void *)get_zeroed_page(GFP_KERNEL);
-
-	if (!new_ldt->entries) {
-		kfree(new_ldt);
-		return NULL;
-	}
-
-	new_ldt->nr_entries = num_entries;
-	return new_ldt;
-}
-
-static void free_ldt_struct(struct ldt_struct *ldt)
-{
-	if (likely(!ldt))
-		return;
-
-	paravirt_free_ldt(ldt->entries, ldt->nr_entries);
-	if (ldt->nr_entries * LDT_ENTRY_SIZE > PAGE_SIZE)
-		vfree_atomic(ldt->entries);
-	else
-		free_page((unsigned long)ldt->entries);
-	kfree(ldt);
-}
-
 /*
  * Called on fork from arch_dup_mmap(). Just copy the current LDT state,
  * the new task is not running, so nothing can be installed.
  */
 int ldt_dup_context(struct mm_struct *old_mm, struct mm_struct *mm)
 {
-	struct ldt_struct *new_ldt;
-	int retval = 0;
+	struct ldt_mapping *old_lmap, *lmap;
+	struct vm_area_struct *vma;
+	struct ldt_struct *old_ldt;
+	unsigned long addr, len;
+	int nentries, ret = 0;
 
 	if (!old_mm)
 		return 0;
 
 	mutex_lock(&old_mm->context.lock);
-	if (!old_mm->context.ldt)
+	old_lmap = old_mm->context.ldt_mapping;
+	if (!old_lmap || !old_mm->context.ldt)
 		goto out_unlock;
 
-	new_ldt = alloc_ldt_struct(old_mm->context.ldt->nr_entries);
-	if (!new_ldt) {
-		retval = -ENOMEM;
+	old_ldt = old_mm->context.ldt;
+	nentries = old_ldt->nr_entries;
+	if (!nentries)
 		goto out_unlock;
-	}
 
-	memcpy(new_ldt->entries, old_mm->context.ldt->entries,
-	       new_ldt->nr_entries * LDT_ENTRY_SIZE);
-	finalize_ldt_struct(new_ldt);
-
-	mm->context.ldt = new_ldt;
+	lmap = ldt_alloc_lmap(mm, nentries);
+	if (IS_ERR(lmap)) {
+		ret = PTR_ERR(lmap);
+		goto out_unlock;
+	}
 
-out_unlock:
-	mutex_unlock(&old_mm->context.lock);
-	return retval;
-}
+	addr = (unsigned long)old_mm->context.ldt_mapping->ldts[0].entries;
+	vma = find_vma(mm, addr);
+	if (!vma)
+		goto out_lmap;
 
-/*
- * This can run unlocked because the mm is no longer in use. No need to
- * clear LDT on the CPU either because that's called from __mm_drop() and
- * the task which owned the mm is already dead. The context switch code has
- * either cleared LDT or installed a new one.
- */
-void destroy_context_ldt(struct mm_struct *mm)
-{
-	struct ldt_mapping *lmap = mm->context.ldt_mapping;
-	struct ldt_struct *ldt = mm->context.ldt;
+	mm->context.ldt_mapping = lmap;
+	/*
+	 * Copy the current settings over. Save the number of entries and
+	 * the data.
+	 */
+	lmap->ldts[0].entries = (struct desc_struct *)addr;
+	lmap->ldts[1].entries = (struct desc_struct *)(addr + LDT_ENTRIES_MAP_SIZE);
 
-	free_ldt_struct(ldt);
-	mm->context.ldt = NULL;
+	lmap->ldts[0].nr_entries = nentries;
+	ldt_clone_entries(&lmap->ldts[0], old_ldt, nentries);
 
-	if (!lmap)
-		return;
+	len = ALIGN(nentries * LDT_ENTRY_SIZE, PAGE_SIZE);
+	ret = populate_vma_page_range(vma, addr, addr + len, NULL);
+	if (ret != len / PAGE_SIZE)
+		goto out_lmap;
+	finalize_ldt_struct(&lmap->ldts[0]);
+	mm->context.ldt = &lmap->ldts[0];
+	ret = 0;
 
+out_unlock:
+	mutex_unlock(&old_mm->context.lock);
+	return ret;
+out_lmap:
 	mm->context.ldt_mapping = NULL;
+	mutex_unlock(&old_mm->context.lock);
 	ldt_free_lmap(lmap);
+	return -ENOMEM;
 }
 
 /*
@@ -441,12 +433,32 @@ void ldt_exit_user(struct pt_regs *regs)
 	ldt_touch_seg(regs->ss);
 }
 
+/*
+ * This can run unlocked because the mm is no longer in use. No need to
+ * clear LDT on the CPU either because that's called from __mm_drop() and
+ * the task which owned the mm is already dead. The context switch code has
+ * either cleared LDT or installed a new one.
+ */
+void destroy_context_ldt(struct mm_struct *mm)
+{
+	struct ldt_mapping *lmap = mm->context.ldt_mapping;
+	struct ldt_struct *ldt = mm->context.ldt;
+
+	if (!lmap)
+		return;
+	if (ldt)
+		paravirt_free_ldt(ldt->entries, ldt->nr_entries);
+	mm->context.ldt = NULL;
+	mm->context.ldt_mapping = NULL;
+	ldt_free_lmap(lmap);
+}
+
 static int read_ldt(void __user *ptr, unsigned long nbytes)
 {
 	struct mm_struct *mm = current->mm;
 	struct ldt_struct *ldt;
 	unsigned long tocopy;
-	int ret = 0;
+	int i, ret = 0;
 
 	down_read(&mm->context.ldt_usr_sem);
 
@@ -463,8 +475,14 @@ static int read_ldt(void __user *ptr, un
 	if (tocopy < nbytes && clear_user(ptr + tocopy, nbytes - tocopy))
 		goto out_unlock;
 
-	if (copy_to_user(ptr, ldt->entries, tocopy))
-		goto out_unlock;
+	for (i = 0; tocopy; i++) {
+		unsigned long n = min(PAGE_SIZE, tocopy);
+
+		if (copy_to_user(ptr, page_address(ldt->pages[i]), n))
+			goto out_unlock;
+		tocopy -= n;
+		ptr += n;
+	}
 	ret = nbytes;
 out_unlock:
 	up_read(&mm->context.ldt_usr_sem);
@@ -488,12 +506,13 @@ static int read_default_ldt(void __user
 
 static int write_ldt(void __user *ptr, unsigned long bytecount, int oldmode)
 {
-	struct mm_struct *mm = current->mm;
 	struct ldt_struct *new_ldt, *old_ldt;
-	unsigned int old_nr_entries, new_nr_entries;
+	unsigned int nold, nentries, ldtidx;
+	struct mm_struct *mm = current->mm;
 	struct user_desc ldt_info;
-	struct desc_struct ldt;
-	int error;
+	struct ldt_mapping *lmap;
+	struct desc_struct entry;
+	int error, mapped;
 
 	error = -EINVAL;
 	if (bytecount != sizeof(ldt_info))
@@ -515,39 +534,68 @@ static int write_ldt(void __user *ptr, u
 	if ((oldmode && !ldt_info.base_addr && !ldt_info.limit) ||
 	    LDT_empty(&ldt_info)) {
 		/* The user wants to clear the entry. */
-		memset(&ldt, 0, sizeof(ldt));
+		memset(&entry, 0, sizeof(entry));
 	} else {
-		if (!IS_ENABLED(CONFIG_X86_16BIT) && !ldt_info.seg_32bit) {
-			error = -EINVAL;
+		if (!IS_ENABLED(CONFIG_X86_16BIT) && !ldt_info.seg_32bit)
 			goto out;
-		}
-
-		fill_ldt(&ldt, &ldt_info);
+		fill_ldt(&entry, &ldt_info);
 		if (oldmode)
-			ldt.avl = 0;
+			entry.avl = 0;
 	}
 
 	if (down_write_killable(&mm->context.ldt_usr_sem))
 		return -EINTR;
 
-	old_ldt       = mm->context.ldt;
-	old_nr_entries = old_ldt ? old_ldt->nr_entries : 0;
-	new_nr_entries = max(ldt_info.entry_number + 1, old_nr_entries);
-
-	error = -ENOMEM;
-	new_ldt = alloc_ldt_struct(new_nr_entries);
-	if (!new_ldt)
+	lmap = mm->context.ldt_mapping;
+	old_ldt = mm->context.ldt;
+	ldtidx = lmap ? lmap->ldt_index ^ 1 : 0;
+
+	if (!lmap) {
+		/* First invocation, install it. */
+		nentries = ldt_info.entry_number + 1;
+		lmap = ldt_alloc_lmap(mm, nentries);
+		if (IS_ERR(lmap)) {
+			error = PTR_ERR(lmap);
+			goto out_unlock;
+		}
+		mm->context.ldt_mapping = lmap;
+	}
+
+	/*
+	 * ldt_close() can clear lmap->ldt_mapped under context.lock, so
+	 * lmap->ldt_mapped needs to be read under that lock as well.
+	 *
+	 * If !mapped, try and establish the mapping; this code is fully
+	 * serialized under ldt_usr_sem. If the VMA vanishes after dropping
+	 * the lock, then ldt_install() will fail later on.
+	 */
+	mutex_lock(&mm->context.lock);
+	mapped = lmap->ldt_mapped;
+	mutex_unlock(&mm->context.lock);
+	if (!mapped) {
+		error = ldt_mmap(mm, lmap);
+		if (error)
+			goto out_unlock;
+	}
+
+	nold = old_ldt ? old_ldt->nr_entries : 0;
+	nentries = max(ldt_info.entry_number + 1, nold);
+	/* Select the new ldt and allocate pages if necessary */
+	new_ldt = &lmap->ldts[ldtidx];
+	error = ldt_alloc_pages(new_ldt, nentries);
+	if (error)
 		goto out_unlock;
 
-	if (old_ldt)
-		memcpy(new_ldt->entries, old_ldt->entries, old_nr_entries * LDT_ENTRY_SIZE);
+	if (nold)
+		ldt_clone_entries(new_ldt, old_ldt, nold);
 
-	new_ldt->entries[ldt_info.entry_number] = ldt;
+	ldt_set_entry(new_ldt, &entry, ldt_info.entry_number);
+	new_ldt->nr_entries = nentries;
+	lmap->ldt_index = ldtidx;
 	finalize_ldt_struct(new_ldt);
-
-	ldt_install_mm(mm, new_ldt);
-	free_ldt_struct(old_ldt);
-	error = 0;
+	/* Install the new LDT. Might fail due to vm_unmap() or ENOMEM */
+	error = ldt_install(mm, new_ldt);
+	cleanup_ldt_struct(error ? new_ldt : old_ldt);
 
 out_unlock:
 	up_write(&mm->context.ldt_usr_sem);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
