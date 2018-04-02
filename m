Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2236B002C
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 13:29:50 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 1-v6so6045219plv.6
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 10:29:50 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id a61-v6si740752pla.400.2018.04.02.10.29.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Apr 2018 10:29:49 -0700 (PDT)
Subject: [PATCH 06/11] x86/mm: remove extra filtering in pageattr code
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Mon, 02 Apr 2018 10:27:09 -0700
References: <20180402172700.65CAE838@viggo.jf.intel.com>
In-Reply-To: <20180402172700.65CAE838@viggo.jf.intel.com>
Message-Id: <20180402172709.38FCB89B@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The pageattr code has a mode where it can set or clear PTE bits in
existing PTEs, so the page protections of the *new* PTEs come from
one of two places:
1. The set/clear masks: cpa->mask_clr / cpa->mask_set
2. The existing PTE

We filter ->mask_set/clr for supported PTE bits at entry to
__change_page_attr() so we never need to filter them again.

The only other place permissions can come from is an existing PTE
and those already presumably have good bits.  We do not need to filter
them again.

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

 b/arch/x86/mm/pageattr.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff -puN arch/x86/mm/pageattr.c~x86-pageattr-dont-filter-global arch/x86/mm/pageattr.c
--- a/arch/x86/mm/pageattr.c~x86-pageattr-dont-filter-global	2018-04-02 10:26:45.574661211 -0700
+++ b/arch/x86/mm/pageattr.c	2018-04-02 10:26:45.578661211 -0700
@@ -598,7 +598,6 @@ try_preserve_large_page(pte_t *kpte, uns
 	req_prot = pgprot_clear_protnone_bits(req_prot);
         if (pgprot_val(req_prot) & _PAGE_PRESENT)
 		pgprot_val(req_prot) |= _PAGE_PSE;
-	req_prot = canon_pgprot(req_prot);
 
 	/*
 	 * old_pfn points to the large page base pfn. So we need
@@ -718,7 +717,7 @@ __split_large_page(struct cpa_data *cpa,
 	 */
 	pfn = ref_pfn;
 	for (i = 0; i < PTRS_PER_PTE; i++, pfn += pfninc)
-		set_pte(&pbase[i], pfn_pte(pfn, canon_pgprot(ref_prot)));
+		set_pte(&pbase[i], pfn_pte(pfn, ref_prot));
 
 	if (virt_addr_valid(address)) {
 		unsigned long pfn = PFN_DOWN(__pa(address));
@@ -935,7 +934,6 @@ static void populate_pte(struct cpa_data
 	pte = pte_offset_kernel(pmd, start);
 
 	pgprot = pgprot_clear_protnone_bits(pgprot);
-	pgprot = canon_pgprot(pgprot);
 
 	while (num_pages-- && start < end) {
 		set_pte(pte, pfn_pte(cpa->pfn, pgprot));
@@ -1234,7 +1232,7 @@ repeat:
 		 * after all we're only going to change it's attributes
 		 * not the memory it points to
 		 */
-		new_pte = pfn_pte(pfn, canon_pgprot(new_prot));
+		new_pte = pfn_pte(pfn, new_prot);
 		cpa->pfn = pfn;
 		/*
 		 * Do we really change anything ?
_
