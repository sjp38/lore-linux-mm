Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3264D6B00A8
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 02:33:21 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2J6XJde030131
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Mar 2010 15:33:19 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B411445DE4E
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:33:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E0A245DE4D
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:33:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 789431DB803B
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:33:18 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 31ED21DB8037
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:33:18 +0900 (JST)
Date: Fri, 19 Mar 2010 15:29:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] pagemap: add #ifdefs CONFIG_HUGETLB_PAGE on code
 walking hugetlb vma
Message-Id: <20100319152934.c4243698.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1268979996-12297-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1268979996-12297-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, andi.kleen@intel.com, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, 19 Mar 2010 15:26:35 +0900
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> If !CONFIG_HUGETLB_PAGE, pagemap_hugetlb_range() is never called.
> So put it (and its calling function) into #ifdef block.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Hmm? What is benefit ? Is this broken now ?

Thanks,
-Kame

> ---
>  fs/proc/task_mmu.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 183f8ff..2a3ef17 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -652,6 +652,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  	return err;
>  }
>  
> +#ifdef CONFIG_HUGETLB_PAGE
>  static u64 huge_pte_to_pagemap_entry(pte_t pte, int offset)
>  {
>  	u64 pme = 0;
> @@ -695,6 +696,7 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long addr,
>  
>  	return err;
>  }
> +#endif /* HUGETLB_PAGE */
>  
>  /*
>   * /proc/pid/pagemap - an array mapping virtual pages to pfns
> @@ -788,7 +790,9 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
>  
>  	pagemap_walk.pmd_entry = pagemap_pte_range;
>  	pagemap_walk.pte_hole = pagemap_pte_hole;
> +#ifdef CONFIG_HUGETLB_PAGE
>  	pagemap_walk.hugetlb_entry = pagemap_hugetlb_range;
> +#endif
>  	pagemap_walk.mm = mm;
>  	pagemap_walk.private = &pm;
>  
> -- 
> 1.7.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
