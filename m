Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B23AB6B01CC
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 14:39:58 -0400 (EDT)
Date: Tue, 23 Mar 2010 18:39:36 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 11/11] Do not compact within a preferred zone after a
	compaction failure
Message-ID: <20100323183936.GF5870@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie> <1269347146-7461-12-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1003231327580.10178@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003231327580.10178@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 23, 2010 at 01:31:43PM -0500, Christoph Lameter wrote:
> On Tue, 23 Mar 2010, Mel Gorman wrote:
> 
> > The fragmentation index may indicate that a failure it due to external
> 
> s/it/is/
> 

Correct.

> > fragmentation, a compaction run complete and an allocation failure still
> 
> ???
> 

I was having some sort of fit when I wrote that obviously. Try this on
for size

The fragmentation index may indicate that a failure is due to external
fragmentation but after a compaction run completes, it is still possible  
for an allocation to fail.

> > fail. There are two obvious reasons as to why
> >
> >   o Page migration cannot move all pages so fragmentation remains
> >   o A suitable page may exist but watermarks are not met
> >
> > In the event of compaction and allocation failure, this patch prevents
> > compaction happening for a short interval. It's only recorded on the
> 
> compaction is "recorded"? deferred?
> 

deferred makes more sense.

What I was thinking at the time was that compact_resume was stored in struct
zone - i.e. that is where it is recorded.

> > preferred zone but that should be enough coverage. This could have been
> > implemented similar to the zonelist_cache but the increased size of the
> > zonelist did not appear to be justified.
> 
> > @@ -1787,6 +1787,9 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
> >  			 */
> >  			count_vm_event(COMPACTFAIL);
> >
> > +			/* On failure, avoid compaction for a short time. */
> > +			defer_compaction(preferred_zone, jiffies + HZ/50);
> > +
> 
> 20ms? How was that interval determined?
> 

Matches the time the page allocator would defer to an event like
congestion. The choice is somewhat arbitrary. Ideally, there would be
some sort of event that would re-enable compaction but there wasn't an
obvious candidate so I used time.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
