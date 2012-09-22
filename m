Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id DFD896B0044
	for <linux-mm@kvack.org>; Sat, 22 Sep 2012 08:42:57 -0400 (EDT)
Date: Sat, 22 Sep 2012 20:42:50 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/5] Move the check for ra_pages after
 VM_SequentialReadHint()
Message-ID: <20120922124250.GB15962@localhost>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <b3c8b02fb273826f864f64d4588b36758fde2b5d.1348309711.git.rprabhu@wnohang.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b3c8b02fb273826f864f64d4588b36758fde2b5d.1348309711.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: raghu.prabhu13@gmail.com
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

On Sat, Sep 22, 2012 at 04:03:13PM +0530, raghu.prabhu13@gmail.com wrote:
> From: Raghavendra D Prabhu <rprabhu@wnohang.net>
> 
> page_cache_sync_readahead checks for ra->ra_pages again, so moving the check
> after VM_SequentialReadHint.

Well it depends on what case you are optimizing for. I suspect there
are much more tmpfs users than VM_SequentialReadHint users. So this
change is actually not desirable wrt the more widely used cases.

Thanks,
Fengguang

> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
> ---
>  mm/filemap.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 3843445..606a648 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1523,8 +1523,6 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
>  	/* If we don't want any read-ahead, don't bother */
>  	if (VM_RandomReadHint(vma))
>  		return;
> -	if (!ra->ra_pages)
> -		return;
>  
>  	if (VM_SequentialReadHint(vma)) {
>  		page_cache_sync_readahead(mapping, ra, file, offset,
> @@ -1532,6 +1530,9 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
>  		return;
>  	}
>  
> +	if (!ra->ra_pages)
> +		return;
> +
>  	/* Avoid banging the cache line if not needed */
>  	if (ra->mmap_miss < MMAP_LOTSAMISS * 10)
>  		ra->mmap_miss++;
> -- 
> 1.7.12.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
