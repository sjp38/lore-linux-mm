Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA00584
	for <linux-mm@kvack.org>; Mon, 25 Jan 1999 13:44:02 -0500
Date: Mon, 25 Jan 1999 10:43:46 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <199901251625.QAA04452@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.990125103135.21082F-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 25 Jan 1999, Stephen C. Tweedie wrote:
> 
> The changes are very similar to the self-tuning clock counter we had in
> those ac* vms.  The modified shrink_mmap() just avoids decrementing the
> count for locked, non-DMA (if GFP_DMA) or multiply-mapped pages.  The
> effect is to avoid counting memory mapped pages when we trim cache.  In
> low memory, this allows us to keep trimming back the "excess" unmapped
> pure cache pages even if a large fraction of physical memory is occupied
> by mapped pages.  

Parts of your patch makes sense, other parts make no sense at all.

For example, the "multiply by two" that you removed, is done in order to
make shrink_mmap() look at all pages when given a priority of zero. Your
patch makes it possible that shrink_mmap() wouldn't have looked at all
pages, because count is still decremented before looking at "referenced"

I don't think that's actually a problem, because before we call
shrink_mmap() with argument 0, we'll have called it many times before, and
that together with the fact that you changed the count to not be
decremented for shared pages makes the "problem" fairly academic. So my
only objection is basically that I think you mixed up the behaviour of the
new patch with the (original) patch of yours that made count decrements
conditional on the PG_referenced bit.

Basically, this is _very_ different from the self-tuning clock you
proposed earlier: your earlier patch had the explanation that you wanted
to more quickly go through referenced pages, while this one goes through
_shared_ pages more quickly. Big difference.

I like the second way of thinking about it a lot more, though. And it may
be that even though you _thought_ that the first one was due to reference
counting, the shared page issue was the more important one. 

As far as I can see, this patch essentially makes us more likely to keep
shared pages - somehting I wholeheartedly agree with, and I'll apply it. I
just wanted to point out that I think you're making up the explanations
for your patches as you go along, and that this is NOT the same
explanation you had for your earlier patch that did a very similar thing.
Sounds like you made up the explanations after making the patch.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
