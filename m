Date: Fri, 29 Feb 2008 22:48:00 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080229214800.GD8091@v2.random>
References: <20080228011020.GG8091@v2.random> <Pine.LNX.4.64.0802281043430.29191@schroedinger.engr.sgi.com> <20080229005530.GO8091@v2.random> <Pine.LNX.4.64.0802281658560.1954@schroedinger.engr.sgi.com> <20080229131302.GT8091@v2.random> <Pine.LNX.4.64.0802291149290.11292@schroedinger.engr.sgi.com> <20080229201744.GB8091@v2.random> <Pine.LNX.4.64.0802291301530.11889@schroedinger.engr.sgi.com> <20080229212327.GC8091@v2.random> <Pine.LNX.4.64.0802291329250.13402@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802291329250.13402@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, Feb 29, 2008 at 01:34:34PM -0800, Christoph Lameter wrote:
> On Fri, 29 Feb 2008, Andrea Arcangeli wrote:
> 
> > On Fri, Feb 29, 2008 at 01:03:16PM -0800, Christoph Lameter wrote:
> > > That means we need both the anon_vma locks and the i_mmap_lock to become 
> > > semaphores. I think semaphores are better than mutexes. Rik and Lee saw 
> > > some performance improvements because list can be traversed in parallel 
> > > when the anon_vma lock is switched to be a rw lock.
> > 
> > The improvement was with a rw spinlock IIRC, so I don't see how it's
> > related to this.
> 
> AFAICT The rw semaphore fastpath is similar in performance to a rw 
> spinlock. 

read side is taken in the slow path.

write side is taken in the fast path.

pagefault is fast path, VM during swapping is slow path.

> > Perhaps the rwlock spinlock can be changed to a rw semaphore without
> > measurable overscheduling in the fast path. However theoretically
> 
> Overscheduling? You mean overhead?

The only possible overhead that a rw semaphore could ever generate vs
a rw lock is overscheduling.

> > speaking the rw_lock spinlock is more efficient than a rw semaphore in
> > case of a little contention during the page fault fast path because
> > the critical section is just a list_add so it'd be overkill to
> > schedule while waiting. That's why currently it's a spinlock (or rw
> > spinlock).
> 
> On the other hand a semaphore puts the process to sleep and may actually 
> improve performance because there is less time spend in a busy loop. 
> Other processes may do something useful and we stay off the contended 
> cacheline reducing traffic on the interconnect.

Yes, that's the positive side, the negative side is that you'll put
the task in uninterruptible sleep and call schedule() and require a
wakeup, because a list_add taking <1usec is running in the
other cpu. No other downside. But that's the only reason it's a
spinlock right now, infact there can't be any other reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
