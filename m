Date: Tue, 4 Mar 2008 14:35:21 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Notifier for Externally Mapped Memory (EMM)
In-Reply-To: <20080304222030.GB8951@v2.random>
Message-ID: <Pine.LNX.4.64.0803041422070.20821@schroedinger.engr.sgi.com>
References: <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com>
 <20080227192610.GF28483@v2.random> <20080302155457.GK8091@v2.random>
 <20080303213707.GA8091@v2.random> <20080303220502.GA5301@v2.random>
 <47CC9B57.5050402@qumranet.com> <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com>
 <20080304133020.GC5301@v2.random> <Pine.LNX.4.64.0803041059110.13957@schroedinger.engr.sgi.com>
 <20080304222030.GB8951@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Tue, 4 Mar 2008, Andrea Arcangeli wrote:

> I once ripped invalidate_page while working on #v8 but then I
> reintroduced it because I thought reducing the total number of hooks
> was beneficial to the core linux VM (even if only a
> microoptimization, I sure agree about that, but it's trivial to add
> one hook instead of two hooks there, so a microoptimization was worth
> it IMHO).

Well the problem is if one does not have the begin/end hooks then 
reliable clearing of the mapping may not be possible. begin/end allow
holding off new references and that avoids the issue that would come
with an single callback that could race with something else.
 
> Your API is also too restrictive, if we'll happen to need one more
> method that doesn't take just (start,end) we'll have to cause all
> drivers to have significant changes instead of one-liners to use
> whatever new feature.

What would that be? I think the API need to stay as simple as possible. 
And this set is pretty minimal and easy to understand. Not having the 
invalidate_page() removes a troublespot from the API.
 
> IMHO the design is actually same and I don't understand why you
> rewrote it once more time in a less flexibile way (on a style side
> you're not even using hlist), dropping RCU (not sure how you replace
> it with), etc....

All of that is needed in order to allow sleeping in the future. Your 
version locks us into atomic callbacks. It also makes the API needlessly 
complex.

RCU means that the callbacks occur in an atomic context.

> Converging in a single design is great, but it'd be nice if we could
> converge into a single implementation, and my last patch doesn't have
> any bug and I think it's quite nicer too (also including Nick cleanup
> work) but then I may be biased ;).

It is the atomic dead end that we want to avoid. And your patch is exactly 
that. Both the invalidate_page and the RCU locks us into this.

> But as usual I'm entirely satisfied by your brand new EMM Notifier to
> be merged and all perfecting work done on my MMU notifier patch over
> the weeks by multiple developers (including you) to be dropped for
> good, as long as we can enable the new advanced KVM features in
> 2.6.25.

Well I really want us to have one API that is suitable for multiple 
purposes and that allows a generic use by device drivers for multiple 
purposes. The discussion in the last month have made that possible. I am 
glad that you do not see any major issues with the patch. I sure wish I 
would not have to post a competing patchset because I want things to be 
merged ASAP and get this over with. But we need to have at minimum clear 
way to support sleeping with the existing API in the future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
