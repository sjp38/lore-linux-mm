Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 08BFF6B004D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 01:56:19 -0500 (EST)
Date: Wed, 9 Jan 2013 01:56:12 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] mm: prevent to add a page to swap if may_writepage
 is unset
Message-ID: <20130109065612.GB8550@cmpxchg.org>
References: <1357712474-27595-1-git-send-email-minchan@kernel.org>
 <1357712474-27595-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357712474-27595-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>

On Wed, Jan 09, 2013 at 03:21:13PM +0900, Minchan Kim wrote:
> Recently, Luigi reported there are lots of free swap space when
> OOM happens. It's easily reproduced on zram-over-swap, where
> many instance of memory hogs are running and laptop_mode is enabled.
> 
> Luigi reported there was no problem when he disabled laptop_mode.
> The problem when I investigate problem is following as.
> 
> try_to_free_pages disable may_writepage if laptop_mode is enabled.
> shrink_page_list adds lots of anon pages in swap cache by
> add_to_swap, which makes pages Dirty and rotate them to head of
> inactive LRU without pageout. If it is repeated, inactive anon LRU
> is full of Dirty and SwapCache pages.
> 
> In case of that, isolate_lru_pages fails because it try to isolate
> clean page due to may_writepage == 0.
> 
> The may_writepage could be 1 only if total_scanned is higher than
> writeback_threshold in do_try_to_free_pages but unfortunately,
> VM can't isolate anon pages from inactive anon lru list by
> above reason and we already reclaimed all file-backed pages.
> So it ends up OOM killing.
> 
> This patch prevents to add a page to swap cache unnecessary when
> may_writepage is unset so anoymous lru list isn't full of
> Dirty/Swapcache page. So VM can isolate pages from anon lru list,
> which ends up setting may_writepage to 1 and could swap out
> anon lru pages. When OOM triggers, I confirmed swap space was full.
> 
> Reported-by: Luigi Semenzato <semenzato@google.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

We used to ignore the page's writeback state on isolation in the past,
could you include a reference to since when this problem has been in
the tree?  Also, would it make sense to tag it for one of the stable
trees?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
