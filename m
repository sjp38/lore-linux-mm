From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200001131852.KAA85109@google.engr.sgi.com>
Subject: Re: [RFC] 2.3.39 zone balancing
Date: Thu, 13 Jan 2000 10:52:51 -0800 (PST)
In-Reply-To: <Pine.LNX.4.10.10001131430520.13454-100000@mirkwood.dummy.home> from "Rik van Riel" at Jan 13, 2000 02:40:14 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: torvalds@transmeta.com, mingo@chiara.csoma.elte.hu, andrea@suse.de, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> On Wed, 12 Jan 2000, Kanoj Sarcar wrote:
> 
> > --- mm/page_alloc.c	Tue Jan 11 11:00:31 2000
> > +++ mm/page_alloc.c	Tue Jan 11 23:59:35 2000
> > +		cumulative += size;
> > +		mask = (cumulative >> 7);
> > +		if (mask < 1) mask = 1;
> > +		zone->pages_low = mask*2;
> > +		zone->pages_high = mask*3;
> >  		zone->low_on_memory = 0;
> 
> I think that busier machines probably have a larger need
> for DMA memory than this code fragment will give us. I
> have the gut feeling that we'll want to keep about 512kB
> or more free in the lower 16MB of busy machines...

Note that as I point out in my documentation, and as Alan
also points out, 2.2 is doing fine. The 2.2 code does not
guarantee dma-zone balancing even if it is empty (if there
is enough regular free pages). Which means all dma requests
will fail. I have tried to fix that, since with HIGHMEM, 
the problem is actually more aggravated.

My aim is to fix a couple of problems, move to a zone based
balancing, and then maybe finetune it. For example, the 
>> 7 part can be replaced with >> N, where N is dependent 
on the zone type, or size of lower zones, etc. I mention this
in the doc too. The only problem is, if N < 7, you will probably
have degraded perfomance in certain cases due to more frequent
balancing.

> 
> (if only because such a large amount of free pages in
> such a small part of the address space will give us
> higher-order free pages)

I note that Andrea also commented about this. I am also
of the same opinion as him, we should not (as far as possible)
try to intermingle unrelated issues. In this case though,
I have no idea how having a large number of free dma pages
ensures more higher-order free pages. Can someone give me
the logic for this claim?

> 
> > --- mm/vmscan.c	Tue Jan 11 11:00:31 2000
> > +++ mm/vmscan.c	Tue Jan 11 23:29:41 2000
> > @@ -534,8 +534,11 @@
> >  	int retval = 1;
> >  
> >  	wake_up_process(kswapd_process);
> > -	if (gfp_mask & __GFP_WAIT)
> > +	if (gfp_mask & __GFP_WAIT) {
> > +		current->flags |= PF_MEMALLOC;
> >  		retval = do_try_to_free_pages(gfp_mask, zone);
> > +		current->flags &= ~PF_MEMALLOC;
> > +	}
> >  	return retval;
> >  }
> 
> Please note that kswapd still exits when the total number
> of free pages in the system is high enough. Balancing can
> probably better be done in the background by kswapd than
> by applications that happen to stumble across a nonbalanced
> zone...

Yes, we need to decide whether kswapd needs modification too. Its
just that I want to do incremental fixes, instead of change a 
huge bunch of code all at once. The question is, if I had a Linux
2.3 kernel, where I had completely deleted kswapd(), what problems 
would the kernel face? Ie, what is kswapd()'s purpose?

Kanoj

> 
> regards,
> 
> Rik
> --
> The Internet is not a network of computers. It is a network
> of people. That is its real strength.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
