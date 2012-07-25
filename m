Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id E59416B004D
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 15:51:52 -0400 (EDT)
Received: by yenr5 with SMTP id r5so1404426yen.14
        for <linux-mm@kvack.org>; Wed, 25 Jul 2012 12:51:52 -0700 (PDT)
Date: Wed, 25 Jul 2012 12:51:47 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 25/34] mm: vmscan: Check if reclaim should really abort
 even if compaction_ready() is true for one zone
Message-ID: <20120725195147.GA5444@kroah.com>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
 <1343050727-3045-26-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1343050727-3045-26-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Stable <stable@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 23, 2012 at 02:38:38PM +0100, Mel Gorman wrote:
> commit 0cee34fd72c582b4f8ad8ce00645b75fb4168199 upstream.
> 
> Stable note: Not tracked on Bugzilla. THP and compaction was found to
> 	aggressively reclaim pages and stall systems under different
> 	situations that was addressed piecemeal over time.
> 
> If compaction can proceed for a given zone, shrink_zones() does not
> reclaim any more pages from it. After commit [e0c2327: vmscan: abort
> reclaim/compaction if compaction can proceed], do_try_to_free_pages()
> tries to finish as soon as possible once one zone can compact.
> 
> This was intended to prevent slabs being shrunk unnecessarily but
> there are side-effects. One is that a small zone that is ready for
> compaction will abort reclaim even if the chances of successfully
> allocating a THP from that zone is small. It also means that reclaim
> can return too early even though sc->nr_to_reclaim pages were not
> reclaimed.
> 
> This partially reverts the commit until it is proven that slabs are
> really being shrunk unnecessarily but preserves the check to return
> 1 to avoid OOM if reclaim was aborted prematurely.
> 
> [aarcange@redhat.com: This patch replaces a revert from Andrea]
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Cc: Dave Jones <davej@redhat.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andy Isaacson <adi@hexapodia.org>
> Cc: Nai Xia <nai.xia@gmail.com>
> Cc: Johannes Weiner <jweiner@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/vmscan.c |   19 +++++++++----------
>  1 file changed, 9 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f109f2d..bc31f32 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2129,7 +2129,8 @@ static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
>   *
>   * This function returns true if a zone is being reclaimed for a costly
>   * allocation and compaction is ready to begin. This indicates to the caller
> - * that it should retry the allocation or fail.
> + * that it should consider retrying the allocation instead of
> + * further reclaim.
>   */
>  static bool shrink_zones(int priority, struct zonelist *zonelist,
>  					struct scan_control *sc)

This hunk didn't apply (the original commit from Linus's tree also
didn't apply due to some context changes in the rest of the patch.)  So
I took the original comment changes from Linus's tree, and the context
changes from this one and applied that.

Franken-patches, the story of my life...

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
