Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3ECD46B0005
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 16:58:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 203so1295207pfz.19
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 13:58:01 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id r20si8635565pfk.224.2018.04.06.13.57.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 13:57:59 -0700 (PDT)
Subject: [PATCH 01/11] x86/mm: factor out pageattr _PAGE_GLOBAL setting
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 06 Apr 2018 13:55:02 -0700
References: <20180406205501.24A1A4E7@viggo.jf.intel.com>
In-Reply-To: <20180406205501.24A1A4E7@viggo.jf.intel.com>
Message-Id: <20180406205502.86E199DA@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The pageattr code has a pattern repeated where it sets _PAGE_GLOBAL
for present PTEs but clears it for non-present PTEs.  The intention
is to keep _PAGE_GLOBAL from getting confused with _PAGE_PROTNONE
since _PAGE_GLOBAL is for present PTEs and _PAGE_PROTNONE is for
non-present

But, this pattern makes no sense.  Effectively, it says, if you use
the pageattr code, always set _PAGE_GLOBAL when _PAGE_PRESENT.
canon_pgprot() will clear it if unsupported (because it masks the
value with __supported_pte_mask) but we *always* set it. Even if
canon_pgprot() did not filter _PAGE_GLOBAL, it would be OK. 
_PAGE_GLOBAL is ignored when CR4.PGE=0 by the hardware.

This unconditional setting of _PAGE_GLOBAL is a problem when we have
PTI and non-PTI and we want some areas to have _PAGE_GLOBAL and some
not.

This updated version of the code says:
1. Clear _PAGE_GLOBAL when !_PAGE_PRESENT
2. Never set _PAGE_GLOBAL implicitly
3. Allow _PAGE_GLOBAL to be in cpa.set_mask
4. Allow _PAGE_GLOBAL to be inherited from previous PTE

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: x86@kernel.org
Cc: Nadav Amit <namit@vmware.com>
---

 b/arch/x86/mm/pageattr.c |   66 ++++++++++++++++-------------------------------
 1 file changed, 23 insertions(+), 43 deletions(-)

diff -puN arch/x86/mm/pageattr.c~kpti-centralize-global-setting arch/x86/mm/pageattr.c
--- a/arch/x86/mm/pageattr.c~kpti-centralize-global-setting	2018-04-06 10:47:53.651796130 -0700
+++ b/arch/x86/mm/pageattr.c	2018-04-06 10:47:53.655796130 -0700
@@ -512,6 +512,23 @@ static void __set_pmd_pte(pte_t *kpte, u
 #endif
 }
 
+static pgprot_t pgprot_clear_protnone_bits(pgprot_t prot)
+{
+	/*
+	 * _PAGE_GLOBAL means "global page" for present PTEs.
+	 * But, it is also used to indicate _PAGE_PROTNONE
+	 * for non-present PTEs.
+	 *
+	 * This ensures that a _PAGE_GLOBAL PTE going from
+	 * present to non-present is not confused as
+	 * _PAGE_PROTNONE.
+	 */
+	if (!(pgprot_val(prot) & _PAGE_PRESENT))
+		pgprot_val(prot) &= ~_PAGE_GLOBAL;
+
+	return prot;
+}
+
 static int
 try_preserve_large_page(pte_t *kpte, unsigned long address,
 			struct cpa_data *cpa)
@@ -577,18 +594,11 @@ try_preserve_large_page(pte_t *kpte, uns
 	 * different bit positions in the two formats.
 	 */
 	req_prot = pgprot_4k_2_large(req_prot);
-
-	/*
-	 * Set the PSE and GLOBAL flags only if the PRESENT flag is
-	 * set otherwise pmd_present/pmd_huge will return true even on
-	 * a non present pmd. The canon_pgprot will clear _PAGE_GLOBAL
-	 * for the ancient hardware that doesn't support it.
-	 */
+	req_prot = pgprot_clear_protnone_bits(req_prot);
 	if (pgprot_val(req_prot) & _PAGE_PRESENT)
-		pgprot_val(req_prot) |= _PAGE_PSE | _PAGE_GLOBAL;
+		pgprot_val(req_prot) |= _PAGE_PSE;
 	else
-		pgprot_val(req_prot) &= ~(_PAGE_PSE | _PAGE_GLOBAL);
-
+		pgprot_val(req_prot) &= ~_PAGE_PSE;
 	req_prot = canon_pgprot(req_prot);
 
 	/*
@@ -698,16 +708,7 @@ __split_large_page(struct cpa_data *cpa,
 		return 1;
 	}
 
-	/*
-	 * Set the GLOBAL flags only if the PRESENT flag is set
-	 * otherwise pmd/pte_present will return true even on a non
-	 * present pmd/pte. The canon_pgprot will clear _PAGE_GLOBAL
-	 * for the ancient hardware that doesn't support it.
-	 */
-	if (pgprot_val(ref_prot) & _PAGE_PRESENT)
-		pgprot_val(ref_prot) |= _PAGE_GLOBAL;
-	else
-		pgprot_val(ref_prot) &= ~_PAGE_GLOBAL;
+	ref_prot = pgprot_clear_protnone_bits(ref_prot);
 
 	/*
 	 * Get the target pfn from the original entry:
@@ -930,18 +931,7 @@ static void populate_pte(struct cpa_data
 
 	pte = pte_offset_kernel(pmd, start);
 
-	/*
-	 * Set the GLOBAL flags only if the PRESENT flag is
-	 * set otherwise pte_present will return true even on
-	 * a non present pte. The canon_pgprot will clear
-	 * _PAGE_GLOBAL for the ancient hardware that doesn't
-	 * support it.
-	 */
-	if (pgprot_val(pgprot) & _PAGE_PRESENT)
-		pgprot_val(pgprot) |= _PAGE_GLOBAL;
-	else
-		pgprot_val(pgprot) &= ~_PAGE_GLOBAL;
-
+	pgprot = pgprot_clear_protnone_bits(pgprot);
 	pgprot = canon_pgprot(pgprot);
 
 	while (num_pages-- && start < end) {
@@ -1234,17 +1224,7 @@ repeat:
 
 		new_prot = static_protections(new_prot, address, pfn);
 
-		/*
-		 * Set the GLOBAL flags only if the PRESENT flag is
-		 * set otherwise pte_present will return true even on
-		 * a non present pte. The canon_pgprot will clear
-		 * _PAGE_GLOBAL for the ancient hardware that doesn't
-		 * support it.
-		 */
-		if (pgprot_val(new_prot) & _PAGE_PRESENT)
-			pgprot_val(new_prot) |= _PAGE_GLOBAL;
-		else
-			pgprot_val(new_prot) &= ~_PAGE_GLOBAL;
+		new_prot = pgprot_clear_protnone_bits(new_prot);
 
 		/*
 		 * We need to keep the pfn from the existing PTE,
_
