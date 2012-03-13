Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 3FC8F6B004A
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 22:58:04 -0400 (EDT)
Received: by dadv6 with SMTP id v6so167143dad.14
        for <linux-mm@kvack.org>; Mon, 12 Mar 2012 19:58:03 -0700 (PDT)
Date: Tue, 13 Mar 2012 11:57:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Control page reclaim granularity
Message-ID: <20120313025756.GC7125@barrios>
References: <20120308073412.GA6975@gmail.com>
 <20120308093514.GA28856@barrios>
 <4F5E0E5C.8040508@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F5E0E5C.8040508@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, kosaki.motohiro@jp.fujitsu.com

On Mon, Mar 12, 2012 at 10:55:24AM -0400, Rik van Riel wrote:
> On 03/08/2012 04:35 AM, Minchan Kim wrote:
> >On Thu, Mar 08, 2012 at 03:34:13PM +0800, Zheng Liu wrote:
> >>Hi list,
> >>
> >>Recently we encounter a problem about page reclaim.  I abstract it in here.
> >>The problem is that there are two different file types.  One is small index
> >>file, and another is large data file.  The index file is mmaped into memory,
> >>and application hope that they can be kept in memory and don't be reclaimed
> >>too frequently.  The data file is manipulted by read/write, and they should
> >>be reclaimed more frequently than the index file.
> 
> They should indeed be.  The data pages should not get promoted
> to the active list unless they get referenced twice while on
> the inactive list.
> 
> Mmaped pages, on the other hand, get promoted to the active
> list after just one reference.

As I look the code, mmaped page doesn't get promoted by one reference.
It will get promoted by second-round trip or touched by several mapping
when first round trip.

                if (referenced_page || referenced_ptes > 1) 
		        return PAGEREF_ACTIVATE;

> 
> Also, as long as the inactive file list is larger than the
> active file list, we do not reclaim active file pages at
> all.

True.

> 
> >I  think it's a regression since 2.6.28.
> >Before we were trying to keep mapped pages in memory(See calc_reclaim_mapped).
> >But we removed that routine when we applied split lru page replacement.
> >Rik, KOSAKI. What's the rationale?
> 
> One main reason is scalability.  We have to treat pages
> in such a way that we do not have to search through
> gigabytes of memory to find a few eviction candidates
> to place on the inactive list - where they could get
> reused and stopped from eviction again.

Okay. Thanks, Rik.
Then, another question.
Why did we handle mmaped page specially at that time?
Just out of curiosity.

> 
> -- 
> All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
