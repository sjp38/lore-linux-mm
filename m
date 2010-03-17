Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4936B00A7
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 07:33:46 -0400 (EDT)
Date: Wed, 17 Mar 2010 11:33:26 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 06/11] Export fragmentation index via
	/proc/extfrag_index
Message-ID: <20100317113326.GD12388@csn.ul.ie>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie> <1268412087-13536-7-git-send-email-mel@csn.ul.ie> <20100317114321.4C9A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100317114321.4C9A.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 17, 2010 at 11:49:49AM +0900, KOSAKI Motohiro wrote:
> > +/*
> > + * A fragmentation index only makes sense if an allocation of a requested
> > + * size would fail. If that is true, the fragmentation index indicates
> > + * whether external fragmentation or a lack of memory was the problem.
> > + * The value can be used to determine if page reclaim or compaction
> > + * should be used
> > + */
> > +int fragmentation_index(unsigned int order, struct contig_page_info *info)
> > +{
> > +	unsigned long requested = 1UL << order;
> > +
> > +	if (!info->free_blocks_total)
> > +		return 0;
> > +
> > +	/* Fragmentation index only makes sense when a request would fail */
> > +	if (info->free_blocks_suitable)
> > +		return -1000;
> > +
> > +	/*
> > +	 * Index is between 0 and 1 so return within 3 decimal places
> > +	 *
> > +	 * 0 => allocation would fail due to lack of memory
> > +	 * 1 => allocation would fail due to fragmentation
> > +	 */
> > +	return 1000 - ( (1000+(info->free_pages * 1000 / requested)) / info->free_blocks_total);
> > +}
> 
> Dumb question.
> 
> your paper (http://portal.acm.org/citation.cfm?id=1375634.1375641) says
> 
> fragmentation_index = 1 - (TotalFree/SizeRequested)/BlocksFree
> 
> but your code have extra '1000+'. Why?

To get an approximation to three decimal places.

> 
> Probably, I haven't understand the intention of this calculation.
> 
> 
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
