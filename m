Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA00208
	for <linux-mm@kvack.org>; Tue, 7 Jul 1998 11:12:37 -0400
Date: Tue, 7 Jul 1998 13:01:11 +0100
Message-Id: <199807071201.NAA00934@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980706203947.369E-100000@dragon.bogus>
References: <199807061436.PAA01547@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.96.980706203947.369E-100000@dragon.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <arcangeli@mbox.queen.it>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 6 Jul 1998 21:28:42 +0200 (CEST), Andrea Arcangeli
<arcangeli@mbox.queen.it> said:

> On Mon, 6 Jul 1998, Stephen C. Tweedie wrote:
>> No --- that's the whole point.  We have per-page process page aging
>> which lets us differentiate between processes which are active and those
>> which are idle, and between the used and unused pages within the active
>> processes.

> Nice! The problem is that probably the kernel think that bash and every
> not 100% CPU eater is an idle process... 

Not at all. :) A process only has to touch a page once per sweep of
the vm scanner for that page to be marked in use.  A shell which
touches a few pages for every keystroke will get the same preservation
of those pages as a process which is touching the same number of pages
in a tight loop.

>> If you are short on memory, then you don't want to keep around any
>> process pages which belong to idle tasks.  The only way to do that is to

> This is again more true for low memory machines (where the current kswapd
> policy sucks). I 100% agree with this, I don' t agree to swapout to make
> space from the cache. 

I've just explained why we _do_ want to do this on low memory
machines, to a certain extent.  When memory is low, we don't want to
keep around anything which we don't need,  and so swapping out
completely unused pages is a good thing.  The thing we need to avoid
is swapping anything touched recently; switching off swapout completely,
even just to make room for the cache, is wrong.

>> invoke the swapper.  We need to make sure that we are just aggressive
>> enough to discard pages which are not in use, and not to discard pages
>> which have been touched recently.

> I think that we are too much aggressive. 

Sure, in 2.1.

> It would be nice if it would be swapped out _only_ pages that are not used
> in the past half an hour. If kswapd would run in such way I would thank
> you a lot instead of being irritate ;-).

?? Some people will want to keep anything used within the last half
hour; in other cases, 5 minutes idle should qualify for a swapout.  On
the compilation benchmarks I run on 6MB machines, any page not used
within the past 10 seconds or so should be history!

>> You also don't want lpd sitting around, either.

> NO. I want lpd sitting around if it' s been used in the last 10 minutes
> for example. I don' t want to swapout process for make space for the
> _cache_ if the process is not 100% idle instead.

Not if your memory is full.

You CANNOT say "I want this in memory, not that".  You will always be
able to find situations where it doesn't work.  You need a balance.
I'm quite sure that you don't want your kernel build to thrash simply
because the vm system is afraid of swapping out the sendmail and lpd
daemons you used 10 minutes ago.

> 2.0.34 destroy (wooo nice I love when I see the cache destroyed ;-)
> completly the cache and runs great. 

No it doesn't.  It balances the cache better; that's a very different
thing.  The only difference between 2.0 and 2.1 in this regard is the
tuning of that balance; the underlying code is more or less the same.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
