Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 4722D6B0070
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 04:06:45 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so2681628bkc.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 01:06:43 -0800 (PST)
Date: Tue, 20 Nov 2012 10:06:37 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Message-ID: <20121120090637.GA14873@gmail.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
 <alpine.DEB.2.00.1211191644340.24618@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1211191703270.24618@chino.kir.corp.google.com>
 <20121120060014.GA14065@gmail.com>
 <alpine.DEB.2.00.1211192213420.5498@chino.kir.corp.google.com>
 <20121120074445.GA14539@gmail.com>
 <alpine.DEB.2.00.1211200001420.16449@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211200001420.16449@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* David Rientjes <rientjes@google.com> wrote:

> On Tue, 20 Nov 2012, Ingo Molnar wrote:
> 
> > > This happened to be an Opteron (but not 83xx series), 2.4Ghz.  
> > 
> > Ok - roughly which family/model from /proc/cpuinfo?
> 
> It's close enough, it's 23xx.

Ok - which family/model number in /proc/cpuinfo?

I'm asking because that will matter most to page fault 
micro-characteristics and the 23xx series existed in Barcelona 
form as well (family/model of 16/2) and it still exists in its 
current Shanghai form as well.

My guess is Barcelona 16/2?

If that is correct then the closest I can get to your topology 
is a 4-socket 32-way Opteron system with 32 GB of RAM - which 
seems close enough for testing purposes.

But checking numa/core on such a system still keeps me 
absolutely puzzled, as I get the following with a similar 
16-warehouses SPECjbb 2005 test, using java -Xms8192m -Xmx8192m 
-Xss256k sizing, THP enabled, 2x 240 seconds runs (I tried to 
configure it all very close to yours), using -tip-a07005cbd847:

         kernel             warehouses    transactions/sec
         ---------          ----------
         v3.7-rc6:          16            197802
                            16            197997

         numa/core:         16            203086
                            16            203967

So sadly numa/core is about 2%-3% faster on this 4x4 system too!
:-/

But I have to say, your SPECjbb score is uncharacteristically 
low even for an oddball-topology Barcelona system - which is the 
oldest/slowest system I can think of. So there might be more to 
this.

To further characterise a "good" SPECjbb run, there's no 
page_fault overhead visible in perf top:

Mainline profile:

    94.99%  perf-1244.map     [.] 0x00007f04cd1aa523                 
     2.52%  libjvm.so         [.] 0x00000000007004a1                 
     0.62%  [vdso]            [.] 0x0000000000000972                 
     0.31%  [kernel]          [k] clear_page_c                       
     0.17%  [kernel]          [k] timekeeping_get_ns.constprop.7     
     0.11%  [kernel]          [k] rep_nop                            
     0.09%  [kernel]          [k] ktime_get                          
     0.08%  [kernel]          [k] get_cycles                         
     0.06%  [kernel]          [k] read_tsc                           
     0.05%  libc-2.15.so      [.] __strcmp_sse2                      

numa/core profile:

    95.66%  perf-1201.map     [.] 0x00007fe4ad1c8fc7                 
     1.70%  libjvm.so         [.] 0x0000000000381581                 
     0.59%  [vdso]            [.] 0x0000000000000607                 
     0.19%  [kernel]          [k] do_raw_spin_lock                   
     0.11%  [kernel]          [k] generic_smp_call_function_interrupt
     0.11%  [kernel]          [k] timekeeping_get_ns.constprop.7     
     0.08%  [kernel]          [k] ktime_get                          
     0.06%  [kernel]          [k] get_cycles                         
     0.05%  [kernel]          [k] __native_flush_tlb                 
     0.05%  [kernel]          [k] rep_nop                            
     0.04%  perf              [.] add_hist_entry.isra.9              
     0.04%  [kernel]          [k] rcu_check_callbacks                
     0.04%  [kernel]          [k] ktime_get_update_offsets           
     0.04%  libc-2.15.so      [.] __strcmp_sse2                      

