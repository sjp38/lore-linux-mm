Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 7FF416B00A9
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 01:49:08 -0400 (EDT)
Message-ID: <4FD586D2.2070803@kernel.org>
Date: Mon, 11 Jun 2012 14:49:06 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3 05/10] mm: frontswap: split frontswap_shrink further
 to simplify locking
References: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com> <1339325468-30614-6-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1339325468-30614-6-git-send-email-levinsasha928@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/10/2012 07:51 PM, Sasha Levin wrote:

> Split frontswap_shrink to simplify the locking in the original code.
> 
> Also, assert that the function that was split still runs under the
> swap spinlock.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  mm/frontswap.c |   36 +++++++++++++++++++++---------------
>  1 files changed, 21 insertions(+), 15 deletions(-)
> 
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index faa43b7..e6353d9 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -265,6 +265,24 @@ static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
>  	return ret;
>  }
>  
> +static int __frontswap_shrink(unsigned long target_pages,
> +				unsigned long *pages_to_unuse,
> +				int *type)


__frontswap_shrink isn't good name.
This function doesn't shrink at all.

How about __frontswap_shrink_pages with description of function?


> +{
> +	unsigned long total_pages = 0, total_pages_to_unuse;
> +
> +	assert_spin_locked(&swap_lock);


About assertion, it's ditto with my previous reply.

> +
> +	total_pages = __frontswap_curr_pages();
> +	if (total_pages <= target_pages) {
> +		/* Nothing to do */
> +		*pages_to_unuse = 0;
> +		return 0;
> +	}
> +	total_pages_to_unuse = total_pages - target_pages;
> +	return __frontswap_unuse_pages(total_pages_to_unuse, pages_to_unuse, type);
> +}
> +
>  /*
>   * Frontswap, like a true swap device, may unnecessarily retain pages
>   * under certain circumstances; "shrink" frontswap is essentially a
> @@ -275,10 +293,8 @@ static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
>   */
>  void frontswap_shrink(unsigned long target_pages)
>  {
> -	unsigned long total_pages = 0, total_pages_to_unuse;
>  	unsigned long pages_to_unuse = 0;
>  	int type, ret;
> -	bool locked = false;
>  
>  	/*
>  	 * we don't want to hold swap_lock while doing a very
> @@ -286,20 +302,10 @@ void frontswap_shrink(unsigned long target_pages)
>  	 * so restart scan from swap_list.head each time
>  	 */
>  	spin_lock(&swap_lock);
> -	locked = true;
> -	total_pages = __frontswap_curr_pages();
> -	if (total_pages <= target_pages)
> -		goto out;
> -	total_pages_to_unuse = total_pages - target_pages;
> -	ret = __frontswap_unuse_pages(total_pages_to_unuse, &pages_to_unuse, &type);
> -	if (ret < 0)
> -		goto out;
> -	locked = false;
> +	ret = __frontswap_shrink(target_pages, &pages_to_unuse, &type);
>  	spin_unlock(&swap_lock);
> -	try_to_unuse(type, true, pages_to_unuse);
> -out:
> -	if (locked)
> -		spin_unlock(&swap_lock);
> +	if (ret == 0 && pages_to_unuse)
> +		try_to_unuse(type, true, pages_to_unuse);
>  	return;
>  }
>  EXPORT_SYMBOL(frontswap_shrink);



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
