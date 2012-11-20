Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id A5ADD6B0071
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 02:37:04 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so4380696pbc.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2012 23:37:04 -0800 (PST)
Date: Mon, 19 Nov 2012 23:37:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
In-Reply-To: <20121120071704.GA14199@gmail.com>
Message-ID: <alpine.DEB.2.00.1211192329090.14460@chino.kir.corp.google.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org> <20121119162909.GL8218@suse.de> <20121119191339.GA11701@gmail.com> <20121119211804.GM8218@suse.de> <20121119223604.GA13470@gmail.com> <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
 <20121120071704.GA14199@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Tue, 20 Nov 2012, Ingo Molnar wrote:

> No doubt numa/core should not regress with THP off or on and 
> I'll fix that.
> 
> As a background, here's how SPECjbb gets slower on mainline 
> (v3.7-rc6) if you boot Mel's kernel config and turn THP forcibly
> off:
> 
>   (avg: 502395 ops/sec)
>   (avg: 505902 ops/sec)
>   (avg: 509271 ops/sec)
> 
>   # echo never > /sys/kernel/mm/transparent_hugepage/enabled
> 
>   (avg: 376989 ops/sec)
>   (avg: 379463 ops/sec)
>   (avg: 378131 ops/sec)
> 
> A ~30% slowdown.
> 
> [ How do I know? I asked for Mel's kernel config days ago and
>   actually booted Mel's very config in the past few days, 
>   spending hours on testing it on 4 separate NUMA systems, 
>   trying to find Mel's regression. In the past Mel was a 
>   reliable tester so I blindly trusted his results. Was that 
>   some weird sort of denial on my part? :-) ]
> 

I confirm that numa/core regresses significantly more without thp than the 
6.3% regression I reported with thp in terms of throughput on the same 
system.  numa/core at 01aa90068b12 ("sched: Use the best-buddy 'ideal cpu' 
in balancing decisions") had 99389.49 SPECjbb2005 bops whereas 
ec05a2311c35 ("Merge branch 'sched/urgent' into sched/core") had 122246.90 
SPECjbb2005 bops, a 23.0% regression.

perf top -U for >=0.70% at 01aa90068b12 ("sched: Use the best-buddy 'ideal 
cpu' in balancing decisions"):

    16.34%  [kernel]  [k] page_fault               
    12.15%  [kernel]  [k] down_read_trylock        
     9.21%  [kernel]  [k] up_read                  
     7.58%  [kernel]  [k] handle_pte_fault         
     6.10%  [kernel]  [k] handle_mm_fault          
     4.35%  [kernel]  [k] retint_swapgs            
     3.99%  [kernel]  [k] find_vma                 
     3.95%  [kernel]  [k] __do_page_fault          
     3.81%  [kernel]  [k] mpol_misplaced           
     3.41%  [kernel]  [k] get_vma_policy           
     2.68%  [kernel]  [k] task_numa_fault          
     1.82%  [kernel]  [k] pte_numa                 
     1.65%  [kernel]  [k] do_page_fault            
     1.46%  [kernel]  [k] _raw_spin_lock           
     1.28%  [kernel]  [k] do_wp_page               
     1.26%  [kernel]  [k] vm_normal_page           
     1.25%  [kernel]  [k] unlock_page              
     1.01%  [kernel]  [k] change_protection        
     0.80%  [kernel]  [k] getnstimeofday           
     0.79%  [kernel]  [k] ktime_get                
     0.76%  [kernel]  [k] __wake_up_bit            
     0.74%  [kernel]  [k] rcu_check_callbacks      

and at ec05a2311c35 ("Merge branch 'sched/urgent' into sched/core"):

    22.01%  [kernel]  [k] page_fault                            
     6.54%  [kernel]  [k] rcu_check_callbacks                   
     5.04%  [kernel]  [k] getnstimeofday                        
     4.12%  [kernel]  [k] ktime_get                             
     3.55%  [kernel]  [k] read_tsc                              
     3.37%  [kernel]  [k] task_tick_fair                        
     2.61%  [kernel]  [k] emulate_vsyscall                      
     2.22%  [kernel]  [k] __do_page_fault                       
     1.78%  [kernel]  [k] run_timer_softirq                     
     1.71%  [kernel]  [k] write_ok_or_segv                      
     1.55%  [kernel]  [k] copy_user_generic_string              
     1.48%  [kernel]  [k] __bad_area_nosemaphore                
     1.27%  [kernel]  [k] retint_swapgs                         
     1.26%  [kernel]  [k] spurious_fault                        
     1.15%  [kernel]  [k] update_rq_clock                       
     1.12%  [kernel]  [k] update_cfs_shares                     
     1.09%  [kernel]  [k] _raw_spin_lock                        
     1.08%  [kernel]  [k] update_curr                           
     1.07%  [kernel]  [k] error_entry                           
     1.05%  [kernel]  [k] x86_pmu_disable_all                   
     0.88%  [kernel]  [k] sys_gettimeofday                      
     0.88%  [kernel]  [k] __do_softirq                          
     0.87%  [kernel]  [k] _raw_spin_lock_irq                    
     0.84%  [kernel]  [k] hrtimer_forward                       
     0.81%  [kernel]  [k] ktime_get_update_offsets              
     0.79%  [kernel]  [k] __update_cpu_load                     
     0.77%  [kernel]  [k] acct_update_integrals                 
     0.77%  [kernel]  [k] hrtimer_interrupt                     
     0.75%  [kernel]  [k] perf_adjust_freq_unthr_context.part.81
     0.73%  [kernel]  [k] do_gettimeofday                       
     0.73%  [kernel]  [k] apic_timer_interrupt                  
     0.72%  [kernel]  [k] timerqueue_add                        
     0.70%  [kernel]  [k] tick_sched_timer

This is in comparison to my earlier perftop results which were with thp 
enabled.  Keep in mind that this system has a NUMA configuration of

$ cat /sys/devices/system/node/node*/distance 
10 20 20 30
20 10 20 20
20 20 10 20
30 20 20 10

so perhaps you would have better luck reproducing the problem using the 
new ability to fake the distance in between nodes that Peter introduced in 
94c0dd3278dd ("x86/numa: Allow specifying node_distance() for numa=fake") 
with numa=fake=4:10,20,20,30,20,10,20,20,20,20,10,20,30,20,20,10 ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
