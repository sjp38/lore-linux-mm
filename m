Message-ID: <4816823D.8000101@cn.fujitsu.com>
Date: Tue, 29 Apr 2008 10:04:45 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 5/8] memcg: optimize branches
References: <20080428201900.ae25e086.kamezawa.hiroyu@jp.fujitsu.com> <20080428202810.a8de4468.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080428202810.a8de4468.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Showing brach direction for obvious conditions.
> 

Did you compare the compiled objects with and without this patch ?

It seems gcc will take (ptr == NULL) as unlikely without your explicit
anotation. And likely() and unlikely() should be used in some performance-
critical path only ?

> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  mm/memcontrol.c |   10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> Index: mm-2.6.25-mm1/mm/memcontrol.c
> ===================================================================
> --- mm-2.6.25-mm1.orig/mm/memcontrol.c
> +++ mm-2.6.25-mm1/mm/memcontrol.c
> @@ -541,7 +541,7 @@ retry:
>  	 * The page_cgroup exists and
>  	 * the page has already been accounted.
>  	 */
> -	if (pc) {
> +	if (unlikely(pc)) {
>  		VM_BUG_ON(pc->page != page);
>  		VM_BUG_ON(!pc->mem_cgroup);
>  		unlock_page_cgroup(page);
> @@ -550,7 +550,7 @@ retry:
>  	unlock_page_cgroup(page);
>  
>  	pc = kmem_cache_zalloc(page_cgroup_cache, gfp_mask);
> -	if (pc == NULL)
> +	if (unlikely(!pc))
>  		goto err;
>  
>  	/*
> @@ -602,7 +602,7 @@ retry:
>  		pc->flags = PAGE_CGROUP_FLAG_CACHE;
>  
>  	lock_page_cgroup(page);
> -	if (page_get_page_cgroup(page)) {
> +	if (unlikely(page_get_page_cgroup(page))) {
>  		unlock_page_cgroup(page);
>  		/*
>  		 * Another charge has been added to this page already.
> @@ -668,7 +668,7 @@ void __mem_cgroup_uncharge_common(struct
>  	 */
>  	lock_page_cgroup(page);
>  	pc = page_get_page_cgroup(page);
> -	if (!pc)
> +	if (unlikely(!pc))
>  		goto unlock;
>  
>  	VM_BUG_ON(pc->page != page);
> 
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
