Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA24643
	for <linux-mm@kvack.org>; Mon, 21 Dec 1998 13:59:28 -0500
Date: Mon, 21 Dec 1998 18:59:05 GMT
Message-Id: <199812211859.SAA02961@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <Pine.LNX.3.95.981221095438.6187B-100000@penguin.transmeta.com>
References: <199812211637.QAA02759@dax.scot.redhat.com>
	<Pine.LNX.3.95.981221095438.6187B-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@e-mind.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 21 Dec 1998 09:58:10 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> I'm testing it now - the problem is probably just due to my mixing up the
> pre-2 and pre-3 patches, and pre-3 got the "timid" memory freeing
> parameters even though the whole point of the pre-3 approach is that it
> isn't needed any more.

Yep, and although things did improve when I restored some of that
aggressiveness (initial priority = 6 again), it was still mondo slow
on 8MB.  I also restored the swapout loop (so that the foreground
try_to_free_page() takes a swap cluster argument again, rather than
always freeing just one page at a time); still no improvement (which
actually surprised me --- I guess that kswapd is doing clustering for
swapout well enough on its own).

>> You simply CANNOT tell from looking at the code that it "will
>> work well for everybody out there on every hardware".  

> Agreed.

> However, I very much believe that tweaking comes _after_ the basic
> arhictecture is right. 

Right.

> As such, your "current != kswapd" tweak gave a whopping good hint about
> what the architecture _should_ be. And we'll be zeroing in on something
> that has both the performance and the architecture right. 

Sure: I think we can agree that the most important principle in this
respect is that the foreground and background swapping tasks may be
similar but they do not _need_ to be the same, and they may well have
different requirements.

Linus, would it help at all if I just sat down and recoded the VM I'm
running now in a manner which makes the design obvious?  In other
words, clearly separate out the foreground and background paths as you
have done, with the "current != kswapd" test removed and the
foreground-specific code in its own, identifiable code path, but
preserving the actual algorithm?

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
