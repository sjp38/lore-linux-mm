Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CEC6C6B007D
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 00:50:58 -0500 (EST)
From: "H. Peter Anvin" <hpa@zytor.com>
Subject: [PATCH 2/2] x86: get rid of the insane TIF_ABI_PENDING bit
Date: Thu, 28 Jan 2010 21:41:34 -0800
Message-Id: <1264743694-4586-2-git-send-email-hpa@zytor.com>
In-Reply-To: <1264743694-4586-1-git-send-email-hpa@zytor.com>
References: <4B627236.1040508@zytor.com>
 <1264743694-4586-1-git-send-email-hpa@zytor.com>
Sender: owner-linux-mm@kvack.org
To: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org, security@kernel.org, tony.luck@intel.com, jmorris@namei.org, mikew@google.com, md@google.com, linux-mm@kvack.org, mingo@redhat.com, tglx@linutronix.de, minipli@googlemail.com, roland@redhat.com, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

Now that the previous commit made it possible to do the personality
setting at the point of no return, we do just that for ELF binaries.
And suddenly all the reasons for that insane TIF_ABI_PENDING bit go
away, and we can just make SET_PERSONALITY() just do the obvious thing
for a 32-bit compat process.

Everything becomes much more straightforward this way.

Signed-off-by: H. Peter Anvin <hpa@zytor.com>
---
 arch/x86/ia32/ia32_aout.c          |    1 -
 arch/x86/include/asm/elf.h         |   10 ++--------
 arch/x86/include/asm/thread_info.h |    2 --
 arch/x86/kernel/process.c          |   12 +++---------
 arch/x86/kernel/process_64.c       |   11 +++++++++++
 5 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/arch/x86/ia32/ia32_aout.c b/arch/x86/ia32/ia32_aout.c
index 435d2a5..f9f4724 100644
--- a/arch/x86/ia32/ia32_aout.c
+++ b/arch/x86/ia32/ia32_aout.c
@@ -311,7 +311,6 @@ static int load_aout_binary(struct linux_binprm *bprm, struct pt_regs *regs)
 	/* OK, This is the point of no return */
 	set_personality(PER_LINUX);
 	set_thread_flag(TIF_IA32);
-	clear_thread_flag(TIF_ABI_PENDING);
 
 	setup_new_exec(bprm);
 
diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index b4501ee..1994d3f 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -181,14 +181,8 @@ do {							\
 void start_thread_ia32(struct pt_regs *regs, u32 new_ip, u32 new_sp);
 #define compat_start_thread start_thread_ia32
 
-#define COMPAT_SET_PERSONALITY(ex)			\
-do {							\
-	if (test_thread_flag(TIF_IA32))			\
-		clear_thread_flag(TIF_ABI_PENDING);	\
-	else						\
-		set_thread_flag(TIF_ABI_PENDING);	\
-	current->personality |= force_personality32;	\
-} while (0)
+void set_personality_ia32(void);
+#define COMPAT_SET_PERSONALITY(ex) set_personality_ia32()
 
 #define COMPAT_ELF_PLATFORM			("i686")
 
diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index 375c917..e0d2890 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -87,7 +87,6 @@ struct thread_info {
 #define TIF_NOTSC		16	/* TSC is not accessible in userland */
 #define TIF_IA32		17	/* 32bit process */
 #define TIF_FORK		18	/* ret_from_fork */
-#define TIF_ABI_PENDING		19
 #define TIF_MEMDIE		20
 #define TIF_DEBUG		21	/* uses debug registers */
 #define TIF_IO_BITMAP		22	/* uses I/O bitmap */
@@ -112,7 +111,6 @@ struct thread_info {
 #define _TIF_NOTSC		(1 << TIF_NOTSC)
 #define _TIF_IA32		(1 << TIF_IA32)
 #define _TIF_FORK		(1 << TIF_FORK)
-#define _TIF_ABI_PENDING	(1 << TIF_ABI_PENDING)
 #define _TIF_DEBUG		(1 << TIF_DEBUG)
 #define _TIF_IO_BITMAP		(1 << TIF_IO_BITMAP)
 #define _TIF_FREEZE		(1 << TIF_FREEZE)
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 02c3ee0..7d42304 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -116,15 +116,9 @@ void flush_thread(void)
 	struct task_struct *tsk = current;
 
 #ifdef CONFIG_X86_64
-	if (test_tsk_thread_flag(tsk, TIF_ABI_PENDING)) {
-		clear_tsk_thread_flag(tsk, TIF_ABI_PENDING);
-		if (test_tsk_thread_flag(tsk, TIF_IA32)) {
-			clear_tsk_thread_flag(tsk, TIF_IA32);
-		} else {
-			set_tsk_thread_flag(tsk, TIF_IA32);
-			current_thread_info()->status |= TS_COMPAT;
-		}
-	}
+	/* Set up the first "return" to user space */
+	if (test_tsk_thread_flag(tsk, TIF_IA32))
+		current_thread_info()->status |= TS_COMPAT;
 #endif
 
 	flush_ptrace_hw_breakpoint(tsk);
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index f9e0331..41a26a8 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -521,6 +521,17 @@ void set_personality_64bit(void)
 	current->personality &= ~READ_IMPLIES_EXEC;
 }
 
+void set_personality_ia32(void)
+{
+	/* inherit personality from parent */
+
+	/* Make sure to be in 32bit mode */
+	set_thread_flag(TIF_IA32);
+
+	/* Prepare the first "return" to user space */
+	current_thread_info()->status |= TS_COMPAT;
+}
+
 unsigned long get_wchan(struct task_struct *p)
 {
 	unsigned long stack;
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
