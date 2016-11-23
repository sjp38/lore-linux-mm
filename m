Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4416B028D
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 13:16:38 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id b202so33088681oii.3
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 10:16:38 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0092.outbound.protection.outlook.com. [104.47.2.92])
        by mx.google.com with ESMTPS id m92si15438128otm.2.2016.11.23.10.16.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 23 Nov 2016 10:16:37 -0800 (PST)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCH] x86/coredump: always use user_regs_struct for compat_elf_gregset_t
Date: Wed, 23 Nov 2016 21:13:30 +0300
Message-ID: <20161123181330.10705-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, linux-mm@kvack.org, x86@kernel.org

>From commit 90954e7b9407 ("x86/coredump: Use pr_reg size, rather that
TIF_IA32 flag") elf coredump file is constructed according to register
set size - and that's good: if binary crashes with 32-bit code selector,
generate 32-bit ELF core, otherwise - 64-bit core.
That was made for restoring 32-bit applications on x86_64: we want
32-bit application after restore to generate 32-bit ELF dump on crash.
All was quite good and recently I started reworking 32-bit applications
dumping part of CRIU: now it has two parasites (32 and 64) for seizing
compat/native tasks, after rework it'll have one parasite, working in
64-bit mode, to which 32-bit prologue long-jumps during infection.

And while it has worked for my work machine, in VM with
!CONFIG_X86_X32_ABI during reworking I faced that segfault in 32-bit
binary, that has long-jumped to 64-bit mode results in dereference
of garbage:

 32-victim[19266]: segfault at f775ef65 ip 00000000f775ef65 sp 00000000f776aa50 error 14
 BUG: unable to handle kernel paging request at ffffffffffffffff
 IP: [<ffffffff81332ce0>] strlen+0x0/0x20
 PGD 1e09067 PUD 1e0b067 PMD 0
 Oops: 0000 [#1] SMP
 Modules linked in:
 CPU: 3 PID: 19266 Comm: 32-victim Not tainted 4.9.0-rc6 #18
 task: ffff88013a183500 task.stack: ffffc90009ca4000
 RIP: 0010:[<ffffffff81332ce0>]  [<ffffffff81332ce0>] strlen+0x0/0x20
 RSP: 0000:ffffc90009ca7a40  EFLAGS: 00010286
 RAX: 0000000000000030 RBX: ffff88013789add0 RCX: 0000000000000804
 RDX: 0000000000000002 RSI: ffffc90009ca7cf8 RDI: ffffffffffffffff
 RBP: ffffc90009ca7a68 R08: 0000000000000000 R09: 0000000000000000
 R10: ffff88013fd9b058 R11: 0000000000000000 R12: ffffc90009ca7cf8
 R13: ffffc90009ca7b18 R14: 0000000000000000 R15: ffff88013a77df60
 FS:  0000000000000000(0000) GS:ffff88013fd80000(0063) knlGS:00000000f75a06c0
 CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
 CR2: ffffffffffffffff CR3: 0000000137be5000 CR4: 00000000001406e0
 DR0: 00000000f775f420 DR1: 0000000000000000 DR2: 0000000000000000
 DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
 Stack:
  ffffffff811d6929 00000005378deda8 0000000200000200 ffff88013789ad00
  ffffc90009ca7cf8 ffffc90009ca7c18 ffffffff811d9479 ffff88013a183500
  00000000000000bc 0000000200000010 ffffc90009ca7b48 ffffc90009ca7b30
 Call Trace:
  [<ffffffff811d6929>] ? writenote+0x19/0xa0
  [<ffffffff811d9479>] elf_core_dump+0x11a9/0x1480
  [<ffffffff811dc70b>] do_coredump+0xa6b/0xe60
  [<ffffffff81065820>] ? signal_wake_up_state+0x20/0x30
  [<ffffffff81065941>] ? complete_signal+0xf1/0x1f0
  [<ffffffff810679e8>] get_signal+0x1a8/0x5c0
  [<ffffffff8101b1a3>] do_signal+0x23/0x660
  [<ffffffff811268d3>] ? printk+0x48/0x4a
  [<ffffffff810a37ba>] ? vprintk_default+0x1a/0x20
  [<ffffffff81055375>] ? bad_area+0x41/0x48
  [<ffffffff8104b4b3>] ? __do_page_fault+0x3e3/0x490
  [<ffffffff81054296>] exit_to_usermode_loop+0x34/0x65
  [<ffffffff8100178f>] prepare_exit_to_usermode+0x2f/0x40
  [<ffffffff818f861b>] retint_user+0x8/0x10

That's because we have 64-bit registers set (with according total size)
and we're writing it to elf_thread_core_info which has smaller size
on !CONFIG_X86_X32_ABI. That lead to overwriting ELF notes part.

Tested on 32-, 64-bit ELF crashes and on 32-bit binaries that have
jumped with 64-bit code selector - all is readable with gdb.

Fixes: commit 90954e7b9407 ("x86/coredump: Use pr_reg size, rather that
TIF_IA32 flag")

Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/include/asm/compat.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/compat.h b/arch/x86/include/asm/compat.h
index 03d269bed941..24118c0b4640 100644
--- a/arch/x86/include/asm/compat.h
+++ b/arch/x86/include/asm/compat.h
@@ -272,7 +272,6 @@ struct compat_shmid64_ds {
 /*
  * The type of struct elf_prstatus.pr_reg in compatible core dumps.
  */
-#ifdef CONFIG_X86_X32_ABI
 typedef struct user_regs_struct compat_elf_gregset_t;
 
 /* Full regset -- prstatus on x32, otherwise on ia32 */
@@ -281,10 +280,9 @@ typedef struct user_regs_struct compat_elf_gregset_t;
   do { *(int *) (((void *) &((S)->pr_reg)) + R) = (V); } \
   while (0)
 
+#ifdef CONFIG_X86_X32_ABI
 #define COMPAT_USE_64BIT_TIME \
 	(!!(task_pt_regs(current)->orig_ax & __X32_SYSCALL_BIT))
-#else
-typedef struct user_regs_struct32 compat_elf_gregset_t;
 #endif
 
 /*
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
