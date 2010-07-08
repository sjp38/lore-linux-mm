Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9BCB86B02A3
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 16:32:54 -0400 (EDT)
Date: Thu, 8 Jul 2010 13:31:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 2/2] vmscan: shrink_slab() require number of
 lru_pages, not page order
Message-Id: <20100708133152.5e556508.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1007080901460.9707@router.home>
References: <20100708163401.CD34.A69D9226@jp.fujitsu.com>
	<20100708163934.CD37.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1007080901460.9707@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Jul 2010 09:04:18 -0500 (CDT)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Thu, 8 Jul 2010, KOSAKI Motohiro wrote:
> 
> > Fix simple argument error. Usually 'order' is very small value than
> > lru_pages. then it can makes unnecessary icache dropping.
> 
> AFAICT this is not argument error but someone changed the naming of the
> parameter.

It's been there since day zero:

: commit 2a16e3f4b0c408b9e50297d2ec27e295d490267a
: Author:     Christoph Lameter <clameter@engr.sgi.com>
: AuthorDate: Wed Feb 1 03:05:35 2006 -0800
: Commit:     Linus Torvalds <torvalds@g5.osdl.org>
: CommitDate: Wed Feb 1 08:53:16 2006 -0800
: 
:     [PATCH] Reclaim slab during zone reclaim
:     
:     If large amounts of zone memory are used by empty slabs then zone_reclaim
:     becomes uneffective.  This patch shakes the slab a bit.
:     
:     The problem with this patch is that the slab reclaim is not containable to a
:     zone.  Thus slab reclaim may affect the whole system and be extremely slow.
:     This also means that we cannot determine how many pages were freed in this
:     zone.  Thus we need to go off node for at least one allocation.
:     
:     The functionality is disabled by default.
:     
:     We could modify the shrinkers to take a zone parameter but that would be quite
:     invasive.  Better ideas are welcome.
:     
:     Signed-off-by: Christoph Lameter <clameter@sgi.com>
:     Signed-off-by: Andrew Morton <akpm@osdl.org>
:     Signed-off-by: Linus Torvalds <torvalds@osdl.org>
: 
: diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
: index 4bca2a3..a46c10f 100644
: --- a/Documentation/sysctl/vm.txt
: +++ b/Documentation/sysctl/vm.txt
: @@ -137,6 +137,7 @@ This is value ORed together of
:  1	= Zone reclaim on
:  2	= Zone reclaim writes dirty pages out
:  4	= Zone reclaim swaps pages
: +8	= Also do a global slab reclaim pass
:  
:  zone_reclaim_mode is set during bootup to 1 if it is determined that pages
:  from remote zones will cause a measurable performance reduction. The
: @@ -160,6 +161,11 @@ Allowing regular swap effectively restricts allocations to the local
:  node unless explicitly overridden by memory policies or cpuset
:  configurations.
:  
: +It may be advisable to allow slab reclaim if the system makes heavy
: +use of files and builds up large slab caches. However, the slab
: +shrink operation is global, may take a long time and free slabs
: +in all nodes of the system.
: +
:  ================================================================
:  
:  zone_reclaim_interval:
: diff --git a/mm/vmscan.c b/mm/vmscan.c
: index 9e2ef36..aa4b80d 100644
: --- a/mm/vmscan.c
: +++ b/mm/vmscan.c
: @@ -1596,6 +1596,7 @@ int zone_reclaim_mode __read_mostly;
:  #define RECLAIM_ZONE (1<<0)	/* Run shrink_cache on the zone */
:  #define RECLAIM_WRITE (1<<1)	/* Writeout pages during reclaim */
:  #define RECLAIM_SWAP (1<<2)	/* Swap pages out during reclaim */
: +#define RECLAIM_SLAB (1<<3)	/* Do a global slab shrink if the zone is out of memory */
:  
:  /*
:   * Mininum time between zone reclaim scans
: @@ -1666,6 +1667,19 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
:  
:  	} while (sc.nr_reclaimed < nr_pages && sc.priority > 0);
:  
: +	if (sc.nr_reclaimed < nr_pages && (zone_reclaim_mode & RECLAIM_SLAB)) {
: +		/*
: +		 * shrink_slab does not currently allow us to determine
: +		 * how many pages were freed in the zone. So we just
: +		 * shake the slab and then go offnode for a single allocation.
: +		 *
: +		 * shrink_slab will free memory on all zones and may take
: +		 * a long time.
: +		 */
: +		shrink_slab(sc.nr_scanned, gfp_mask, order);
: +		sc.nr_reclaimed = 1;    /* Avoid getting the off node timeout */
: +	}
: +
:  	p->reclaim_state = NULL;
:  	current->flags &= ~PF_MEMALLOC;

> The "lru_pages" parameter is really a division factor affecting
> the number of pages scanned. This patch increases this division factor
> significantly and therefore reduces the number of items scanned during
> zone_reclaim.
> 

And for that reason I won't apply the patch.  I'd be crazy to do so. 
It tosses away four years testing, replacing it with something which
could have a large effect on reclaim behaviour, with no indication
whether that effect is good or bad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
