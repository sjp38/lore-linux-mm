Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id E198F6B029F
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 20:17:55 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 16D393EE0C0
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 10:17:54 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E5D9645DEB4
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 10:17:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BD30E45DEB3
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 10:17:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AD16B1DB803B
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 10:17:53 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6180CE08003
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 10:17:53 +0900 (JST)
Date: Wed, 14 Dec 2011 10:16:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: clean up soft_limit_tree properly new
Message-Id: <20111214101636.e463405c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111213170012.8fe53c90.akpm@linux-foundation.org>
References: <CAJd=RBB_AoJmyPd7gfHn+Kk39cn-+Wn-pFvU0ZWRZhw2fxoihw@mail.gmail.com>
	<alpine.LSU.2.00.1112111520510.2297@eggly>
	<20111212131118.GA15249@tiehlicka.suse.cz>
	<CAJd=RBAZT0zVnMm7i7P4J9Qg+LvTYh25RwFP7JZnN9dxwWp55g@mail.gmail.com>
	<20111212140750.GE14720@tiehlicka.suse.cz>
	<20111212140935.GF14720@tiehlicka.suse.cz>
	<20111213170012.8fe53c90.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 13 Dec 2011 17:00:12 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 12 Dec 2011 15:09:35 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > And a follow up patch for the proper clean up:
> > ---
> > >From 4b9f5a1e88496af9f336d1ef37cfdf3754a3ba48 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Mon, 12 Dec 2011 15:04:18 +0100
> > Subject: [PATCH] memcg: clean up soft_limit_tree properly
> > 
> > If we are not able to allocate tree nodes for all NUMA nodes then we
> > should better clean up those that were allocated otherwise we will leak
> > a memory.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> >  mm/memcontrol.c |   12 +++++++++++-
> >  1 files changed, 11 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 6aff93c..838d812 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -4874,7 +4874,7 @@ static int mem_cgroup_soft_limit_tree_init(void)
> >  			tmp = -1;
> >  		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, tmp);
> >  		if (!rtpn)
> > -			return 1;
> > +			goto err_cleanup;
> >  
> >  		soft_limit_tree.rb_tree_per_node[node] = rtpn;
> >  
> > @@ -4885,6 +4885,16 @@ static int mem_cgroup_soft_limit_tree_init(void)
> >  		}
> >  	}
> >  	return 0;
> > +
> > +err_cleanup:
> > +	for_each_node_state(node, N_POSSIBLE) {
> > +		if (!soft_limit_tree.rb_tree_per_node[node])
> > +			break;
> > +		kfree(soft_limit_tree.rb_tree_per_node[node]);
> > +		soft_limit_tree.rb_tree_per_node[node] = NULL;
> > +	}
> > +	return 1;
> > +
> >  }
> 
> afacit the kernel never frees the soft_limit_tree.rb_tree_per_node[]
> entries on the mem_cgroup_destroy() path.  Bug?
> 

soft_limit_tree.rb_tree_per_node[] is a global object and allocated once
at creating root cgroup.

Nodes of rb_tree for a memcg are contained in struct mem_cgroup_per_zone
and it's freed at mem_cgroup_destroy().

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
