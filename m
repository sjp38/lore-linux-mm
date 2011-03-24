Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D55DE8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:53:13 -0400 (EDT)
Date: Thu, 24 Mar 2011 19:52:58 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: [boot crash #2] Re: [GIT PULL] SLAB changes for v2.6.39-rc1
Message-ID: <20110324185258.GA28370@elte.hu>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>
 <20110324142146.GA11682@elte.hu>
 <alpine.DEB.2.00.1103240940570.32226@router.home>
 <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>
 <20110324172653.GA28507@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110324172653.GA28507@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org


There's a different crash triggered by the slub merge as well, i've bisected it 
back to one of these commits:

09b9cc4: sd: Fail discard requests when logical block provisioning has been disabled
a24c5a0: slub: Dont define useless label in the !CONFIG_CMPXCHG_LOCAL case
5bfe53a: slab,rcu: don't assume the size of struct rcu_head
da9a638: slub,rcu: don't assume the size of struct rcu_head
ab9a0f1: slub: automatically reserve bytes at the end of slab
8a5ec0b: Lockless (and preemptless) fastpaths for slub
d3f661d: slub: Get rid of slab_free_hook_irq()
1a757fe: slub: min_partial needs to be in first cacheline
d71f606: slub: fix ksize() build error
b3d4188: slub: fix kmemcheck calls to match ksize() hints
3ff84a7: Revert "slab: Fix missing DEBUG_SLAB last user"
6331046: mm: Remove support for kmem_cache_name()

The crash is below.

	Ingo

[/sbin/fsck.ext3 (1) -- /] fsck.ext3 -a /dev/sda6 
general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
last sysfs file: /sys/block/sda/sda10/dev
CPU 0 
Pid: 0, comm: swapper Tainted: G        W   2.6.38-tip-09247-g0637536-dirty #110370 System manufacturer System Product Name/A8N-E
RIP: 0010:[<ffffffff810570a9>]  [<ffffffff810570a9>] get_next_timer_interrupt+0x119/0x260
RSP: 0018:ffff88003fa03ec8  EFLAGS: 00010002
RAX: 6b6b6b6b6b6b6b6b RBX: 000000013fff034e RCX: ffffffff82808cc0
RDX: 6b6b6b6b6b6b6b6b RSI: 0000000000000000 RDI: 000000000000000e
RBP: ffff88003fa03f18 R08: 000000000000000e R09: ffffffff82808be0
R10: 0000000000000000 R11: 0000000003fffc0e R12: 00000000ffff034e
R13: ffffffff828087c0 R14: 0000000000000010 R15: ffff88003fa0c200
FS:  000000000071d8f0(0000) GS:ffff88003fa00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 000000000072fc5f CR3: 000000003bc32000 CR4: 00000000000006b0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff82400000, task ffffffff8242f020)
Stack:
 ffff88003fa03f18 ffffffff810929bb ffffffff82808be0 ffffffff82808ce0
 ffffffff82808de0 ffffffff82808ee0 ffff88003fa0dbe0 0000000000000000
 0000000000000086 00000013a4a5c86d ffff88003fa03f78 ffffffff81076761
Call Trace:
 <IRQ> 
 [<ffffffff810929bb>] ? rcu_needs_cpu+0x6b/0x220
 [<ffffffff81076761>] tick_nohz_stop_sched_tick+0x2c1/0x3d0
 [<ffffffff81d64b6c>] ? call_softirq+0x1c/0x30
 [<ffffffff8104dcc4>] irq_exit+0x84/0xb0
 [<ffffffff81d651e0>] smp_apic_timer_interrupt+0x70/0x9b
 [<ffffffff81d64653>] apic_timer_interrupt+0x13/0x20
 <EOI> 
 [<ffffffff8100a262>] ? default_idle+0x42/0x110
 [<ffffffff810011cd>] cpu_idle+0x5d/0xb0
 [<ffffffff81cc7d1e>] rest_init+0x72/0x74
 [<ffffffff825dec49>] start_kernel+0x44d/0x458
 [<ffffffff825de322>] x86_64_start_reservations+0x132/0x136
 [<ffffffff825de416>] x86_64_start_kernel+0xf0/0xf7
Code: 04 4c 01 c9 48 8b 01 eb 22 66 0f 1f 84 00 00 00 00 00 f6 40 18 01 75 10 48 8b 40 10 be 01 00 00 00 48 39 d8 48 0f 48 d8 48 89 d0 
 8b 10 48 39 c1 0f 18 0a 75 dc 85 f6 75 5d 83 c7 01 83 e7 0f 
RIP  [<ffffffff810570a9>] get_next_timer_interrupt+0x119/0x260
 RSP <ffff88003fa03ec8>
---[ end trace cea3203dccec701b ]---
Kernel panic - not syncing: Fatal exception
Pid: 0, comm: swapper Tainted: G      D W   2.6.38-tip-09247-g0637536-dirty #110370
Call Trace:
 <IRQ>  [<ffffffff81d4da7f>] panic+0x91/0x18e
 [<ffffffff81005ec4>] oops_end+0xd4/0xf0
 [<ffffffff81006038>] die+0x58/0x90
 [<ffffffff810033d2>] do_general_protection+0x162/0x170
 [<ffffffff812bf265>] ? __cfq_slice_expired+0x295/0x490
 [<ffffffff81d6382f>] general_protection+0x1f/0x30
 [<ffffffff810570a9>] ? get_next_timer_interrupt+0x119/0x260
 [<ffffffff81056fd4>] ? get_next_timer_interrupt+0x44/0x260
 [<ffffffff810929bb>] ? rcu_needs_cpu+0x6b/0x220
 [<ffffffff81076761>] tick_nohz_stop_sched_tick+0x2c1/0x3d0
 [<ffffffff81d64b6c>] ? call_softirq+0x1c/0x30
 [<ffffffff8104dcc4>] irq_exit+0x84/0xb0
 [<ffffffff81d651e0>] smp_apic_timer_interrupt+0x70/0x9b
 [<ffffffff81d64653>] apic_timer_interrupt+0x13/0x20
 <EOI>  [<ffffffff8100a262>] ? default_idle+0x42/0x110
 [<ffffffff810011cd>] cpu_idle+0x5d/0xb0
 [<ffffffff81cc7d1e>] rest_init+0x72/0x74
 [<ffffffff825dec49>] start_kernel+0x44d/0x458
 [<ffffffff825de322>] x86_64_start_reservations+0x132/0x136
 [<ffffffff825de416>] x86_64_start_kernel+0xf0/0xf7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
