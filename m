Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id F1FFA6B025E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 12:50:48 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id l5so54692797ioa.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 09:50:48 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a5si13767764itd.72.2016.06.15.09.50.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 09:50:47 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: kernel, mm: NULL deref in copy_process while OOMing
Message-ID: <57618763.5010201@oracle.com>
Date: Wed, 15 Jun 2016 12:50:43 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

Hi all,

I'm seeing the following NULL ptr deref in copy_process right after a bunch
of OOM killing activity on -next kernels:

Out of memory (oom_kill_allocating_task): Kill process 3477 (trinity-c159) score 0 or sacrifice child
Killed process 3477 (trinity-c159) total-vm:3226820kB, anon-rss:36832kB, file-rss:1640kB, shmem-rss:444kB
oom_reaper: reaped process 3477 (trinity-c159), now anon-rss:0kB, file-rss:0kB, shmem-rss:444kB
Out of memory (oom_kill_allocating_task): Kill process 3450 (trinity-c156) score 0 or sacrifice child
Killed process 3450 (trinity-c156) total-vm:3769768kB, anon-rss:36832kB, file-rss:1652kB, shmem-rss:508kB
oom_reaper: reaped process 3450 (trinity-c156), now anon-rss:0kB, file-rss:0kB, shmem-rss:572kB
BUG: unable to handle kernel NULL pointer dereference at 0000000000000150
IP: copy_process (./arch/x86/include/asm/atomic.h:103 kernel/fork.c:484 kernel/fork.c:964 kernel/fork.c:1018 kernel/fork.c:1484)
PGD 1ff944067 PUD 1ff929067 PMD 0
Oops: 0002 [#1] PREEMPT SMP KASAN
Modules linked in:
CPU: 18 PID: 8761 Comm: trinity-main Not tainted 4.7.0-rc3-sasha-02101-g1e1b9fa #3108
task: ffff880165564000 ti: ffff880337ad0000 task.ti: ffff880337ad0000
RIP: copy_process (./arch/x86/include/asm/atomic.h:103 kernel/fork.c:484 kernel/fork.c:964 kernel/fork.c:1018 kernel/fork.c:1484)
RSP: 0018:ffff880337ad7bb0  EFLAGS: 00010282
RAX: 0000000000000000 RBX: ffff880314fbbe00 RCX: dffffc0000000000
RDX: 1ffff10013393b9f RSI: ffff88029ba79d40 RDI: ffff880099c9dcf8
RBP: ffff880337ad7dc8 R08: ffffffffaca1a600 R09: 0000000000000000
R10: ffffed00629f77d8 R11: 0000000000000000 R12: ffff88016c013000
R13: ffff88029ba79d40 R14: ffff880314fbbe50 R15: ffff880099c9dc00
FS:  00007f37feaa5700(0000) GS:ffff880203700000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000150 CR3: 00000001ff565000 CR4: 00000000000006a0
Stack:
0000000001200011 ffffed002d80260c ffff88016c013060 0000000000000000
ffff880314fba7a0 ffff880314fba7a8 ffff88016bd32810 ffff880314fba780
ffff88009aca7410 ffff880314fbbe10 ffff88016c013068 ffff880201efd068
Call Trace:
_do_fork (kernel/fork.c:1768)
SyS_clone (kernel/fork.c:1865)
do_syscall_64 (arch/x86/entry/common.c:350)
entry_SYSCALL64_slow_path (arch/x86/entry/entry_64.S:251)
Code: 00 00 00 fc ff df 4c 89 f0 48 c1 e8 03 80 3c 08 00 74 08 4c 89 f7 e8 c7 8c 41 00 f6 43 51 08 74 11 e8 bc 12 24 00 48 8b 44 24 18 <f0> ff 88 50 01 00 00 e8 ab 12 24 00 48 8b 44 24 40 48 83 c0 28
All code
========
   0:   00 00                   add    %al,(%rax)
   2:   00 fc                   add    %bh,%ah
   4:   ff df                   lcallq *<internal disassembler error>
   6:   4c 89 f0                mov    %r14,%rax
   9:   48 c1 e8 03             shr    $0x3,%rax
   d:   80 3c 08 00             cmpb   $0x0,(%rax,%rcx,1)
  11:   74 08                   je     0x1b
  13:   4c 89 f7                mov    %r14,%rdi
  16:   e8 c7 8c 41 00          callq  0x418ce2
  1b:   f6 43 51 08             testb  $0x8,0x51(%rbx)
  1f:   74 11                   je     0x32
  21:   e8 bc 12 24 00          callq  0x2412e2
  26:   48 8b 44 24 18          mov    0x18(%rsp),%rax
  2b:*  f0 ff 88 50 01 00 00    lock decl 0x150(%rax)           <-- trapping instruction
  32:   e8 ab 12 24 00          callq  0x2412e2
  37:   48 8b 44 24 40          mov    0x40(%rsp),%rax
  3c:   48 83 c0 28             add    $0x28,%rax
        ...

Code starting with the faulting instruction
===========================================
   0:   f0 ff 88 50 01 00 00    lock decl 0x150(%rax)
   7:   e8 ab 12 24 00          callq  0x2412b7
   c:   48 8b 44 24 40          mov    0x40(%rsp),%rax
  11:   48 83 c0 28             add    $0x28,%rax
        ...
RIP copy_process (./arch/x86/include/asm/atomic.h:103 kernel/fork.c:484 kernel/fork.c:964 kernel/fork.c:1018 kernel/fork.c:1484)
RSP <ffff880337ad7bb0>
CR2: 0000000000000150


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
