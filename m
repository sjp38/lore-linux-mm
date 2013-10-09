Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8D59F6B003B
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 11:54:45 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so1086590pbc.2
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 08:54:45 -0700 (PDT)
Received: by mail-vb0-f46.google.com with SMTP id p13so633312vbe.5
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 08:54:42 -0700 (PDT)
MIME-Version: 1.0
From: William Dauchy <wdauchy@gmail.com>
Date: Wed, 9 Oct 2013 17:54:20 +0200
Message-ID: <CAJ75kXYqNfWejMhykEqmby4Yvs1w+Tv+QxKHZF67j77HJnco5A@mail.gmail.com>
Subject: strange oom behaviour on 3.10
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org
Cc: linux-mm@kvack.org

Hi,

I have been through a strange issue with cgroups on v3.10.x.
The oom is triggered for a cgroups wich has reached the memory limit.
I'm getting several:

Task in /lxc/VM_A killed as a result of limit of /lxc/VM_A
memory: usage 262144kB, limit 262144kB, failcnt 44742

which is quite normal.
The last one is:
Task in / killed as a result of limit of /lxc/VM_A
memory: usage 128420kB, limit 262144kB, failcnt 44749

Why do I have a oom kill is this case since the memory usage is ok?
Why is it choosing a task in / instead of in /lxc/VM_A?

Details of last trace is:


