Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id B0FF06B6A50
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 12:06:47 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id g3so4049601wmf.1
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 09:06:47 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id z124si6309561wmc.102.2018.12.03.09.06.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 09:06:46 -0800 (PST)
Message-Id: <b7a1ceeab24e088ef02b99037128bbe926267893.1543811917.git.christophe.leroy@c-s.fr>
In-Reply-To: <dd9ef91add7fcf5a9e369dde322b1822e90eb218.1543811917.git.christophe.leroy@c-s.fr>
References: <dd9ef91add7fcf5a9e369dde322b1822e90eb218.1543811917.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 2/2] powerpc: use probe_user_read() and probe_user_address()
Date: Mon,  3 Dec 2018 17:06:44 +0000 (UTC)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Instead of opencoding, use probe_user_read() and probe_user_address()
to failessly read a user location.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/process.c   | 12 +-----------
 arch/powerpc/mm/fault.c         |  6 +-----
 arch/powerpc/perf/callchain.c   | 20 +++-----------------
 arch/powerpc/perf/core-book3s.c |  8 +-------
 arch/powerpc/sysdev/fsl_pci.c   |  9 +++------
 5 files changed, 9 insertions(+), 46 deletions(-)

diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
index 96f34730010f..b77a2b4007e5 100644
--- a/arch/powerpc/kernel/process.c
+++ b/arch/powerpc/kernel/process.c
@@ -1298,16 +1298,6 @@ void show_user_instructions(struct pt_regs *regs)
 
 	pc = regs->nip - (NR_INSN_TO_PRINT * 3 / 4 * sizeof(int));
 
-	/*
-	 * Make sure the NIP points at userspace, not kernel text/data or
-	 * elsewhere.
-	 */
-	if (!__access_ok(pc, NR_INSN_TO_PRINT * sizeof(int), USER_DS)) {
-		pr_info("%s[%d]: Bad NIP, not dumping instructions.\n",
-			current->comm, current->pid);
-		return;
-	}
-
 	seq_buf_init(&s, buf, sizeof(buf));
 
 	while (n) {
@@ -1318,7 +1308,7 @@ void show_user_instructions(struct pt_regs *regs)
 		for (i = 0; i < 8 && n; i++, n--, pc += sizeof(int)) {
 			int instr;
 
-			if (probe_kernel_address((const void *)pc, instr)) {
+			if (probe_user_address((const void *)pc, instr)) {
 				seq_buf_printf(&s, "XXXXXXXX ");
 				continue;
 			}
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 1697e903bbf2..a87a2d2e7a8b 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -274,12 +274,8 @@ static bool bad_stack_expansion(struct pt_regs *regs, unsigned long address,
 		if ((flags & FAULT_FLAG_WRITE) && (flags & FAULT_FLAG_USER) &&
 		    access_ok(VERIFY_READ, nip, sizeof(*nip))) {
 			unsigned int inst;
-			int res;
 
-			pagefault_disable();
-			res = __get_user_inatomic(inst, nip);
-			pagefault_enable();
-			if (!res)
+			if (!probe_user_address(nip, inst))
 				return !store_updates_sp(inst);
 			*must_retry = true;
 		}
diff --git a/arch/powerpc/perf/callchain.c b/arch/powerpc/perf/callchain.c
index 0af051a1974e..efe518c4e8c7 100644
--- a/arch/powerpc/perf/callchain.c
+++ b/arch/powerpc/perf/callchain.c
@@ -159,12 +159,8 @@ static int read_user_stack_64(unsigned long __user *ptr, unsigned long *ret)
 	    ((unsigned long)ptr & 7))
 		return -EFAULT;
 
-	pagefault_disable();
-	if (!__get_user_inatomic(*ret, ptr)) {
-		pagefault_enable();
+	if (!probe_user_address(ptr, *ret))
 		return 0;
-	}
-	pagefault_enable();
 
 	return read_user_stack_slow(ptr, ret, 8);
 }
@@ -175,12 +171,8 @@ static int read_user_stack_32(unsigned int __user *ptr, unsigned int *ret)
 	    ((unsigned long)ptr & 3))
 		return -EFAULT;
 
-	pagefault_disable();
-	if (!__get_user_inatomic(*ret, ptr)) {
-		pagefault_enable();
+	if (!probe_user_address(ptr, *ret))
 		return 0;
-	}
-	pagefault_enable();
 
 	return read_user_stack_slow(ptr, ret, 4);
 }
@@ -307,17 +299,11 @@ static inline int current_is_64bit(void)
  */
 static int read_user_stack_32(unsigned int __user *ptr, unsigned int *ret)
 {
-	int rc;
-
 	if ((unsigned long)ptr > TASK_SIZE - sizeof(unsigned int) ||
 	    ((unsigned long)ptr & 3))
 		return -EFAULT;
 
-	pagefault_disable();
-	rc = __get_user_inatomic(*ret, ptr);
-	pagefault_enable();
-
-	return rc;
+	return probe_user_address(ptr, *ret);
 }
 
 static inline void perf_callchain_user_64(struct perf_callchain_entry_ctx *entry,
diff --git a/arch/powerpc/perf/core-book3s.c b/arch/powerpc/perf/core-book3s.c
index 81f8a0c838ae..25b28aa499b9 100644
--- a/arch/powerpc/perf/core-book3s.c
+++ b/arch/powerpc/perf/core-book3s.c
@@ -407,7 +407,6 @@ static void power_pmu_sched_task(struct perf_event_context *ctx, bool sched_in)
 static __u64 power_pmu_bhrb_to(u64 addr)
 {
 	unsigned int instr;
-	int ret;
 	__u64 target;
 
 	if (is_kernel_addr(addr)) {
@@ -418,13 +417,8 @@ static __u64 power_pmu_bhrb_to(u64 addr)
 	}
 
 	/* Userspace: need copy instruction here then translate it */
-	pagefault_disable();
-	ret = __get_user_inatomic(instr, (unsigned int __user *)addr);
-	if (ret) {
-		pagefault_enable();
+	if (probe_user_address((unsigned int __user *)addr, instr))
 		return 0;
-	}
-	pagefault_enable();
 
 	target = branch_target(&instr);
 	if ((!target) || (instr & BRANCH_ABSOLUTE))
diff --git a/arch/powerpc/sysdev/fsl_pci.c b/arch/powerpc/sysdev/fsl_pci.c
index 918be816b097..b8e2349910b7 100644
--- a/arch/powerpc/sysdev/fsl_pci.c
+++ b/arch/powerpc/sysdev/fsl_pci.c
@@ -1068,13 +1068,10 @@ int fsl_pci_mcheck_exception(struct pt_regs *regs)
 	addr += mfspr(SPRN_MCAR);
 
 	if (is_in_pci_mem_space(addr)) {
-		if (user_mode(regs)) {
-			pagefault_disable();
-			ret = get_user(inst, (__u32 __user *)regs->nip);
-			pagefault_enable();
-		} else {
+		if (user_mode(regs))
+			ret = probe_user_address((void *)regs->nip, inst);
+		else
 			ret = probe_kernel_address((void *)regs->nip, inst);
-		}
 
 		if (!ret && mcheck_handle_load(regs, inst)) {
 			regs->nip += 4;
-- 
2.13.3
