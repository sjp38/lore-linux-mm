Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id D79046B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 04:09:36 -0400 (EDT)
Received: by wibhh20 with SMTP id hh20so29013275wib.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 01:09:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wb6si7026084wjc.121.2015.08.20.01.09.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Aug 2015 01:09:35 -0700 (PDT)
Date: Thu, 20 Aug 2015 10:09:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, vmscan: unlock page while waiting on writeback
Message-ID: <20150820080929.GE4780@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1508191930390.2073@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1508191930390.2073@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org

On Wed 19-08-15 19:36:31, Hugh Dickins wrote:
> This is merely a politeness: I've not found that shrink_page_list() leads
> to deadlock with the page it holds locked across wait_on_page_writeback();
> but nevertheless, why hold others off by keeping the page locked there?

OK, this makes sense to me. It is safer to wait without page locked.
Maybe some fs will want to lock the page before clearing the page
writeback in the future and we would be broken in a very subtle way.

> And while we're at it: remove the mistaken "not " from the commentary
> on this Case 3 (and a distracting blank line from Case 2, if I may).
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> I remembered this old patch when we were discussing the more important
> ecf5fc6e9654 "mm, vmscan: Do not wait for page writeback for GFP_NOFS
> allocations", and now retested it against mmotm.
> 
>  mm/vmscan.c |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> --- mmotm/mm/vmscan.c	2015-08-17 18:46:26.601521575 -0700
> +++ linux/mm/vmscan.c	2015-08-17 18:53:41.335108240 -0700
> @@ -991,7 +991,7 @@ static unsigned long shrink_page_list(st
>  		 *    __GFP_IO|__GFP_FS for this reason); but more thought
>  		 *    would probably show more reasons.
>  		 *
> -		 * 3) Legacy memcg encounters a page that is not already marked
> +		 * 3) Legacy memcg encounters a page that is already marked
>  		 *    PageReclaim. memcg does not have any dirty pages
>  		 *    throttling so we could easily OOM just because too many
>  		 *    pages are in writeback and there is nothing else to
> @@ -1021,12 +1021,15 @@ static unsigned long shrink_page_list(st
>  				 */
>  				SetPageReclaim(page);
>  				nr_writeback++;
> -
>  				goto keep_locked;
>  
>  			/* Case 3 above */
>  			} else {
> +				unlock_page(page);
>  				wait_on_page_writeback(page);
> +				/* then go back and try same page again */
> +				list_add_tail(&page->lru, page_list);
> +				continue;
>  			}
>  		}
>  

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
