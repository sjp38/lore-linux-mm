Date: Tue, 24 Apr 2001 09:38:08 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] swap-speedup-2.4.3-B3
In-Reply-To: <Pine.LNX.4.30.0104240714200.1227-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0104240932570.15791-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Szabolcs Szakacsits <szaka@f-secure.com>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Apr 2001, Ingo Molnar wrote:
> 
> the latest swap-speedup patch can be found at:

Please don't add more of those horrible "wait" arguments.

Make two different versions of a function instead. It's going to clean up
and simplify the code, and there really isn't any reason to do what you're
doing.

You should split up the logic differently: if you want to wait for the
page, then DO so:

	page = lookup_swap_cache(..);
	if (page) {
		wait_for_swap_cache:valid(page);
		.. use page ..
	}

Note how much more readable and UNDERSTANDABLE the above is, compared to

	page = lookup_swap_cache(..., 1);
	if (page) {
		...

and note also how splitting up the waiting will

 - simplify the swap cache lookup function, making it faster for people
   who do _NOT_ want to wait.

 - make it easier to statically check the correctness of programs by just
   eye-balling them ("Hey, he's calling 'wait' with the spinlock held").

 - more easily moving the wait around, allowing for more concurrency.

Basically, I don't want to mix synchronous and asynchronous
interfaces. Everything should be asynchronous by default, and waiting
should be explicit.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
