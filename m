Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz [195.113.31.123])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA29797
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 06:21:18 -0500
Message-ID: <19990111122039.53340@atrey.karlin.mff.cuni.cz>
Date: Mon, 11 Jan 1999 12:20:39 +0100
From: Pavel Machek <pavel@atrey.karlin.mff.cuni.cz>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
References: <199901101659.QAA00922@dax.scot.redhat.com> <Pine.LNX.3.95.990110103201.7668D-100000@penguin.transmeta.com> <199901102249.WAA01684@dax.scot.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199901102249.WAA01684@dax.scot.redhat.com>; from Stephen C. Tweedie on Sun, Jan 10, 1999 at 10:49:47PM +0000
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Savochkin Andrey Vladimirovich <saw@msu.ru>, Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, "Eric W. Biederman" <ebiederm+eric@ccr.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> In fact, to make it really safe we'd need to avoid synchronous swapout
> altogether: otherwise we can have
> 
> 	    A			kswiod		nbd server process
> 	    lock_super();
> 	    bread(ndb device);
> 	    try_to_free_page();
> 	    rw_swap_page_async();
> 				filemap_write_page();
> 				lock_super();
> 	    wait_on_buffer();
> 						try_to_free_page();
> 						rw_swap_page_sync();
> 						Oops, kswiod is stalled.
> 
> Can we get away without synchronous swapout?  Notice that in this case,
> kswiod may be blocked but kswapd itself will not be.  As long as the nbd
> server does not try to do a synchronous swap, it won't deadlock on
> kswiod.  In other words, it is safe to wait for avaibility of
> another

Is this only matter of nbd? If so, maybe the best solution is to start
claiming: "don't swap over nbd, don't mount localhost drives read
write". [It is bad, but it is probably better than polluting rest of
kernel with nbd workarounds...]

								Pavel
-- 
The best software in life is free (not shareware)!		Pavel
GCM d? s-: !g p?:+ au- a--@ w+ v- C++@ UL+++ L++ N++ E++ W--- M- Y- R+
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
