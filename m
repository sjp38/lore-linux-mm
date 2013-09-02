Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 76DBA6B0034
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 14:34:36 -0400 (EDT)
Date: Mon, 02 Sep 2013 14:34:20 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1378146860-wzqztoop-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1378125224-12794-2-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1378125224-12794-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1378125224-12794-2-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] mm/hwpoison: fix miss catch transparent huge page
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 02, 2013 at 08:33:42PM +0800, Wanpeng Li wrote:
> PageTransHuge() can't guarantee the page is transparent huge page since it 
> return true for both transparent huge and hugetlbfs pages. This patch fix 
> it by check the page is also !hugetlbfs page.
> 
> Before patch:
> 
> [  121.571128] Injecting memory failure at pfn 23a200
> [  121.571141] MCE 0x23a200: huge page recovery: Delayed
> [  140.355100] MCE: Memory failure is now running on 0x23a200
> 
> After patch:
> 
> [   94.290793] Injecting memory failure at pfn 23a000
> [   94.290800] MCE 0x23a000: huge page recovery: Delayed
> [  105.722303] MCE: Software-unpoisoned page 0x23a000
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

PageTransHuge doesn't care about hugetlbfs at all, assuming that it
shouldn't be called hugetlbfs context as commented.

  /*                                                                    
   * PageHuge() only returns true for hugetlbfs pages, but not for      
   * normal or transparent huge pages.                                  
   *                                                                    
   * PageTransHuge() returns true for both transparent huge and         
   * hugetlbfs pages, but not normal pages. PageTransHuge() can only be 
   * called only in the core VM paths where hugetlbfs pages can't exist.
   */
  static inline int PageTransHuge(struct page *page)

I think it's for the ultra optimization of thp, so we can't change that.
So we need to follow the pattern whenever possible.

  if (PageHuge) {
    hugetlb specific code
  } else if (PageTransHuge) {
    thp specific code
  }
  normal page code / common code

> ---
>  mm/memory-failure.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index e28ee77..b114570 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1349,7 +1349,7 @@ int unpoison_memory(unsigned long pfn)
>  	 * worked by memory_failure() and the page lock is not held yet.
>  	 * In such case, we yield to memory_failure() and make unpoison fail.
>  	 */
> -	if (PageTransHuge(page)) {
> +	if (PageTransHuge(page) && !PageHuge(page)) {
>  		pr_info("MCE: Memory failure is now running on %#lx\n", pfn);
>  			return 0;
>  	}

I think that we can effectively follow the above pattern by reversing
these two checks.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
