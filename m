From: Sasha Levin <sasha.levin@oracle.com>
Subject: mm,x86: page table corruption after adding reserve_memtype
Date: Sun, 06 Apr 2014 10:42:23 -0400
Message-ID: <534167CF.4060400@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>
List-Id: linux-mm.kvack.org

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel, I've stumbled on the following spew:

[ 1590.944125] reserve_memtype added [mem 0xffff8800000b0000-0xffff8800000b0fff], track uncached-minus, req uncached-minus, ret uncached-minus
[ 1593.391567] trinity-c184: Corrupted page table at address 7f16a347d000
[ 1593.391567] PGD 120e67067 PUD 104d2c067 PMD 9b71b067 PTE ffff8800000b0235
[ 1593.391567] Bad pagetable: 0009 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 1593.391567] Dumping ftrace buffer:
[ 1593.391567]    (ftrace buffer empty)
[ 1593.391567] Modules linked in:
[ 1593.391567] CPU: 8 PID: 8739 Comm: trinity-c184 Not tainted 3.14.0-next-20140403-sasha-00022-g10224c0 #377
[ 1593.391567] task: ffff8800cb8f3000 ti: ffff880113d90000 task.ti: ffff880113d90000
[ 1593.391567] RIP: copy_user_generic_unrolled (arch/x86/lib/copy_user_64.S:142)
[ 1593.391567] RSP: 0018:ffff880113d91e80  EFLAGS: 00010206
[ 1593.391567] RAX: ffff880113d90000 RBX: 00007f16a347d000 RCX: 0000000000000003
[ 1593.391567] RDX: 0000000000000010 RSI: 00007f16a347d000 RDI: ffff880113d91e88
[ 1593.391567] RBP: ffff880113d91f68 R08: 00000000000f5a5a R09: 0000000000000000
[ 1593.391567] R10: 0000000000000000 R11: 0000000000000001 R12: 000000000000009f
[ 1593.391567] R13: 000000000000009f R14: 00007f16a3444ae8 R15: 000000000000009f
[ 1593.391567] FS:  00007f16a346e700(0000) GS:ffff8801ef000000(0000) knlGS:0000000000000000
[ 1593.391567] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1593.391567] CR2: 00007f16a347d000 CR3: 0000000102ed6000 CR4: 00000000000006a0
[ 1593.391567] DR0: 0000000000696000 DR1: 0000000000696000 DR2: 0000000000000000
[ 1593.391567] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[ 1593.391567] Stack:
[ 1593.391567]  ffffffff8c15f5fa 00007f16a3444ae8 0000000000000082 ffffffff8c27a9c5
[ 1593.391567]  ffff8800cb8f3000 000000000000009f 00007f16a3444ae8 ffff880113d91ec8
[ 1593.391567]  ffffffff8cb2e853 ffff880113d91ee8 ffffffff8c1c16e4 0000000000000282
[ 1593.391567] Call Trace:
[ 1593.391567] ? SYSC_adjtimex (kernel/time.c:218)
[ 1593.391567] ? context_tracking_user_exit (arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:182 (discriminator 2))
[ 1593.391567] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 1593.391567] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2557 kernel/locking/lockdep.c:2599)
[ 1593.391567] ? trace_hardirqs_on (kernel/locking/lockdep.c:2607)
[ 1593.391567] ? syscall_trace_enter (include/linux/context_tracking.h:27 arch/x86/kernel/ptrace.c:1461)
[ 1593.391567] ? tracesys (arch/x86/kernel/entry_64.S:738)
[ 1593.391567] SyS_adjtimex (kernel/time.c:209)
[ 1593.391567] tracesys (arch/x86/kernel/entry_64.S:749)
[ 1593.391567] Code: 82 8c 00 00 00 89 f9 83 e1 07 74 15 83 e9 08 f7 d9 29 ca 8a 06 88 07 48 ff c6 48 ff c7 ff c9 75 f2 89 d1 83 e2 3f c1 e9 06 74 4a <4c> 8b 06 4c 8b 4e 08 4c 8b 56 10 4c 8b 5e 18 4c 89 07 4c 89 4f
[ 1593.391567] RIP copy_user_generic_unrolled (arch/x86/lib/copy_user_64.S:142)
[ 1593.391567]  RSP <ffff880113d91e80>


Thanks,
Sasha
