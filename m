Date: Thu, 8 May 2008 00:58:01 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080507225801.GK8276@duo.random>
References: <6b384bb988786aa78ef0.1210170958@duo.random> <alpine.LFD.1.10.0805071349200.3024@woody.linux-foundation.org> <20080507212650.GA8276@duo.random> <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org> <20080507222205.GC8276@duo.random> <alpine.LFD.1.10.0805071540300.3024@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0805071540300.3024@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2008 at 03:44:24PM -0700, Linus Torvalds wrote:
> 
> 
> On Thu, 8 May 2008, Andrea Arcangeli wrote:
> > 
> > Unfortunately the lock you're talking about would be:
> > 
> > static spinlock_t global_lock = ...
> > 
> > There's no way to make it more granular.
> 
> Right. So what? 
> 
> It's still about a million times faster than what the code does now.

mmu_notifier_register only runs when windows or linux or macosx
boots. Who could ever care of the msec spent in mm_lock compared to
the time it takes to linux to boot?

What you're proposing is to slowdown AIM and certain benchmarks 20% or
more for all users, just so you save at most 1msec to start a VM.

> Rewrite the code, or not. I don't care. I'll very happily not merge crap 
> for the rest of my life.

If you want the global lock I'll do it no problem, I just think it's
obviously inferior solution for 99% of users out there (including kvm
users that will also have to take that lock while kvm userland runs).

In my view the most we should do in this area is to reduce further the
max number of locks to take if max_map_count already isn't enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
