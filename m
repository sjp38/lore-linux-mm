Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id ED0416B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 06:31:00 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id n0FBUilU011469
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 17:00:44 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0FBUm4g4350180
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 17:00:48 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n0FBUhLj005045
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 22:30:43 +1100
Date: Thu, 15 Jan 2009 17:00:37 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] mark_page_accessed() in do_swap_page() move latter
	than memcg charge
Message-ID: <20090115113037.GH30358@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090109043257.GB9737@balbir.in.ibm.com> <20090109134736.a995fc49.kamezawa.hiroyu@jp.fujitsu.com> <20090115200545.EBE6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090115200545.EBE6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, menage@google.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-01-15 20:08:36]:

> 
> sorry for late responce.
> 
> > > In this case we've hit a case where the page is valid and the pc is
> > > not. This does fix the problem, but won't this impact us getting
> > > correct reclaim stats and thus indirectly impact the working of
> > > pressure?
> > > 
> >  - If retruns NULL, only global LRU's status is updated. 
> > 
> > Because this page is not belongs to any memcg, we cannot update
> > any counters. But yes, your point is a concern.
> > 
> > Maybe moving acitvate_page() to
> > ==
> > do_swap_page()
> > {
> >     
> > - activate_page()
> >    mem_cgroup_try_charge()..
> >    ....
> >    mem_cgroup_commit_charge()....
> >    ....
> > +  activate_page()   
> > }
> > ==
> > is necessary. How do you think, kosaki ?
> 
> 
> OK. it makes sense. and my test found no bug.
> 
> ==
> 
> mark_page_accessed() update reclaim_stat statics.
> but currently, memcg charge is called after mark_page_accessed().
> 
> then, mark_page_accessed() don't update memcg statics correctly.
> 
> fixing here.
> 

Changelog needs to be a bit more elaborate, may be talk about invalid
pointer we hit if mark_page_accessed is not moved, etc.

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> ---
>  mm/memory.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Index: b/mm/memory.c
> ===================================================================
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2426,8 +2426,6 @@ static int do_swap_page(struct mm_struct
>  		count_vm_event(PGMAJFAULT);
>  	}
> 
> -	mark_page_accessed(page);
> -
>  	lock_page(page);
>  	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
> 
> @@ -2480,6 +2478,8 @@ static int do_swap_page(struct mm_struct
>  		try_to_free_swap(page);
>  	unlock_page(page);
> 
> +	mark_page_accessed(page);
> +
>  	if (write_access) {
>  		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
>  		if (ret & VM_FAULT_ERROR)
> 
> 
>

Looks good to me otherwise

Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
