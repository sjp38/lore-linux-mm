Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6ADEA6B023E
	for <linux-mm@kvack.org>; Wed, 19 May 2010 17:52:03 -0400 (EDT)
Date: Wed, 19 May 2010 23:51:45 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] tmpfs: Insert tmpfs cache pages to inactive list at first
Message-ID: <20100519215145.GE2868@cmpxchg.org>
References: <20100519174327.9591.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100519174327.9591.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 19, 2010 at 05:44:49PM +0900, KOSAKI Motohiro wrote:
> Shaohua Li reported parallel file copy on tmpfs can lead to
> OOM killer. This is regression of caused by commit 9ff473b9a7
> (vmscan: evict streaming IO first). Wow, It is 2 years old patch!
> 
> Currently, tmpfs file cache is inserted active list at first. It
> mean the insertion doesn't only increase numbers of pages in anon LRU,
> but also reduce anon scanning ratio. Therefore, vmscan will get totally
> confusion. It scan almost only file LRU even though the system have
> plenty unused tmpfs pages.
> 
> Historically, lru_cache_add_active_anon() was used by two reasons.
> 1) Intend to priotize shmem page rather than regular file cache.
> 2) Intend to avoid reclaim priority inversion of used once pages.
> 
> But we've lost both motivation because (1) Now we have separate
> anon and file LRU list. then, to insert active list doesn't help
> such priotize. (2) In past, one pte access bit will cause page
> activation. then to insert inactive list with pte access bit mean
> higher priority than to insert active list. Its priority inversion
> may lead to uninteded lru chun. but it was already solved by commit
> 645747462 (vmscan: detect mapped file pages used only once).
> (Thanks Hannes, you are great!)
> 
> Thus, now we can use lru_cache_add_anon() instead.
> 
> Reported-by: Shaohua Li <shaohua.li@intel.com>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

> Cc: Rik van Riel <riel@redhat.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/filemap.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index b941996..023ef61 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -452,7 +452,7 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
>  		if (page_is_file_cache(page))
>  			lru_cache_add_file(page);
>  		else
> -			lru_cache_add_active_anon(page);
> +			lru_cache_add_anon(page);

Looks like the active_anon and active_file versions have no users
anymore..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
