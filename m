Date: Thu, 15 May 2008 06:01:48 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080515110147.GD10126@sgi.com>
References: <6b384bb988786aa78ef0.1210170958@duo.random> <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org> <20080508003838.GA9878@sgi.com> <200805132206.47655.nickpiggin@yahoo.com.au> <20080513153238.GL19717@sgi.com> <20080514041122.GE24516@wotan.suse.de> <20080514112625.GY9878@sgi.com> <20080515075747.GA7177@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080515075747.GA7177@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Robin Holt <holt@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <andrea@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

We are pursuing Linus' suggestion currently.  This discussion is
completely unrelated to that work.

On Thu, May 15, 2008 at 09:57:47AM +0200, Nick Piggin wrote:
> I'm not sure if you're thinking about what I'm thinking of. With the
> scheme I'm imagining, all you will need is some way to raise an IPI-like
> interrupt on the target domain. The IPI target will have a driver to
> handle the interrupt, which will determine the mm and virtual addresses
> which are to be invalidated, and will then tear down those page tables
> and issue hardware TLB flushes within its domain. On the Linux side,
> I don't see why this can't be done.

We would need to deposit the payload into a central location to do the
invalidate, correct?  That central location would either need to be
indexed by physical cpuid (65536 possible currently, UV will push that
up much higher) or some sort of global id which is difficult because
remote partitions can reboot giving you a different view of the machine
and running partitions would need to be updated.  Alternatively, that
central location would need to be protected by a global lock or atomic
type operation, but a majority of the machine does not have coherent
access to other partitions so they would need to use uncached operations.
Essentially, take away from this paragraph that it is going to be really
slow or really large.

Then we need to deposit the information needed to do the invalidate.

Lastly, we would need to interrupt.  Unfortunately, here we have a
thundering herd.  There could be up to 16256 processors interrupting the
same processor.  That will be a lot of work.  It will need to look up the
mm (without grabbing any sleeping locks in either xpmem or the kernel)
and do the tlb invalidates.

Unfortunately, the sending side is not free to continue (in most cases)
until it knows that the invalidate is completed.  So it will need to spin
waiting for a completion signal will could be as simple as an uncached
word.  But how will it handle the possible failure of the other partition?
How will it detect that failure and recover?  A timeout value could be
difficult to gauge because the other side may be off doing a considerable
amount of work and may just be backed up.

> Sure, you obviously would need to rework your code because it's been
> written with the assumption that it can sleep.

It is an assumption based upon some of the kernel functions we call
doing things like grabbing mutexes or rw_sems.  That pushes back to us.
I think the kernel's locking is perfectly reasonable.  The problem we run
into is we are trying to get from one context in one kernel to a different
context in another and the in-between piece needs to be sleepable.

> What is XPMEM exactly anyway? I'd assumed it is a Linux driver.

XPMEM allows one process to make a portion of its virtual address range
directly addressable by another process with the appropriate access.
The other process can be on other partitions.  As long as Numa-link
allows access to the memory, we can make it available.  Userland has an
advantage in that the kernel entrance/exit code contains memory errors
so we can contain hardware failures (in most cases) to only needing to
terminate a user program and not lose the partition.  The kernel enjoys
no such fault containment so it can not safely directly reference memory.


Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
