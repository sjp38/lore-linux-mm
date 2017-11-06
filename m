Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 99D99280246
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:58:51 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id j185so6800547qkj.15
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:58:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n51sor8125386qta.110.2017.11.06.00.58.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 00:58:50 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v9 11/51] powerpc: introduce execute-only pkey
Date: Mon,  6 Nov 2017 00:57:03 -0800
Message-Id: <1509958663-18737-12-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

This patch provides the implementation of execute-only pkey.
The architecture-independent layer expects the arch-dependent
layer, to support the ability to create and enable a special
key which has execute-only permission.

Acked-by: Balbir Singh <bsingharora@gmail.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/mmu.h |    1 +
 arch/powerpc/include/asm/pkeys.h         |    8 ++++-
 arch/powerpc/mm/pkeys.c                  |   56 ++++++++++++++++++++++++++++++
 3 files changed, 64 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/mmu.h b/arch/powerpc/include/asm/book3s/64/mmu.h
index df17fbc..44dbc91 100644
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
index 0b2d9f0..20d1f0e 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -128,9 +128,13 @@ static inline int mm_pkey_free(struct mm_struct *mm, int pkey)
  * Try to dedicate one of the protection keys to be used as an
  * execute-only protection key.
  */
+extern int __execute_only_pkey(struct mm_struct *mm);
 static inline int execute_only_pkey(struct mm_struct *mm)
 {
-	return 0;
+	if (static_branch_likely(&pkey_disabled))
+		return -1;
+
+	return __execute_only_pkey(mm);
 }
 
 static inline int arch_override_mprotect_pkey(struct vm_area_struct *vma,
@@ -154,6 +158,8 @@ static inline void pkey_mm_init(struct mm_struct *mm)
 	if (static_branch_likely(&pkey_disabled))
 		return;
 	mm_pkey_allocation_map(mm) = initial_allocation_mask;
+	/* -1 means unallocated or invalid */
+	mm->context.execute_only_pkey = -1;
 }
 
 extern void thread_pkey_regs_save(struct thread_struct *thread);
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 469f370..5da94fe 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -247,3 +247,59 @@ void thread_pkey_regs_init(struct thread_struct *thread)
 	write_iamr(read_iamr() & pkey_iamr_mask);
 	write_uamor(read_uamor() & pkey_amr_uamor_mask);
 }
+
+static inline bool pkey_allows_readwrite(int pkey)
+{
+	int pkey_shift = pkeyshift(pkey);
+
+	if (!is_pkey_enabled(pkey))
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
+	 * We do not want to go through the relatively costly dance to set AMR
+	 * if we do not need to. Check it first and assume that if the
+	 * execute-only pkey is readwrite-disabled than we do not have to set it
+	 * ourselves.
+	 */
+	if (!need_to_set_mm_pkey && !pkey_allows_readwrite(execute_only_pkey))
+		return execute_only_pkey;
+
+	/*
+	 * Set up AMR so that it denies access for everything other than
+	 * execution.
+	 */
+	ret = __arch_set_user_pkey_access(current, execute_only_pkey,
+					  PKEY_DISABLE_ACCESS |
+					  PKEY_DISABLE_WRITE);
+	/*
+	 * If the AMR-set operation failed somehow, just return 0 and
+	 * effectively disable execute-only support.
+	 */
+	if (ret) {
+		mm_pkey_free(mm, execute_only_pkey);
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
