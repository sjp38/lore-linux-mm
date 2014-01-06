Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id A479B6B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 05:56:24 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so7696329eaj.21
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 02:56:23 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i1si83312567eev.5.2014.01.06.02.56.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 02:56:22 -0800 (PST)
Date: Mon, 6 Jan 2014 11:56:20 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH V3] mm readahead: Fix the readahead fail in case of
 empty numa node
Message-ID: <20140106105620.GC3312@quack.suse.cz>
References: <1389003715-29733-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389003715-29733-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, jack@suse.cz, Linus <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 06-01-14 15:51:55, Raghavendra K T wrote:
> Currently, max_sane_readahead returns zero on the cpu with empty numa node,
> fix this by checking for potential empty numa node case during calculation.
> We also limit the number of readahead pages to 4k.
> 
> Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> ---
> The current patch limits the readahead into 4k pages (16MB was suggested
> by Linus).  and also handles the case of memoryless cpu issuing readahead
> failures.  We still do not consider [fm]advise() specific calculations
> here.  I have dropped the iterating over numa node to calculate free page
> idea.  I do not have much idea whether there is any impact on big
> streaming apps..  Comments/suggestions ?
  As you say I would be also interested what impact this has on a streaming
application. It should be rather easy to check - create 1 GB file, drop
caches. Then measure how long does it take to open the file, call fadvise
FADV_WILLNEED, read the whole file (for a kernel with and without your
patch). Do several measurements so that we get some meaningful statistics.
Resulting numbers can then be part of the changelog. Thanks!

								Honza

>  mm/readahead.c | 15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/readahead.c b/mm/readahead.c
> index 7cdbb44..be4d205 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -237,14 +237,25 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  	return ret;
>  }
>  
> +#define MAX_REMOTE_READAHEAD   4096UL
>  /*
>   * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
>   * sensible upper limit.
>   */
>  unsigned long max_sane_readahead(unsigned long nr)
>  {
> -	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE_FILE)
> -		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
> +	unsigned long local_free_page;
> +	unsigned long sane_nr = min(nr, MAX_REMOTE_READAHEAD);
> +
> +	local_free_page = node_page_state(numa_node_id(), NR_INACTIVE_FILE)
> +			  + node_page_state(numa_node_id(), NR_FREE_PAGES);
> +
> +	/*
> +	 * Readahead onto remote memory is better than no readahead when local
> +	 * numa node does not have memory. We sanitize readahead size depending
> +	 * on free memory in the local node but limiting to 4k pages.
> +	 */
> +	return local_free_page ? min(sane_nr, local_free_page / 2) : sane_nr;
>  }
>  
>  /*
> -- 
> 1.7.11.7
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
