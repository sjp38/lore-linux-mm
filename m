Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 0AC1E6B00BB
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 03:05:06 -0400 (EDT)
Date: Thu, 12 Jul 2012 09:05:01 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120712070501.GB21013@tiehlicka.suse.cz>
References: <1340117404-30348-1-git-send-email-mhocko@suse.cz>
 <20120619150014.1ebc108c.akpm@linux-foundation.org>
 <20120620101119.GC5541@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1207111818380.1299@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207111818380.1299@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Fengguang Wu <fengguang.wu@intel.com>

On Wed 11-07-12 18:57:43, Hugh Dickins wrote:
> Hi Michal,

Hi,

> 
> On Wed, 20 Jun 2012, Michal Hocko wrote:
> > Hi Andrew,
> > here is an updated version if it is easier for you to drop the previous
> > one.
> > changes since v1
> > * added Mel's Reviewed-by
> > * updated changelog as per Andrew
> > * updated the condition to be optimized for no-memcg case
> 
> I mentioned in Johannes's [03/11] thread a couple of days ago, that
> I was having a problem with your wait_on_page_writeback() in mmotm.
> 
> It turns out that your original patch was fine, but you let dark angels
> whisper into your ear, to persuade you to remove the "&& may_enter_fs".
> 
> Part of my load builds kernels on extN over loop over tmpfs: loop does
> mapping_set_gfp_mask(mapping, lo->old_gfp_mask & ~(__GFP_IO|__GFP_FS))
> because it knows it will deadlock, if the loop thread enters reclaim,
> and reclaim tries to write back a dirty page, one which needs the loop
> thread to perform the write.

Good catch! I have totally missed the loop driver.

> With the may_enter_fs check restored, all is well.  I don't entirely
> like your patch: I think it would be much better to wait in the same
> place as the wait_iff_congested(), when the pages gathered have been
> sent for writing and unlocked and putback and freed; 

I guess you mean
	if (nr_writeback && nr_writeback >=
                        (nr_taken >> (DEF_PRIORITY - sc->priority)))
                wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);

I have tried to hook here but it has some issues. First of all we do not
know how long we should wait. Waiting for specific pages sounded more
event based and more precise.

We can surely do better but I wanted to stop the OOM first without any
other possible side effects on the global reclaim. I have tried to make
the band aid as simple as possible. Memcg dirty pages accounting is
forming already so we are one (tiny) step closer to the throttling.
 
> and I also wonder if it should go beyond the !global_reclaim case for
> swap pages, because they don't participate in dirty limiting.

Worth a separate patch?

> But those are things I should investigate later - I did write a patch
> like that before, when I was having some unexpected OOM trouble with a
> private kernel; but my OOMs then were because of something silly that
> I'd left out, and I'm not at present sure if we have a problem in this
> regard or not.
> 
> The important thing is to get the may_enter_fs back into your patch:
> I can't really Sign-off the below because it's yours, but
> Acked-by: Hugh Dickins <hughd@google.com>

Thanks a lot Hugh!

When we are back to the patch. Is it going into 3.5? I hope so and I
think it is really worth stable as well. Andrew?

> ---
> 
>  mm/vmscan.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> --- 3.5-rc6-mm1/mm/vmscan.c	2012-07-11 14:42:13.668335884 -0700
> +++ linux/mm/vmscan.c	2012-07-11 16:01:20.712814127 -0700
> @@ -726,7 +726,8 @@ static unsigned long shrink_page_list(st
>  			 * writeback from reclaim and there is nothing else to
>  			 * reclaim.
>  			 */
> -			if (!global_reclaim(sc) && PageReclaim(page))
> +			if (!global_reclaim(sc) && PageReclaim(page) &&
> +					may_enter_fs)
>  				wait_on_page_writeback(page);
>  			else {
>  				nr_writeback++;

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
