Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id F209B830BE
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 13:16:20 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g62so4588686ith.1
        for <linux-mm@kvack.org>; Fri, 26 Aug 2016 10:16:20 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50102.outbound.protection.outlook.com. [40.107.5.102])
        by mx.google.com with ESMTPS id w63si16418622otb.162.2016.08.26.10.15.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Aug 2016 10:15:58 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv3 5/6] x86/ptrace: down with test_thread_flag(TIF_IA32)
Date: Fri, 26 Aug 2016 20:13:16 +0300
Message-ID: <20160826171317.3944-6-dsafonov@virtuozzo.com>
In-Reply-To: <20160826171317.3944-1-dsafonov@virtuozzo.com>
References: <20160826171317.3944-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, luto@kernel.org, oleg@redhat.com, tglx@linutronix.de, hpa@zytor.com, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, gorcunov@openvz.org, xemul@virtuozzo.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Pedro Alves <palves@redhat.com>

As the task isn't executing at the moment of {GET,SET}REGS,
return regset that corresponds to code selector, rather than
value of TIF_IA32 flag.
I.e. if we ptrace i386 elf binary that has just changed it's
code selector to __USER_CS, than GET_REGS will return
full x86_64 register set.

Note, that this will work only if application has changed it's CS.
If the application does 32-bit syscall with __USER_CS, ptrace
will still return 64-bit register set. Which might be still confusing
for tools that expect TS_COMPACT to be exposed [1, 2].

So this this change should make PTRACE_GETREGSET more reliable and
this will be another step to drop TIF_{IA32,X32} flags.

[1]: https://sourceforge.net/p/strace/mailman/message/30471411/
[2]: https://lkml.org/lkml/2012/1/18/320

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Pedro Alves <palves@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/kernel/ptrace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
index f79576a541ff..ad0bab8fc594 100644
--- a/arch/x86/kernel/ptrace.c
+++ b/arch/x86/kernel/ptrace.c
@@ -1358,7 +1358,7 @@ void update_regset_xstate_info(unsigned int size, u64 xstate_mask)
 const struct user_regset_view *task_user_regset_view(struct task_struct *task)
 {
 #ifdef CONFIG_IA32_EMULATION
-	if (test_tsk_thread_flag(task, TIF_IA32))
+	if (!user_64bit_mode(task_pt_regs(task)))
 #endif
 #if defined CONFIG_X86_32 || defined CONFIG_IA32_EMULATION
 		return &user_x86_32_view;
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
