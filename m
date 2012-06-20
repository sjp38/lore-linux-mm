Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id BBC0C6B006C
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 02:31:33 -0400 (EDT)
Message-ID: <4FE16E50.9030304@cn.fujitsu.com>
Date: Wed, 20 Jun 2012 14:31:44 +0800
From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Reply-To: gaowanlong@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH] mm, fadvise: don't return -EINVAL when filesystem has
 no optimization way
References: <1339792575-17637-1-git-send-email-kosaki.motohiro@gmail.com>
In-Reply-To: <1339792575-17637-1-git-send-email-kosaki.motohiro@gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, Eric Wong <normalperson@yhbt.net>

On 06/16/2012 04:36 AM, kosaki.motohiro@gmail.com wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Eric Wong reported his test suite was fail when /tmp is tmpfs.
> 
> https://lkml.org/lkml/2012/2/24/479
> 
> Current,input check of POSIX_FADV_WILLNEED has two problems.
> 
> 1) require a_ops->readpage.
>    But in fact, force_page_cache_readahead() only require
>    a target filesystem has either ->readpage or ->readpages.
> 2) return -EINVAL when filesystem don't have ->readpage.
>    But, posix says, it should be retrieved a hint. Thus fadvise()
>    should return 0 if filesystem has no optimization way.
>    Especially, userland application don't know a filesystem type
>    of TMPDIR directory as Eric pointed out. Then, userland can't
>    avoid this error. We shouldn't encourage to ignore syscall
>    return value.
> 
> Thus, this patch change a return value to 0 when filesytem don't
> support readahead.
> 
> Cc: linux-mm@kvack.org
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Hillf Danton <dhillf@gmail.com>
> Signed-off-by: Eric Wong <normalperson@yhbt.net>
> Tested-by: Eric Wong <normalperson@yhbt.net>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/fadvise.c |   18 +++++++-----------
>  1 files changed, 7 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/fadvise.c b/mm/fadvise.c
> index 469491e..33e6baf 100644
> --- a/mm/fadvise.c
> +++ b/mm/fadvise.c
> @@ -93,11 +93,6 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
>  		spin_unlock(&file->f_lock);
>  		break;
>  	case POSIX_FADV_WILLNEED:
> -		if (!mapping->a_ops->readpage) {
> -			ret = -EINVAL;
> -			break;
> -		}

Why not check both readpage and readpages, if they are not here,
just beak and no following force_page_cache_readahead ?

Thanks,
Wanlong Gao

> -
>  		/* First and last PARTIAL page! */
>  		start_index = offset >> PAGE_CACHE_SHIFT;
>  		end_index = endbyte >> PAGE_CACHE_SHIFT;
> @@ -106,12 +101,13 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
>  		nrpages = end_index - start_index + 1;
>  		if (!nrpages)
>  			nrpages = ~0UL;
> -		
> -		ret = force_page_cache_readahead(mapping, file,
> -				start_index,
> -				nrpages);
> -		if (ret > 0)
> -			ret = 0;
> +
> +		/*
> +		 * Ignore return value because fadvise() shall return 
> +		 * success even if filesystem can't retrieve a hint,
> +		 */		
> +		force_page_cache_readahead(mapping, file, start_index,
> +					   nrpages);
>  		break;
>  	case POSIX_FADV_NOREUSE:
>  		break;
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
