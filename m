Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id AA1C86B0072
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 19:43:30 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so608915pad.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 16:43:30 -0800 (PST)
Date: Tue, 20 Nov 2012 16:43:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] x86/vsyscall: Add Kconfig option to use native vsyscalls,
 switch to it
In-Reply-To: <20121120094132.GA15156@gmail.com>
Message-ID: <alpine.DEB.2.00.1211201641550.6232@chino.kir.corp.google.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org> <20121119162909.GL8218@suse.de> <alpine.DEB.2.00.1211191644340.24618@chino.kir.corp.google.com> <alpine.DEB.2.00.1211191703270.24618@chino.kir.corp.google.com> <20121120060014.GA14065@gmail.com>
 <alpine.DEB.2.00.1211192213420.5498@chino.kir.corp.google.com> <20121120074445.GA14539@gmail.com> <alpine.DEB.2.00.1211200001420.16449@chino.kir.corp.google.com> <20121120090637.GA14873@gmail.com> <20121120094132.GA15156@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andy Lutomirski <luto@amacapital.net>

On Tue, 20 Nov 2012, Ingo Molnar wrote:

> Subject: x86/vsyscall: Add Kconfig option to use native vsyscalls, switch to it
> From: Ingo Molnar <mingo@kernel.org>
> 
> Apparently there's still plenty of systems out there triggering
> the vsyscall emulation page faults - causing hard to track down
> performance regressions on page fault intense workloads...
> 
> Some people seem to have run into that with threading-intense
> Java workloads.
> 
> So until there's a better solution to this, add a Kconfig switch
> to make the vsyscall mode configurable and turn native vsyscall
> support back on by default.
> 
> Distributions whose libraries and applications use the vDSO and never
> access the vsyscall page can change the config option to off.
> 
> Note, I don't think we want to expose the "none" option via a Kconfig
> switch - it breaks the ABI. So it's "native" versus "emulate", with
> "none" being available as a kernel boot option, for the super paranoid.
> 
> For more background, see these upstream commits:
> 
>   3ae36655b97a x86-64: Rework vsyscall emulation and add vsyscall= parameter
>   5cec93c216db x86-64: Emulate legacy vsyscalls
> 
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Ingo Molnar <mingo@kernel.org>

It's slightly better, not sure if it's worth changing everybody's default 
for the small speedup here, though.

THP enabled:

   numa/core at ec05a2311c35:		136918.34 SPECjbb2005 bops
   numa/core at 01aa90068b12:		128315.19 SPECjbb2005 bops (-6.3%)
   numa/core at 01aa90068b12 + patch:	128589.34 SPECjbb2005 bops (-6.1%)

THP disabled:

   numa/core at ec05a2311c35:		122246.90 SPECjbb2005 bops
   numa/core at 01aa90068b12:		 99389.49 SPECjbb2005 bops (-18.7%)
   numa/core at 01aa90068b12 + patch:	100726.34 SPECjbb2005 bops (-17.6%)

perf top w/ THP enabled:

    92.56%  perf-13343.map    [.] 0x00007fd513d2ba7a                        
     1.24%  libjvm.so         [.] instanceKlass::oop_push_contents(PSPromoti
     1.01%  libjvm.so         [.] PSPromotionManager::drain_stacks_depth(boo
     0.77%  libjvm.so         [.] PSPromotionManager::copy_to_survivor_space
     0.57%  libjvm.so         [.] PSPromotionManager::claim_or_forward_inter
     0.26%  libjvm.so         [.] Copy::pd_disjoint_words(HeapWord*, HeapWord*, unsi
     0.22%  libjvm.so         [.] CardTableExtension::scavenge_contents_parallel(Obj
     0.20%  [kernel]          [k] read_tsc                                          
     0.15%  [kernel]          [k] _raw_spin_lock                                    
     0.13%  [kernel]          [k] getnstimeofday                                    
     0.12%  [kernel]          [k] page_fault                                        
     0.11%  [kernel]          [k] generic_smp_call_function_interrupt               
     0.10%  [kernel]          [k] ktime_get                                         
     0.10%  [kernel]          [k] rcu_check_callbacks                               
     0.09%  [kernel]          [k] ktime_get_update_offsets                          
     0.09%  libjvm.so         [.] objArrayKlass::oop_push_contents(PSPromotionManage
     0.08%  [kernel]          [k] flush_tlb_func                                    
     0.07%  [kernel]          [k] system_call                                       
     0.07%  libjvm.so         [.] oopDesc::size_given_klass(Klass*)                 
     0.06%  [kernel]          [k] handle_mm_fault                                   
     0.06%  [kernel]          [k] task_tick_fair                                    
     0.05%  libc-2.3.6.so     [.] __gettimeofday                                    
     0.05%  libjvm.so         [.] os::javaTimeMillis()                              
     0.05%  [kernel]          [k] handle_pte_fault                                  
     0.05%  [kernel]          [k] system_call_after_swapgs                          
     0.04%  [kernel]          [k] mpol_misplaced                                    
     0.04%  [kernel]          [k] __do_page_fault                                   
     0.04%  perf              [.] 0x0000000000035903                                
     0.04%  [kernel]          [k] copy_user_generic_string                          
     0.04%  [kernel]          [k] task_numa_fault                                   
     0.04%  [acpi_cpufreq]    [.] 0x000000005f51a009                                
     0.04%  [kernel]          [k] find_vma                                          
     0.04%  [kernel]          [k] run_timer_softirq                                 
     0.03%  [kernel]          [k] sysret_check                                      
     0.03%  [kernel]          [k] smp_call_function_many                            
     0.03%  [kernel]          [k] update_cfs_shares                                 
     0.02%  [kernel]          [k] do_wp_page                                        
     0.02%  [kernel]          [k] get_vma_policy                                    
     0.02%  [kernel]          [k] update_curr                                       
     0.02%  [kernel]          [k] down_read_trylock                                 
     0.02%  [kernel]          [k] apic_timer_interrupt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
