Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 451478D003B
	for <linux-mm@kvack.org>; Fri,  8 Apr 2011 09:23:20 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p38D7gZO011000
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 07:07:42 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p38DNBKf104580
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 07:23:12 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p38DNAMC013109
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 07:23:10 -0600
Subject: Re: [PATCH] print vmalloc() state after allocation failures
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110408001942.GC2874@cmpxchg.org>
References: <20110407172302.3B7546DA@kernel>
	 <20110408001942.GC2874@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Fri, 08 Apr 2011 06:23:08 -0700
Message-ID: <1302268988.8184.6890.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, 2011-04-07 at 17:19 -0700, Johannes Weiner wrote:
> On Thu, Apr 07, 2011 at 10:23:02AM -0700, Dave Hansen wrote:
> > @@ -1579,6 +1579,18 @@ static void *__vmalloc_area_node(struct 
> >  	return area->addr;
> >  
> >  fail:
> > +	if (!(gfp_mask & __GFP_NOWARN) && printk_ratelimit()) {
> 
> There is a comment above the declaration of printk_ratelimit:
> 
> /*
>  * Please don't use printk_ratelimit(), because it shares ratelimiting state
>  * with all other unrelated printk_ratelimit() callsites.  Instead use
>  * printk_ratelimited() or plain old __ratelimit().
>  */
> 
> I realize that the page allocator does it the same way, but I think it
> should probably be fixed in there, rather than spread any further.

You're the second person to mention this.  I should have listened the
first time. :)  I'll fix it up and repost.

> > +		/*
> > +		 * We probably did a show_mem() and a stack dump above
> > +		 * inside of alloc_page*().  This is only so we can
> > +		 * tell how big the vmalloc() really was.  This will
> > +		 * also not be exactly the same as what was passed
> > +		 * to vmalloc() due to alignment and the guard page.
> > +		 */
> > +		printk(KERN_WARNING "%s: vmalloc: allocation failure, "
> > +			"allocated %ld of %ld bytes\n", current->comm,
> > +			(area->nr_pages*PAGE_SIZE), area->size);
> > +	}
> 
> To me, this does not look like something that should just be appended
> to the whole pile spewed out by dump_stack() and show_mem().  What do
> you think about doing the page allocation with __GFP_NOWARN and have
> the full report come from this place, with the line you introduce as
> leader?

That sounds fine to me.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
