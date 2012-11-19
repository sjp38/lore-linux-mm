Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id DF3196B0071
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 21:15:30 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so3182484eek.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 18:15:30 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 03/27] x86/mm: Introduce pte_accessible()
Date: Mon, 19 Nov 2012 03:14:20 +0100
Message-Id: <1353291284-2998-4-git-send-email-mingo@kernel.org>
In-Reply-To: <1353291284-2998-1-git-send-email-mingo@kernel.org>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

From: Rik van Riel <riel@redhat.com>

We need pte_present to return true for _PAGE_PROTNONE pages, to indicate that
the pte is associated with a page.

However, for TLB flushing purposes, we would like to know whether the pte
points to an actually accessible page.  This allows us to skip remote TLB
flushes for pages that are not actually accessible.

Fill in this method for x86 and provide a safe (but slower) method
on other architectures.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Fixed-by: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Hugh Dickins <hughd@google.com>
Link: http://lkml.kernel.org/n/tip-66p11te4uj23gevgh4j987ip@git.kernel.org
[ Added Linus's review fixes. ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/include/asm/pgtable.h | 6 ++++++
 include/asm-generic/pgtable.h  | 4 ++++
 2 files changed, 10 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index a1f780d..5fe03aa 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -407,6 +407,12 @@ static inline int pte_present(pte_t a)
 	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE);
 }
 
+#define pte_accessible pte_accessible
+static inline int pte_accessible(pte_t a)
+{
+	return pte_flags(a) & _PAGE_PRESENT;
+}
+
 static inline int pte_hidden(pte_t pte)
 {
 	return pte_flags(pte) & _PAGE_HIDDEN;
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index b36ce40..48fc1dc 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -219,6 +219,10 @@ static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
 #define move_pte(pte, prot, old_addr, new_addr)	(pte)
 #endif
 
+#ifndef pte_accessible
+# define pte_accessible(pte)		((void)(pte),1)
+#endif
+
 #ifndef flush_tlb_fix_spurious_fault
 #define flush_tlb_fix_spurious_fault(vma, address) flush_tlb_page(vma, address)
 #endif
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
