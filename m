Date: Mon, 6 Aug 2007 12:22:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] wait for page writeback when directly reclaiming
 contiguous areas
Message-Id: <20070806122204.924fa0e9.akpm@linux-foundation.org>
In-Reply-To: <7bdbf266c3f68dc57a9cf7469c2652a5@pinky>
References: <exportbomb.1186077923@pinky>
	<7bdbf266c3f68dc57a9cf7469c2652a5@pinky>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 02 Aug 2007 19:18:43 +0100 Andy Whitcroft <apw@shadowen.org> wrote:

> @@ -458,8 +475,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		if (page_mapped(page) || PageSwapCache(page))
>  			sc->nr_scanned++;
>  
> -		if (PageWriteback(page))
> -			goto keep_locked;
> +		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
> +			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
> +
> +		if (PageWriteback(page)) {
> +			if (sync_writeback == PAGEOUT_IO_SYNC && may_enter_fs)
> +				wait_on_page_writeback(page);
> +			else
> +				goto keep_locked;
> +		}

this bit could do with a comment explaining the design decisions, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
