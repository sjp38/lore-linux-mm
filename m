From: Andi Kleen <andi@firstfloor.org>
References: <20080318209.039112899@firstfloor.org>
In-Reply-To: <20080318209.039112899@firstfloor.org>
Subject: [PATCH prototype] [6/8] Core predictive bitmap engine
Message-Id: <20080318010940.5B2081B41E1@basil.firstfloor.org>
Date: Tue, 18 Mar 2008 02:09:40 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patchkit is an experimental optimization I played around with 
some time ago.

This is more a prototype still, but I wanted to push it out 
so that other people can play with it.

The basic idea is that most programs have the same working set
over multiple runs. So instead of demand paging all the text pages
in the order the program runs save the working set to disk and prefetch
it at program start and then save it at program exit.

This allows some optimizations: 
- it can avoid unnecessary disk seeks because the blocks will be fetched in 
sorted offset order instead of program execution order. 
- batch kernel entries (each demand page exception has some
overhead just for entering the kernel). This keeps the caches hot too.
- The prefetch could be in theory done in the background while the program 
runs (although that is not implemented currently)

Some details on the implementation:

To do all this we need a bitmap space somewhere in the ELF executable. I originally
hoped to use a standard ELF PHDR for this, which are already parsed by the
Linux ELF loader. However the problem is that PHDRs are part of the 
mapped program image and inserting any new ones requires relinking
the program. Since relinking programs just to get this would be 
rather heavy-handed I used a hack by setting another bitflag 
in the gnu_execstack header and when it is set let the kernel
look for ELF SHDRs at the end of the file. Disadvantage is that
this costs a seek, but it allows easily to update existing 
executables with a simple too.

The seek overhead would be gone if the linkers are taught to 
always generate a PBITMAP bitmap header.

I also considered external bitmap files, but just putting it into the ELF
files and keeping it all together seemed much nicer policywise.

Then there is some probability of thrashing the bitmap, e.g. when
a program runs in different modi with totally different working sets
(a good example of this would be busybox). I haven't found
a good heuristic to handle this yet (e.g. one possibility would
be to or the bitmap instead of rewriting it on exit) this is something
that could need further experimentation. Also one doesn't want
too many bitmap updates of course so there is a simple heuristic 
to not update bitmaps more often than a sysctl configurable 
interval.  

User tools:
ftp://ftp.firstfloor.org/pub/ak/pbitmap/pbitmap.c 
is a simple program to a pbitmap shdrs to an existing ELF executable.

Base kernel:
Again 2.6.25-rc6

Drawbacks: 
- No support for dynamic libraries right now (except very clumpsily
through the mmap_slurp hack). This is the main reason it is not 
very useful for speed up desktops currently. 

- Executable files have to be writable by the user executing it
currently to get bitmap updates. It would be possible to let the 
kernel bypass this, but I haven't thought too much about the security 
implications of it.
However any user can use the bitmap data written by a user with
write rights.

That's currently one of the bigger usability issues (together
with the missing shared library support) and why it is more 
a prototype than a fully usable solution.

Possible areas of improvements if anybody is interested:
- Background prefetch
- Tune all the sysctl defaults
- Implement shared library support (will require glibc support)
- Do something about the executable access problem
- Experiment with more fancy heuristics to update bitmaps (like OR
or do aging etc.) 

Signed-off-by: Andi Kleen <andi@firstfloor.org>

---
 fs/binfmt_elf.c          |  101 +++++++++++
 include/linux/mm.h       |    7 
 include/linux/mm_types.h |    3 
 kernel/fork.c            |    1 
 mm/Makefile              |    2 
 mm/mmap.c                |    1 
 mm/pbitmap.c             |  404 +++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 517 insertions(+), 2 deletions(-)

Index: linux/fs/binfmt_elf.c
===================================================================
--- linux.orig/fs/binfmt_elf.c
+++ linux/fs/binfmt_elf.c
@@ -527,6 +527,89 @@ static unsigned long randomize_stack_top
 #endif
 }
 
