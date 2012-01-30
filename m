Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 9B0926B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 01:28:10 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 213213EE0BD
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 15:28:09 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0781745DE4D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 15:28:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D877E45DE52
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 15:28:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CA1071DB803E
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 15:28:08 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7ECA41DB803B
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 15:28:08 +0900 (JST)
Date: Mon, 30 Jan 2012 15:26:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/6] introduce thp_ptep_get()
Message-Id: <20120130152646.3f202259.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1327705373-29395-6-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1327705373-29395-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1327705373-29395-6-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Fri, 27 Jan 2012 18:02:52 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Casting pmd into pte_t to handle thp is strongly architecture dependent.
> This patch introduces a new function to separate this dependency from
> independent part.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  arch/x86/include/asm/pgtable.h |    5 +++++
>  fs/proc/task_mmu.c             |    4 ++--
>  include/asm-generic/pgtable.h  |    4 ++++
>  3 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git 3.3-rc1.orig/arch/x86/include/asm/pgtable.h 3.3-rc1/arch/x86/include/asm/pgtable.h
> index 49afb3f..4cfcc7e 100644
> --- 3.3-rc1.orig/arch/x86/include/asm/pgtable.h
> +++ 3.3-rc1/arch/x86/include/asm/pgtable.h
> @@ -165,6 +165,11 @@ static inline int has_transparent_hugepage(void)
>  {
>  	return cpu_has_pse;
>  }
> +
> +static inline pte_t thp_ptep_get(pmd_t *pmd)
> +{
> +	return *(pte_t *)pmd;
> +}

I'm sorry but I don't think the name is good. 
(But I know my sense of naming is bad ;)

How about pmd_to_pte_t ?

And, I wonder you can add error check as VM_BUG_ON(!pmd_trans_huge(*pmd));


Thanks,
-Kame




>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  
>  static inline pte_t pte_set_flags(pte_t pte, pteval_t set)
> diff --git 3.3-rc1.orig/fs/proc/task_mmu.c 3.3-rc1/fs/proc/task_mmu.c
> index 2622b64..e2063d9 100644
> --- 3.3-rc1.orig/fs/proc/task_mmu.c
> +++ 3.3-rc1/fs/proc/task_mmu.c
> @@ -395,7 +395,7 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  	spinlock_t *ptl;
>  
>  	if (pmd_trans_huge_lock(pmd, vma) == 1) {
> -		smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_PMD_SIZE, walk);
> +		smaps_pte_entry(thp_ptep_get(pmd), addr, HPAGE_PMD_SIZE, walk);
>  		spin_unlock(&walk->mm->page_table_lock);
>  		mss->anonymous_thp += HPAGE_PMD_SIZE;
>  		return 0;
> @@ -964,7 +964,7 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
>  	md = walk->private;
>  
>  	if (pmd_trans_huge_lock(pmd, md->vma) == 1) {
> -		pte_t huge_pte = *(pte_t *)pmd;
> +		pte_t huge_pte = thp_ptep_get(pmd);
>  		struct page *page;
>  
>  		page = can_gather_numa_stats(huge_pte, md->vma, addr);
> diff --git 3.3-rc1.orig/include/asm-generic/pgtable.h 3.3-rc1/include/asm-generic/pgtable.h
> index 76bff2b..f346bdc 100644
> --- 3.3-rc1.orig/include/asm-generic/pgtable.h
> +++ 3.3-rc1/include/asm-generic/pgtable.h
> @@ -434,6 +434,10 @@ static inline int pmd_trans_splitting(pmd_t pmd)
>  {
>  	return 0;
>  }
> +static inline pte_t thp_ptep_get(pmd_t *pmd)
> +{
> +	return 0;
> +}
>  #ifndef __HAVE_ARCH_PMD_WRITE
>  static inline int pmd_write(pmd_t pmd)
>  {
> -- 
> 1.7.7.6
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
