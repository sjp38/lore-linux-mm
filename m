Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 406346B005A
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 22:30:48 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8U2hGVd006261
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 30 Sep 2009 11:43:16 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 283A745DE50
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 11:43:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E9DC745DE4F
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 11:43:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C7D321DB8040
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 11:43:15 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7039F1DB803E
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 11:43:15 +0900 (JST)
Date: Wed, 30 Sep 2009 11:41:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 10/10] memcg: add commentary
Message-Id: <20090930114105.66bdcd7a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090930112149.87bc16fe.nishimura@mxp.nes.nec.co.jp>
References: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090925173018.2435084f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090930112149.87bc16fe.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Thank you for review.

On Wed, 30 Sep 2009 11:21:49 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> A few trivial comments and a question.
> 
> > @@ -1144,6 +1172,13 @@ static int mem_cgroup_count_children(str
> >   	mem_cgroup_walk_tree(mem, &num, mem_cgroup_count_children_cb);
> >  	return num;
> >  }
> > +
> > +/**
> > + * mem_cgroup_oon_called - check oom-kill is called recentlry under memcg
> s/oon/oom/
> 
yes.

> > + * @mem: mem_cgroup to be checked.
> > + *
> > + * Returns true if oom-kill was invoked in this memcg recently.
> > + */
> >  bool mem_cgroup_oom_called(struct task_struct *task)
> >  {
> >  	bool ret = false;
> 
> 
> 
> > @@ -1314,6 +1349,16 @@ static int mem_cgroup_hierarchical_recla
> >  	return total;
> >  }
> >  
> > +/*
> > + * This function is called by kswapd before entering per-zone memory reclaim.
> > + * This selects a victim mem_cgroup from soft-limit tree and memory will be
> > + * reclaimed from that.
> > + *
> > + * Soft-limit tree is sorted by the extent how many mem_cgroup's memoyr usage
> > + * excess the soft limit and a memory cgroup which has the largest excess
> > + * s selected as a victim. This Soft-limit tree is maintained perzone and
> "is selected"
>  ^
> 
will fix.


> > + * we never select a memcg which has no memory usage on this zone.
> > + */
> I'm sorry if I misunderstand about softlimit implementation, what prevents
> a memcg which has no memory usage on this zone from being selected ?
> IIUC, mz->usage_in_excess has a value calculated from res_counter_soft_limit_excess(),
> which doesn't take account of zone but only calculates "usage - soft_limit".
> 
right. But the point is that if memcg has _no_ pages in the zone, memcg is
not on RB-tree. So, Hmm, How about this ?
==
Because this soft-limit tree is maintained per zone, if memcg has little usage on
this zone, we can expect such memcg won't be found on this per-zone RB-tree.
==

I wonder there are something should be improved on this tree management.
Maybe we should add some per-zone check around here.
==
>                 __mem_cgroup_remove_exceeded(mz->mem, mz, mctz);
>                 excess = res_counter_soft_limit_excess(&mz->mem->res);
>                 /*
>                  * One school of thought says that we should not add
>                  * back the node to the tree if reclaim returns 0.
>                  * But our reclaim could return 0, simply because due
>                  * to priority we are exposing a smaller subset of
>                  * memory to reclaim from. Consider this as a longer
>                  * term TODO.
>                  */
>                 /* If excess == 0, no tree ops */
>                 __mem_cgroup_insert_exceeded(mz->mem, mz, mctz, excess);
>                 spin_unlock(&mctz->lock);
==
Its cost will not be high.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
