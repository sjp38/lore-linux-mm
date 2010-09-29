Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9226F6B004A
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 10:42:24 -0400 (EDT)
Date: Wed, 29 Sep 2010 15:41:59 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: zone state overhead
Message-ID: <20100929144159.GC14204@csn.ul.ie>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com> <alpine.DEB.2.00.1009280736020.4144@router.home> <20100928133059.GL8187@csn.ul.ie> <alpine.DEB.2.00.1009282024570.31551@chino.kir.corp.google.com> <20100929100307.GA14204@csn.ul.ie> <alpine.DEB.2.00.1009290736280.30777@router.home> <20100929141730.GB14204@csn.ul.ie> <alpine.DEB.2.00.1009290930360.1538@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009290930360.1538@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 29, 2010 at 09:34:09AM -0500, Christoph Lameter wrote:
> On Wed, 29 Sep 2010, Mel Gorman wrote:
> 
> > > Updating the threshold also is expensive.
> >
> > Even if it's moved to a read-mostly part of the zone such as after
> > lowmem_reserve?
> 
> The threshold is stored in the hot part of the per cpu page structure.
> 

And the consequences of moving it? In terms of moving, it would probably
work out better to move percpu_drift_mark after the lowmem_reserve and
put the threshold after it so they're at least similarly hot across
CPUs.

> > > I thought more along the lines
> > > of reducing the threshold for good if the VM runs into reclaim trouble
> > > because of too high fuzziness in the counters.
> > >
> >
> > That would be unfortunate as it would only take trouble to happen once
> > for performance to be impaired for the remaining uptime of the machine.
> 
> Reclaim also impairs performance and inaccurate counters may cause
> unnecessary reclaim.

Ah, it's limited to be fair. You might end up reclaiming "maximum drift"
number of pages you didn't need to but that doesn't seem as bad.

> Ultimately this is a tradeoff. The current thresholds
> were calculated so that there will be zero impact even for very large
> configurations where all processors continual page fault. I think we have
> some leeway to go lower there. The tuning situation was a bit extreme.
> 

Ok.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
