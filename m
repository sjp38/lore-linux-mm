From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [ofa-general] Re: [patch 1/9] EMM Notifier: The notifier calls
Date: Wed, 2 Apr 2008 08:49:52 +0200
Message-ID: <20080402064952.GF19189@duo.random>
References: <20080401205531.986291575@sgi.com>
	<20080401205635.793766935@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20080401205635.793766935@sgi.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, steiner@sgi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

On Tue, Apr 01, 2008 at 01:55:32PM -0700, Christoph Lameter wrote:
> +/* Perform a callback */
> +int __emm_notify(struct mm_struct *mm, enum emm_operation op,
> +		unsigned long start, unsigned long end)
> +{
> +	struct emm_notifier *e = rcu_dereference(mm)->emm_notifier;
> +	int x;
> +
> +	while (e) {
> +
> +		if (e->callback) {
> +			x = e->callback(e, mm, op, start, end);
> +			if (x)
> +				return x;

There are much bigger issues besides the rcu safety in this patch,
proper aging of the secondary mmu through access bits set by hardware
is unfixable with this model (you would need to do age |=
e->callback), which is the proof of why this isn't flexibile enough by
forcing the same parameter and retvals for all methods. No idea why
you go for such inferior solution that will never get the aging right
and will likely fall apart if we add more methods in the future.

For example the "switch" you have to add in
xpmem_emm_notifier_callback doesn't look good, at least gcc may be
able to optimize it with an array indexing simulating proper pointer
to function like in #v9.

Most other patches will apply cleanly on top of my coming mmu
notifiers #v10 that I hope will go in -mm.

For #v10 the only two left open issues to discuss are:

1) the moment you remove rcu_read_lock from the methods (my #v9 had
   rcu_read_lock so synchronize_rcu() in Jack's patch was working with
   my #v9) GRU has no way to ensure the methods will fire immediately
   after registering. To fix this race after removing the
   rcu_read_lock (to prepare for the later patches that allows the VM
   to schedule when the mmu notifiers methods are invoked) I can
   replace rcu_read_lock with seqlock locking in the same way as I did
   in a previous patch posted here (seqlock_write around the
   registration method, and seqlock_read replying all callbacks if the
   race happened). then synchronize_rcu become unnecessary and the
   methods will be correctly replied allowing GRU not to corrupt
   memory after the registration method. EMM would also need a fix
   like this for GRU to be safe on top of EMM.

   Another less obviously safe approach is to allow the register
   method to succeed only when mm_users=1 and the task is single
   threaded. This way if all the places where the mmu notifers aren't
   invoked on the mm not by the current task, are only doing
   invalidates after/before zapping ptes, if the istantiation of new
   ptes is single threaded too, we shouldn't worry if we miss an
   invalidate for a pte that is zero and doesn't point to any physical
   page. In the places where current->mm != mm I'm using
   invalidate_page 99% of the time, and that only follows the
   ptep_clear_flush. The problem are the range_begin that will happen
   before zapping the pte in places where current->mm !=
   mm. Unfortunately in my incremental patch where I move all
   invalidate_page outside of the PT lock to prepare for allowing
   sleeping inside the mmu notifiers, I used range_begin/end in places
   like try_to_unmap_cluster where current->mm != mm. In general
   this solution looks more fragile than the seqlock.

2) I'm uncertain how the driver can handle a range_end called before
   range_begin. Also multiple range_begin can happen in parallel later
   followed by range_end, so if there's a global seqlock that
   serializes the secondary mmu page fault, that will screwup (you
   can't seqlock_write in range_begin and sequnlock_write in
   range_end). The write side of the seqlock must be serialized and
   calling seqlock_write twice in a row before any sequnlock operation
   will break.

   A recursive rwsem taken in range_begin and released in range_end
   seems to be the only way to stop the secondary mmu page faults.

   If I would remove all range_begin/end in places where current->mm
   != mm, then I could as well bail out in mmu_notifier_register if
   use mm_users != 1 to solve problem 2 too.

   My solution to this is that I believe the driver is safe if the
   range_end is being missed if range_end is followed by an invalidate
   event like in invalidate_range_end, so the driver is ok to just
   have a static value that accounts if range_begin has ever happened
   and it will just return from range_end without doing anything if no
   range_begin ever happened.


Notably I'll be trying to use range_begin in KVM too so I got to deal
with 2) too. For Nick: the reason for using range_begin is supposedly
an optimization: to guarantee that the last free of the page will
happen outside the mmu_lock, so KVM internally to the mmu_lock is free
to do:

   	     spin_lock(kvm->mmu_lock)
   	     put_page()
	     spte = nonpresent
	     flush secondary tlb()
	     spin_unlock(kvm->mmu_lock)

The above ordering is unsafe if the page could ever reach the freelist
before the tlb flush happened. The range_begin will take the mmu_lock
and will hold off kvm new page faults to allow kvm to free as many
page it wants, invalidate all ptes and only at the end do a single tlb
flush, while still being allowed to madvise(don't need) or munmap
parts of the memory mapped by sptes. It's uncertain if the ordering
should be changed to be robust against put_page putting the page in
the freelist immediately, instead of using range_begin to serialize
against the page going out of ptes immediately after put_page is
called. If we go for a range_end-only usage of the mmu notifiers kvm
will need some reordering and zapping a large number of ptes will
require multiple tlb flushes as the pages have to be pointed by an
array and the array is of limited size (the size of the array decides
the frequency of the tlb flushes). The suggested usage of range_begin
allows to do a single tlb flush for an unlimited number of sptes being
zapped.
