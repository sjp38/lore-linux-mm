Date: Fri, 29 Feb 2008 14:12:57 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
In-Reply-To: <20080229214800.GD8091@v2.random>
Message-ID: <Pine.LNX.4.64.0802291408520.14224@schroedinger.engr.sgi.com>
References: <20080228011020.GG8091@v2.random>
 <Pine.LNX.4.64.0802281043430.29191@schroedinger.engr.sgi.com>
 <20080229005530.GO8091@v2.random> <Pine.LNX.4.64.0802281658560.1954@schroedinger.engr.sgi.com>
 <20080229131302.GT8091@v2.random> <Pine.LNX.4.64.0802291149290.11292@schroedinger.engr.sgi.com>
 <20080229201744.GB8091@v2.random> <Pine.LNX.4.64.0802291301530.11889@schroedinger.engr.sgi.com>
 <20080229212327.GC8091@v2.random> <Pine.LNX.4.64.0802291329250.13402@schroedinger.engr.sgi.com>
 <20080229214800.GD8091@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 29 Feb 2008, Andrea Arcangeli wrote:

> > AFAICT The rw semaphore fastpath is similar in performance to a rw 
> > spinlock. 
> 
> read side is taken in the slow path.

Slowpath meaning VM slowpath or lock slow path? Its seems that the rwsem 
read side path is pretty efficient:

static inline void __down_read(struct rw_semaphore *sem)
{
        __asm__ __volatile__(
                "# beginning down_read\n\t"
LOCK_PREFIX     "  incl      (%%eax)\n\t" /* adds 0x00000001, returns the old value */
                "  jns        1f\n"
                "  call call_rwsem_down_read_failed\n"
                "1:\n\t"
                "# ending down_read\n\t"
                : "+m" (sem->count)
                : "a" (sem)
                : "memory", "cc");
}



> 
> write side is taken in the fast path.
> 
> pagefault is fast path, VM during swapping is slow path.

Not sure what you are saying here. A pagefault should be considered as a 
fast path and swapping is not performance critical?

> > > Perhaps the rwlock spinlock can be changed to a rw semaphore without
> > > measurable overscheduling in the fast path. However theoretically
> > 
> > Overscheduling? You mean overhead?
> 
> The only possible overhead that a rw semaphore could ever generate vs
> a rw lock is overscheduling.

Ok too many calls to schedule() because the slow path (of the semaphore) 
is taken?

> > On the other hand a semaphore puts the process to sleep and may actually 
> > improve performance because there is less time spend in a busy loop. 
> > Other processes may do something useful and we stay off the contended 
> > cacheline reducing traffic on the interconnect.
> 
> Yes, that's the positive side, the negative side is that you'll put
> the task in uninterruptible sleep and call schedule() and require a
> wakeup, because a list_add taking <1usec is running in the
> other cpu. No other downside. But that's the only reason it's a
> spinlock right now, infact there can't be any other reason.

But that is only happening for the contended case. Certainly a spinlock is 
better for 2p system but the more processors content for the lock (and 
the longer the hold off is, typical for the processors with 4p or 8p or 
more) the better a semaphore will work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
