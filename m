Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 26F516B0264
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 06:59:06 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id at7so95967382obd.1
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 03:59:06 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0116.outbound.protection.outlook.com. [104.47.0.116])
        by mx.google.com with ESMTPS id r135si2539241oie.6.2016.06.29.03.59.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 29 Jun 2016 03:59:05 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv2 5/6] x86/ptrace: down with test_thread_flag(TIF_IA32)
Date: Wed, 29 Jun 2016 13:57:35 +0300
Message-ID: <20160629105736.15017-6-dsafonov@virtuozzo.com>
In-Reply-To: <20160629105736.15017-1-dsafonov@virtuozzo.com>
References: <20160629105736.15017-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, linux-mm@kvack.org, mingo@redhat.com, luto@amacapital.net, gorcunov@openvz.org, xemul@virtuozzo.com, oleg@redhat.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, x86@kernel.org

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

Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>
Cc: x86@kernel.org
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/kernel/ptrace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
index 600edd225e81..a2612d06cf4b 100644
--- a/arch/x86/kernel/ptrace.c
+++ b/arch/x86/kernel/ptrace.c
@@ -1355,7 +1355,7 @@ void update_regset_xstate_info(unsigned int size, u64 xstate_mask)
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
