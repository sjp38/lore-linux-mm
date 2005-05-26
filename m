Date: Thu, 26 May 2005 04:05:53 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] small valid_swaphandles() optimization
Message-ID: <20050526070552.GA18507@logos.cnet>
References: <20050525134234.GA16054@logos.cnet> <Pine.LNX.4.61.0505260303520.5870@goblin.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0505260303520.5870@goblin.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 26, 2005 at 03:15:16AM +0100, Hugh Dickins wrote:
> On Wed, 25 May 2005, Marcelo Tosatti wrote:
> > 
> > The following patch, relative to valid_swaphandles(), moves the EOF 
> > check outside validity check loop, saving a few instructions. 
> 
> But increasing the function's footprint - though not very excitingly
> either way.  Any benchmarks in support of it ?-)

It moves a comparison outside the loop. You do an add and a
comparison once, instead of 8 comparisons.

It seemed more readable to me, also :) 

> Hmmm.  Doesn't it go wrong on the toff == swapdev->max - 1 case,
> when i becomes 0 then is decremented negative at the end of the loop?

Yikes, indeed. 

> Easily fixed, but suggests your optimization not worth the obfuscation?

ok! probably not worth the trouble. Andrew, please drop it. 

> Hugh
> 
> > --- a/mm/swapfile.c.orig	2005-05-25 15:45:18.000000000 -0300
> > +++ b/mm/swapfile.c	2005-05-25 16:20:45.000000000 -0300
> > @@ -1713,11 +1713,12 @@
> >  		toff++, i--;
> >  	*offset = toff;
> >  
> > +	/* Don't read-ahead past the end of the swap area */
> > +	if (toff+i >= swapdev->max)
> > +		i = swapdev->max - toff - 1;
> > +
> >  	swap_device_lock(swapdev);
> >  	do {
> > -		/* Don't read-ahead past the end of the swap area */
> > -		if (toff >= swapdev->max)
> > -			break;
> >  		/* Don't read in free or bad pages */
> >  		if (!swapdev->swap_map[toff])
> >  			break;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
