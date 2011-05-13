Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 99F9D900001
	for <linux-mm@kvack.org>; Fri, 13 May 2011 03:18:52 -0400 (EDT)
Date: Fri, 13 May 2011 09:18:34 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [rfc patch 3/6] mm: memcg-aware global reclaim
Message-ID: <20110513071834.GD18610@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
 <1305212038-15445-4-git-send-email-hannes@cmpxchg.org>
 <20110513090450.3c40d2ee.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110513090450.3c40d2ee.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, May 13, 2011 at 09:04:50AM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 12 May 2011 16:53:55 +0200
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > A page charged to a memcg is linked to a lru list specific to that
> > memcg.  At the same time, traditional global reclaim is obvlivious to
> > memcgs, and all the pages are also linked to a global per-zone list.
> > 
> > This patch changes traditional global reclaim to iterate over all
> > existing memcgs, so that it no longer relies on the global list being
> > present.
> > 
> > This is one step forward in integrating memcg code better into the
> > rest of memory management.  It is also a prerequisite to get rid of
> > the global per-zone lru lists.
> 
> As I said, I don't want removing global reclaim until dirty_ratio support and
> better softlimit algorithm, at least. Current my concern is dirty_ratio,
> if you want to speed up, please help Greg and implement dirty_ratio first.

As I said, I am not proposing this for integration now.  It was more
like asking if people were okay with this direction before we put
things in place that could be in the way of the long-term plan.

Note that 6/6 is an attempt to improve the soft limit algorithm.

> BTW, could you separete clean up code and your new logic ? 1st half of
> codes seems to be just a clean up and seems nice. But , IIUC, someone
> changed the arguments from chunk of params to be a flags....in some patch.

Sorry again, I know that the series is pretty unorganized.

> +	do {
> +		mem_cgroup_hierarchy_walk(root, &mem);
> +		sc->current_memcg = mem;
> +		do_shrink_zone(priority, zone, sc);
> +	} while (mem != root);
> 
> This move hierarchy walk from memcontrol.c to vmscan.c ?
> 
> About moving hierarchy walk, I may say okay...because my patch does this, too.
> 
> But....doesn't this reclaim too much memory if hierarchy is very deep ?
> Could you add some 'quit' path ?

Yes, I think I'll just reinstate the logic from
mem_cgroup_select_victim() to remember the last child, and add an exit
condition based on the number of reclaimed pages.

This was also suggested by Rik in this thread already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
