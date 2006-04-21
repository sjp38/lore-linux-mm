Date: Fri, 21 Apr 2006 08:55:18 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/5] mm: remove vmalloc_to_pfn
Message-ID: <20060421065518.GK21660@wotan.suse.de>
References: <20060301045901.12434.54077.sendpatchset@linux.site> <20060301045921.12434.16382.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060301045921.12434.16382.sendpatchset@linux.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Sigh, missed nommu, sorry.

---

vmalloc_to_pfn no longer has any callers left in the kernel. It was previously
used so remap_pfn_range can be used on vmalloc memory, but is obsolete with
the introduction of remap_vmalloc_range.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -1002,7 +1002,6 @@ static inline unsigned long vma_pages(st
 
 struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
 struct page *vmalloc_to_page(void *addr);
-unsigned long vmalloc_to_pfn(void *addr);
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -2394,16 +2394,6 @@ struct page * vmalloc_to_page(void * vma
 
 EXPORT_SYMBOL(vmalloc_to_page);
 
-/*
- * Map a vmalloc()-space virtual address to the physical page frame number.
- */
-unsigned long vmalloc_to_pfn(void * vmalloc_addr)
-{
-	return page_to_pfn(vmalloc_to_page(vmalloc_addr));
-}
-
-EXPORT_SYMBOL(vmalloc_to_pfn);
-
 #if !defined(__HAVE_ARCH_GATE_AREA)
 
 #if defined(AT_SYSINFO_EHDR)
Index: linux-2.6/mm/nommu.c
===================================================================
--- linux-2.6.orig/mm/nommu.c
+++ linux-2.6/mm/nommu.c
@@ -167,12 +167,6 @@ struct page * vmalloc_to_page(void *addr
 	return virt_to_page(addr);
 }
 
-unsigned long vmalloc_to_pfn(void *addr)
-{
-	return page_to_pfn(virt_to_page(addr));
-}
-
-
 long vread(char *buf, char *addr, unsigned long count)
 {
 	memcpy(buf, addr, count);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
