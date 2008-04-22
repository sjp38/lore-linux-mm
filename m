Date: Tue, 22 Apr 2008 20:43:35 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 00 of 12] mmu notifier #v13
Message-ID: <20080422184335.GN24536@duo.random>
References: <patchbomb.1208872276@duo.random> <20080422182213.GS22493@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080422182213.GS22493@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2008 at 01:22:13PM -0500, Robin Holt wrote:
> 1) invalidate_page:  You retain an invalidate_page() callout.  I believe
> we have progressed that discussion to the point that it requires some
> direction for Andrew, Linus, or somebody in authority.  The basics
> of the difference distill down to no expected significant performance
> difference between the two.  The invalidate_page() callout potentially
> can simplify GRU code.  It does provide a more complex api for the
> users of mmu_notifier which, IIRC, Christoph had interpretted from one
> of Andrew's earlier comments as being undesirable.  I vaguely recall
> that sentiment as having been expressed.

invalidate_page as demonstrated in KVM pseudocode doesn't change the
locking requirements, and it has the benefit of reducing the window of
time the secondary page fault has to be masked and at the same time
_halves_ the number of _hooks_ in the VM every time the VM deal with
single pages (example: do_wp_page hot path). As long as we can't fully
converge because of point 3, it'd rather keep invalidate_page to be
better. But that's by far not a priority to keep.

> 2) Range callout names: Your range callouts are invalidate_range_start
> and invalidate_range_end whereas Christoph's are start and end.  I do not
> believe this has been discussed in great detail.  I know I have expressed
> a preference for your names.  I admit to having failed to follow up on
> this issue.  I certainly believe we could come to an agreement quickly
> if pressed.

I think using ->start ->end is a mistake, think when we later add
mprotect_range_start/end. Here too I keep the better names only
because we can't converge on point 3 (the API will eventually change,
like every other kernel interal API, even core things like __free_page
have been mostly obsoleted).

> 3) The structure of the patch set:  Christoph's upcoming release orders
> the patches so the prerequisite patches are seperately reviewable
> and each file is only touched by a single patch.  Additionally, that

Each file touched by a single patch? I doubt... The split is about the
same, the main difference is the merge ordering, I always had the zero
risk part at the head, he moved it at the tail when he incorporated
#v12 into his patchset.

> allows mmu_notifiers to be introduced as a single patch with sleeping
> functionality from its inception and an API which remains unchanged.
> Your patch set, however, introduces one API, then turns around and
> changes that API.  Again, the desire to make it an unchanging API was
> expressed by, IIRC, Andrew.  This does represent a risk to XPMEM as
> the non-sleeping API may become entrenched and make acceptance of the
> sleeping version less acceptable.
> 
> Can we agree upon this list of issues?

This is a kernel internal API, so it will definitely change over
time. It's nothing close to a syscall.

Also note: the API is obviously defined in mmu_notifier.h and none of
the 2-12 patches touches mmu_notifier.h. So the extension of the
method semantics is 100% backwards compatible.

My patch order and API backward compatible extension over the patchset
is done to allow 2.6.26 to fully support KVM/GRU and 2.6.27 to support
XPMEM as well. KVM/GRU won't notice any difference once the support
for XPMEM is added, but even if the API would completely change in
2.6.27, that's still better than no functionality at all in 2.6.26.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
