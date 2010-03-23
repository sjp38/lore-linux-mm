Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0BBB36B01BF
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 14:14:44 -0400 (EDT)
Date: Tue, 23 Mar 2010 18:14:22 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 05/11] Export unusable free space index via
	/proc/unusable_index
Message-ID: <20100323181422.GC5870@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie> <1269347146-7461-6-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1003231229310.10178@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003231229310.10178@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 23, 2010 at 12:31:35PM -0500, Christoph Lameter wrote:
> On Tue, 23 Mar 2010, Mel Gorman wrote:
> 
> > +/*
> > + * Return an index indicating how much of the available free memory is
> > + * unusable for an allocation of the requested size.
> > + */
> > +static int unusable_free_index(unsigned int order,
> > +				struct contig_page_info *info)
> > +{
> > +	/* No free memory is interpreted as all free memory is unusable */
> > +	if (info->free_pages == 0)
> > +		return 1000;
> 
> 
> Is that assumption correct? If you have no free memory then you do not
> know about the fragmentation status that would result if you would run
> reclaim and free some memory.

True, but reclaim and the freeing of memory is a possible future event.
At the time the index is being measured, saying "there is no free memory" and
"of the free memory available, none if it is usable" has the same end-result -
an allocation attempt will fail so the value makes sense.

If it returned zero, it would be a bit confusing. As memory within the zone
gets consumed, the value for high-orders would go towards 1 until there was
no free memory when it would suddenly go to 0. If you graphed that over
time, it would look a bit strange.

> Going into a compaction mode would not be
> useful. Should this not return 0 to avoid any compaction run when all
> memory is allocated?
> 

A combination of watermarks and fragmentation_index is what is used in
the compaction decision, not unusable_free_index.

> Otherwise
> 
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> 

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
