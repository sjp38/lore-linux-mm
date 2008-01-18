Subject: Re: [PATCH -v6 2/2] Updating ctime and mtime for memory-mapped
	files
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1JFobo-00009i-Dk@pomaz-ex.szeredi.hu>
References: <12006091182260-git-send-email-salikhmetov@gmail.com>
	 <12006091211208-git-send-email-salikhmetov@gmail.com>
	 <E1JFnsg-0008UU-LU@pomaz-ex.szeredi.hu> <1200651337.5920.9.camel@twins>
	 <E1JFobo-00009i-Dk@pomaz-ex.szeredi.hu>
Content-Type: text/plain
Date: Fri, 18 Jan 2008 12:00:50 +0100
Message-Id: <1200654050.5920.14.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-01-18 at 11:38 +0100, Miklos Szeredi wrote:
> > On Fri, 2008-01-18 at 10:51 +0100, Miklos Szeredi wrote:
> > 
> > > > diff --git a/mm/msync.c b/mm/msync.c
> > > > index a4de868..a49af28 100644
> > > > --- a/mm/msync.c
> > > > +++ b/mm/msync.c
> > > > @@ -13,11 +13,33 @@
> > > >  #include <linux/syscalls.h>
> > > >  
> > > >  /*
> > > > + * Scan the PTEs for pages belonging to the VMA and mark them read-only.
> > > > + * It will force a pagefault on the next write access.
> > > > + */
> > > > +static void vma_wrprotect(struct vm_area_struct *vma)
> > > > +{
> > > > +	unsigned long addr;
> > > > +
> > > > +	for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE) {
> > > > +		spinlock_t *ptl;
> > > > +		pgd_t *pgd = pgd_offset(vma->vm_mm, addr);
> > > > +		pud_t *pud = pud_offset(pgd, addr);
> > > > +		pmd_t *pmd = pmd_offset(pud, addr);
> > > > +		pte_t *pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > > > +
> > > > +		if (pte_dirty(*pte) && pte_write(*pte))
> > > > +			*pte = pte_wrprotect(*pte);
> > > > +		pte_unmap_unlock(pte, ptl);
> > > > +	}
> > > > +}
> > > 
> > > What about ram based filesystems?  They don't start out with read-only
> > > pte's, so I think they don't want them read-protected now either.
> > > Unless this is essential for correct mtime/ctime accounting on these
> > > filesystems (I don't think it really is).  But then the mapping should
> > > start out read-only as well, otherwise the time update will only work
> > > after an msync(MS_ASYNC).
> > 
> > page_mkclean() has all the needed logic for this, it also walks the rmap
> > and cleans out all other users, which I think is needed too for
> > consistencies sake:
> > 
> > Process A			Process B
> > 
> > mmap(foo.txt)			mmap(foo.txt)
> > 
> > dirty page
> > 				dirty page
> > 
> > msync(MS_ASYNC)
> > 
> > 				dirty page
> > 
> > msync(MS_ASYNC) <--- now what?!

how about:

diff --git a/mm/msync.c b/mm/msync.c
index 144a757..a1b3fc6 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -14,6 +14,122 @@
 #include <linux/syscalls.h>
 #include <linux/sched.h>
 
+unsigned long masync_pte_range(struct vm_area_struct *vma, pmd_t *pdm,
+		unsigned long addr, unsigned long end)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	arch_enter_lazy_mmu_mode();
+	do {
+		pte_t ptent = *pte;
+
+		if (pte_none(ptent))
+			continue;
+
+		if (!pte_present(ptent))
+			continue;
+
+		if (pte_dirty(ptent) && pte_write(ptent)) {
+			flush_cache_page(vma, addr, pte_pfn(ptent));
+			ptent = ptep_clear_flush(vma, addr, pte);
+			ptent = pte_wrprotect(ptent);
+			set_pte_at(vma->vm_mnm, addr, pte, ptent);
+		}
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	arch_leave_lazy_mmu_mode();
+	pte_unmap_unlock(pte - 1, ptl);
+
+	return addr;
+}
+
+unsigned long masync_pmd_range(struct vm_area_struct *vma, pud_t *pud,
+		unsigned long addr, unsigned long end)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		next = masync_pte_range(vma, pmd, addr, next);
+	} while (pmd++, addr = next, addr != end);
+
+	return addr;
+}
+
+unsigned long masync_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
+	       	unsigned long addr, unsigned long end)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		next = masync_pmd_range(vma, pud, addr, next);
+	} while (pud++, addr = next, addr != end);
+
+	return addr;
+}
+
+unsigned long masync_pgd_range()
+{
+	pgd_t *pgd;
+	unsigned long next;
+
+	pgd = pgd_offset(vma->vm_mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_of_clear_bad(pgd))
+			continue;
+		next = masync_pud_range(vma, pgd, addr, next);
+	} while (pgd++, addr = next, addr != end);
+
+	return addr;
+}
+
+int masync_vma_one(struct vm_area_struct *vma,
+		unsigned long start, unsigned long end)
+{
+	if (start < vma->vm_start)
+		start = vma->vm_start;
+
+	if (end > vma->vm_end)
+		end = vma->vm_end;
+
+	masync_pgd_range(vma, start, end);
+
+	return 0;
+}
+
+int masync_vma(struct vm_area_struct *vma, 
+		unsigned long start, unsigned long end)
+{
+	struct address_space *mapping;
+	struct vm_area_struct *vma_iter;
+
+	if (!(vma->vm_flags & VM_SHARED))
+		return 0;
+
+	mapping = vma->vm_file->f_mapping;
+
+	if (!mapping_cap_account_dirty(mapping))
+		return 0;
+
+	spin_lock(&mapping->i_mmap_lock);
+	vma_prio_tree_foreach(vma_iter, &iter, &mapping->i_mmap, start, end)
+		masync_vma_one(vma_iter, start, end);
+	spin_unlock(&mapping->i_mmap_lock);
+
+	return 0;
+}
+
 /*
  * MS_SYNC syncs the entire file - including mappings.
  *



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
