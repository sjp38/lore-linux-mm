Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 934996B005D
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 04:22:42 -0400 (EDT)
Date: Mon, 10 Sep 2012 10:22:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: + mm-memblock-reduce-overhead-in-binary-search.patch added to
 -mm tree
Message-ID: <20120910082035.GA13035@dhcp22.suse.cz>
References: <20120907235058.A33F75C0219@hpza9.eem.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120907235058.A33F75C0219@hpza9.eem.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, liwanp@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, shangw@linux.vnet.ibm.com, yinghai@kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

[Sorry for the late reply]

On Fri 07-09-12 16:50:57, Andrew Morton wrote:
> 
> The patch titled
>      Subject: mm/memblock: reduce overhead in binary search
> has been added to the -mm tree.  Its filename is
>      mm-memblock-reduce-overhead-in-binary-search.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> The -mm tree is included into linux-next and is updated
> there every 3-4 working days
> 
> ------------------------------------------------------
> From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Subject: mm/memblock: reduce overhead in binary search
> 
> When checking that the indicated address belongs to the memory region, the
> memory regions are checked one by one through a binary search, which will
> be time consuming.

How many blocks do you have that O(long) is that time consuming?

> If the indicated address isn't in the memory region, then we needn't do
> the time-consuming search.  

How often does this happen?

> Add a check on the indicated address for that purpose.

We have 2 users of this function. One is exynos_sysmmu_enable and the
other pfn_valid for unicore32. The first one doesn't seem to be used
anywhere (as per git grep). The other one could benefit from it but it
would be nice to hear about how much it really helps becuase if the
address is (almost) never outside of start,end DRAM bounds then you just
add a pointless check.
Besides that, if this kind of optimization is really worth, why don't we
do the same thing for memblock_is_reserved and memblock_is_region_memory
as well?

So, while the patch seems correct, I do not see how much it helps while
it definitely adds a code to maintain.

> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Gavin Shan <shangw@linux.vnet.ibm.com>
> Cc: Yinghai Lu <yinghai@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/memblock.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff -puN mm/memblock.c~mm-memblock-reduce-overhead-in-binary-search mm/memblock.c
> --- a/mm/memblock.c~mm-memblock-reduce-overhead-in-binary-search
> +++ a/mm/memblock.c
> @@ -888,6 +888,11 @@ int __init memblock_is_reserved(phys_add
>  
>  int __init_memblock memblock_is_memory(phys_addr_t addr)
>  {
> +
> +	if (unlikely(addr < memblock_start_of_DRAM() ||
> +		addr >= memblock_end_of_DRAM()))
> +		return 0;
> +
>  	return memblock_search(&memblock.memory, addr) != -1;
>  }
>  
> _
> 
> Patches currently in -mm which might be from liwanp@linux.vnet.ibm.com are
> 
> mm-mmu_notifier-init-notifier-if-necessary.patch
> mm-vmscan-fix-error-number-for-failed-kthread.patch
> mm-memblock-reduce-overhead-in-binary-search.patch
> mm-memblock-rename-get_allocated_memblock_reserved_regions_info.patch
> mm-memblock-use-existing-interface-to-set-nid.patch
> mm-memblock-cleanup-early_node_map-related-comments.patch
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
