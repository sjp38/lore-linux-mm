Message-ID: <3B1E61E4.291EF31C@uow.edu.au>
Date: Thu, 07 Jun 2001 03:01:24 +1000
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: [PATCH] reapswap for 2.4.5-ac10
References: <3B1E2C3C.55DF1E3C@uow.edu.au>,
		<3B1E203C.5DC20103@uow.edu.au>,	
	 <l03130308b7439bb9f187@[192.168.239.105]>
	 <l0313030db743d4a05018@[192.168.239.105]> <l0313030fb743f99e010e@[192.168.239.105]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jonathan Morton wrote:
> 
> >> >So the more users, the more slowly it ages.  You get the idea.
> >>
> >> However big you make that scaling constant, you'll always find some pages
> >> which have more users than that.
> >
> >2^24?
> 
> True, you aren't going to find 16 million processes on a box anytime soon.
> However, it still doesn't quite appeal to me - it looks too much like a
> hack.  What happens if, by some freak, someone does build a machine which
> can handle that much?  Consider some future type of machine which is
> essentially a Beowulf cluster with a single address space - I imagine NUMA
> machines are already approaching this size.

Sure.  SPARC has a 24 bit limit on atomic_t, so it'd better
not get too large :)

> >> BUT, as it turns out, refill_inactive_scan() already does ageing down on a
> >> page-by-page basis, rather than process-by-process.
> >
> >Yes.  page->count needs looking at if you're doing physically-addressed
> >scanning.  Rik's patch probably does that.
> 
> Explain...

Rik has a (big) patch which allows reverse lookups - physical back to
virtual.  So rather than scanning multiply mapped pages many times,
each page is scanned but once, and you can go from the physical
page back to all its users' ptes to see if/when any of them have
touched the page.  I think.   It'll be at http://www.surriel.com/patches/
Search for "pmap".

> AFAICT, the scanning in refill_inactive_scan() simply looks at a list of
> pages, and doesn't really do physical addresses.  The age of a page should
> be independent on the number of mappings it has, but dependent instead on
> how much it is used (or how long it is not used for).  That code already
> exists, and it works.

Well, the page will have different ages wrt all the mms which map it.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
