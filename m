Date: Thu, 3 Jul 2008 06:00:36 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [problem] raid performance loss with 2.6.26-rc8 on 32-bit x86 (bisected)
Message-ID: <20080703050036.GD14614@csn.ul.ie>
References: <1214877439.7885.40.camel@dwillia2-linux.ch.intel.com> <20080701080910.GA10865@csn.ul.ie> <20080701175855.GI32727@shadowen.org> <20080701190741.GB16501@csn.ul.ie> <1214944175.26855.18.camel@dwillia2-linux.ch.intel.com> <20080702051759.GA26338@csn.ul.ie> <1215049766.2840.43.camel@dwillia2-linux.ch.intel.com> <20080703042750.GB14614@csn.ul.ie> <alpine.LFD.1.10.0807022135360.18105@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0807022135360.18105@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, NeilBrown <neilb@suse.de>, babydr@baby-dragons.com, cl@linux-foundation.org, lee.schermerhorn@hp.com, a.beregalov@gmail.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On (02/07/08 21:43), Linus Torvalds didst pronounce:
> 
> 
> On Thu, 3 Jul 2008, Mel Gorman wrote:
> 
> > diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.26-rc8-clean/mm/page_alloc.c linux-2.6.26-rc8-fix-kswapd-on-numa/mm/page_alloc.c
> > --- linux-2.6.26-rc8-clean/mm/page_alloc.c	2008-06-24 18:58:20.000000000 -0700
> > +++ linux-2.6.26-rc8-fix-kswapd-on-numa/mm/page_alloc.c	2008-07-02 21:14:16.000000000 -0700
> > @@ -2328,7 +2328,8 @@ static void build_zonelists(pg_data_t *p
> >  static void build_zonelist_cache(pg_data_t *pgdat)
> >  {
> >  	pgdat->node_zonelists[0].zlcache_ptr = NULL;
> > -	pgdat->node_zonelists[1].zlcache_ptr = NULL;
> > +	if (NUMA_BUILD)
> > +		pgdat->node_zonelists[1].zlcache_ptr = NULL;
> >  }
> 
> This makes no sense.
> 
> That whole thing is inside a
> 
> 	#ifdef CONFIG_NUMA
> 	... numa code ..
> 	#else
> 	... this code ..
> 	#endif
> 
> so CONFIG_NUMA will _not_ be set, and NUMA_BUILD is always 0.
> 
> So why do that
> 
> 	if (NUMA_BUILD)
> 		..
> 
> at all, when it is known to be false?
> 

Because I'm a muppet and a bit cross-eyed from looking at this until the
problem would reveal itself. I knew this is needed fixing but choose the
most stupid way possible to fix it.

> So the patch may be correct, but wouldn't it be better to just remove the 
> line entirely, instead of moving it into a conditional that cannot be 
> true?
> 

Yes, revised patch below. Same fix, more sensible.

> Also, I'm not quite seeing why those zonelists should be zeroed out at 
> all. Shouldn't a non-NUMA setup always aim to have node_zonelists[0] == 
> node_zonelists[1] == all appropriate zones?
> 

node_zonelists[1] doesn't exist at all on non-NUMA so there is only
node_zonelists[0] that is all appropriate zones.

> I have to say, the whole mmzoen thing is confusing. The code makes my eyes 
> bleed. I can't really follow it.

I'm looking at this too long to comment with anything other than a blank
stare :/

====
Subject: [PATCH] Do not overwrite nr_zones on !NUMA when initialising zlcache_ptr

With the two-zonelist patches on !NUMA machines, there really is only one
zonelist as __GFP_THISNODE is meaningless. However, during initialisation, the
assumption is made that two zonelists exist when initialising zlcache_ptr. The
result is that pgdat->nr_zones is always 0. As kswapd uses this value to
determine what reclaim work is necessary, the result is that kswapd never
reclaims. This causes processes to stall frequently in low-memory situations
as they always direct reclaim.  This patch initialises zlcache_ptr correctly.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 page_alloc.c |    1 -
 1 file changed, 1 deletion(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.26-rc8-clean/mm/page_alloc.c linux-2.6.26-rc8-fix-kswapd-on-numa/mm/page_alloc.c
--- linux-2.6.26-rc8-clean/mm/page_alloc.c	2008-06-24 18:58:20.000000000 -0700
+++ linux-2.6.26-rc8-fix-kswapd-on-numa/mm/page_alloc.c	2008-07-02 21:49:09.000000000 -0700
@@ -2328,7 +2328,6 @@ static void build_zonelists(pg_data_t *p
 static void build_zonelist_cache(pg_data_t *pgdat)
 {
 	pgdat->node_zonelists[0].zlcache_ptr = NULL;
-	pgdat->node_zonelists[1].zlcache_ptr = NULL;
 }
 
 #endif	/* CONFIG_NUMA */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
