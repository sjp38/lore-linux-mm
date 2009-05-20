Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D58AF6B004D
	for <linux-mm@kvack.org>; Wed, 20 May 2009 06:46:59 -0400 (EDT)
Date: Wed, 20 May 2009 11:47:39 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] clean up setup_per_zone_pages_min
Message-ID: <20090520104739.GD12433@csn.ul.ie>
References: <20090520161853.1bfd415c.minchan.kim@barrios-desktop> <20090520085416.GA27056@csn.ul.ie> <20090520185803.e5b0698a.minchan.kim@barrios-desktop> <20090520102129.GA12433@csn.ul.ie> <20090520193045.2070f7fa.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090520193045.2070f7fa.minchan.kim@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 20, 2009 at 07:30:45PM +0900, Minchan Kim wrote:
> On Wed, 20 May 2009 11:21:29 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Wed, May 20, 2009 at 06:58:03PM +0900, Minchan Kim wrote:
> > > Hi, Mel. 
> > > 
> > > On Wed, 20 May 2009 09:54:16 +0100
> > > Mel Gorman <mel@csn.ul.ie> wrote:
> > > 
> > > > On Wed, May 20, 2009 at 04:18:53PM +0900, Minchan Kim wrote:
> > > > > 
> > > > > Mel changed zone->pages_[high/low/min] with zone->watermark array.
> > > > > So, setup_per_zone_pages_min also have to be changed.
> > > > > 
> > > > 
> > > > Just to be clear, this is a function renaming to match the new zone
> > > > field name, not something I missed. As the function changes min, low and
> > > > max, a better name might have been setup_per_zone_watermarks but whether
> > > 
> > > At first, I thouht, too. But It's handle of min_free_kbytes.
> > > Documentation said, it's to compute a watermark[WMARK_MIN]. 
> > > I think many people already used that knob to contorl pages_min to keep the 
> > > low pages. 
> > 
> > Which documentation?
> 
> Documentation/sysctl/vm.txt - min_free_kbytes.
> 

That documentation states

==== 
This is used to force the Linux VM to keep a minimum number
of kilobytes free.  The VM uses this number to compute a pages_min
value for each lowmem zone in the system.  Each lowmem zone gets
a number of reserved free pages based proportionally on its size.
====

This is true. It just happens in the implementation that sets pages_min
(or it's renamed value) also sets the low and high watermarks are also set
based on the value of the minimum value. It doesn't need to be updated.

> > I'm looking at the function comment and see
> > 
> >  * setup_per_zone_pages_min - called when min_free_kbytes changes.
> >  *
> >  * Ensures that the pages_{min,low,high} values for each zone are set
> >  * correctly with respect to min_free_kbytes.
> > 
> > So, the values of all the watermarks are updated by that function depending
> > on what the new value of min_free_kbytes is. It is a bit wrong I suppose as
> > it missed memory hot-add
> > 
> > setup_per_zone_pages_min - called when min_free_kbytes changes or when memory is hot-added
> 
> God!. I changed this function's comments with memory hot plug. 
> With my mistake, My patch 3/3 lost it. 
> I will add comment about memory hotplug.
> 
> Thanks for pointing me out. :)
> 
> 
> > > 
> > > So, I determined function name is proper now. 
> > > If setup_per_zone_watermark is better than it, we also have to change with 
> > > documentation. 
> > > 
> > > > you go with that name or not, this is better than what is there so;
> > > > 
> > > > Acked-by: Mel Gorman <mel@csn.ul.ie>
> > > 
> > > 
> > > -- 
> > > Kinds Regards
> > > Minchan Kim
> > > 
> > 
> > -- 
> > Mel Gorman
> > Part-time Phd Student                          Linux Technology Center
> > University of Limerick                         IBM Dublin Software Lab
> 
> 
> -- 
> Kinds Regards
> Minchan Kim
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
