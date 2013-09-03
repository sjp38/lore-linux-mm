Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id AF5996B0032
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 20:21:08 -0400 (EDT)
Date: Mon, 02 Sep 2013 20:20:52 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1378167652-baz1wfnf-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1378165006-19435-2-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1378165006-19435-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1378165006-19435-2-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/4] mm/hwpoison: fix miss catch transparent huge page
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 03, 2013 at 07:36:44AM +0800, Wanpeng Li wrote:
> Changelog:
>  *v1 -> v2: reverse PageTransHuge(page) && !PageHuge(page) check 
> 
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

Thanks!

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

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
> +	if (!PageHuge(page) && PageTransHuge(page)) {
>  		pr_info("MCE: Memory failure is now running on %#lx\n", pfn);
>  			return 0;
>  	}
> -- 
> 1.8.1.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
