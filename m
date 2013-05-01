Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 842336B0188
	for <linux-mm@kvack.org>; Wed,  1 May 2013 12:44:16 -0400 (EDT)
Received: by mail-oa0-f69.google.com with SMTP id l20so10443682oag.0
        for <linux-mm@kvack.org>; Wed, 01 May 2013 09:44:10 -0700 (PDT)
Date: Wed, 1 May 2013 11:44:06 -0500
From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: deadlock on vmap_area_lock
Message-ID: <20130501164406.GC2404@BohrerMBP.rgmadvisors.com>
References: <20130501144341.GA2404@BohrerMBP.rgmadvisors.com>
 <alpine.DEB.2.02.1305010855440.4547@chino.kir.corp.google.com>
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1305010855440.4547@chino.kir.corp.google.com>
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: xfs@oss.sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 01, 2013 at 08:57:38AM -0700, David Rientjes wrote:
> On Wed, 1 May 2013, Shawn Bohrer wrote:
> 
> > I've got two compute clusters with around 350 machines each which are
> > running kernels based off of 3.1.9 (Yes I realize this is ancient by
> > todays standards).  All of the machines run a 'find' command once an
> > hour on one of the mounted XFS filesystems.  Occasionally these find
> > commands get stuck requiring a reboot of the system.  I took a peek
> > today and see this with perf:
> > 
> >     72.22%          find  [kernel.kallsyms]          [k] _raw_spin_lock
> >                     |
> >                     --- _raw_spin_lock
> >                        |          
> >                        |--98.84%-- vm_map_ram
> >                        |          _xfs_buf_map_pages
> >                        |          xfs_buf_get
> >                        |          xfs_buf_read
> >                        |          xfs_trans_read_buf
> >                        |          xfs_da_do_buf
> >                        |          xfs_da_read_buf
> >                        |          xfs_dir2_block_getdents
> >                        |          xfs_readdir
> >                        |          xfs_file_readdir
> >                        |          vfs_readdir
> >                        |          sys_getdents
> >                        |          system_call_fastpath
> >                        |          __getdents64
> >                        |          
> >                        |--1.12%-- _xfs_buf_map_pages
> >                        |          xfs_buf_get
> >                        |          xfs_buf_read
> >                        |          xfs_trans_read_buf
> >                        |          xfs_da_do_buf
> >                        |          xfs_da_read_buf
> >                        |          xfs_dir2_block_getdents
> >                        |          xfs_readdir
> >                        |          xfs_file_readdir
> >                        |          vfs_readdir
> >                        |          sys_getdents
> >                        |          system_call_fastpath
> >                        |          __getdents64
> >                         --0.04%-- [...]
> > 
> > Looking at the code my best guess is that we are spinning on
> > vmap_area_lock, but I could be wrong.  This is the only process
> > spinning on the machine so I'm assuming either another process has
> > blocked while holding the lock, or perhaps this find process has tried
> > to acquire the vmap_area_lock twice?
> > 
> 
> Significant spinlock contention doesn't necessarily mean that there's a 
> deadlock, but it also doesn't mean the opposite.

