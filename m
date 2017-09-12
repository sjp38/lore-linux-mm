Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8C52A6B0266
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 11:40:02 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 6so22815969pgh.0
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 08:40:02 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id h9si7942823pgc.40.2017.09.12.08.40.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Sep 2017 08:40:01 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 09/11] x86/mm: Provide pmdp_establish() helper
Date: Tue, 12 Sep 2017 18:39:39 +0300
Message-Id: <20170912153941.47012-10-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170912153941.47012-1-kirill.shutemov@linux.intel.com>
References: <20170912153941.47012-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

We need an atomic way to setup pmd page table entry, avoiding races with
CPU setting dirty/accessed bits. This is required to implement
pmdp_invalidate() that doesn't loose these bits.

On PAE we can avoid expensive cmpxchg8b for cases when new page table
entry is not present. If it's present, fallback to cpmxchg loop.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/include/asm/pgtable-3level.h | 37 ++++++++++++++++++++++++++++++++++-
 arch/x86/include/asm/pgtable.h        | 15 ++++++++++++++
 2 files changed, 51 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index c8821bab938f..cd73be22be1d 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -157,7 +157,6 @@ static inline pte_t native_ptep_get_and_clear(pte_t *ptep)
 #define native_ptep_get_and_clear(xp) native_local_ptep_get_and_clear(xp)
 #endif
 
-#ifdef CONFIG_SMP
 union split_pmd {
 	struct {
 		u32 pmd_low;
@@ -165,6 +164,8 @@ union split_pmd {
 	};
 	pmd_t pmd;
 };
+
+#ifdef CONFIG_SMP
 static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
 {
 	union split_pmd res, *orig = (union split_pmd *)pmdp;
@@ -180,6 +181,40 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
 #define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
 #endif
 
+#ifndef pmdp_establish
+#define pmdp_establish pmdp_establish
+static inline pmd_t pmdp_establish(struct vm_area_struct *vma,
+		unsigned long address, pmd_t *pmdp, pmd_t pmd)
+{
+	pmd_t old;
+
+	/*
+	 * If pmd has present bit cleared we can get away without expensive
+	 * cmpxchg64: we can update pmdp half-by-half without racing with
+	 * anybody.
+	 */
+	if (!(pmd_val(pmd) & _PAGE_PRESENT)) {
+		union split_pmd old, new, *ptr;
+
+		ptr = (union split_pmd *)pmdp;
+
+		new.pmd = pmd;
+
+		/* xchg acts as a barrier before setting of the high bits */
+		old.pmd_low = xchg(&ptr->pmd_low, new.pmd_low);
+		old.pmd_high = ptr->pmd_high;
+		ptr->pmd_high = new.pmd_high;
+		return old.pmd;
+	}
+
+	{
+		old = *pmdp;
+	} while (cmpxchg64(&pmdp->pmd, old.pmd, pmd.pmd) != old.pmd);
+
+	return old;
+}
+#endif
+
 #ifdef CONFIG_SMP
 union split_pud {
 	struct {
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 5b4c44d419c5..ff19dbd6c93d 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1111,6 +1111,21 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 	clear_bit(_PAGE_BIT_RW, (unsigned long *)pmdp);
 }
 
+#ifndef pmdp_establish
+#define pmdp_establish pmdp_establish
+static inline pmd_t pmdp_establish(struct vm_area_struct *vma,
+		unsigned long address, pmd_t *pmdp, pmd_t pmd)
+{
+	if (IS_ENABLED(CONFIG_SMP)) {
+		return xchg(pmdp, pmd);
+	} else {
+		pmd_t old = *pmdp;
+		*pmdp = pmd;
+		return old;
+	}
+}
+#endif
+
 /*
  * clone_pgd_range(pgd_t *dst, pgd_t *src, int count);
  *
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
