Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 3F5976B0099
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 21:41:17 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so5075443pbc.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 18:41:16 -0800 (PST)
Date: Tue, 20 Nov 2012 18:41:14 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH, v2] mm, numa: Turn 4K pte NUMA faults into effective
 hugepage ones
In-Reply-To: <20121120160918.GA18167@gmail.com>
Message-ID: <alpine.DEB.2.00.1211201833080.2278@chino.kir.corp.google.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org> <20121119162909.GL8218@suse.de> <20121119191339.GA11701@gmail.com> <20121119211804.GM8218@suse.de> <20121119223604.GA13470@gmail.com> <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
 <20121120071704.GA14199@gmail.com> <20121120152933.GA17996@gmail.com> <20121120160918.GA18167@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Tue, 20 Nov 2012, Ingo Molnar wrote:

> Reduce the 4K page fault count by looking around and processing
> nearby pages if possible.
> 
> To keep the logic and cache overhead simple and straightforward
> we do a couple of simplifications:
> 
>  - we only scan in the HPAGE_SIZE range of the faulting address
>  - we only go as far as the vma allows us
> 
> Also simplify the do_numa_page() flow while at it and fix the
> previous double faulting we incurred due to not properly fixing
> up freshly migrated ptes.
> 
> Suggested-by: Mel Gorman <mgorman@suse.de>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Ingo Molnar <mingo@kernel.org>

Acked-by: David Rientjes <rientjes@google.com>

Ok, this is significantly better, it almost cut the regression in half on 
my system.  With THP enabled:

   numa/core at ec05a2311c35:           136918.34 SPECjbb2005 bops
   numa/core at 01aa90068b12:           128315.19 SPECjbb2005 bops (-6.3%)
   numa/core at 01aa90068b12 + patch:   132523.06 SPECjbb2005 bops (-3.2%)

Here's the newest perftop, which is radically different than before (not 
nearly the number of newly-added numa/core functions in the biggest 
consumers) but still incurs significant overhead from page faults.

    92.18%  perf-6697.map     [.] 0x00007fe2c5afd079                               
     1.20%  libjvm.so         [.] instanceKlass::oop_push_contents(PSPromotionManag
     1.05%  libjvm.so         [.] PSPromotionManager::drain_stacks_depth(bool)     
     0.78%  libjvm.so         [.] PSPromotionManager::copy_to_survivor_space(oopDes
     0.59%  libjvm.so         [.] PSPromotionManager::claim_or_forward_internal_dep
     0.49%  [kernel]          [k] page_fault                                               
     0.27%  libjvm.so         [.] Copy::pd_disjoint_words(HeapWord*, HeapWord*, unsigned lo
     0.27%  libc-2.3.6.so     [.] __gettimeofday                                           
     0.19%  libjvm.so         [.] CardTableExtension::scavenge_contents_parallel(ObjectStar
     0.16%  [kernel]          [k] getnstimeofday                                           
     0.14%  [kernel]          [k] _raw_spin_lock                                           
     0.13%  [kernel]          [k] generic_smp_call_function_interrupt                      
     0.11%  [kernel]          [k] ktime_get                                                
     0.11%  [kernel]          [k] rcu_check_callbacks                                      
     0.10%  [kernel]          [k] read_tsc                                                 
     0.09%  libjvm.so         [.] os::javaTimeMillis()                                     
     0.09%  [kernel]          [k] clear_page_c                                             
     0.08%  [kernel]          [k] flush_tlb_func                                           
     0.08%  [kernel]          [k] ktime_get_update_offsets                                 
     0.07%  [kernel]          [k] task_tick_fair                                           
     0.06%  [kernel]          [k] emulate_vsyscall                                         
     0.06%  libjvm.so         [.] oopDesc::size_given_klass(Klass*)                        
     0.06%  [kernel]          [k] __do_page_fault                                          
     0.04%  [kernel]          [k] __bad_area_nosemaphore                                   
     0.04%  perf              [.] 0x000000000003310b                                       
     0.04%  libjvm.so         [.] objArrayKlass::oop_push_contents(PSPromotionManager*, oop
     0.04%  [kernel]          [k] run_timer_softirq                                        
     0.04%  [kernel]          [k] copy_user_generic_string                                 
     0.03%  [kernel]          [k] task_numa_fault                                          
     0.03%  [kernel]          [k] smp_call_function_many                                   
     0.03%  [kernel]          [k] retint_swapgs                                            
     0.03%  [kernel]          [k] update_cfs_shares                                        
     0.03%  [kernel]          [k] error_sti                                                
     0.03%  [kernel]          [k] _raw_spin_lock_irq                                       
     0.03%  [kernel]          [k] update_curr                                              
     0.02%  [kernel]          [k] write_ok_or_segv                                         
     0.02%  [kernel]          [k] call_function_interrupt                                  
     0.02%  [kernel]          [k] __do_softirq                                             
     0.02%  [kernel]          [k] acct_update_integrals                                    
     0.02%  [kernel]          [k] x86_pmu_disable_all                                      
     0.02%  [kernel]          [k] apic_timer_interrupt                                     
     0.02%  [kernel]          [k] tick_sched_timer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
