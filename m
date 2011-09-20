Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 066599000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 04:46:08 -0400 (EDT)
Date: Tue, 20 Sep 2011 10:45:53 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 01/11] mm: memcg: consolidate hierarchy iteration
 primitives
Message-ID: <20110920084553.GA11489@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-2-git-send-email-jweiner@redhat.com>
 <20110919125333.GC21847@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110919125333.GC21847@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 19, 2011 at 02:53:33PM +0200, Michal Hocko wrote:
> Hi,
> 
> On Mon 12-09-11 12:57:18, Johannes Weiner wrote:
> > Memory control groups are currently bolted onto the side of
> > traditional memory management in places where better integration would
> > be preferrable.  To reclaim memory, for example, memory control groups
> > maintain their own LRU list and reclaim strategy aside from the global
> > per-zone LRU list reclaim.  But an extra list head for each existing
> > page frame is expensive and maintaining it requires additional code.
> > 
> > This patchset disables the global per-zone LRU lists on memory cgroup
> > configurations and converts all its users to operate on the per-memory
> > cgroup lists instead.  As LRU pages are then exclusively on one list,
> > this saves two list pointers for each page frame in the system:
> > 
> > page_cgroup array size with 4G physical memory
> > 
> >   vanilla: [    0.000000] allocated 31457280 bytes of page_cgroup
> >   patched: [    0.000000] allocated 15728640 bytes of page_cgroup
> > 
> > At the same time, system performance for various workloads is
> > unaffected:
> > 
> > 100G sparse file cat, 4G physical memory, 10 runs, to test for code
> > bloat in the traditional LRU handling and kswapd & direct reclaim
> > paths, without/with the memory controller configured in
> > 
> >   vanilla: 71.603(0.207) seconds
> >   patched: 71.640(0.156) seconds
> > 
> >   vanilla: 79.558(0.288) seconds
> >   patched: 77.233(0.147) seconds
> > 
> > 100G sparse file cat in 1G memory cgroup, 10 runs, to test for code
> > bloat in the traditional memory cgroup LRU handling and reclaim path
> > 
> >   vanilla: 96.844(0.281) seconds
> >   patched: 94.454(0.311) seconds
> > 
> > 4 unlimited memcgs running kbuild -j32 each, 4G physical memory, 500M
> > swap on SSD, 10 runs, to test for regressions in kswapd & direct
> > reclaim using per-memcg LRU lists with multiple memcgs and multiple
> > allocators within each memcg
> > 
> >   vanilla: 717.722(1.440) seconds [ 69720.100(11600.835) majfaults ]
> >   patched: 714.106(2.313) seconds [ 71109.300(14886.186) majfaults ]
> > 
> > 16 unlimited memcgs running kbuild, 1900M hierarchical limit, 500M
> > swap on SSD, 10 runs, to test for regressions in hierarchical memcg
> > setups
> > 
> >   vanilla: 2742.058(1.992) seconds [ 26479.600(1736.737) majfaults ]
> >   patched: 2743.267(1.214) seconds [ 27240.700(1076.063) majfaults ]
> 
> I guess you want to have this in the first patch to have it for
> reference once it gets to the tree, right? I have no objections but it
> seems unrelated to the patch and so it might be confusing a bit. I
> haven't seen other patches in the series so there is probably no better
> place to put this.

Andrew usually hand-picks what's of long-term interest from the series
description and puts it in the first patch.  I thought I'd save him
the trouble.

> > This patch:
> > 
> > There are currently two different implementations of iterating over a
> > memory cgroup hierarchy tree.
> > 
> > Consolidate them into one worker function and base the convenience
> > looping-macros on top of it.
> > 
> > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> 
> Looks mostly good. There is just one issue I spotted and I guess we
> want some comments. After the issue is fixed:
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index b76011a..912c7c7 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -781,83 +781,75 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
> >  	return memcg;
> >  }
> >  
> > -/* The caller has to guarantee "mem" exists before calling this */
> 
> Shouldn't we have a similar comment that we have to keep a reference to
> root if non-NULL. A mention about remember parameter and what is it used
> for (hierarchical reclaim) would be helpful as well.

The only thing that dictates the lifetime of a memcg is its reference
count, so having a reference count while operating on a memecg is not
even a question for all existing memcg-internal callsites.

But I did, in fact, add kernel-doc style documentation to
mem_cgroup_iter() when it becomes a public interface in 5/11.  Can you
take a look and tell me whether you are okay with that?

> > @@ -1719,21 +1670,21 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
> >  		} else
> >  			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
> >  						noswap);
> > -		css_put(&victim->css);
> >  		/*
> >  		 * At shrinking usage, we can't check we should stop here or
> >  		 * reclaim more. It's depends on callers. last_scanned_child
> >  		 * will work enough for keeping fairness under tree.
> >  		 */
> >  		if (shrink)
> > -			return ret;
> > +			break;
> 
> Hmm, we are returning total but it doesn't get set to ret for shrinking
> case so we are alway returning 0. You want to move the line bellow up.

Heh, none of the limit shrinkers actually mind the return value.  But
you are right, of course, nice catch!

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 912c7c7..316f3ed 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1670,6 +1670,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
 		} else
 			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
 						noswap);
+		total += ret;
 		/*
 		 * At shrinking usage, we can't check we should stop here or
 		 * reclaim more. It's depends on callers. last_scanned_child
@@ -1677,7 +1678,6 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
 		 */
 		if (shrink)
 			break;
-		total += ret;
 		if (check_soft) {
 			if (!res_counter_soft_limit_excess(&root_memcg->res))
 				break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
