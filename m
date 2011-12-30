Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 193C06B004D
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 22:39:23 -0500 (EST)
Received: by qcsd17 with SMTP id d17so9987196qcs.14
        for <linux-mm@kvack.org>; Thu, 29 Dec 2011 19:39:22 -0800 (PST)
Message-ID: <4EFD3266.4080701@gmail.com>
Date: Thu, 29 Dec 2011 22:39:18 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] pagemap: avoid splitting thp when reading /proc/pid/pagemap
References: <1324506228-18327-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1324506228-18327-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1324506228-18327-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

(12/21/11 5:23 PM), Naoya Horiguchi wrote:
> Thp split is not necessary if we explicitly check whether pmds are
> mapping thps or not. This patch introduces the check and the code
> to generate pagemap entries for pmds mapping thps, which results in
> less performance impact of pagemap on thp.
> 
> Signed-off-by: Naoya Horiguchi<n-horiguchi@ah.jp.nec.com>
> Reviewed-by: Andi Kleen<ak@linux.intel.com>
> 
> Changes since v1:
>    - move pfn declaration to the beginning of pagemap_pte_range()
> ---
>   fs/proc/task_mmu.c |   49 +++++++++++++++++++++++++++++++++++++++++++------
>   1 files changed, 43 insertions(+), 6 deletions(-)
> 
> diff --git 3.2-rc5.orig/fs/proc/task_mmu.c 3.2-rc5/fs/proc/task_mmu.c
> index e418c5a..0df61ab 100644
> --- 3.2-rc5.orig/fs/proc/task_mmu.c
> +++ 3.2-rc5/fs/proc/task_mmu.c
> @@ -600,6 +600,9 @@ struct pagemapread {
>   	u64 *buffer;
>   };
> 
> +#define PAGEMAP_WALK_SIZE	(PMD_SIZE)
> +#define PAGEMAP_WALK_MASK	(PMD_MASK)
> +
>   #define PM_ENTRY_BYTES      sizeof(u64)
>   #define PM_STATUS_BITS      3
>   #define PM_STATUS_OFFSET    (64 - PM_STATUS_BITS)
> @@ -658,6 +661,22 @@ static u64 pte_to_pagemap_entry(pte_t pte)
>   	return pme;
>   }
> 
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static u64 thp_pte_to_pagemap_entry(pte_t pte, int offset)
> +{
> +	u64 pme = 0;
> +	if (pte_present(pte))

When does pte_present() return 0?

> +		pme = PM_PFRAME(pte_pfn(pte) + offset)
> +			| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
> +	return pme;
> +}
> +#else
> +static inline u64 thp_pte_to_pagemap_entry(pte_t pte, int offset)
> +{
> +	return 0;
> +}
> +#endif
> +
>   static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>   			     struct mm_walk *walk)
>   {
> @@ -665,14 +684,34 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>   	struct pagemapread *pm = walk->private;
>   	pte_t *pte;
>   	int err = 0;
> -
> -	split_huge_page_pmd(walk->mm, pmd);
> +	u64 pfn = PM_NOT_PRESENT;
> 
>   	/* find the first VMA at or above 'addr' */
>   	vma = find_vma(walk->mm, addr);
> -	for (; addr != end; addr += PAGE_SIZE) {
> -		u64 pfn = PM_NOT_PRESENT;
> 
> +	spin_lock(&walk->mm->page_table_lock);
> +	if (pmd_trans_huge(*pmd)) {
> +		if (pmd_trans_splitting(*pmd)) {
> +			spin_unlock(&walk->mm->page_table_lock);
> +			wait_split_huge_page(vma->anon_vma, pmd);
> +		} else {
> +			for (; addr != end; addr += PAGE_SIZE) {
> +				int offset = (addr&  ~PAGEMAP_WALK_MASK)
> +					>>  PAGE_SHIFT;

implicit narrowing conversion. offset should be unsigned long.


> +				pfn = thp_pte_to_pagemap_entry(*(pte_t *)pmd,
> +							       offset);

This (pte_t*) cast looks introduce new implicit assumption. Please don't
put x86 assumption here directly.




> +				err = add_to_pagemap(addr, pfn, pm);
> +				if (err)
> +					break;
> +			}
> +			spin_unlock(&walk->mm->page_table_lock);
> +			return err;
> +		}
> +	} else {
> +		spin_unlock(&walk->mm->page_table_lock);
> +	}

coding standard violation. plz run check_patch.pl.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
