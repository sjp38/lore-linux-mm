Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 7BF176B00A0
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:49:10 -0400 (EDT)
Message-ID: <5034FEFC.1030901@redhat.com>
Date: Wed, 22 Aug 2012 11:47:08 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC]swap: add a simple random read swapin detection
References: <20120822034044.GB24099@kernel.org>
In-Reply-To: <20120822034044.GB24099@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, fengguang.wu@intel.com

On 08/21/2012 11:40 PM, Shaohua Li wrote:

> +#define SWAPRA_MISS  (100)
>   /**
>    * swapin_readahead - swap in pages in hope we need them soon
>    * @entry: swap entry of this memory
> @@ -379,6 +380,13 @@ struct page *swapin_readahead(swp_entry_
>   	unsigned long mask = (1UL << page_cluster) - 1;
>   	struct blk_plug plug;
>
> +	if (vma) {
> +		if (atomic_read(&vma->swapra_miss) < SWAPRA_MISS * 10)
> +			atomic_inc(&vma->swapra_miss);
> +		if (atomic_read(&vma->swapra_miss) > SWAPRA_MISS)
> +			goto skip;
> +	}

> --- linux.orig/mm/memory.c	2012-08-21 23:01:20.861907922 +0800
> +++ linux/mm/memory.c	2012-08-22 10:39:58.638872631 +0800
> @@ -2953,7 +2953,8 @@ static int do_swap_page(struct mm_struct
>   		ret = VM_FAULT_HWPOISON;
>   		delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
>   		goto out_release;
> -	}
> +	} else if (!(flags & FAULT_FLAG_TRIED))
> +		atomic_dec_if_positive(&vma->swapra_miss);

The approach makes sense when viewed together with
the changelog, but I fear it will be non-obvious
to anyone who just looks at the code later in time.

Please hide these increments and decrements behind
some simple accessor functions, eg:

swap_cache_hit()
swap_cache_miss()
swap_cache_skip_readahead()

These small functions can then be placed together
(maybe in swap.c?) and get a good comment documenting
exactly what they are supposed to do.

As an aside, how well do these patches work?

What kind of performance changes have you seen, both
on SSDs and hard disks?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
