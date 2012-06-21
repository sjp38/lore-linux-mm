Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 653426B00AB
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 05:57:36 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2445949pbb.14
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 02:57:35 -0700 (PDT)
Date: Thu, 21 Jun 2012 02:57:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: abort compaction if migration page cannot be
 charged to memcg
In-Reply-To: <20120621093220.GL4011@suse.de>
Message-ID: <alpine.DEB.2.00.1206210247440.15747@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206202351030.28770@chino.kir.corp.google.com> <20120621093220.GL4011@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 21 Jun 2012, Mel Gorman wrote:

> I take it this happens in a memcg that is full and the temporary page
> is enough to push it over the edge. Is that correct? If so, it should
> be included in the changelog because that would make this a -stable
> candidate on the grounds that it is a corner case where compaction can
> consume excessive CPU when using memcgs leading to apparant stalls.
> 

Yes, the charge against the page under migration causes the oom.  It's 
really a nasty side-effect of memcg page migration that we have to charge 
a temporary page that I wish we could address there and certainly we can 
try to do that in the future.  This issue has just been causing us a lot 
of pain, especially for systems with a low number of very large memcgs.

I agree with your assessment that it should be added to stable and ask 
that Andrew replace the old changelog with the following:

===SNIP===

mm, thp: abort compaction if migration page cannot be charged to memcg

If page migration cannot charge the temporary page to the memcg,
migrate_pages() will return -ENOMEM.  This isn't considered in memory
compaction however, and the loop continues to iterate over all pageblocks
trying to isolate and migrate pages.  If a small number of very large 
memcgs happen to be oom, however, these attempts will mostly be futile 
leading to an enormous amout of cpu consumption due to the page migration 
failures. 

This patch will short circuit and fail memory compaction if 
migrate_pages() returns -ENOMEM.  COMPACT_PARTIAL is returned in case some 
migrations were successful so that the page allocator will retry.

Cc: stable@vger.kernel.org
Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: David Rientjes <rientjes@google.com>

===SNIP===

> However, here is a possible extention to your patch that should work while
> preserving THP success rates but needs a more messing.  At the place of
> your patch do something like this in compact_zone
> 
> arbitrary_mem_group = NULL
> 
> ...
> 
> /*
>  * Break out if memcg has "unmovable" pages that disable compaction in
>  * this zone
>  */
> if err == -ENOMEM
>   foreach page in cc->migratepages
>     cgroup = page_cgroup(page)
>     if cgroup
>       mem_group = cgroup->mem_cgroup
>       if mem_cgroup->disabled_compaction == true
>          goto out
>       else
>          arbitrary_cgroup = mem_cgroup
>       
> i.e. add a new boolean to mem_cgroup that is set to true if this memcg
> has impaired compaction. If a cgroup is not disabled_compaction then
> remember that.
> 
> Next is when to set disabled_compaction. At the end of compact_zones,
> do
> 
> if ret == COMPACT_COMPLETE && cc->order != -1 && arbitrary_cgroup
>    arbitrary_cgroup->disabled_compaction = true
> 
> i.e. if we are in direct compaction and there was a full compaction
> cycle that failed due to a cgroup getting in the way then tag that
> cgroup is "disabled_compaction". On subsequent compaction attempts if
> that cgroup is encountered again then abort compaction faster.
> 
> This will mitigate a small full memcg disabling compaction for the entire
> zone at least until such time as the memcg has polluted every movable
> pageblock.
> 

Interesting approach, I'll look to do something like this as a follow-up 
to this patch since we have usecases that reproduce this easily.

Thanks for looking at it and the detailed analysis, Mel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
