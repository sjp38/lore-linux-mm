Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0947B6B000A
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 13:46:52 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s21so7003732pfm.15
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 10:46:52 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id p26-v6si9053861pli.534.2018.03.23.10.46.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 10:46:50 -0700 (PDT)
Subject: [PATCH 01/11] x86/mm: factor out pageattr _PAGE_GLOBAL setting
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 23 Mar 2018 10:44:49 -0700
References: <20180323174447.55F35636@viggo.jf.intel.com>
In-Reply-To: <20180323174447.55F35636@viggo.jf.intel.com>
Message-Id: <20180323174449.2C319A44@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The pageattr code has a pattern repeated where it sets
_PAGE_GLOBAL for present PTEs but clears it for non-present PTEs.
The intention is to keep _PAGE_GLOBAL from getting confused
with _PAGE_PROTNONE since _PAGE_GLOBAL is for present PTEs and
_PAGE_PROTNONE is for non-present

But, this pattern makes no sense.  Effectively, it says, if
you use the pageattr code, always set _PAGE_GLOBAL when
_PAGE_PRESENT.  canon_pgprot() will clear it if unsupported,
but we *always* set it.

This gets confusing when we have PTI and non-PTI and we want
some areas to have _PAGE_GLOBAL and some not.

This updated version of the code says:
1. Clear _PAGE_GLOBAL when !_PAGE_PRESENT
2. Never set _PAGE_GLOBAL implicitly
3. Allow _PAGE_GLOBAL to be in cpa.set_mask
4. Allow _PAGE_GLOBAL to be inherited from previous PTE

Aside: _PAGE_GLOBAL is ignored when CR4.PGE=1, so why do we
even go to the trouble of filtering it anywhere?

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

 b/arch/x86/mm/pageattr.c |   68 ++++++++++++++++-------------------------------
 1 file changed, 24 insertions(+), 44 deletions(-)

diff -puN arch/x86/mm/pageattr.c~kpti-centralize-global-setting arch/x86/mm/pageattr.c
--- a/arch/x86/mm/pageattr.c~kpti-centralize-global-setting	2018-03-21 16:31:56.262192322 -0700
+++ b/arch/x86/mm/pageattr.c	2018-03-21 16:31:56.266192322 -0700
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
-	if (pgprot_val(req_prot) & _PAGE_PRESENT)
-		pgprot_val(req_prot) |= _PAGE_PSE | _PAGE_GLOBAL;
+	req_prot = pgprot_clear_protnone_bits(req_prot);
+        if (pgprot_val(req_prot) & _PAGE_PRESENT)
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
