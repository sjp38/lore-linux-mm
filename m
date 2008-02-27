Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1R5vUYC021673
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 16:57:30 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1R5vroD4542682
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 16:57:53 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1R5vrSV016524
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 16:57:53 +1100
Date: Wed, 27 Feb 2008 11:22:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 05/15] memcg: fix VM_BUG_ON from page migration
Message-ID: <20080227055211.GB2317@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site> <Pine.LNX.4.64.0802252338080.27067@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802252338080.27067@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Hugh Dickins <hugh@veritas.com> [2008-02-25 23:39:23]:

> Page migration gave me free_hot_cold_page's VM_BUG_ON page->page_cgroup.
> remove_migration_pte was calling mem_cgroup_charge on the new page whenever
> it found a swap pte, before it had determined it to be a migration entry.
> That left a surplus reference count on the page_cgroup, so it was still
> attached when the page was later freed.
> 
> Move that mem_cgroup_charge down to where we're sure it's a migration entry.
> We were already under i_mmap_lock or anon_vma->lock, so its GFP_KERNEL was
> already inappropriate: change that to GFP_ATOMIC.
>

One side effect I see of this patch is that the page_cgroup lock and
the lru_lock can now be taken from within i_mmap_lock or
anon_vma->lock.
 
> It's essential that remove_migration_pte removes all the migration entries,
> other crashes follow if not.  So proceed even when the charge fails: normally
> it cannot, but after a mem_cgroup_force_empty it might - comment in the code.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
> 
>  mm/migrate.c |   19 ++++++++++++++-----
>  1 file changed, 14 insertions(+), 5 deletions(-)
> 
> --- memcg04/mm/migrate.c	2008-02-11 07:18:12.000000000 +0000
> +++ memcg05/mm/migrate.c	2008-02-25 14:05:50.000000000 +0000
> @@ -153,11 +153,6 @@ static void remove_migration_pte(struct 
>   		return;
>   	}
> 
> -	if (mem_cgroup_charge(new, mm, GFP_KERNEL)) {
> -		pte_unmap(ptep);
> -		return;
> -	}
> -
>   	ptl = pte_lockptr(mm, pmd);
>   	spin_lock(ptl);
>  	pte = *ptep;
> @@ -169,6 +164,20 @@ static void remove_migration_pte(struct 
>  	if (!is_migration_entry(entry) || migration_entry_to_page(entry) != old)
>  		goto out;

Is it not easier to uncharge here then to move to the charging to the
context below? Do you suspect this will be a common operation (so we
might end up charging/uncharing more frequently?)

> 
> +	/*
> +	 * Yes, ignore the return value from a GFP_ATOMIC mem_cgroup_charge.
> +	 * Failure is not an option here: we're now expected to remove every
> +	 * migration pte, and will cause crashes otherwise.  Normally this
> +	 * is not an issue: mem_cgroup_prepare_migration bumped up the old
> +	 * page_cgroup count for safety, that's now attached to the new page,
> +	 * so this charge should just be another incrementation of the count,
> +	 * to keep in balance with rmap.c's mem_cgroup_uncharging.  But if
> +	 * there's been a force_empty, those reference counts may no longer
> +	 * be reliable, and this charge can actually fail: oh well, we don't
> +	 * make the situation any worse by proceeding as if it had succeeded.
> +	 */
> +	mem_cgroup_charge(new, mm, GFP_ATOMIC);
> +
>  	get_page(new);
>  	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
>  	if (is_write_migration_entry(entry))

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
