Date: Tue, 19 Aug 2008 14:09:07 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] mm: unlockless reclaim
In-Reply-To: <20080818122554.GB9062@wotan.suse.de>
References: <20080818122428.GA9062@wotan.suse.de> <20080818122554.GB9062@wotan.suse.de>
Message-Id: <20080819135424.60DA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> -		unlock_page(page);
> +		/*
> +		 * At this point, we have no other references and there is
> +		 * no way to pick any more up (removed from LRU, removed
> +		 * from pagecache). Can use non-atomic bitops now (and
> +		 * we obviously don't have to worry about waking up a process
> +		 * waiting on the page lock, because there are no references.
> +		 */
> +		__clear_page_locked(page);
>  free_it:
>  		nr_reclaimed++;
>  		if (!pagevec_add(&freed_pvec, page)) {
> 

To insert VM_BUG_ON(page_count(page) != 1) is better?
Otherthing, looks good to me.

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
