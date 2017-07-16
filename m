Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1AA6B064C
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:58:54 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id z72so4667846qkz.7
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:54 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id o22si11705866qki.45.2017.07.15.20.58.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:58:53 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id v17so14724125qka.3
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:53 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 21/62] powerpc: introduce execute-only pkey
Date: Sat, 15 Jul 2017 20:56:23 -0700
Message-Id: <1500177424-13695-22-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

This patch provides the implementation of execute-only pkey.
The architecture-independent  expects the ability to create
and manage a special key which has execute-only permission.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/mmu.h |    1 +
 arch/powerpc/include/asm/pkeys.h         |    8 ++++-
 arch/powerpc/mm/pkeys.c                  |   57 ++++++++++++++++++++++++++++++
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
index 0e744f1..1864148 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -118,11 +118,15 @@ static inline int mm_pkey_free(struct mm_struct *mm, int pkey)
  * Try to dedicate one of the protection keys to be used as an
  * execute-only protection key.
  */
+extern int __execute_only_pkey(struct mm_struct *mm);
 static inline int execute_only_pkey(struct mm_struct *mm)
 {
-	return 0;
+	if (!pkey_inited)
+		return -1;
+	return __execute_only_pkey(mm);
 }
 
+
 static inline int arch_override_mprotect_pkey(struct vm_area_struct *vma,
 		int prot, int pkey)
 {
@@ -144,6 +148,8 @@ static inline void pkey_mm_init(struct mm_struct *mm)
 	if (!pkey_inited)
 		return;
 	mm_pkey_allocation_map(mm) = PKEY_INITIAL_ALLOCAION;
+	/* -1 means unallocated or invalid */
+	mm->context.execute_only_pkey = -1;
 }
 
 static inline void pkey_initialize(void)
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index b9ad98d..34e8557 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -97,3 +97,60 @@ int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 	init_iamr(pkey, new_iamr_bits);
 	return 0;
 }
+
+static inline bool pkey_allows_readwrite(int pkey)
+{
+	int pkey_shift = pkeyshift(pkey);
+
+	if (!(read_uamor() & (0x3UL << pkey_shift)))
+		return true;
+
+	return !(read_amr() & ((AMR_RD_BIT|AMR_WR_BIT) << pkey_shift));
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
