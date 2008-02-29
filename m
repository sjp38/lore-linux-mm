Date: Fri, 29 Feb 2008 23:41:44 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080229224144.GE8091@v2.random>
References: <20080229005530.GO8091@v2.random> <Pine.LNX.4.64.0802281658560.1954@schroedinger.engr.sgi.com> <20080229131302.GT8091@v2.random> <Pine.LNX.4.64.0802291149290.11292@schroedinger.engr.sgi.com> <20080229201744.GB8091@v2.random> <Pine.LNX.4.64.0802291301530.11889@schroedinger.engr.sgi.com> <20080229212327.GC8091@v2.random> <Pine.LNX.4.64.0802291329250.13402@schroedinger.engr.sgi.com> <20080229214800.GD8091@v2.random> <Pine.LNX.4.64.0802291408520.14224@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802291408520.14224@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, Feb 29, 2008 at 02:12:57PM -0800, Christoph Lameter wrote:
> On Fri, 29 Feb 2008, Andrea Arcangeli wrote:
> 
> > > AFAICT The rw semaphore fastpath is similar in performance to a rw 
> > > spinlock. 
> > 
> > read side is taken in the slow path.
> 
> Slowpath meaning VM slowpath or lock slow path? Its seems that the rwsem 

With slow path I meant the VM. Sorry if that was confusing given locks
also have fast paths (no contention) and slow paths (contention).

> read side path is pretty efficient:

Yes. The assembly doesn't worry me at all.

> > pagefault is fast path, VM during swapping is slow path.
> 
> Not sure what you are saying here. A pagefault should be considered as a 
> fast path and swapping is not performance critical?

Yes, swapping is I/O bound and it rarely becomes CPU hog in the common
case.

There are corner case workloads (including OOM) where swapping can
become cpu bound (that's also where rwlock helps). But certainly the
speed of fork() and a page fault, is critical for _everyone_, not just
a few workloads and setups.

> Ok too many calls to schedule() because the slow path (of the semaphore) 
> is taken?

Yes, that's the only possible worry when converting a spinlock to
mutex.

> But that is only happening for the contended case. Certainly a spinlock is 
> better for 2p system but the more processors content for the lock (and 
> the longer the hold off is, typical for the processors with 4p or 8p or 
> more) the better a semaphore will work.

Sure. That's also why the PT lock switches for >4way compiles. Config
option helps to keep the VM optimal for everyone. Here it is possible
it won't be necessary but I can't be sure given both i_mmap_lock and
anon-vma lock are used in some many places. Some TPC comparison would
be nice before making a default switch IMHO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
