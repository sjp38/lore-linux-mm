Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8092B6008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 00:54:11 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o734x6hM020845
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Aug 2010 13:59:07 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A9FF145DE55
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 13:59:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B4F645DE51
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 13:59:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7577FE08001
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 13:59:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CB59E18008
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 13:59:06 +0900 (JST)
Date: Tue, 3 Aug 2010 13:54:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm 1/5] quick lookup memcg by ID
Message-Id: <20100803135413.38b64f8f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100803135129.4316dfff.nishimura@mxp.nes.nec.co.jp>
References: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100802191304.8e520808.kamezawa.hiroyu@jp.fujitsu.com>
	<20100803133109.c0e6f150.nishimura@mxp.nes.nec.co.jp>
	<20100803133723.bb6487a0.kamezawa.hiroyu@jp.fujitsu.com>
	<20100803135129.4316dfff.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010 13:51:29 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Tue, 3 Aug 2010 13:37:23 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Tue, 3 Aug 2010 13:31:09 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> (snip)
> > > > +/* 0 is unused */
> > > > +static atomic_t mem_cgroup_num;
> > > > +#define NR_MEMCG_GROUPS (CONFIG_MEM_CGROUP_MAX_GROUPS + 1)
> > > > +static struct mem_cgroup *mem_cgroups[NR_MEMCG_GROUPS] __read_mostly;
> > > > +
> > > > +static struct mem_cgroup *id_to_memcg(unsigned short id)
> > > > +{
> > > > +	/*
> > > > +	 * This array is set to NULL when mem_cgroup is freed.
> > > > +	 * IOW, there are no more references && rcu_synchronized().
> > > > +	 * This lookup-caching is safe.
> > > > +	 */
> > > > +	if (unlikely(!mem_cgroups[id])) {
> > > > +		struct cgroup_subsys_state *css;
> > > > +
> > > > +		rcu_read_lock();
> > > > +		css = css_lookup(&mem_cgroup_subsys, id);
> > > > +		rcu_read_unlock();
> > > > +		if (!css)
> > > > +			return NULL;
> > > > +		mem_cgroups[id] = container_of(css, struct mem_cgroup, css);
> > > > +	}
> > > > +	return mem_cgroups[id];
> > > > +}
> > > id_to_memcg() seems to be called under rcu_read_lock() already, so I think
> > > rcu_read_lock()/unlock() would be unnecessary.
> > > 
> > 
> > Maybe. I thought about which is better to add
> > 
> > 	VM_BUG_ON(!rcu_read_lock_held);
> > or
> > 	rcu_read_lock()
> > 	..
> > 	rcu_read_unlock()
> > 
> > Do you like former ? If so, it's ok to remove rcu-read-lock.
> > 
> Yes, I personally like the former.

ok, will rewrite in that style.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
