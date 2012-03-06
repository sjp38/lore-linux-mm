Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 011D66B007E
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 18:29:19 -0500 (EST)
Received: by iajr24 with SMTP id r24so10073513iaj.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 15:29:19 -0800 (PST)
Date: Tue, 6 Mar 2012 15:28:43 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] ksm: clean up page_trans_compound_anon_split
In-Reply-To: <1330594374-13497-1-git-send-email-lliubbo@gmail.com>
Message-ID: <alpine.LSU.2.00.1203061515470.1292@eggly.anvils>
References: <1330594374-13497-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, akpm@linux-foundation.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, linux-mm@kvack.org

On Thu, 1 Mar 2012, Bob Liu wrote:

> Signed-off-by: Bob Liu <lliubbo@gmail.com>

I agree it looks very much nicer: a patch on these lines would be good.

But you've lost the comment about a return of 1 meaning "Retry later if
split_huge_page run from under us", which I think was a helpful comment.

And you've not commented on the functional change which you made:
if page_trans_compound_anon() returns NULL, then _split() now returns
1 where before it returned 0.  I suspect that's a reasonable change
in a rare case, and better left simple as you have it, than slavishly
reproduce the earlier behaviour; but I'd like to have an Ack from the
author before we commit your modification.

But you didn't Cc Andrea whose code this is, and who understands THP
and its races better than anybody: now Cc'ed.

Hugh

> ---
>  mm/ksm.c |   12 ++----------
>  1 files changed, 2 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 1925ffb..8e10786 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -817,7 +817,7 @@ out:
>  
>  static int page_trans_compound_anon_split(struct page *page)
>  {
> -	int ret = 0;
> +	int ret = 1;
>  	struct page *transhuge_head = page_trans_compound_anon(page);
>  	if (transhuge_head) {
>  		/* Get the reference on the head to split it. */
> @@ -828,16 +828,8 @@ static int page_trans_compound_anon_split(struct page *page)
>  			 */
>  			if (PageAnon(transhuge_head))
>  				ret = split_huge_page(transhuge_head);
> -			else
> -				/*
> -				 * Retry later if split_huge_page run
> -				 * from under us.
> -				 */
> -				ret = 1;
>  			put_page(transhuge_head);
> -		} else
> -			/* Retry later if split_huge_page run from under us. */
> -			ret = 1;
> +		}
>  	}
>  	return ret;
>  }
> -- 
> 1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
