Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 9C5046B00A9
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 05:32:26 -0400 (EDT)
Date: Thu, 21 Jun 2012 10:32:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch] mm, thp: abort compaction if migration page cannot be
 charged to memcg
Message-ID: <20120621093220.GL4011@suse.de>
References: <alpine.DEB.2.00.1206202351030.28770@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206202351030.28770@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 20, 2012 at 11:52:35PM -0700, David Rientjes wrote:
> If page migration cannot charge the new page to the memcg,
> migrate_pages() will return -ENOMEM. 

I take it this happens in a memcg that is full and the temporary page
is enough to push it over the edge. Is that correct? If so, it should
be included in the changelog because that would make this a -stable
candidate on the grounds that it is a corner case where compaction can
consume excessive CPU when using memcgs leading to apparant stalls.

> This isn't considered in memory
> compaction however, and the loop continues to iterate over all pageblocks
> trying in a futile attempt to continue migrations which are only bound to
> fail.
> 

This is not necessarily true if it was just one small memcg that was
occupying that pageblock for example. 

> This will short circuit and fail memory compaction if migrate_pages()
> returns -ENOMEM.  COMPACT_PARTIAL is returned in case some migrations
> were successful so that the page allocator will retry.
> 

the "some migration" could have been in other unrelated zones so
COMPACT_PARTIAL makes sense from that perspective.

> Signed-off-by: David Rientjes <rientjes@google.com>

There is a side-effect that a small memcg that is full will cause
compaction to abort when it could have succeeded. This will impact THP
allocation success rates in other memcgs or in the root domain.

The ideal would be to backout iff the memcg occupied a large percentage of
the zone that was poorly fragmented. There is no way of finding this out
easily and a good value for a "large percentage" is unknowable. Besides it
would depend on the distribution as if the memcg had one page per pageblock
it would still fail so you'd need a full scan anyway. That all feels
like a bust and a path to fail. I'd like to see a more detailed
changelog but otherwise;

Acked-by: Mel Gorman <mgorman@suse.de>

However, here is a possible extention to your patch that should work while
preserving THP success rates but needs a more messing.  At the place of
your patch do something like this in compact_zone

arbitrary_mem_group = NULL

...

/*
 * Break out if memcg has "unmovable" pages that disable compaction in
 * this zone
 */
if err == -ENOMEM
  foreach page in cc->migratepages
    cgroup = page_cgroup(page)
    if cgroup
      mem_group = cgroup->mem_cgroup
      if mem_cgroup->disabled_compaction == true
         goto out
      else
         arbitrary_cgroup = mem_cgroup
      
i.e. add a new boolean to mem_cgroup that is set to true if this memcg
has impaired compaction. If a cgroup is not disabled_compaction then
remember that.

Next is when to set disabled_compaction. At the end of compact_zones,
do

if ret == COMPACT_COMPLETE && cc->order != -1 && arbitrary_cgroup
   arbitrary_cgroup->disabled_compaction = true

i.e. if we are in direct compaction and there was a full compaction
cycle that failed due to a cgroup getting in the way then tag that
cgroup is "disabled_compaction". On subsequent compaction attempts if
that cgroup is encountered again then abort compaction faster.

This will mitigate a small full memcg disabling compaction for the entire
zone at least until such time as the memcg has polluted every movable
pageblock.

>  			putback_lru_pages(&cc->migratepages);
>  			cc->nr_migratepages = 0;
> +			if (err == -ENOMEM) {
> +				ret = COMPACT_PARTIAL;
> +				goto out;
> +			}
>  		}
> -
>  	}
>  
>  out:

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
