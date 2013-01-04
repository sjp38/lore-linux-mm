Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 08DA86B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 09:56:39 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id o22so8726508qcr.19
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 06:56:39 -0800 (PST)
Date: Fri, 4 Jan 2013 09:56:35 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH] mm: memblock: fix wrong memmove size in
 memblock_merge_regions()
Message-ID: <20130104145635.GA15633@mtj.dyndns.org>
References: <1357290650-25544-1-git-send-email-linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357290650-25544-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, mingo@kernel.org, yinghai@kernel.org, liwanp@linux.vnet.ibm.com, benh@kernel.crashing.org, tangchen@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 04, 2013 at 05:10:50PM +0800, Lin Feng wrote:
> The memmove span covers from (next+1) to the end of the array, and the index
> of next is (i+1), so the index of (next+1) is (i+2). So the size of remaining
> array elements is (type->cnt - (i + 2)).
> 
> PS. It seems that memblock_merge_regions() could be made some improvement:
> we need't memmove the remaining array elements until we find a none-mergable
> element, but now we memmove everytime we find a neighboring compatible region.
> I'm not sure if the trial is worth though.
> 
> Cc: Tejun Heo <tj@kernel.org>
> Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
> ---
>  mm/memblock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 6259055..85ce056 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -314,7 +314,7 @@ static void __init_memblock memblock_merge_regions(struct memblock_type *type)
>  		}
>  
>  		this->size += next->size;
> -		memmove(next, next + 1, (type->cnt - (i + 1)) * sizeof(*next));
> +		memmove(next, next + 1, (type->cnt - (i + 2)) * sizeof(*next));

Heh, that's confusing.  Nice catch.  Can you please also add a comment
explaning the index so that it's less confusing for the future readers?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
