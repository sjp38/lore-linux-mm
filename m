Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2ED0F6B0382
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 19:57:44 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7NNve9W000557
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 24 Aug 2010 08:57:41 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BA57645DE7E
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 08:57:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9690545DE7B
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 08:57:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C1621DB8044
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 08:57:40 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EDE061DB8040
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 08:57:38 +0900 (JST)
Date: Tue, 24 Aug 2010 08:52:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: use ID in page_cgroup
Message-Id: <20100824085243.8dd3c8de.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100823143237.b7822ffc.nishimura@mxp.nes.nec.co.jp>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820190132.43684862.kamezawa.hiroyu@jp.fujitsu.com>
	<20100823143237.b7822ffc.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 23 Aug 2010 14:32:37 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Fri, 20 Aug 2010 19:01:32 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > 
> > I have an idea to remove page_cgroup->page pointer, 8bytes reduction per page.
> > But it will be after this work.
> Another off topic. I think we can reduce the size of mem_cgroup by packing
> some boolean members into one "unsinged long flags".
> 
I'll use "flags" to remove struct page pointer.


> > @@ -300,12 +300,13 @@ static atomic_t mem_cgroup_num;
> >  #define NR_MEMCG_GROUPS (CONFIG_MEM_CGROUP_MAX_GROUPS + 1)
> >  static struct mem_cgroup *mem_cgroups[NR_MEMCG_GROUPS] __read_mostly;
> >  
> > -/* Must be called under rcu_read_lock */
> > -static struct mem_cgroup *id_to_memcg(unsigned short id)
> > +/* Must be called under rcu_read_lock, set safe==true if under lock */
> Do you mean, "Set safe==true if we can ensure by some locks that the id can be
> safely dereferenced without rcu_read_lock", right ?
> 

yes. that's just for rcu_deerference_check().


> > +static struct mem_cgroup *id_to_memcg(unsigned short id, bool safe)
> >  {
> >  	struct mem_cgroup *ret;
> >  	/* see mem_cgroup_free() */
> > -	ret = rcu_dereference_check(mem_cgroups[id], rch_read_lock_held());
> > +	ret = rcu_dereference_check(mem_cgroups[id],
> > +				rch_read_lock_held() || safe);
> >  	if (likely(ret && ret->valid))
> >  		return ret;
> >  	return NULL;
> 
> (snip)
> > @@ -723,6 +729,11 @@ static inline bool mem_cgroup_is_root(st
> >  	return (mem == root_mem_cgroup);
> >  }
> >  
> > +static inline bool mem_cgroup_is_rootid(unsigned short id)
> > +{
> > +	return (id == 1);
> > +}
> > +
> It might be better to add
> 
> 	BUG_ON(newid->id != 1)
> 
> in cgroup.c::cgroup_init_idr().
> 

Why ??

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
