Date: Sat, 11 Feb 2006 21:14:37 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Get rid of scan_control
Message-Id: <20060211211437.0633dfdb.akpm@osdl.org>
In-Reply-To: <43EEC136.5060609@yahoo.com.au>
References: <Pine.LNX.4.62.0602092039230.13184@schroedinger.engr.sgi.com>
	<20060211045355.GA3318@dmt.cnet>
	<20060211013255.20832152.akpm@osdl.org>
	<20060211014649.7cb3b9e2.akpm@osdl.org>
	<43EEAC93.3000803@yahoo.com.au>
	<Pine.LNX.4.62.0602111941480.25758@schroedinger.engr.sgi.com>
	<43EEB4DA.6030501@yahoo.com.au>
	<Pine.LNX.4.62.0602112036350.25872@schroedinger.engr.sgi.com>
	<43EEC136.5060609@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: clameter@engr.sgi.com, marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> There are downsides to it. I was basically on the fence with its
>  removal from mainline, because the complexity of parameters going
>  to/from functions make the improvement borderline.
> 
>  But I would have kept it for my internal work, and given Marcelo
>  is also interested in it I guess it could stay for now (unless
>  you trump that with some performance numbers I guess).

I'm wobbly too.  I still hate the thing, but I hate it less after I fixed
up some of its straggliness.

Returning nr_reclaimed up and down the stack makes sense too - I'll try that.

btw, it'd be nice to think of some better function names too.  We have:

	try_to_free_pages
	->shrink_caches
	  ->shrink_zone
	    ->shrink_cache
	      ->shrink_list

which is fairly irrational.

Something like

	try_to_free_pages
	->shrink_zones(struct zone **zones, ..)
	  ->shrink_zone(struct zone *, ...)
	    ->do_shrink_zone(struct zone *, ...)
	      ->shrink_page_list(struct list_head *, ...)

perhaps.  Maybe s/shrink/reclaim/ just to confuse everyone more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
