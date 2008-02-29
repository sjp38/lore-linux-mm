Date: Fri, 29 Feb 2008 11:29:18 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 01/21] move isolate_lru_page() to vmscan.c
In-Reply-To: <20080228192928.004828816@redhat.com>
References: <20080228192908.126720629@redhat.com> <20080228192928.004828816@redhat.com>
Message-Id: <20080229112120.66E1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi Rik

> @@ -870,14 +840,17 @@ static int do_move_pages(struct mm_struc
>  				!migrate_all)
>  			goto put_and_set;
>  
> -		err = isolate_lru_page(page, &pagelist);
> +		err = isolate_lru_page(page);
> +		if (err) {
>  put_and_set:
> -		/*
> -		 * Either remove the duplicate refcount from
> -		 * isolate_lru_page() or drop the page ref if it was
> -		 * not isolated.
> -		 */
> -		put_page(page);
> +			/*
> +			 * Either remove the duplicate refcount from
> +			 * isolate_lru_page() or drop the page ref if it was
> +			 * not isolated.
> +			 */
> +			put_page(page);
> +		} else
> +			list_add_tail(&page->lru, &pagelist);

We think this portion change to following code.

---------------------------------------------
	err = isolate_lru_page(page);
	if (!err)
		list_add_tail(&page->lru, &pagelist);
put_and_set:
	put_page(page);	/* drop follow_page() reference */
---------------------------------------------

because nobody hope change page_count.


original do_move_pages: 
		follow_page:      page_count +1
		isolate_lru_page: page_count +1
		put_page:         page_count -1
                ----------------------------------
                total                        +1
this patch:
		follow_page:      page_count +1
		isolate_lru_page: page_count +1
                ----------------------------------
                total                        +2


- kosaki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
