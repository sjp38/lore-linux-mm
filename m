Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E26EC6B01EE
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 18:05:54 -0400 (EDT)
Date: Fri, 2 Apr 2010 15:05:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND][PATCH] __isolate_lru_page:skip unneeded "not"
Message-Id: <20100402150511.6f71fbfd.akpm@linux-foundation.org>
In-Reply-To: <1270129055-3656-1-git-send-email-lliubbo@gmail.com>
References: <1270129055-3656-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu,  1 Apr 2010 21:37:35 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> PageActive(page) will return int 0 or 1, mode is also int 0 or 1,
> they are comparible so "not" is unneeded to be sure to boolean
> values.
> I also collected the ISOLATE_BOTH check together.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/vmscan.c |   15 +++++----------
>  1 files changed, 5 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e0e5f15..ce9ee85 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -862,16 +862,11 @@ int __isolate_lru_page(struct page *page, int mode, int file)
>  	if (!PageLRU(page))
>  		return ret;
>  
> -	/*
> -	 * When checking the active state, we need to be sure we are
> -	 * dealing with comparible boolean values.  Take the logical not
> -	 * of each.
> -	 */

You deleted a spelling mistake too!

> -	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
> -		return ret;
> -
> -	if (mode != ISOLATE_BOTH && page_is_file_cache(page) != file)
> -		return ret;
> +	if (mode != ISOLATE_BOTH) {
> +		if ((PageActive(page) != mode) ||
> +			(page_is_file_cache(page) != file))
> +				return ret;
> +	}

The compiler should be able to avoid testing for ISOLATE_BOTH twice,
and I think the previous code layout was superior:

	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
		return ret;

	if (mode != ISOLATE_BOTH && page_is_file_cache(page) != file)
		return ret;

Because it gives us nice places to put a comment explaining what the
code is doing, whereas making it a more complex single expression:

	if (mode != ISOLATE_BOTH) {
		if ((PageActive(page) != mode) ||
			(page_is_file_cache(page) != file))
				return ret;
	}

makes clearly commenting each test more difficult.

Yeah, there's no comment there at present.  But that's because we suck
- I'm sure someone is working on it ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
