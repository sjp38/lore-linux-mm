Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id D6B056B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 22:00:15 -0400 (EDT)
Date: Wed, 17 Oct 2012 10:00:12 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] Change the check for PageReadahead into an else-if
Message-ID: <20121017020012.GA13769@localhost>
References: <08589dd39c78346ec2ed2fedfd6e3121ca38acda.1350413420.git.rprabhu@wnohang.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <08589dd39c78346ec2ed2fedfd6e3121ca38acda.1350413420.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: raghu.prabhu13@gmail.com
Cc: zheng.yan@oracle.com, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, Raghavendra D Prabhu <rprabhu@wnohang.net>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Oct 17, 2012 at 12:28:05AM +0530, raghu.prabhu13@gmail.com wrote:
> From: Raghavendra D Prabhu <rprabhu@wnohang.net>
> 
> >From 51daa88ebd8e0d437289f589af29d4b39379ea76, page_sync_readahead coalesces
> async readahead into its readahead window, so another checking for that again is
> not required.
>
> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
> ---
>  fs/btrfs/relocation.c | 10 ++++------
>  mm/filemap.c          |  3 +--
>  2 files changed, 5 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/btrfs/relocation.c b/fs/btrfs/relocation.c
> index 4da0865..6362003 100644

> --- a/fs/btrfs/relocation.c
> +++ b/fs/btrfs/relocation.c
> @@ -2996,12 +2996,10 @@ static int relocate_file_extent_cluster(struct inode *inode,
>  				ret = -ENOMEM;
>  				goto out;
>  			}
> -		}
> -
> -		if (PageReadahead(page)) {
> -			page_cache_async_readahead(inode->i_mapping,
> -						   ra, NULL, page, index,
> -						   last_index + 1 - index);
> +		} else if (PageReadahead(page)) {
> +				page_cache_async_readahead(inode->i_mapping,
> +							ra, NULL, page, index,
> +							last_index + 1 - index);

That extra indent is not necessary.

Otherwise looks good to me. Thanks!

Reviewed-by: Fengguang Wu <fengguang.wu@intel.com>

>  		}
>  
>  		if (!PageUptodate(page)) {
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 3843445..d703224 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1113,8 +1113,7 @@ find_page:
>  			page = find_get_page(mapping, index);
>  			if (unlikely(page == NULL))
>  				goto no_cached_page;
> -		}
> -		if (PageReadahead(page)) {
> +		} else if (PageReadahead(page)) {
>  			page_cache_async_readahead(mapping,
>  					ra, filp, page,
>  					index, last_index - index);
> -- 
> 1.7.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
