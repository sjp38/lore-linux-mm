Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
References: <Pine.LNX.4.21.0007171149440.30603-100000@duckman.distro.conectiva>
From: "John Fremlin" <vii@penguinpowered.com>
Date: 17 Jul 2000 20:57:48 +0100
In-Reply-To: Rik van Riel's message of "Mon, 17 Jul 2000 11:53:48 -0300 (BRST)"
Message-ID: <m2snt8bkcj.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Yannis Smaragdakis <yannis@cc.gatech.edu>, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, davem@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

[...]

> Both LRU and LFU break down on linear accesses to an array
> that doesn't fit in memory. In that case you really want
> MRU replacement, with some simple code that "detects the
> window size" you need to keep in memory. This seems to be
> the only way to get any speedup on such programs when you
> increase memory size to something which is still smaller
> than the total program size.

I think that a generational garbage collection like scheme might work
well here (also obviating the need for the "simple code"). 

In more detail: you keep a bunch of (possibly just 2) lists of pages
(generations). Every time you want pages you search the younger lists
first; if a page is still being used (how to measure this? -- if it's
faulted back quickly off of the scavenge list?) it gets promoted to
the next generation and scanned less often. This could be tuned to
deal well with the pathological streaming IO case (i.e. even the app
doing the IO doesn't suffer at all), I don't know how well in general.

I hope this stuff isn't just reiterating the obvious (alternatively I
hope it isn't too obvious I don't know what I'm talking about ;-) ).

-- 

	http://web.onetel.net.uk/~elephant/john
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
