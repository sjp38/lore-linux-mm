Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 93C866B0055
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 21:18:13 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0G2IBqi004687
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 16 Jan 2009 11:18:11 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 42B7445DE4F
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 11:18:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1940A45DE4D
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 11:18:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AF391DB8038
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 11:18:10 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D44631DB803F
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 11:18:06 +0900 (JST)
Date: Fri, 16 Jan 2009 11:17:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: get/put parents at create/free
Message-Id: <20090116111702.fba37439.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090115181243.8dad9052.akpm@linux-foundation.org>
References: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp>
	<20090114175121.275ecd59.nishimura@mxp.nes.nec.co.jp>
	<7602a77a9fc6b1e8757468048fde749a.squirrel@webmail-b.css.fujitsu.com>
	<20090115100330.37d89d3d.nishimura@mxp.nes.nec.co.jp>
	<20090115110044.3a863af8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115111420.8559bdb3.nishimura@mxp.nes.nec.co.jp>
	<20090115133814.a52460fa.nishimura@mxp.nes.nec.co.jp>
	<20090115164537.d402e95f.nishimura@mxp.nes.nec.co.jp>
	<20090115165453.271848d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115171315.965da4e3.nishimura@mxp.nes.nec.co.jp>
	<20090115172336.0ed780bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115175131.9542ae59.nishimura@mxp.nes.nec.co.jp>
	<20090115181056.74a938d5.kamezawa.hiroyu@jp.fujitsu.com>
	<20090116105009.7cabac46.nishimura@mxp.nes.nec.co.jp>
	<20090115181243.8dad9052.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jan 2009 18:12:43 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 16 Jan 2009 10:50:09 +0900 Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > This version works well in my test.
> > 
> > Andrew, please pick up this one.
> > 
> > ===
> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > The lifetime of struct cgroup and struct mem_cgroup is different and
> > mem_cgroup has its own reference count for handling references from swap_cgroup.
> > 
> > This causes strange problem that the parent mem_cgroup dies while
> > child mem_cgroup alive, and this problem causes a bug in case of use_hierarchy==1
> > because res_counter_uncharge climbs up the tree.
> > 
> > This patch is for avoiding it by getting the parent at create, and
> > putting it at freeing.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Reviewed-by; KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |   23 ++++++++++++++++++++++-
> >  1 files changed, 22 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index fb62b43..45e1b51 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -202,6 +202,8 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
> >  
> >  static void mem_cgroup_get(struct mem_cgroup *mem);
> >  static void mem_cgroup_put(struct mem_cgroup *mem);
> > +static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
> > +static void mem_cgroup_get_parent(struct mem_cgroup *mem);
> >  
> >  static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
> >  					 struct page_cgroup *pc,
> > @@ -2185,10 +2187,28 @@ static void mem_cgroup_get(struct mem_cgroup *mem)
> >  
> >  static void mem_cgroup_put(struct mem_cgroup *mem)
> >  {
> > -	if (atomic_dec_and_test(&mem->refcnt))
> > +	if (atomic_dec_and_test(&mem->refcnt)) {
> > +		struct mem_cgroup *parent = parent_mem_cgroup(mem);
> >  		__mem_cgroup_free(mem);
> > +		if (parent)
> > +			mem_cgroup_put(parent);
> > +	}
> > +}
> > +
> > +static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem)
> > +{
> > +	if (!mem->res.parent)
> > +		return NULL;
> > +	return mem_cgroup_from_res_counter(mem->res.parent, res);
> >  }
> >  
> > +static void mem_cgroup_get_parent(struct mem_cgroup *mem)
> > +{
> > +	struct mem_cgroup *parent = parent_mem_cgroup(mem);
> > +
> > +	if (parent)
> > +		mem_cgroup_get(parent);
> > +}
> >  
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> >  static void __init enable_swap_cgroup(void)
> > @@ -2237,6 +2257,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >  	if (parent)
> >  		mem->swappiness = get_swappiness(parent);
> >  	atomic_set(&mem->refcnt, 1);
> > +	mem_cgroup_get_parent(mem);
> >  	return &mem->css;
> >  free_out:
> >  	__mem_cgroup_free(mem);
> 
> It seems strange that we add a little helper function for the get(),
> but open-code the put()?
> 
Maybe I don't feel this as strange because I saw update history of this patch ;(
As you pointed out, I like open-code rather than helper here. Nishimura-san,
could you update ?

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
