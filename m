Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 1E1BB6B000C
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 12:52:58 -0500 (EST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 21 Jan 2013 10:52:56 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 3D6B71FF003F
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 10:52:40 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0LHqotC131996
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 10:52:50 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0LHqno3025493
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 10:52:49 -0700
Subject: [PATCH 4/5] create slow_virt_to_phys()
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 21 Jan 2013 09:52:49 -0800
References: <20130121175244.E5839E06@kernel.stglabs.ibm.com>
In-Reply-To: <20130121175244.E5839E06@kernel.stglabs.ibm.com>
Message-Id: <20130121175249.AFE9EAD7@kernel.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>


This is necessary because __pa() does not work on some kinds of
memory, like vmalloc() or the alloc_remap() areas on 32-bit
NUMA systems.  We have some functions to do conversions _like_
this in the vmalloc() code (like vmalloc_to_page()), but they
do not work on sizes other than 4k pages.  We would potentially
need to be able to handle all the page sizes that we use for
the kernel linear mapping (4k, 2M, 1G).

In practice, on 32-bit NUMA systems, the percpu areas get stuck
in the alloc_remap() area.  Any __pa() call on them will break
and basically return garbage.

This patch introduces a new function slow_virt_to_phys(), which
walks the kernel page tables on x86 and should do precisely
the same logical thing as __pa(), but actually work on a wider
range of memory.  It should work on the normal linear mapping,
vmalloc(), kmap(), etc...

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
Acked-by: Rik van Riel <riel@redhat.com>
---

 linux-2.6.git-dave/arch/x86/include/asm/pgtable_types.h |    1 
 linux-2.6.git-dave/arch/x86/mm/pageattr.c               |   31 ++++++++++++++++
 2 files changed, 32 insertions(+)

diff -puN arch/x86/include/asm/pgtable_types.h~create-slow_virt_to_phys arch/x86/include/asm/pgtable_types.h
--- linux-2.6.git/arch/x86/include/asm/pgtable_types.h~create-slow_virt_to_phys	2013-01-17 10:22:26.590434129 -0800
+++ linux-2.6.git-dave/arch/x86/include/asm/pgtable_types.h	2013-01-17 10:22:26.598434199 -0800
@@ -352,6 +352,7 @@ static inline void update_page_count(int
  * as a pte too.
  */
 extern pte_t *lookup_address(unsigned long address, unsigned int *level);
+extern phys_addr_t slow_virt_to_phys(void *__address);
 
 #endif	/* !__ASSEMBLY__ */
 
diff -puN arch/x86/mm/pageattr.c~create-slow_virt_to_phys arch/x86/mm/pageattr.c
--- linux-2.6.git/arch/x86/mm/pageattr.c~create-slow_virt_to_phys	2013-01-17 10:22:26.594434163 -0800
+++ linux-2.6.git-dave/arch/x86/mm/pageattr.c	2013-01-17 10:22:26.598434199 -0800
@@ -364,6 +364,37 @@ pte_t *lookup_address(unsigned long addr
 EXPORT_SYMBOL_GPL(lookup_address);
 
 /*
+ * This is necessary because __pa() does not work on some
+ * kinds of memory, like vmalloc() or the alloc_remap()
+ * areas on 32-bit NUMA systems.  The percpu areas can
+ * end up in this kind of memory, for instance.
+ *
+ * This could be optimized, but it is only intended to be
+ * used at inititalization time, and keeping it
+ * unoptimized should increase the testing coverage for
+ * the more obscure platforms.
+ */
+phys_addr_t slow_virt_to_phys(void *__virt_addr)
+{
+	unsigned long virt_addr = (unsigned long)__virt_addr;
+	phys_addr_t phys_addr;
+	unsigned long offset;
+	unsigned int level = -1;
+	unsigned long psize = 0;
+	unsigned long pmask = 0;
+	pte_t *pte;
+
+	pte = lookup_address(virt_addr, &level);
+	BUG_ON(!pte);
+	psize = page_level_size(level);
+	pmask = page_level_mask(level);
+	offset = virt_addr & ~pmask;
+	phys_addr = pte_pfn(*pte) << PAGE_SHIFT;
+	return (phys_addr | offset);
+}
+EXPORT_SYMBOL_GPL(slow_virt_to_phys);
+
+/*
  * Set the new pmd in all the pgds we know about:
  */
 static void __set_pmd_pte(pte_t *kpte, unsigned long address, pte_t pte)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
