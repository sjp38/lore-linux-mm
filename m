Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 223376B01AC
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 05:40:25 -0400 (EDT)
Date: Fri, 26 Mar 2010 09:40:01 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 10/11] Direct compact when a high-order allocation fails
Message-ID: <20100326094001.GX2024@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie> <1269347146-7461-11-git-send-email-mel@csn.ul.ie> <20100324101927.0d54f4ad.kamezawa.hiroyu@jp.fujitsu.com> <20100324114056.GE21147@csn.ul.ie> <20100325093006.cd0361e6.kamezawa.hiroyu@jp.fujitsu.com> <20100325094826.GM2024@csn.ul.ie> <20100325185021.63e16884.kamezawa.hiroyu@jp.fujitsu.com> <20100325101653.GN2024@csn.ul.ie> <20100326100308.564ebb7b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100326100308.564ebb7b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 26, 2010 at 10:03:08AM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 25 Mar 2010 10:16:54 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Thu, Mar 25, 2010 at 06:50:21PM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Thu, 25 Mar 2010 09:48:26 +0000
> > > Mel Gorman <mel@csn.ul.ie> wrote:
> > > 
> > > > > In that case, compact_finished() can't
> > > > > find there is a free chunk and do more work.  How about using a function like
> > > > > 	 free_pcppages_bulk(zone, pcp->batch, pcp);
> > > > > to bypass pcp list and freeing pages at once ?
> > > > > 
> > > > 
> > > > I think you mean to drain the PCP lists while compaction is happening
> > > > but is it justified? It's potentially a lot of IPI calls just to check
> > > > if compaction can finish a little earlier. If the pages on the PCP lists
> > > > are making that much of a difference to high-order page availability, it
> > > > implies that the zone is pretty full and it's likely that compaction was
> > > > avoided and we direct reclaimed.
> > > > 
> > > Ah, sorry for my short word again. I mean draining "local" pcp list because
> > > a thread which run direct-compaction freed pages. IPI is not necessary and
> > > overkill.
> > > 
> > 
> > Ah, I see now. There are two places that pages get freed.  release_freepages()
> > at the end of compaction when it's too late for compact_finished() to be
> > helped and within migration itself. Migration frees with either
> > free_page() or more commonly put_page() with put_page() being the most
> > frequently used. As free_page() is called on failure to migrate (rare),
> > there is little help in changing it and I'd rather not modify how
> > put_page() works.
> > 
> > I could add a variant of drain_local_pages() that drains just the local PCP of
> > a given zone before compact_finished() is called. The cost would be a doubling
> > of the number of times zone->lock is taken to do the drain. Is it
> > justified? It seems overkill to me to take the zone->lock just in case
> > compaction can finish a little earlier. It feels like it would be adding
> > a guaranteed cost for a potential saving.
> > 
> If you want to keep code comapct, I don't ask more.
> 
> I worried about that just because memory hot-unplug were suffered by pagevec
> and pcp list before using  MIGRATE_ISOLATE and proper lru_add_drain().
> 

What I can do to cover that situation that won't cost much is to call
drain_local_pages after compaction completes.

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