+static void elf_read_pb_phdr(struct file *f, struct elf_phdr *phdr, int nhdr)
+{
+	int i, found, err;
+	unsigned long *buf;
+
+	if (!pbitmap_enabled)
+		return;
+	buf = (unsigned long *)__get_free_page(GFP_KERNEL);
+	if (!buf)
+		return;
+	found = 0;
+	for (i = 0; i < nhdr; i++) {
+		struct elf_phdr *ep = &phdr[i];
+		if (ep->p_type != PT_PRESENT_BITMAP)
+			continue;
+
+		err = pbitmap_load(f, buf, ep->p_vaddr, ep->p_offset,
+				   ep->p_filesz);
+		if (err < 0)
+			printk("%s: pbitmap load failed: %d\n",
+			       current->comm, err);
+		else
+			found += err;
+	}
+	if (found > 0)
+		printk("%s: %d pages prefetched\n", current->comm, found);
+	free_page((unsigned long)buf);
+}
+
+/* All errors are ignored because the pbitmap is optional */
+static void elf_read_pb_shdr(struct file *f, struct elfhdr *hdr)
+{
+	int err;
+	unsigned n;
+	void *buf;
+
+	if (!pbitmap_enabled)
+		return;
+
+	/* Need to rate limit them later */
+	if (hdr->e_shentsize != sizeof(struct elf_shdr)) {
+		printk(KERN_WARNING "%s: unexpected shdr size %d\n",
+		       current->comm, hdr->e_shentsize);
+		return;
+	}
+	if (hdr->e_shnum >= PAGE_SIZE / sizeof(struct elf_shdr)) {
+		printk(KERN_WARNING "%s: too many shdrs (%u)\n",
+		       current->comm, hdr->e_shnum);
+		return;
+	}
+	buf = (void *)__get_free_page(GFP_KERNEL);
+	if (!buf)
+		return;
+	n = hdr->e_shnum * sizeof(struct elf_shdr);
+	err = kernel_read(f, hdr->e_shoff, buf, n);
+	if (err != n) {
+		printk(KERN_WARNING "%s: shdr read failed: %d\n",
+		       current->comm, err);
+	} else {
+		int found = 0;
+		struct elf_shdr *shdrs = (struct elf_shdr *)buf;
+
+		for (n = 0; n < hdr->e_shnum; n++) {
+			struct elf_shdr *sh = &shdrs[n];
+			if (sh->sh_type != SHT_PRESENT_BITMAP)
+				continue;
+			err = pbitmap_load(f, buf, sh->sh_addr,
+					   sh->sh_offset,
+					   sh->sh_size);
+			if (err < 0)
+				printk("%s: pbitmap load failed: %d\n",
+				       current->comm, err);
+			else
+				found += err;
+		}
+		if (found > 0 && pbitmap_enabled > 1)
+			printk("%s: %d pages prefetched\n", current->comm,
+			       found);
+
+	}
+	free_page((unsigned long)buf);
+}
+
 static int load_elf_binary(struct linux_binprm *bprm, struct pt_regs *regs)
 {
 	struct file *interpreter = NULL; /* to shut gcc up */
@@ -551,6 +634,8 @@ static int load_elf_binary(struct linux_
 		struct elfhdr interp_elf_ex;
   		struct exec interp_ex;
 	} *loc;
+	int pbitmap_seen = 0;
+	int please_load_shdrs = 0;
 
 	loc = kmalloc(sizeof(*loc), GFP_KERNEL);
 	if (!loc) {
@@ -706,6 +791,10 @@ static int load_elf_binary(struct linux_
 				executable_stack = EXSTACK_ENABLE_X;
 			else
 				executable_stack = EXSTACK_DISABLE_X;
+
+			/* Hack */
+			if (elf_ppnt->p_flags & PF_PLEASE_LOAD_SHDRS)
+				please_load_shdrs = 1;
 			break;
 		}
 
@@ -768,8 +857,13 @@ static int load_elf_binary(struct linux_
 		int elf_prot = 0, elf_flags;
 		unsigned long k, vaddr;
 
-		if (elf_ppnt->p_type != PT_LOAD)
+		if (elf_ppnt->p_type != PT_LOAD) {
+			if (elf_ppnt->p_type == PT_PRESENT_BITMAP) {
+				/* convert to writable */
+				pbitmap_seen = 1;
+			}
 			continue;
+		}
 
 		if (unlikely (elf_brk > elf_bss)) {
 			unsigned long nbyte;
@@ -969,6 +1063,11 @@ static int load_elf_binary(struct linux_
 			arch_randomize_brk(current->mm);
 #endif
 
+	if (pbitmap_seen)
+		elf_read_pb_phdr(bprm->file, elf_phdata, loc->elf_ex.e_phnum);
+	if (please_load_shdrs)
+		elf_read_pb_shdr(bprm->file, &loc->elf_ex);
+
 	if (current->personality & MMAP_PAGE_ZERO) {
 		/* Why this, you ask???  Well SVr4 maps page 0 as read-only,
 		   and some applications "depend" upon this behavior.
Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h
+++ linux/include/linux/mm.h
@@ -1215,6 +1215,13 @@ unsigned long shrink_slab(unsigned long 
 void drop_pagecache(void);
 void drop_slab(void);
 
+void pbitmap_update(struct mm_struct *mm);
+int pbitmap_load(struct file *f, unsigned long *buf,
+		 unsigned long vaddr, unsigned long file_offset, unsigned long filesz);
+extern int pbitmap_enabled;
+extern int pbitmap_early_fault;
+extern unsigned pbitmap_update_interval;
+
 #ifndef CONFIG_MMU
 #define randomize_va_space 0
 #else
Index: linux/kernel/fork.c
===================================================================
--- linux.orig/kernel/fork.c
+++ linux/kernel/fork.c
@@ -359,6 +359,7 @@ static struct mm_struct * mm_init(struct
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
 	mm_init_cgroup(mm, p);
+	INIT_LIST_HEAD(&mm->pbitmap_list);
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
Index: linux/mm/pbitmap.c
===================================================================
--- /dev/null
+++ linux/mm/pbitmap.c
@@ -0,0 +1,404 @@
+/*
+ * Manage bitmaps of the working set of programs in executable files
+ * and use them later for quick prefetching.
+ *
+ * Subject to the GNU General Public License, version 2 only.
+ * Copyright 2007 Andi Kleen, SUSE Labs
+ *
+ * Locking: this file generally doesn't bother much with locking
+ * because during the update we're the last user of the mm just being
+ * destroyed and very little can interfere. And during the bitmap load
+ * the pbitmap object is just being constructed and also 100% private.
+ */
+
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/fs.h>
+#include <linux/gfp.h>
+#include <linux/mount.h>
+#include <asm/uaccess.h>
+
+#define Pprintk(x...)
+
+#define BITS_PER_PAGE	 (PAGE_SIZE * 8)
+#define BITS_TO_BYTES(x) (((x) + 8 - 1) / 8)
+
+struct pbitmap {
+	struct list_head node;
+	unsigned long start;
+	unsigned long npages;
+	loff_t file_offset;	/* offset of bitmap in ELF file */
+	pgoff_t pgoff;		/* page cache offset of VMA */
+	struct path backing;
+	/* Temporarily used in the update phase to pass down arguments: */
+	unsigned long *buffer;	/* always a PAGE */
+	struct file *fh;
+};
+
+int pbitmap_enabled __read_mostly;
+int pbitmap_early_fault __read_mostly = 1;
+unsigned pbitmap_update_interval __read_mostly = 0; /* seconds */
+
+static struct pbitmap *
+alloc_pb(struct vm_area_struct *vma, unsigned long vaddr,
+	unsigned long file_offset, unsigned long filesz)
+{
+	struct pbitmap *pb;
+	pb = kzalloc(sizeof(struct pbitmap), GFP_KERNEL);
+	if (!pb)
+		return NULL;
+
+	Pprintk("alloc_pb vaddr %lx filesz %lu\n", vaddr, filesz);
+	pb->file_offset = file_offset;
+	pb->start = vaddr;
+	pb->pgoff = vma->vm_pgoff + ((vaddr - vma->vm_start) >> PAGE_SHIFT);
+	pb->npages = filesz*8;
+	pb->npages = min_t(unsigned long, pb->npages, vma_pages(vma));
+
+	/* Save away the file to make sure we access the same file later */
+	pb->backing.mnt = mntget(vma->vm_file->f_vfsmnt);
+	pb->backing.dentry = dget(vma->vm_file->f_dentry);
+	return pb;
+}
+
+void free_pb(struct pbitmap *pb)
+{
+	if (pb->fh)
+		filp_close(pb->fh, 0);
+	else {
+		dput(pb->backing.dentry);
+		mntput(pb->backing.mnt);
+	}
+	kfree(pb);
+}
+
+static int
+pbitmap_prefetch(struct file *f, unsigned long *buf, struct pbitmap *pb)
+{
+	int found = 0;
+	long left = BITS_TO_BYTES(pb->npages);
+	unsigned long offset = pb->file_offset;
+
+	Pprintk("%s prefetch %lx %lu\n", current->comm, offset, left);
+	while (left > 0) {
+		int n = left, k, bit;
+		if (n > PAGE_SIZE)
+			n = PAGE_SIZE;
+
+		/* Read the bitmap */
+
+		k = kernel_read(f, offset, (char *)buf, n);
+		if (n != k) {
+			printk("prefetch read failed: %d\n", n);
+			return -EIO;
+		}
+		Pprintk("bitmap [%lx]\n", *(unsigned long *)buf);
+
+		left -= n;
+		offset += n;
+
+		n *= 8;
+
+		/* First do IO on everything */
+		readahead_bitmap(f, pb->pgoff + pb->npages - left, buf, n);
+
+		if (!pbitmap_early_fault)
+			continue;
+
+		/* Now map it all in */
+		bit = 0;
+		while ((bit = find_next_bit(buf, n, bit)) < n) {
+			int err, i;
+			for (i = 1; i < n - bit; i++)
+				if (!test_bit(bit + i, buf))
+					break;
+			err = get_user_pages(current, current->mm,
+					     pb->start + bit*PAGE_SIZE,
+					     i*PAGE_SIZE,
+					     0,
+					     0,
+					     NULL, NULL);
+			if (err < 0) {
+				printk("prefetch gup failed %d %lx\n", err,
+				       pb->start+bit*PAGE_SIZE);
+			} else
+				found += err;
+			bit += i;
+		}
+	}
+	return found;
+}
+
+/* Prefetch the program's working set from last exit. */
+int pbitmap_load(struct file *f, unsigned long *buf,
+		 unsigned long vaddr, unsigned long file_offset,
+		 unsigned long filesz)
+{
+	int err;
+	struct pbitmap *pb;
+	struct vm_area_struct *vma;
+
+	vaddr &= PAGE_MASK;
+
+	vma = find_vma(current->mm, vaddr);
+	if (!vma)
+		return 0;
+
+	/* Likely BSS */
+	if (vma->vm_file == NULL)
+		return 0;
+
+	pb = alloc_pb(vma, vaddr, file_offset, filesz);
+	if (!pb)
+		return -ENOMEM;
+
+	/* For large programs it might be better to start a thread */
+	err = pbitmap_prefetch(f, buf, pb);
+	if (err < 0) {
+		free_pb(pb);
+		return err;
+	}
+	printk("%d prefetched\n", err);
+	list_add_tail(&pb->node, &current->mm->pbitmap_list);
+	return err;
+}
+
+/*
+ * Standard page table walker.
+ * Could later be converted to the .22 generic walker, but let's keep it like
+ * this for now.
+ */
+
+static void
+pbitmap_pte_range(struct vm_area_struct *vma, pmd_t *pmd, unsigned long addr,
+		  unsigned long end, struct pbitmap *pb)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+
+	Pprintk("addr %lx end %lx start %lx\n", addr, end, pb->start);
+
+	/* Turn addresses into bitmap offsets */
+	addr -= pb->start;
+	end -= pb->start;
+	addr >>= PAGE_SHIFT;
+	end >>= PAGE_SHIFT;
+
+	do {
+		if (pte_present(*pte))
+			__set_bit(addr, pb->buffer);
+	} while (pte++, addr++, addr != end);
+	pte_unmap_unlock(pte - 1, ptl);
+}
+
+static inline void pbitmap_pmd_range(struct vm_area_struct *vma, pud_t *pud,
+				     unsigned long addr, unsigned long end,
+				     struct pbitmap *pb)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none(*pmd))
+			continue;
+		pbitmap_pte_range(vma, pmd, addr, next, pb);
+	} while (pmd++, addr = next, addr != end);
+}
+
+static void pbitmap_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
+			      unsigned long addr, unsigned long end,
+			      struct pbitmap *pb)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none(*pud))
+			continue;
+		pbitmap_pmd_range(vma, pud, addr, next, pb);
+	} while (pud++, addr = next, addr != end);
+}
+
+static void pbitmap_page_range(struct vm_area_struct *vma,
+			      unsigned long addr, unsigned long end,
+			      struct pbitmap *pb)
+{
+	pgd_t *pgd;
+	unsigned long next;
+
+	BUG_ON(addr >= end);
+	pgd = pgd_offset(vma->vm_mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none(*pgd))
+			continue;
+		pbitmap_pud_range(vma, pgd, addr, next, pb);
+	} while (pgd++, addr = next, addr != end);
+}
+
+/*
+ * Do some paranoid checks on the VMA just in case the user unmaped it and
+ * mapped something else there.
+ * This is not strictly needed for security because the bitmap update will only
+ * write to the cached executable.
+ */
+static int vma_in_file(struct vm_area_struct *vma, struct pbitmap *pb)
+{
+	if (!vma->vm_file || vma->vm_file->f_dentry != pb->backing.dentry)
+		return 0;
+	if (vma->vm_start >= pb->start + pb->npages*PAGE_SIZE)
+		return 0;
+	return vma->vm_pgoff + vma_pages(vma) > pb->pgoff &&
+		vma->vm_pgoff < pb->pgoff + pb->npages;
+}
+
+static void pbitmap_walk_vmas(struct pbitmap *pb, struct vm_area_struct *vma)
+{
+	unsigned long addr = pb->start;
+
+	for (; vma && vma_in_file(vma, pb); vma = vma->vm_next) {
+		unsigned long end = pb->start + pb->npages*PAGE_SIZE;
+		if (addr < vma->vm_start)
+			addr = vma->vm_start;
+		if (end > vma->vm_end) // off by one?
+			end = vma->vm_end;
+		Pprintk("p_p_r	%lx %lx vma %lx-%lx pb start %lx pages %lu\n",
+		       addr, end,
+		       vma->vm_start, vma->vm_end,
+		       pb->start, pb->npages);
+		if (addr == end)
+			continue;
+		pbitmap_page_range(vma, addr, end, pb);
+	}
+}
+
+long bit_count(unsigned char *buffer, int n)
+{
+	int i;
+	long x = 0;
+	for (i = 0; i < n; i++) {
+		unsigned char v = buffer[i];
+		while (v) {
+			if (v & 1)
+				x++;
+			v >>= 1;
+		}
+	}
+	return x;
+}
+
+/* Avoid thrashing from too frequent updates */
+static int no_update(struct pbitmap *pb)
+{
+	struct inode *i;
+	if (!pbitmap_update_interval)
+		return 0;
+	i = pb->backing.dentry->d_inode;
+	return i->i_mtime.tv_sec + pbitmap_update_interval < xtime.tv_sec;
+}
+
+/*
+ * Update the present bitmaps on disk on program exit.
+ *
+ * Doesn't do any mmap_sem locking anywhere because there should be no
+ * other users of the mm at this point. The page table locks are
+ * unfortunately still needed because the mm could still being swapped
+ * out in parallel (TBD teach the swapper to not do that)
+ *
+ * Could be merged with unmap_vmas later; but it's easier to do it this
+ * way for now.
+ */
+void pbitmap_update(struct mm_struct *mm)
+{
+	struct pbitmap *pb, *prev;
+	struct vm_area_struct *vma;
+	mm_segment_t oldfs;
+	unsigned long *buffer;
+	int order;
+
+	if (list_empty(&mm->pbitmap_list))
+		return;
+
+	buffer = NULL;
+
+	oldfs = get_fs();
+	prev = NULL;
+	list_for_each_entry (pb, &mm->pbitmap_list, node) {
+		 long bytes = BITS_TO_BYTES(pb->npages);
+
+		if (!bytes)
+			continue;
+
+		/* This is typically order 0; only extremly large VMAs
+		   (> 128MB) would have order >0. Failing is also not fatal.
+		   We don't want any swapping so use GFP_NOFS */
+		if (!buffer || bytes > (PAGE_SIZE << order)) {
+			if (buffer)
+				free_pages((unsigned long)buffer, order);
+			order = get_order(bytes);
+			buffer = (unsigned long *)
+				__get_free_pages(GFP_NOFS|__GFP_NOWARN|
+						 __GFP_ZERO, order);
+			if (!buffer) {
+				printk("allocation %d failed\n", order);
+				break;
+			}
+		}
+
+		pb->buffer = buffer;
+
+		vma = find_vma(mm, pb->start);
+		/* Reuse the last file if possible */
+		if (prev && prev->fh &&
+		    pb->backing.dentry == prev->backing.dentry &&
+		    pb->backing.mnt == prev->backing.mnt) {
+			pb->fh = prev->fh;
+			prev->fh = NULL;
+		} else {
+			if (no_update(pb))
+				continue;
+			/* Reopen to get a writable file */
+			pb->fh = dentry_open(pb->backing.dentry,
+					     pb->backing.mnt,
+					     O_WRONLY|O_FORCEWRITE);
+			if (IS_ERR(pb->fh)) {
+				printk("dentry open of %s failed: %ld\n",
+				       pb->backing.dentry->d_name.name,
+				       PTR_ERR(pb->fh));
+				pb->fh = NULL;
+			}
+		}
+		if (pb->fh) {
+			int n;
+			pbitmap_walk_vmas(pb, vma);
+			Pprintk("%s: %ld bytes end %ld bits [%lx] at %Lx\n",
+				current->comm, bytes,
+				bit_count((unsigned char *)buffer, bytes),
+				buffer[0], pb->file_offset);
+			set_fs(KERNEL_DS);
+			n = vfs_write(pb->fh, (char *)buffer, bytes,
+				      &pb->file_offset);
+			set_fs(oldfs);
+			if (n != bytes)
+				printk("%s: bitmap write %d of %ld\n",
+				       current->comm, n, bytes);
+
+			/* fh contains the references now */
+			pb->backing.dentry = NULL;
+			pb->backing.mnt = NULL;
+		}
+		prev = pb;
+	}
+	list_for_each_entry_safe (pb, prev, &mm->pbitmap_list, node)
+		free_pb(pb);
+
+	if (buffer)
+		free_page((unsigned long)buffer);
+}
Index: linux/mm/mmap.c
===================================================================
--- linux.orig/mm/mmap.c
+++ linux/mm/mmap.c
@@ -2039,6 +2039,7 @@ void exit_mmap(struct mm_struct *mm)
 	/* mm's last user has gone, and its about to be pulled down */
 	arch_exit_mmap(mm);
 
+	pbitmap_update(mm);
 	lru_add_drain();
 	flush_cache_mm(mm);
 	tlb = tlb_gather_mmu(mm, 1);
Index: linux/mm/Makefile
===================================================================
--- linux.orig/mm/Makefile
+++ linux/mm/Makefile
@@ -11,7 +11,7 @@ obj-y			:= bootmem.o filemap.o mempool.o
 			   page_alloc.o page-writeback.o pdflush.o \
 			   readahead.o swap.o truncate.o vmscan.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
-			   page_isolation.o $(mmu-y)
+			   page_isolation.o $(mmu-y) pbitmap.o
 
 obj-$(CONFIG_PROC_PAGE_MONITOR) += pagewalk.o
 obj-$(CONFIG_BOUNCE)	+= bounce.o
Index: linux/include/linux/mm_types.h
===================================================================
--- linux.orig/include/linux/mm_types.h
+++ linux/include/linux/mm_types.h
@@ -222,6 +222,9 @@ struct mm_struct {
 	/* aio bits */
 	rwlock_t		ioctx_list_lock;
 	struct kioctx		*ioctx_list;
+
+	struct list_head	pbitmap_list;
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 	struct mem_cgroup *mem_cgroup;
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
