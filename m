Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 65EA96B0005
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 17:16:45 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p12so12028876pfn.13
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 14:16:45 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id r14si4469006pgt.292.2018.04.17.14.16.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 14:16:44 -0700 (PDT)
Subject: [PATCH 2/2] x86, pti: fix boot warning from Global-bit setting
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 17 Apr 2018 14:13:04 -0700
References: <20180417211302.421F6442@viggo.jf.intel.com>
In-Reply-To: <20180417211302.421F6442@viggo.jf.intel.com>
Message-Id: <20180417211304.7B3F1FDB@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, mceier@gmail.com, aaro.koskinen@nokia.com, aarcange@redhat.com, luto@kernel.org, arjan@linux.intel.com, bp@alien8.de, dan.j.williams@intel.com, dwmw2@infradead.org, gregkh@linuxfoundation.org, hughd@google.com, jpoimboe@redhat.com, jgross@suse.com, keescook@google.com, torvalds@linux-foundation.org, namit@vmware.com, peterz@infradead.org, tglx@linutronix.de


These are _very_ lightly tested.  I'm throwing them out there for
folks are looking for a fix.

---

From: Dave Hansen <dave.hansen@linux.intel.com>

pageattr.c is not friendly when it encounters empty (zero) PTEs.  The
kernel linear map is exempt from these checks, but kernel text is not.
This patch adds the code to also exempt kernel text from these checks.
The proximate cause of these warnings was most likely an __init area
that spanned a 2MB page boundary that resulted in a "zero" PMD.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Fixes: 39114b7a7 (x86/pti: Never implicitly clear _PAGE_GLOBAL for kernel image)
Reported-by: Mariusz Ceier <mceier@gmail.com>
Reported-by: Aaro Koskinen <aaro.koskinen@nokia.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Kees Cook <keescook@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nadav Amit <namit@vmware.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
---

 b/arch/x86/mm/pageattr.c |   17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff -puN arch/x86/mm/pageattr.c~pti-glb-warning-inpageattr arch/x86/mm/pageattr.c
--- a/arch/x86/mm/pageattr.c~pti-glb-warning-inpageattr	2018-04-17 14:10:22.695395554 -0700
+++ b/arch/x86/mm/pageattr.c	2018-04-17 14:10:22.721395554 -0700
@@ -1151,6 +1151,16 @@ static int populate_pgd(struct cpa_data
 	return 0;
 }
 
+bool __cpa_pfn_in_highmap(unsigned long pfn)
+{
+	/*
+	 * Kernel text has an alias mapping at a high address, known
+	 * here as "highmap".
+	 */
+	return within_inclusive(pfn, highmap_start_pfn(),
+			highmap_end_pfn());
+}
+
 static int __cpa_process_fault(struct cpa_data *cpa, unsigned long vaddr,
 			       int primary)
 {
@@ -1183,6 +1193,10 @@ static int __cpa_process_fault(struct cp
 		cpa->numpages = 1;
 		cpa->pfn = __pa(vaddr) >> PAGE_SHIFT;
 		return 0;
+
+	} else if (__cpa_pfn_in_highmap(cpa->pfn)) {
+		/* Faults in the highmap are OK, so do not warn: */
+		return -EFAULT;
 	} else {
 		WARN(1, KERN_WARNING "CPA: called for zero pte. "
 			"vaddr = %lx cpa->vaddr = %lx\n", vaddr,
@@ -1335,8 +1349,7 @@ static int cpa_process_alias(struct cpa_
 	 * to touch the high mapped kernel as well:
 	 */
 	if (!within(vaddr, (unsigned long)_text, _brk_end) &&
-	    within_inclusive(cpa->pfn, highmap_start_pfn(),
-			     highmap_end_pfn())) {
+	    __cpa_pfn_in_highmap(cpa->pfn)) {
 		unsigned long temp_cpa_vaddr = (cpa->pfn << PAGE_SHIFT) +
 					       __START_KERNEL_map - phys_base;
 		alias_cpa = *cpa;
_
