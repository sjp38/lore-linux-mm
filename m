Received: from d1o43.telia.com (d1o43.telia.com [194.22.195.241])
	by maile.telia.com (8.9.3/8.9.3) with ESMTP id CAA19419
	for <linux-mm@kvack.org>; Thu, 8 Jun 2000 02:06:10 +0200 (CEST)
Received: from norran.net (roger@t8o43p27.telia.com [194.237.168.207])
	by d1o43.telia.com (8.8.8/8.8.8) with ESMTP id CAA12876
	for <linux-mm@kvack.org>; Thu, 8 Jun 2000 02:06:09 +0200 (CEST)
Message-ID: <393EE2FA.43690671@norran.net>
Date: Thu, 08 Jun 2000 02:04:10 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: reduce shrink_mmap rate of failure (initial attempt)
References: <01BFD09A.CC430AF0@lando.optronic.se>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi again,

There is an even more likely scenario...

* shrink_mmap is called when no zone is under pressure.
  then it will search the list over and over again...

Who could do such a nasty thing?

do_try_to_free_pages !

  Its agenda is not to stop when there is no pressure - it will go on
  until FREE_COUNT (8) pages are freed...

Even in the normal ac10 this should be a problem.
Several turns in do_try_to_free_pages with shrink_mmap failing will be
done - each swapping out some pages...

It will take time and swap...

/RogerL


Roger Larsson wrote:
> 
> >That patch hangs my machine here when I run mmap002.  The machine is
> >in shrink_mmap.  It hangs trying to get the pagmap_lru_lock.
> >
> >I think that the idea is good, but it doesn't work here :(.
> >
> >Later, Juan.
> 
> Ouch...
> 
> The only possible explaination is that we are searching for pages on a zone.
> But no such pages are possible to free from LRU...
> And we LOOP the list, holding the lru lock...
> Note: without this patch you may end up in another bad situation where
> shrink_mmap always fails and swapping will start until it swaps out a page
> of that specific zone.
> And without the test? We would free all other LRU pages without finding one
> that we want :-(
> 
> This will be interesting to fix...
> 
> May the allocation of pages play a part? Filling zone after zone will give no
> mix between the zones.
> 
> /RogerL
> (from work)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
