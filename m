Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 235BF6B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 20:35:16 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o810YorF027568
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Sep 2010 09:34:50 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AC7E45DE55
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 09:34:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3161045DE51
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 09:34:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1847F1DB803B
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 09:34:50 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B41C91DB803C
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 09:34:49 +0900 (JST)
Date: Wed, 1 Sep 2010 09:29:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/5] memcg: quick memcg lookup array
Message-Id: <20100901092948.a99c6a57.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100830170324.16933949.nishimura@mxp.nes.nec.co.jp>
References: <20100825170435.15f8eb73.kamezawa.hiroyu@jp.fujitsu.com>
	<20100825170741.f1f0a220.kamezawa.hiroyu@jp.fujitsu.com>
	<20100830170324.16933949.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 30 Aug 2010 17:03:24 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > Index: mmotm-0811/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-0811.orig/mm/memcontrol.c
> > +++ mmotm-0811/mm/memcontrol.c
> > @@ -195,6 +195,7 @@ static void mem_cgroup_oom_notify(struct
> >   */
> >  struct mem_cgroup {
> >  	struct cgroup_subsys_state css;
> > +	int	valid; /* for checking validness under RCU access.*/
> >  	/*
> >  	 * the counter to account for memory usage
> >  	 */
> Do we really need to add this new member ?
> Can't we safely access "mem(=rcu_dereference(mem_cgroup[id]))" under rcu_read_lock() ?
> (iow, "mem" is not freed ?)
> 

Maybe this can be removed. I'll check again.




> 
> > @@ -4049,6 +4068,7 @@ static void __mem_cgroup_free(struct mem
> >  	mem_cgroup_remove_from_trees(mem);
> >  	free_css_id(&mem_cgroup_subsys, &mem->css);
> >  
> > +	atomic_dec(&mem_cgroup_num);
> >  	for_each_node_state(node, N_POSSIBLE)
> >  		free_mem_cgroup_per_zone_info(mem, node);
> >  
> > @@ -4059,6 +4079,19 @@ static void __mem_cgroup_free(struct mem
> >  		vfree(mem);
> >  }
> >  
> > +static void mem_cgroup_free(struct mem_cgroup *mem)
> > +{
> > +	/* No more lookup */
> > +	mem->valid = 0;
> > +	rcu_assign_pointer(mem_cgroups[css_id(&mem->css)], NULL);
> > +	/*
> > +	 * Because we call vfree() etc...use synchronize_rcu() rather than
> > + 	 * call_rcu();
> > + 	 */
> > +	synchronize_rcu();
> > +	__mem_cgroup_free(mem);
> > +}
> > +
> >  static void mem_cgroup_get(struct mem_cgroup *mem)
> >  {
> >  	atomic_inc(&mem->refcnt);
> > @@ -4068,7 +4101,7 @@ static void __mem_cgroup_put(struct mem_
> >  {
> >  	if (atomic_sub_and_test(count, &mem->refcnt)) {
> >  		struct mem_cgroup *parent = parent_mem_cgroup(mem);
> > -		__mem_cgroup_free(mem);
> > +		mem_cgroup_free(mem);
> >  		if (parent)
> >  			mem_cgroup_put(parent);
> >  	}
> > @@ -4189,9 +4222,11 @@ mem_cgroup_create(struct cgroup_subsys *
> >  	atomic_set(&mem->refcnt, 1);
> >  	mem->move_charge_at_immigrate = 0;
> >  	mutex_init(&mem->thresholds_lock);
> > +	atomic_inc(&mem_cgroup_num);
> > +	register_memcg_id(mem);
> >  	return &mem->css;
> >  free_out:
> > -	__mem_cgroup_free(mem);
> > +	mem_cgroup_free(mem);
> >  	root_mem_cgroup = NULL;
> >  	return ERR_PTR(error);
> >  }
> I think mem_cgroup_num should be increased at mem_cgroup_alloc(), because it
> is decreased at __mem_cgroup_free(). Otherwise, it can be decreased while it
> has not been increased, if mem_cgroup_create() fails after mem_cgroup_alloc().
> 

Hmm. thank you for checking, I'll fix.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
