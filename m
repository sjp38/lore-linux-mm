Date: Tue, 29 Apr 2008 02:10:52 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080429001052.GA8315@duo.random>
References: <20080423002848.GA32618@sgi.com> <20080423163713.GC24536@duo.random> <20080423221928.GV24536@duo.random> <20080424064753.GH24536@duo.random> <20080424095112.GC30298@sgi.com> <20080424153943.GJ24536@duo.random> <20080424174145.GM24536@duo.random> <20080426131734.GB19717@sgi.com> <20080427122727.GO9514@duo.random> <Pine.LNX.4.64.0804281332030.31163@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804281332030.31163@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 28, 2008 at 01:34:11PM -0700, Christoph Lameter wrote:
> On Sun, 27 Apr 2008, Andrea Arcangeli wrote:
> 
> > Talking about post 2.6.26: the refcount with rcu in the anon-vma
> > conversion seems unnecessary and may explain part of the AIM slowdown
> > too. The rest looks ok and probably we should switch the code to a
> > compile-time decision between rwlock and rwsem (so obsoleting the
> > current spinlock).
> 
> You are going to take a semphore in an rcu section? Guess you did not 
> activate all debugging options while testing? I was not aware that you can 
> take a sleeping lock from a non preemptible context.

I'd hoped to discuss this topic after mmu-notifier-core was already
merged, but let's do it anyway.

My point of view is that there was no rcu when I wrote that code, yet
there was no reference count and yet all locking looks still exactly
the same as I wrote it. There's even still the page_table_lock to
serialize threads taking the mmap_sem in read mode against the first
vma->anon_vma = anon_vma during the page fault.

Frankly I've absolutely no idea why rcu is needed in all rmap code
when walking the page->mapping. Definitely the PG_locked is taken so
there's no way page->mapping could possibly go away under the rmap
code, hence the anon_vma can't go away as it's queued in the vma, and
the vma has to go away before the page is zapped out of the pte.

So there are some possible scenarios:

1) my original anon_vma code was buggy not taking the rcu_read_lock()
and somebody fixed it (I tend to exclude it)

2) somebody has seen a race that doesn't exist and didn't bother to
document it other than with this obscure comment

 * Getting a lock on a stable anon_vma from a page off the LRU is
 * tricky: page_lock_anon_vma rely on RCU to guard against the races.

I tend to exclude it too as VM folks are too smart for this to be the case.

3) somebody did some microoptimization using rcu and we surely can
undo that microoptimization to get the code back to my original code
that didn't need rcu despite it worked exactly the same, and that is
going to be cheaper to use with semaphores than doubling the number of
locked ops for every lock instruction.

Now the double atomic op may not be horrible when not contented, as it
works on the same cacheline but with cacheline bouncing with
contention it sounds doubly horrible than a single cacheline bounce
and I don't see the point of it as you can't use rcu anyways, so you
can't possibly take advantage of whatever microoptimization done over
the original locking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
