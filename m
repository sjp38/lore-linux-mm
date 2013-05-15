Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 7289C6B0036
	for <linux-mm@kvack.org>; Wed, 15 May 2013 17:39:04 -0400 (EDT)
Date: Wed, 15 May 2013 14:39:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 7/9] mm: vmscan: Block kswapd if it is encountering
 pages under writeback
Message-Id: <20130515143902.2a381d9a5e11298bf58771d8@linux-foundation.org>
In-Reply-To: <1368432760-21573-8-git-send-email-mgorman@suse.de>
References: <1368432760-21573-1-git-send-email-mgorman@suse.de>
	<1368432760-21573-8-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 13 May 2013 09:12:38 +0100 Mel Gorman <mgorman@suse.de> wrote:

> Historically, kswapd used to congestion_wait() at higher priorities if it
> was not making forward progress. This made no sense as the failure to make
> progress could be completely independent of IO. It was later replaced by
> wait_iff_congested() and removed entirely by commit 258401a6 (mm: don't
> wait on congested zones in balance_pgdat()) as it was duplicating logic
> in shrink_inactive_list().
> 
> This is problematic. If kswapd encounters many pages under writeback and
> it continues to scan until it reaches the high watermark then it will
> quickly skip over the pages under writeback and reclaim clean young
> pages or push applications out to swap.
> 
> The use of wait_iff_congested() is not suited to kswapd as it will only
> stall if the underlying BDI is really congested or a direct reclaimer was
> unable to write to the underlying BDI. kswapd bypasses the BDI congestion
> as it sets PF_SWAPWRITE but even if this was taken into account then it
> would cause direct reclaimers to stall on writeback which is not desirable.
> 
> This patch sets a ZONE_WRITEBACK flag if direct reclaim or kswapd is
> encountering too many pages under writeback. If this flag is set and
> kswapd encounters a PageReclaim page under writeback then it'll assume
> that the LRU lists are being recycled too quickly before IO can complete
> and block waiting for some IO to complete.
> 
>
> ...
>
>  		if (PageWriteback(page)) {
> -			/*
> -			 * memcg doesn't have any dirty pages throttling so we
> -			 * could easily OOM just because too many pages are in
> -			 * writeback and there is nothing else to reclaim.
> -			 *
> -			 * Check __GFP_IO, certainly because a loop driver
> -			 * thread might enter reclaim, and deadlock if it waits
> -			 * on a page for which it is needed to do the write
> -			 * (loop masks off __GFP_IO|__GFP_FS for this reason);
> -			 * but more thought would probably show more reasons.
> -			 *
> -			 * Don't require __GFP_FS, since we're not going into
> -			 * the FS, just waiting on its writeback completion.
> -			 * Worryingly, ext4 gfs2 and xfs allocate pages with
> -			 * grab_cache_page_write_begin(,,AOP_FLAG_NOFS), so
> -			 * testing may_enter_fs here is liable to OOM on them.
> -			 */
> -			if (global_reclaim(sc) ||
> +			/* Case 1 above */
> +			if (current_is_kswapd() &&
> +			    PageReclaim(page) &&
> +			    zone_is_reclaim_writeback(zone)) {
> +				wait_on_page_writeback(page);

wait_on_page_writeback() is problematic.

- The page could be against data which is at the remote end of the
  disk and the wait takes far too long.

- The page could be against a really slow device, perhaps one which
  has a (relatively!) large amount of dirty data pending.

- (What happens if the wait is against a page which is backed by a
  device which is failing or was unplugged or is taking 60 seconds per
  -EIO or whatever?)

- (Can the wait be against an NFS/NBD/whatever page whose ethernet
  cable got unplugged?)

- The termination of wait_on_page_writeback() simply doesn't tell us
  what we want to know here: that there has been a useful amount of
  writeback completion against the pages on the tail of this LRU.

  We really don't care when *this* page's write completes.  What we
  want to know is whether reclaim can usefully restart polling the LRU.
  These are different things, and can sometimes be very different.

These problems were observed in testing and this is why the scanner's
wait_on_page() (and, iirc, wait_on_buffer()) calls were replaced with
congestion_wait() sometime back in the 17th century.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
