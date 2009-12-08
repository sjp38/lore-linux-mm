Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5328460021B
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 21:16:00 -0500 (EST)
Date: Tue, 8 Dec 2009 11:13:49 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [cleanup][PATCH mmotm]memcg: don't call
 mem_cgroup_soft_limit_check() against root cgroup (Re: [BUG?] [PATCH] soft
 limits and root cgroups)
Message-Id: <20091208111349.36a2dcc9.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091208014713.GL5780@balbir.in.ibm.com>
References: <cc557aab0912071041j5c5731dbj9fd669ef26e6f2ae@mail.gmail.com>
	<20091208100954.44996a7e.nishimura@mxp.nes.nec.co.jp>
	<20091208014713.GL5780@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > current memory cgroup doesn't use res_counter about root cgroup, so soft limits
> > on root cgroup has no use.
> > This patch disables writing to <root cgroup>/memory.soft_limit_in_bytes and
> > changes uncharge path not to call mem_cgroup_soft_limit_check() against root
> > cgroup.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  Documentation/cgroups/memory.txt |    1 +
> >  mm/memcontrol.c                  |    6 +++++-
> >  2 files changed, 6 insertions(+), 1 deletions(-)
> > 
> > diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> > index b871f25..e1b5328 100644
> > --- a/Documentation/cgroups/memory.txt
> > +++ b/Documentation/cgroups/memory.txt
> > @@ -413,6 +413,7 @@ NOTE1: Soft limits take effect over a long period of time, since they involve
> >         reclaiming memory for balancing between memory cgroups
> >  NOTE2: It is recommended to set the soft limit always below the hard limit,
> >         otherwise the hard limit will take precedence.
> > +NOTE3: We cannot set soft limits on the root cgroup any more.
> > 
> >  8. TODO
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 661b8c6..0751533 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2056,7 +2056,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
> >  	mz = page_cgroup_zoneinfo(pc);
> >  	unlock_page_cgroup(pc);
> > 
> > -	if (mem_cgroup_soft_limit_check(mem))
> > +	if (!mem_cgroup_is_root(mem) && mem_cgroup_soft_limit_check(mem))
> >  		mem_cgroup_update_tree(mem, page);
> 
> May be the mem_cgroup_is_root() check should go inside
> mem_cgroup_soft_limit_check() for future call sites as well.
> 
I agree, thank you for your suggestion.
I'll update this patch with your ack, but considering it's in merge window now,
I'll hold this patch a while(this is not a so urgent patch).

Thanks,
Daisuke Nishimura.

> >  	/* at swapout, this memcg will be accessed to record to swap */
> >  	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
> > @@ -2787,6 +2787,10 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
> >  			ret = mem_cgroup_resize_memsw_limit(memcg, val);
> >  		break;
> >  	case RES_SOFT_LIMIT:
> > +		if (mem_cgroup_is_root(memcg)) { /* Can't set limit on root */
> > +			ret = -EINVAL;
> > +			break;
> > +		}
> >  		ret = res_counter_memparse_write_strategy(buffer, &val);
> >  		if (ret)
> >  			break;
> > 
> 
> looks good to me
> 
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>  
> 
> -- 
> 	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
