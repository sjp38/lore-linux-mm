Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 252326B01AD
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 08:03:52 -0400 (EDT)
Date: Tue, 23 Mar 2010 12:03:30 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 06/11] Export fragmentation index via
	/proc/extfrag_index
Message-ID: <20100323120329.GE9590@csn.ul.ie>
References: <20100317114321.4C9A.A69D9226@jp.fujitsu.com> <20100317113326.GD12388@csn.ul.ie> <20100323050910.A473.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100323050910.A473.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 23, 2010 at 09:22:04AM +0900, KOSAKI Motohiro wrote:
> > > > +	/*
> > > > +	 * Index is between 0 and 1 so return within 3 decimal places
> > > > +	 *
> > > > +	 * 0 => allocation would fail due to lack of memory
> > > > +	 * 1 => allocation would fail due to fragmentation
> > > > +	 */
> > > > +	return 1000 - ( (1000+(info->free_pages * 1000 / requested)) / info->free_blocks_total);
> > > > +}
> > > 
> > > Dumb question.
> > > your paper (http://portal.acm.org/citation.cfm?id=1375634.1375641) says
> > > fragmentation_index = 1 - (TotalFree/SizeRequested)/BlocksFree
> > > but your code have extra '1000+'. Why?
> > 
> > To get an approximation to three decimal places.
> 
> Do you mean this is poor man's round up logic?

Not exactly.

The intention is to have a value of 968 instead of 0.968231. i.e.
instead of a value between 0 and 1, it'll be a value between 0 and 1000
that matches the first three digits after the decimal place.

> Why don't you use DIV_ROUND_UP? likes following,
> 
> return 1000 - (DIV_ROUND_UP(info->free_pages * 1000 / requested) /  info->free_blocks_total);
> 

Because it's not doing the same thing unless I missed something.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