CPU: 28 PID: 22783 Comm: mysqld Not tainted 3.10 #1
Hardware name: Dell Inc. PowerEdge C8220/0TDN55, BIOS 1.1.17 01/09/2013
ffffffff815160a7 0000000000000000 ffffffff815136fc 0000000000000000
0000000100000010 0000000000000000 ffff88207fffbd80 0000000100000000
0000000000000000 0000000000000001 ffffffff810b7718 0000000000000001
Call Trace:
[<ffffffff815160a7>] ? dump_stack+0xd/0x17
[<ffffffff815136fc>] ? dump_header+0x78/0x21a
[<ffffffff810b7718>] ? find_lock_task_mm+0x28/0x80
[<ffffffff81103c8b>] ? mem_cgroup_same_or_subtree+0x2b/0x50
[<ffffffff810b7bd0>] ? oom_kill_process+0x270/0x400
[<ffffffff8104a6ec>] ? has_ns_capability_noaudit+0x4c/0x70
[<ffffffff81104f91>] ? __mem_cgroup_try_charge+0x9e1/0xa10
[<ffffffff810f00df>] ? alloc_pages_vma+0xaf/0x1d0
[<ffffffff8110560b>] ? mem_cgroup_charge_common+0x4b/0xa0
[<ffffffff810d7cd4>] ? handle_pte_fault+0x6f4/0x990
[<ffffffff810d92c5>] ? handle_mm_fault+0x355/0x710
[<ffffffff8151212a>] ? mm_fault_error+0xd4/0x1e8
[<ffffffff81028b0e>] ? __do_page_fault+0x17e/0x570
[<ffffffff811f7acb>] ? blk_finish_plug+0xb/0x40
[<ffffffff810d3b7e>] ? SyS_madvise+0x2ae/0x860
[<ffffffff8110b308>] ? SyS_faccessat+0x208/0x230
[<ffffffff8151abe8>] ? page_fault+0x38/0x40
Task in / killed as a result of limit of /lxc/VM_A
memory: usage 128420kB, limit 262144kB, failcnt 44749
memory+swap: usage 128420kB, limit 524288kB, failcnt 0
kmem: usage 0kB, limit 9007199254740991kB, failcnt 0
Memory cgroup stats for /lxc/VM_A: cache:65588KB rss:66752KB
rss_huge:12288KB mapped_file:256KB swap:0KB inactive_anon:4372KB
active_anon:127900KB inactive_file:8KB active_file:0KB unevictable:0KB
[ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[ 1418]     0  1418     4441      427      14        0             0 start
[ 1622]  5101  1622    65868    10170      62        0         -1000 mysqld
[ 2221]  5000  2221    89139     1857     121        0             0 php5-fpm
[ 2235]  5001  2235    24212      951      52        0             0 apache2
[32334]     0 32334     1023       80       8        0             0 sleep
[32337]  5001 32337   193388     2897     124        0             0 apache2
[14138]  5000 14138    93086     6582     129        0             0 php5-fpm
[22853]  5000 22853    89887     2773     124        0             0 php5-fpm
Memory cgroup out of memory: Kill process 1458 (php5-fpm) score 705 or
sacrifice child

I even don't have the usual last line "Killed process [...]"

After that I have all the details of stalls tasks before complete
machine freeze.

INFO: rcu_preempt detected stalls on CPUs/tasks: { 12} (detected by 1,
t=15015 jiffies, g=10207183, c=10207182, q=412)
sending NMI to all CPUs:
NMI backtrace for cpu 0
CPU: 0 PID: 21642 Comm: php5-fpm Not tainted 3.10 #1
Hardware name: Dell Inc. PowerEdge C8220/0TDN55, BIOS 1.1.17 01/09/2013
task: ffff880f18128fe0 ti: ffff880f18129470 task.ti: ffff880f18129470
RIP: 0010:[<ffffffff8122786a>]  [<ffffffff8122786a>]
__write_lock_failed+0x1a/0x40
RSP: 0018:ffff880ff258be98  EFLAGS: 00000087
RAX: ffff880f18129470 RBX: ffff880f18129580 RCX: ffff880ff258bee8
RDX: 0000000000000058 RSI: 0000000000000001 RDI: ffffffff81a04040
RBP: ffff881023116900 R08: 0000000000000037 R09: 0000000000000000
R10: 000000000000001c R11: 0000000000000000 R12: ffff881023116970
R13: ffff880f18128fe0 R14: 0000000000000000 R15: ffff880f18128fe0
FS:  0000000000000000(0000) GS:ffff88103fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000383d57dd300 CR3: 0000000001526000 CR4: 00000000000607f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Stack:
ffffffff8151a547 ffffffff81042a9f ffff881990bd4e40 ffff880ff258bee8
ffff882029086520 000000018110e2db 0000000000000002 ffff880f1584a810
000003d805aeddb8 8000000000000000 ffff880ff258bee8 ffff880ff258bee8
Call Trace:
[<ffffffff8151a547>] ? _raw_write_lock_irq+0x27/0x30
[<ffffffff81042a9f>] ? do_exit+0x30f/0xab0
[<ffffffff810432b8>] ? do_group_exit+0x38/0xa0
[<ffffffff81043332>] ? SyS_exit_group+0x12/0x20
[<ffffffff8151b3be>] ? system_call_fastpath+0x18/0x1d
Code: 48 0f ba 2c 24 3f c3 90 90 90 90 90 90 90 90 90 90 f0 81 07 00
00 10 00 71 09 f0 81 2f 00 00 10 00 cd 04 f3 90 81 3f 00 00 10 00 <75>
f6 f0 81 2f 00 00 10 00 71 09 f0 81 07 00 00 10 00 cd 04 75


My 3.10.x build includes these additional patches:
609838c mm: invoke oom-killer from remaining unconverted page fault handlers
94bce45 arch: mm: remove obsolete init OOM protection
8713410 arch: mm: do not invoke OOM killer on kernel fault OOM
759496b arch: mm: pass userspace fault flag to generic fault handler
3a13c4d x86: finish user fault error path with fatal signal
519e524 mm: memcg: enable memcg OOM killer only for user faults
fb2a6fc mm: memcg: rework and document OOM waiting and wakeup
3812c8c mm: memcg: do not trap chargers with full callstack on OOM
658b72c memcg: check for proper lock held in mem_cgroup_update_page_stat

and also last patches from Johannes Weiner:
mm: memcg: handle non-error OOM situations more gracefully
fs: buffer: move allocation failure loop into the allocator

Any hint? Am I missing something?

Best regards,
-- 
William

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
