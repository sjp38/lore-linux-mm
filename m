Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id F18BF6B0071
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 01:05:30 -0400 (EDT)
Date: Fri, 11 Jun 2010 13:59:41 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH] memcg remove css_get/put per pages v2
Message-Id: <20100611135941.b4df2e82.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100611135202.c0bc30c3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100608121901.3cab9bdf.kamezawa.hiroyu@jp.fujitsu.com>
	<20100609155940.dd121130.kamezawa.hiroyu@jp.fujitsu.com>
	<20100611133744.e5f14e3d.nishimura@mxp.nes.nec.co.jp>
	<20100611135202.c0bc30c3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jun 2010 13:52:02 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 11 Jun 2010 13:37:44 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > > @@ -2432,15 +2463,18 @@ mem_cgroup_uncharge_swapcache(struct pag
> > >  	if (!swapout) /* this was a swap cache but the swap is unused ! */
> > >  		ctype = MEM_CGROUP_CHARGE_TYPE_DROP;
> > >  
> > > -	memcg = __mem_cgroup_uncharge_common(page, ctype);
> > > +	memcg = try_get_mem_cgroup_from_page(page);
> > > +	if (!memcg)
> > > +		return;
> > > +
> > > +	__mem_cgroup_uncharge_common(page, ctype);
> > >  
> > >  	/* record memcg information */
> > > -	if (do_swap_account && swapout && memcg) {
> > > +	if (do_swap_account && swapout) {
> > >  		swap_cgroup_record(ent, css_id(&memcg->css));
> > >  		mem_cgroup_get(memcg);
> > >  	}
> > > -	if (swapout && memcg)
> > > -		css_put(&memcg->css);
> > > +	css_put(&memcg->css);
> > >  }
> > >  #endif
> > >  
> > hmm, this change seems to cause a problem.
> > I can see under flow of mem->memsw and "swap" field in memory.stat. 
> > 
> > I think doing swap_cgroup_record() against mem_cgroup which is not returned
> > by __mem_cgroup_uncharge_common() is a bad behavior.
> > 
> > How about doing like this ? We can safely access mem_cgroup while it has
> > memory.usage, iow, before we call res_counter_uncharge().
> > After this change, it seems to work well.
> > 
> 
> Thank you!. seems to work. I'll merge your change.
> Can I add your Signed-off-by ?
> 
Sure.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
