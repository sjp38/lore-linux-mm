Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5196B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 09:52:03 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id a70so861323pge.8
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 06:52:03 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 1si65803pgw.51.2017.06.14.06.52.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 06:52:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/3] x86/mm: Provide pmdp_mknotpresent() helper
Date: Wed, 14 Jun 2017 16:51:41 +0300
Message-Id: <20170614135143.25068-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170614135143.25068-1-kirill.shutemov@linux.intel.com>
References: <20170614135143.25068-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

We need an atomic way to make pmd page table entry not-present.
This is required to implement pmdp_invalidate() that doesn't loose dirty
or access bits.

On x86, we need to clear two bits -- _PAGE_PRESENT and _PAGE_PROTNONE --
to make the entry non-present. The implementation uses cmpxchg() loop to
make it atomically.

PAE requires special treatment to avoid expensive cmpxchg8b(). Both
bits are in the lower part of the entry, so we can use 4-byte cmpxchg() on
this part of page table entry.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/include/asm/pgtable-3level.h | 17 +++++++++++++++++
 arch/x86/include/asm/pgtable.h        | 13 +++++++++++++
 2 files changed, 30 insertions(+)

diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index 50d35e3185f5..b6efa955ecd0 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -176,8 +176,25 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
 
 	return res.pmd;
 }
+
+#define pmdp_mknotpresent pmdp_mknotpresent
+static inline void pmdp_mknotpresent(pmd_t *pmdp)
+{
+	union split_pmd *p, old, new;
+
+	p = (union split_pmd *)pmdp;
+	{
+		old = *p;
+		new.pmd = pmd_mknotpresent(old.pmd);
+	} while (cmpxchg(&p->pmd_low, old.pmd_low, new.pmd_low) != old.pmd_low);
+}
 #else
 #define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
+
+static inline void pmdp_mknotpresent(pmd_t *pmdp)
+{
+	*pmdp = pmd_mknotpresent(*pmdp);
+}
 #endif
 
 #ifdef CONFIG_SMP
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index f5af95a0c6b8..576420df12b8 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1092,6 +1092,19 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 	clear_bit(_PAGE_BIT_RW, (unsigned long *)pmdp);
 }
 
+#ifndef pmdp_mknotpresent
+#define pmdp_mknotpresent pmdp_mknotpresent
+static inline void pmdp_mknotpresent(pmd_t *pmdp)
+{
+	pmd_t old, new;
+
+	{
+		old = *pmdp;
+		new = pmd_mknotpresent(old);
+	} while (pmd_val(cmpxchg(pmdp, old, new)) != pmd_val(old));
+}
+#endif
+
 /*
  * clone_pgd_range(pgd_t *dst, pgd_t *src, int count);
  *
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
