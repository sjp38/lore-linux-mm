Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id BBAF26B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 06:48:04 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id 10so6796462lbg.20
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 03:48:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q14si17960583lbv.18.2014.08.12.03.48.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 12 Aug 2014 03:48:02 -0700 (PDT)
Date: Tue, 12 Aug 2014 11:47:58 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] x86,mm: fix pte_special versus pte_numa
Message-ID: <20140812104758.GE7970@suse.de>
References: <53DD5F20.8010507@oracle.com>
 <alpine.LSU.2.11.1408040418500.3406@eggly.anvils>
 <20140805144439.GW10819@suse.de>
 <alpine.LSU.2.11.1408051649330.6591@eggly.anvils>
 <53E17F06.30401@oracle.com>
 <53E989FB.5000904@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <53E989FB.5000904@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Sasha Levin <sasha.levin@oracle.com>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

Sasha Levin has shown oopses on ffffea0003480048 and ffffea0003480008
at mm/memory.c:1132, running Trinity on different 3.16-rc-next kernels:
where zap_pte_range() checks page->mapping to see if PageAnon(page).

Those addresses fit struct pages for pfns d2001 and d2000, and in each
dump a register or a stack slot showed d2001730 or d2000730: pte flags
0x730 are PCD ACCESSED PROTNONE SPECIAL IOMAP; and Sasha's e820 map has
a hole between cfffffff and 100000000, which would need special access.

Commit c46a7c817e66 ("x86: define _PAGE_NUMA by reusing software bits on
the PMD and PTE levels") has broken vm_normal_page(): a PROTNONE SPECIAL
pte no longer passes the pte_special() test, so zap_pte_range() goes on
to try to access a non-existent struct page.

Fix this by refining pte_special() (SPECIAL with PRESENT or PROTNONE)
to complement pte_numa() (SPECIAL with neither PRESENT nor PROTNONE).
A hint that this was a problem was that c46a7c817e66 added pte_numa()
test to vm_normal_page(), and moved its is_zero_pfn() test from slow to
fast path: This was papering over a pte_special() snag when the zero page
was encountered during zap. This patch reverts vm_normal_page() to how it
was before, relying on pte_special().

It still appears that this patch may be incomplete: aren't there other
places which need to be handling PROTNONE along with PRESENT?  For example,
pte_mknuma() clears _PAGE_PRESENT and sets _PAGE_NUMA, but on a PROT_NONE
area, that would make it pte_special(). This is side-stepped by the fact
that NUMA hinting faults skipped PROT_NONE VMAs and there are no grounds
where a NUMA hinting fault on a PROT_NONE VMA would be interesting.

Fixes: c46a7c817e66 ("x86: define _PAGE_NUMA by reusing software bits on the PMD and PTE levels")
Reported-and-tested-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Cc: stable@vger.kernel.org [3.16]
---
 arch/x86/include/asm/pgtable.h | 9 +++++++--
 mm/memory.c                    | 7 +++----
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 0ec0560..aa97a07 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -131,8 +131,13 @@ static inline int pte_exec(pte_t pte)
 
 static inline int pte_special(pte_t pte)
 {
-	return (pte_flags(pte) & (_PAGE_PRESENT|_PAGE_SPECIAL)) ==
-				 (_PAGE_PRESENT|_PAGE_SPECIAL);
+	/*
+	 * See CONFIG_NUMA_BALANCING pte_numa in include/asm-generic/pgtable.h.
+	 * On x86 we have _PAGE_BIT_NUMA == _PAGE_BIT_GLOBAL+1 ==
+	 * __PAGE_BIT_SOFTW1 == _PAGE_BIT_SPECIAL.
+	 */
+	return (pte_flags(pte) & _PAGE_SPECIAL) &&
+		(pte_flags(pte) & (_PAGE_PRESENT|_PAGE_PROTNONE));
 }
 
 static inline unsigned long pte_pfn(pte_t pte)
diff --git a/mm/memory.c b/mm/memory.c
index 8b44f76..0a21f3d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -751,7 +751,7 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 	unsigned long pfn = pte_pfn(pte);
 
 	if (HAVE_PTE_SPECIAL) {
-		if (likely(!pte_special(pte) || pte_numa(pte)))
+		if (likely(!pte_special(pte)))
 			goto check_pfn;
 		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
 			return NULL;
@@ -777,15 +777,14 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 		}
 	}
 
+	if (is_zero_pfn(pfn))
+		return NULL;
 check_pfn:
 	if (unlikely(pfn > highest_memmap_pfn)) {
 		print_bad_pte(vma, addr, pte, NULL);
 		return NULL;
 	}
 
-	if (is_zero_pfn(pfn))
-		return NULL;
-
 	/*
 	 * NOTE! We still have PageReserved() pages in the page tables.
 	 * eg. VDSO mappings can cause them to exist.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
