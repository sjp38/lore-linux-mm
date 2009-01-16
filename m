Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E471D6B0044
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 03:28:08 -0500 (EST)
Date: Fri, 16 Jan 2009 17:26:51 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [BUG] memcg: panic when rmdir()
Message-Id: <20090116172651.3e11fb0c.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090116170724.d2ad8344.kamezawa.hiroyu@jp.fujitsu.com>
References: <497025E8.8050207@cn.fujitsu.com>
	<20090116170724.d2ad8344.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Li Zefan <lizf@cn.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Jan 2009 17:07:24 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, at swapoff, even while try_charge() fails, commit is executed.
> This is bug and make refcnt of cgroup_subsys_state minus, finally.
> 
Nice catch!

I think this bug can explain this problem I've seen.
Commiting on trycharge failure will add the pc to the lru
without a corresponding charge and refcnt.
And rmdir uncharges the pc(so we get WARNING: at kernel/res_counter.c:71)
and decrements the refcnt(so we get BUG at kernel/cgroup.c:2517).

Even if the problem cannot be fixed by this patch, this patch is valid and needed.

> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

I'll test it.


Thanks,
Daisuke Nishimura.

> ---
> Index: mmotm-2.6.29-Jan14/mm/swapfile.c
> ===================================================================
> --- mmotm-2.6.29-Jan14.orig/mm/swapfile.c
> +++ mmotm-2.6.29-Jan14/mm/swapfile.c
> @@ -698,8 +698,10 @@ static int unuse_pte(struct vm_area_stru
>  	pte_t *pte;
>  	int ret = 1;
>  
> -	if (mem_cgroup_try_charge_swapin(vma->vm_mm, page, GFP_KERNEL, &ptr))
> +	if (mem_cgroup_try_charge_swapin(vma->vm_mm, page, GFP_KERNEL, &ptr)) {
>  		ret = -ENOMEM;
> +		goto out_nolock;
> +	}
>  
>  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
>  	if (unlikely(!pte_same(*pte, swp_entry_to_pte(entry)))) {
> @@ -723,6 +725,7 @@ static int unuse_pte(struct vm_area_stru
>  	activate_page(page);
>  out:
>  	pte_unmap_unlock(pte, ptl);
> +out_nolock:
>  	return ret;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
