Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D4626B025E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:21:26 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id t5so204058920qkc.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 06:21:26 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0126.outbound.protection.outlook.com. [157.55.234.126])
        by mx.google.com with ESMTPS id v9si36449111qhb.70.2016.04.15.06.21.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 06:21:25 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv3 2/2] x86: rename is_{ia32,x32}_task to in_{ia32,x32}_syscall
Date: Fri, 15 Apr 2016 16:20:12 +0300
Message-ID: <1460726412-1724-2-git-send-email-dsafonov@virtuozzo.com>
In-Reply-To: <1460726412-1724-1-git-send-email-dsafonov@virtuozzo.com>
References: <1460388169-13340-1-git-send-email-dsafonov@virtuozzo.com>
 <1460726412-1724-1-git-send-email-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: luto@amacapital.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>

Impact: clearify meaning

Suggested-by: Andy Lutomirski <luto@amacapital.net>
Suggested-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
v3: initial patch

 arch/x86/entry/common.c            | 2 +-
 arch/x86/entry/vdso/vma.c          | 2 +-
 arch/x86/include/asm/compat.h      | 4 ++--
 arch/x86/include/asm/thread_info.h | 2 +-
 arch/x86/kernel/process_64.c       | 2 +-
 arch/x86/kernel/ptrace.c           | 2 +-
 arch/x86/kernel/signal.c           | 2 +-
 arch/x86/kernel/uprobes.c          | 2 +-
 8 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/arch/x86/entry/common.c b/arch/x86/entry/common.c
index e79d93d44ecd..ec138e538c44 100644
--- a/arch/x86/entry/common.c
+++ b/arch/x86/entry/common.c
@@ -191,7 +191,7 @@ long syscall_trace_enter_phase2(struct pt_regs *regs, u32 arch,
 
 long syscall_trace_enter(struct pt_regs *regs)
 {
-	u32 arch = is_ia32_task() ? AUDIT_ARCH_I386 : AUDIT_ARCH_X86_64;
+	u32 arch = in_ia32_syscall() ? AUDIT_ARCH_I386 : AUDIT_ARCH_X86_64;
 	unsigned long phase1_result = syscall_trace_enter_phase1(regs, arch);
 
 	if (phase1_result == 0)
diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 8510b1b55b21..0b861fc274b6 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -109,7 +109,7 @@ static int vdso_mremap(const struct vm_special_mapping *sm,
 	if (image->size != new_size)
 		return -EINVAL;
 
-	if (is_ia32_task()) {
+	if (in_ia32_syscall()) {
 		unsigned long vdso_land = vdso_image_32.sym_int80_landing_pad;
 		unsigned long old_land_addr = vdso_land +
 			(unsigned long)current->mm->context.vdso;
diff --git a/arch/x86/include/asm/compat.h b/arch/x86/include/asm/compat.h
index ebb102e1bbc7..5a3b2c119ed0 100644
--- a/arch/x86/include/asm/compat.h
+++ b/arch/x86/include/asm/compat.h
@@ -307,7 +307,7 @@ static inline void __user *arch_compat_alloc_user_space(long len)
 	return (void __user *)round_down(sp - len, 16);
 }
 
-static inline bool is_x32_task(void)
+static inline bool in_x32_syscall(void)
 {
 #ifdef CONFIG_X86_X32_ABI
 	if (task_pt_regs(current)->orig_ax & __X32_SYSCALL_BIT)
@@ -318,7 +318,7 @@ static inline bool is_x32_task(void)
 
 static inline bool in_compat_syscall(void)
 {
-	return is_ia32_task() || is_x32_task();
+	return in_ia32_syscall() || in_x32_syscall();
 }
 #define in_compat_syscall in_compat_syscall	/* override the generic impl */
 
diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index ffae84df8a93..30c133ac05cd 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -255,7 +255,7 @@ static inline bool test_and_clear_restore_sigmask(void)
 	return true;
 }
 
-static inline bool is_ia32_task(void)
+static inline bool in_ia32_syscall(void)
 {
 #ifdef CONFIG_X86_32
 	return true;
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index 6cbab31ac23a..4a62ec457b56 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -210,7 +210,7 @@ int copy_thread_tls(unsigned long clone_flags, unsigned long sp,
 	 */
 	if (clone_flags & CLONE_SETTLS) {
 #ifdef CONFIG_IA32_EMULATION
-		if (is_ia32_task())
+		if (in_ia32_syscall())
 			err = do_set_thread_area(p, -1,
 				(struct user_desc __user *)tls, 0);
 		else
diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
index 32e9d9cbb884..0f4d2a5df2dc 100644
--- a/arch/x86/kernel/ptrace.c
+++ b/arch/x86/kernel/ptrace.c
@@ -1266,7 +1266,7 @@ long compat_arch_ptrace(struct task_struct *child, compat_long_t request,
 			compat_ulong_t caddr, compat_ulong_t cdata)
 {
 #ifdef CONFIG_X86_X32_ABI
-	if (!is_ia32_task())
+	if (!in_ia32_syscall())
 		return x32_arch_ptrace(child, request, caddr, cdata);
 #endif
 #ifdef CONFIG_IA32_EMULATION
diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
index 548ddf7d6fd2..aa31265aa61d 100644
--- a/arch/x86/kernel/signal.c
+++ b/arch/x86/kernel/signal.c
@@ -762,7 +762,7 @@ handle_signal(struct ksignal *ksig, struct pt_regs *regs)
 static inline unsigned long get_nr_restart_syscall(const struct pt_regs *regs)
 {
 #ifdef CONFIG_X86_64
-	if (is_ia32_task())
+	if (in_ia32_syscall())
 		return __NR_ia32_restart_syscall;
 #endif
 #ifdef CONFIG_X86_X32_ABI
diff --git a/arch/x86/kernel/uprobes.c b/arch/x86/kernel/uprobes.c
index bf4db6eaec8f..98b4dc87628b 100644
--- a/arch/x86/kernel/uprobes.c
+++ b/arch/x86/kernel/uprobes.c
@@ -516,7 +516,7 @@ struct uprobe_xol_ops {
 
 static inline int sizeof_long(void)
 {
-	return is_ia32_task() ? 4 : 8;
+	return in_ia32_syscall() ? 4 : 8;
 }
 
 static int default_pre_xol_op(struct arch_uprobe *auprobe, struct pt_regs *regs)
-- 
2.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
