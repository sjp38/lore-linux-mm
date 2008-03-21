Date: Fri, 21 Mar 2008 09:39:52 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [11/14] vcompound: Fallbacks for order 1 stack allocations on
	IA64 and x86
Message-ID: <20080321083952.GA20454@elte.hu>
References: <20080321061703.921169367@sgi.com> <20080321061726.782068299@sgi.com> <20080321.002502.223136918.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080321.002502.223136918.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

* David Miller <davem@davemloft.net> wrote:

> From: Christoph Lameter <clameter@sgi.com>
> Date: Thu, 20 Mar 2008 23:17:14 -0700
> 
> > This allows fallback for order 1 stack allocations. In the fallback
> > scenario the stacks will be virtually mapped.
> > 
> > Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> I would be very careful with this especially on IA64.
> 
> If the TLB miss or other low-level trap handler depends upon being 
> able to dereference thread info, task struct, or kernel stack stuff 
> without causing a fault outside of the linear PAGE_OFFSET area, this 
> patch will cause problems.
> 
> It will be difficult to debug the kinds of crashes this will cause 
> too. [...]

another thing is that this patchset includes KERNEL_STACK_SIZE_ORDER 
which has been NACK-ed before on x86 by several people and i'm nacking 
this "configurable stack size" aspect of it again.

although it's not being spelled out in the changelog, i believe the 
fundamental problem comes from a cpumask_t taking 512 bytes with 
nr_cpus=4096, and if a few of them are on the kernel stack it can be a 
problem. The correct answer is to not put them on the stack and we've 
been taking patches to that end. Every other object allocator in the 
kernel is able to not put stuff on the kernel stack. We _dont_ want 
higher-order kernel stacks and we dont want to make a special exception 
for cpumask_t either.

i believe time might be better spent increasing PAGE_SIZE on these 
ridiculously large systems and making that work well with our binary 
formats - instead of complicating our kernel VM with virtually mapped 
buffers. That will also solve the kernel stack problem, in a very 
natural way.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
