Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68C6C6B0038
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 20:52:44 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id e2so370499qti.3
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 17:52:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 41sor4416656qtp.135.2018.01.18.17.52.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 17:52:43 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v10 21/27] powerpc: Deliver SEGV signal on pkey violation
Date: Thu, 18 Jan 2018 17:50:42 -0800
Message-Id: <1516326648-22775-22-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
References: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

The value of the pkey, whose protection got violated,
is made available in si_pkey field of the siginfo structure.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
Signed-off-by: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/bug.h |    1 +
 arch/powerpc/kernel/traps.c    |   12 +++++++++++-
 arch/powerpc/mm/fault.c        |   39 +++++++++++++++++++++++++++------------
 3 files changed, 39 insertions(+), 13 deletions(-)

diff --git a/arch/powerpc/include/asm/bug.h b/arch/powerpc/include/asm/bug.h
index 3c04249..97c3847 100644
--- a/arch/powerpc/include/asm/bug.h
+++ b/arch/powerpc/include/asm/bug.h
@@ -133,6 +133,7 @@
 extern int do_page_fault(struct pt_regs *, unsigned long, unsigned long);
 extern void bad_page_fault(struct pt_regs *, unsigned long, int);
 extern void _exception(int, struct pt_regs *, int, unsigned long);
+extern void _exception_pkey(int, struct pt_regs *, int, unsigned long, int);
 extern void die(const char *, struct pt_regs *, long);
 extern bool die_will_crash(void);
 
diff --git a/arch/powerpc/kernel/traps.c b/arch/powerpc/kernel/traps.c
index f3eb61b..3753498 100644
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
@@ -266,7 +267,9 @@ void user_single_step_siginfo(struct task_struct *tsk,
 	info->si_addr = (void __user *)regs->nip;
 }
 
-void _exception(int signr, struct pt_regs *regs, int code, unsigned long addr)
+
+void _exception_pkey(int signr, struct pt_regs *regs, int code,
+		unsigned long addr, int key)
 {
 	siginfo_t info;
 	const char fmt32[] = KERN_INFO "%s[%d]: unhandled signal %d " \
@@ -293,9 +296,16 @@ void _exception(int signr, struct pt_regs *regs, int code, unsigned long addr)
 	info.si_signo = signr;
 	info.si_code = code;
 	info.si_addr = (void __user *) addr;
+	info.si_pkey = key;
+
 	force_sig_info(signr, &info, current);
 }
 
+void _exception(int signr, struct pt_regs *regs, int code, unsigned long addr)
+{
+	_exception_pkey(signr, regs, code, addr, 0);
+}
+
 void system_reset_exception(struct pt_regs *regs)
 {
 	/*
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 943a91e..65f8b04 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -107,7 +107,8 @@ static bool store_updates_sp(struct pt_regs *regs)
  */
 
 static int
-__bad_area_nosemaphore(struct pt_regs *regs, unsigned long address, int si_code)
+__bad_area_nosemaphore(struct pt_regs *regs, unsigned long address, int si_code,
+		int pkey)
 {
 	/*
 	 * If we are in kernel mode, bail out with a SEGV, this will
@@ -117,17 +118,18 @@ static bool store_updates_sp(struct pt_regs *regs)
 	if (!user_mode(regs))
 		return SIGSEGV;
 
-	_exception(SIGSEGV, regs, si_code, address);
+	_exception_pkey(SIGSEGV, regs, si_code, address, pkey);
 
 	return 0;
 }
 
 static noinline int bad_area_nosemaphore(struct pt_regs *regs, unsigned long address)
 {
-	return __bad_area_nosemaphore(regs, address, SEGV_MAPERR);
+	return __bad_area_nosemaphore(regs, address, SEGV_MAPERR, 0);
 }
 
-static int __bad_area(struct pt_regs *regs, unsigned long address, int si_code)
+static int __bad_area(struct pt_regs *regs, unsigned long address, int si_code,
+			int pkey)
 {
 	struct mm_struct *mm = current->mm;
 
@@ -137,12 +139,18 @@ static int __bad_area(struct pt_regs *regs, unsigned long address, int si_code)
 	 */
 	up_read(&mm->mmap_sem);
 
-	return __bad_area_nosemaphore(regs, address, si_code);
+	return __bad_area_nosemaphore(regs, address, si_code, pkey);
 }
 
 static noinline int bad_area(struct pt_regs *regs, unsigned long address)
 {
-	return __bad_area(regs, address, SEGV_MAPERR);
+	return __bad_area(regs, address, SEGV_MAPERR, 0);
+}
+
+static int bad_key_fault_exception(struct pt_regs *regs, unsigned long address,
+				    int pkey)
+{
+	return __bad_area_nosemaphore(regs, address, SEGV_PKUERR, pkey);
 }
 
 static int do_sigbus(struct pt_regs *regs, unsigned long address,
@@ -427,10 +435,9 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
 
-	if (error_code & DSISR_KEYFAULT) {
-		_exception(SIGSEGV, regs, SEGV_PKUERR, address);
-		return 0;
-	}
+	if (error_code & DSISR_KEYFAULT)
+		return bad_key_fault_exception(regs, address,
+					       get_mm_addr_key(mm, address));
 
 	/*
 	 * We want to do this outside mmap_sem, because reading code around nip
@@ -513,10 +520,18 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 	if (unlikely(fault & VM_FAULT_SIGSEGV) &&
 		!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
 			is_exec, 0)) {
+		/*
+		 * The PGD-PDT...PMD-PTE tree may not have been fully setup.
+		 * Hence we cannot walk the tree to locate the PTE, to locate
+		 * the key. Hence let's use vma_pkey() to get the key; instead
+		 * of get_mm_addr_key().
+		 */
 		int pkey = vma_pkey(vma);
 
-		if (likely(pkey))
-			return __bad_area(regs, address, SEGV_PKUERR);
+		if (likely(pkey)) {
+			up_read(&mm->mmap_sem);
+			return bad_key_fault_exception(regs, address, pkey);
+		}
 	}
 #endif /* CONFIG_PPC_MEM_KEYS */
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
