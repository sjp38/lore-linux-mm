Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA01123
	for <linux-mm@kvack.org>; Mon, 25 Jan 1999 14:15:43 -0500
Date: Mon, 25 Jan 1999 19:15:22 GMT
Message-Id: <199901251915.TAA08849@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.95.990125103135.21082F-100000@penguin.transmeta.com>
References: <199901251625.QAA04452@dax.scot.redhat.com>
	<Pine.LNX.3.95.990125103135.21082F-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 25 Jan 1999 10:43:46 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> For example, the "multiply by two" that you removed, is done in order to
> make shrink_mmap() look at all pages when given a priority of zero.

Yes, but unfortunately that same *2 is the primary constant by which we
tune the relative aggressiveness of shrink_mmap() and
try_to_swap_out().  Simple profiling was showing that for any given
value of priority, we were biased too much against reclaiming cache for
some very common workloads: kernel builds were evicting include files
between gcc invocations on machines from 16MB right up to 64MB.

> So my only objection is basically that I think you mixed up the
> behaviour of the new patch with the (original) patch of yours that
> made count decrements conditional on the PG_referenced bit.

> Basically, this is _very_ different from the self-tuning clock you
> proposed earlier: your earlier patch had the explanation that you wanted
> to more quickly go through referenced pages, while this one goes through
> _shared_ pages more quickly. Big difference.

OK, let me give you the fuller explanation. :)

> I like the second way of thinking about it a lot more, though. And it may
> be that even though you _thought_ that the first one was due to reference
> counting, the shared page issue was the more important one. 

Yes and no.  The shared page issue dominates on low memory, that much is
clear, but the two patches do behave similarly in that case: we do not
expect to have too much excess cache in low memory, and shared pages
will dominate (and on 8MB, you can clearly see that they do dominate).
Both generations of the patch avoid counting those pages in the clock.
That was _always_ intended to be the effect in low memory.  That has not
changed in the new patch.

The page referencing issue is more significant once you have a large
cache with rapid cache turnover, in which case you really do want to age
things faster.  However, that is currently dealt with anyway, by the
fact that most processes reclaim their own memory rather than relying on
kswapd, and that they do so by shrink_mmap() first rather than relying
on the try_to_free_page() internal state that we used to have.  

As a result I really don't see the page referencing as being much of a
problem now: your other changes to vmscan.c have pretty much taken care
of that according to most of the traces I've taken.

Therefore the minimum necessary change to restore the old ac* behaviour
is to address the shared page skipping.  vmstat does show the new code
keeping a very similar balance and throughput to the old version.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
