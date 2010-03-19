Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 180066B01B1
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 16:07:06 -0400 (EDT)
Subject: Re: [PATCH 1/2] pagemap: add #ifdefs CONFIG_HUGETLB_PAGE on code
 walking hugetlb vma
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1268979996-12297-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1268979996-12297-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 19 Mar 2010 15:07:01 -0500
Message-ID: <1269029221.9534.145.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, andi.kleen@intel.com, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, 2010-03-19 at 15:26 +0900, Naoya Horiguchi wrote:
> If !CONFIG_HUGETLB_PAGE, pagemap_hugetlb_range() is never called.
> So put it (and its calling function) into #ifdef block.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Matt Mackall <mpm@selenic.com>

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



-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
