Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 88CA28D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 17:09:42 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <20110330203.501921634@firstfloor.org>
In-Reply-To: <20110330203.501921634@firstfloor.org>
Subject: [PATCH] [214/275] x86: Flush TLB if PGD entry is changed in i386 PAE mode
Message-Id: <20110330210739.07D5E3E1A05@tassilo.jf.intel.com>
Date: Wed, 30 Mar 2011 14:07:38 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shaohua.li@intel.com, y-goto@jp.fujitsu.com, ak@linux.intel.com, riel@redhat.com, asit.k.mallick@intel.com, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-mm@kvack.org, mingo@elte.hu, gregkh@suse.de, linux-kernel@vger.kernel.org, stable@kernel.org, tim.bird@am.sony.com

2.6.35-longterm review patch.  If anyone has any objections, please let me know.

------------------
From: Shaohua Li <shaohua.li@intel.com>

commit 4981d01eada5354d81c8929d5b2836829ba3df7b upstream.

According to intel CPU manual, every time PGD entry is changed in i386 PAE
mode, we need do a full TLB flush. Current code follows this and there is
comment for this too in the code.

But current code misses the multi-threaded case. A changed page table
might be used by several CPUs, every such CPU should flush TLB. Usually
this isn't a problem, because we prepopulate all PGD entries at process
fork. But when the process does munmap and follows new mmap, this issue
will be triggered.

When it happens, some CPUs keep doing page faults:

  http://marc.info/?l=linux-kernel&m=129915020508238&w=2

Reported-by: Yasunori Goto<y-goto@jp.fujitsu.com>
Tested-by: Yasunori Goto<y-goto@jp.fujitsu.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Shaohua Li<shaohua.li@intel.com>
Cc: Mallick Asit K <asit.k.mallick@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>
LKML-Reference: <1300246649.2337.95.camel@sli10-conroe>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 arch/x86/include/asm/pgtable-3level.h |   11 +++--------
 arch/x86/mm/pgtable.c                 |    3 +--
 2 files changed, 4 insertions(+), 10 deletions(-)

Index: linux-2.6.35.y/arch/x86/include/asm/pgtable-3level.h
===================================================================
--- linux-2.6.35.y.orig/arch/x86/include/asm/pgtable-3level.h	2011-03-29 22:50:32.352430601 -0700
+++ linux-2.6.35.y/arch/x86/include/asm/pgtable-3level.h	2011-03-29 23:03:02.707230900 -0700
@@ -69,8 +69,6 @@
 
 static inline void pud_clear(pud_t *pudp)
 {
-	unsigned long pgd;
-
 	set_pud(pudp, __pud(0));
 
 	/*
@@ -79,13 +77,10 @@
 	 * section 8.1: in PAE mode we explicitly have to flush the
 	 * TLB via cr3 if the top-level pgd is changed...
 	 *
-	 * Make sure the pud entry we're updating is within the
-	 * current pgd to avoid unnecessary TLB flushes.
+	 * Currently all places where pud_clear() is called either have
+	 * flush_tlb_mm() followed or don't need TLB flush (x86_64 code or
+	 * pud_clear_bad()), so we don't need TLB flush here.
 	 */
-	pgd = read_cr3();
-	if (__pa(pudp) >= pgd && __pa(pudp) <
-	    (pgd + sizeof(pgd_t)*PTRS_PER_PGD))
-		write_cr3(pgd);
 }
 
 #ifdef CONFIG_SMP
Index: linux-2.6.35.y/arch/x86/mm/pgtable.c
===================================================================
--- linux-2.6.35.y.orig/arch/x86/mm/pgtable.c	2011-03-29 22:50:32.352430601 -0700
+++ linux-2.6.35.y/arch/x86/mm/pgtable.c	2011-03-29 23:03:02.708230874 -0700
@@ -160,8 +160,7 @@
 	 * section 8.1: in PAE mode we explicitly have to flush the
 	 * TLB via cr3 if the top-level pgd is changed...
 	 */
-	if (mm == current->active_mm)
-		write_cr3(read_cr3());
+	flush_tlb_mm(mm);
 }
 #else  /* !CONFIG_X86_PAE */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
