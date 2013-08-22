Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 8FA5A6B0033
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 12:43:31 -0400 (EDT)
Date: Thu, 22 Aug 2013 12:43:08 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1377189788-xv5ewgmb-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1377164907-24801-3-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377164907-24801-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377164907-24801-3-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/6] mm/hwpoison: fix num_poisoned_pages error statistics
 for thp
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 22, 2013 at 05:48:24PM +0800, Wanpeng Li wrote:
> There is a race between hwpoison page and unpoison page, memory_failure 
> set the page hwpoison and increase num_poisoned_pages without hold page 
> lock, and one page count will be accounted against thp for num_poisoned_pages.
> However, unpoison can occur before memory_failure hold page lock and 
> split transparent hugepage, unpoison will decrease num_poisoned_pages 
> by 1 << compound_order since memory_failure has not yet split transparent 
> hugepage with page lock held. That means we account one page for hwpoison
> and 1 << compound_order for unpoison. This patch fix it by decrease one 
> account for num_poisoned_pages against no hugetlbfs pages case.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

I think that a thp never becomes hwpoisoned without splitting, so "trying
to unpoison thp" never happens (I think that this implicit fact should be
commented somewhere or asserted with VM_BUG_ON().)
And nr_pages in unpoison_memory() can be greater than 1 for hugetlbfs page.
So does this patch break counting when unpoisoning free hugetlbfs pages?

Thanks,
Naoya Horiguchi

> ---
>  mm/memory-failure.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 5092e06..6bfd51e 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1350,7 +1350,7 @@ int unpoison_memory(unsigned long pfn)
>  			return 0;
>  		}
>  		if (TestClearPageHWPoison(p))
> -			atomic_long_sub(nr_pages, &num_poisoned_pages);
> +			atomic_long_dec(&num_poisoned_pages);
>  		pr_info("MCE: Software-unpoisoned free page %#lx\n", pfn);
>  		return 0;
>  	}
> -- 
> 1.8.1.2
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
