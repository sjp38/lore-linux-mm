Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0066B006E
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 09:35:47 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id h18so703028igc.13
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 06:35:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a13si2515422igm.21.2014.06.26.06.35.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jun 2014 06:35:46 -0700 (PDT)
Message-ID: <53AC21A8.5090703@redhat.com>
Date: Thu, 26 Jun 2014 15:35:36 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 04/13] smaps: remove mem_size_stats->vma and use walk_page_vma()
References: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1403295099-6407-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1403295099-6407-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 06/20/2014 10:11 PM, Naoya Horiguchi wrote:
> pagewalk.c can handle vma in itself, so we don't have to pass vma via
> walk->private. And show_smap() walks pages on vma basis, so using
> walk_page_vma() is preferable.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  fs/proc/task_mmu.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git v3.16-rc1.orig/fs/proc/task_mmu.c v3.16-rc1/fs/proc/task_mmu.c
> index cfa63ee92c96..9b6c7d4fd3f4 100644
> --- v3.16-rc1.orig/fs/proc/task_mmu.c
> +++ v3.16-rc1/fs/proc/task_mmu.c
> @@ -430,7 +430,6 @@ const struct file_operations proc_tid_maps_operations = {
>  
>  #ifdef CONFIG_PROC_PAGE_MONITOR
>  struct mem_size_stats {
> -	struct vm_area_struct *vma;
>  	unsigned long resident;
>  	unsigned long shared_clean;
>  	unsigned long shared_dirty;
> @@ -449,7 +448,7 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
>  		unsigned long ptent_size, struct mm_walk *walk)
>  {
>  	struct mem_size_stats *mss = walk->private;
> -	struct vm_area_struct *vma = mss->vma;
> +	struct vm_area_struct *vma = walk->vma;
>  	pgoff_t pgoff = linear_page_index(vma, addr);
>  	struct page *page = NULL;
>  	int mapcount;
> @@ -501,7 +500,7 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  			   struct mm_walk *walk)
>  {
>  	struct mem_size_stats *mss = walk->private;
> -	struct vm_area_struct *vma = mss->vma;
> +	struct vm_area_struct *vma = walk->vma;
>  	pte_t *pte;
>  	spinlock_t *ptl;
>  
> @@ -590,14 +589,13 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>  	struct mm_walk smaps_walk = {
>  		.pmd_entry = smaps_pte_range,
>  		.mm = vma->vm_mm,
> +		.vma = vma,

Seems redundant: walk_page_vma() sets walk.vma anyway and so does
walk_page_range(). Is there any case when the caller should set .vma itself?

Jerome

>  		.private = &mss,
>  	};
>  
>  	memset(&mss, 0, sizeof mss);
> -	mss.vma = vma;
>  	/* mmap_sem is held in m_start */
> -	if (vma->vm_mm && !is_vm_hugetlb_page(vma))
> -		walk_page_range(vma->vm_start, vma->vm_end, &smaps_walk);
> +	walk_page_vma(vma, &smaps_walk);
>  
>  	show_map_vma(m, vma, is_pid);
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
