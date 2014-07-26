Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6BAB86B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 22:23:52 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so6648260pdb.3
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 19:23:52 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id su6si10911954pab.177.2014.07.25.19.23.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 25 Jul 2014 19:23:51 -0700 (PDT)
Message-ID: <53D31101.8000107@oracle.com>
Date: Fri, 25 Jul 2014 22:22:57 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: vmstat: On demand vmstat workers V8
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1407100903130.12483@gentwo.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>, akpm@linux-foundation.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

On 07/10/2014 10:04 AM, Christoph Lameter wrote:
> This patch creates a vmstat shepherd worker that monitors the
> per cpu differentials on all processors. If there are differentials
> on a processor then a vmstat worker local to the processors
> with the differentials is created. That worker will then start
> folding the diffs in regular intervals. Should the worker
> find that there is no work to be done then it will make the shepherd
> worker monitor the differentials again.

Hi Christoph, all,

This patch doesn't interact well with my fuzzing setup. I'm seeing
the following:

[  490.446927] BUG: using __this_cpu_read() in preemptible [00000000] code: kworker/16:1/7368
[  490.447909] caller is __this_cpu_preempt_check+0x13/0x20
[  490.448596] CPU: 8 PID: 7368 Comm: kworker/16:1 Not tainted 3.16.0-rc6-next-20140725-sasha-00047-g9eb9a52 #933
[  490.449847] Workqueue: events vmstat_update
[  490.450558]  ffffffff97383bb6 0000000000000000 ffffffff9727df83 ffff8803077cfb68
[  490.451520]  ffffffff95dc96b3 0000000000000008 ffff8803077cfba0 ffffffff92002438
[  490.452475]  ffff8803077cfc80 ffff880be21ea138 ffff8803077cfc80 00000000001e6a48
[  490.453459] Call Trace:
[  490.453776] dump_stack (lib/dump_stack.c:52)
[  490.454394] check_preemption_disabled (lib/smp_processor_id.c:46)
[  490.455161] __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  490.455927] refresh_cpu_vm_stats (mm/vmstat.c:492)
[  490.456753] vmstat_update (mm/vmstat.c:1252)
[  490.457463] process_one_work (kernel/workqueue.c:2022 include/linux/jump_label.h:115 include/trace/events/workqueue.h:111 kernel/workqueue.c:2027)
[  490.458159] ? process_one_work (include/linux/workqueue.h:185 kernel/workqueue.c:598 kernel/workqueue.c:625 kernel/workqueue.c:2015)
[  490.458887] worker_thread (include/linux/list.h:188 kernel/workqueue.c:2154)
[  490.459555] ? __schedule (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 include/linux/sched.h:2854 kernel/sched/core.c:2825)
[  490.460370] ? process_one_work (kernel/workqueue.c:2098)
[  490.461177] kthread (kernel/kthread.c:207)
[  490.461792] ? flush_kthread_work (kernel/kthread.c:176)
[  490.462529] ret_from_fork (arch/x86/kernel/entry_64.S:348)
[  490.463181] ? flush_kthread_work (kernel/kthread.c:176)
[  490.464008] ------------[ cut here ]------------
[  490.464613] kernel BUG at mm/vmstat.c:1278!
[  490.465116] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  490.465981] Dumping ftrace buffer:
[  490.466585]    (ftrace buffer empty)
[  490.467030] Modules linked in:
[  490.467429] CPU: 8 PID: 7368 Comm: kworker/16:1 Not tainted 3.16.0-rc6-next-20140725-sasha-00047-g9eb9a52 #933
[  490.468641] Workqueue: events vmstat_update
[  490.469163] task: ffff88030772b000 ti: ffff8803077cc000 task.ti: ffff8803077cc000
[  490.470033] RIP: vmstat_update (mm/vmstat.c:1278)
[  490.470269] RSP: 0000:ffff8803077cfcb8  EFLAGS: 00010287
[  490.470269] RAX: ffff87ffffffffff RBX: 0000000000000008 RCX: 0000000000000000
[  490.470269] RDX: ffff88030772bcf8 RSI: ffffffff972e5fd0 RDI: ffffffff986fa5d0
[  490.470269] RBP: ffff8803077cfcd0 R08: 0000000000000002 R09: 0000000000000000
[  490.470269] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8805fa7e34d0
[  490.470269] R13: ffff8803117e2240 R14: 0000000000000800 R15: 0000000000000000
[  490.470269] FS:  0000000000000000(0000) GS:ffff880311200000(0000) knlGS:0000000000000000
[  490.470269] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  490.470269] CR2: 00007fffc67fef1a CR3: 0000000017a22000 CR4: 00000000000006a0
[  490.470269] Stack:
[  490.470269]  ffff8803117dd240 ffff88030af938e0 ffff8803117e2240 ffff8803077cfd88
[  490.470269]  ffffffff911f45f5 ffffffff911f455d ffff88030af93928 ffff88031081e900
[  490.470269]  ffff88030af938f0 ffff88030af93900 ffff88030af938e8 ffff88030af938f8
[  490.470269] Call Trace:
[  490.470269] process_one_work (kernel/workqueue.c:2022 include/linux/jump_label.h:115 include/trace/events/workqueue.h:111 kernel/workqueue.c:2027)
[  490.470269] ? process_one_work (include/linux/workqueue.h:185 kernel/workqueue.c:598 kernel/workqueue.c:625 kernel/workqueue.c:2015)
[  490.470269] worker_thread (include/linux/list.h:188 kernel/workqueue.c:2154)
[  490.470269] ? __schedule (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 include/linux/sched.h:2854 kernel/sched/core.c:2825)
[  490.470269] ? process_one_work (kernel/workqueue.c:2098)
[  490.470269] kthread (kernel/kthread.c:207)
[  490.470269] ? flush_kthread_work (kernel/kthread.c:176)
[  490.470269] ret_from_fork (arch/x86/kernel/entry_64.S:348)
[  490.470269] ? flush_kthread_work (kernel/kthread.c:176)
[ 490.470269] Code: c7 d0 a5 6f 98 89 c3 e8 9f 9e 08 00 3b 1d 89 8b 35 07 73 7f f0 49 0f ab 1c 24 72 0f 5b 41 5c 41 5d 5d c3 0f 1f 84 00 00 00 00 00 <0f> 0b 66 0f 1f 44 00 00 48 63 3d f1 be 36 07 48 c7 c3 40 d2 1d
All code
========
   0:   c7                      (bad)
   1:   d0 a5 6f 98 89 c3       shlb   -0x3c766791(%rbp)
   7:   e8 9f 9e 08 00          callq  0x89eab
   c:   3b 1d 89 8b 35 07       cmp    0x7358b89(%rip),%ebx        # 0x7358b9b
  12:   73 7f                   jae    0x93
  14:   f0 49 0f ab 1c 24       lock bts %rbx,(%r12)
  1a:   72 0f                   jb     0x2b
  1c:   5b                      pop    %rbx
  1d:   41 5c                   pop    %r12
  1f:   41 5d                   pop    %r13
  21:   5d                      pop    %rbp
  22:   c3                      retq
  23:   0f 1f 84 00 00 00 00    nopl   0x0(%rax,%rax,1)
  2a:   00
  2b:*  0f 0b                   ud2             <-- trapping instruction
  2d:   66 0f 1f 44 00 00       nopw   0x0(%rax,%rax,1)
  33:   48 63 3d f1 be 36 07    movslq 0x736bef1(%rip),%rdi        # 0x736bf2b
  3a:   48 c7 c3 40 d2 1d 00    mov    $0x1dd240,%rbx

Code starting with the faulting instruction
===========================================
   0:   0f 0b                   ud2
   2:   66 0f 1f 44 00 00       nopw   0x0(%rax,%rax,1)
   8:   48 63 3d f1 be 36 07    movslq 0x736bef1(%rip),%rdi        # 0x736bf00
   f:   48 c7 c3 40 d2 1d 00    mov    $0x1dd240,%rbx
[  490.470269] RIP vmstat_update (mm/vmstat.c:1278)
[  490.470269]  RSP <ffff8803077cfcb8>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
