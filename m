Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id F2EC06B0089
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 06:35:32 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id d1so8539324wiv.13
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 03:35:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v3si10198633wix.58.2014.08.06.03.35.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 Aug 2014 03:35:31 -0700 (PDT)
Date: Wed, 6 Aug 2014 11:35:27 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: mm: BUG in unmap_page_range
Message-ID: <20140806103527.GY10819@suse.de>
References: <53DD5F20.8010507@oracle.com>
 <alpine.LSU.2.11.1408040418500.3406@eggly.anvils>
 <20140805144439.GW10819@suse.de>
 <alpine.LSU.2.11.1408051649330.6591@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1408051649330.6591@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On Tue, Aug 05, 2014 at 05:42:03PM -0700, Hugh Dickins wrote:
> > <SNIP>
> > 
> > I'm attaching a preliminary pair of patches. The first which deals with
> > ARCH_USES_NUMA_PROT_NONE and the second which is yours with a revised
> > changelog. I'm adding Aneesh to the cc to look at the powerpc portion of
> > the first patch.
> 
> Thanks a lot, Mel.
> 
> I am surprised by the ordering, but perhaps you meant nothing by it.

I didn't mean anything by it. It was based on the order I looked at the
patches in. Revisited c46a7c817, looked at ARCH_USES_NUMA_PROT_NONE issue
to see if it had any potential impact to your patch and then moved on to
your patch.

> Isn't the first one a welcome but optional cleanup, and the second one
> a fix that we need in 3.16-stable?  Or does the fix actually depend in
> some unstated way upon the cleanup, in powerpc-land perhaps?
> 

It shouldn't as powerpc can use its old helpers. I've included Aneesh in
the cc just in case.

> Aside from that, for the first patch: yes, I heartily approve of the
> disappearance of CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE and
> CONFIG_ARCH_USES_NUMA_PROT_NONE.  If you wish, add
> Acked-by: Hugh Dickins <hughd@google.com>
> but of course it's really Aneesh and powerpc who are the test of it.
> 

Thanks. I have a second version finished for that which I'll send once
this bug is addressed.

> One thing I did wonder, though: at first I was reassured by the
> VM_BUG_ON(!pte_present(pte)) you add to pte_mknuma(); but then thought
> it would be better as VM_BUG_ON(!(val & _PAGE_PRESENT)), being stronger
> - asserting that indeed we do not put NUMA hints on PROT_NONE areas.
> (But I have not tested, perhaps such a VM_BUG_ON would actually fire.)
> 

It shouldn't so I'll use the stronger test.

Sasha, if it's not too late would you mind testing this patch in isolation
as a -stable candidate for 3.16 please? It worked for me including within
trinity but then again I was not seeing crashes with 3.16 either so I do
not consider my trinity testing to be a reliable indicator.

---8<---
x86,mm: fix pte_special versus pte_numa

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
Reported-by: Sasha Levin <sasha.levin@oracle.com>
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
