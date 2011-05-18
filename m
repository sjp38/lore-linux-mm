Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D200C8D003B
	for <linux-mm@kvack.org>; Wed, 18 May 2011 01:50:04 -0400 (EDT)
Date: Wed, 18 May 2011 14:43:49 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH mmotm] add the pagefault count into memcg stats: shmem
 fix
Message-Id: <20110518144349.a44ae926.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <alpine.LSU.2.00.1105171120220.29593@sister.anvils>
References: <alpine.LSU.2.00.1105171120220.29593@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Tue, 17 May 2011 11:24:40 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> mem_cgroup_count_vm_event() should update the PGMAJFAULT count for the
> target mm, not for current mm (but of course they're usually the same).
> 
hmm, why ?
In shmem_getpage(), we charge the page to the memcg where current mm belongs to,
so I think counting vm events of the memcg is right.

Thanks,
Daisuke Nishimura.

> We don't know the target mm in shmem_getpage(), so do it at the outer
> level in shmem_fault(); and it's easier to follow if we move the
> count_vm_event(PGMAJFAULT) there too.
> 
> Hah, it was using __count_vm_event() before, sneaking that update into
> the unpreemptible section under info->lock: well, it comes to the same
> on x86 at least, and I still think it's best to keep these together.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> 
>  mm/shmem.c |   13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
> 
> --- mmotm/mm/shmem.c	2011-05-13 14:57:45.367884578 -0700
> +++ linux/mm/shmem.c	2011-05-17 10:27:19.901934756 -0700
> @@ -1293,14 +1293,10 @@ repeat:
>  		swappage = lookup_swap_cache(swap);
>  		if (!swappage) {
>  			shmem_swp_unmap(entry);
> +			spin_unlock(&info->lock);
>  			/* here we actually do the io */
> -			if (type && !(*type & VM_FAULT_MAJOR)) {
> -				__count_vm_event(PGMAJFAULT);
> -				mem_cgroup_count_vm_event(current->mm,
> -							  PGMAJFAULT);
> +			if (type)
>  				*type |= VM_FAULT_MAJOR;
> -			}
> -			spin_unlock(&info->lock);
>  			swappage = shmem_swapin(swap, gfp, info, idx);
>  			if (!swappage) {
>  				spin_lock(&info->lock);
> @@ -1539,7 +1535,10 @@ static int shmem_fault(struct vm_area_st
>  	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_CACHE, &ret);
>  	if (error)
>  		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
> -
> +	if (ret & VM_FAULT_MAJOR) {
> +		count_vm_event(PGMAJFAULT);
> +		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
> +	}
>  	return ret | VM_FAULT_LOCKED;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
