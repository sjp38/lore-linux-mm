Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA23179
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 15:51:42 -0500
Date: Sun, 10 Jan 1999 12:50:01 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Results: pre6 vs pre6+zlatko's_patch  vs pre5 vs arcavm13
In-Reply-To: <Pine.LNX.3.96.990110213618.543A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.95.990110124737.7668K-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Steve Bergman <steve@netplus.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>



On Sun, 10 Jan 1999, Andrea Arcangeli wrote:
> 
> Steve, could you try the image test in 128Mbyte with this my new patch
> (arca-vm-14) applyed against clean 2.2.0-pre6?

Please don't do this.

>  	do {
>  		int result;
> -		tsk->swap_address = address + PAGE_SIZE;
>  		result = try_to_swap_out(tsk, vma, address, pte, gfp_mask);
> +		address += PAGE_SIZE;
> +		tsk->swap_address = address;

The above is horribly broken, and should be killed on sight.

"swap_address" _must_ be set before try_to_swap_out(), because otherwise
when try-to_swap_out() sleeps any other processes trying to free will
start from the wrong address - unfairly penalizing the process in
question, as the accessed bits have been cleared.

If the above help, it only does so because it is unfair - which _can_ help
simply because other processes run faster.

It looks like you tried to optimize away one add, at the expense of
getting the whole algorithm wrong.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
