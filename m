Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 54F646B0096
	for <linux-mm@kvack.org>; Wed, 22 May 2013 06:49:40 -0400 (EDT)
Date: Wed, 22 May 2013 12:49:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/4] mm/memory-hotplug: fix lowmem count overflow when
 offline pages
Message-ID: <20130522104937.GC19989@dhcp22.suse.cz>
References: <1369214970-1526-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369214970-1526-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 22-05-13 17:29:27, Wanpeng Li wrote:
> Logic memory-remove code fails to correctly account the Total High Memory 
> when a memory block which contains High Memory is offlined as shown in the
> example below. The following patch fixes it.
> 
> cat /proc/meminfo 
> MemTotal:        7079452 kB
> MemFree:         5805976 kB
> Buffers:           94372 kB
> Cached:           872000 kB
> SwapCached:            0 kB
> Active:           626936 kB
> Inactive:         519236 kB
> Active(anon):     180780 kB
> Inactive(anon):   222944 kB
> Active(file):     446156 kB
> Inactive(file):   296292 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> HighTotal:       7294672 kB
> HighFree:        5181024 kB
> LowTotal:       4294752076 kB
> LowFree:          624952 kB

Ok, so the HighTotal is higher than MemTotal but it would have been more
straightforward to show number of HighTotal before hotremove, show how
much memory has been removed and the number after.

It is not clear which stable kernels need this fix as well.

> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Anyway
Reviewed-by: Michal Hocko <mhocko@suse.cz>

with a nit pick bellow

> ---
>  mm/page_alloc.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 98cbdf6..80474b2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6140,6 +6140,10 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>  		list_del(&page->lru);
>  		rmv_page_order(page);
>  		zone->free_area[order].nr_free--;
> +#ifdef CONFIG_HIGHMEM
> +		if (PageHighMem(page))
> +			totalhigh_pages -= 1 << order;
> +#endif

ifdef shouldn't be necessary as PageHighMem should default to false for
!CONFIG_HIGHMEM AFAICS.

>  		for (i = 0; i < (1 << order); i++)
>  			SetPageReserved((page+i));
>  		pfn += (1 << order);
> -- 
> 1.8.1.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
