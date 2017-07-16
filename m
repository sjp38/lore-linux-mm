Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id EE22A6B066C
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:59:28 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v76so59118377qka.5
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:59:28 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id f5si11865534qtg.123.2017.07.15.20.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:59:28 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id c18so6918681qkb.2
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:59:28 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 35/62] powerpc: Deliver SEGV signal on pkey violation
Date: Sat, 15 Jul 2017 20:56:37 -0700
Message-Id: <1500177424-13695-36-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

The value of the AMR register at the time of exception
is made available in gp_regs[PT_AMR] of the siginfo.

The value of the pkey, whose protection got violated,
is made available in si_pkey field of the siginfo structure.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/uapi/asm/ptrace.h |    1 +
 arch/powerpc/kernel/signal_32.c        |    5 +++++
 arch/powerpc/kernel/signal_64.c        |    4 ++++
 arch/powerpc/kernel/traps.c            |   15 +++++++++++++++
 4 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/include/uapi/asm/ptrace.h b/arch/powerpc/include/uapi/asm/ptrace.h
index 8036b38..fc9c9c0 100644
--- a/arch/powerpc/include/uapi/asm/ptrace.h
+++ b/arch/powerpc/include/uapi/asm/ptrace.h
@@ -110,6 +110,7 @@ struct pt_regs {
 #define PT_RESULT 43
 #define PT_DSCR 44
 #define PT_REGS_COUNT 44
+#define PT_AMR	45
 
 #define PT_FPR0	48	/* each FP reg occupies 2 slots in this space */
 
diff --git a/arch/powerpc/kernel/signal_32.c b/arch/powerpc/kernel/signal_32.c
index 97bb138..9c4a7f3 100644
--- a/arch/powerpc/kernel/signal_32.c
+++ b/arch/powerpc/kernel/signal_32.c
@@ -500,6 +500,11 @@ static int save_user_regs(struct pt_regs *regs, struct mcontext __user *frame,
 				   (unsigned long) &frame->tramp[2]);
 	}
 
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	if (__put_user(get_paca()->paca_amr, &frame->mc_gregs[PT_AMR]))
+		return 1;
+#endif /*  CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 	return 0;
 }
 
diff --git a/arch/powerpc/kernel/signal_64.c b/arch/powerpc/kernel/signal_64.c
index c83c115..86a4262 100644
--- a/arch/powerpc/kernel/signal_64.c
+++ b/arch/powerpc/kernel/signal_64.c
@@ -174,6 +174,10 @@ static long setup_sigcontext(struct sigcontext __user *sc,
 	if (set != NULL)
 		err |=  __put_user(set->sig[0], &sc->oldmask);
 
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	err |= __put_user(get_paca()->paca_amr, &sc->gp_regs[PT_AMR]);
+#endif /*  CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 	return err;
 }
 
diff --git a/arch/powerpc/kernel/traps.c b/arch/powerpc/kernel/traps.c
index d4e545d..fe1e7c7 100644
--- a/arch/powerpc/kernel/traps.c
+++ b/arch/powerpc/kernel/traps.c
@@ -20,6 +20,7 @@
 #include <linux/sched/debug.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
+#include <linux/pkeys.h>
 #include <linux/stddef.h>
 #include <linux/unistd.h>
 #include <linux/ptrace.h>
@@ -247,6 +248,15 @@ void user_single_step_siginfo(struct task_struct *tsk,
 	info->si_addr = (void __user *)regs->nip;
 }
 
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+static void fill_sig_info_pkey(int si_code, siginfo_t *info, unsigned long addr)
+{
+	if (si_code != SEGV_PKUERR)
+		return;
+	info->si_pkey = get_paca()->paca_pkey;
+}
+#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 void _exception(int signr, struct pt_regs *regs, int code, unsigned long addr)
 {
 	siginfo_t info;
@@ -274,6 +284,11 @@ void _exception(int signr, struct pt_regs *regs, int code, unsigned long addr)
 	info.si_signo = signr;
 	info.si_code = code;
 	info.si_addr = (void __user *) addr;
+
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	fill_sig_info_pkey(code, &info, addr);
+#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 	force_sig_info(signr, &info, current);
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