Correct it doesn't and I can't prove the find command is not making
progress, however these finds normally complete in under 15 min and
we've let the stuck ones run for days.  Additionally if this was just
contention I'd expect to see multiple threads/CPUs contending and I
only have a single CPU pegged running find at 99%. I should clarify
that the perf snippet above was for the entire system.  Profiling just
the find command shows:

    82.56%     find  [kernel.kallsyms]  [k] _raw_spin_lock
    16.63%     find  [kernel.kallsyms]  [k] vm_map_ram
     0.13%     find  [kernel.kallsyms]  [k] hrtimer_interrupt
     0.04%     find  [kernel.kallsyms]  [k] update_curr
     0.03%     find  [igb]              [k] igb_poll
     0.03%     find  [kernel.kallsyms]  [k] irqtime_account_process_tick
     0.03%     find  [kernel.kallsyms]  [k] account_system_vtime
     0.03%     find  [kernel.kallsyms]  [k] task_tick_fair
     0.03%     find  [kernel.kallsyms]  [k] perf_event_task_tick
     0.03%     find  [kernel.kallsyms]  [k] scheduler_tick
     0.03%     find  [kernel.kallsyms]  [k] rb_erase
     0.02%     find  [kernel.kallsyms]  [k] native_write_msr_safe
     0.02%     find  [kernel.kallsyms]  [k] native_sched_clock
     0.02%     find  [kernel.kallsyms]  [k] dma_issue_pending_all
     0.02%     find  [kernel.kallsyms]  [k] handle_irq_event_percpu
     0.02%     find  [kernel.kallsyms]  [k] timerqueue_del
     0.02%     find  [kernel.kallsyms]  [k] run_timer_softirq
     0.02%     find  [kernel.kallsyms]  [k] get_mm_counter
     0.02%     find  [kernel.kallsyms]  [k] __rcu_pending
     0.02%     find  [kernel.kallsyms]  [k] tick_program_event
     0.01%     find  [kernel.kallsyms]  [k] __netif_receive_skb
     0.01%     find  [kernel.kallsyms]  [k] ip_route_input_common
     0.01%     find  [kernel.kallsyms]  [k] __insert_vmap_area
     0.01%     find  [igb]              [k] igb_alloc_rx_buffers_adv
     0.01%     find  [kernel.kallsyms]  [k] irq_exit
     0.01%     find  [kernel.kallsyms]  [k] acct_update_integrals
     0.01%     find  [kernel.kallsyms]  [k] apic_timer_interrupt
     0.01%     find  [kernel.kallsyms]  [k] tick_sched_timer
     0.01%     find  [kernel.kallsyms]  [k] __remove_hrtimer
     0.01%     find  [kernel.kallsyms]  [k] do_IRQ
     0.01%     find  [kernel.kallsyms]  [k] dev_gro_receive
     0.01%     find  [kernel.kallsyms]  [k] net_rx_action
     0.01%     find  [kernel.kallsyms]  [k] classify
     0.01%     find  [kernel.kallsyms]  [k] __udp4_lib_mcast_deliver
     0.01%     find  [kernel.kallsyms]  [k] rb_next
     0.01%     find  [kernel.kallsyms]  [k] smp_apic_timer_interrupt
     0.01%     find  [kernel.kallsyms]  [k] intel_pmu_disable_all
     0.01%     find  [ioatdma]          [k] ioat2_issue_pending
     0.01%     find  [kernel.kallsyms]  [k] get_partial_node
     0.01%     find  [kernel.kallsyms]  [k] ktime_get
     0.01%     find  [kernel.kallsyms]  [k] radix_tree_lookup_element
     0.01%     find  [kernel.kallsyms]  [k] swiotlb_map_page
     0.01%     find  [kernel.kallsyms]  [k] __schedule
     0.01%     find  [kernel.kallsyms]  [k] _raw_spin_lock_irq
     0.01%     find  [kernel.kallsyms]  [k] hrtimer_forward
     0.01%     find  [kernel.kallsyms]  [k] sched_clock_tick
     0.01%     find  [kernel.kallsyms]  [k] clockevents_program_event
     0.01%     find  [kernel.kallsyms]  [k] raw_local_deliver
     0.01%     find  [kernel.kallsyms]  [k] exit_idle
     0.01%     find  [kernel.kallsyms]  [k] sched_clock_cpu
     0.01%     find  [kernel.kallsyms]  [k] sched_clock
     0.01%     find  [kernel.kallsyms]  [k] idle_cpu
     0.01%     find  [kernel.kallsyms]  [k] update_process_times
     0.01%     find  [kernel.kallsyms]  [k] tick_dev_program_event

> Depending on your 
> definition of "occassionally", would it be possible to run with 
> CONFIG_PROVE_LOCKING and CONFIG_LOCKDEP to see if it uncovers any real 
> deadlock potential?

Yeah, I can probably enable these on a few machines and hope I get
lucky.  These machines are used for real work so I'll have to gauge
what how significant the performance impact is to determine how many
machines I can sacrifice to the cause.

Thanks,
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
