Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 667716B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 20:59:04 -0400 (EDT)
Date: Thu, 29 Oct 2009 09:50:51 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [BUGFIX][PATCH] memcg: fix wrong pointer initialization at page
 migration when memcg is disabled.
Message-Id: <20091029095051.7812e5ad.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091029093013.cd58f3a5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091029093013.cd58f3a5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Lee.Schermerhorn@hp.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Oct 2009 09:30:13 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> Lee Schermerhorn reported that he saw bad pointer dereference
> in mem_cgroup_end_migration() when he disabled memcg by boot option.
> 
> memcg's page migration logic works as
> 
> 	mem_cgroup_prepare_migration(page, &ptr);
> 	do page migration
> 	mem_cgroup_end_migration(page, ptr);
> 
> Now, ptr is not initialized in prepare_migration when memcg is disabled
> by boot option. This causes panic in end_migration. This patch fixes it.
> 
> Reported-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> Cc: Balbir Singh <balbir@in.ibm.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.32-rc5/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.32-rc5.orig/mm/memcontrol.c
> +++ linux-2.6.32-rc5/mm/memcontrol.c
> @@ -1990,7 +1990,8 @@ int mem_cgroup_prepare_migration(struct 
>  	struct page_cgroup *pc;
>  	struct mem_cgroup *mem = NULL;
>  	int ret = 0;
> -
> +	/* this pointer will be checked at end_migration */
> +	*ptr = NULL;
>  	if (mem_cgroup_disabled())
>  		return 0;
>  
> 
I thought unmap_and_move() itself initializes "mem" to NULL, but it doesn't...
I personaly prefer initializing "mem" to NULL in unmap_and_move(), but anyway
I think this patch is also correct.

	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

And I think we should send a fix for this bug to -stable too.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
