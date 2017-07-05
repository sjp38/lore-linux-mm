Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 294736B03FF
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:23:45 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d78so603148qkb.0
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:45 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id m3si31989qkd.257.2017.07.05.14.23.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:23:44 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id p21so206103qke.0
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:44 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v5 31/38] powerpc: introduce get_pte_pkey() helper
Date: Wed,  5 Jul 2017 14:22:08 -0700
Message-Id: <1499289735-14220-32-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

get_pte_pkey() helper returns the pkey associated with
a address corresponding to a given mm_struct.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/mmu-hash.h |    5 ++++
 arch/powerpc/mm/hash_utils_64.c               |   28 +++++++++++++++++++++++++
 2 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/mmu-hash.h b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
index f7a6ed3..369f9ff 100644
--- a/arch/powerpc/include/asm/book3s/64/mmu-hash.h
+++ b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
@@ -450,6 +450,11 @@ extern int hash_page(unsigned long ea, unsigned long access, unsigned long trap,
 int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
 		     pte_t *ptep, unsigned long trap, unsigned long flags,
 		     int ssize, unsigned int shift, unsigned int mmu_psize);
+
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+u16 get_pte_pkey(struct mm_struct *mm, unsigned long address);
+#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 extern int __hash_page_thp(unsigned long ea, unsigned long access,
 			   unsigned long vsid, pmd_t *pmdp, unsigned long trap,
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index 1e74529..591990c 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -1573,6 +1573,34 @@ void hash_preload(struct mm_struct *mm, unsigned long ea,
 	local_irq_restore(flags);
 }
 
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+/*
+ * return the protection key associated with the given address
+ * and the mm_struct.
+ */
+u16 get_pte_pkey(struct mm_struct *mm, unsigned long address)
+{
+	pte_t *ptep;
+	u16 pkey = 0;
+	unsigned long flags;
+
+	if (REGION_ID(address) == VMALLOC_REGION_ID)
+		mm = &init_mm;
+
+	if (!mm || !mm->pgd)
+		return 0;
+
+	local_irq_save(flags);
+	ptep = find_linux_pte_or_hugepte(mm->pgd, address,
+			NULL, NULL);
+	if (ptep)
+		pkey = pte_to_pkey_bits(pte_val(READ_ONCE(*ptep)));
+	local_irq_restore(flags);
+
+	return pkey;
+}
+#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 #ifdef CONFIG_PPC_TRANSACTIONAL_MEM
 static inline void tm_flush_hash_page(int local)
 {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
