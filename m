Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E378F6B002D
	for <linux-mm@kvack.org>; Sat, 22 Oct 2011 13:35:43 -0400 (EDT)
From: =?utf-8?q?Pawe=C5=82_Sikora?= <pluto@agmk.net>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
Date: Sat, 22 Oct 2011 18:42:26 +0200
References: <201110122012.33767.pluto@agmk.net> <201110212336.47267.pluto@agmk.net> <201110221421.23181.nai.xia@gmail.com>
In-Reply-To: <201110221421.23181.nai.xia@gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <201110221842.26940.pluto@agmk.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nai.xia@gmail.com
Cc: Hugh Dickins <hughd@google.com>, arekm@pld-linux.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, jpiszcz@lucidpixels.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On Saturday 22 of October 2011 08:21:23 Nai Xia wrote:
> On Saturday 22 October 2011 05:36:46 PaweA? Sikora wrote:
> > On Friday 21 of October 2011 11:07:56 Nai Xia wrote:
> > > On Fri, Oct 21, 2011 at 4:07 PM, Pawel Sikora <pluto@agmk.net> wrote:
> > > > On Friday 21 of October 2011 14:22:37 Nai Xia wrote:
> > > >
> > > >> And as a side note. Since I notice that Pawel's workload may include OOM,
> > > >
> > > > my last tests on patched (3.0.4 + migrate.c fix + vserver) kernel produce full cpu load
> > > > on dual 8-cores opterons like on this htop screenshot -> http://pluto.agmk.net/kernel/screen1.png
> > > > afaics all userspace applications usualy don't use more than half of physical memory
> > > > and so called "cache" on htop bar doesn't reach the 100%.
> > > 
> > > OKi 1/4 ?did you logged any OOM killing if there was some memory usage burst?
> > > But, well my above OOM reasoning is a direct short cut to imagined
> > > root cause of "adjacent VMAs which
> > > should have been merged but in fact not merged" case.
> > > Maybe there are other cases that can lead to this or maybe it's
> > > totally another bug....
> > 
> > i don't see any OOM killing with my conservative settings
> > (vm.overcommit_memory=2, vm.overcommit_ratio=100).
> 
> OK, that does not matter now. Andrea showed us a simpler way to goto
> this bug. 
> 
> > 
> > > But still I think if my reasoning is good, similar bad things will
> > > happen again some time in the future,
> > > even if it was not your case here...
> > > 
> > > >
> > > > the patched kernel with disabled CONFIG_TRANSPARENT_HUGEPAGE (new thing in 2.6.38)
> > > > died at night, so now i'm going to disable also CONFIG_COMPACTION/MIGRATION in next
> > > > steps and stress this machine again...
> > > 
> > > OK, it's smart to narrow down the range first....
> > 
> > disabling hugepage/compacting didn't help but disabling hugepage/compacting/migration keeps
> > opterons stable for ~9h so far. userspace uses ~40GB (from 64) ram, caches reach 100% on htop bar,
> > average load ~16. i wonder if it survive weekend...
> > 
> 
> Maybe you should give another shot of Andrea's latest anon_vma_order_tail() patch. :)
> 

all my attempts to disabling thp/compaction/migration failed (machine locked).
now, i'm testing 3.0.7+vserver+Hugh's+Andrea's patches+enabled few kernel debug options.

so far it has logged only something unrelated to memory managment subsystem:

