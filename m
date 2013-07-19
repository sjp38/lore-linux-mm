Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id E479F6B0031
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 10:53:31 -0400 (EDT)
Date: Fri, 19 Jul 2013 10:53:23 -0400
From: Dave Jones <davej@redhat.com>
Subject: mlockall triggred rcu_preempt stall.
Message-ID: <20130719145323.GA1903@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, paulmck@linux.vnet.ibm.com

My fuzz tester keeps hitting this. Every instance shows the non-irq stack
came in from mlockall.  I'm only seeing this on one box, but that has more
ram (8gb) than my other machines, which might explain it.

	Dave

INFO: rcu_preempt self-detected stall on CPU { 3}  (t=6500 jiffies g=470344 c=470343 q=0)
sending NMI to all CPUs:
NMI backtrace for cpu 3
CPU: 3 PID: 29664 Comm: trinity-child2 Not tainted 3.11.0-rc1+ #32
task: ffff88023e743fc0 ti: ffff88022f6f2000 task.ti: ffff88022f6f2000
RIP: 0010:[<ffffffff810bf7d1>]  [<ffffffff810bf7d1>] trace_hardirqs_off_caller+0x21/0xb0
RSP: 0018:ffff880244e03c30  EFLAGS: 00000046
RAX: ffff88023e743fc0 RBX: 0000000000000001 RCX: 000000000000003c
RDX: 000000000000000f RSI: 0000000000000004 RDI: ffffffff81033cab
RBP: ffff880244e03c38 R08: ffff880243288a80 R09: 0000000000000001
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880243288a80
R13: ffff8802437eda40 R14: 0000000000080000 R15: 000000000000d010
FS:  00007f50ae33b740(0000) GS:ffff880244e00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000000097f000 CR3: 0000000240fa0000 CR4: 00000000001407e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffffffff810bf86d ffff880244e03c98 ffffffff81033cab 0000000000000096
 000000000000d008 0000000300000002 0000000000000004 0000000000000003
 0000000000002710 ffffffff81c50d00 ffffffff81c50d00 ffff880244fcde00
Call Trace:
 <IRQ> 
 [<ffffffff810bf86d>] ? trace_hardirqs_off+0xd/0x10
 [<ffffffff81033cab>] __x2apic_send_IPI_mask+0x1ab/0x1c0
 [<ffffffff81033cdc>] x2apic_send_IPI_all+0x1c/0x20
 [<ffffffff81030115>] arch_trigger_all_cpu_backtrace+0x65/0xa0
 [<ffffffff811144b1>] rcu_check_callbacks+0x331/0x8e0
 [<ffffffff8108bfa0>] ? hrtimer_run_queues+0x20/0x180
 [<ffffffff8109e905>] ? sched_clock_cpu+0xb5/0x100
 [<ffffffff81069557>] update_process_times+0x47/0x80
 [<ffffffff810bd115>] tick_sched_handle.isra.16+0x25/0x60
 [<ffffffff810bd231>] tick_sched_timer+0x41/0x60
 [<ffffffff8108ace1>] __run_hrtimer+0x81/0x4e0
 [<ffffffff810bd1f0>] ? tick_sched_do_timer+0x60/0x60
 [<ffffffff8108b93f>] hrtimer_interrupt+0xff/0x240
 [<ffffffff8102de84>] local_apic_timer_interrupt+0x34/0x60
 [<ffffffff81718c5f>] smp_apic_timer_interrupt+0x3f/0x60
 [<ffffffff817178ef>] apic_timer_interrupt+0x6f/0x80
 [<ffffffff8170e8e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff8105f101>] ? __do_softirq+0xb1/0x440
 [<ffffffff8105f64d>] irq_exit+0xcd/0xe0
 [<ffffffff81718c65>] smp_apic_timer_interrupt+0x45/0x60
 [<ffffffff817178ef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff8170e8e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff8170b830>] ? wait_for_completion_killable+0x170/0x170
 [<ffffffff8170c853>] ? preempt_schedule_irq+0x53/0x90
 [<ffffffff8170e9f6>] retint_kernel+0x26/0x30
 [<ffffffff8107a523>] ? queue_work_on+0x43/0x90
 [<ffffffff8107c369>] schedule_on_each_cpu+0xc9/0x1a0
 [<ffffffff81167770>] ? lru_add_drain+0x50/0x50
 [<ffffffff811677c5>] lru_add_drain_all+0x15/0x20
 [<ffffffff81186965>] SyS_mlockall+0xa5/0x1a0
 [<ffffffff81716e94>] tracesys+0xdd/0xe2
Code: 5d c3 0f 1f 84 00 00 00 00 00 44 8b 1d 29 73 bd 00 65 48 8b 04 25 00 ba 00 00 45 85 db 74 69 44 8b 90 a4 06 00 00 45 85 d2 75 5d <44> 8b 0d a0 47 00 01 45 85 c9 74 33 44 8b 80 70 06 00 00 45 85 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
