Message-ID: <3D24F869.2538BC08@zip.com.au>
Date: Thu, 04 Jul 2002 18:37:45 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: vm lock contention reduction
References: <3D24D4A0.D39B8F2C@zip.com.au> <Pine.LNX.4.44L.0207042027060.6047-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Thu, 4 Jul 2002, Andrew Morton wrote:
> 
> > If the machine is instead full of anon pages then everything is still
> > crap because the page reclaim code is scanning zillions of pages and not
> > doing much useful with them.
> 
> This is something that can be fixed with rmap, because the
> kernel _will_ be able to do something useful with the anon
> pages.

I think that would be quite useful - we just need to be sure that if the
pages aren't added to swapcache we should park them up on the active list
out of the way.

The refill_inactive() logic in 2.5.24 seems a bit wonky at present.
In here:

        ratio = (unsigned long)nr_pages * ps.nr_active /
                                ((ps.nr_inactive | 1) * 2);
        refill_inactive(ratio);

`ratio' tends to evaluate to zero if you have a ton of inactive
or pagecache pages.  So the VM is not recirculating old pages
off the inactive list at all.

I changed it to add 1 to ratio.  Also to only call refill_inactive
when the number-to-process reaches 32 pages - the kernel tends
to settle into steady states where it's calling refill_inactive
for just one or two pages, which is a waste of CPU.

Didn't make much observable difference.

> Now we just need to get Arjan to tune the O(1) page launder
> thing he was looking at ;)

We keep seeing mysterious references to this. What is the idea
behind it?

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
