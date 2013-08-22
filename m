Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 230606B0034
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 11:53:13 -0400 (EDT)
Date: Thu, 22 Aug 2013 11:52:52 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1377186772-rb1um2cz-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1377164907-24801-2-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377164907-24801-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377164907-24801-2-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/6] mm/hwpoison: don't need to hold compound lock for
 hugetlbfs page
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 22, 2013 at 05:48:23PM +0800, Wanpeng Li wrote:
> compound lock is introduced by commit e9da73d67("thp: compound_lock."), 
> it is used to serialize put_page against __split_huge_page_refcount(). 
> In addition, transparent hugepages will be splitted in hwpoison handler 
> and just one subpage will be poisoned. There is unnecessary to hold 
> compound lock for hugetlbfs page. This patch replace compound_trans_order 
> by compond_order in the place where the page is hugetlbfs page.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  mm/memory-failure.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 2c13aa7..5092e06 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -206,7 +206,7 @@ static int kill_proc(struct task_struct *t, unsigned long addr, int trapno,
>  #ifdef __ARCH_SI_TRAPNO
>  	si.si_trapno = trapno;
>  #endif
> -	si.si_addr_lsb = compound_trans_order(compound_head(page)) + PAGE_SHIFT;
> +	si.si_addr_lsb = compound_order(compound_head(page)) + PAGE_SHIFT;
>  
>  	if ((flags & MF_ACTION_REQUIRED) && t == current) {
>  		si.si_code = BUS_MCEERR_AR;
> @@ -983,7 +983,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
>  static void set_page_hwpoison_huge_page(struct page *hpage)
>  {
>  	int i;
> -	int nr_pages = 1 << compound_trans_order(hpage);
> +	int nr_pages = 1 << compound_order(hpage);
>  	for (i = 0; i < nr_pages; i++)
>  		SetPageHWPoison(hpage + i);
>  }
> @@ -991,7 +991,7 @@ static void set_page_hwpoison_huge_page(struct page *hpage)
>  static void clear_page_hwpoison_huge_page(struct page *hpage)
>  {
>  	int i;
> -	int nr_pages = 1 << compound_trans_order(hpage);
> +	int nr_pages = 1 << compound_order(hpage);
>  	for (i = 0; i < nr_pages; i++)
>  		ClearPageHWPoison(hpage + i);
>  }
> @@ -1491,7 +1491,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
>  	} else {
>  		set_page_hwpoison_huge_page(hpage);
>  		dequeue_hwpoisoned_huge_page(hpage);
> -		atomic_long_add(1 << compound_trans_order(hpage),
> +		atomic_long_add(1 << compound_order(hpage),
>  				&num_poisoned_pages);
>  	}
>  	return ret;
> @@ -1551,7 +1551,7 @@ int soft_offline_page(struct page *page, int flags)
>  		if (PageHuge(page)) {
>  			set_page_hwpoison_huge_page(hpage);
>  			dequeue_hwpoisoned_huge_page(hpage);
> -			atomic_long_add(1 << compound_trans_order(hpage),
> +			atomic_long_add(1 << compound_order(hpage),
>  					&num_poisoned_pages);
>  		} else {
>  			SetPageHWPoison(page);

We have one more compound_trans_order() in unpoison_memory(), so could you
replace that too?

With that change ...
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
