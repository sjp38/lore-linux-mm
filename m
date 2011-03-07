Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E184A8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 09:58:37 -0500 (EST)
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Dan Rosenberg <drosenberg@vsecurity.com>
In-Reply-To: <20110306131955.722d9bd5@lxorguk.ukuu.org.uk>
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
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 07 Mar 2011 09:56:48 -0500
Message-ID: <1299509808.2071.1445.camel@dan>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Ted Ts'o <tytso@mit.edu>, Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>

On Sun, 2011-03-06 at 13:19 +0000, Alan Cox wrote:
> > If we had wrappers for the most common cases, then any cases that were
> > left that used copy_from_user() explicitly could be flagged and
> > checked by hand, since they would be exception, and not the rule.
> 
> Arjan's copy_from_user validation code already does verification checks
> on the copies using gcc magic.
> 
> Some of the others might be useful - kmalloc_from_user() is a fairly
> obvious interface, a copy_from_user_into() interface where you pass
> the destination object and its actual length as well is mostly covered by
> Arjan's stuff.
> 
> Alan

This is all worthwhile discussion, and a good implementation of these
kinds of features is available as part of grsecurity (PAX_USERCOPY) - it
provides additional bounds-checking for copy operations into both heap
and stack buffers.  Rather than reinventing the wheel, perhaps it would
be a better use of time to extract this patch and make it suitable for
inclusion.

In the meantime, I'd like to get back to the original patch
(make /proc/slabinfo 0400), and the subsequent followup patch (randomize
free objects within a slab).  While it's clear that these patches by
themselves will not entirely prevent kernel heap exploits, they both
seem to be sane improvements, won't significantly impact performance,
and shouldn't be more than a very minor inconvenience to some small
subset of normal users.  In addition, the absence of these changes might
undermine future hardening improvements (e.g. with a more hardened heap,
the readability of /proc/slabinfo may be more necessary for successful
exploitation).

-Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
