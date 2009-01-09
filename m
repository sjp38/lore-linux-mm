Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4196B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 20:46:59 -0500 (EST)
Date: Fri, 9 Jan 2009 10:44:16 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 4/4] memcg: make oom less frequently
Message-Id: <20090109104416.9bf4aab7.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <44480.10.75.179.62.1231413588.squirrel@webmail-b.css.fujitsu.com>
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp>
	<20090108191520.df9c1d92.nishimura@mxp.nes.nec.co.jp>
	<44480.10.75.179.62.1231413588.squirrel@webmail-b.css.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

On Thu, 8 Jan 2009 20:19:48 +0900 (JST), "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Daisuke Nishimura said:
> > In previous implementation, mem_cgroup_try_charge checked the return
> > value of mem_cgroup_try_to_free_pages, and just retried if some pages
> > had been reclaimed.
> > But now, try_charge(and mem_cgroup_hierarchical_reclaim called from it)
> > only checks whether the usage is less than the limit.
> >
> > This patch tries to change the behavior as before to cause oom less
> > frequently.
> >
> > To prevent try_charge from getting stuck in infinite loop,
> > MEM_CGROUP_RECLAIM_RETRIES_MAX is defined.
> >
> >
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> I think this is necessary change.
> My version of hierarchy reclaim will do this.
> 
> But RETRIES_MAX is not clear ;) please use one counter.
> 
> And why MAX=32 ?
I inserted printk and counted the loop count on oom(tested with 4 children).
It seemed 32 would be enough.

> > +		if (ret)
> > +			continue;
> seems to do enough work.
> 
> While memory can be reclaimed, it's not dead lock.
I see.
I introduced this max count because mmap_sem might be hold for a long time
at page fault, but this is not "dead" lock as you say.

> To handle live-lock situation as "reclaimed memory is stolen very soon",
> should we check signal_pending(current) or some flags ?
> 
> IMHO, using jiffies to detect how long we should retry is easy to understand
> ....like
>  "if memory charging cannot make progress for XXXX minutes,
>   trigger some notifier or show some flag to user via cgroupfs interface.
>   to show we're tooooooo busy."
> 
Good Idea.

But I think it would be enough for now to check signal_pending(curren) and
return -ENOMEM.

How about this one?
===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

In previous implementation, mem_cgroup_try_charge checked the return
value of mem_cgroup_try_to_free_pages, and just retried if some pages
had been reclaimed.
But now, try_charge(and mem_cgroup_hierarchical_reclaim called from it)
only checks whether the usage is less than the limit.

This patch tries to change the behavior as before to cause oom less frequently.


Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index dc38a0e..2ab0a5c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -770,10 +770,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
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
 
@@ -784,10 +784,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
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
@@ -870,8 +870,13 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 		if (!(gfp_mask & __GFP_WAIT))
 			goto nomem;
 
+		if (signal_pending(current))
+			goto oom;
+
 		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
 							noswap);
+		if (ret)
+			continue;
 
 		/*
 		 * try_to_free_mem_cgroup_pages() might not give us a full
@@ -885,6 +890,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 			continue;
 
 		if (!nr_retries--) {
+oom:
 			if (oom) {
 				mutex_lock(&memcg_tasklist);
 				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
