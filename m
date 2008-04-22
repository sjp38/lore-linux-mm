Date: Tue, 22 Apr 2008 10:26:00 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 0 of 9] mmu notifier #v12
Message-ID: <20080422152600.GP30298@sgi.com>
References: <patchbomb.1207669443@duo.random> <20080409131709.GR11364@sgi.com> <20080409144401.GT10133@duo.random> <20080409185500.GT11364@sgi.com> <20080422072026.GM12709@duo.random> <20080422120056.GR12709@duo.random> <20080422130120.GR22493@sgi.com> <20080422132143.GS12709@duo.random> <20080422133604.GN30298@sgi.com> <20080422134847.GT12709@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080422134847.GT12709@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>, akpm@linux-foundation.org
Cc: Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Andrew, Could we get direction/guidance from you as regards
the invalidate_page() callout of Andrea's patch set versus the
invalidate_range_start/invalidate_range_end callout pairs of Christoph's
patchset?  This is only in the context of the __xip_unmap, do_wp_page,
page_mkclean_one, and try_to_unmap_one call sites.

On Tue, Apr 22, 2008 at 03:48:47PM +0200, Andrea Arcangeli wrote:
> On Tue, Apr 22, 2008 at 08:36:04AM -0500, Robin Holt wrote:
> > I am a little confused about the value of the seq_lock versus a simple
> > atomic, but I assumed there is a reason and left it at that.
> 
> There's no value for anything but get_user_pages (get_user_pages takes
> its own lock internally though). I preferred to explain it as a
> seqlock because it was simpler for reading, but I totally agree in the
> final implementation it shouldn't be a seqlock. My code was meant to
> be pseudo-code only. It doesn't even need to be atomic ;).

Unless there is additional locking in your fault path, I think it does
need to be atomic.

> > I don't know what you mean by "it'd" run slower and what you mean by
> > "armed and disarmed".
> 
> 1) when armed the time-window where the kvm-page-fault would be
> blocked would be a bit larger without invalidate_page for no good
> reason

But that is a distinction without a difference.  In the _start/_end
case, kvm's fault handler will not have any _DIRECT_ blocking, but
get_user_pages() had certainly better block waiting for some other lock
to prevent the process's pages being refaulted.

I am no VM expert, but that seems like it is critical to having a
consistent virtual address space.  Effectively, you have a delay on the
kvm fault handler beginning when either invalidate_page() is entered
or invalidate_range_start() is entered until when the _CALLER_ of the
invalidate* method has unlocked.  That time will remain essentailly
identical for either case.  I would argue you would be hard pressed to
even measure the difference.

> 2) if you were to remove invalidate_page when disarmed the VM could
> would need two branches instead of one in various places

Those branches are conditional upon there being list entries.  That check
should be extremely cheap.  The vast majority of cases will have no
registered notifiers.  The second check for the _end callout will be
from cpu cache.

> I don't want to waste cycles if not wasting them improves performance
> both when armed and disarmed.

In summary, I think we have narrowed down the case of no registered
notifiers to being infinitesimal.  The case of registered notifiers
being a distinction without a difference.

> > When I was discussing this difference with Jack, he reminded me that
> > the GRU, due to its hardware, does not have any race issues with the
> > invalidate_page callout simply doing the tlb shootdown and not modifying
> > any of its internal structures.  He then put a caveat on the discussion
> > that _either_ method was acceptable as far as he was concerned.  The real
> > issue is getting a patch in that satisfies all needs and not whether
> > there is a seperate invalidate_page callout.
> 
> Sure, we have that patch now, I'll send it out in a minute, I was just
> trying to explain why it makes sense to have an invalidate_page too
> (which remains the only difference by now), removing it would be a
> regression on all sides, even if a minor one.

I think GRU is the only compelling case I have heard for having the
invalidate_page seperate.  In the case of the GRU, the hardware enforces a
lifetime of the invalidate which covers all in-progress faults including
ones where the hardware is informed after the flush of a PTE.  in all
cases, once the GRU invalidate instruction is issued, all active requests
are invalidated.  Future faults will be blocked in get_user_pages().
Without that special feature of the hardware, I don't think any code
simplification exists.  I, of course, reserve the right to be wrong.

I believe the argument against a seperate invalidate_page() callout was
Christoph's interpretation of Andrew's comments.  I am not certain Andrew
was aware of this special aspects of the GRU hardware and whether that
had been factored into the discussion at that point in time.


Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
