Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1B16B005A
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 00:39:54 -0400 (EDT)
Date: Wed, 30 Sep 2009 13:36:18 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 10/10] memcg: add commentary
Message-Id: <20090930133618.1055e551.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090930114105.66bdcd7a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090925173018.2435084f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090930112149.87bc16fe.nishimura@mxp.nes.nec.co.jp>
	<20090930114105.66bdcd7a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> > > + * we never select a memcg which has no memory usage on this zone.
> > > + */
> > I'm sorry if I misunderstand about softlimit implementation, what prevents
> > a memcg which has no memory usage on this zone from being selected ?
> > IIUC, mz->usage_in_excess has a value calculated from res_counter_soft_limit_excess(),
> > which doesn't take account of zone but only calculates "usage - soft_limit".
> > 
> right. But the point is that if memcg has _no_ pages in the zone, memcg is
> not on RB-tree. So, Hmm, How about this ?
Thank you for your clarification.

> ==
> Because this soft-limit tree is maintained per zone, if memcg has little usage on
> this zone, we can expect such memcg won't be found on this per-zone RB-tree.
> ==
> 
I think "never" above is exaggeration a bit, but otherwise it looks good for me.

> I wonder there are something should be improved on this tree management.
I agree.
But I think it would be enough for now to leave it in TODO-list.


Thanks,
Daisuke Nishimura.

> Maybe we should add some per-zone check around here.
> ==
> >                 __mem_cgroup_remove_exceeded(mz->mem, mz, mctz);
> >                 excess = res_counter_soft_limit_excess(&mz->mem->res);
> >                 /*
> >                  * One school of thought says that we should not add
> >                  * back the node to the tree if reclaim returns 0.
> >                  * But our reclaim could return 0, simply because due
> >                  * to priority we are exposing a smaller subset of
> >                  * memory to reclaim from. Consider this as a longer
> >                  * term TODO.
> >                  */
> >                 /* If excess == 0, no tree ops */
> >                 __mem_cgroup_insert_exceeded(mz->mem, mz, mctz, excess);
> >                 spin_unlock(&mctz->lock);
> ==
> Its cost will not be high.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
