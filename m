Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 5AB916B00A8
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 01:43:10 -0400 (EDT)
Message-ID: <4FD5856C.5060708@kernel.org>
Date: Mon, 11 Jun 2012 14:43:08 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3 04/10] mm: frontswap: split out __frontswap_unuse_pages
References: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com> <1339325468-30614-5-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1339325468-30614-5-git-send-email-levinsasha928@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/10/2012 07:51 PM, Sasha Levin wrote:

> An attempt at making frontswap_shrink shorter and more readable. This patch
> splits out walking through the swap list to find an entry with enough
> pages to unuse.
> 
> Also, assert that the internal __frontswap_unuse_pages is called under swap
> lock, since that part of code was previously directly happen inside the lock.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  mm/frontswap.c |   59 +++++++++++++++++++++++++++++++++++++-------------------
>  1 files changed, 39 insertions(+), 20 deletions(-)
> 
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index 5faf840..faa43b7 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -230,6 +230,41 @@ static unsigned long __frontswap_curr_pages(void)
>  	return totalpages;
>  }
>  
> +static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
> +					int *swapid)


Normally, we use "unsigned int type" instead of swapid.
I admit the naming is rather awkward but that should be another patch.
So let's keep consistency with swap subsystem.

> +{
> +	int ret = -EINVAL;
> +	struct swap_info_struct *si = NULL;
> +	int si_frontswap_pages;
> +	unsigned long total_pages_to_unuse = total;
> +	unsigned long pages = 0, pages_to_unuse = 0;
> +	int type;
> +
> +	assert_spin_locked(&swap_lock);


Normally, we should use this assertion when we can't find swap_lock is hold or not easily
by complicated call depth or unexpected use-case like general function.
But I expect this function's caller is very limited, not complicated.
Just comment write down isn't enough?


> +	for (type = swap_list.head; type >= 0; type = si->next) {
> +		si = swap_info[type];
> +		si_frontswap_pages = atomic_read(&si->frontswap_pages);
> +		if (total_pages_to_unuse < si_frontswap_pages) {
> +			pages = pages_to_unuse = total_pages_to_unuse;
> +		} else {
> +			pages = si_frontswap_pages;
> +			pages_to_unuse = 0; /* unuse all */
> +		}
> +		/* ensure there is enough RAM to fetch pages from frontswap */
> +		if (security_vm_enough_memory_mm(current->mm, pages)) {
> +			ret = -ENOMEM;


Nipick:
I am not sure detailed error returning would be good.
Caller doesn't matter it now but it can consider it in future.
Hmm, 

> +			continue;
> +		}
> +		vm_unacct_memory(pages);
> +		*unused = pages_to_unuse;
> +		*swapid = type;
> +		ret = 0;
> +		break;
> +	}
> +
> +	return ret;
> +}
> +
>  /*
>   * Frontswap, like a true swap device, may unnecessarily retain pages
>   * under certain circumstances; "shrink" frontswap is essentially a
> @@ -240,11 +275,9 @@ static unsigned long __frontswap_curr_pages(void)
>   */
>  void frontswap_shrink(unsigned long target_pages)
>  {
> -	struct swap_info_struct *si = NULL;
> -	int si_frontswap_pages;
>  	unsigned long total_pages = 0, total_pages_to_unuse;
> -	unsigned long pages = 0, pages_to_unuse = 0;
> -	int type;
> +	unsigned long pages_to_unuse = 0;
> +	int type, ret;
>  	bool locked = false;
>  
>  	/*
> @@ -258,22 +291,8 @@ void frontswap_shrink(unsigned long target_pages)
>  	if (total_pages <= target_pages)
>  		goto out;
>  	total_pages_to_unuse = total_pages - target_pages;
> -	for (type = swap_list.head; type >= 0; type = si->next) {
> -		si = swap_info[type];
> -		si_frontswap_pages = atomic_read(&si->frontswap_pages);
> -		if (total_pages_to_unuse < si_frontswap_pages) {
> -			pages = pages_to_unuse = total_pages_to_unuse;
> -		} else {
> -			pages = si_frontswap_pages;
> -			pages_to_unuse = 0; /* unuse all */
> -		}
> -		/* ensure there is enough RAM to fetch pages from frontswap */
> -		if (security_vm_enough_memory_mm(current->mm, pages))
> -			continue;
> -		vm_unacct_memory(pages);
> -		break;
> -	}
> -	if (type < 0)
> +	ret = __frontswap_unuse_pages(total_pages_to_unuse, &pages_to_unuse, &type);
> +	if (ret < 0)
>  		goto out;
>  	locked = false;
>  	spin_unlock(&swap_lock);



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
