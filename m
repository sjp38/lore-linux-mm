Date: Fri, 3 Aug 2007 05:14:26 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] balance-on-fork NUMA placement
Message-ID: <20070803031426.GA28310@wotan.suse.de>
References: <200707311114.09284.ak@suse.de> <Pine.LNX.4.64.0707311639450.31337@schroedinger.engr.sgi.com> <20070802034201.GA32631@wotan.suse.de> <Pine.LNX.4.64.0708021254160.8527@schroedinger.engr.sgi.com> <20070803002639.GC14775@wotan.suse.de> <Pine.LNX.4.64.0708021748110.13312@schroedinger.engr.sgi.com> <20070803005700.GD14775@wotan.suse.de> <Pine.LNX.4.64.0708021801010.13312@schroedinger.engr.sgi.com> <20070803011448.GF14775@wotan.suse.de> <Pine.LNX.4.64.0708021827280.13538@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708021827280.13538@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 02, 2007 at 06:34:04PM -0700, Christoph Lameter wrote:
> On Fri, 3 Aug 2007, Nick Piggin wrote:
> 
> > Yeah it only gets set if the parent is initially using a default policy
> > at this stage (and then is restored afterwards of course).
> 
> Uggh. Looks like more hackery ahead. I think this cannot be done in the 
> desired clean way until we have some revving of the memory policy 
> subsystem that makes policies task context independent so that you can do

Well what's wrong with it? It seems to use memory policies for exactly
what they are intended (aside from it being kernel directed...).


> alloc_pages(...., memory_policy)

That still doesn't completely help because again it would require modifying
call sites (at which point I could just do alloc_pages_node).


> The cleanest solution that I can think of at this point is certainly to 
> switch to another processor and do the allocation and copying actions from 
> there. We have the migration process context right? Can that be used to 
> start the new thread and can the original processor wait on some flag 
> until that is complete?

I guess you could, but that is going to add a context switch to fork
(although it usually already has one in single-CPU situation because we
run child first)... I bet it will slow something down, but it would be
interesting to see.

I don't know the fork path well enough off the top of my head to know if
it will be that simple (with error handling etc). But I think it could
be done.


> Forking off from there not only places the data correctly but it also 
> warms up the caches for the new process and avoids evicting cacheline on 
> the original processor.

Yeah, you might be right there. If the numbers say that approach is
better, then I'd not be against it. But we'd still need the simpler
mpol approach to compare it with. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
