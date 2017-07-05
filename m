Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id A9CAC6B03F3
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:23:30 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id h47so587738qta.12
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:30 -0700 (PDT)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id 123si47792qkd.376.2017.07.05.14.23.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:23:29 -0700 (PDT)
Received: by mail-qt0-x241.google.com with SMTP id m54so196044qtb.1
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:29 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v5 25/38] powerpc: helper to validate key-access permissions of a pte
Date: Wed,  5 Jul 2017 14:22:02 -0700
Message-Id: <1499289735-14220-26-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

helper function that checks if the read/write/execute is allowed
on the pte.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h |    2 +
 arch/powerpc/include/asm/pkeys.h             |    9 +++++++
 arch/powerpc/mm/pkeys.c                      |   31 ++++++++++++++++++++++++++
 3 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index d9c87c4..aad205c 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -474,6 +474,8 @@ static inline void write_uamor(u64 value)
 	mtspr(SPRN_UAMOR, value);
 }
 
+extern bool arch_pte_access_permitted(u64 pte, bool write, bool execute);
+
 #else /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
 
 static inline u64 read_amr(void)
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 6477b87..01f2bfc 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -31,6 +31,15 @@ static inline u64 pte_to_hpte_pkey_bits(u64 pteflags)
 		((pteflags & H_PAGE_PKEY_BIT4) ? HPTE_R_KEY_BIT4 : 0x0UL));
 }
 
+static inline u16 pte_to_pkey_bits(u64 pteflags)
+{
+	return (((pteflags & H_PAGE_PKEY_BIT0) ? 0x10 : 0x0UL) |
+		((pteflags & H_PAGE_PKEY_BIT1) ? 0x8 : 0x0UL) |
+		((pteflags & H_PAGE_PKEY_BIT2) ? 0x4 : 0x0UL) |
+		((pteflags & H_PAGE_PKEY_BIT3) ? 0x2 : 0x0UL) |
+		((pteflags & H_PAGE_PKEY_BIT4) ? 0x1 : 0x0UL));
+}
+
 static inline int vma_pkey(struct vm_area_struct *vma)
 {
 	return (vma->vm_flags & ARCH_VM_PKEY_FLAGS) >> VM_PKEY_SHIFT;
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index c60a045..044a17d 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -170,3 +170,34 @@ int __arch_override_mprotect_pkey(struct vm_area_struct *vma, int prot,
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
+		if (!(amr & (AMR_AD_BIT << pkey_shift)))
+			return true;
+	}
+
+	amr = read_amr(); /* delay reading amr uptil absolutely needed */
+	return (write && !(amr & (AMR_WD_BIT << pkey_shift)));
+}
+
+bool arch_pte_access_permitted(u64 pte, bool write, bool execute)
+{
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
