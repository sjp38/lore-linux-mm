Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B478B6B006E
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 07:36:30 -0500 (EST)
Date: Mon, 21 Nov 2011 12:36:24 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/8] mm: compaction: defer compaction only with
 sync_migration
Message-ID: <20111121123624.GD19415@suse.de>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
 <1321732460-14155-5-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1321732460-14155-5-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org

On Sat, Nov 19, 2011 at 08:54:16PM +0100, Andrea Arcangeli wrote:
> Let only sync migration drive the
> compaction_deferred()/defer_compaction() logic. So sync migration
> isn't prevented to run if async migration fails. Without sync
> migration pages requiring migrate.c:writeout() or a ->migratepage
> operation (that isn't migrate_page) can't me migrated, and that has
> the effect of polluting the movable pageblock with pages that won't be
> migrated by async migration, so it's fundamental to guarantee sync
> compaction will be run too before failing.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/page_alloc.c |   50 ++++++++++++++++++++++++++++++--------------------
>  1 files changed, 30 insertions(+), 20 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9dd443d..2229f7d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1891,7 +1891,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  {
>  	struct page *page;
>  
> -	if (!order || compaction_deferred(preferred_zone))
> +	if (!order)
>  		return NULL;
>  

What is the motivation for moving the compation_deferred()
check to __alloc_pages_slowpath()? If compaction was deferred
for async compaction, we try direct reclaim as the linear isolation
might succeed where compaction failed and compaction will likely be
skipped again the second time around.

If anything, entering direct reclaim for THP when compaction is deferred
is wrong as it also potentially stalls for a long period of time
in reclaim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
