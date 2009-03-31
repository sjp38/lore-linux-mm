Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 326B26B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 16:28:14 -0400 (EDT)
Date: Tue, 31 Mar 2009 22:30:14 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Detailed Stack Information Patch [0/3]
Message-ID: <20090331203014.GR11935@one.firstfloor.org>
References: <1238511498.364.60.camel@matrix> <87eiwdn15a.fsf@basil.nowhere.org> <1238523735.3692.30.camel@matrix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1238523735.3692.30.camel@matrix>
Sender: owner-linux-mm@kvack.org
To: Stefani Seibold <stefani@seibold.net>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, Joerg Engel <joern@logfs.org>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 31, 2009 at 08:22:15PM +0200, Stefani Seibold wrote:
> Hi Andi,
> 
> Am Dienstag, den 31.03.2009, 17:49 +0200 schrieb Andi Kleen:
> > Stefani Seibold <stefani@seibold.net> writes:
> > >
> > > - Get out of virtual memory by creating a lot of threads
> > >  (f.e. the developer did assign each of them the default size)
> > 
> > The application just fails then? I don't think that needs
> > a new monitoring tool.
> > 
> 
> First, this patch is not only a monitoring tool. Only the last part 3/3
> is the monitoring tool.
> 
> Patch 1/3 enhance the the proc/<pid>/task/<tid>/maps by the marking the
> thread stack.

Well some implementation of it. There are certainly runtimes that
switch stacks. For example what happens when someone uses sigaltstack()?

You'll probably need some more sanity checks, otherwise a monitor
will occasionally just report crap in legitimate cases. Unfortunately
it's difficult to distingush the legitimate cases from the bugs.

> > > - Misuse the thread stack for big temporary data buffers
> > 
> > That would be better checked for at compile time
> > (except for alloca, but that is quite rare)
> 
> Fine but it did not work for functions like:

That's the alloca() case, but you can disable both with the right options.
There's still the "recursive function" case.

> > > - Thread stack overruns
> > 
> > Your method would be racy at best to determine this because
> > you don't keep track of the worst case, only the current case.
> > 
> > So e.g. if you monitoring app checks once per second the stack
> > could overflow between your monitoring intervals, but already
> > have bounced back before the checker comes in.
> > 
> 
> The Monitor is part 3/3. And you are right it is not a complete rock
> solid solution. But it works in many cases and thats is what counts.

For stack overflow one would think a rock solid solution
is needed?  After all you'll crash if you miss a case.

> > track of consumption in the VMA that has the stack,  but
> > that can't handle very large jumps (like f() { char x[1<<30]; } )
> > The later can only be handled well by the compiler.
> 
> Thats is exactly what i am doing, i walk through the pages of the thread
> stack mapped memory and keep track of the highest access page. So i have
> the high water mark of the used stack.

Ok. Of course it doesn't work for really large allocations. there used
to be special patches around to add a special gap to catch those,
but it's problematic with the tight address space on 32bit and also
again not fully bullet proof. On 64bit the solution is typical
to just use a large stack.

> The patches are not intrusive, especially part 1.

To be honest it seems too much like a special case hack to me
to include by default. It could be probably done with a systemtap
script in the same way, but I would really recommend to just
build with gcc's stack overflow checker while testing together
with static checking.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
