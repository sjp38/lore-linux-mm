Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 600406B0069
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 20:52:47 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id d15so375608qtg.2
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 17:52:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 29sor6183466qkv.87.2018.01.18.17.52.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 17:52:46 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v10 22/27] powerpc/ptrace: Add memory protection key regset
Date: Thu, 18 Jan 2018 17:50:43 -0800
Message-Id: <1516326648-22775-23-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
References: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>

The AMR/IAMR/UAMOR are part of the program context.
Allow it to be accessed via ptrace and through core files.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
Signed-off-by: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pkeys.h    |    5 +++
 arch/powerpc/include/uapi/asm/elf.h |    1 +
 arch/powerpc/kernel/ptrace.c        |   66 +++++++++++++++++++++++++++++++++++
 arch/powerpc/kernel/traps.c         |    7 ++++
 include/uapi/linux/elf.h            |    1 +
 5 files changed, 80 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 7c45a40..0c480b2 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -213,6 +213,11 @@ static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 	return __arch_set_user_pkey_access(tsk, pkey, init_val);
 }
 
+static inline bool arch_pkeys_enabled(void)
+{
+	return !static_branch_likely(&pkey_disabled);
+}
+
 extern void pkey_mm_init(struct mm_struct *mm);
 extern void thread_pkey_regs_save(struct thread_struct *thread);
 extern void thread_pkey_regs_restore(struct thread_struct *new_thread,
diff --git a/arch/powerpc/include/uapi/asm/elf.h b/arch/powerpc/include/uapi/asm/elf.h
index 5f201d4..860c592 100644
--- a/arch/powerpc/include/uapi/asm/elf.h
+++ b/arch/powerpc/include/uapi/asm/elf.h
@@ -97,6 +97,7 @@
 #define ELF_NTMSPRREG	3	/* include tfhar, tfiar, texasr */
 #define ELF_NEBB	3	/* includes ebbrr, ebbhr, bescr */
 #define ELF_NPMU	5	/* includes siar, sdar, sier, mmcr2, mmcr0 */
+#define ELF_NPKEY	3	/* includes amr, iamr, uamor */
 
 typedef unsigned long elf_greg_t64;
 typedef elf_greg_t64 elf_gregset_t64[ELF_NGREG];
diff --git a/arch/powerpc/kernel/ptrace.c b/arch/powerpc/kernel/ptrace.c
index f52ad5b..3718a04 100644
--- a/arch/powerpc/kernel/ptrace.c
+++ b/arch/powerpc/kernel/ptrace.c
@@ -35,6 +35,7 @@
 #include <linux/context_tracking.h>
 
 #include <linux/uaccess.h>
+#include <linux/pkeys.h>
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/switch_to.h>
@@ -1775,6 +1776,61 @@ static int pmu_set(struct task_struct *target,
 	return ret;
 }
 #endif
+
+#ifdef CONFIG_PPC_MEM_KEYS
+static int pkey_active(struct task_struct *target,
+		       const struct user_regset *regset)
+{
+	if (!arch_pkeys_enabled())
+		return -ENODEV;
+
+	return regset->n;
+}
+
+static int pkey_get(struct task_struct *target,
+		    const struct user_regset *regset,
+		    unsigned int pos, unsigned int count,
+		    void *kbuf, void __user *ubuf)
+{
+	BUILD_BUG_ON(TSO(amr) + sizeof(unsigned long) != TSO(iamr));
+	BUILD_BUG_ON(TSO(iamr) + sizeof(unsigned long) != TSO(uamor));
+
+	if (!arch_pkeys_enabled())
+		return -ENODEV;
+
+	return user_regset_copyout(&pos, &count, &kbuf, &ubuf,
+				   &target->thread.amr, 0,
+				   ELF_NPKEY * sizeof(unsigned long));
+}
+
+static int pkey_set(struct task_struct *target,
+		      const struct user_regset *regset,
+		      unsigned int pos, unsigned int count,
+		      const void *kbuf, const void __user *ubuf)
+{
+	u64 new_amr;
+	int ret;
+
+	if (!arch_pkeys_enabled())
+		return -ENODEV;
+
+	/* Only the AMR can be set from userspace */
+	if (pos != 0 || count != sizeof(new_amr))
+		return -EINVAL;
+
+	ret = user_regset_copyin(&pos, &count, &kbuf, &ubuf,
+				 &new_amr, 0, sizeof(new_amr));
+	if (ret)
+		return ret;
+
+	/* UAMOR determines which bits of the AMR can be set from userspace. */
+	target->thread.amr = (new_amr & target->thread.uamor) |
+		(target->thread.amr & ~target->thread.uamor);
+
+	return 0;
+}
+#endif /* CONFIG_PPC_MEM_KEYS */
+
 /*
  * These are our native regset flavors.
  */
@@ -1809,6 +1865,9 @@ enum powerpc_regset {
 	REGSET_EBB,		/* EBB registers */
 	REGSET_PMR,		/* Performance Monitor Registers */
 #endif
+#ifdef CONFIG_PPC_MEM_KEYS
+	REGSET_PKEY,		/* AMR register */
+#endif
 };
 
 static const struct user_regset native_regsets[] = {
@@ -1914,6 +1973,13 @@ enum powerpc_regset {
 		.active = pmu_active, .get = pmu_get, .set = pmu_set
 	},
 #endif
+#ifdef CONFIG_PPC_MEM_KEYS
+	[REGSET_PKEY] = {
+		.core_note_type = NT_PPC_PKEY, .n = ELF_NPKEY,
+		.size = sizeof(u64), .align = sizeof(u64),
+		.active = pkey_active, .get = pkey_get, .set = pkey_set
+	},
+#endif
 };
 
 static const struct user_regset_view user_ppc_native_view = {
diff --git a/arch/powerpc/kernel/traps.c b/arch/powerpc/kernel/traps.c
index 3753498..c42ca5b 100644
--- a/arch/powerpc/kernel/traps.c
+++ b/arch/powerpc/kernel/traps.c
@@ -292,6 +292,13 @@ void _exception_pkey(int signr, struct pt_regs *regs, int code,
 		local_irq_enable();
 
 	current->thread.trap_nr = code;
+
+	/*
+	 * Save all the pkey registers AMR/IAMR/UAMOR. Eg: Core dumps need
+	 * to capture the content, if the task gets killed.
+	 */
+	thread_pkey_regs_save(&current->thread);
+
 	memset(&info, 0, sizeof(info));
 	info.si_signo = signr;
 	info.si_code = code;
diff --git a/include/uapi/linux/elf.h b/include/uapi/linux/elf.h
index bb68369..3bf73fb 100644
--- a/include/uapi/linux/elf.h
+++ b/include/uapi/linux/elf.h
@@ -396,6 +396,7 @@
 #define NT_PPC_TM_CTAR	0x10d		/* TM checkpointed Target Address Register */
 #define NT_PPC_TM_CPPR	0x10e		/* TM checkpointed Program Priority Register */
 #define NT_PPC_TM_CDSCR	0x10f		/* TM checkpointed Data Stream Control Register */
+#define NT_PPC_PKEY	0x110		/* Memory Protection Keys registers */
 #define NT_386_TLS	0x200		/* i386 TLS slots (struct user_desc) */
 #define NT_386_IOPERM	0x201		/* x86 io permission bitmap (1=deny) */
 #define NT_X86_XSTATE	0x202		/* x86 extended state using xsave */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
