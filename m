Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C98A18E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 02:37:49 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id t2so1223396edb.22
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 23:37:49 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id 18-v6si737763ejo.149.2019.01.07.23.37.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 23:37:48 -0800 (PST)
Message-Id: <e939991366b784ef13c7afcab51749e3b46327ac.1546932949.git.christophe.leroy@c-s.fr>
In-Reply-To: <0b0db24e18063076e9d9f4e376994af83da05456.1546932949.git.christophe.leroy@c-s.fr>
References: <0b0db24e18063076e9d9f4e376994af83da05456.1546932949.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v2 2/2] powerpc: use probe_user_read()
Date: Tue,  8 Jan 2019 07:37:47 +0000 (UTC)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Instead of opencoding, use probe_user_read() to failessly
read a user location.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 v2: Using probe_user_read() instead of probe_user_address()

 arch/powerpc/kernel/process.c   | 12 +-----------
 arch/powerpc/mm/fault.c         |  6 +-----
 arch/powerpc/perf/callchain.c   | 20 +++-----------------
 arch/powerpc/perf/core-book3s.c |  8 +-------
 arch/powerpc/sysdev/fsl_pci.c   | 10 ++++------
 5 files changed, 10 insertions(+), 46 deletions(-)

diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
index ce393df243aa..6a4b59d574c2 100644
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
+			if (probe_user_read(&instr, (void __user *)pc, sizeof(instr))) {
 				seq_buf_printf(&s, "XXXXXXXX ");
 				continue;
 			}
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 887f11bcf330..ec74305fa330 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -276,12 +276,8 @@ static bool bad_stack_expansion(struct pt_regs *regs, unsigned long address,
 		if ((flags & FAULT_FLAG_WRITE) && (flags & FAULT_FLAG_USER) &&
 		    access_ok(nip, sizeof(*nip))) {
 			unsigned int inst;
-			int res;
 
-			pagefault_disable();
-			res = __get_user_inatomic(inst, nip);
-			pagefault_enable();
-			if (!res)
+			if (!probe_user_read(&inst, nip, sizeof(inst)))
 				return !store_updates_sp(inst);
 			*must_retry = true;
 		}
diff --git a/arch/powerpc/perf/callchain.c b/arch/powerpc/perf/callchain.c
index 0af051a1974e..0680efb2237b 100644
--- a/arch/powerpc/perf/callchain.c
+++ b/arch/powerpc/perf/callchain.c
@@ -159,12 +159,8 @@ static int read_user_stack_64(unsigned long __user *ptr, unsigned long *ret)
 	    ((unsigned long)ptr & 7))
 		return -EFAULT;
 
-	pagefault_disable();
-	if (!__get_user_inatomic(*ret, ptr)) {
-		pagefault_enable();
+	if (!probe_user_read(ret, ptr, sizeof(*ret)))
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
+	if (!probe_user_read(ret, ptr, sizeof(*ret)))
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
+	return probe_user_read(ret, ptr, sizeof(*ret));
 }
 
 static inline void perf_callchain_user_64(struct perf_callchain_entry_ctx *entry,
diff --git a/arch/powerpc/perf/core-book3s.c b/arch/powerpc/perf/core-book3s.c
index b0723002a396..4b64ddf0db68 100644
--- a/arch/powerpc/perf/core-book3s.c
+++ b/arch/powerpc/perf/core-book3s.c
@@ -416,7 +416,6 @@ static void power_pmu_sched_task(struct perf_event_context *ctx, bool sched_in)
 static __u64 power_pmu_bhrb_to(u64 addr)
 {
 	unsigned int instr;
-	int ret;
 	__u64 target;
 
 	if (is_kernel_addr(addr)) {
@@ -427,13 +426,8 @@ static __u64 power_pmu_bhrb_to(u64 addr)
 	}
 
 	/* Userspace: need copy instruction here then translate it */
-	pagefault_disable();
-	ret = __get_user_inatomic(instr, (unsigned int __user *)addr);
-	if (ret) {
-		pagefault_enable();
+	if (probe_user_read(&instr, (unsigned int __user *)addr, sizeof(instr)))
 		return 0;
-	}
-	pagefault_enable();
 
 	target = branch_target(&instr);
 	if ((!target) || (instr & BRANCH_ABSOLUTE))
diff --git a/arch/powerpc/sysdev/fsl_pci.c b/arch/powerpc/sysdev/fsl_pci.c
index 918be816b097..c8a1b26489f5 100644
--- a/arch/powerpc/sysdev/fsl_pci.c
+++ b/arch/powerpc/sysdev/fsl_pci.c
@@ -1068,13 +1068,11 @@ int fsl_pci_mcheck_exception(struct pt_regs *regs)
 	addr += mfspr(SPRN_MCAR);
 
 	if (is_in_pci_mem_space(addr)) {
-		if (user_mode(regs)) {
-			pagefault_disable();
-			ret = get_user(inst, (__u32 __user *)regs->nip);
-			pagefault_enable();
-		} else {
+		if (user_mode(regs))
+			ret = probe_user_read(&inst, (void __user *)regs->nip,
+					      sizeof(inst));
+		else
 			ret = probe_kernel_address((void *)regs->nip, inst);
-		}
 
 		if (!ret && mcheck_handle_load(regs, inst)) {
 			regs->nip += 4;
-- 
2.13.3
