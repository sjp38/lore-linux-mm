Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 460A68D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 08:47:53 -0400 (EDT)
Date: Fri, 18 Mar 2011 12:47:37 GMT
From: tip-bot for Shaohua Li <shaohua.li@intel.com>
Reply-To: mingo@redhat.com, hpa@zytor.com, linux-kernel@vger.kernel.org,
        torvalds@linux-foundation.org, shaohua.li@intel.com,
        asit.k.mallick@intel.com, y-goto@jp.fujitsu.com, riel@redhat.com,
        akpm@linux-foundation.org, stable@kernel.org, tglx@linutronix.de,
        linux-mm@kvack.org, mingo@elte.hu
In-Reply-To: <1300246649.2337.95.camel@sli10-conroe>
References: <1300246649.2337.95.camel@sli10-conroe>
Subject: [tip:x86/urgent] x86: Flush TLB if PGD entry is changed in i386 PAE mode
Message-ID: <tip-4981d01eada5354d81c8929d5b2836829ba3df7b@git.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, hpa@zytor.com, mingo@redhat.com, torvalds@linux-foundation.org, asit.k.mallick@intel.com, shaohua.li@intel.com, y-goto@jp.fujitsu.com, riel@redhat.com, akpm@linux-foundation.org, stable@kernel.org, tglx@linutronix.de, linux-mm@kvack.org, mingo@elte.hu

Commit-ID:  4981d01eada5354d81c8929d5b2836829ba3df7b
Gitweb:     http://git.kernel.org/tip/4981d01eada5354d81c8929d5b2836829ba3df7b
Author:     Shaohua Li <shaohua.li@intel.com>
AuthorDate: Wed, 16 Mar 2011 11:37:29 +0800
Committer:  Ingo Molnar <mingo@elte.hu>
CommitDate: Fri, 18 Mar 2011 11:44:01 +0100

x86: Flush TLB if PGD entry is changed in i386 PAE mode

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
Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Shaohua Li<shaohua.li@intel.com>
Cc: Mallick Asit K <asit.k.mallick@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>
Cc: stable <stable@kernel.org>
LKML-Reference: <1300246649.2337.95.camel@sli10-conroe>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 arch/x86/include/asm/pgtable-3level.h |   11 +++--------
 arch/x86/mm/pgtable.c                 |    3 +--
 2 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index 94b979d..effff47 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -69,8 +69,6 @@ static inline void native_pmd_clear(pmd_t *pmd)
 
 static inline void pud_clear(pud_t *pudp)
 {
-	unsigned long pgd;
-
 	set_pud(pudp, __pud(0));
 
 	/*
@@ -79,13 +77,10 @@ static inline void pud_clear(pud_t *pudp)
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
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 0113d19..8573b83 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -168,8 +168,7 @@ void pud_populate(struct mm_struct *mm, pud_t *pudp, pmd_t *pmd)
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
