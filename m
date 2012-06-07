Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 9A5CD6B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 14:37:24 -0400 (EDT)
Date: Thu, 7 Jun 2012 14:30:22 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 06/11] mm: frontswap: make all branches of if statement
 in put page consistent
Message-ID: <20120607183022.GA9472@phenom.dumpdata.com>
References: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
 <1338980115-2394-6-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338980115-2394-6-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: dan.magenheimer@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jun 06, 2012 at 12:55:10PM +0200, Sasha Levin wrote:
> Currently it has a complex structure where different things are compared
> at each branch. Simplify that and make both branches look similar.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  mm/frontswap.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index 618ef91..f2f4685 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -119,16 +119,16 @@ int __frontswap_put_page(struct page *page)
>  		frontswap_succ_puts++;
>  		if (!dup)
>  			atomic_inc(&sis->frontswap_pages);
> -	} else if (dup) {
> +	} else {
>  		/*
>  		  failed dup always results in automatic invalidate of
>  		  the (older) page from frontswap
>  		 */
> -		frontswap_clear(sis, offset);
> -		atomic_dec(&sis->frontswap_pages);
> -		frontswap_failed_puts++;

Hmm, you must be using an older branch b/c the frontswap_failed_puts++
doesn't exist anymore. Could you rebase on top of linus/master please.

> -	} else {
>  		frontswap_failed_puts++;
> +		if (dup) {
> +			frontswap_clear(sis, offset);
> +			atomic_dec(&sis->frontswap_pages);
> +		}
>  	}
>  	if (frontswap_writethrough_enabled)
>  		/* report failure so swap also writes to swap device */
> -- 
> 1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
