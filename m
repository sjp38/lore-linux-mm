Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D3CF86B0047
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 03:33:50 -0500 (EST)
Message-ID: <49704644.3020102@cn.fujitsu.com>
Date: Fri, 16 Jan 2009 16:33:08 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [BUG] memcg: panic when rmdir()
References: <497025E8.8050207@cn.fujitsu.com> <20090116170724.d2ad8344.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090116170724.d2ad8344.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 16 Jan 2009 14:15:04 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>> Found this when testing memory resource controller, can be triggered
>> with:
>> - CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n
>> - or CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y
>> - or CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y && boot with noswapaccount
>>
> 
> Li-san, could you try this ? I myself can't reproduce the bug yet...

I've tested this patch, and the bug seems to disappear. :)

Tested-by: Li Zefan <lizf@cn.fujitsu.com>

I'm going to be off office, and I'll do more testing to confirm this
next week.

> ==
> 
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, at swapoff, even while try_charge() fails, commit is executed.
> This is bug and make refcnt of cgroup_subsys_state minus, finally.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
