Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 432566B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 08:26:35 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q189so9346051pgq.17
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 05:26:35 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00105.outbound.protection.outlook.com. [40.107.0.105])
        by mx.google.com with ESMTPS id l91si7355018plb.85.2017.03.29.05.26.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 05:26:34 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv4] x86/mm: make in_compat_syscall() work during exec
Date: Wed, 29 Mar 2017 15:22:48 +0300
Message-ID: <20170329122249.22570-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Adam Borowski <kilobyte@angband.pl>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Andrei Vagin <avagin@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>

After my changes to mmap(), its code now relies on the bitness of
performing syscall. According to that, it chooses the base of allocation:
mmap_base for 64-bit mmap() and mmap_compat_base for 32-bit syscall.
It was done by:
  commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for
32-bit mmap()").

The code afterwards relies on in_compat_syscall() returning true for
32-bit syscalls. It's usually so while we're in context of application
that does 32-bit syscalls. But during exec() it is not valid for x32 ELF.
The reason is that the application hasn't yet done any syscall, so x32
bit has not being set.

But do_execve() calls load_elf_binary(), which adds mappings with
elf_map(). That results in -ENOMEM for x32 ELF binaries as
in_compat_syscall() says we're in 64-bit syscall and so mmap_base
is used instead of mmap_compat_base.
For i386 ELFs it works as SET_PERSONALITY() sets TS_COMPAT flag.

As suggested by HPA and with diff by Thomas, make SET_PERSONALITY()
change original syscall number to appropriate execve() number to
pretend that we've come from the same bitness syscall as loading binary.

Fixes: commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for
32-bit mmap()")
Cc: 0x7f454c46@gmail.com
Cc: linux-mm@kvack.org
Cc: Andrei Vagin <avagin@gmail.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Borislav Petkov <bp@suse.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: x86@kernel.org
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Reported-by: Adam Borowski <kilobyte@angband.pl>
Suggested-by: H. Peter Anvin <hpa@zytor.com>
Suggested-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/kernel/process_64.c | 67 ++++++++++++++++++++++++++++++--------------
 1 file changed, 46 insertions(+), 21 deletions(-)

diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index ea1a6180bf39..4af8ef0b0a08 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -486,6 +486,10 @@ __switch_to(struct task_struct *prev_p, struct task_struct *next_p)
 	return prev_p;
 }
 
+#define __NR_execve		59
+#define __NR_x32_execve		520
+#define __NR_ia32_execve	11
+
 void set_personality_64bit(void)
 {
 	/* inherit personality from parent */
@@ -494,6 +498,8 @@ void set_personality_64bit(void)
 	clear_thread_flag(TIF_IA32);
 	clear_thread_flag(TIF_ADDR32);
 	clear_thread_flag(TIF_X32);
+	/* Pretend that this comes from a 64bit execve */
+	task_pt_regs(current)->orig_ax = __NR_execve;
 
 	/* Ensure the corresponding mm is not marked. */
 	if (current->mm)
@@ -506,32 +512,51 @@ void set_personality_64bit(void)
 	current->personality &= ~READ_IMPLIES_EXEC;
 }
 
-void set_personality_ia32(bool x32)
+static void __set_personality_x32(void)
 {
-	/* inherit personality from parent */
+#ifdef CONFIG_X86_X32
+	clear_thread_flag(TIF_IA32);
+	set_thread_flag(TIF_X32);
+	if (current->mm)
+		current->mm->context.ia32_compat = TIF_X32;
+	current->personality &= ~READ_IMPLIES_EXEC;
+	/*
+	 * in_compat_syscall() uses the presence of the x32
+	 * syscall bit flag to determine compat status.
+	 * The x86 mmap() code relies on the syscall bitness
+	 * so set x32 syscall bit right here to make
+	 * in_compat_syscall() work during exec().
+	 *
+	 * Pretend to come from a x32 execve.
+	 */
+	task_pt_regs(current)->orig_ax = __NR_x32_execve | __X32_SYSCALL_BIT;
+	current->thread.status &= ~TS_COMPAT;
+#endif
+}
 
+static void __set_personality_ia32(void)
+{
+#ifdef CONFIG_IA32_EMULATION
+	set_thread_flag(TIF_IA32);
+	clear_thread_flag(TIF_X32);
+	if (current->mm)
+		current->mm->context.ia32_compat = TIF_IA32;
+	current->personality |= force_personality32;
+	/* Prepare the first "return" to user space */
+	task_pt_regs(current)->orig_ax = __NR_ia32_execve;
+	current->thread.status |= TS_COMPAT;
+#endif
+}
+
+void set_personality_ia32(bool x32)
+{
 	/* Make sure to be in 32bit mode */
 	set_thread_flag(TIF_ADDR32);
 
-	/* Mark the associated mm as containing 32-bit tasks. */
-	if (x32) {
-		clear_thread_flag(TIF_IA32);
-		set_thread_flag(TIF_X32);
-		if (current->mm)
-			current->mm->context.ia32_compat = TIF_X32;
-		current->personality &= ~READ_IMPLIES_EXEC;
-		/* in_compat_syscall() uses the presence of the x32
-		   syscall bit flag to determine compat status */
-		current->thread.status &= ~TS_COMPAT;
-	} else {
-		set_thread_flag(TIF_IA32);
-		clear_thread_flag(TIF_X32);
-		if (current->mm)
-			current->mm->context.ia32_compat = TIF_IA32;
-		current->personality |= force_personality32;
-		/* Prepare the first "return" to user space */
-		current->thread.status |= TS_COMPAT;
-	}
+	if (x32)
+		__set_personality_x32();
+	else
+		__set_personality_ia32();
 }
 EXPORT_SYMBOL_GPL(set_personality_ia32);
 
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
