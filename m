Date: Thu, 3 Jul 2008 09:11:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][-mm] [3/7] add shmem page to active list.
Message-Id: <20080703091144.93465ba5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080702211057.7a7cf3dc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
	<20080702211057.7a7cf3dc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


On Wed, 2 Jul 2008 21:10:57 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Original one is Hugh Dickins's
>   http://marc.info/?l=linux-kernel&m=121469899304590&w=2
> Not necessary if his one is merged.
> 
It was merged. Then, this patch will be removed. (but see below)

> add shmem's page to active list when we link it to memcg's lru.
> need discussion ?
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>  mm/memcontrol.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> Index: test-2.6.26-rc5-mm3++/mm/memcontrol.c
> ===================================================================
> --- test-2.6.26-rc5-mm3++.orig/mm/memcontrol.c
> +++ test-2.6.26-rc5-mm3++/mm/memcontrol.c
> @@ -575,7 +575,10 @@ static int mem_cgroup_charge_common(stru
>  	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
>  		pc->flags = PAGE_CGROUP_FLAG_FILE;
>  	else
> -		pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
> +		pc->flags = 0;
> +	/* anonymous page and shmem pages are started from active list */
> +	if (!page_is_file_cache(page))
> +		pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
>  
This was wrong ;(

       if (page_is_file_cache(page))
                pc->flags = PAGE_CGROUP_FLAG_FILE;
        else
                pc->flags = PAGE_CGROUP_ACTIVE;

will be a correct one. And this will change the shmem's accounting attribute
from CACHE to ANON. Does anyone have strong demand to account shmem as CACHE ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
