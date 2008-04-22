Date: Tue, 22 Apr 2008 15:48:47 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 0 of 9] mmu notifier #v12
Message-ID: <20080422134847.GT12709@duo.random>
References: <patchbomb.1207669443@duo.random> <20080409131709.GR11364@sgi.com> <20080409144401.GT10133@duo.random> <20080409185500.GT11364@sgi.com> <20080422072026.GM12709@duo.random> <20080422120056.GR12709@duo.random> <20080422130120.GR22493@sgi.com> <20080422132143.GS12709@duo.random> <20080422133604.GN30298@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080422133604.GN30298@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2008 at 08:36:04AM -0500, Robin Holt wrote:
> I am a little confused about the value of the seq_lock versus a simple
> atomic, but I assumed there is a reason and left it at that.

There's no value for anything but get_user_pages (get_user_pages takes
its own lock internally though). I preferred to explain it as a
seqlock because it was simpler for reading, but I totally agree in the
final implementation it shouldn't be a seqlock. My code was meant to
be pseudo-code only. It doesn't even need to be atomic ;).

> I don't know what you mean by "it'd" run slower and what you mean by
> "armed and disarmed".

1) when armed the time-window where the kvm-page-fault would be
blocked would be a bit larger without invalidate_page for no good
reason

2) if you were to remove invalidate_page when disarmed the VM could
would need two branches instead of one in various places

I don't want to waste cycles if not wasting them improves performance
both when armed and disarmed.

> For the sake of this discussion, I will assume "it'd" means the kernel in
> general and not KVM.  With the two call sites for range_begin/range_end,

I actually meant for both.

> By disarmed, I will assume you mean no notifiers registered for a
> particular mm.  In that case, the cache will make the second call
> effectively free.  So, for the disarmed case, I see no measurable
> difference.

For rmap is sure effective free, for do_wp_page it costs one branch
for no good reason.

> For the case where there is a notifier registered, I certainly can see
> a difference.  I am not certain how to quantify the difference as it

Agreed.

> When I was discussing this difference with Jack, he reminded me that
> the GRU, due to its hardware, does not have any race issues with the
> invalidate_page callout simply doing the tlb shootdown and not modifying
> any of its internal structures.  He then put a caveat on the discussion
> that _either_ method was acceptable as far as he was concerned.  The real
> issue is getting a patch in that satisfies all needs and not whether
> there is a seperate invalidate_page callout.

Sure, we have that patch now, I'll send it out in a minute, I was just
trying to explain why it makes sense to have an invalidate_page too
(which remains the only difference by now), removing it would be a
regression on all sides, even if a minor one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
