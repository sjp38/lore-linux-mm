Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3519F6B0644
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:58:44 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id e127so3357567qka.8
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:44 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id t9si11728729qkt.381.2017.07.15.20.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:58:43 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id c18so6917725qkb.2
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:43 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 17/62] powerpc: implementation for arch_set_user_pkey_access()
Date: Sat, 15 Jul 2017 20:56:19 -0700
Message-Id: <1500177424-13695-18-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

This patch provides the detailed implementation for
a user to allocate a key and enable it in the hardware.

It provides the plumbing, but it cannot be used till
the system call is implemented. The next patch  will
do so.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/pkeys.h |   10 +++++++++-
 arch/powerpc/mm/pkeys.c          |   27 +++++++++++++++++++++++++++
 2 files changed, 36 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 7f5c21d..1943e6b 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -3,6 +3,10 @@
 
 extern bool pkey_inited;
 #define arch_max_pkey()  32
+#define AMR_RD_BIT 0x1UL
+#define AMR_WR_BIT 0x2UL
+#define IAMR_EX_BIT 0x1UL
+#define AMR_BITS_PER_PKEY 2
 #define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | \
 				VM_PKEY_BIT3 | VM_PKEY_BIT4)
 #define AMR_BITS_PER_PKEY 2
@@ -113,10 +117,14 @@ static inline int arch_override_mprotect_pkey(struct vm_area_struct *vma,
 	return 0;
 }
 
+extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+		unsigned long init_val);
 static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val)
 {
-	return 0;
+	if (!pkey_inited)
+		return -1;
+	return __arch_set_user_pkey_access(tsk, pkey, init_val);
 }
 
 static inline void pkey_mm_init(struct mm_struct *mm)
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 04ee361..98d0391 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -17,6 +17,10 @@
 
 bool pkey_inited;
 #define pkeyshift(pkey) ((arch_max_pkey()-pkey-1) * AMR_BITS_PER_PKEY)
+static bool is_pkey_enabled(int pkey)
+{
+	return !!(read_uamor() & (0x3ul << pkeyshift(pkey)));
+}
 
 static inline void init_amr(int pkey, u8 init_bits)
 {
@@ -60,3 +64,26 @@ void __arch_deactivate_pkey(int pkey)
 {
 	pkey_status_change(pkey, false);
 }
+
+/*
+ * set the access right in AMR IAMR and UAMOR register
+ * for @pkey to that specified in @init_val.
+ */
+int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+		unsigned long init_val)
+{
+	u64 new_amr_bits = 0x0ul;
+
+	if (!is_pkey_enabled(pkey))
+		return -1;
+
+	/* Set the bits we need in AMR:  */
+	if (init_val & PKEY_DISABLE_ACCESS)
+		new_amr_bits |= AMR_RD_BIT | AMR_WR_BIT;
+	else if (init_val & PKEY_DISABLE_WRITE)
+		new_amr_bits |= AMR_WR_BIT;
+
+	init_amr(pkey, new_amr_bits);
+
+	return 0;
+}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
