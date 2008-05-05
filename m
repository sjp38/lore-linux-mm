Date: Mon, 5 May 2008 12:25:06 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH 01 of 11] mmu-notifier-core
Message-ID: <20080505172506.GA9247@sgi.com>
References: <patchbomb.1209740703@duo.random> <1489529e7b53d3f2dab8.1209740704@duo.random> <20080505162113.GA18761@sgi.com> <20080505171434.GF8470@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080505171434.GF8470@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, May 05, 2008 at 07:14:34PM +0200, Andrea Arcangeli wrote:
> On Mon, May 05, 2008 at 11:21:13AM -0500, Jack Steiner wrote:
> > The GRU does the registration/deregistration of mmu notifiers from mmap/munmap.
> > At this point, the mmap_sem is already held writeable. I hit a deadlock
> > in mm_lock.
> 
> It'd been better to know about this detail earlier,

Agree. My apologies... I should have caught it.


> but frankly this
> is a minor problem, the important thing is we all agree together on
> the more difficult parts ;).
> 
> > A quick fix would be to do one of the following:
> > 
> > 	- move the mmap_sem locking to the caller of the [de]registration routines.
> > 	  Since the first/last thing done in mm_lock/mm_unlock is to
> > 	  acquire/release mmap_sem, this change does not cause major changes.
> 
> I don't like this solution very much. Nor GRU nor KVM will call
> mmu_notifier_register inside the mmap_sem protected sections, so I
> think the default mmu_notifier_register should be smp safe by itself
> without requiring additional locks to be artificially taken externally
> (especially because the need for mmap_sem in write mode is a very
> mmu_notifier internal detail).
> 
> > 	- add a flag to mmu_notifier_[un]register routines to indicate
> > 	  if mmap_sem is already locked.
> 
> The interface would change like this:
> 
> #define MMU_NOTIFIER_REGISTER_MMAP_SEM (1<<0)
> void mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm,
> 			   unsigned long mmu_notifier_flags);

That works...


> 
> A third solution is to add:
> 
> /*
>  * This must can be called instead of mmu_notifier_register after
>  * taking the mmap_sem in write mode (read mode isn't enough).
>  */
> void __mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm);
> 
> Do you still prefer the bitflag or you prefer
> __mmu_notifier_register. It's ok either ways, except
> __mmu_notifier_reigster could be removed in a backwards compatible
> way, the bitflag can't.
> 
> > I've temporarily deleted the mm_lock locking of mmap_sem and am continuing to
> > test. More later....

__mmu_notifier_register/__mmu_notifier_unregister seems like a better way to
go, although either is ok.


> 
> Sure! In the meantime go ahead this way.
> 
> Another very minor change I've been thinking about is to make
> ->release not mandatory. It happens that with KVM ->release isn't
> strictly required because after mm_users reaches 0, no guest could
> possibly run anymore. So I'm using ->release only for debugging by
> placing -1UL in the root shadow pagetable, to be sure ;). So because
> at least one user won't strictly require ->release being consistent in
> having all method optional may be nicer. Alternatively we could make
> them all mandatory and if somebody doesn't need one of the methods it
> should implement it as a dummy function. Both ways have pros and cons,
> but they don't make any difference to us in practice. If I've to
> change the patch for the mmap_sem taken during registration I may as
> well cleanup this minor bit.
 
Let me finish my testing. At one time, I did not use ->release but
with all the locking & teardown changes, I need to do some reverification.


--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
