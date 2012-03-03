Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id A54686B00E8
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 19:23:02 -0500 (EST)
Received: by dadv6 with SMTP id v6so2525062dad.14
        for <linux-mm@kvack.org>; Fri, 02 Mar 2012 16:23:01 -0800 (PST)
Date: Fri, 2 Mar 2012 16:22:25 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/7] mm: rework __isolate_lru_page() file/anon filter
In-Reply-To: <20120229091547.29236.28230.stgit@zurg>
Message-ID: <alpine.LSU.2.00.1203021542560.3578@eggly.anvils>
References: <20120229090748.29236.35489.stgit@zurg> <20120229091547.29236.28230.stgit@zurg>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 29 Feb 2012, Konstantin Khlebnikov wrote:

> This patch adds file/anon filter bits into isolate_mode_t,
> this allows to simplify checks in __isolate_lru_page().
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Almost-Acked-by: Hugh Dickins <hughd@google.com>

with one whitespace nit, and one functional addition requested.

I'm perfectly happy with your :?s myself, but some people do dislike
them.  I'm happy with the switch alternative if it's as efficient:
something that surprised me very much when trying to get convincing
performance numbers for per-memcg per-zone lru_lock at home...

... __isolate_lru_page() featured astonishly high on the perf report
of streaming from files on ext4 on /dev/ram0 to /dev/null, coming
immediately below the obvious zeroing and copying: okay, the zeroing
and copying were around 30% each, and __isolate_lru_page() down around
2% or below, but even so it seemed very odd that it should feature so
high, and any optimizations to it very welcome - unless it was purely
some bogus result.

> ---
>  include/linux/mmzone.h |    4 ++++
>  include/linux/swap.h   |    2 +-
>  mm/compaction.c        |    5 +++--
>  mm/vmscan.c            |   27 +++++++++++++--------------
>  4 files changed, 21 insertions(+), 17 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index eff4918..2fed935 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -193,6 +193,10 @@ struct lruvec {
>  #define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x8)
>  /* Isolate for asynchronous migration */
>  #define ISOLATE_ASYNC_MIGRATE	((__force isolate_mode_t)0x10)
> +/* Isolate swap-backed pages */
> +#define	ISOLATE_ANON		((__force isolate_mode_t)0x20)
> +/* Isolate file-backed pages */
> +#define	ISOLATE_FILE		((__force isolate_mode_t)0x40)

>From the patch you can see that the #defines above yours used a
space where you have used a tab: better to use a space as above.

> @@ -375,7 +376,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  			mode |= ISOLATE_ASYNC_MIGRATE;
>  
>  		/* Try isolate the page */
> -		if (__isolate_lru_page(page, mode, 0) != 0)
> +		if (__isolate_lru_page(page, mode) != 0)
>  			continue;

I thought you were missing something there, but no, that's rather
the case you are simplifying.  However...

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index af6cfe7..1b70338 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1520,6 +1511,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
>  		isolate_mode |= ISOLATE_UNMAPPED;
>  	if (!sc->may_writepage)
>  		isolate_mode |= ISOLATE_CLEAN;
> +	if (file)
> +		isolate_mode |= ISOLATE_FILE;
> +	else
> +		isolate_mode |= ISOLATE_ANON;

Above here, under "if (sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM)",
don't you need

		isolate_mode |= ISOLATE_ACTIVE | ISOLATE_FILE | ISOLATE_ANON;

now to reproduce the same "all_lru_mode" behaviour as before?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
