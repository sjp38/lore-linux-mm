Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4EDQ5d5007666
	for <linux-mm@kvack.org>; Wed, 14 May 2008 09:26:05 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4EDQ5wq106470
	for <linux-mm@kvack.org>; Wed, 14 May 2008 07:26:05 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4EDQ5JH012436
	for <linux-mm@kvack.org>; Wed, 14 May 2008 07:26:05 -0600
Date: Wed, 14 May 2008 06:26:04 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [patch 1/2] read_barrier_depends arch fixlets
Message-ID: <20080514132604.GA8812@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20080505112021.GC5018@wotan.suse.de> <20080505121240.GD5018@wotan.suse.de> <alpine.LFD.1.10.0805050828120.32269@woody.linux-foundation.org> <20080506095138.GE10141@wotan.suse.de> <alpine.LFD.1.10.0805060750430.32269@woody.linux-foundation.org> <20080513080143.GB19870@wotan.suse.de> <alpine.LFD.1.10.0805130844000.3019@woody.linux-foundation.org> <20080514003417.GA24516@wotan.suse.de> <alpine.LFD.1.10.0805131753150.3019@woody.linux-foundation.org> <20080514043511.GD23578@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080514043511.GD23578@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 14, 2008 at 06:35:11AM +0200, Nick Piggin wrote:
> read_barrie_depends has always been a noop (not a compiler barrier) on all
> architectures except SMP alpha. This brings UP alpha and frv into line with all
> other architectures, and fixes incorrect documentation.

One update for the documentation update.

							Thanx, Paul

> Signed-off-by: Nick Piggin <npiggin@suse.de>
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> ---
>  Documentation/memory-barriers.txt |   12 +++++++++++-
>  include/asm-alpha/barrier.h       |    2 +-
>  include/asm-frv/system.h          |    2 +-
>  3 files changed, 13 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6/include/asm-alpha/barrier.h
> ===================================================================
> --- linux-2.6.orig/include/asm-alpha/barrier.h
> +++ linux-2.6/include/asm-alpha/barrier.h
> @@ -24,7 +24,7 @@ __asm__ __volatile__("mb": : :"memory")
>  #define smp_mb()	barrier()
>  #define smp_rmb()	barrier()
>  #define smp_wmb()	barrier()
> -#define smp_read_barrier_depends()	barrier()
> +#define smp_read_barrier_depends()	do { } while (0)
>  #endif
> 
>  #define set_mb(var, value) \
> Index: linux-2.6/include/asm-frv/system.h
> ===================================================================
> --- linux-2.6.orig/include/asm-frv/system.h
> +++ linux-2.6/include/asm-frv/system.h
> @@ -179,7 +179,7 @@ do {							\
>  #define mb()			asm volatile ("membar" : : :"memory")
>  #define rmb()			asm volatile ("membar" : : :"memory")
>  #define wmb()			asm volatile ("membar" : : :"memory")
> -#define read_barrier_depends()	barrier()
> +#define read_barrier_depends()	do { } while (0)
> 
>  #ifdef CONFIG_SMP
>  #define smp_mb()			mb()
> Index: linux-2.6/Documentation/memory-barriers.txt
> ===================================================================
> --- linux-2.6.orig/Documentation/memory-barriers.txt
> +++ linux-2.6/Documentation/memory-barriers.txt
> @@ -994,7 +994,17 @@ The Linux kernel has eight basic CPU mem
>  	DATA DEPENDENCY	read_barrier_depends()	smp_read_barrier_depends()
> 
> 
> -All CPU memory barriers unconditionally imply compiler barriers.
> +All memory barriers except the data dependency barriers imply a compiler
> +barrier. Data dependencies do not impose any additional compiler ordering.
> +
> +Aside: In the case of data dependencies, the compiler would be expected to
> +issue the loads in the correct order (eg. `a[b]` would have to load the value
> +of b before loading a[b]), however there is no guarantee in the C specification
> +that the compiler may not speculate the value of b (eg. is equal to 1) and load
> +a before b (eg. tmp = a[1]; if (b != 1) tmp = a[b]; ). There is also the
> +problem of a compiler reloading b after having loaded a[b], thus having a newer
> +copy of b than a[b]. A consensus has not yet been reached about these problems,
> +however the ACCESS_ONCE macro is a good place to start looking.

Please add something like:

"For example, b_local = b; smp_read_barrier_depends(); tmp = a[b_local];"

>  SMP memory barriers are reduced to compiler barriers on uniprocessor compiled
>  systems because it is assumed that a CPU will appear to be self-consistent,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
