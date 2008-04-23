Date: Wed, 23 Apr 2008 09:47:47 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080423144747.GU30298@sgi.com>
References: <ea87c15371b1bd49380c.1208872277@duo.random> <Pine.LNX.4.64.0804221315160.3640@schroedinger.engr.sgi.com> <20080422223545.GP24536@duo.random> <20080422230727.GR30298@sgi.com> <20080423133619.GV24536@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423133619.GV24536@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 03:36:19PM +0200, Andrea Arcangeli wrote:
> On Tue, Apr 22, 2008 at 06:07:27PM -0500, Robin Holt wrote:
> > > The only other change I did has been to move mmu_notifier_unregister
> > > at the end of the patchset after getting more questions about its
> > > reliability and I documented a bit the rmmod requirements for
> > > ->release. we'll think later if it makes sense to add it, nobody's
> > > using it anyway.
> > 
> > XPMEM is using it.  GRU will be as well (probably already does).
> 
> XPMEM requires more patches anyway. Note that in previous email you
> told me you weren't using it. I think GRU can work fine on 2.6.26

I said I could test without it.  It is needed for the final version.
It also makes the API consistent.  What you are proposing is equivalent
to having a file you can open but never close.

This whole discussion seems ludicrous.  You could refactor the code to get
the sorted list of locks, pass that list into mm_lock to do the locking,
do the register/unregister, then pass the same list into mm_unlock.

If the allocation fails, you could fall back to the older slower method
of repeatedly scanning the lists and acquiring locks in ascending order.

> without mmu_notifier_unregister, like KVM too. You've simply to unpin
> the module count in ->release. The most important bit is that you've
> to do that anyway in case mmu_notifier_unregister fails (and it can

If you are not going to provide the _unregister callout you need to change
the API so I can scan the list of notifiers to see if my structures are
already registered.

We register our notifier structure at device open time.  If we receive a
_release callout, we mark our structure as unregistered.  At device close
time, if we have not been unregistered, we call _unregister.  If you
take away _unregister, I have an xpmem kernel structure in use _AFTER_
the device is closed with no indication that the process is using it.
In that case, I need to get an extra reference to the module in my device
open method and hold that reference until the _release callout.

Additionally, if the users program reopens the device, I need to scan the
mmu_notifiers list to see if this tasks notifier is already registered.

I view _unregister as essential.  Did I miss something?

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
