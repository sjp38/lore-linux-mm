Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0DA280257
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:59:07 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id t54so6599179qte.14
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:59:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m129sor7348791qkc.153.2017.11.06.00.59.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 00:59:06 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v9 17/51] powerpc: check key protection for user page access
Date: Mon,  6 Nov 2017 00:57:09 -0800
Message-Id: <1509958663-18737-18-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

Make sure that the kernel does not access user pages without
checking their key-protection.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index c277a63..5ecb846 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -464,6 +464,19 @@ static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
 
 #ifdef CONFIG_PPC_MEM_KEYS
 extern bool arch_pte_access_permitted(u64 pte, bool write, bool execute);
+
+#define pte_access_permitted(pte, write) \
+	(pte_present(pte) && \
+	 ((!(write) || pte_write(pte)) && \
+	  arch_pte_access_permitted(pte_val(pte), !!write, 0)))
+
+/*
+ * We store key in pmd for huge tlb pages. So need to check for key protection.
+ */
+#define pmd_access_permitted(pmd, write) \
+	(pmd_present(pmd) && \
+	 ((!(write) || pmd_write(pmd)) && \
+	  arch_pte_access_permitted(pmd_val(pmd), !!write, 0)))
 #endif /* CONFIG_PPC_MEM_KEYS */
 
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
