Received: from cs.utexas.edu (root@cs.utexas.edu [128.83.139.9])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA09042
	for <linux-mm@kvack.org>; Tue, 12 Jan 1999 11:59:13 -0500
Message-Id: <199901121658.KAA28147@feta.cs.utexas.edu>
From: "Paul R. Wilson" <wilson@cs.utexas.edu>
Date: Tue, 12 Jan 1999 10:58:52 -0600
Subject: Re: question about try_to_swap_out()
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>From sct@redhat.com Tue Jan 12 10:10:50 1999
>From: "Stephen C. Tweedie" <sct@redhat.com>
>Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
>Subject: Re: question about try_to_swap_out()
>
>Hi,
>
>On Sun, 10 Jan 1999 21:38:46 -0600, "Paul R. Wilson"
><wilson@cs.utexas.edu> said:
>
>> After checking that that a page is present and pageable, try_to_swap_out()
>> checks to see if the page is reserved or locked or not DMA'able when
>> where looking for a DMA page.  If any of these three things is
>> true, it returns 0 without changing anything.
>
>> It seems to me that it should go ahead and check the pte age bit,
>> and update the page frame's PG_referenced bit, before returning 0.
>
>Not really.  Reserved pages never get swapped anyway.

Right.  Not only that, they're very seldom touched, so the pte bit
will generally not be set, and the branch won't be taken.  [ As I
understand it, reserved pages are not generally used at all---or
am I really mistaken, and they're reserved for important purposes
rather than being a pool of pages that's only used in an extreme
pinch? ]

>  For DMA, we don't
>want to disturb non-DMA processes at all --- the demand for DMA and
>non-DMA pages might be very different.

I guess I don't understand what's going on with DMA pages.  (And I need
to, for Part II of the Linux VM doc I'm writing.)

I've been under the impression that the DMA flag in the page struct
was describing the page frame, and whether it's DMAable (not describing
whether there was a DMA going on).  As I [mis?] understood it, this
is used on platforms where some memory is DMA'able and some isn't, 
but a page used for VM might or might not be DMA'able.  (Is that
wrong?  I've been wondering. I'd think you'd DMA into and out
of page frames for paging.)

I would think that it could be significant if you're skipping DMA
pages, which are valuable.  You want to get them back in a timely
manner, so you want to go ahead and age them normally.

>For locked pages, we expect this
>to be sufficiently rare that it's totally irrelevant whether we age the
>page or not.

Right.  So I figured it wouldn't hurt to do it the conceptually
"Right" way.  I figured that if a locked page was not being touched
by teh program, it should be aging normally---the aging stuff is
about recording what the program is doing with the pages, not about
what the VM system chooses to do behind the program's back.

>> Am I off-base here, or should the conditional that checks to see
>> whether a page is young (and updates the reference bits) be moved
>> up ahead of the conditional that checks to see whether a page
>> is (reserved | locked | not-dma-but-we-need-dma)?
>
>I really don't think it's that important!

I didn't think it was important, but couldn't be sure.  There's
lots of weirdness in the VM code, such that it's hard to tell
what is weird for a really good reason, and what's weird for
no particular reason, and what's weird because it matters a little
bit, but not much.  It's fairly confusing for a newbie---you just
can't tell what's what, half the time.

In general, it would be nice if the code just made sense when
you read it, and this is one of those cases where you just go
"huh?" and start doubting that you have any idea what the issues
are.

At any rate, thanks for the clarification, and thanks in advance
for any further clarifications.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
