Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 573B86B003D
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 13:52:35 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp09.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2MIP3Q0008428
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 05:25:03 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2MIeknr491750
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 05:40:49 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2MIeSKi010716
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 05:40:29 +1100
Date: Mon, 23 Mar 2009 00:10:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH mmotm] memcg: try_get_mem_cgroup_from_swapcache
	fix
Message-ID: <20090322184015.GE24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090323000238.e650c65e.d-nishimura@mtf.biglobe.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090323000238.e650c65e.d-nishimura@mtf.biglobe.ne.jp>
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> [2009-03-23 00:02:38]:

> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> css_tryget can be called twice in !PageCgroupUsed case.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
> This is a fix for cgroups-use-css-id-in-swap-cgroup-for-saving-memory-v5.patch
> 
>  mm/memcontrol.c |   10 ++++------
>  1 files changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5de6be9..55dea59 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1027,9 +1027,11 @@ static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
>  	/*
>  	 * Used bit of swapcache is solid under page lock.
>  	 */
> -	if (PageCgroupUsed(pc))
> +	if (PageCgroupUsed(pc)) {
>  		mem = pc->mem_cgroup;
> -	else {
> +		if (mem && !css_tryget(&mem->css))
> +			mem = NULL;
> +	} else {
>  		ent.val = page_private(page);
>  		id = lookup_swap_cgroup(ent);
>  		rcu_read_lock();
> @@ -1038,10 +1040,6 @@ static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
>  			mem = NULL;
>  		rcu_read_unlock();
>  	}
> -	if (!mem)
> -		return NULL;
> -	if (!css_tryget(&mem->css))
> -		return NULL;
>  	return mem;
>  }

How did you detect the problem? Any test case/steps to reproduce the issue?


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
