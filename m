Date: Wed, 25 Jun 2008 19:53:55 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [-mm][PATCH 9/10]  memcg: fix mem_cgroup_end_migration() race
Message-Id: <20080625195355.6f452a4f.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080625190914.D867.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080625185717.D84C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080625190914.D867.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jun 2008 19:10:11 +0900, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> =
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
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
Sorry for late reply.

I've confirmed that this patch fixes the bad page problem
I had been seeing on my test(survived more than 28h w/o errors).

> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 

Tested-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>


Thanks,
Daisuke Nishimura.

> ---
>  mm/memcontrol.c |   14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> Index: b/mm/memcontrol.c
> ===================================================================
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
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
>  
>  /*
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
