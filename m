Date: Fri, 27 Jul 2007 04:19:43 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch][rfc] remove ZERO_PAGE?
Message-ID: <20070727021943.GD13939@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <andrea@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I'd like to see if we can get the ball rolling on this again, and try to
get it in 2.6.24 maybe. Any comments?

---
Inserting a ZERO_PAGE for anonymous read faults appears to be a false
optimisation: if an application is performance critical, it would not
be doing read faults of new memory or at least it could be expected to
write to that memory soon afterwards. If it is memory use is critical,
it should not be touching addresses that it knows to be zero anyway.

eg. Very sparse matrix code might benefit from the ZERO_PAGE, however it
would only be a naive implementation that isn't tuned for memory usage
anyway.

The motivation for this came from a situation where an Altix system
was essentially livelocked tearing down ZERO_PAGE pagetables when an
HPC app aborted during startup. This is also a case of a silly
userspace access pattern, but it did highlight the potential scalability
problem of the ZERO_PAGE, and corner cases where it can really hurt.

Mesuring on my desktop system, there are never many mappings to the
ZERO_PAGE, thus memory usage should not increase too much if we remove
it. My desktop is by no means representative, but it gives some
indication.

When running a make -j4 kernel compile on my dual core system, there are
about 1,000 mappings to the ZERO_PAGE created per second, and about 1,000
ZERO_PAGE COW faults per second! (Less than 1 ZERO_PAGE mapping per second
is torn down without being COWed). So this patch will save 1,000 page
faults per second, and 2,000 bounces of the ZERO_PAGE struct page
cacheline per second when running kbuild, which might end up being a
significant scalability hit on big systems.

The /dev/zero ZERO_PAGE usage and TLB tricks also get nuked. I don't see
much use to them except complexity and useless benchmarks. All other
users of ZERO_PAGE are converted just to use ZERO_PAGE(0) for simplicity.
We can look at replacing them all and ripping out ZERO_PAGE completely
if/when this patch gets in.

Index: linux-2.6/drivers/char/mem.c
===================================================================
--- linux-2.6.orig/drivers/char/mem.c
+++ linux-2.6/drivers/char/mem.c
@@ -625,65 +625,10 @@ static ssize_t splice_write_null(struct 
 	return splice_from_pipe(pipe, out, ppos, len, flags, pipe_to_null);
 }
 
