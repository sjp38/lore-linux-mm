Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2E523280257
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:59:36 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id t5so6812210qkc.14
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:59:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p36sor8244640qta.154.2017.11.06.00.59.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 00:59:35 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v9 27/51] mm, x86 : introduce arch_pkeys_enabled()
Date: Mon,  6 Nov 2017 00:57:19 -0800
Message-Id: <1509958663-18737-28-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

Arch neutral code needs to know if the architecture supports
protection  keys  to  display protection key in smaps. Hence
introducing arch_pkeys_enabled().

This patch also provides x86 implementation for
arch_pkeys_enabled().

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/x86/include/asm/pkeys.h |    1 +
 arch/x86/kernel/fpu/xstate.c |    5 +++++
 include/linux/pkeys.h        |    5 +++++
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/pkeys.h b/arch/x86/include/asm/pkeys.h
index a0ba1ff..f6c287b 100644
--- a/arch/x86/include/asm/pkeys.h
+++ b/arch/x86/include/asm/pkeys.h
@@ -6,6 +6,7 @@
 
 extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val);
+extern bool arch_pkeys_enabled(void);
 
 /*
  * Try to dedicate one of the protection keys to be used as an
diff --git a/arch/x86/kernel/fpu/xstate.c b/arch/x86/kernel/fpu/xstate.c
index f1d5476..a43db74 100644
--- a/arch/x86/kernel/fpu/xstate.c
+++ b/arch/x86/kernel/fpu/xstate.c
@@ -942,6 +942,11 @@ int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 
 	return 0;
 }
+
+bool arch_pkeys_enabled(void)
+{
+	return boot_cpu_has(X86_FEATURE_OSPKE);
+}
 #endif /* ! CONFIG_ARCH_HAS_PKEYS */
 
 /*
diff --git a/include/linux/pkeys.h b/include/linux/pkeys.h
index 0794ca7..3ca2e44 100644
--- a/include/linux/pkeys.h
+++ b/include/linux/pkeys.h
@@ -35,6 +35,11 @@ static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 	return 0;
 }
 
+static inline bool arch_pkeys_enabled(void)
+{
+	return false;
+}
+
 static inline void copy_init_pkru_to_fpregs(void)
 {
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
