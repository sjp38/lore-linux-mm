Date: Mon, 17 Jul 2000 11:53:48 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
In-Reply-To: <20000717102811.D5127@redhat.com>
Message-ID: <Pine.LNX.4.21.0007171149440.30603-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Yannis Smaragdakis <yannis@cc.gatech.edu>, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, davem@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 17 Jul 2000, Stephen C. Tweedie wrote:
> On Mon, Jul 17, 2000 at 03:09:06AM -0400, Yannis Smaragdakis wrote:
> 
> > Although I agree with Rik in many major points, I disagree in that I
> > don't think that page aging should be frequency-based. Overall, I strongly
> > believe that frequency is the wrong thing to be measuring for deciding
> > which page to evict from RAM. The reason is that a page that is brought
> > to memory and touched 1000 times in relatively quick succession is *not*
> > more valuable than one that is brought to memory and only touched once. 
> > Both will cause exactly one page fault.
> 
> Not when you are swapping.  A page which is likely to be touched
> again in the future will cause further page faults if we evict
> it.  A page which isn't going to be touched again can be evicted
> without that penalty.  The past behaviour is only useful in as
> much as it provides a way of guessing future behaviour, and we
> want to make sure that we evict those pages least likely to be
> touched again in the near future. Access frequency *is* a
> credible way of assessing that, as there are many common access
> patterns in which a large volume of data is accessed exactly
> once --- LRU breaks down completely in that case, LFU does not.

*nod*

LFU works great in preventing typical LRU breakdown in some
common situations, but pure page aging isn't enough either...

> > Also, one should be cautious of
> > pages that are brought in RAM, touched many times, but then stay untouched
> > for a long time. Frequency should never outweigh recency--the latter is
> > a better predictor, as OS designers have found since the early 70s.
> 
> No, they have not.  Look at the literature and you will see that OS
> designers keep peppering their code with large numbers of special
> cases to cope with the fact that LRU breaks down on large sequential
> accesses.  FreeBSD, which uses a LFU-based design, needs no such
> special cases.

Actually, FreeBSD has a special case in the page fault code
for sequential accesses and I believe we must have that too.

Both LRU and LFU break down on linear accesses to an array
that doesn't fit in memory. In that case you really want
MRU replacement, with some simple code that "detects the
window size" you need to keep in memory. This seems to be
the only way to get any speedup on such programs when you
increase memory size to something which is still smaller
than the total program size.

> > Having said that, LRU is certainly broken, but there are other ways to
> > fix it.
> 
> Right.  LFU is just one way of fixing LRU.

Since *both* recency and frequency are important, we can
simply use an algorithm which keeps both into account.
Page aging nicely fits the bill here.

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
