Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 807D86B0038
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 11:39:55 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e199so21122334pfh.3
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 08:39:55 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u64si7776612pgd.545.2017.09.12.08.39.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Sep 2017 08:39:54 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 04/11] arm64: Provide pmdp_establish() helper
Date: Tue, 12 Sep 2017 18:39:34 +0300
Message-Id: <20170912153941.47012-5-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170912153941.47012-1-kirill.shutemov@linux.intel.com>
References: <20170912153941.47012-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Catalin Marinas <catalin.marinas@arm.com>

We need an atomic way to setup pmd page table entry, avoiding races with
CPU setting dirty/accessed bits. This is required to implement
pmdp_invalidate() that doesn't lose these bits.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/arm64/include/asm/pgtable.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index bc4e92337d16..09bb86533d32 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -663,6 +663,13 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 {
 	ptep_set_wrprotect(mm, address, (pte_t *)pmdp);
 }
+
+#define pmdp_establish pmdp_establish
+static inline pmd_t pmdp_establish(struct vm_area_struct *vma,
+		unsigned long address, pmd_t *pmdp, pmd_t pmd)
+{
+	return __pmd(xchg_relaxed(&pmd_val(*pmdp), pmd_val(pmd)));
+}
 #endif
 
 extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
