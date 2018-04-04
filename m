Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 61B636B0007
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 21:12:35 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id q12-v6so9905358plr.17
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 18:12:35 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id g11si1214037pgs.153.2018.04.03.18.12.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 18:12:34 -0700 (PDT)
Subject: [PATCH 02/11] x86/mm: undo double _PAGE_PSE clearing
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 03 Apr 2018 18:09:48 -0700
References: <20180404010946.6186729B@viggo.jf.intel.com>
In-Reply-To: <20180404010946.6186729B@viggo.jf.intel.com>
Message-Id: <20180404010948.548BE9FA@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com


From: Dave Hansen <dave.hansen@linux.intel.com>

When clearing _PAGE_PRESENT on a huge page, we need to be careful
to also clear _PAGE_PSE, otherwise it might still get confused
for a valid large page table entry.

We do that near the spot where we *set* _PAGE_PSE.  That's fine,
but it's unnecessary.  pgprot_large_2_4k() already did it.

BTW, I also noticed that pgprot_large_2_4k() and
pgprot_4k_2_large() are not symmetric.  pgprot_large_2_4k() clears
_PAGE_PSE (because it is aliased to _PAGE_PAT) but
pgprot_4k_2_large() does not put _PAGE_PSE back.  Bummer.

Also, add some comments and change "promote" to "move".  "Promote"
seems an odd word to move when we are logically moving a bit to a
lower bit position.  Also add an extra line return to make it clear
to which line the comment applies.

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

 b/arch/x86/mm/pageattr.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff -puN arch/x86/mm/pageattr.c~kpti-undo-double-_PAGE_PSE-clear arch/x86/mm/pageattr.c
--- a/arch/x86/mm/pageattr.c~kpti-undo-double-_PAGE_PSE-clear	2018-04-02 16:41:13.124605178 -0700
+++ b/arch/x86/mm/pageattr.c	2018-04-02 16:41:13.128605178 -0700
@@ -583,6 +583,7 @@ try_preserve_large_page(pte_t *kpte, uns
 	 * up accordingly.
 	 */
 	old_pte = *kpte;
+	/* Clear PSE (aka _PAGE_PAT) and move PAT bit to correct position */
 	req_prot = pgprot_large_2_4k(old_prot);
 
 	pgprot_val(req_prot) &= ~pgprot_val(cpa->mask_clr);
@@ -597,8 +598,6 @@ try_preserve_large_page(pte_t *kpte, uns
 	req_prot = pgprot_clear_protnone_bits(req_prot);
 	if (pgprot_val(req_prot) & _PAGE_PRESENT)
 		pgprot_val(req_prot) |= _PAGE_PSE;
-	else
-		pgprot_val(req_prot) &= ~_PAGE_PSE;
 	req_prot = canon_pgprot(req_prot);
 
 	/*
@@ -684,8 +683,12 @@ __split_large_page(struct cpa_data *cpa,
 	switch (level) {
 	case PG_LEVEL_2M:
 		ref_prot = pmd_pgprot(*(pmd_t *)kpte);
-		/* clear PSE and promote PAT bit to correct position */
+		/*
+		 * Clear PSE (aka _PAGE_PAT) and move
+		 * PAT bit to correct position.
+		 */
 		ref_prot = pgprot_large_2_4k(ref_prot);
+
 		ref_pfn = pmd_pfn(*(pmd_t *)kpte);
 		break;
 
_
