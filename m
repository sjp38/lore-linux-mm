Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E05766B0069
	for <linux-mm@kvack.org>; Sun,  6 Nov 2011 21:30:58 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A4B5F3EE0B6
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 11:30:51 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B67D45DF9F
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 11:30:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7350645DF52
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 11:30:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6654F1DB803C
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 11:30:51 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 331451DB8038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 11:30:51 +0900 (JST)
Date: Mon, 7 Nov 2011 11:29:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [rfc 1/3] mm: vmscan: never swap under low memory pressure
Message-Id: <20111107112941.0dfa07cb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111102163141.GH19965@redhat.com>
References: <20110808110658.31053.55013.stgit@localhost6>
	<CAOJsxLF909NRC2r6RL+hm1ARve+3mA6UM_CY9epJaauyqJTG8w@mail.gmail.com>
	<4E3FD403.6000400@parallels.com>
	<20111102163056.GG19965@redhat.com>
	<20111102163141.GH19965@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@parallels.com>, Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Gene Heskett <gene.heskett@gmail.com>

On Wed, 2 Nov 2011 17:31:41 +0100
Johannes Weiner <jweiner@redhat.com> wrote:

> We want to prevent floods of used-once file cache pushing us to swap
> out anonymous pages.  Never swap under a certain priority level.  The
> availability of used-once cache pages should prevent us from reaching
> that threshold.
> 
> This is needed because subsequent patches will revert some of the
> mechanisms that tried to prefer file over anon, and this should not
> result in more eager swapping again.
> 
> It might also be better to keep the aging machinery going and just not
> swap, rather than staying away from anonymous pages in the first place
> and having less useful age information at the time of swapout.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> ---
>  mm/vmscan.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a90c603..39d3da3 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -831,6 +831,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		 * Try to allocate it some swap space here.
>  		 */
>  		if (PageAnon(page) && !PageSwapCache(page)) {
> +			if (priority >= DEF_PRIORITY - 2)
> +				goto keep_locked;
>  			if (!(sc->gfp_mask & __GFP_IO))
>  				goto keep_locked;
>  			if (!add_to_swap(page))

Hm, how about not scanning LRU_ANON rather than checking here ?
Add some bias to get_scan_count() or some..
If you think to need rotation of LRU, only kswapd should do that..

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
