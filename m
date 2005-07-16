Date: Sat, 16 Jul 2005 15:39:01 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [NUMA] Display and modify the memory policy of a process
 through /proc/<pid>/numa_policy
Message-Id: <20050716153901.3082f1d8.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.62.0507160808570.21470@schroedinger.engr.sgi.com>
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
	<Pine.LNX.4.62.0507160808570.21470@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: ak@suse.de, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph wrote:
> We can number the vma's if that makes you feel better and refer to the 
> number of the vma.

I really doubt you want to go down that path.

VMA's are a kernel internel detail.  They can come and go, be merged
and split, in the dark of the night, transparent to user space.

One might argue that virtual address ranges (rather than VMAs) are
appropriate to be manipulated from outside the task, on the other
side of the position that Andi takes.  Not that I am arguing such --
Andi is making stronger points against such than I am able to refute.

But VMA's are not really visible, except via diagnostic displays
(and Andi makes a good case against even those) to user space; not
even the VMA's within one's own task.

No, I don't think you want to consider numbering VMA's for the purposes
of manipulating them.

===

My intuition is that we are seeing a clash of computing models here.

Main memory is becoming hundreds, even thousands, of times slower
than internal CPU operations.  And main memory is, under the rubric
"NUMA", becoming no longer a monolithic resource on larger systems.
Within a few years, high end workstations will join the ranks of
NUMA systems, just as they have already joined the ranks of SMP
systems.

What was once the private business of each individual task, it's
address space and the placement of its memory, is now becoming the
proper business of system wide administration.  This is because memory
placement can have substantial affects on system and job performance.

We see a variation of this clash on issues of how the kernel should
consume and place its internal memory for caches, buffers and such.
What used to be the private business of the kernel, guided by the
rule that it is best to consume almost all available memory to
cache something, is becoming a system problem, as it can be counter
productive on NUMA systems.

Folks like SGI, on the high end of big honkin NUMA iron, are seeing
it first.  As system architectures become more complex, and scaled
down NUMA architectures become in more widespread use, others will
see it as well, though with no doubt different tradeoffs and ordering
of requirements than SGI and its competitors notice currently.

However, I would presume that Andi is entirely correct, and that
the architecture of the kernel does not allow one task safely to
manipulate another's address space or memory placement there under,
at least not in a way that us mere mortals can understand.

A rock and a hard place.

Just brainstorming ... if one could load a kernel module that could
be called in the context of a target task, either when it is returning
from kernel space or was entering or leaving a timer/resched interrupt
taken while in user space, where that module could, if it was so
coded, munge the tasks memory placement, then would this provide a
basis for solutions to some of these problems?

I am presuming that the hooks for such a module, given it was under
GPL license, would be modest, and of minimum burden to the great
majority of systems that had no such need.

In short, when memory management and placement has such a dominant
impact on overall system performance, it cannot remain solely the
private business of each application.  We need to look for a safe and
simple means to enable external (from outside the task) management
of a tasks memory, without requiring massive surgery on a large body
of critical code that is (quite properly) not designed to handle such.

And we have to co-exist with the folks pushing Linux in the other
direction, embedded in wrist watches or whatever.  Those folks will
properly refuse to waste any non-trivial number brain or CPU cycles
on NUMA requirements.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
