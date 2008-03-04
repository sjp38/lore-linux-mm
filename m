Date: Tue, 4 Mar 2008 23:20:30 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [RFC] Notifier for Externally Mapped Memory (EMM)
Message-ID: <20080304222030.GB8951@v2.random>
References: <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com> <20080227192610.GF28483@v2.random> <20080302155457.GK8091@v2.random> <20080303213707.GA8091@v2.random> <20080303220502.GA5301@v2.random> <47CC9B57.5050402@qumranet.com> <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com> <20080304133020.GC5301@v2.random> <Pine.LNX.4.64.0803041059110.13957@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803041059110.13957@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Tue, Mar 04, 2008 at 11:00:31AM -0800, Christoph Lameter wrote:
> But as you pointed out before that path is a slow path anyways. Its rarely 

It's a slow path but I don't see why you think two hooks are better
than one, when only one is necessary.

I once ripped invalidate_page while working on #v8 but then I
reintroduced it because I thought reducing the total number of hooks
was beneficial to the core linux VM (even if only a
microoptimization, I sure agree about that, but it's trivial to add
one hook instead of two hooks there, so a microoptimization was worth
it IMHO).

Your API is also too restrictive, if we'll happen to need one more
method that doesn't take just (start,end) we'll have to cause all
drivers to have significant changes instead of one-liners to use
whatever new feature.

> taken. Having a single eviction callback simplifies design.

IMHO the design is actually same and I don't understand why you
rewrote it once more time in a less flexibile way (on a style side
you're not even using hlist), dropping RCU (not sure how you replace
it with), etc....

Your implementation has the same bug you had in your first V1, see how
you're not clearing the spte young bits if the pte young bit is
set. Once you fix that, your change in the ptep_clear_flush_young path
will look remarkably similar to the patch I posted incremental with
#v8 to make ->clear_flush_young sleep capable...

Converging in a single design is great, but it'd be nice if we could
converge into a single implementation, and my last patch doesn't have
any bug and I think it's quite nicer too (also including Nick cleanup
work) but then I may be biased ;).

But as usual I'm entirely satisfied by your brand new EMM Notifier to
be merged and all perfecting work done on my MMU notifier patch over
the weeks by multiple developers (including you) to be dropped for
good, as long as we can enable the new advanced KVM features in
2.6.25.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
