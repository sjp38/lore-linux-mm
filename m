Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id A82C46B0071
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:08:21 -0400 (EDT)
Message-Id: <20121025124832.996734608@chello.nl>
Date: Thu, 25 Oct 2012 14:16:24 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 07/31] sched, numa, mm, s390/thp: Implement pmd_pgprot() for s390
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0007-sched-numa-mm-s390-thp-Implement-pmd_pgprot-for-s390.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ralf Baechle <ralf@linux-mips.org>, Ingo Molnar <mingo@kernel.org>

From: Gerald Schaefer <gerald.schaefer@de.ibm.com>

This patch adds an implementation of pmd_pgprot() for s390,
in preparation to future THP changes.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/s390/include/asm/pgtable.h |   13 +++++++++++++
 1 file changed, 13 insertions(+)

Index: tip/arch/s390/include/asm/pgtable.h
===================================================================
--- tip.orig/arch/s390/include/asm/pgtable.h
+++ tip/arch/s390/include/asm/pgtable.h
@@ -1240,6 +1240,19 @@ static inline void set_pmd_at(struct mm_
 	*pmdp = entry;
 }
 
+static inline pgprot_t pmd_pgprot(pmd_t pmd)
+{
+	pgprot_t prot = PAGE_RW;
+
+	if (pmd_val(pmd) & _SEGMENT_ENTRY_RO) {
+		if (pmd_val(pmd) & _SEGMENT_ENTRY_INV)
+			prot = PAGE_NONE;
+		else
+			prot = PAGE_RO;
+	}
+	return prot;
+}
+
 static inline unsigned long massage_pgprot_pmd(pgprot_t pgprot)
 {
 	unsigned long pgprot_pmd = 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
