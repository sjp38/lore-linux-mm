Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DEA838D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 11:02:40 -0500 (EST)
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1299509808.2071.1445.camel@dan>
References: <AANLkTimRN_=APe_PWMFe_6CHHC7psUbCYE-O0qc=mmYY@mail.gmail.com>
	 <1299270709.3062.313.camel@calx> <1299271377.2071.1406.camel@dan>
	 <AANLkTik6tAfaSr3wxdQ1u_Hd326TmNZe0-FQc3NuYMKN@mail.gmail.com>
	 <1299272907.2071.1415.camel@dan>
	 <AANLkTina+O77BFV+7mO9fX2aJimpO0ov_MKwxGtMwqG+@mail.gmail.com>
	 <1299275042.2071.1422.camel@dan>
	 <AANLkTikA=88EMs8RRm0RPQ+Q9nKj=2G+G86h5nCnV7Se@mail.gmail.com>
	 <AANLkTikQxOgYFLbc2KbEKgRYL1RCnkPE-T80-GBY2Cgj@mail.gmail.com>
	 <1299279756.3062.361.camel@calx> <20110305162508.GA11120@thunk.org>
	 <20110306131955.722d9bd5@lxorguk.ukuu.org.uk>
	 <1299509808.2071.1445.camel@dan>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 07 Mar 2011 10:02:10 -0600
Message-ID: <1299513730.3062.444.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Rosenberg <drosenberg@vsecurity.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Ted Ts'o <tytso@mit.edu>, Pekka Enberg <penberg@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 2011-03-07 at 09:56 -0500, Dan Rosenberg wrote:
> On Sun, 2011-03-06 at 13:19 +0000, Alan Cox wrote:
> > > If we had wrappers for the most common cases, then any cases that were
> > > left that used copy_from_user() explicitly could be flagged and
> > > checked by hand, since they would be exception, and not the rule.
> > 
> > Arjan's copy_from_user validation code already does verification checks
> > on the copies using gcc magic.
> > 
> > Some of the others might be useful - kmalloc_from_user() is a fairly
> > obvious interface, a copy_from_user_into() interface where you pass
> > the destination object and its actual length as well is mostly covered by
> > Arjan's stuff.
> > 
> > Alan
> 
> This is all worthwhile discussion, and a good implementation of these
> kinds of features is available as part of grsecurity (PAX_USERCOPY) - it
> provides additional bounds-checking for copy operations into both heap
> and stack buffers.  Rather than reinventing the wheel, perhaps it would
> be a better use of time to extract this patch and make it suitable for
> inclusion.

Bounds-checking the existing generic functions is not at all the same,
and is in fact counterproductive. It says "go ahead, think even LESS
about getting your code right, because there's a (slow) safety net
built-in".

The above proposal is instead "copy these patterns that simplify your
code"

Consider time_after:

http://www.cs.fsu.edu/~baker/devices/lxr/http/source/linux/include/linux/jiffies.h#L93

Before this code (now more than 10 years old), there was lots of code in
the kernel that manually compared time stamps and got it wrong. These
error would show up about 43 days later when someone on an Alpha would
get a panic. We eventually ended up setting the clock to wrap after only
5 minutes and hundreds of these bugs showed up. The fix was not to try
to catch unlikely timer values, but to instead make it easy to get the
code right.

> In the meantime, I'd like to get back to the original patch
> (make /proc/slabinfo 0400), and the subsequent followup patch (randomize
> free objects within a slab).  While it's clear that these patches by
> themselves will not entirely prevent kernel heap exploits, they both
> seem to be sane improvements, won't significantly impact performance,
> and shouldn't be more than a very minor inconvenience to some small
> subset of normal users.  In addition, the absence of these changes might
> undermine future hardening improvements (e.g. with a more hardened heap,
> the readability of /proc/slabinfo may be more necessary for successful
> exploitation).

If a "hardened heap" ever shows up which doesn't have the massive
overhead of a debugging heap and is thus interesting to the real world,
we can consider these changes then. But I won't be holding my breath.

The only method I know of to harden a heap that would prevent the
exploits we're looking at is basically CONFIG_PAGE_DEBUG: put each
object on a separate page and surround it by two not-present pages. Then
any overflow gets caught instantaneously by the MMU. Before anyone gets
excited about this approach: having 96-byte objects take 4k of physical
memory, 12k of virtual memory, and have massive TLB flushing overhead is
a great way to make your i7 feel like a 386.

Every other method that doesn't rely on hardware (eg redzoning) is only
defense against accidental overruns and will only catch problems long
after the fact. Further, if you can inject exploit code into a
neighboring object, you can probably properly repair the redzone while
you're at it.

The kind of randomization that defends address spaces won't work here.
That requires a vast amount of virtual memory to be any defense against
NOP sleds or equivalents. And we've only got physical space around the
size of a page to play with. If the attacker can control allocation of
lots of objects, we basically have to assume that space is crowded.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
