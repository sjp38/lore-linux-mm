Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6C4C66008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 00:51:12 -0400 (EDT)
Date: Tue, 3 Aug 2010 13:51:29 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mm 1/5] quick lookup memcg by ID
Message-Id: <20100803135129.4316dfff.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100803133723.bb6487a0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100802191304.8e520808.kamezawa.hiroyu@jp.fujitsu.com>
	<20100803133109.c0e6f150.nishimura@mxp.nes.nec.co.jp>
	<20100803133723.bb6487a0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010 13:37:23 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 3 Aug 2010 13:31:09 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
(snip)
> > > +/* 0 is unused */
> > > +static atomic_t mem_cgroup_num;
> > > +#define NR_MEMCG_GROUPS (CONFIG_MEM_CGROUP_MAX_GROUPS + 1)
> > > +static struct mem_cgroup *mem_cgroups[NR_MEMCG_GROUPS] __read_mostly;
> > > +
> > > +static struct mem_cgroup *id_to_memcg(unsigned short id)
> > > +{
> > > +	/*
> > > +	 * This array is set to NULL when mem_cgroup is freed.
> > > +	 * IOW, there are no more references && rcu_synchronized().
> > > +	 * This lookup-caching is safe.
> > > +	 */
> > > +	if (unlikely(!mem_cgroups[id])) {
> > > +		struct cgroup_subsys_state *css;
> > > +
> > > +		rcu_read_lock();
> > > +		css = css_lookup(&mem_cgroup_subsys, id);
> > > +		rcu_read_unlock();
> > > +		if (!css)
> > > +			return NULL;
> > > +		mem_cgroups[id] = container_of(css, struct mem_cgroup, css);
> > > +	}
> > > +	return mem_cgroups[id];
> > > +}
> > id_to_memcg() seems to be called under rcu_read_lock() already, so I think
> > rcu_read_lock()/unlock() would be unnecessary.
> > 
> 
> Maybe. I thought about which is better to add
> 
> 	VM_BUG_ON(!rcu_read_lock_held);
> or
> 	rcu_read_lock()
> 	..
> 	rcu_read_unlock()
> 
> Do you like former ? If so, it's ok to remove rcu-read-lock.
> 
Yes, I personally like the former.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
