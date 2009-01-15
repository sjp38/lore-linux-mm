Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5AB386B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 02:56:07 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0F7u21Y014250
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 16:56:03 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 93E1345DE57
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 16:56:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ADC1445DE62
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 16:56:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A05F1DB803C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 16:56:00 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1029F1DB803B
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 16:55:58 +0900 (JST)
Date: Thu, 15 Jan 2009 16:54:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg: get/put parents at create/free
Message-Id: <20090115165453.271848d9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090115164537.d402e95f.nishimura@mxp.nes.nec.co.jp>
References: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp>
	<20090114175121.275ecd59.nishimura@mxp.nes.nec.co.jp>
	<7602a77a9fc6b1e8757468048fde749a.squirrel@webmail-b.css.fujitsu.com>
	<20090115100330.37d89d3d.nishimura@mxp.nes.nec.co.jp>
	<20090115110044.3a863af8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115111420.8559bdb3.nishimura@mxp.nes.nec.co.jp>
	<20090115133814.a52460fa.nishimura@mxp.nes.nec.co.jp>
	<20090115164537.d402e95f.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jan 2009 16:45:37 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu, 15 Jan 2009 13:38:14 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > On Thu, 15 Jan 2009 11:14:20 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > > > To handle the problem "parent may be obsolete",
> > > > > > 
> > > > > > call mem_cgroup_get(parent) at create()
> > > > > > call mem_cgroup_put(parent) at freeing memcg.
> > > > > >      (regardless of use_hierarchy.)
> > > > > > 
> > > > > > is clearer way to go, I think.
> > > > > > 
> > > > > > I wonder whether there is  mis-accounting problem or not..
> > > > > > 
> > hmm, after more consideration, although this patch can prevent the BUG,
> > it can leak memsw accounting of parents because memsw of parents, which
> > have been incremented by charge, does not decremented.
> > 
> > I'll try pet/put parent approach..
> > Or any other good ideas ?
> > 
> I attach a tryial patch.
> 
> It has been working fine so far(for about 1 hour).
> 
> Thanks,
> Daisuke Nishimura.
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> mem_cgroup_get ensures that the memcg that has been got can be accessed
> even after the directory has been removed, but it doesn't ensure that parents
> of it can be accessed: parents might have been freed already by rmdir.
> 
> This causes a bug in case of use_hierarchy==1, because res_counter_uncharge
> climb up the tree.
> 
> This patch tries to fix this probrem by getting parents at create, and
> putting them at freeing.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |   33 ++++++++++++++++++++++++++++++++-
>  1 files changed, 32 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fb62b43..b4aed07 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -202,6 +202,8 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
>  
>  static void mem_cgroup_get(struct mem_cgroup *mem);
>  static void mem_cgroup_put(struct mem_cgroup *mem);
> +static void mem_cgroup_get_parents(struct mem_cgroup *mem);
> +static void mem_cgroup_put_parents(struct mem_cgroup *mem);
>  
>  static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
>  					 struct page_cgroup *pc,
> @@ -2185,10 +2187,38 @@ static void mem_cgroup_get(struct mem_cgroup *mem)
>  
>  static void mem_cgroup_put(struct mem_cgroup *mem)
>  {
> -	if (atomic_dec_and_test(&mem->refcnt))
> +	if (atomic_dec_and_test(&mem->refcnt)) {
> +		mem_cgroup_put_parents(mem);
>  		__mem_cgroup_free(mem);
> +	}
> +}
> +
> +static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem)
> +{
> +	if (!mem->res.parent)
> +		return NULL;
> +	return mem_cgroup_from_res_counter(mem->res.parent, res);
> +}
> +
> +static void mem_cgroup_get_parents(struct mem_cgroup *mem)
> +{
> +	struct mem_cgroup *parent = parent_mem_cgroup(mem);
> +
> +	while (parent) {
> +		mem_cgroup_get(parent);
> +		parent = parent_mem_cgroup(parent);
> +	}
>  }
>  

does we have to add refcnt to all ancestors ?

Thanks,
-Kame

> +static void mem_cgroup_put_parents(struct mem_cgroup *mem)
> +{
> +	struct mem_cgroup *parent = parent_mem_cgroup(mem);
> +
> +	while (parent) {
> +		mem_cgroup_put(parent);
> +		parent = parent_mem_cgroup(parent);
> +	}
> +}
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  static void __init enable_swap_cgroup(void)
> @@ -2237,6 +2267,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	if (parent)
>  		mem->swappiness = get_swappiness(parent);
>  	atomic_set(&mem->refcnt, 1);
> +	mem_cgroup_get_parents(mem);
>  	return &mem->css;
>  free_out:
>  	__mem_cgroup_free(mem);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