No page fault overhead (see the page fault rate further below) - 
the NUMA scanning overhead shows up only through some mild TLB 
flush activity (which I'll fix btw).

[ Stupid question: cpufreq is configured to always-2.4GHz, 
  right? If you could send me your kernel config (you can do 
  that privately as well) then I can try to boot it and see. ]

> > > It's perf top -U, the benchmark itself was unchanged so I 
> > > didn't think it was interesting to gather the user 
> > > symbols.  If that would be helpful, let me know!
> > 
> > Yeah, regular perf top output would be very helpful to get a 
> > general sense of proportion. Thanks!
> 
> Ok, here it is:
> 
>     91.24%  perf-10971.map    [.] 0x00007f116a6c6fb8                            
>      1.19%  libjvm.so         [.] instanceKlass::oop_push_contents(PSPromotionMa
>      1.04%  libjvm.so         [.] PSPromotionManager::drain_stacks_depth(bool)  
>      0.79%  libjvm.so         [.] PSPromotionManager::copy_to_survivor_space(oop
>      0.60%  libjvm.so         [.] PSPromotionManager::claim_or_forward_internal_
>      0.58%  [kernel]          [k] page_fault                                    
>      0.28%  libc-2.3.6.so     [.] __gettimeofday                                        
>      0.26%  libjvm.so         [.] Copy::pd_disjoint_words(HeapWord*, HeapWord*, unsigned
>      0.22%  [kernel]          [k] getnstimeofday                                        
>      0.18%  libjvm.so         [.] CardTableExtension::scavenge_contents_parallel(ObjectS
>      0.15%  [kernel]          [k] _raw_spin_lock                                        
>      0.12%  [kernel]          [k] ktime_get_update_offsets                              
>      0.11%  [kernel]          [k] ktime_get                                             
>      0.11%  [kernel]          [k] rcu_check_callbacks                                   
>      0.10%  [kernel]          [k] generic_smp_call_function_interrupt                   
>      0.10%  [kernel]          [k] read_tsc                                              
>      0.10%  [kernel]          [k] clear_page_c                                          
>      0.10%  [kernel]          [k] __do_page_fault                                       
>      0.08%  [kernel]          [k] handle_mm_fault                                       
>      0.08%  libjvm.so         [.] os::javaTimeMillis()                                  
>      0.08%  [kernel]          [k] emulate_vsyscall                                      

Oh, finally a clue: you seem to have vsyscall emulation 
overhead!

Vsyscall emulation is fundamentally page fault driven - which 
might explain why you are seeing page fault overhead. It might 
also interact with other sources of faults - such as numa/core's 
working set probing ...

Many JVMs try to be smart with the vsyscall. As a test, does the 
vsyscall=native boot option change the results/behavior in any 
way?

Stupid question, if you apply the patch attached below and if 
you do page fault profiling while the run is in steady state:

   perf record -e faults -g -a sleep 10

do you see it often coming from the vsyscall page?

Also, this:

   perf stat -e faults -a --repeat 10 sleep 1

should normally report something like this during SPECjbb steady 
state, numa/core:

          warmup:   3,895 faults/sec                ( +- 12.11% )
    steady state:   3,910 faults/sec                ( +-  6.72% )

Which is about 250 faults/sec/CPU - i.e. it should be barely 
recognizable in profiles - let alone be prominent as in yours.

Thanks,

	Ingo

---
 arch/x86/mm/fault.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux/arch/x86/mm/fault.c
===================================================================
--- linux.orig/arch/x86/mm/fault.c
+++ linux/arch/x86/mm/fault.c
@@ -1030,6 +1030,9 @@ __do_page_fault(struct pt_regs *regs, un
 	/* Get the faulting address: */
 	address = read_cr2();
 
+	/* Instrument as early as possible: */
+	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
+
 	/*
 	 * Detect and handle instructions that would cause a page fault for
 	 * both a tracked kernel page and a userspace page.
@@ -1107,8 +1110,6 @@ __do_page_fault(struct pt_regs *regs, un
 		}
 	}
 
-	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
-
 	/*
 	 * If we're in an interrupt, have no user context or are running
 	 * in an atomic region then we must not take the fault:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
