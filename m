Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 39C406B0044
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 03:53:44 -0500 (EST)
Date: Fri, 9 Jan 2009 17:52:15 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 4/4] memcg: make oom less frequently
Message-Id: <20090109175215.705c94ea.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090109055804.GF9737@balbir.in.ibm.com>
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp>
	<20090108191520.df9c1d92.nishimura@mxp.nes.nec.co.jp>
	<20090109055804.GF9737@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jan 2009 11:28:04 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> [2009-01-08 19:15:20]:
> 
> > In previous implementation, mem_cgroup_try_charge checked the return
> > value of mem_cgroup_try_to_free_pages, and just retried if some pages
> > had been reclaimed.
> > But now, try_charge(and mem_cgroup_hierarchical_reclaim called from it)
> > only checks whether the usage is less than the limit.
> > 
> > This patch tries to change the behavior as before to cause oom less frequently.
> > 
> > To prevent try_charge from getting stuck in infinite loop,
> > MEM_CGROUP_RECLAIM_RETRIES_MAX is defined.
> > 
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  mm/memcontrol.c |   16 ++++++++++++----
> >  1 files changed, 12 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 804c054..fedd76b 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -42,6 +42,7 @@
> > 
> >  struct cgroup_subsys mem_cgroup_subsys __read_mostly;
> >  #define MEM_CGROUP_RECLAIM_RETRIES	5
> > +#define MEM_CGROUP_RECLAIM_RETRIES_MAX	32
> 
> Why 32 are you seeing frequent OOMs? I had 5 iterations to allow
> 
> 1. pages to move to swap cache, which added back pressure to memcg in
> the original implementation, since the pages came back
> 2. It look longer to move, recalim those pages.
> 
> Ideally 3 would suffice, but I added an additional 2 retries for
> safety.
> 
Before this patch, try_charge doesn't check the return value of
try_to_free_page, i.e. how many pages has been reclaimed, and
only checks whether the usage has become less than the limit.
So, oom can be caused if the group is too busy.

IIRC memory-cgroup-hierarchical-reclaim patch introduced this behavior,
and, I don't remember in detail, some tests which had not caused oom
started to cause oom after it.
That was the motivation of my first version of this patch(*1).

*1 http://lkml.org/lkml/2008/11/28/35

Anyway, this is the updated version.
I removed RETRIES_MAX.


Thanks,
Daisuke Nishimura.
===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

In previous implementation, mem_cgroup_try_charge checked the return
value of mem_cgroup_try_to_free_pages, and just retried if some pages
had been reclaimed.
But now, try_charge(and mem_cgroup_hierarchical_reclaim called from it)
only checks whether the usage is less than the limit.

This patch tries to change the behavior as before to cause oom less frequently.

ChangeLog: RFC->v1
- removed RETRIES_MAX.


Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7ba5c61..fb0e9eb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -781,10 +781,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 	 * but there might be left over accounting, even after children
 	 * have left.
 	 */
-	ret = try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap,
+	ret += try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap,
 					   get_swappiness(root_mem));
 	if (mem_cgroup_check_under_limit(root_mem))
-		return 0;
+		return 1;	/* indicate reclaim has succeeded */
 	if (!root_mem->use_hierarchy)
 		return ret;
 
@@ -795,10 +795,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 			next_mem = mem_cgroup_get_next_node(root_mem);
 			continue;
 		}
-		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap,
+		ret += try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap,
 						   get_swappiness(next_mem));
 		if (mem_cgroup_check_under_limit(root_mem))
-			return 0;
+			return 1;	/* indicate reclaim has succeeded */
 		next_mem = mem_cgroup_get_next_node(root_mem);
 	}
 	return ret;
@@ -883,6 +883,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 
 		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
 							noswap);
+		if (ret)
+			continue;
 
 		/*
 		 * try_to_free_mem_cgroup_pages() might not give us a full

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
