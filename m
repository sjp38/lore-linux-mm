Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 34DD86B0062
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 07:23:19 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so8422534pbc.14
        for <linux-mm@kvack.org>; Mon, 26 Nov 2012 04:23:18 -0800 (PST)
Message-ID: <50B35F0E.1090905@gmail.com>
Date: Mon, 26 Nov 2012 20:22:38 +0800
From: wujianguo <wujianguo106@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/5] page_alloc: Bootmem limit with movablecore_map
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <1353667445-7593-6-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1353667445-7593-6-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On 2012-11-23 18:44, Tang Chen wrote:
> This patch make sure bootmem will not allocate memory from areas that
> may be ZONE_MOVABLE. The map info is from movablecore_map boot option.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
> Tested-by: Lin Feng <linfeng@cn.fujitsu.com>
> ---
>  include/linux/memblock.h |    1 +
>  mm/memblock.c            |   15 ++++++++++++++-
>  2 files changed, 15 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index d452ee1..6e25597 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -42,6 +42,7 @@ struct memblock {
>  
>  extern struct memblock memblock;
>  extern int memblock_debug;
> +extern struct movablecore_map movablecore_map;
>  
>  #define memblock_dbg(fmt, ...) \
>  	if (memblock_debug) printk(KERN_INFO pr_fmt(fmt), ##__VA_ARGS__)
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 6259055..33b3b4d 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -101,6 +101,7 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
>  {
>  	phys_addr_t this_start, this_end, cand;
>  	u64 i;
> +	int curr = movablecore_map.nr_map - 1;
>  
>  	/* pump up @end */
>  	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
> @@ -114,13 +115,25 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t start,
>  		this_start = clamp(this_start, start, end);
>  		this_end = clamp(this_end, start, end);
>  
> -		if (this_end < size)
> +restart:
> +		if (this_end <= this_start || this_end < size)
>  			continue;
>  
> +		for (; curr >= 0; curr--) {
> +			if (movablecore_map.map[curr].start < this_end)

movablecore_map[curr].start should be movablecore_map[curr].start << PAGE_SHIFT.
May be you can change movablecore_map[].start/end to movablecore_map[].start_pfn/end_pfn
to avoid confusion.

> +				break;
> +		}
> +
>  		cand = round_down(this_end - size, align);
> +		if (curr >= 0 && cand < movablecore_map.map[curr].end) {
> +			this_end = movablecore_map.map[curr].start;

Ditto.

> +			goto restart;
> +		}
> +
>  		if (cand >= this_start)
>  			return cand;
>  	}
> +
>  	return 0;
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
