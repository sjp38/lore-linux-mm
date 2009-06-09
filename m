Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9C76B005A
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 04:21:21 -0400 (EDT)
Date: Tue, 9 Jun 2009 09:50:38 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] Do not unconditionally treat zones that fail
	zone_reclaim() as full
Message-ID: <20090609085037.GI18380@csn.ul.ie>
References: <1244466090-10711-1-git-send-email-mel@csn.ul.ie> <1244466090-10711-4-git-send-email-mel@csn.ul.ie> <20090609031119.GB7875@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090609031119.GB7875@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "linuxram@us.ibm.com" <linuxram@us.ibm.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 11:11:19AM +0800, Wu Fengguang wrote:
> On Mon, Jun 08, 2009 at 09:01:30PM +0800, Mel Gorman wrote:
> > On NUMA machines, the administrator can configure zone_reclaim_mode that
> > is a more targetted form of direct reclaim. On machines with large NUMA
> > distances for example, a zone_reclaim_mode defaults to 1 meaning that clean
> > unmapped pages will be reclaimed if the zone watermarks are not being
> > met. The problem is that zone_reclaim() failing at all means the zone
> > gets marked full.
> > 
> > This can cause situations where a zone is usable, but is being skipped
> > because it has been considered full. Take a situation where a large tmpfs
> > mount is occuping a large percentage of memory overall. The pages do not
> > get cleaned or reclaimed by zone_reclaim(), but the zone gets marked full
> > and the zonelist cache considers them not worth trying in the future.
> > 
> > This patch makes zone_reclaim() return more fine-grained information about
> > what occured when zone_reclaim() failued. The zone only gets marked full if
> > it really is unreclaimable. If it's a case that the scan did not occur or
> > if enough pages were not reclaimed with the limited reclaim_mode, then the
> > zone is simply skipped.
> > 
> > There is a side-effect to this patch. Currently, if zone_reclaim()
> > successfully reclaimed SWAP_CLUSTER_MAX, an allocation attempt would
> > go ahead. With this patch applied, zone watermarks are rechecked after
> > zone_reclaim() does some work.
> >
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> Thanks for making the code a lot more readable :)
> 
> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
> 

Thanks.

> >  	/*
> >  	 * Do not scan if the allocation should not be delayed.
> >  	 */
> >  	if (!(gfp_mask & __GFP_WAIT) || (current->flags & PF_MEMALLOC))
> > -			return 0;
> > +			return ZONE_RECLAIM_NOSCAN;
> 
> Why not kill the extra tab?
> 

Why not indeed. Tab is now killed.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
