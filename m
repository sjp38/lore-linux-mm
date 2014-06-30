Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 350C46B0036
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 08:07:43 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q59so8150661wes.40
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 05:07:42 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id j3si14355898wjf.168.2014.06.30.05.07.41
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 05:07:42 -0700 (PDT)
Date: Mon, 30 Jun 2014 15:07:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 07/13] numa_maps: remove numa_maps->vma
Message-ID: <20140630120735.GW19833@node.dhcp.inet.fi>
References: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1403295099-6407-8-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403295099-6407-8-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Jun 20, 2014 at 04:11:33PM -0400, Naoya Horiguchi wrote:
> pagewalk.c can handle vma in itself, so we don't have to pass vma via
> walk->private. And show_numa_map() walks pages on vma basis, so using
> walk_page_vma() is preferable.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  fs/proc/task_mmu.c | 18 ++++++++----------
>  1 file changed, 8 insertions(+), 10 deletions(-)
> 
> diff --git v3.16-rc1.orig/fs/proc/task_mmu.c v3.16-rc1/fs/proc/task_mmu.c
> index 74f87794afab..b4459c006d50 100644
> --- v3.16-rc1.orig/fs/proc/task_mmu.c
> +++ v3.16-rc1/fs/proc/task_mmu.c
> @@ -1247,7 +1247,6 @@ const struct file_operations proc_pagemap_operations = {
>  #ifdef CONFIG_NUMA
>  
>  struct numa_maps {
> -	struct vm_area_struct *vma;
>  	unsigned long pages;
>  	unsigned long anon;
>  	unsigned long active;
> @@ -1316,18 +1315,17 @@ static struct page *can_gather_numa_stats(pte_t pte, struct vm_area_struct *vma,
>  static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
>  		unsigned long end, struct mm_walk *walk)
>  {
> -	struct numa_maps *md;
> +	struct numa_maps *md = walk->private;
> +	struct vm_area_struct *vma = walk->vma;
>  	spinlock_t *ptl;
>  	pte_t *orig_pte;
>  	pte_t *pte;
>  
> -	md = walk->private;
> -
> -	if (pmd_trans_huge_lock(pmd, md->vma, &ptl) == 1) {
> +	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
>  		pte_t huge_pte = *(pte_t *)pmd;
>  		struct page *page;
>  
> -		page = can_gather_numa_stats(huge_pte, md->vma, addr);
> +		page = can_gather_numa_stats(huge_pte, vma, addr);
>  		if (page)
>  			gather_stats(page, md, pte_dirty(huge_pte),
>  				     HPAGE_PMD_SIZE/PAGE_SIZE);
> @@ -1339,7 +1337,7 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
>  		return 0;
>  	orig_pte = pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
>  	do {
> -		struct page *page = can_gather_numa_stats(*pte, md->vma, addr);
> +		struct page *page = can_gather_numa_stats(*pte, vma, addr);
>  		if (!page)
>  			continue;
>  		gather_stats(page, md, pte_dirty(*pte), 1);
> @@ -1398,12 +1396,11 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
>  	/* Ensure we start with an empty set of numa_maps statistics. */
>  	memset(md, 0, sizeof(*md));
>  
> -	md->vma = vma;
> -
>  	walk.hugetlb_entry = gather_hugetbl_stats;
>  	walk.pmd_entry = gather_pte_stats;
>  	walk.private = md;
>  	walk.mm = mm;
> +	walk.vma = vma;

Redundant. 

And it's probably good idea move walk initialization to declaration.

Otherwise:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

>  
>  	pol = get_vma_policy(task, vma, vma->vm_start);
>  	mpol_to_str(buffer, sizeof(buffer), pol);
> @@ -1434,7 +1431,8 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
>  	if (is_vm_hugetlb_page(vma))
>  		seq_puts(m, " huge");
>  
> -	walk_page_range(vma->vm_start, vma->vm_end, &walk);
> +	/* mmap_sem is held by m_start */
> +	walk_page_vma(vma, &walk);
>  
>  	if (!md->pages)
>  		goto out;
> -- 
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
