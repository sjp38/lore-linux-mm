Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E126D6B0403
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:23:49 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 50so654432qtz.3
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:49 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id t41si109751qtg.226.2017.07.05.14.23.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:23:49 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id c20so202611qte.0
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:48 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v5 33/38] powerpc: Deliver SEGV signal on pkey violation
Date: Wed,  5 Jul 2017 14:22:10 -0700
Message-Id: <1499289735-14220-34-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

The value of the AMR register at the time of exception
is made available in gp_regs[PT_AMR] of the siginfo.

The value of the pkey, whose protection got violated,
is made available in si_pkey field of the siginfo structure.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/uapi/asm/ptrace.h |    3 ++-
 arch/powerpc/kernel/signal_32.c        |    5 +++++
 arch/powerpc/kernel/signal_64.c        |    4 ++++
 arch/powerpc/kernel/traps.c            |   14 ++++++++++++++
 4 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/include/uapi/asm/ptrace.h b/arch/powerpc/include/uapi/asm/ptrace.h
index 8036b38..7ec2428 100644
--- a/arch/powerpc/include/uapi/asm/ptrace.h
+++ b/arch/powerpc/include/uapi/asm/ptrace.h
@@ -108,8 +108,9 @@ struct pt_regs {
 #define PT_DAR	41
 #define PT_DSISR 42
 #define PT_RESULT 43
-#define PT_DSCR 44
 #define PT_REGS_COUNT 44
+#define PT_DSCR 44
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
index d4e545d..cc0a8c4 100644
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
@@ -247,6 +248,14 @@ void user_single_step_siginfo(struct task_struct *tsk,
 	info->si_addr = (void __user *)regs->nip;
 }
 
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+static void fill_sig_info_pkey(int si_code, siginfo_t *info, unsigned long addr)
+{
+	WARN_ON(si_code != SEGV_PKUERR);
+	info->si_pkey = get_paca()->paca_pkey;
+}
+#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 void _exception(int signr, struct pt_regs *regs, int code, unsigned long addr)
 {
 	siginfo_t info;
@@ -274,6 +283,11 @@ void _exception(int signr, struct pt_regs *regs, int code, unsigned long addr)
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
