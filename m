Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id D93696B0062
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 05:26:34 -0400 (EDT)
Date: Mon, 16 Jul 2012 11:26:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH mmotm] memcg: further prevent OOM with too many dirty
 pages
Message-ID: <20120716092631.GC14664@tiehlicka.suse.cz>
References: <1340117404-30348-1-git-send-email-mhocko@suse.cz>
 <20120619150014.1ebc108c.akpm@linux-foundation.org>
 <20120620101119.GC5541@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1207111818380.1299@eggly.anvils>
 <20120712070501.GB21013@tiehlicka.suse.cz>
 <20120712141343.e1cb7776.akpm@linux-foundation.org>
 <alpine.LSU.2.00.1207121539150.27721@eggly.anvils>
 <20120713082150.GA1448@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1207160111280.3936@eggly.anvils>
 <alpine.LSU.2.00.1207160131120.3936@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207160131120.3936@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Fengguang Wu <fengguang.wu@intel.com>

On Mon 16-07-12 01:35:34, Hugh Dickins wrote:
> The may_enter_fs test turns out to be too restrictive: though I saw
> no problem with it when testing on 3.5-rc6, it very soon OOMed when
> I tested on 3.5-rc6-mm1.  I don't know what the difference there is,
> perhaps I just slightly changed the way I started off the testing:
> dd if=/dev/zero of=/mnt/temp bs=1M count=1024; rm -f /mnt/temp; sync
> repeatedly, in 20M memory.limit_in_bytes cgroup to ext4 on USB stick.
> 
> ext4 (and gfs2 and xfs) turn out to allocate new pages for writing
> with AOP_FLAG_NOFS: that seems a little worrying, and it's unclear
> to me why the transaction needs to be started even before allocating
> pagecache memory.  But it may not be worth worrying about these days:
> if direct reclaim avoids FS writeback, does __GFP_FS now mean anything?
> 
> Anyway, we insisted on the may_enter_fs test to avoid hangs with the
> loop device; but since that also masks off __GFP_IO, we can test for
> __GFP_IO directly, ignoring may_enter_fs and __GFP_FS.
> 
> But even so, the test still OOMs sometimes: when originally testing
> on 3.5-rc6, it OOMed about one time in five or ten; when testing
> just now on 3.5-rc6-mm1, it OOMed on the first iteration.
> 
> This residual problem comes from an accumulation of pages under
> ordinary writeback, not marked PageReclaim, so rightly not causing
> the memcg check to wait on their writeback: these too can prevent
> shrink_page_list() from freeing any pages, so many times that memcg
> reclaim fails and OOMs.

I guess you managed to trigger this with 20M limit, right? I have tested
with different group sizes but the writeback didn't trigger for most of
them and all the dirty data were flushed from the reclaim. Have you used
any special setting the dirty ratio? Or was it with xfs (IIUC that one
does ignore writeback from the direct reclaim completely).

> Deal with these in the same way as direct reclaim now deals with
> dirty FS pages: mark them PageReclaim.  It is appropriate to rotate
> these to tail of list when writepage completes, but more importantly,
> the PageReclaim flag makes memcg reclaim wait on them if encountered
> again.  Increment NR_VMSCAN_IMMEDIATE?  That's arguable: I chose not.
> 
> Setting PageReclaim here may occasionally race with end_page_writeback()
> clearing it: lru_deactivate_fn() already faced the same race, and
> correctly concluded that the window is small and the issue non-critical.
> 
> With these changes, the test runs indefinitely without OOMing on ext4,
> ext3 and ext2: I'll move on to test with other filesystems later.
> 
> Trivia: invert conditions for a clearer block without an else,
> and goto keep_locked to do the unlock_page.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: stable@vger.kernel.org (along with the patch it fixes)

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks Hugh

> ---
> Incremental on top of what I believe you presently have in mmotm:
> better folded in on top of Michal's original and the may_enter_fs "fix".
> 
>  mm/vmscan.c |   33 ++++++++++++++++++++++++---------
>  1 file changed, 24 insertions(+), 9 deletions(-)
> 
> --- mmotm/mm/vmscan.c	2012-07-14 18:43:46.618738947 -0700
> +++ linux/mm/vmscan.c	2012-07-15 19:28:50.038830668 -0700
> @@ -723,23 +723,38 @@ static unsigned long shrink_page_list(st
>  			/*
>  			 * memcg doesn't have any dirty pages throttling so we
>  			 * could easily OOM just because too many pages are in
> -			 * writeback from reclaim and there is nothing else to
> -			 * reclaim.
> +			 * writeback and there is nothing else to reclaim.
>  			 *
> -			 * Check may_enter_fs, certainly because a loop driver
> +			 * Check __GFP_IO, certainly because a loop driver
>  			 * thread might enter reclaim, and deadlock if it waits
>  			 * on a page for which it is needed to do the write
>  			 * (loop masks off __GFP_IO|__GFP_FS for this reason);
>  			 * but more thought would probably show more reasons.
> +			 *
> +			 * Don't require __GFP_FS, since we're not going into
> +			 * the FS, just waiting on its writeback completion.
> +			 * Worryingly, ext4 gfs2 and xfs allocate pages with
> +			 * grab_cache_page_write_begin(,,AOP_FLAG_NOFS), so
> +			 * testing may_enter_fs here is liable to OOM on them.
>  			 */
> -			if (!global_reclaim(sc) && PageReclaim(page) &&
> -					may_enter_fs)
> -				wait_on_page_writeback(page);
> -			else {
> +			if (global_reclaim(sc) ||
> +			    !PageReclaim(page) || !(sc->gfp_mask & __GFP_IO)) {
> +				/*
> +				 * This is slightly racy - end_page_writeback()
> +				 * might have just cleared PageReclaim, then
> +				 * setting PageReclaim here end up interpreted
> +				 * as PageReadahead - but that does not matter
> +				 * enough to care.  What we do want is for this
> +				 * page to have PageReclaim set next time memcg
> +				 * reclaim reaches the tests above, so it will
> +				 * then wait_on_page_writeback() to avoid OOM;
> +				 * and it's also appropriate in global reclaim.
> +				 */
> +				SetPageReclaim(page);
>  				nr_writeback++;
> -				unlock_page(page);
> -				goto keep;
> +				goto keep_locked;
>  			}
> +			wait_on_page_writeback(page);
>  		}
>  
>  		references = page_check_references(page, sc);

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
