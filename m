Date: Tue, 22 Apr 2008 08:36:04 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 0 of 9] mmu notifier #v12
Message-ID: <20080422133604.GN30298@sgi.com>
References: <patchbomb.1207669443@duo.random> <20080409131709.GR11364@sgi.com> <20080409144401.GT10133@duo.random> <20080409185500.GT11364@sgi.com> <20080422072026.GM12709@duo.random> <20080422120056.GR12709@duo.random> <20080422130120.GR22493@sgi.com> <20080422132143.GS12709@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080422132143.GS12709@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2008 at 03:21:43PM +0200, Andrea Arcangeli wrote:
> On Tue, Apr 22, 2008 at 08:01:20AM -0500, Robin Holt wrote:
> > On Tue, Apr 22, 2008 at 02:00:56PM +0200, Andrea Arcangeli wrote:
> > > On Tue, Apr 22, 2008 at 09:20:26AM +0200, Andrea Arcangeli wrote:
> > > >     invalidate_range_start {
> > > > 	spin_lock(&kvm->mmu_lock);
> > > > 
> > > > 	kvm->invalidate_range_count++;
> > > > 	rmap-invalidate of sptes in range
> > > > 
> > > 
> > > 	write_seqlock; write_sequnlock;
> > 
> > I don't think you need it here since invalidate_range_count is already
> > elevated which will accomplish the same effect.
> 
> Agreed, seqlock only in range_end should be enough. BTW, the fact

I am a little confused about the value of the seq_lock versus a simple
atomic, but I assumed there is a reason and left it at that.

> seqlock is needed regardless of invalidate_page existing or not,
> really makes invalidate_page a no brainer not just from the core VM
> point of view, but from the driver point of view too. The
> kvm_page_fault logic would be the same even if I remove
> invalidate_page from the mmu notifier patch but it'd run slower both
> when armed and disarmed.

I don't know what you mean by "it'd" run slower and what you mean by
"armed and disarmed".

For the sake of this discussion, I will assume "it'd" means the kernel in
general and not KVM.  With the two call sites for range_begin/range_end,
I would agree we have more call sites, but the second is extremely likely
to be cache hot.

By disarmed, I will assume you mean no notifiers registered for a
particular mm.  In that case, the cache will make the second call
effectively free.  So, for the disarmed case, I see no measurable
difference.

For the case where there is a notifier registered, I certainly can see
a difference.  I am not certain how to quantify the difference as it
depends on the callee.  In the case of xpmem, our callout is always very
expensive for the _start case.  Our _end case is very light, but it is
essentially the exact same steps we would perform for the _page callout.

When I was discussing this difference with Jack, he reminded me that
the GRU, due to its hardware, does not have any race issues with the
invalidate_page callout simply doing the tlb shootdown and not modifying
any of its internal structures.  He then put a caveat on the discussion
that _either_ method was acceptable as far as he was concerned.  The real
issue is getting a patch in that satisfies all needs and not whether
there is a seperate invalidate_page callout.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
