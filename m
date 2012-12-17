Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id D4B986B0098
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 13:43:12 -0500 (EST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/2] pageattr: prevent PSE and GLOABL leftovers to confuse pmd/pte_present and pmd_huge
Date: Mon, 17 Dec 2012 19:00:24 +0100
Message-Id: <1355767224-13298-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1355767224-13298-1-git-send-email-aarcange@redhat.com>
References: <1355767224-13298-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

Without this patch any kernel code that reads kernel memory in non
present kernel pte/pmds (as set by pageattr.c) will crash.

With this kernel code:

static struct page *crash_page;
static unsigned long *crash_address;
[..]
	crash_page = alloc_pages(GFP_KERNEL, 9);
	crash_address = page_address(crash_page);
	if (set_memory_np((unsigned long)crash_address, 1))
		printk("set_memory_np failure\n");
[..]

The kernel will crash if inside the "crash tool" one would try to read
the memory at the not present address.

crash> p crash_address
crash_address = $8 = (long unsigned int *) 0xffff88023c000000
crash> rd 0xffff88023c000000
[ *lockup* ]

The lockup happens because _PAGE_GLOBAL and _PAGE_PROTNONE shares the
same bit, and pageattr leaves _PAGE_GLOBAL set on a kernel pte which
is then mistaken as _PAGE_PROTNONE (so pte_present returns true by
mistake and the kernel fault then gets confused and loops).

With THP the same can happen after we taught pmd_present to check
_PAGE_PROTNONE and _PAGE_PSE in commit
027ef6c87853b0a9df53175063028edb4950d476. THP has the same problem
with _PAGE_GLOBAL as the 4k pages, but it also has a problem with
_PAGE_PSE, which must be cleared too.

After the patch is applied copy_user correctly returns -EFAULT and
doesn't lockup anymore.

crash> p crash_address
crash_address = $9 = (long unsigned int *) 0xffff88023c000000
crash> rd 0xffff88023c000000
rd: read error: kernel virtual address: ffff88023c000000  type: "64-bit KVADDR"

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/mm/pageattr.c |   50 +++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 47 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index a718e0d..2713be4 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -445,6 +445,19 @@ try_preserve_large_page(pte_t *kpte, unsigned long address,
 	pgprot_val(req_prot) |= pgprot_val(cpa->mask_set);
 
 	/*
+	 * Set the PSE and GLOBAL flags only if the PRESENT flag is
+	 * set otherwise pmd_present/pmd_huge will return true even on
+	 * a non present pmd. The canon_pgprot will clear _PAGE_GLOBAL
+	 * for the ancient hardware that doesn't support it.
+	 */
+	if (pgprot_val(new_prot) & _PAGE_PRESENT)
+		pgprot_val(new_prot) |= _PAGE_PSE | _PAGE_GLOBAL;
+	else
+		pgprot_val(new_prot) &= ~(_PAGE_PSE | _PAGE_GLOBAL);
+
+	new_prot = canon_pgprot(new_prot);
+
+	/*
 	 * old_pte points to the large page base address. So we need
 	 * to add the offset of the virtual address:
 	 */
@@ -489,7 +502,7 @@ try_preserve_large_page(pte_t *kpte, unsigned long address,
 		 * The address is aligned and the number of pages
 		 * covers the full page.
 		 */
-		new_pte = pfn_pte(pte_pfn(old_pte), canon_pgprot(new_prot));
+		new_pte = pfn_pte(pte_pfn(old_pte), new_prot);
 		__set_pmd_pte(kpte, address, new_pte);
 		cpa->flags |= CPA_FLUSHTLB;
 		do_split = 0;
@@ -540,16 +553,35 @@ static int split_large_page(pte_t *kpte, unsigned long address)
 #ifdef CONFIG_X86_64
 	if (level == PG_LEVEL_1G) {
 		pfninc = PMD_PAGE_SIZE >> PAGE_SHIFT;
-		pgprot_val(ref_prot) |= _PAGE_PSE;
+		/*
+		 * Set the PSE flags only if the PRESENT flag is set
+		 * otherwise pmd_present/pmd_huge will return true
+		 * even on a non present pmd.
+		 */
+		if (pgprot_val(ref_prot) & _PAGE_PRESENT)
+			pgprot_val(ref_prot) |= _PAGE_PSE;
+		else
+			pgprot_val(ref_prot) &= ~_PAGE_PSE;
 	}
 #endif
 
 	/*
+	 * Set the GLOBAL flags only if the PRESENT flag is set
+	 * otherwise pmd/pte_present will return true even on a non
+	 * present pmd/pte. The canon_pgprot will clear _PAGE_GLOBAL
+	 * for the ancient hardware that doesn't support it.
+	 */
+	if (pgprot_val(ref_prot) & _PAGE_PRESENT)
+		pgprot_val(ref_prot) |= _PAGE_GLOBAL;
+	else
+		pgprot_val(ref_prot) &= ~_PAGE_GLOBAL;
+
+	/*
 	 * Get the target pfn from the original entry:
 	 */
 	pfn = pte_pfn(*kpte);
 	for (i = 0; i < PTRS_PER_PTE; i++, pfn += pfninc)
-		set_pte(&pbase[i], pfn_pte(pfn, ref_prot));
+		set_pte(&pbase[i], pfn_pte(pfn, canon_pgprot(ref_prot)));
 
 	if (address >= (unsigned long)__va(0) &&
 		address < (unsigned long)__va(max_low_pfn_mapped << PAGE_SHIFT))
@@ -660,6 +692,18 @@ repeat:
 		new_prot = static_protections(new_prot, address, pfn);
 
 		/*
+		 * Set the GLOBAL flags only if the PRESENT flag is
+		 * set otherwise pte_present will return true even on
+		 * a non present pte. The canon_pgprot will clear
+		 * _PAGE_GLOBAL for the ancient hardware that doesn't
+		 * support it.
+		 */
+		if (pgprot_val(new_prot) & _PAGE_PRESENT)
+			pgprot_val(new_prot) |= _PAGE_GLOBAL;
+		else
+			pgprot_val(new_prot) &= ~_PAGE_GLOBAL;
+
+		/*
 		 * We need to keep the pfn from the existing PTE,
 		 * after all we're only going to change it's attributes
 		 * not the memory it points to

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
