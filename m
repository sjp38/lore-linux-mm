Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B91856B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 01:27:15 -0500 (EST)
Subject: Re: [patch 3/5]thp: add tlb_remove_pmd_tlb_entry
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20111110153651.GZ5075@redhat.com>
References: <1319511571.22361.139.camel@sli10-conroe>
	 <20111110153651.GZ5075@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 11 Nov 2011 14:36:29 +0800
Message-ID: <1320993389.22361.256.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Thu, 2011-11-10 at 23:36 +0800, Andrea Arcangeli wrote:
> On Tue, Oct 25, 2011 at 10:59:31AM +0800, Shaohua Li wrote:
> > Index: linux/arch/x86/include/asm/tlb.h
> > ===================================================================
> > --- linux.orig/arch/x86/include/asm/tlb.h	2011-10-25 09:00:39.000000000 +0800
> > +++ linux/arch/x86/include/asm/tlb.h	2011-10-25 09:02:52.000000000 +0800
> > @@ -4,6 +4,7 @@
> >  #define tlb_start_vma(tlb, vma) do { } while (0)
> >  #define tlb_end_vma(tlb, vma) do { } while (0)
> >  #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
> > +#define __tlb_remove_pmd_tlb_entry(tlb, pmdp, address) do { } while (0)
> >  #define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
> 
> This is superfluous, it's already define below as noop.
> 
> >  
> >  #include <asm-generic/tlb.h>
> > Index: linux/include/asm-generic/tlb.h
> > ===================================================================
> > --- linux.orig/include/asm-generic/tlb.h	2011-10-25 09:00:23.000000000 +0800
> > +++ linux/include/asm-generic/tlb.h	2011-10-25 09:18:01.000000000 +0800
> > @@ -139,6 +139,16 @@ static inline void tlb_remove_page(struc
> >  		__tlb_remove_tlb_entry(tlb, ptep, address);	\
> >  	} while (0)
> >  
> > +#ifndef __tlb_remove_pmd_tlb_entry
> > +#define __tlb_remove_pmd_tlb_entry(tlb, pmdp, address) do {} while(0)
> > +#endif
> > +
> > +#define tlb_remove_pmd_tlb_entry(tlb, pmdp, address)		\
> > +	do {							\
> > +		tlb->need_flush = 1;				\
> > +		__tlb_remove_pmd_tlb_entry(tlb, pmdp, address);	\
> > +	} while (0)
> 
> this looks weird, why do we set need_flush = 1 again, considering that
> we're doing tlb_remove_page() just a few lines later (which also sets
> tlb->need_flush = 1).
> 
> Ok that other archs may need the __tlb_remove_pmd_tlb_entry to be
> called (and I've no idea why), but the need_flush = 1 seems
> unnecessary.
> 
> Why other archs need the __tlb_remove_pmd_tlb_entry to be called?
> 
> One way to go would be to change the tlb->need_flush = 1 in
> __tlb_remove_page to a VM_BUG_ON(!tlb->need_flush) and then we keep it
> above and we add the __tlb_remove_pmd_tlb_entry call.
> 
> Or is there any place where __tlb_remove_page is called without a
> tlb_remove_*tlb_entry being called before it?
> 
> In any case the VM_BUG_ON will verify this.
ok, I made the whole tlb_remove_pmd_tlb_entry() noop now. we don't need
add anything on it for x86 currently. We can change it later if
necessary.


We have tlb_remove_tlb_entry to indicate a pte tlb flush entry should be
flushed, but not a corresponding API for pmd entry. This isn't a problem so far
because THP is only for x86 currently and tlb_flush() under x86 will flush
entire TLB. But this is confusion and could be missed if thp is ported to
other arch.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 include/asm-generic/tlb.h |    6 ++++++
 include/linux/huge_mm.h   |    2 +-
 mm/huge_memory.c          |    3 ++-
 mm/memory.c               |    2 +-
 4 files changed, 10 insertions(+), 3 deletions(-)

Index: linux/include/asm-generic/tlb.h
===================================================================
--- linux.orig/include/asm-generic/tlb.h	2011-11-11 14:26:33.000000000 +0800
+++ linux/include/asm-generic/tlb.h	2011-11-11 14:26:35.000000000 +0800
@@ -139,6 +139,12 @@ static inline void tlb_remove_page(struc
 		__tlb_remove_tlb_entry(tlb, ptep, address);	\
 	} while (0)
 
+/**
+ * tlb_remove_pmd_tlb_entry - remember a pmd mapping for later tlb invalidation
+ * This is a nop so far, because only x86 needs it.
+ */
+#define tlb_remove_pmd_tlb_entry(tlb, pmdp, address) do {} while (0)
+
 #define pte_free_tlb(tlb, ptep, address)			\
 	do {							\
 		tlb->need_flush = 1;				\
Index: linux/include/linux/huge_mm.h
===================================================================
--- linux.orig/include/linux/huge_mm.h	2011-11-11 14:26:33.000000000 +0800
+++ linux/include/linux/huge_mm.h	2011-11-11 14:26:35.000000000 +0800
@@ -18,7 +18,7 @@ extern struct page *follow_trans_huge_pm
 					  unsigned int flags);
 extern int zap_huge_pmd(struct mmu_gather *tlb,
 			struct vm_area_struct *vma,
-			pmd_t *pmd);
+			pmd_t *pmd, unsigned long addr);
 extern int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, unsigned long end,
 			unsigned char *vec);
Index: linux/mm/huge_memory.c
===================================================================
--- linux.orig/mm/huge_memory.c	2011-11-11 14:26:33.000000000 +0800
+++ linux/mm/huge_memory.c	2011-11-11 14:26:35.000000000 +0800
@@ -1026,7 +1026,7 @@ out:
 }
 
 int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
-		 pmd_t *pmd)
+		 pmd_t *pmd, unsigned long addr)
 {
 	int ret = 0;
 
@@ -1042,6 +1042,7 @@ int zap_huge_pmd(struct mmu_gather *tlb,
 			pgtable = get_pmd_huge_pte(tlb->mm);
 			page = pmd_page(*pmd);
 			pmd_clear(pmd);
+			tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 			page_remove_rmap(page);
 			VM_BUG_ON(page_mapcount(page) < 0);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c	2011-11-11 14:26:33.000000000 +0800
+++ linux/mm/memory.c	2011-11-11 14:26:35.000000000 +0800
@@ -1231,7 +1231,7 @@ static inline unsigned long zap_pmd_rang
 			if (next-addr != HPAGE_PMD_SIZE) {
 				VM_BUG_ON(!rwsem_is_locked(&tlb->mm->mmap_sem));
 				split_huge_page_pmd(vma->vm_mm, pmd);
-			} else if (zap_huge_pmd(tlb, vma, pmd))
+			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				continue;
 			/* fall through */
 		}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
