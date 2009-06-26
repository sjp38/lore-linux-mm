Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DC9606B006A
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 08:48:20 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5QCiXM1013704
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 08:44:33 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5QCnlWX247100
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 08:49:47 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5QCnjnu016683
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 08:49:46 -0400
Date: Fri, 26 Jun 2009 10:18:03 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: add commens for expaing memory barrier (Was Re:
	Low overhead patches for the memory cgroup controller (v5)
Message-ID: <20090626044803.GG8642@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090615043900.GF23577@balbir.in.ibm.com> <20090622154343.9cdbf23a.akpm@linux-foundation.org> <20090623090116.556d4f97.kamezawa.hiroyu@jp.fujitsu.com> <20090626095745.01cef410.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090626095745.01cef410.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, lizf@cn.fujitsu.com, menage@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-06-26 09:57:45]:

> On Tue, 23 Jun 2009 09:01:16 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > Do we still need the smp_wmb()?
> > > 
> > > It's hard to say, because we forgot to document it :(
> > > 
> > Sorry for lack of documentation.
> > 
> > pc->mem_cgroup should be visible before SetPageCgroupUsed(). Othrewise,
> > A routine believes USED bit will see bad pc->mem_cgroup.
> > 
> > I'd like to  add a comment later (againt new mmotm.)
> > 
> 
> Ok, it's now.
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Add comments for the reason of smp_wmb() in mem_cgroup_commit_charge().
> 
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |    7 +++++++
>  1 file changed, 7 insertions(+)
> 
> Index: mmotm-2.6.31-Jun25/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.31-Jun25.orig/mm/memcontrol.c
> +++ mmotm-2.6.31-Jun25/mm/memcontrol.c
> @@ -1134,6 +1134,13 @@ static void __mem_cgroup_commit_charge(s
>  	}
> 
>  	pc->mem_cgroup = mem;
> +	/*
> + 	 * We access a page_cgroup asynchronously without lock_page_cgroup().
> + 	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
> + 	 * is accessed after testing USED bit. To make pc->mem_cgroup visible
> + 	 * before USED bit, we need memory barrier here.
> + 	 * See mem_cgroup_add_lru_list(), etc.
> + 	 */


I don't think this is sufficient, since in
mem_cgroup_get_reclaim_stat_from_page() we say we need this since we
set used bit without atomic operation. The used bit is now atomically
set. I think we need to reword other comments as well.
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
