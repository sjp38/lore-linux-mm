Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 0DBA86B0032
	for <linux-mm@kvack.org>; Wed, 15 May 2013 18:53:32 -0400 (EDT)
Date: Wed, 15 May 2013 15:53:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/4] mm: pagevec: Defer deciding what LRU to add a page
 to until pagevec drain time
Message-Id: <20130515155330.35036978515a6d8e0fe98feb@linux-foundation.org>
In-Reply-To: <1368440482-27909-3-git-send-email-mgorman@suse.de>
References: <1368440482-27909-1-git-send-email-mgorman@suse.de>
	<1368440482-27909-3-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>, Theodore Tso <tytso@mit.edu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>

On Mon, 13 May 2013 11:21:20 +0100 Mel Gorman <mgorman@suse.de> wrote:

> mark_page_accessed cannot activate an inactive page that is located on
> an inactive LRU pagevec. Hints from filesystems may be ignored as a
> result. In preparation for fixing that problem, this patch removes the
> per-LRU pagevecs and leaves just one pagevec. The final LRU the page is
> added to is deferred until the pagevec is drained.
> 
> This means that fewer pagevecs are available and potentially there is
> greater contention on the LRU lock. However, this only applies in the case
> where there is an almost perfect mix of file, anon, active and inactive
> pages being added to the LRU. In practice I expect that we are adding
> stream of pages of a particular time and that the changes in contention
> will barely be measurable.
> 
> ...
>
> index c612a6a..0911579 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -39,7 +39,7 @@
>  /* How many pages do we try to swap or page in/out together? */
>  int page_cluster;
>  
> -static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
> +static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
>  static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
>  static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
>  
> @@ -460,13 +460,18 @@ EXPORT_SYMBOL(mark_page_accessed);
>   */

The comment preceding __lru_cache_add() needs an update.

>  void __lru_cache_add(struct page *page, enum lru_list lru)
>  {
> -	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs)[lru];
> +	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
> +
> +	if (is_active_lru(lru))
> +		SetPageActive(page);
> +	else
> +		ClearPageActive(page);

The whole use of `enum lru_list' here has always made my cry, but I'll weep
about that in [4/4].

>  	page_cache_get(page);
>  	if (!pagevec_space(pvec))
>  		__pagevec_lru_add(pvec, lru);
>  	pagevec_add(pvec, page);
> -	put_cpu_var(lru_add_pvecs);
> +	put_cpu_var(lru_add_pvec);
>  }
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
