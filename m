Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6FCDA6B0035
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 17:13:04 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so18787114pbb.8
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 14:13:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id yd9si56156407pab.263.2014.01.06.14.13.02
        for <linux-mm@kvack.org>;
        Mon, 06 Jan 2014 14:13:03 -0800 (PST)
Date: Mon, 6 Jan 2014 14:13:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH V3] mm readahead: Fix the readahead fail in case of
 empty numa node
Message-Id: <20140106141300.4e1c950d45c614d6c29bdd8f@linux-foundation.org>
In-Reply-To: <1389003715-29733-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
References: <1389003715-29733-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, jack@suse.cz, Linus <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon,  6 Jan 2014 15:51:55 +0530 Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com> wrote:

> Currently, max_sane_readahead returns zero on the cpu with empty numa node,
> fix this by checking for potential empty numa node case during calculation.
> We also limit the number of readahead pages to 4k.
> 
> ...
>
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

So if the local node has two free pages, we do just one page of
readahead.

Then the local node has one free page and we do zero pages readahead.

Assuming that bug(!) is fixed, the local node now has zero free pages
and we suddenly resume doing large readahead.

This transition from large readahead to very small readahead then back
to large readahead is illogical, surely?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
