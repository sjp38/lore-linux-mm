Received: from cs.utexas.edu (root@cs.utexas.edu [128.83.139.9])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA10133
	for <linux-mm@kvack.org>; Tue, 12 Jan 1999 13:43:12 -0500
Message-Id: <199901121842.MAA28563@feta.cs.utexas.edu>
From: "Paul R. Wilson" <wilson@cs.utexas.edu>
Date: Tue, 12 Jan 1999 12:42:52 -0600
Subject: Re: question about try_to_swap_out()
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org, wilson@cs.utexas.edu
List-ID: <linux-mm.kvack.org>

>From sct@redhat.com Tue Jan 12 12:15:03 1999
>Subject: Re: question about try_to_swap_out()
>
>Hi,
>
>On Tue, 12 Jan 1999 10:58:52 -0600, "Paul R. Wilson"
><wilson@cs.utexas.edu> said:
>
>> I would think that it could be significant if you're skipping DMA
>> pages, which are valuable.  You want to get them back in a timely
>> manner, so you want to go ahead and age them normally.
>
>We don't ever do that.  We can _require_ a DMA allocation, but we never
>explicitly avoid allocating DMA pages.

Sorry, I said it backwards.   I meant "non-DMA", not "DMA".

What I mean is that if try_to_swap_out() is told to look for a DMA page
(via the __GFP_DMA flag in the gfp_maks argument), it skips non-DMA
pages in terms of re-setting their reference bits---the clock sweeps
right by them without re-setting their reference bits.

It seems to me that this means that if the clock reaches a non-DMA'able
page whose reference bit is set, that bit will stay set for at least
another clock sweep IF try_to_swap_out() is looking for a DMA page.

I don't know whether it would ever occur in practice, but it seems
that a non-DMA page could stay in memory indefinitely after the
last touch to it, if it just happens that the clock hand keeps
sweeping by that page at times that it's looking for DMA pages.
The page would keep getting skipped.

It seems to me that the test about DMA's ought to be broken
out of the conditional that tests whether the page is locked
or reserved, and moved after the testing and re-setting of
the reference bit.  (Maybe the test for locked pages, too.  I'm
not sure about what's going on with locking.)  This would make
the code more comprehensible, if nothing else.

---

More generally, it seems to me that the stuff about DMAable
pages is inelegant.  Would it work to just keep sweeping the
clock until the right kind of memory is freed, rather than
putting weird tests inside the clock-sweeping code itself, 
and passing weird flags down through the call chains?  

(Is the time cost of freeing pages of the "wrong" type signficant?
I wouldn't think so---amortized, it's no more expensive because
it's work we should do anyway.  And if you're thrashing, CPU
cost isn't the big issue.)

I assume there's a reason it's done this way---e.g., that
finding the wrong kind of free able page (and _doing_ something
with it) temporarily uses more memory or something.  I'd
think that could be gotten around.  It seems to me that there
has to be a simpler way to do things, but I could be missing
the boat.

Whatever the rationale, I'd like to document it.

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
