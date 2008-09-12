Date: Fri, 12 Sep 2008 19:58:18 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Mark the correct zone as full when scanning zonelists
Message-ID: <20080912185817.GA20056@csn.ul.ie>
References: <20080911212550.GA18087@csn.ul.ie> <20080911144155.c70ef145.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080911144155.c70ef145.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On (11/09/08 14:41), Andrew Morton didst pronounce:
> On Thu, 11 Sep 2008 22:25:51 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > The for_each_zone_zonelist() uses a struct zoneref *z cursor when scanning
> > zonelists to keep track of where in the zonelist it is. The zoneref that
> > is returned corresponds to the the next zone that is to be scanned, not
> > the current one as it originally thought of as an opaque list.
> > 
> > When the page allocator is scanning a zonelist, it marks zones that it
> > temporarily full zones to eliminate near-future scanning attempts.
> 
> That sentence needs help.
> 

I've posted a revised leader below.

> > It uses
> > the zoneref for the marking and consequently the incorrect zone gets marked
> > full. This leads to a suitable zone being skipped in the mistaken belief
> > it is full. This patch corrects the problem by changing zoneref to be the
> > current zone being scanned instead of the next one.
> 
> Applicable to 2.6.26 as well, yes?
> 

Yes. I was going to get it right for mainline first before posting to
stable.

> 
> Someone reported a bug a few weeks ago which I think this patch will fix,
> yes?  I don't remember who that was, nor do I recall the precise details
> of what the userspace-visible (mis)behaviour was.
> 
> Are you able to fill in the gaps here?  Put yourself in the position of
> a poor little -stable maintainer scratching his head wondering ytf he
> was sent this patch.
> 

I'm not aware of this bug but I'll go digging for it and see what I
find. Thanks

=== Begin revised changelog ===

The iterator for_each_zone_zonelist() uses a struct zoneref *z cursor when
scanning zonelists to keep track of where in the zonelist it is. The zoneref
that is returned corresponds to the the next zone that is to be scanned,
not the current one. It was intended to be treated as an opaque list.

When the page allocator is scanning a zonelist, it marks elements in the
zonelist corresponding to zones that are temporarily full. As the zonelist
is being updated, it uses the cursor here;

  if (NUMA_BUILD)
        zlc_mark_zone_full(zonelist, z);

This is intended to prevent rescanning in the near future but the zoneref
cursor does not correspond to the zone that has been found to be full. This is
an easy misunderstanding to make so this patch corrects the problem by changing
zoneref cursor to be the current zone being scanned instead of the next one.

This issue affects 2.6.26.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
