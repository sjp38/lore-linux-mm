Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0CA23280257
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:59:10 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id h9so6589957qtc.2
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:59:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n36sor2332220qkh.9.2017.11.06.00.59.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 00:59:09 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v9 18/51] powerpc: implementation for arch_vma_access_permitted()
Date: Mon,  6 Nov 2017 00:57:10 -0800
Message-Id: <1509958663-18737-19-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

This patch provides the implementation for
arch_vma_access_permitted(). Returns true if the
requested access is allowed by pkey associated with the
vma.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/mmu_context.h |    5 +++-
 arch/powerpc/mm/pkeys.c                |   34 ++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index a557735..95a3288 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -136,6 +136,10 @@ static inline void arch_bprm_mm_init(struct mm_struct *mm,
 {
 }
 
+#ifdef CONFIG_PPC_MEM_KEYS
+bool arch_vma_access_permitted(struct vm_area_struct *vma, bool write,
+			       bool execute, bool foreign);
+#else /* CONFIG_PPC_MEM_KEYS */
 static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 		bool write, bool execute, bool foreign)
 {
@@ -143,7 +147,6 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 	return true;
 }
 
-#ifndef CONFIG_PPC_MEM_KEYS
 #define pkey_initialize()
 #define pkey_mm_init(mm)
 #define thread_pkey_regs_save(thread)
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 13902be..3b221bd 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -375,3 +375,37 @@ bool arch_pte_access_permitted(u64 pte, bool write, bool execute)
 
 	return pkey_access_permitted(pte_to_pkey_bits(pte), write, execute);
 }
+
+/*
+ * We only want to enforce protection keys on the current thread because we
+ * effectively have no access to AMR/IAMR for other threads or any way to tell
+ * which AMR/IAMR in a threaded process we could use.
+ *
+ * So do not enforce things if the VMA is not from the current mm, or if we are
+ * in a kernel thread.
+ */
+static inline bool vma_is_foreign(struct vm_area_struct *vma)
+{
+	if (!current->mm)
+		return true;
+
+	/* if it is not our ->mm, it has to be foreign */
+	if (current->mm != vma->vm_mm)
+		return true;
+
+	return false;
+}
+
+bool arch_vma_access_permitted(struct vm_area_struct *vma, bool write,
+			       bool execute, bool foreign)
+{
+	if (static_branch_likely(&pkey_disabled))
+		return true;
+	/*
+	 * Do not enforce our key-permissions on a foreign vma.
+	 */
+	if (foreign || vma_is_foreign(vma))
+		return true;
+
+	return pkey_access_permitted(vma_pkey(vma), write, execute);
+}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
