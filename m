Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 066CF6B0381
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 19:56:12 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7NNu9WP024820
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 24 Aug 2010 08:56:10 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 77E3345DE62
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 08:56:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 48D6C45DD77
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 08:56:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CC331DB8040
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 08:56:09 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BEB4F1DB803C
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 08:56:08 +0900 (JST)
Date: Tue, 24 Aug 2010 08:51:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/5] memcg: use array and ID for quick look up
Message-Id: <20100824085111.6acf8881.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100823123533.b75b99c5.nishimura@mxp.nes.nec.co.jp>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820185917.87876cb0.kamezawa.hiroyu@jp.fujitsu.com>
	<20100823123533.b75b99c5.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 23 Aug 2010 12:35:33 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Hi,
> 
> > +/* 0 is unused */
> > +static atomic_t mem_cgroup_num;
> > +#define NR_MEMCG_GROUPS (CONFIG_MEM_CGROUP_MAX_GROUPS + 1)
> > +static struct mem_cgroup *mem_cgroups[NR_MEMCG_GROUPS] __read_mostly;
> > +
> > +/* Must be called under rcu_read_lock */
> > +static struct mem_cgroup *id_to_memcg(unsigned short id)
> > +{
> > +	struct mem_cgroup *ret;
> > +	/* see mem_cgroup_free() */
> > +	ret = rcu_dereference_check(mem_cgroups[id], rch_read_lock_held());
> > +	if (likely(ret && ret->valid))
> > +		return ret;
> > +	return NULL;
> > +}
> > +
> I prefer "mem" to "ret".
> 
Hmm, ok.


> > @@ -2231,7 +2244,7 @@ __mem_cgroup_commit_charge_swapin(struct
> >  
> >  		id = swap_cgroup_record(ent, 0);
> >  		rcu_read_lock();
> > -		memcg = mem_cgroup_lookup(id);
> > +		memcg = id_to_memcg(id);
> >  		if (memcg) {
> >  			/*
> >  			 * This recorded memcg can be obsolete one. So, avoid
> > @@ -2240,9 +2253,10 @@ __mem_cgroup_commit_charge_swapin(struct
> >  			if (!mem_cgroup_is_root(memcg))
> >  				res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> >  			mem_cgroup_swap_statistics(memcg, false);
> > +			rcu_read_unlock();
> >  			mem_cgroup_put(memcg);
> > -		}
> > -		rcu_read_unlock();
> > +		} else
> > +			rcu_read_unlock();
> >  	}
> >  	/*
> >  	 * At swapin, we may charge account against cgroup which has no tasks.
> > @@ -2495,7 +2509,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
> >  
> >  	id = swap_cgroup_record(ent, 0);
> >  	rcu_read_lock();
> > -	memcg = mem_cgroup_lookup(id);
> > +	memcg = id_to_memcg(id);
> >  	if (memcg) {
> >  		/*
> >  		 * We uncharge this because swap is freed.
> > @@ -2504,9 +2518,10 @@ void mem_cgroup_uncharge_swap(swp_entry_
> >  		if (!mem_cgroup_is_root(memcg))
> >  			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> >  		mem_cgroup_swap_statistics(memcg, false);
> > +		rcu_read_unlock();
> >  		mem_cgroup_put(memcg);
> > -	}
> > -	rcu_read_unlock();
> > +	} else
> > +		rcu_read_unlock();
> >  }
> >  
> >  /**
> Could you explain why we need rcu_read_unlock() before mem_cgroup_put() ?
> I suspect that it's because mem_cgroup_put() can free the memcg, but do we
> need mem->valid then ?
> 
mem_cgroup_put() may call synchronize_rcu(). So, we have to unlock before it.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
