Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 941336B004A
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 20:39:51 -0400 (EDT)
Date: Wed, 1 Sep 2010 19:39:43 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
In-Reply-To: <20100902092628.D065.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1009011935040.20518@router.home>
References: <20100901203422.GA19519@csn.ul.ie> <alpine.DEB.2.00.1009011919110.20518@router.home> <20100902092628.D065.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Sep 2010, KOSAKI Motohiro wrote:

> > 	nr_free_pages += delta;
> > 	if (nr_free_pages < 0)
> > 		nr_free_pages = 0;
>
> nr_free_pages is unsined. this wouldn't works ;)

The VM counters are signed and must be signed otherwise the deferred
update scheme would cause desasters. For treatment in the page allocator
these may be converted to unsigned.

The effect needs to be the same as retrieving a global or
zone ZVC counter. Which is currently implemented in the following way:

static inline unsigned long zone_page_state(struct zone *zone,
                                        enum zone_stat_item item)
{
        long x = atomic_long_read(&zone->vm_stat[item]);
#ifdef CONFIG_SMP
        if (x < 0)
                x = 0;
#endif
        return x;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
