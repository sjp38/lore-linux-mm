Date: Mon, 17 Jul 2000 10:28:11 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
Message-ID: <20000717102811.D5127@redhat.com>
References: <Pine.LNX.4.21.0007111503520.10961-100000@duckman.distro.conectiva> <200007170709.DAA27512@ocelot.cc.gatech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200007170709.DAA27512@ocelot.cc.gatech.edu>; from yannis@cc.gatech.edu on Mon, Jul 17, 2000 at 03:09:06AM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yannis Smaragdakis <yannis@cc.gatech.edu>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, davem@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Jul 17, 2000 at 03:09:06AM -0400, Yannis Smaragdakis wrote:

> Although I agree with Rik in many major points, I disagree in that I
> don't think that page aging should be frequency-based. Overall, I strongly
> believe that frequency is the wrong thing to be measuring for deciding
> which page to evict from RAM. The reason is that a page that is brought
> to memory and touched 1000 times in relatively quick succession is *not*
> more valuable than one that is brought to memory and only touched once. 
> Both will cause exactly one page fault.

Not when you are swapping.  A page which is likely to be touched again
in the future will cause further page faults if we evict it.  A page
which isn't going to be touched again can be evicted without that
penalty.  The past behaviour is only useful in as much as it provides
a way of guessing future behaviour, and we want to make sure that we
evict those pages least likely to be touched again in the near future.
Access frequency *is* a credible way of assessing that, as there are
many common access patterns in which a large volume of data is
accessed exactly once --- LRU breaks down completely in that case, LFU
does not.

> Also, one should be cautious of
> pages that are brought in RAM, touched many times, but then stay untouched
> for a long time. Frequency should never outweigh recency--the latter is
> a better predictor, as OS designers have found since the early 70s.

No, they have not.  Look at the literature and you will see that OS
designers keep peppering their code with large numbers of special
cases to cope with the fact that LRU breaks down on large sequential
accesses.  FreeBSD, which uses a LFU-based design, needs no such
special cases.

> Having said that, LRU is certainly broken, but there are other ways to
> fix it.

Right.  LFU is just one way of fixing LRU.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
