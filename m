Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 834A36B0008
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 18:24:17 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j18so5324291pfn.17
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 15:24:17 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id p16si5677937pgc.241.2018.04.20.15.24.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 15:24:16 -0700 (PDT)
Subject: [PATCH 3/5] x86, pti: reduce amount of kernel text allowed to be Global
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 20 Apr 2018 15:20:23 -0700
References: <20180420222018.E7646EE1@viggo.jf.intel.com>
In-Reply-To: <20180420222018.E7646EE1@viggo.jf.intel.com>
Message-Id: <20180420222023.1C8B2B20@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, keescook@google.com, aarcange@redhat.com, luto@kernel.org, arjan@linux.intel.com, bp@alien8.de, dan.j.williams@intel.com, dwmw2@infradead.org, gregkh@linuxfoundation.org, hughd@google.com, jpoimboe@redhat.com, jgross@suse.com, torvalds@linux-foundation.org, namit@vmware.com, peterz@infradead.org, tglx@linutronix.de


Kees reported to me that I made too much of the kernel image global.
It was far more than just text:

	I think this is too much set global: _end is after data,
	bss, and brk, and all kinds of other stuff that could
	hold secrets. I think this should match what
	mark_rodata_ro() is doing.

This does exactly that.  We use __end_rodata_hpage_align as our
marker both because it is huge-page-aligned and it does not contain
any sections we expect to hold secrets.

Kees's logic was that r/o data is in the kernel image anyway and,
in the case of traditional distributions, can be freely downloaded
from the web, so there's no reason to hide it.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reported-by: Kees Cook <keescook@google.com>
Fixes: 8c06c7740 (x86/pti: Leave kernel text global for !PCID)
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

 b/arch/x86/mm/pti.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff -puN arch/x86/mm/pti.c~pti-glb-too-much-mapped arch/x86/mm/pti.c
--- a/arch/x86/mm/pti.c~pti-glb-too-much-mapped	2018-04-20 14:10:02.164749166 -0700
+++ b/arch/x86/mm/pti.c	2018-04-20 14:10:02.168749166 -0700
@@ -430,12 +430,24 @@ static inline bool pti_kernel_image_glob
  */
 void pti_clone_kernel_text(void)
 {
+	/*
+	 * rodata is part of the kernel image and is normally
+	 * readable on the filesystem or on the web.  But, do not
+	 * clone the areas past rodata, they might contain secrets.
+	 */
 	unsigned long start = PFN_ALIGN(_text);
-	unsigned long end = ALIGN((unsigned long)_end, PMD_PAGE_SIZE);
+	unsigned long end = (unsigned long)__end_rodata_hpage_align;
 
 	if (!pti_kernel_image_global_ok())
 		return;
 
+	pr_debug("mapping partial kernel image into user address space\n");
+
+	/*
+	 * Note that this will undo _some_ of the work that
+	 * pti_set_kernel_image_nonglobal() did to clear the
+	 * global bit.
+	 */
 	pti_clone_pmds(start, end, _PAGE_RW);
 }
 
@@ -458,8 +470,6 @@ void pti_set_kernel_image_nonglobal(void
 	if (pti_kernel_image_global_ok())
 		return;
 
-	pr_debug("set kernel image non-global\n");
-
 	set_memory_nonglobal(start, (end - start) >> PAGE_SHIFT);
 }
 
_
