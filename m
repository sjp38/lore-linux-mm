Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5O7RtH4005479
	for <linux-mm@kvack.org>; Tue, 24 Jun 2008 12:57:55 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5O7Rawn901142
	for <linux-mm@kvack.org>; Tue, 24 Jun 2008 12:57:36 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5O7RsrS032475
	for <linux-mm@kvack.org>; Tue, 24 Jun 2008 12:57:55 +0530
Message-ID: <4860A1EB.4070202@linux.vnet.ibm.com>
Date: Tue, 24 Jun 2008 12:57:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: end migration fix (was  [bad page] memcg: another
 bad page at page migration (2.6.26-rc5-mm3 + patch collection))
References: <20080623145341.0a365c67.nishimura@mxp.nes.nec.co.jp> <20080624145127.539eb5ff.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080624145127.539eb5ff.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, xemul@openvz.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Hi, Nishimura-san. thank you for all your help. 
> 
> I think this one is......hopefully.
> 
> ==
> 
> In general, mem_cgroup's charge on ANON page is removed when page_remove_rmap()
> is called.
> 
> At migration, the newpage is remapped again by remove_migration_ptes(). But
> pte may be already changed (by task exits).
> It is charged at page allocation but have no chance to be uncharged in that
> case because it is never added to rmap.
> 
> Handle that corner case in mem_cgroup_end_migration().
> 
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> 
> ---
>  mm/memcontrol.c |   14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> Index: test2-2.6.26-rc5-mm3/mm/memcontrol.c
> ===================================================================
> --- test2-2.6.26-rc5-mm3.orig/mm/memcontrol.c
> +++ test2-2.6.26-rc5-mm3/mm/memcontrol.c
> @@ -747,10 +747,22 @@ int mem_cgroup_prepare_migration(struct 
>  /* remove redundant charge if migration failed*/
>  void mem_cgroup_end_migration(struct page *newpage)
>  {
> -	/* At success, page->mapping is not NULL and nothing to do. */
> +	/*
> +	 * At success, page->mapping is not NULL.
> +	 * special rollback care is necessary when
> +	 * 1. at migration failure. (newpage->mapping is cleared in this case)
> +	 * 2. the newpage was moved but not remapped again because the task
> +	 *    exits and the newpage is obsolete. In this case, the new page
> +	 *    may be a swapcache. So, we just call mem_cgroup_uncharge_page()
> +	 *    always for avoiding mess. The  page_cgroup will be removed if
> +	 *    unnecessary. File cache pages is still on radix-tree. Don't
> +	 *    care it.
> +	 */
>  	if (!newpage->mapping)
>  		__mem_cgroup_uncharge_common(newpage,
>  					 MEM_CGROUP_CHARGE_TYPE_FORCE);
> +	else if (PageAnon(newpage))
> +		mem_cgroup_uncharge_page(newpage);
>  }

Definitely makes sense to me!

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
