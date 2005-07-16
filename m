Date: Sat, 16 Jul 2005 16:30:30 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [NUMA] Display and modify the memory policy of a process
 through /proc/<pid>/numa_policy
Message-Id: <20050716163030.0147b6ba.pj@sgi.com>
In-Reply-To: <20050716020141.GO15783@wotan.suse.de>
References: <20050715214700.GJ15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com>
	<20050715220753.GK15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com>
	<20050715223756.GL15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com>
	<20050715225635.GM15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151602390.12530@schroedinger.engr.sgi.com>
	<20050715234402.GN15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151647300.12832@schroedinger.engr.sgi.com>
	<20050716020141.GO15783@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: clameter@engr.sgi.com, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andi wrote:
> I think the per VMA approach is fundamentally wrong because
> virtual addresses are nothing an external user can safely
> access.

Earlier, he also wrote:
> In short blocks of memory are useless here because they have no 
> relationship to what the code actually does. 

There are two questions here - should we and can we.

One the one hand, I hear Andi saying we should not want to alter the
placement of pages allocated to an external task at such a fine level
of granularity.

On the other hand, I hear him saying we can't do it, because the
locking cannot be safely handled.

There is also one confusion that I sometimes succumb to, reading these
replies - between memory policies to control future allocations and
memory policies to relocate already allocated memory.

I think between the numa calls (mbind, set_mempolicy) and cpusets,
we have a decent array of mechanisms to control future allocations.
The full set of features required may not be complete, but the
framework seems to be in place, and the majority of what features we
will need are supported now.

We are lacking in sufficient means to relocate already allocated
user memory.

I'd disagree with Andi that we should not support rearranging memory
at a fine granularity.  For most systems and most applications, Andi
is no doubt right.  But for some systems and some applications, such
as big long running tightly parallel applications on NUMA systems,
placement is often well understood and closely managed at a fine
granularity, because algorithm and memory placement closely interact,
and can have a huge impact on performance.

I willingly bow to Andi's expertise when he says we can't do it now
because memory structures and placement cannot be safely modified
from outside a task.

But I don't agree that we shouldn't look for a way to do it.

We need a way to safely rearrange the placement of already allocated
user memory pages, at a fine granularity (per physical page), without
significant impact to the main body of kernel memory management code.

I think that must mean code operating within the context of the target
task.  I suspect that means at least a portion of this code must be
operating within kernel space.  It should enable external, system
administrator imposed, per-page relocation of already allocated memory.

In some cases, the details of the code that decide what page should
go where will be very specific to a situation, and belong in user
space, or at most, a loadable kernel module, certainly not in main
line kernel code.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
