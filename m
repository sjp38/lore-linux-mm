Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B997D6B026E
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:43:42 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f8so3976114pgs.9
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:43:42 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x32si3069112pld.64.2017.12.14.03.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 03:43:35 -0800 (PST)
Message-Id: <20171214113851.947543516@infradead.org>
Date: Thu, 14 Dec 2017 12:27:43 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH v2 17/17] x86/ldt: Make it read only VMA mapped
References: <20171214112726.742649793@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=x86-ldt--Make-it-VMA-mapped.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

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
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -67,24 +67,48 @@ static void __ldt_install(void *__mm)
 
 	if (this_cpu_read(cpu_tlbstate.loaded_mm) == mm &&
 	    !(current->flags & PF_KTHREAD)) {
-		unsigned int nentries = ldt ? ldt->nr_entries : 0;
-
-		set_ldt(ldt->entries, nentries);
-		refresh_ldt_segments();
+		if (ldt) {
+			set_ldt(ldt->entries, ldt->nr_entries);
+			refresh_ldt_segments();
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
@@ -277,53 +301,68 @@ static int ldt_mmap(struct mm_struct *mm
 	return ret;
 }
 
-/* The caller must call finalize_ldt_struct on the result. LDT starts zeroed. */
-static struct ldt_struct *alloc_ldt_struct(unsigned int num_entries)
+/*
+ * Called on fork from arch_dup_mmap(). Just copy the current LDT state,
+ * the new task is not running, so nothing can be installed.
+ */
+int ldt_dup_context(struct mm_struct *old_mm, struct mm_struct *mm)
 {
-	struct ldt_struct *new_ldt;
-	unsigned int alloc_size;
+	struct ldt_mapping *old_lmap, *lmap;
+	struct vm_area_struct *vma;
+	struct ldt_struct *old_ldt;
+	unsigned long addr, len;
+	int nentries, ret = 0;
 
-	if (num_entries > LDT_ENTRIES)
-		return NULL;
+	if (!old_mm)
+		return 0;
 
-	new_ldt = kmalloc(sizeof(struct ldt_struct), GFP_KERNEL);
-	if (!new_ldt)
-		return NULL;
+	mutex_lock(&old_mm->context.lock);
+	old_lmap = old_mm->context.ldt_mapping;
+	if (!old_lmap || !old_mm->context.ldt)
+		goto out_unlock;
+
+	old_ldt = old_mm->context.ldt;
+	nentries = old_ldt->nr_entries;
+	if (!nentries)
+		goto out_unlock;
+	lmap = ldt_alloc_lmap(mm, nentries);
+	if (IS_ERR(lmap)) {
+		ret = PTR_ERR(lmap);
+		goto out_unlock;
+	}
 
-	BUILD_BUG_ON(LDT_ENTRY_SIZE != sizeof(struct desc_struct));
-	alloc_size = num_entries * LDT_ENTRY_SIZE;
+	addr = (unsigned long)old_mm->context.ldt_mapping->ldts[0].entries;
+	vma = find_vma(mm, addr);
+	if (!vma)
+		goto out_lmap;
 
+	mm->context.ldt_mapping = lmap;
 	/*
-	 * Xen is very picky: it requires a page-aligned LDT that has no
-	 * trailing nonzero bytes in any page that contains LDT descriptors.
-	 * Keep it simple: zero the whole allocation and never allocate less
-	 * than PAGE_SIZE.
+	 * Copy the current settings over. Save the number of entries and
+	 * the data.
 	 */
-	if (alloc_size > PAGE_SIZE)
-		new_ldt->entries = vzalloc(alloc_size);
-	else
-		new_ldt->entries = (void *)get_zeroed_page(GFP_KERNEL);
+	lmap->ldts[0].entries = (struct desc_struct *)addr;
+	lmap->ldts[1].entries = (struct desc_struct *)(addr + LDT_ENTRIES_MAP_SIZE);
 
-	if (!new_ldt->entries) {
-		kfree(new_ldt);
-		return NULL;
-	}
+	lmap->ldts[0].nr_entries = nentries;
+	ldt_clone_entries(&lmap->ldts[0], old_ldt, nentries);
 
-	new_ldt->nr_entries = num_entries;
-	return new_ldt;
-}
+	len = ALIGN(nentries * LDT_ENTRY_SIZE, PAGE_SIZE);
+	ret = populate_vma_page_range(vma, addr, addr + len, NULL);
+	if (ret != len / PAGE_SIZE)
+		goto out_lmap;
+	finalize_ldt_struct(&lmap->ldts[0]);
+	mm->context.ldt = &lmap->ldts[0];
+	ret = 0;
 
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
+out_unlock:
+	mutex_unlock(&old_mm->context.lock);
+	return ret;
+out_lmap:
+	mm->context.ldt_mapping = NULL;
+	mutex_unlock(&old_mm->context.lock);
+	ldt_free_lmap(lmap);
+	return -ENOMEM;
 }
 
 /*
@@ -337,55 +376,21 @@ void destroy_context_ldt(struct mm_struc
 	struct ldt_mapping *lmap = mm->context.ldt_mapping;
 	struct ldt_struct *ldt = mm->context.ldt;
 
-	free_ldt_struct(ldt);
-	mm->context.ldt = NULL;
-
 	if (!lmap)
 		return;
-
+	if (ldt)
+		paravirt_free_ldt(ldt->entries, ldt->nr_entries);
+	mm->context.ldt = NULL;
 	mm->context.ldt_mapping = NULL;
 	ldt_free_lmap(lmap);
 }
 
-/*
- * Called on fork from arch_dup_mmap(). Just copy the current LDT state,
- * the new task is not running, so nothing can be installed.
- */
-int ldt_dup_context(struct mm_struct *old_mm, struct mm_struct *mm)
-{
-	struct ldt_struct *new_ldt;
-	int retval = 0;
-
-	if (!old_mm)
-		return 0;
-
-	mutex_lock(&old_mm->context.lock);
-	if (!old_mm->context.ldt)
-		goto out_unlock;
-
-	new_ldt = alloc_ldt_struct(old_mm->context.ldt->nr_entries);
-	if (!new_ldt) {
-		retval = -ENOMEM;
-		goto out_unlock;
-	}
-
-	memcpy(new_ldt->entries, old_mm->context.ldt->entries,
-	       new_ldt->nr_entries * LDT_ENTRY_SIZE);
-	finalize_ldt_struct(new_ldt);
-
-	mm->context.ldt = new_ldt;
-
-out_unlock:
-	mutex_unlock(&old_mm->context.lock);
-	return retval;
-}
-
 static int read_ldt(void __user *ptr, unsigned long nbytes)
 {
 	struct mm_struct *mm = current->mm;
 	struct ldt_struct *ldt;
 	unsigned long tocopy;
-	int ret = 0;
+	int i, ret = 0;
 
 	down_read(&mm->context.ldt_usr_sem);
 
@@ -402,8 +407,14 @@ static int read_ldt(void __user *ptr, un
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
@@ -427,12 +438,13 @@ static int read_default_ldt(void __user
 
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
@@ -454,39 +466,68 @@ static int write_ldt(void __user *ptr, u
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
