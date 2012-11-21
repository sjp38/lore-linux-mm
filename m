Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id C30BF6B0062
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 06:47:34 -0500 (EST)
Date: Wed, 21 Nov 2012 11:47:28 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] x86/mm: Don't flush the TLB on #WP pmd fixups
Message-ID: <20121121114728.GZ8218@suse.de>
References: <20121119162909.GL8218@suse.de>
 <alpine.DEB.2.00.1211191644340.24618@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1211191703270.24618@chino.kir.corp.google.com>
 <20121120060014.GA14065@gmail.com>
 <alpine.DEB.2.00.1211192213420.5498@chino.kir.corp.google.com>
 <20121120074445.GA14539@gmail.com>
 <alpine.DEB.2.00.1211200001420.16449@chino.kir.corp.google.com>
 <20121120090637.GA14873@gmail.com>
 <20121120120251.GA15742@gmail.com>
 <20121120123156.GA15798@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121120123156.GA15798@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Tue, Nov 20, 2012 at 01:31:56PM +0100, Ingo Molnar wrote:
> 
> * Ingo Molnar <mingo@kernel.org> wrote:
> 
> > * Ingo Molnar <mingo@kernel.org> wrote:
> > 
> > > numa/core profile:
> > > 
> > >     95.66%  perf-1201.map     [.] 0x00007fe4ad1c8fc7                 
> > >      1.70%  libjvm.so         [.] 0x0000000000381581                 
> > >      0.59%  [vdso]            [.] 0x0000000000000607                 
> > >      0.19%  [kernel]          [k] do_raw_spin_lock                   
> > >      0.11%  [kernel]          [k] generic_smp_call_function_interrupt
> > >      0.11%  [kernel]          [k] timekeeping_get_ns.constprop.7     
> > >      0.08%  [kernel]          [k] ktime_get                          
> > >      0.06%  [kernel]          [k] get_cycles                         
> > >      0.05%  [kernel]          [k] __native_flush_tlb                 
> > >      0.05%  [kernel]          [k] rep_nop                            
> > >      0.04%  perf              [.] add_hist_entry.isra.9              
> > >      0.04%  [kernel]          [k] rcu_check_callbacks                
> > >      0.04%  [kernel]          [k] ktime_get_update_offsets           
> > >      0.04%  libc-2.15.so      [.] __strcmp_sse2                      
> > > 
> > > No page fault overhead (see the page fault rate further below) 
> > > - the NUMA scanning overhead shows up only through some mild 
> > > TLB flush activity (which I'll fix btw).
> > 
> > The patch attached below should get rid of that mild TLB 
> > flushing activity as well.
> 
> This has further increased SPECjbb from 203k/sec to 207k/sec, 
> i.e. it's now 5% faster than mainline - THP enabled.
> 
> The profile is now totally flat even during a full 32-WH SPECjbb 
> run, with the highest overhead entries left all related to timer 
> IRQ processing or profiling. That is on a system that should be 
> very close to yours.
> 

This is a stab in the dark but are you always running with profiling enabled?

I have not checked this with perf but a number of years ago I found that
oprofile could distort results really badly (7-30% depending on the workload
at the time) when I was evalating hugetlbfs and THP. In some cases I would
find that profiling would show that a patch series improved performance
when the same series showed regressions if profiling was disabled. The
sampling rate had to be reduced quite a bit to avoid this effect.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
