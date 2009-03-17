Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2F18A6B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 06:11:12 -0400 (EDT)
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.14.3/8.13.8) with ESMTP id n2HAB8Z2228534
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 10:11:09 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2HAB8x82646144
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 10:11:08 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2HAB8TW021144
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 10:11:08 GMT
Date: Tue, 17 Mar 2009 11:11:06 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: oom-killer killing even if memory is available?
Message-ID: <20090317111106.1fb3f919@osiris.boeblingen.de.ibm.com>
In-Reply-To: <200903172051.13907.nickpiggin@yahoo.com.au>
References: <20090317100049.33f67964@osiris.boeblingen.de.ibm.com>
	<200903172051.13907.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andreas Krebbel <krebbel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Mar 2009 20:51:13 +1100
Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> On Tuesday 17 March 2009 20:00:49 Heiko Carstens wrote:
> > the below looks like there is some bug in the memory management code.
> > Even if there seems to be plenty of memory available the oom-killer
> > kills processes.
> >
> > The below happened after 27 days uptime, memory seems to be heavily
> > fragmented,
> 
> What slab allocator are you using?

That was SLAB.

> > but there are stills larger portions of memory free that
> > could satisfy an order 2 allocation. Any idea why this fails?
> 
> We still keep some watermarks around for higher order pages (for
> GFP_ATOMIC and page reclaim etc purposes).
> 
> Possibly it is being a bit aggressive with the higher orders; when I
> added it I just made a guess at a sane function. See
> mm/page_alloc.c:zone_watermark_ok(). In particular, the for loop at the
> end of the function is the slowpath where it is calculating higher
> order watermarks. The min >>= 1 statement, 1 could be replaced with 2.
> Or we could just keep reserves for 0..PAGE_ALLOC_COSTLY_ORDER and then
> give away _any_ free pages for higher orders than that.
> 
> Still would seem to just prolong the inevitable? Exploding after 27 days
> of uptime is rather sad :(

Yes, it seems to look more like a memory leak. Hmm..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
