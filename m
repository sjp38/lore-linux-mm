Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 573D86B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 10:01:43 -0500 (EST)
Received: by mail-qc0-f177.google.com with SMTP id u28so8668998qcs.22
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 07:01:42 -0800 (PST)
Date: Fri, 4 Jan 2013 10:01:39 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH] mm: memblock: optimize memblock_find_in_range_node()
 to minimize the search work
Message-ID: <20130104150139.GB15633@mtj.dyndns.org>
References: <1357291493-25773-1-git-send-email-linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357291493-25773-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, mingo@kernel.org, yinghai@kernel.org, liwanp@linux.vnet.ibm.com, benh@kernel.crashing.org, tangchen@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 04, 2013 at 05:24:53PM +0800, Lin Feng wrote:
> The memblock array is in ascending order and we traverse the memblock array in
> reverse order so we can add some simple check to reduce the search work.
> 
> Tejun fix a underflow bug in 5d53cb27d8, but I think we could break there for
> the same reason.
> 
> Cc: Tejun Heo <tj@kernel.org>
> Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
> ---
>  mm/memblock.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 6259055..a710557 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -111,11 +111,18 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
>  	end = max(start, end);
>  
>  	for_each_free_mem_range_reverse(i, nid, &this_start, &this_end, NULL) {
> +		/*
> +		 * exclude the regions out of the candidate range, since it's
> +		 * likely to find a suitable range, we ignore the worst case.
> +		 */
> +		if (this_start >= end)
> +			continue;
> +
>  		this_start = clamp(this_start, start, end);
>  		this_end = clamp(this_end, start, end);
>  
>  		if (this_end < size)
> -			continue;
> +			break;

I don't know.  This only saves looping when memblocks are below the
requested size, right?  I don't think it would matter in any way and
would prefer to keep the logic as simple as possible.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
