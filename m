Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8DF2B6B01F0
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 17:48:47 -0400 (EDT)
Date: Fri, 27 Aug 2010 14:48:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/3 v3] oom: add per-mm oom disable count
Message-Id: <20100827144835.a125feea.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1008201539310.9201@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008201539310.9201@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010 15:41:48 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> From: Ying Han <yinghan@google.com>
> 
> It's pointless to kill a task if another thread sharing its mm cannot be
> killed to allow future memory freeing.  A subsequent patch will prevent
> kills in such cases, but first it's necessary to have a way to flag a
> task that shares memory with an OOM_DISABLE task that doesn't incur an
> additional tasklist scan, which would make select_bad_process() an O(n^2)
> function.
> 
> This patch adds an atomic counter to struct mm_struct that follows how
> many threads attached to it have an oom_score_adj of OOM_SCORE_ADJ_MIN.
> They cannot be killed by the kernel, so their memory cannot be freed in
> oom conditions.
> 
> This only requires task_lock() on the task that we're operating on, it
> does not require mm->mmap_sem since task_lock() pins the mm and the
> operation is atomic.

I don't think lockdep likes us taking task_lock() inside
lock_task_sighand(), in oom_adjust_write():

[   78.185341] 
[   78.185341] =========================================================
[   78.185341] [ INFO: possible irq lock inversion dependency detected ]
[   78.185341] 2.6.36-rc2-mm1 #6
[   78.185341] ---------------------------------------------------------
[   78.185341] kworker/0:1/0 just changed the state of lock:
[   78.185341]  (&(&sighand->siglock)->rlock){-.....}, at: [<ffffffff81042d83>] lock_task_sighand+0x9a/0xda
[   78.185341] but this lock took another, HARDIRQ-unsafe lock in the past:
[   78.185341]  (&(&p->alloc_lock)->rlock){+.+...}
[   78.185341] 
[   78.185341] and interrupts could create inverse lock ordering between them.
[   78.185341] 
[   78.185341] 
[   78.185341] other info that might help us debug this:
[   78.185341] 2 locks held by kworker/0:1/0:
[   78.185341]  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff81044f28>] kill_pid_info+0x0/0x8d
[   78.185341]  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff81042ce9>] lock_task_sighand+0x0/0xda
[   78.185341] 
[   78.185341] the shortest dependencies between 2nd lock and 1st lock:
[   78.185341]  -> (&(&p->alloc_lock)->rlock){+.+...} ops: 221932 {
[   78.185341]     HARDIRQ-ON-W at:
[   78.185341]                                          [<ffffffff8105f595>] __lock_acquire+0x67c/0x865
[   78.185341]                                          [<ffffffff8105fbc7>] lock_acquire+0x8b/0xa8
[   78.185341]                                          [<ffffffff8137df6f>] _raw_spin_lock+0x2f/0x62
[   78.185341]                                          [<ffffffff810c48be>] set_task_comm+0x20/0x61
[   78.185341]                                          [<ffffffff8104eb0e>] kthreadd+0x21/0xf4
[   78.185341]                                          [<ffffffff81003814>] kernel_thread_helper+0x4/0x10
[   78.185341]     SOFTIRQ-ON-W at:
[   78.185341]                                          [<ffffffff8105f5b7>] __lock_acquire+0x69e/0x865
[   78.185341]                                          [<ffffffff8105fbc7>] lock_acquire+0x8b/0xa8
[   78.185341]                                          [<ffffffff8137df6f>] _raw_spin_lock+0x2f/0x62
[   78.185341]                                          [<ffffffff810c48be>] set_task_comm+0x20/0x61
[   78.185341]                                          [<ffffffff8104eb0e>] kthreadd+0x21/0xf4
[   78.185341]                                          [<ffffffff81003814>] kernel_thread_helper+0x4/0x10
[   78.185341]     INITIAL USE at:
[   78.185341]                                         [<ffffffff8105f602>] __lock_acquire+0x6e9/0x865
[   78.185341]                                         [<ffffffff8105fbc7>] lock_acquire+0x8b/0xa8
[   78.185341]                                         [<ffffffff8137df6f>] _raw_spin_lock+0x2f/0x62
[   78.185341]                                         [<ffffffff810c48be>] set_task_comm+0x20/0x61
[   78.185341]                                         [<ffffffff8104eb0e>] kthreadd+0x21/0xf4
[   78.185341]                                         [<ffffffff81003814>] kernel_thread_helper+0x4/0x10
[   78.185341]   }
[   78.185341]   ... key      at: [<ffffffff81b4d568>] __key.46765+0x0/0x8
[   78.185341]   ... acquired at:
[   78.185341]    [<ffffffff8105f701>] __lock_acquire+0x7e8/0x865
[   78.185341]    [<ffffffff8105fbc7>] lock_acquire+0x8b/0xa8
[   78.185341]    [<ffffffff8137df6f>] _raw_spin_lock+0x2f/0x62
[   78.185341]    [<ffffffff8110b910>] oom_adjust_write+0x144/0x2a9
[   78.185341]    [<ffffffff810c02c4>] vfs_write+0xb1/0x13d
[   78.185341]    [<ffffffff810c0873>] sys_write+0x4a/0x75
[   78.185341]    [<ffffffff810029eb>] system_call_fastpath+0x16/0x1b
[   78.185341] 
[   78.185341] -> (&(&sighand->siglock)->rlock){-.....} ops: 208770 {
[   78.185341]    IN-HARDIRQ-W at:
[   78.185341]                                        [<ffffffff8105f51f>] __lock_acquire+0x606/0x865
[   78.185341]                                        [<ffffffff8105fbc7>] lock_acquire+0x8b/0xa8
[   78.185341]                                        [<ffffffff8137e756>] _raw_spin_lock_irqsave+0x3b/0x73
[   78.185341]                                        [<ffffffff81042d83>] lock_task_sighand+0x9a/0xda
[   78.185341]                                        [<ffffffff81044bc9>] do_send_sig_info+0x2f/0x72
[   78.185341]                                        [<ffffffff81044f17>] group_send_sig_info+0x88/0x99
[   78.185341]                                        [<ffffffff81044f88>] kill_pid_info+0x60/0x8d
[   78.185341]                                        [<ffffffff8103b79c>] it_real_fn+0x17/0x1b
[   78.185341]                                        [<ffffffff81051efd>] hrtimer_run_queues+0x167/0x1cb
[   78.185341]                                        [<ffffffff81041bb3>] run_local_timers+0x9/0x15
[   78.185341]                                        [<ffffffff81041d7d>] update_process_times+0x2d/0x56
[   78.185341]                                        [<ffffffff810593ff>] tick_periodic+0x63/0x6f
[   78.185341]                                        [<ffffffff81059429>] tick_handle_periodic+0x1e/0x6b
[   78.185341]                                        [<ffffffff81019b2e>] smp_apic_timer_interrupt+0x83/0x96
[   78.185341]                                        [<ffffffff810033d3>] apic_timer_interrupt+0x13/0x20
[   78.185341]                                        [<ffffffff810014ca>] cpu_idle+0x48/0x66
[   78.185341]                                        [<ffffffff813772bd>] start_secondary+0x1b9/0x1bd
[   78.185341]    INITIAL USE at:
[   78.185341]                                       [<ffffffff8105f602>] __lock_acquire+0x6e9/0x865
[   78.185341]                                       [<ffffffff8105fbc7>] lock_acquire+0x8b/0xa8
[   78.185341]                                       [<ffffffff8137e756>] _raw_spin_lock_irqsave+0x3b/0x73
[   78.185341]                                       [<ffffffff81043122>] flush_signals+0x1d/0x43
[   78.185341]                                       [<ffffffff81043172>] ignore_signals+0x2a/0x2c
[   78.185341]                                       [<ffffffff8104eb16>] kthreadd+0x29/0xf4
[   78.185341]                                       [<ffffffff81003814>] kernel_thread_helper+0x4/0x10
[   78.185341]  }
[   78.185341]  ... key      at: [<ffffffff81b4d538>] __key.47081+0x0/0x8
[   78.185341]  ... acquired at:
[   78.185341]    [<ffffffff8105c566>] check_usage_forwards+0xc0/0xcf
[   78.185341]    [<ffffffff8105ce6f>] mark_lock+0x2f4/0x53f
[   78.185341]    [<ffffffff8105f51f>] __lock_acquire+0x606/0x865
[   78.185341]    [<ffffffff8105fbc7>] lock_acquire+0x8b/0xa8
[   78.185341]    [<ffffffff8137e756>] _raw_spin_lock_irqsave+0x3b/0x73
[   78.185341]    [<ffffffff81042d83>] lock_task_sighand+0x9a/0xda
[   78.185341]    [<ffffffff81044bc9>] do_send_sig_info+0x2f/0x72
[   78.185341]    [<ffffffff81044f17>] group_send_sig_info+0x88/0x99
[   78.185341]    [<ffffffff81044f88>] kill_pid_info+0x60/0x8d
[   78.185341]    [<ffffffff8103b79c>] it_real_fn+0x17/0x1b
[   78.185341]    [<ffffffff81051efd>] hrtimer_run_queues+0x167/0x1cb
[   78.185341]    [<ffffffff81041bb3>] run_local_timers+0x9/0x15
[   78.185341]    [<ffffffff81041d7d>] update_process_times+0x2d/0x56
[   78.185341]    [<ffffffff810593ff>] tick_periodic+0x63/0x6f
[   78.185341]    [<ffffffff81059429>] tick_handle_periodic+0x1e/0x6b
[   78.185341]    [<ffffffff81019b2e>] smp_apic_timer_interrupt+0x83/0x96
[   78.185341]    [<ffffffff810033d3>] apic_timer_interrupt+0x13/0x20
[   78.185341]    [<ffffffff810014ca>] cpu_idle+0x48/0x66
[   78.185341]    [<ffffffff813772bd>] start_secondary+0x1b9/0x1bd
[   78.185341] 
[   78.185341] 
[   78.185341] stack backtrace:
[   78.185341] Pid: 0, comm: kworker/0:1 Not tainted 2.6.36-rc2-mm1 #6
[   78.185341] Call Trace:
[   78.185341]  <IRQ>  [<ffffffff8105c497>] print_irq_inversion_bug+0x11e/0x12d
[   78.185341]  [<ffffffff8105c566>] check_usage_forwards+0xc0/0xcf
[   78.185341]  [<ffffffff8105c4a6>] ? check_usage_forwards+0x0/0xcf
[   78.185341]  [<ffffffff8105ce6f>] mark_lock+0x2f4/0x53f
[   78.185341]  [<ffffffff8105f51f>] __lock_acquire+0x606/0x865
[   78.185341]  [<ffffffff8105fbc7>] lock_acquire+0x8b/0xa8
[   78.185341]  [<ffffffff81042d83>] ? lock_task_sighand+0x9a/0xda
[   78.185341]  [<ffffffff8137e756>] _raw_spin_lock_irqsave+0x3b/0x73
[   78.185341]  [<ffffffff81042d83>] ? lock_task_sighand+0x9a/0xda
[   78.185341]  [<ffffffff81042d83>] lock_task_sighand+0x9a/0xda
[   78.185341]  [<ffffffff81042ce9>] ? lock_task_sighand+0x0/0xda
[   78.185341]  [<ffffffff81044bc9>] do_send_sig_info+0x2f/0x72
[   78.185341]  [<ffffffff81044f17>] group_send_sig_info+0x88/0x99
[   78.185341]  [<ffffffff81044e8f>] ? group_send_sig_info+0x0/0x99
[   78.185341]  [<ffffffff8103b785>] ? it_real_fn+0x0/0x1b
[   78.185341]  [<ffffffff81044f88>] kill_pid_info+0x60/0x8d
[   78.185341]  [<ffffffff81044f28>] ? kill_pid_info+0x0/0x8d
[   78.185341]  [<ffffffff8103b785>] ? it_real_fn+0x0/0x1b
[   78.185341]  [<ffffffff8103b79c>] it_real_fn+0x17/0x1b
[   78.185341]  [<ffffffff81051efd>] hrtimer_run_queues+0x167/0x1cb
[   78.185341]  [<ffffffff81041bb3>] run_local_timers+0x9/0x15
[   78.185341]  [<ffffffff81041d7d>] update_process_times+0x2d/0x56
[   78.185341]  [<ffffffff810593ff>] tick_periodic+0x63/0x6f
[   78.185341]  [<ffffffff81059429>] tick_handle_periodic+0x1e/0x6b
[   78.185341]  [<ffffffff81019b2e>] smp_apic_timer_interrupt+0x83/0x96
[   78.185341]  [<ffffffff810033d3>] apic_timer_interrupt+0x13/0x20
[   78.185341]  <EOI>  [<ffffffff81381c3a>] ? __atomic_notifier_call_chain+0x0/0x84
[   78.185341]  [<ffffffff81381c3a>] ? __atomic_notifier_call_chain+0x0/0x84
[   78.185341]  [<ffffffff81381c3a>] ? __atomic_notifier_call_chain+0x0/0x84
[   78.185341]  [<ffffffff81009afe>] ? mwait_idle+0x66/0x72
[   78.185341]  [<ffffffff81009af4>] ? mwait_idle+0x5c/0x72
[   78.185341]  [<ffffffff810014ca>] cpu_idle+0x48/0x66
[   78.185341]  [<ffffffff813772bd>] start_secondary+0x1b9/0x1bd
[   78.185341]  [<ffffffff81377104>] ? start_secondary+0x0/0x1bd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
