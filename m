Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id D628D6B0038
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 14:34:41 -0400 (EDT)
Date: Mon, 02 Sep 2013 14:34:26 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1378146866-4o68qbq7-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1378125224-12794-3-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1378125224-12794-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1378125224-12794-3-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/4] mm/hwpoison: fix false report 2nd try page recovery
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 02, 2013 at 08:33:43PM +0800, Wanpeng Li wrote:
> If the page is poisoned by software inject w/ MF_COUNT_INCREASED flag, there
> is a false report 2nd try page recovery which is not truth, this patch fix it
> by report first try free buddy page recovery if MF_COUNT_INCREASED is set.
> 
> Before patch:
> 
> [  346.332041] Injecting memory failure at pfn 200010
> [  346.332189] MCE 0x200010: free buddy, 2nd try page recovery: Delayed
> 
> After patch:
> 
> [  297.742600] Injecting memory failure at pfn 200010
> [  297.742941] MCE 0x200010: free buddy page recovery: Delayed
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/memory-failure.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index b114570..6293164 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1114,8 +1114,10 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  			 * shake_page could have turned it free.
>  			 */
>  			if (is_free_buddy_page(p)) {
> -				action_result(pfn, "free buddy, 2nd try",
> -						DELAYED);
> +				if (flags & MF_COUNT_INCREASED)
> +					action_result(pfn, "free buddy", DELAYED);
> +				else
> +					action_result(pfn, "free buddy, 2nd try", DELAYED);
>  				return 0;
>  			}
>  			action_result(pfn, "non LRU", IGNORED);
> -- 
> 1.7.5.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
