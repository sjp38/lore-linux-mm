Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 0AE976B0006
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 13:08:33 -0500 (EST)
In-Reply-To: <20130121175249.AFE9EAD7@kernel.stglabs.ibm.com>
References: <20130121175244.E5839E06@kernel.stglabs.ibm.com> <20130121175249.AFE9EAD7@kernel.stglabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH 4/5] create slow_virt_to_phys()
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Mon, 21 Jan 2013 12:08:18 -0600
Message-ID: <2ad09c09-98c3-4b2d-9b3f-f16fbcce4edf@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>

Why are you initializing psize/pmask?

Dave Hansen <dave@linux.vnet.ibm.com> wrote:

>
>This is necessary because __pa() does not work on some kinds of
>memory, like vmalloc() or the alloc_remap() areas on 32-bit
>NUMA systems.  We have some functions to do conversions _like_
>this in the vmalloc() code (like vmalloc_to_page()), but they
>do not work on sizes other than 4k pages.  We would potentially
>need to be able to handle all the page sizes that we use for
>the kernel linear mapping (4k, 2M, 1G).
>
>In practice, on 32-bit NUMA systems, the percpu areas get stuck
>in the alloc_remap() area.  Any __pa() call on them will break
>and basically return garbage.
>
>This patch introduces a new function slow_virt_to_phys(), which
>walks the kernel page tables on x86 and should do precisely
>the same logical thing as __pa(), but actually work on a wider
>range of memory.  It should work on the normal linear mapping,
>vmalloc(), kmap(), etc...
>
>Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
>Acked-by: Rik van Riel <riel@redhat.com>
>---
>
> linux-2.6.git-dave/arch/x86/include/asm/pgtable_types.h |    1 
>linux-2.6.git-dave/arch/x86/mm/pageattr.c               |   31
>++++++++++++++++
> 2 files changed, 32 insertions(+)
>
>diff -puN arch/x86/include/asm/pgtable_types.h~create-slow_virt_to_phys
>arch/x86/include/asm/pgtable_types.h
>---
>linux-2.6.git/arch/x86/include/asm/pgtable_types.h~create-slow_virt_to_phys	2013-01-17
>10:22:26.590434129 -0800
>+++ linux-2.6.git-dave/arch/x86/include/asm/pgtable_types.h	2013-01-17
>10:22:26.598434199 -0800
>@@ -352,6 +352,7 @@ static inline void update_page_count(int
>  * as a pte too.
>  */
>extern pte_t *lookup_address(unsigned long address, unsigned int
>*level);
>+extern phys_addr_t slow_virt_to_phys(void *__address);
> 
> #endif	/* !__ASSEMBLY__ */
> 
>diff -puN arch/x86/mm/pageattr.c~create-slow_virt_to_phys
>arch/x86/mm/pageattr.c
>---
>linux-2.6.git/arch/x86/mm/pageattr.c~create-slow_virt_to_phys	2013-01-17
>10:22:26.594434163 -0800
>+++ linux-2.6.git-dave/arch/x86/mm/pageattr.c	2013-01-17
>10:22:26.598434199 -0800
>@@ -364,6 +364,37 @@ pte_t *lookup_address(unsigned long addr
> EXPORT_SYMBOL_GPL(lookup_address);
> 
> /*
>+ * This is necessary because __pa() does not work on some
>+ * kinds of memory, like vmalloc() or the alloc_remap()
>+ * areas on 32-bit NUMA systems.  The percpu areas can
>+ * end up in this kind of memory, for instance.
>+ *
>+ * This could be optimized, but it is only intended to be
>+ * used at inititalization time, and keeping it
>+ * unoptimized should increase the testing coverage for
>+ * the more obscure platforms.
>+ */
>+phys_addr_t slow_virt_to_phys(void *__virt_addr)
>+{
>+	unsigned long virt_addr = (unsigned long)__virt_addr;
>+	phys_addr_t phys_addr;
>+	unsigned long offset;
>+	unsigned int level = -1;
>+	unsigned long psize = 0;
>+	unsigned long pmask = 0;
>+	pte_t *pte;
>+
>+	pte = lookup_address(virt_addr, &level);
>+	BUG_ON(!pte);
>+	psize = page_level_size(level);
>+	pmask = page_level_mask(level);
>+	offset = virt_addr & ~pmask;
>+	phys_addr = pte_pfn(*pte) << PAGE_SHIFT;
>+	return (phys_addr | offset);
>+}
>+EXPORT_SYMBOL_GPL(slow_virt_to_phys);
>+
>+/*
>  * Set the new pmd in all the pgds we know about:
>  */
>static void __set_pmd_pte(pte_t *kpte, unsigned long address, pte_t
>pte)
>_

-- 
Sent from my mobile phone. Please excuse brevity and lack of formatting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