[  258.397014] =======================================================
[  258.397209] [ INFO: possible circular locking dependency detected ]
[  258.397311] 3.0.7-vs2.3.1-dirty #1
[  258.397402] -------------------------------------------------------
[  258.397503] slave_odra_g_00/19432 is trying to acquire lock:
[  258.397603]  (&(&sig->cputimer.lock)->rlock){-.....}, at: [<ffffffff8103adfc>] update_curr+0xfc/0x190
[  258.397912] 
[  258.397912] but task is already holding lock:
[  258.398090]  (&rq->lock){-.-.-.}, at: [<ffffffff81041a8e>] scheduler_tick+0x4e/0x280
[  258.398387] 
[  258.398388] which lock already depends on the new lock.
[  258.398389] 
[  258.398652] 
[  258.398653] the existing dependency chain (in reverse order) is:
[  258.398836] 
[  258.398837] -> #2 (&rq->lock){-.-.-.}:
[  258.399178]        [<ffffffff810959ee>] lock_acquire+0x8e/0x120
[  258.399336]        [<ffffffff81466e5c>] _raw_spin_lock+0x2c/0x40
[  258.399495]        [<ffffffff81040bd7>] wake_up_new_task+0x97/0x1c0
[  258.399652]        [<ffffffff81047db6>] do_fork+0x176/0x460
[  258.399807]        [<ffffffff8100999c>] kernel_thread+0x6c/0x70
[  258.399964]        [<ffffffff8144715d>] rest_init+0x21/0xc4
[  258.400120]        [<ffffffff818adbd2>] start_kernel+0x3d6/0x3e1
[  258.400280]        [<ffffffff818ad322>] x86_64_start_reservations+0x132/0x136
[  258.400336]        [<ffffffff818ad416>] x86_64_start_kernel+0xf0/0xf7
[  258.400336] 
[  258.400336] -> #1 (&p->pi_lock){-.-.-.}:
[  258.400336]        [<ffffffff810959ee>] lock_acquire+0x8e/0x120
[  258.400336]        [<ffffffff81466f5c>] _raw_spin_lock_irqsave+0x3c/0x60
[  258.400336]        [<ffffffff8106f328>] thread_group_cputimer+0x38/0x100
[  258.400336]        [<ffffffff8106f41d>] cpu_timer_sample_group+0x2d/0xa0
[  258.400336]        [<ffffffff8107080a>] set_process_cpu_timer+0x3a/0x110
[  258.400336]        [<ffffffff8107091a>] update_rlimit_cpu+0x3a/0x60
[  258.400336]        [<ffffffff81062c0e>] do_prlimit+0x19e/0x240
[  258.400336]        [<ffffffff81063008>] sys_setrlimit+0x48/0x60
[  258.400336]        [<ffffffff8146efbb>] system_call_fastpath+0x16/0x1b
[  258.400336] 
[  258.400336] -> #0 (&(&sig->cputimer.lock)->rlock){-.....}:
[  258.400336]        [<ffffffff810951e7>] __lock_acquire+0x1aa7/0x1cc0
[  258.400336]        [<ffffffff810959ee>] lock_acquire+0x8e/0x120
[  258.400336]        [<ffffffff81466e5c>] _raw_spin_lock+0x2c/0x40
[  258.400336]        [<ffffffff8103adfc>] update_curr+0xfc/0x190
[  258.400336]        [<ffffffff8103b22d>] task_tick_fair+0x2d/0x140
[  258.400336]        [<ffffffff81041b0f>] scheduler_tick+0xcf/0x280
[  258.400336]        [<ffffffff8105a439>] update_process_times+0x69/0x80
[  258.400336]        [<ffffffff8108e0cf>] tick_sched_timer+0x5f/0xc0
[  258.400336]        [<ffffffff81071339>] __run_hrtimer+0x79/0x1f0
[  258.400336]        [<ffffffff81071ce3>] hrtimer_interrupt+0xf3/0x220
[  258.400336]        [<ffffffff8101daa4>] smp_apic_timer_interrupt+0x64/0xa0
[  258.400336]        [<ffffffff8146f9d3>] apic_timer_interrupt+0x13/0x20
[  258.400336]        [<ffffffff8107092d>] update_rlimit_cpu+0x4d/0x60
[  258.400336]        [<ffffffff81062c0e>] do_prlimit+0x19e/0x240
[  258.400336]        [<ffffffff81063008>] sys_setrlimit+0x48/0x60
[  258.400336]        [<ffffffff8146efbb>] system_call_fastpath+0x16/0x1b
[  258.400336] 
[  258.400336] other info that might help us debug this:
[  258.400336] 
[  258.400336] Chain exists of:
[  258.400336]   &(&sig->cputimer.lock)->rlock --> &p->pi_lock --> &rq->lock
[  258.400336] 
[  258.400336]  Possible unsafe locking scenario:
[  258.400336] 
[  258.400336]        CPU0                    CPU1
[  258.400336]        ----                    ----
[  258.400336]   lock(&rq->lock);
[  258.400336]                                lock(&p->pi_lock);
[  258.400336]                                lock(&rq->lock);
[  258.400336]   lock(&(&sig->cputimer.lock)->rlock);
[  258.400336] 
[  258.400336]  *** DEADLOCK ***
[  258.400336] 
[  258.400336] 2 locks held by slave_odra_g_00/19432:
[  258.400336]  #0:  (tasklist_lock){.+.+..}, at: [<ffffffff81062acd>] do_prlimit+0x5d/0x240
[  258.400336]  #1:  (&rq->lock){-.-.-.}, at: [<ffffffff81041a8e>] scheduler_tick+0x4e/0x280
[  258.400336] 
[  258.400336] stack backtrace:
[  258.400336] Pid: 19432, comm: slave_odra_g_00 Not tainted 3.0.7-vs2.3.1-dirty #1
[  258.400336] Call Trace:
[  258.400336]  <IRQ>  [<ffffffff8145e204>] print_circular_bug+0x23d/0x24e
[  258.400336]  [<ffffffff810951e7>] __lock_acquire+0x1aa7/0x1cc0
[  258.400336]  [<ffffffff8109264d>] ? mark_lock+0x2dd/0x330
[  258.400336]  [<ffffffff81093bfd>] ? __lock_acquire+0x4bd/0x1cc0
[  258.400336]  [<ffffffff8103adfc>] ? update_curr+0xfc/0x190
[  258.400336]  [<ffffffff810959ee>] lock_acquire+0x8e/0x120
[  258.400336]  [<ffffffff8103adfc>] ? update_curr+0xfc/0x190
[  258.400336]  [<ffffffff81466e5c>] _raw_spin_lock+0x2c/0x40
[  258.400336]  [<ffffffff8103adfc>] ? update_curr+0xfc/0x190
[  258.400336]  [<ffffffff8103adfc>] update_curr+0xfc/0x190
[  258.400336]  [<ffffffff8103b22d>] task_tick_fair+0x2d/0x140
[  258.400336]  [<ffffffff81041b0f>] scheduler_tick+0xcf/0x280
[  258.400336]  [<ffffffff8105a439>] update_process_times+0x69/0x80
[  258.400336]  [<ffffffff8108e0cf>] tick_sched_timer+0x5f/0xc0
[  258.400336]  [<ffffffff81071339>] __run_hrtimer+0x79/0x1f0
[  258.400336]  [<ffffffff8108e070>] ? tick_nohz_handler+0x100/0x100
[  258.400336]  [<ffffffff81071ce3>] hrtimer_interrupt+0xf3/0x220
[  258.400336]  [<ffffffff8101daa4>] smp_apic_timer_interrupt+0x64/0xa0
[  258.400336]  [<ffffffff8146f9d3>] apic_timer_interrupt+0x13/0x20
[  258.400336]  <EOI>  [<ffffffff814674e0>] ? _raw_spin_unlock_irq+0x30/0x40
[  258.400336]  [<ffffffff8107092d>] update_rlimit_cpu+0x4d/0x60
[  258.400336]  [<ffffffff81062c0e>] do_prlimit+0x19e/0x240
[  258.400336]  [<ffffffff81063008>] sys_setrlimit+0x48/0x60
[  258.400336]  [<ffffffff8146efbb>] system_call_fastpath+0x16/0x1b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
