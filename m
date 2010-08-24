Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 31ACC6B03F1
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 20:33:13 -0400 (EDT)
Date: Tue, 24 Aug 2010 09:19:20 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 2/5] memcg: use array and ID for quick look up
Message-Id: <20100824091920.181932e0.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100824085111.6acf8881.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820185917.87876cb0.kamezawa.hiroyu@jp.fujitsu.com>
	<20100823123533.b75b99c5.nishimura@mxp.nes.nec.co.jp>
	<20100824085111.6acf8881.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> > > @@ -2231,7 +2244,7 @@ __mem_cgroup_commit_charge_swapin(struct
> > >  
> > >  		id = swap_cgroup_record(ent, 0);
> > >  		rcu_read_lock();
> > > -		memcg = mem_cgroup_lookup(id);
> > > +		memcg = id_to_memcg(id);
> > >  		if (memcg) {
> > >  			/*
> > >  			 * This recorded memcg can be obsolete one. So, avoid
> > > @@ -2240,9 +2253,10 @@ __mem_cgroup_commit_charge_swapin(struct
> > >  			if (!mem_cgroup_is_root(memcg))
> > >  				res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> > >  			mem_cgroup_swap_statistics(memcg, false);
> > > +			rcu_read_unlock();
> > >  			mem_cgroup_put(memcg);
> > > -		}
> > > -		rcu_read_unlock();
> > > +		} else
> > > +			rcu_read_unlock();
> > >  	}
> > >  	/*
> > >  	 * At swapin, we may charge account against cgroup which has no tasks.
> > > @@ -2495,7 +2509,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
> > >  
> > >  	id = swap_cgroup_record(ent, 0);
> > >  	rcu_read_lock();
> > > -	memcg = mem_cgroup_lookup(id);
> > > +	memcg = id_to_memcg(id);
> > >  	if (memcg) {
> > >  		/*
> > >  		 * We uncharge this because swap is freed.
> > > @@ -2504,9 +2518,10 @@ void mem_cgroup_uncharge_swap(swp_entry_
> > >  		if (!mem_cgroup_is_root(memcg))
> > >  			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> > >  		mem_cgroup_swap_statistics(memcg, false);
> > > +		rcu_read_unlock();
> > >  		mem_cgroup_put(memcg);
> > > -	}
> > > -	rcu_read_unlock();
> > > +	} else
> > > +		rcu_read_unlock();
> > >  }
> > >  
> > >  /**
> > Could you explain why we need rcu_read_unlock() before mem_cgroup_put() ?
> > I suspect that it's because mem_cgroup_put() can free the memcg, but do we
> > need mem->valid then ?
> > 
> mem_cgroup_put() may call synchronize_rcu(). So, we have to unlock before it.
> 
Ah, I see. Thank you for your explanation.

Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
