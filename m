Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id A17706B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 01:23:47 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8C67B3EE0B6
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 15:23:45 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E77645DE50
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 15:23:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CDB945DE4D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 15:23:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BBEE1DB803B
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 15:23:45 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BB7391DB802F
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 15:23:44 +0900 (JST)
Date: Mon, 30 Jan 2012 15:22:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/6] thp: optimize away unnecessary page table locking
Message-Id: <20120130152212.3a6a2039.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1327705373-29395-3-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1327705373-29395-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1327705373-29395-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Fri, 27 Jan 2012 18:02:49 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Currently when we check if we can handle thp as it is or we need to
> split it into regular sized pages, we hold page table lock prior to
> check whether a given pmd is mapping thp or not. Because of this,
> when it's not "huge pmd" we suffer from unnecessary lock/unlock overhead.
> To remove it, this patch introduces a optimized check function and
> replace several similar logics with it.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: David Rientjes <rientjes@google.com>
> 
> Changes since v3:
>   - Fix likely/unlikely pattern in pmd_trans_huge_stable()
>   - Change suffix from _stable to _lock
>   - Introduce __pmd_trans_huge_lock() to avoid micro-regression
>   - Return 1 when wait_split_huge_page path is taken
> 
> Changes since v2:
>   - Fix missing "return 0" in "thp under splitting" path
>   - Remove unneeded comment
>   - Change the name of check function to describe what it does
>   - Add VM_BUG_ON(mmap_sem)



> +/*
> + * Returns 1 if a given pmd maps a stable (not under splitting) thp,
> + * -1 if the pmd maps thp under splitting, 0 if the pmd does not map thp.
> + *
> + * Note that if it returns 1, this routine returns without unlocking page
> + * table locks. So callers must unlock them.
> + */


Seems nice clean up but... why you need to return (-1, 0, 1) ?

It seems the caller can't see the difference between -1 and 0.

Why not just return 0 (not locked) or 1 (thp found and locked) ?

Thanks,
-Kame

> +int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma)
> +{
> +	spin_lock(&vma->vm_mm->page_table_lock);
>  	if (likely(pmd_trans_huge(*pmd))) {
>  		if (unlikely(pmd_trans_splitting(*pmd))) {
> -			spin_unlock(&mm->page_table_lock);
> +			spin_unlock(&vma->vm_mm->page_table_lock);
>  			wait_split_huge_page(vma->anon_vma, pmd);
> +			return -1;
>  		} else {
> -			pmd_t entry;
> -
> -			entry = pmdp_get_and_clear(mm, addr, pmd);
> -			entry = pmd_modify(entry, newprot);
> -			set_pmd_at(mm, addr, pmd, entry);
> -			spin_unlock(&vma->vm_mm->page_table_lock);
> -			ret = 1;
> +			/* Thp mapped by 'pmd' is stable, so we can
> +			 * handle it as it is. */
> +			return 1;
>  		}
> -	} else
> -		spin_unlock(&vma->vm_mm->page_table_lock);
> -
> -	return ret;
> +	}
> +	spin_unlock(&vma->vm_mm->page_table_lock);
> +	return 0;
>  }
>  
>  pmd_t *page_check_address_pmd(struct page *page,
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