-#ifdef CONFIG_MMU
-/*
- * For fun, we are using the MMU for this.
- */
-static inline size_t read_zero_pagealigned(char __user * buf, size_t size)
-{
-	struct mm_struct *mm;
-	struct vm_area_struct * vma;
-	unsigned long addr=(unsigned long)buf;
-
-	mm = current->mm;
-	/* Oops, this was forgotten before. -ben */
-	down_read(&mm->mmap_sem);
-
-	/* For private mappings, just map in zero pages. */
-	for (vma = find_vma(mm, addr); vma; vma = vma->vm_next) {
-		unsigned long count;
-
-		if (vma->vm_start > addr || (vma->vm_flags & VM_WRITE) == 0)
-			goto out_up;
-		if (vma->vm_flags & (VM_SHARED | VM_HUGETLB))
-			break;
-		count = vma->vm_end - addr;
-		if (count > size)
-			count = size;
-
-		zap_page_range(vma, addr, count, NULL);
-        	if (zeromap_page_range(vma, addr, count, PAGE_COPY))
-			break;
-
-		size -= count;
-		buf += count;
-		addr += count;
-		if (size == 0)
-			goto out_up;
-	}
-
-	up_read(&mm->mmap_sem);
-	
-	/* The shared case is hard. Let's do the conventional zeroing. */ 
-	do {
-		unsigned long unwritten = clear_user(buf, PAGE_SIZE);
-		if (unwritten)
-			return size + unwritten - PAGE_SIZE;
-		cond_resched();
-		buf += PAGE_SIZE;
-		size -= PAGE_SIZE;
-	} while (size);
-
-	return size;
-out_up:
-	up_read(&mm->mmap_sem);
-	return size;
-}
-
 static ssize_t read_zero(struct file * file, char __user * buf, 
 			 size_t count, loff_t *ppos)
 {
-	unsigned long left, unwritten, written = 0;
+	size_t written;
 
 	if (!count)
 		return 0;
@@ -691,69 +636,33 @@ static ssize_t read_zero(struct file * f
 	if (!access_ok(VERIFY_WRITE, buf, count))
 		return -EFAULT;
 
-	left = count;
-
-	/* do we want to be clever? Arbitrary cut-off */
-	if (count >= PAGE_SIZE*4) {
-		unsigned long partial;
-
-		/* How much left of the page? */
-		partial = (PAGE_SIZE-1) & -(unsigned long) buf;
-		unwritten = clear_user(buf, partial);
-		written = partial - unwritten;
+	written = 0;
+	while (count) {
+		unsigned long unwritten;
+		size_t chunk = count;
+
+		if (chunk > PAGE_SIZE)
+			chunk = PAGE_SIZE;	/* Just for latency reasons */
+		unwritten = clear_user(buf, chunk);
+		written += chunk - unwritten;
 		if (unwritten)
-			goto out;
-		left -= partial;
-		buf += partial;
-		unwritten = read_zero_pagealigned(buf, left & PAGE_MASK);
-		written += (left & PAGE_MASK) - unwritten;
-		if (unwritten)
-			goto out;
-		buf += left & PAGE_MASK;
-		left &= ~PAGE_MASK;
-	}
-	unwritten = clear_user(buf, left);
-	written += left - unwritten;
-out:
-	return written ? written : -EFAULT;
-}
-
-static int mmap_zero(struct file * file, struct vm_area_struct * vma)
-{
-	int err;
-
-	if (vma->vm_flags & VM_SHARED)
-		return shmem_zero_setup(vma);
-	err = zeromap_page_range(vma, vma->vm_start,
-			vma->vm_end - vma->vm_start, vma->vm_page_prot);
-	BUG_ON(err == -EEXIST);
-	return err;
-}
-#else /* CONFIG_MMU */
-static ssize_t read_zero(struct file * file, char * buf, 
-			 size_t count, loff_t *ppos)
-{
-	size_t todo = count;
-
-	while (todo) {
-		size_t chunk = todo;
-
-		if (chunk > 4096)
-			chunk = 4096;	/* Just for latency reasons */
-		if (clear_user(buf, chunk))
-			return -EFAULT;
+			break;
 		buf += chunk;
-		todo -= chunk;
+		count -= chunk;
 		cond_resched();
 	}
-	return count;
+	return written ? written : -EFAULT;
 }
 
 static int mmap_zero(struct file * file, struct vm_area_struct * vma)
 {
+#ifndef CONFIG_MMU
 	return -ENOSYS;
+#endif
+	if (vma->vm_flags & VM_SHARED)
+		return shmem_zero_setup(vma);
+	return 0;
 }
-#endif /* CONFIG_MMU */
 
 static ssize_t write_full(struct file * file, const char __user * buf,
 			  size_t count, loff_t *ppos)
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -778,8 +778,6 @@ void free_pgtables(struct mmu_gather **t
 		unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
-int zeromap_page_range(struct vm_area_struct *vma, unsigned long from,
-			unsigned long size, pgprot_t prot);
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
 
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -966,7 +966,7 @@ no_page_table:
 	 * has touched so far, we don't want to allocate page tables.
 	 */
 	if (flags & FOLL_ANON) {
-		page = ZERO_PAGE(address);
+		page = ZERO_PAGE(0);
 		if (flags & FOLL_GET)
 			get_page(page);
 		BUG_ON(flags & FOLL_WRITE);
@@ -1111,95 +1111,6 @@ int get_user_pages(struct task_struct *t
 }
 EXPORT_SYMBOL(get_user_pages);
 
-static int zeromap_pte_range(struct mm_struct *mm, pmd_t *pmd,
-			unsigned long addr, unsigned long end, pgprot_t prot)
-{
-	pte_t *pte;
-	spinlock_t *ptl;
-	int err = 0;
-
-	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
-	if (!pte)
-		return -EAGAIN;
-	arch_enter_lazy_mmu_mode();
-	do {
-		struct page *page = ZERO_PAGE(addr);
-		pte_t zero_pte = pte_wrprotect(mk_pte(page, prot));
-
-		if (unlikely(!pte_none(*pte))) {
-			err = -EEXIST;
-			pte++;
-			break;
-		}
-		page_cache_get(page);
-		page_add_file_rmap(page);
-		inc_mm_counter(mm, file_rss);
-		set_pte_at(mm, addr, pte, zero_pte);
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	arch_leave_lazy_mmu_mode();
-	pte_unmap_unlock(pte - 1, ptl);
-	return err;
-}
-
-static inline int zeromap_pmd_range(struct mm_struct *mm, pud_t *pud,
-			unsigned long addr, unsigned long end, pgprot_t prot)
-{
-	pmd_t *pmd;
-	unsigned long next;
-	int err;
-
-	pmd = pmd_alloc(mm, pud, addr);
-	if (!pmd)
-		return -EAGAIN;
-	do {
-		next = pmd_addr_end(addr, end);
-		err = zeromap_pte_range(mm, pmd, addr, next, prot);
-		if (err)
-			break;
-	} while (pmd++, addr = next, addr != end);
-	return err;
-}
-
-static inline int zeromap_pud_range(struct mm_struct *mm, pgd_t *pgd,
-			unsigned long addr, unsigned long end, pgprot_t prot)
-{
-	pud_t *pud;
-	unsigned long next;
-	int err;
-
-	pud = pud_alloc(mm, pgd, addr);
-	if (!pud)
-		return -EAGAIN;
-	do {
-		next = pud_addr_end(addr, end);
-		err = zeromap_pmd_range(mm, pud, addr, next, prot);
-		if (err)
-			break;
-	} while (pud++, addr = next, addr != end);
-	return err;
-}
-
-int zeromap_page_range(struct vm_area_struct *vma,
-			unsigned long addr, unsigned long size, pgprot_t prot)
-{
-	pgd_t *pgd;
-	unsigned long next;
-	unsigned long end = addr + size;
-	struct mm_struct *mm = vma->vm_mm;
-	int err;
-
-	BUG_ON(addr >= end);
-	pgd = pgd_offset(mm, addr);
-	flush_cache_range(vma, addr, end);
-	do {
-		next = pgd_addr_end(addr, end);
-		err = zeromap_pud_range(mm, pgd, addr, next, prot);
-		if (err)
-			break;
-	} while (pgd++, addr = next, addr != end);
-	return err;
-}
-
 pte_t * fastcall get_locked_pte(struct mm_struct *mm, unsigned long addr, spinlock_t **ptl)
 {
 	pgd_t * pgd = pgd_offset(mm, addr);
@@ -1714,16 +1625,11 @@ gotten:
 
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
-	if (old_page == ZERO_PAGE(address)) {
-		new_page = alloc_zeroed_user_highpage_movable(vma, address);
-		if (!new_page)
-			goto oom;
-	} else {
-		new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
-		if (!new_page)
-			goto oom;
-		cow_user_page(new_page, old_page, address, vma);
-	}
+	VM_BUG_ON(old_page == ZERO_PAGE(0));
+	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
+	if (!new_page)
+		goto oom;
+	cow_user_page(new_page, old_page, address, vma);
 
 	/*
 	 * Re-check the pte - we dropped the lock
@@ -2249,39 +2155,24 @@ static int do_anonymous_page(struct mm_s
 	spinlock_t *ptl;
 	pte_t entry;
 
-	if (write_access) {
-		/* Allocate our own private page. */
-		pte_unmap(page_table);
-
-		if (unlikely(anon_vma_prepare(vma)))
-			goto oom;
-		page = alloc_zeroed_user_highpage_movable(vma, address);
-		if (!page)
-			goto oom;
-
-		entry = mk_pte(page, vma->vm_page_prot);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	/* Allocate our own private page. */
+	pte_unmap(page_table);
 
-		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-		if (!pte_none(*page_table))
-			goto release;
-		inc_mm_counter(mm, anon_rss);
-		lru_cache_add_active(page);
-		page_add_new_anon_rmap(page, vma, address);
-	} else {
-		/* Map the ZERO_PAGE - vm_page_prot is readonly */
-		page = ZERO_PAGE(address);
-		page_cache_get(page);
-		entry = mk_pte(page, vma->vm_page_prot);
+	if (unlikely(anon_vma_prepare(vma)))
+		goto oom;
+	page = alloc_zeroed_user_highpage_movable(vma, address);
+	if (!page)
+		goto oom;
 
-		ptl = pte_lockptr(mm, pmd);
-		spin_lock(ptl);
-		if (!pte_none(*page_table))
-			goto release;
-		inc_mm_counter(mm, file_rss);
-		page_add_file_rmap(page);
-	}
+	entry = mk_pte(page, vma->vm_page_prot);
+	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 
+	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (!pte_none(*page_table))
+		goto release;
+	inc_mm_counter(mm, anon_rss);
+	lru_cache_add_active(page);
+	page_add_new_anon_rmap(page, vma, address);
 	set_pte_at(mm, address, page_table, entry);
 
 	/* No need to invalidate - it was non-present before */
Index: linux-2.6/fs/binfmt_elf.c
===================================================================
--- linux-2.6.orig/fs/binfmt_elf.c
+++ linux-2.6/fs/binfmt_elf.c
@@ -1733,7 +1733,7 @@ static int elf_core_dump(long signr, str
 						&page, &vma) <= 0) {
 				DUMP_SEEK(PAGE_SIZE);
 			} else {
-				if (page == ZERO_PAGE(addr)) {
+				if (page == ZERO_PAGE(0)) {
 					if (!dump_seek(file, PAGE_SIZE)) {
 						page_cache_release(page);
 						goto end_coredump;
Index: linux-2.6/fs/binfmt_elf_fdpic.c
===================================================================
--- linux-2.6.orig/fs/binfmt_elf_fdpic.c
+++ linux-2.6/fs/binfmt_elf_fdpic.c
@@ -1488,7 +1488,7 @@ static int elf_fdpic_dump_segments(struc
 					   &page, &vma) <= 0) {
 				DUMP_SEEK(file->f_pos + PAGE_SIZE);
 			}
-			else if (page == ZERO_PAGE(addr)) {
+			else if (page == ZERO_PAGE(0)) {
 				page_cache_release(page);
 				DUMP_SEEK(file->f_pos + PAGE_SIZE);
 			}
Index: linux-2.6/fs/direct-io.c
===================================================================
--- linux-2.6.orig/fs/direct-io.c
+++ linux-2.6/fs/direct-io.c
@@ -163,7 +163,7 @@ static int dio_refill_pages(struct dio *
 	up_read(&current->mm->mmap_sem);
 
 	if (ret < 0 && dio->blocks_available && (dio->rw & WRITE)) {
-		struct page *page = ZERO_PAGE(dio->curr_user_address);
+		struct page *page = ZERO_PAGE(0);
 		/*
 		 * A memory fault, but the filesystem has some outstanding
 		 * mapped blocks.  We need to use those blocks up to avoid
@@ -772,7 +772,7 @@ static void dio_zero_block(struct dio *d
 
 	this_chunk_bytes = this_chunk_blocks << dio->blkbits;
 
-	page = ZERO_PAGE(dio->curr_user_address);
+	page = ZERO_PAGE(0);
 	if (submit_page_section(dio, page, 0, this_chunk_bytes, 
 				dio->next_block_for_io))
 		return;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
