Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6B6796B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 01:04:49 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8H54kSN008751
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 17 Sep 2009 14:04:46 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E4CB45DE55
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 14:04:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ED34745DE51
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 14:04:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D657E1DB8038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 14:04:45 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A9431DB803A
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 14:04:42 +0900 (JST)
Date: Thu, 17 Sep 2009 14:02:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/8] memcg: migrate charge of shmem
Message-Id: <20090917140238.72c7de1a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090917112737.57fc2fba.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917112737.57fc2fba.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Sep 2009 11:27:37 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This patch adds some checks to enable migration charge of shmem(and mmapd tmpfs file).
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Hmm...move shmem ? Ah, maybe this patch itself is not bad.
(I don't like move_shmem flag ;)

Thinking more, "file cache" should be able to moved.

Shouldn't we implement
	sys_madvice(REACCOUNT_PAGE_MEMCG)
or some ?

Then, we can isolate a big file cache/shmem.

Thanks.
-Kmae

> ---
>  mm/memcontrol.c |   10 ++++++++--
>  1 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 830fa71..f46fd19 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2844,6 +2844,7 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
>  
>  enum migrate_charge_type {
>  	MIGRATE_CHARGE_ANON,
> +	MIGRATE_CHARGE_SHMEM,
>  	NR_MIGRATE_CHARGE_TYPE,
>  };
>  
> @@ -3210,6 +3211,8 @@ static int migrate_charge_prepare_pte_range(pmd_t *pmd,
>  	pte_t *pte, ptent;
>  	spinlock_t *ptl;
>  	bool move_anon = (mc->to->migrate_charge & (1 << MIGRATE_CHARGE_ANON));
> +	bool move_shmem = (mc->to->migrate_charge &
> +					(1 << MIGRATE_CHARGE_SHMEM));
>  
>  	lru_add_drain_all();
>  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> @@ -3226,6 +3229,8 @@ static int migrate_charge_prepare_pte_range(pmd_t *pmd,
>  
>  		if (PageAnon(page) && move_anon)
>  			;
> +		else if (!PageAnon(page) && PageSwapBacked(page) && move_shmem)
> +			;
>  		else
>  			continue;
>  
> @@ -3281,6 +3286,8 @@ static int migrate_charge_prepare(void)
>  	int ret = 0;
>  	struct mm_struct *mm;
>  	struct vm_area_struct *vma;
> +	bool move_shmem = (mc->to->migrate_charge &
> +					(1 << MIGRATE_CHARGE_SHMEM));
>  
>  	mm = get_task_mm(mc->tsk);
>  	if (!mm)
> @@ -3299,8 +3306,7 @@ static int migrate_charge_prepare(void)
>  		}
>  		if (is_vm_hugetlb_page(vma))
>  			continue;
> -		/* We migrate charge of private pages for now */
> -		if (vma->vm_flags & (VM_SHARED | VM_MAYSHARE))
> +		if (vma->vm_flags & (VM_SHARED | VM_MAYSHARE) && !move_shmem)
>  			continue;
>  		if (mc->to->migrate_charge) {
>  			ret = walk_page_range(vma->vm_start, vma->vm_end,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
