Date: Thu, 8 May 2008 00:22:05 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080507222205.GC8276@duo.random>
References: <6b384bb988786aa78ef0.1210170958@duo.random> <alpine.LFD.1.10.0805071349200.3024@woody.linux-foundation.org> <20080507212650.GA8276@duo.random> <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2008 at 02:36:57PM -0700, Linus Torvalds wrote:
> > had to do any blocking I/O during vmtruncate before, now we have to.
> 
> I really suspect we don't really have to, and that it would be better to 
> just fix the code that does that.

I'll let you discuss with Christoph and Robin about it. The moment I
heard the schedule inside ->invalidate_page() requirement I reacted
the same way you did. But I don't see any other real solution for XPMEM
other than spin-looping for ages halting the scheduler for ages, while
the ack is received from the network device.

But mm_lock is required even without XPMEM. And srcu is also required
without XPMEM to allow ->release to schedule (however downgrading srcu
to rcu will result in a very small patch, srcu and rcu are about the
same with a kernel supporting preempt=y like 2.6.26).

> I literally think that mm_lock() is an unbelievable piece of utter and 
> horrible CRAP.
> 
> There's simply no excuse for code like that.

I think it's a great smp scalability optimization over the global lock
you're proposing below.

> No, the simple solution is to just make up a whole new upper-level lock, 
> and get that lock *first*. You can then take all the multiple locks at a 
> lower level in any order you damn well please. 

Unfortunately the lock you're talking about would be:

static spinlock_t global_lock = ...

There's no way to make it more granular.

So every time before taking any ->i_mmap_lock _and_ any anon_vma->lock
we'd need to take that extremely wide spinlock first (and even worse,
later it would become a rwsem when XPMEM is selected making the VM
even slower than it already becomes when XPMEM support is selected at
compile time).

> And yes, it's one more lock, and yes, it serializes stuff, but:
> 
>  - that code had better not be critical anyway, because if it was, then 
>    the whole "vmalloc+sort+lock+vunmap" sh*t was wrong _anyway_

mmu_notifier_register can take ages. No problem.

>  - parallelism is overrated: it doesn't matter one effing _whit_ if 
>    something is a hundred times more parallel, if it's also a hundred 
>    times *SLOWER*.

mmu_notifier_register is fine to be hundred times slower (preempt-rt
will turn all locks in spinlocks so no problem).

> And here's an admission that I lied: it wasn't *all* clearly crap. I did 
> like one part, namely list_del_init_rcu(), but that one should have been 
> in a separate patch. I'll happily apply that one.

Sure, I'll split it from the rest if the mmu-notifier-core isn't merged.

My objective has been:

1) add zero overhead to the VM before anybody starts a VM with kvm and
   still zero overhead for all other tasks except the task where the
   VM runs.  The only exception is the unlikely(!mm->mmu_notifier_mm)
   check that is optimized away too when CONFIG_KVM=n. And even for
   that check my invalidate_page reduces the number of branches to the
   absolute minimum possible.

2) avoid any new cacheline collision in the fast paths to allow numa
   systems not to nearly-crash (mm->mmu_notifier_mm will be shared and
   never written, except during the first mmu_notifier_register)

3) avoid any risk to introduce regressions in 2.6.26 (the patch must
   be obviously safe). Even if mm_lock would be a bad idea like you
   say, it's order of magnitude safer even if entirely broken then
   messing with the VM core locking in 2.6.26.

mm_lock (or whatever name you like to give it, I admit mm_lock may not
be worrysome enough for people to have an idea to call it in a fast
path) is going to be the real deal for the long term to allow
mmu_notifier_register to serialize against
invalidate_page_start/end. If I fail in 2.6.26 I'll offer
maintainership to Christoph as promised, and you'll find him pushing
for mm_lock to be merged (as XPMEM/GRU aren't technologies running on
cellphones where your global wide spinlocks is optimized away at
compile time, and he also has to deal with XPMEM where such a spinlock
would need to become a rwsem as the anon_vma->sem has to be taken
after it), but let's assume you're right entirely right here that
mm_lock is going to be dropped and there's a better way: it's still a
fine solution for 2.6.26.

And if you prefer I can move the whole mm_lock() from mmap.c/mm.h to
mmu_notifier.[ch] so you don't get any pollution in the core VM, and
mm_lock will be invisible to everything but anybody calling
mmu_notifier_register() then and it will be trivial to remove later if
you really want to add a global spinlock as there's no way to be more
granular than a _global_ numa-wide spinlock taken before any
i_mmap_lock/anon_vma->lock, without my mm_lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
