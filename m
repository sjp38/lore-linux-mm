Date: Wed, 18 Oct 2006 12:38:40 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Page allocator: Single Zone optimizations
Message-Id: <20061018123840.a67e6a44.akpm@osdl.org>
In-Reply-To: <45360CD7.6060202@yahoo.com.au>
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
	<20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com>
	<45347288.6040808@yahoo.com.au>
	<Pine.LNX.4.64.0610171053090.13792@schroedinger.engr.sgi.com>
	<45360CD7.6060202@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Oct 2006 21:15:35 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> > @@ -458,7 +461,8 @@ static inline int is_highmem(struct zone
> >  
> >  static inline int is_normal(struct zone *zone)
> >  {
> > -	return zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
> > +	return SINGLE_ZONE ||
> > +		zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
> >  }
> 
> I don't know if these are any better than ifdef elseif endif. I think
> the goal is not ifdef removal at any cost, but avoiding ifdefs in
> complex functions and within control flow because it makes the code
> less readable.

Certainly readability is a concern.

But the other problem with ifdefs is

#ifdef SOMETHING_WHICH_IS_USUALLY_DEFINED
	stuff_which_works();
#else
	stuff_which_doesnt_compile_or_which_generates_warnings();
#endif


And we do that quite a lot.

Whereas

	if (SOMETHING_WHICH_IS_ZERO_OR_ONE)
		stuff_which_works();
	else
		stuff_which_doesnt_compile_or_which_generates_warnings();

not only loooks heaps better, but the compiler checks it all for us too.

But you knew all that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
