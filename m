Date: Thu, 2 Aug 2007 22:47:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] balance-on-fork NUMA placement
In-Reply-To: <20070803031426.GA28310@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0708022234130.14362@schroedinger.engr.sgi.com>
References: <200707311114.09284.ak@suse.de> <Pine.LNX.4.64.0707311639450.31337@schroedinger.engr.sgi.com>
 <20070802034201.GA32631@wotan.suse.de> <Pine.LNX.4.64.0708021254160.8527@schroedinger.engr.sgi.com>
 <20070803002639.GC14775@wotan.suse.de> <Pine.LNX.4.64.0708021748110.13312@schroedinger.engr.sgi.com>
 <20070803005700.GD14775@wotan.suse.de> <Pine.LNX.4.64.0708021801010.13312@schroedinger.engr.sgi.com>
 <20070803011448.GF14775@wotan.suse.de> <Pine.LNX.4.64.0708021827280.13538@schroedinger.engr.sgi.com>
 <20070803031426.GA28310@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Aug 2007, Nick Piggin wrote:

> Well what's wrong with it? It seems to use memory policies for exactly
> what they are intended (aside from it being kernel directed...).

Sure I think you could do it with some effort. They were primarily 
designed for user space. Lots of little side issues where surprises await 
you. I think Lee documented many of them. See the recent mm commits.

> > start the new thread and can the original processor wait on some flag 
> > until that is complete?
> 
> I guess you could, but that is going to add a context switch to fork
> (although it usually already has one in single-CPU situation because we
> run child first)... I bet it will slow something down, but it would be
> interesting to see.

The context switch is needed at some point anyways to get the new process 
running on the new CPU? Just do it before allocating structures. That way 
the potential memory policy and cpuset context is preserved and followed.

> I don't know the fork path well enough off the top of my head to know if
> it will be that simple (with error handling etc). But I think it could
> be done.

I would think that the forking process has to wait on completion anyways
and get an error code.

> > Forking off from there not only places the data correctly but it also 
> > warms up the caches for the new process and avoids evicting cacheline on 
> > the original processor.
> 
> Yeah, you might be right there. If the numbers say that approach is
> better, then I'd not be against it. But we'd still need the simpler
> mpol approach to compare it with. 

Lets hope that the simpler process is really simpler after all the corner 
cases have been dealt with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
