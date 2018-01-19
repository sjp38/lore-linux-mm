Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 82CB76B0274
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 20:52:30 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id k23so335541qtc.14
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 17:52:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 93sor5727058qtg.127.2018.01.18.17.52.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 17:52:29 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v10 16/27] powerpc: helper to validate key-access permissions of a pte
Date: Thu, 18 Jan 2018 17:50:37 -0800
Message-Id: <1516326648-22775-17-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
References: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

helper function that checks if the read/write/execute is allowed
on the pte.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h |    4 +++
 arch/powerpc/include/asm/pkeys.h             |    9 ++++++++
 arch/powerpc/mm/pkeys.c                      |   28 ++++++++++++++++++++++++++
 3 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index e1a8bb6..e785c68 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -462,6 +462,10 @@ static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
 		pte_update(mm, addr, ptep, 0, _PAGE_PRIVILEGED, 1);
 }
 
+#ifdef CONFIG_PPC_MEM_KEYS
+extern bool arch_pte_access_permitted(u64 pte, bool write, bool execute);
+#endif /* CONFIG_PPC_MEM_KEYS */
+
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 				       unsigned long addr, pte_t *ptep)
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 523d66c..7c45a40 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -82,6 +82,15 @@ static inline u64 pte_to_hpte_pkey_bits(u64 pteflags)
 		((pteflags & H_PTE_PKEY_BIT4) ? HPTE_R_KEY_BIT4 : 0x0UL));
 }
 
+static inline u16 pte_to_pkey_bits(u64 pteflags)
+{
+	return (((pteflags & H_PTE_PKEY_BIT0) ? 0x10 : 0x0UL) |
+		((pteflags & H_PTE_PKEY_BIT1) ? 0x8 : 0x0UL) |
+		((pteflags & H_PTE_PKEY_BIT2) ? 0x4 : 0x0UL) |
+		((pteflags & H_PTE_PKEY_BIT3) ? 0x2 : 0x0UL) |
+		((pteflags & H_PTE_PKEY_BIT4) ? 0x1 : 0x0UL));
+}
+
 #define pkey_alloc_mask(pkey) (0x1 << pkey)
 
 #define mm_pkey_allocation_map(mm) (mm->context.pkey_allocation_map)
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 7630c2f..0e044ea 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -362,3 +362,31 @@ int __arch_override_mprotect_pkey(struct vm_area_struct *vma, int prot,
 	/* Nothing to override. */
 	return vma_pkey(vma);
 }
+
+static bool pkey_access_permitted(int pkey, bool write, bool execute)
+{
+	int pkey_shift;
+	u64 amr;
+
+	if (!pkey)
+		return true;
+
+	if (!is_pkey_enabled(pkey))
+		return true;
+
+	pkey_shift = pkeyshift(pkey);
+	if (execute && !(read_iamr() & (IAMR_EX_BIT << pkey_shift)))
+		return true;
+
+	amr = read_amr(); /* Delay reading amr until absolutely needed */
+	return ((!write && !(amr & (AMR_RD_BIT << pkey_shift))) ||
+		(write &&  !(amr & (AMR_WR_BIT << pkey_shift))));
+}
+
+bool arch_pte_access_permitted(u64 pte, bool write, bool execute)
+{
+	if (static_branch_likely(&pkey_disabled))
+		return true;
+
+	return pkey_access_permitted(pte_to_pkey_bits(pte), write, execute);
+}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
