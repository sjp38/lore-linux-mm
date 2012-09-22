Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 0E1EE6B0044
	for <linux-mm@kvack.org>; Sat, 22 Sep 2012 08:49:28 -0400 (EDT)
Date: Sat, 22 Sep 2012 20:49:20 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] mm/readahead: Change the condition for
 SetPageReadahead
Message-ID: <20120922124920.GB17562@localhost>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <82b88a97e1b86b718fe8e4616820d224f6abbc52.1348309711.git.rprabhu@wnohang.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <82b88a97e1b86b718fe8e4616820d224f6abbc52.1348309711.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: raghu.prabhu13@gmail.com
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

On Sat, Sep 22, 2012 at 04:03:11PM +0530, raghu.prabhu13@gmail.com wrote:
> From: Raghavendra D Prabhu <rprabhu@wnohang.net>
> 
> If page lookup from radix_tree_lookup is successful and its index page_idx ==
> nr_to_read - lookahead_size, then SetPageReadahead never gets called, so this
> fixes that.

NAK. Sorry. It's actually an intentional behavior, so that for the
common cases of many cached files that are accessed frequently, no
PG_readahead will be set at all to pointlessly trap into the readahead
routines once and again.

Perhaps we need a patch for commenting that case. :)

Thanks,
Fengguang

> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
> ---
>  mm/readahead.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/readahead.c b/mm/readahead.c
> index 461fcc0..fec726c 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -189,8 +189,10 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  			break;
>  		page->index = page_offset;
>  		list_add(&page->lru, &page_pool);
> -		if (page_idx == nr_to_read - lookahead_size)
> +		if (page_idx >= nr_to_read - lookahead_size) {
>  			SetPageReadahead(page);
> +			lookahead_size = 0;
> +		}
>  		ret++;
>  	}
>  
> -- 
> 1.7.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
