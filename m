Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 55D146B00A0
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 09:09:44 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e49so654322eek.25
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 06:09:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p8si2709686eew.306.2014.04.08.06.09.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 06:09:40 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/5] mm: use paravirt friendly ops for NUMA hinting ptes
Date: Tue,  8 Apr 2014 14:09:29 +0100
Message-Id: <1396962570-18762-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1396962570-18762-1-git-send-email-mgorman@suse.de>
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-X86 <x86@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Mel Gorman <mgorman@suse.de>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

David Vrabel identified a regression when using automatic NUMA balancing
under Xen whereby page table entries were getting corrupted due to the
use of native PTE operations. Quoting him

	Xen PV guest page tables require that their entries use machine
	addresses if the preset bit (_PAGE_PRESENT) is set, and (for
	successful migration) non-present PTEs must use pseudo-physical
	addresses.  This is because on migration MFNs in present PTEs are
	translated to PFNs (canonicalised) so they may be translated back
	to the new MFN in the destination domain (uncanonicalised).

	pte_mknonnuma(), pmd_mknonnuma(), pte_mknuma() and pmd_mknuma()
	set and clear the _PAGE_PRESENT bit using pte_set_flags(),
	pte_clear_flags(), etc.

	In a Xen PV guest, these functions must translate MFNs to PFNs
	when clearing _PAGE_PRESENT and translate PFNs to MFNs when setting
	_PAGE_PRESENT.

His suggested fix converted p[te|md]_[set|clear]_flags to using
paravirt-friendly ops but this is overkill. He suggested an alternative of
using p[te|md]_modify in the NUMA page table operations but this is does
more work than necessary and would require looking up a VMA for protections.

This patch modifies the NUMA page table operations to use paravirt friendly
operations to set/clear the flags of interest. Unfortunately this will take
a performance hit when updating the PTEs on CONFIG_PARAVIRT but I do not
see a way around it that does not break Xen.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/asm-generic/pgtable.h | 31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 34c7bdc..38a7437 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -680,24 +680,35 @@ static inline int pmd_numa(pmd_t pmd)
 #ifndef pte_mknonnuma
 static inline pte_t pte_mknonnuma(pte_t pte)
 {
-	pte = pte_clear_flags(pte, _PAGE_NUMA);
-	return pte_set_flags(pte, _PAGE_PRESENT|_PAGE_ACCESSED);
+	pteval_t val = pte_val(pte);
+
+	val &= ~_PAGE_NUMA;
+	val |= (_PAGE_PRESENT|_PAGE_ACCESSED);
+	return __pte(val);
 }
 #endif
 
 #ifndef pmd_mknonnuma
 static inline pmd_t pmd_mknonnuma(pmd_t pmd)
 {
-	pmd = pmd_clear_flags(pmd, _PAGE_NUMA);
-	return pmd_set_flags(pmd, _PAGE_PRESENT|_PAGE_ACCESSED);
+	pmdval_t val = pmd_val(pmd);
+
+	val &= ~_PAGE_NUMA;
+	val |= (_PAGE_PRESENT|_PAGE_ACCESSED);
+
+	return __pmd(val);
 }
 #endif
 
 #ifndef pte_mknuma
 static inline pte_t pte_mknuma(pte_t pte)
 {
-	pte = pte_set_flags(pte, _PAGE_NUMA);
-	return pte_clear_flags(pte, _PAGE_PRESENT);
+	pteval_t val = pte_val(pte);
+
+	val &= ~_PAGE_PRESENT;
+	val |= _PAGE_NUMA;
+
+	return __pte(val);
 }
 #endif
 
@@ -716,8 +727,12 @@ static inline void ptep_set_numa(struct mm_struct *mm, unsigned long addr,
 #ifndef pmd_mknuma
 static inline pmd_t pmd_mknuma(pmd_t pmd)
 {
-	pmd = pmd_set_flags(pmd, _PAGE_NUMA);
-	return pmd_clear_flags(pmd, _PAGE_PRESENT);
+	pmdval_t val = pmd_val(pmd);
+
+	val &= ~_PAGE_PRESENT;
+	val |= _PAGE_NUMA;
+
+	return __pmd(val);
 }
 #endif
 
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
