Date: Mon, 29 Jan 2001 17:30:13 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Linux-2.4.1-pre11
In-Reply-To: <Pine.LNX.4.10.10101281049240.3812-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0101291717500.1321-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 28 Jan 2001, Linus Torvalds wrote:

> Quite frankly, I suspect I'd like the thing much more if it
> didn't have a "background" flag, but a more specific thing.

> For example, I don't like how the current one has the "oneshot" parameter.
> I'd much rather just have
> 
> 	deactivated = refill_inactive_scan(count);

I have this buried somewhere in the 3 weeks of code I wrote
while at linux.conf.au. I'll dig up some parts of my code and
I'll give it to you ASAP.

>  - refill_inactive_scan() calling convention change: it should be
> 
> 	int refill_inactive_scan(int nr_to_deactivate);
> 
>    and basically return the number of pages it de-activated, with the
>    parameter being how many pages we _want_ to de-activate.

One moment please, I'll make you a patch.  ;)

>  - kswapd, before it calls refill_inactive_scan(), would basically do
>    something like
> 
> 	nr = free_shortage() + inactive_shortage();
> 	if (nr > MAXSCAN)
> 		nr = MAXSCAN;
> 	if (nr || bg_page_aging)
> 		refill_inactive_scan(nr);
> 
>    which again has some _meaning_. You can point to it and say: we want to
>    de-activate "nr" pages because we're short on memory. But even if the
>    answer is "zero", we may want to do some aging in the background, so
>    "refill_inactive_scan()" can know that a zero argument means that we
>    don't _really_ want to deactivate anything.

Wouldn't that be:
	if (nr < MINSCAN)
		nr = MINSCAN;

Btw, if we fix the inactive_shortage() function to take
per-zone inactive shortage into account, we can just skip
scanning if we only have a free shortage but no inactive
shortage.

Page_launder() then needs to be changed a bit too. If it's
called from a user process, it can have the same behaviour
it has now.

OTOH, when it's called from kswapd, kswapd should just flush
as many pages as needed to make the free shortage go away.

Suppose you have a system with 500 kB free shortage. In the
current setup, kswapd will flush MAX_LAUNDER pages and go to
sleep. An alternative would be to let kswapd not go to sleep
when we have a free shortage, but the result of this would
be that kswapd will keep submitting IO until the first 500 kB
is flushed (also wrong).

Only when kswapd submits 500 kB of dirty pages for IO in the
launder loop, everything will work out (didn't submit too much
IO, get the amount of free pages we need).

>  - refill_inactive() can do
> 
> 	count -= refill_inactive_scan(count);

Have you been reading the (partly messy) big snapshot patch
I posted on january 15th? ;)


cheers,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
