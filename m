Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id CDA356B0007
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 15:28:36 -0500 (EST)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 8 Feb 2013 13:28:36 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id AE9B519D803E
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 13:28:27 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r18KSNtC043422
	for <linux-mm@kvack.org>; Fri, 8 Feb 2013 13:28:26 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r18KSDr4015165
	for <linux-mm@kvack.org>; Fri, 8 Feb 2013 13:28:14 -0700
Subject: [PATCH 1/2] add helper for highmem checks
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 08 Feb 2013 12:28:13 -0800
Message-Id: <20130208202813.62965F25@kernel.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, bp@alien8.de, hpa@zytor.com, mingo@kernel.org, tglx@linutronix.de, Dave Hansen <dave@linux.vnet.ibm.com>


Boris, could you check that this series also fixes the /dev/mem
problem you were seeing?

--

We have a new debugging check on x86 that has caught a number
of long-standing bugs.  However, there is a _bit_ of collateral
damage with things that call __pa(high_memory).

We are now checking that any addresses passed to __pa() are
*valid* and can be dereferenced.

"high_memory", however, is not valid.  It marks the start of
highmem, and isn't itself a valid pointer.  But, those users
are really just asking "is this vaddr mapped"?  So, give them
a helper that does that, plus is also kind to our new
debugging check.


Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/arch/x86/mm/pat.c     |   11 ++++++-----
 linux-2.6.git-dave/drivers/char/mem.c    |    4 ++--
 linux-2.6.git-dave/drivers/mtd/mtdchar.c |    2 +-
 linux-2.6.git-dave/include/linux/mm.h    |   13 +++++++++++++
 4 files changed, 22 insertions(+), 8 deletions(-)

diff -puN drivers/char/mem.c~clean-up-highmem-checks drivers/char/mem.c
--- linux-2.6.git/drivers/char/mem.c~clean-up-highmem-checks	2013-02-08 08:42:37.291222110 -0800
+++ linux-2.6.git-dave/drivers/char/mem.c	2013-02-08 12:27:27.837477867 -0800
@@ -51,7 +51,7 @@ static inline unsigned long size_inside_
 #ifndef ARCH_HAS_VALID_PHYS_ADDR_RANGE
 static inline int valid_phys_addr_range(phys_addr_t addr, size_t count)
 {
-	return addr + count <= __pa(high_memory);
+	return !phys_addr_is_highmem(addr + count);
 }
 
 static inline int valid_mmap_phys_addr_range(unsigned long pfn, size_t size)
@@ -250,7 +250,7 @@ static int uncached_access(struct file *
 	 */
 	if (file->f_flags & O_DSYNC)
 		return 1;
-	return addr >= __pa(high_memory);
+	return phys_addr_is_highmem(addr);
 #endif
 }
 #endif
diff -puN include/linux/mm.h~clean-up-highmem-checks include/linux/mm.h
--- linux-2.6.git/include/linux/mm.h~clean-up-highmem-checks	2013-02-08 08:42:37.295222148 -0800
+++ linux-2.6.git-dave/include/linux/mm.h	2013-02-08 09:01:49.758254468 -0800
@@ -1771,5 +1771,18 @@ static inline unsigned int debug_guardpa
 static inline bool page_is_guard(struct page *page) { return false; }
 #endif /* CONFIG_DEBUG_PAGEALLOC */
 
+static inline phys_addr_t last_lowmem_phys_addr(void)
+{
+	/*
+	 * 'high_memory' is not a pointer that can be dereferenced, so
+	 * avoid calling __pa() on it directly.
+	 */
+	return __pa(high_memory - 1);
+}
+static inline bool phys_addr_is_highmem(phys_addr_t addr)
+{
+	return addr > last_lowmem_paddr();
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff -puN arch/arm/mm/mmap.c~clean-up-highmem-checks arch/arm/mm/mmap.c
diff -puN arch/arm/mach-u300/core.c~clean-up-highmem-checks arch/arm/mach-u300/core.c
diff -puN arch/mips/loongson/common/mem.c~clean-up-highmem-checks arch/mips/loongson/common/mem.c
diff -puN arch/mips/mm/cache.c~clean-up-highmem-checks arch/mips/mm/cache.c
diff -puN arch/sh/mm/mmap.c~clean-up-highmem-checks arch/sh/mm/mmap.c
diff -puN arch/x86/mm/pat.c~clean-up-highmem-checks arch/x86/mm/pat.c
--- linux-2.6.git/arch/x86/mm/pat.c~clean-up-highmem-checks	2013-02-08 08:48:29.486594289 -0800
+++ linux-2.6.git-dave/arch/x86/mm/pat.c	2013-02-08 09:03:32.435231850 -0800
@@ -542,7 +542,7 @@ int phys_mem_access_prot_allowed(struct
 	      boot_cpu_has(X86_FEATURE_K6_MTRR) ||
 	      boot_cpu_has(X86_FEATURE_CYRIX_ARR) ||
 	      boot_cpu_has(X86_FEATURE_CENTAUR_MCR)) &&
-	    (pfn << PAGE_SHIFT) >= __pa(high_memory)) {
+	    phys_addr_is_highmem(pfn << PAGE_SHIFT)) {
 		flags = _PAGE_CACHE_UC;
 	}
 #endif
@@ -560,12 +560,13 @@ int kernel_map_sync_memtype(u64 base, un
 {
 	unsigned long id_sz;
 
-	if (base > __pa(high_memory-1))
+	if (phys_addr_is_highmem(base))
 		return 0;
 
-	id_sz = (__pa(high_memory-1) <= base + size) ?
-				__pa(high_memory) - base :
-				size;
+	if (phys_addr_is_highmem(base + size - 1))
+		id_sz = last_lowmem_phys_addr() - base + 1;
+	else
+		id_sz = size;
 
 	if (ioremap_change_attr((unsigned long)__va(base), id_sz, flags) < 0) {
 		printk(KERN_INFO "%s:%d ioremap_change_attr failed %s "
diff -puN drivers/mtd/mtdchar.c~clean-up-highmem-checks drivers/mtd/mtdchar.c
--- linux-2.6.git/drivers/mtd/mtdchar.c~clean-up-highmem-checks	2013-02-08 08:59:26.632884014 -0800
+++ linux-2.6.git-dave/drivers/mtd/mtdchar.c	2013-02-08 09:50:56.410398581 -0800
@@ -1189,7 +1189,7 @@ static int mtdchar_mmap(struct file *fil
 		vma->vm_flags |= VM_IO | VM_DONTEXPAND | VM_DONTDUMP;
 
 #ifdef pgprot_noncached
-		if (file->f_flags & O_DSYNC || off >= __pa(high_memory))
+		if (file->f_flags & O_DSYNC || phys_addr_is_highmem(off))
 			vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 #endif
 		if (io_remap_pfn_range(vma, vma->vm_start, off >> PAGE_SHIFT,
diff -puN arch/um/kernel/physmem.c~clean-up-highmem-checks arch/um/kernel/physmem.c
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
