Date: Wed, 2 Jul 2008 21:43:05 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [problem] raid performance loss with 2.6.26-rc8 on 32-bit x86
 (bisected)
In-Reply-To: <20080703042750.GB14614@csn.ul.ie>
Message-ID: <alpine.LFD.1.10.0807022135360.18105@woody.linux-foundation.org>
References: <1214877439.7885.40.camel@dwillia2-linux.ch.intel.com> <20080701080910.GA10865@csn.ul.ie> <20080701175855.GI32727@shadowen.org> <20080701190741.GB16501@csn.ul.ie> <1214944175.26855.18.camel@dwillia2-linux.ch.intel.com> <20080702051759.GA26338@csn.ul.ie>
 <1215049766.2840.43.camel@dwillia2-linux.ch.intel.com> <20080703042750.GB14614@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Dan Williams <dan.j.williams@intel.com>, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, NeilBrown <neilb@suse.de>, babydr@baby-dragons.com, cl@linux-foundation.org, lee.schermerhorn@hp.com, a.beregalov@gmail.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>


On Thu, 3 Jul 2008, Mel Gorman wrote:

> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.26-rc8-clean/mm/page_alloc.c linux-2.6.26-rc8-fix-kswapd-on-numa/mm/page_alloc.c
> --- linux-2.6.26-rc8-clean/mm/page_alloc.c	2008-06-24 18:58:20.000000000 -0700
> +++ linux-2.6.26-rc8-fix-kswapd-on-numa/mm/page_alloc.c	2008-07-02 21:14:16.000000000 -0700
> @@ -2328,7 +2328,8 @@ static void build_zonelists(pg_data_t *p
>  static void build_zonelist_cache(pg_data_t *pgdat)
>  {
>  	pgdat->node_zonelists[0].zlcache_ptr = NULL;
> -	pgdat->node_zonelists[1].zlcache_ptr = NULL;
> +	if (NUMA_BUILD)
> +		pgdat->node_zonelists[1].zlcache_ptr = NULL;
>  }

This makes no sense.

That whole thing is inside a

	#ifdef CONFIG_NUMA
	... numa code ..
	#else
	... this code ..
	#endif

so CONFIG_NUMA will _not_ be set, and NUMA_BUILD is always 0.

So why do that

	if (NUMA_BUILD)
		..

at all, when it is known to be false?

So the patch may be correct, but wouldn't it be better to just remove the 
line entirely, instead of moving it into a conditional that cannot be 
true?

Also, I'm not quite seeing why those zonelists should be zeroed out at 
all. Shouldn't a non-NUMA setup always aim to have node_zonelists[0] == 
node_zonelists[1] == all appropriate zones?

I have to say, the whole mmzoen thing is confusing. The code makes my eyes 
bleed. I can't really follow it.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
