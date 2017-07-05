Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 43E3D6B03E8
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:23:16 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id k14so516156qkl.11
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:16 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id 35si119474qtt.80.2017.07.05.14.23.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:23:15 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id m54so195455qtb.1
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:15 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v5 19/38] powerpc: introduce execute-only pkey
Date: Wed,  5 Jul 2017 14:21:56 -0700
Message-Id: <1499289735-14220-20-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

This patch provides the implementation of execute-only pkey.
The architecture-independent  expects the ability to create
and manage a special key which has execute-only permission.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/mmu.h |    1 +
 arch/powerpc/include/asm/pkeys.h         |    6 +++-
 arch/powerpc/mm/pkeys.c                  |   59 ++++++++++++++++++++++++++++++
 3 files changed, 65 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/mmu.h b/arch/powerpc/include/asm/book3s/64/mmu.h
index 104ad72..0c0a2a8 100644
--- a/arch/powerpc/include/asm/book3s/64/mmu.h
+++ b/arch/powerpc/include/asm/book3s/64/mmu.h
@@ -116,6 +116,7 @@ struct patb_entry {
 	 * bit unset -> key available for allocation
 	 */
 	u32 pkey_allocation_map;
+	s16 execute_only_pkey; /* key holding execute-only protection */
 #endif
 } mm_context_t;
 
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 1495342..4b01c37 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -86,11 +86,13 @@ static inline int mm_pkey_free(struct mm_struct *mm, int pkey)
  * Try to dedicate one of the protection keys to be used as an
  * execute-only protection key.
  */
+extern int __execute_only_pkey(struct mm_struct *mm);
 static inline int execute_only_pkey(struct mm_struct *mm)
 {
-	return 0;
+	return __execute_only_pkey(mm);
 }
 
+
 static inline int arch_override_mprotect_pkey(struct vm_area_struct *vma,
 		int prot, int pkey)
 {
@@ -108,5 +110,7 @@ static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 static inline void pkey_mm_init(struct mm_struct *mm)
 {
 	mm_pkey_allocation_map(mm) = PKEY_INITIAL_ALLOCAION;
+	/* -1 means unallocated or invalid */
+	mm->context.execute_only_pkey = -1;
 }
 #endif /*_ASM_PPC64_PKEYS_H */
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index d3ba167..6c90317 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -64,3 +64,62 @@ int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 
 	return 0;
 }
+
+#define pkeyshift(pkey) ((arch_max_pkey()-pkey-1) * AMR_BITS_PER_PKEY)
+
+static inline bool pkey_allows_readwrite(int pkey)
+{
+	int pkey_shift = pkeyshift(pkey);
+
+	if (!(read_uamor() & (0x3UL << pkey_shift)))
+		return true;
+
+	return !(read_amr() & ((AMR_AD_BIT|AMR_WD_BIT) << pkey_shift));
+}
+
+int __execute_only_pkey(struct mm_struct *mm)
+{
+	bool need_to_set_mm_pkey = false;
+	int execute_only_pkey = mm->context.execute_only_pkey;
+	int ret;
+
+	/* Do we need to assign a pkey for mm's execute-only maps? */
+	if (execute_only_pkey == -1) {
+		/* Go allocate one to use, which might fail */
+		execute_only_pkey = mm_pkey_alloc(mm);
+		if (execute_only_pkey < 0)
+			return -1;
+		need_to_set_mm_pkey = true;
+	}
+
+	/*
+	 * We do not want to go through the relatively costly
+	 * dance to set AMR if we do not need to.  Check it
+	 * first and assume that if the execute-only pkey is
+	 * readwrite-disabled than we do not have to set it
+	 * ourselves.
+	 */
+	if (!need_to_set_mm_pkey &&
+	    !pkey_allows_readwrite(execute_only_pkey))
+		return execute_only_pkey;
+
+	/*
+	 * Set up AMR so that it denies access for everything
+	 * other than execution.
+	 */
+	ret = __arch_set_user_pkey_access(current, execute_only_pkey,
+			(PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE));
+	/*
+	 * If the AMR-set operation failed somehow, just return
+	 * 0 and effectively disable execute-only support.
+	 */
+	if (ret) {
+		mm_set_pkey_free(mm, execute_only_pkey);
+		return -1;
+	}
+
+	/* We got one, store it and use it from here on out */
+	if (need_to_set_mm_pkey)
+		mm->context.execute_only_pkey = execute_only_pkey;
+	return execute_only_pkey;
+}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
