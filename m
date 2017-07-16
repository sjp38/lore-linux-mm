Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id AB38D6B065F
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:59:08 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id p25so57093741qtp.4
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:59:08 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id t187si12099323qkh.150.2017.07.15.20.59.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:59:07 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id q66so17063906qki.1
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:59:07 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 27/62] powerpc: helper to validate key-access permissions of a pte
Date: Sat, 15 Jul 2017 20:56:29 -0700
Message-Id: <1500177424-13695-28-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

helper function that checks if the read/write/execute is allowed
on the pte.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h |    4 +++
 arch/powerpc/include/asm/pkeys.h             |   12 +++++++++
 arch/powerpc/mm/pkeys.c                      |   33 ++++++++++++++++++++++++++
 3 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 30d7f55..0056e58 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -472,6 +472,10 @@ static inline void write_uamor(u64 value)
 	mtspr(SPRN_UAMOR, value);
 }
 
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+extern bool arch_pte_access_permitted(u64 pte, bool write, bool execute);
+#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 				       unsigned long addr, pte_t *ptep)
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index bbb5d85..7a9aade 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -53,6 +53,18 @@ static inline u64 pte_to_hpte_pkey_bits(u64 pteflags)
 		((pteflags & H_PAGE_PKEY_BIT4) ? HPTE_R_KEY_BIT4 : 0x0UL));
 }
 
+static inline u16 pte_to_pkey_bits(u64 pteflags)
+{
+	if (!pkey_inited)
+		return 0x0UL;
+
+	return (((pteflags & H_PAGE_PKEY_BIT0) ? 0x10 : 0x0UL) |
+		((pteflags & H_PAGE_PKEY_BIT1) ? 0x8 : 0x0UL) |
+		((pteflags & H_PAGE_PKEY_BIT2) ? 0x4 : 0x0UL) |
+		((pteflags & H_PAGE_PKEY_BIT3) ? 0x2 : 0x0UL) |
+		((pteflags & H_PAGE_PKEY_BIT4) ? 0x1 : 0x0UL));
+}
+
 static inline int vma_pkey(struct vm_area_struct *vma)
 {
 	if (!pkey_inited)
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 403f5ae..1794e17 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -201,3 +201,36 @@ int __arch_override_mprotect_pkey(struct vm_area_struct *vma, int prot,
 	 */
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
+	pkey_shift = pkeyshift(pkey);
+	if (!(read_uamor() & (0x3UL << pkey_shift)))
+		return true;
+
+	if (execute && !(read_iamr() & (IAMR_EX_BIT << pkey_shift)))
+		return true;
+
+	if (!write) {
+		amr = read_amr();
+		if (!(amr & (AMR_RD_BIT << pkey_shift)))
+			return true;
+	}
+
+	amr = read_amr(); /* delay reading amr uptil absolutely needed */
+	return (write && !(amr & (AMR_WR_BIT << pkey_shift)));
+}
+
+bool arch_pte_access_permitted(u64 pte, bool write, bool execute)
+{
+	if (!pkey_inited)
+		return true;
+	return pkey_access_permitted(pte_to_pkey_bits(pte),
+			write, execute);
+}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
