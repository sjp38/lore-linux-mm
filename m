Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6F38D6B0069
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 13:47:36 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id em10so11169788wid.4
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 10:47:35 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f4si654150wje.167.2014.10.08.10.47.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Oct 2014 10:47:35 -0700 (PDT)
Date: Wed, 8 Oct 2014 13:47:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/3] mm: memcontrol: fix transparent huge page
 allocations under pressure
Message-ID: <20141008174725.GA31706@cmpxchg.org>
References: <1411571338-8178-1-git-send-email-hannes@cmpxchg.org>
 <1411571338-8178-4-git-send-email-hannes@cmpxchg.org>
 <20140929135707.GA25956@dhcp22.suse.cz>
 <20140929175700.GA20053@cmpxchg.org>
 <20141007135950.GD14243@dhcp22.suse.cz>
 <20141008011106.GA12339@cmpxchg.org>
 <20141008153329.GF4592@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141008153329.GF4592@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 08, 2014 at 05:33:29PM +0200, Michal Hocko wrote:
> [I do not have time to get over all points here and will be offline
> until Monday - will get back to the rest then]
> 
> On Tue 07-10-14 21:11:06, Johannes Weiner wrote:
> > On Tue, Oct 07, 2014 at 03:59:50PM +0200, Michal Hocko wrote:
> [...]
> > > I am completely missing any notes about potential excessive
> > > swapouts or longer reclaim stalls which are a natural side effect of direct
> > > reclaim with a larger target (or is this something we do not agree on?).
> > 
> > Yes, we disagree here.  Why is reclaiming 2MB once worse than entering
> > reclaim 16 times to reclaim SWAP_CLUSTER_MAX?
> 
> You can enter DEF_PRIORITY reclaim 16 times and reclaim your target but
> you need at least 512<<DEF_PRIORITY pages on your LRUs to do it in a
> single run on that priority. So especially small groups will pay more
> and would be subject to mentioned problems (e.g. over-reclaim).

No, even low priority scans bail out shortly after nr_to_reclaim.

> > There is no inherent difference in reclaiming a big chunk and
> > reclaiming many small chunks that add up to the same size.
>  
> [...]
> 
> > > Another part that matters is the size. Memcgs might be really small and
> > > that changes the math. Large reclaim target will get to low prio reclaim
> > > and thus the excessive reclaim.
> > 
> > I already addressed page size vs. memcg size before.
> > 
> > However, low priority reclaim does not result in excessive reclaim.
> > The reclaim goal is checked every time it scanned SWAP_CLUSTER_MAX
> > pages, and it exits if the goal has been met.  See shrink_lruvec(),
> > shrink_zone() etc.
> 
> Now I am confused. shrink_zone will bail out but shrink_lruvec will loop
> over nr[...] until they are empty and only updates the numbers to be
> roughly proportional once:
> 
>                 if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
>                         continue;
> 
>                 /*
>                  * For kswapd and memcg, reclaim at least the number of pages
>                  * requested. Ensure that the anon and file LRUs are scanned
>                  * proportionally what was requested by get_scan_count(). We
>                  * stop reclaiming one LRU and reduce the amount scanning
>                  * proportional to the original scan target.
>                  */
> 		[...]
> 		scan_adjusted = true;
> 
> Or do you rely on
>                 /*
>                  * It's just vindictive to attack the larger once the smaller
>                  * has gone to zero.  And given the way we stop scanning the
>                  * smaller below, this makes sure that we only make one nudge
>                  * towards proportionality once we've got nr_to_reclaim.
>                  */
>                 if (!nr_file || !nr_anon)
>                         break;
> 
> and SCAN_FILE because !inactive_file_is_low?

That function is indeed quite confusing.

Once nr_to_reclaim has been met, it looks at both LRUs and decides
which one has the smaller scan target left, sets it to 0, and then
scales the bigger target in proportion - that means if it scanned 10%
of nr[file], it sets nr[anon] to 10% of its original size, minus the
anon pages it already scanned.  Based on that alone, overscanning is
limited to twice the requested size, i.e. 4MB for a 2MB THP page,
regardless of how low the priority drops.

In practice, the VM is heavily biased to avoid swapping.  The forceful
SCAN_FILE you point out is one condition that avoids the proportional
scan most of the time.  But even the proportional scan is heavily
biased towards cache - every cache insertion decreases the file
recent_rotated/recent_scanned ratio, whereas anon faults do not.

On top of that, anon pages start out on the active list, whereas cache
starts on the inactive, which means that the majority of the anon scan
target - should there be one - usually translates to deactivation.

So in most cases, I'd expect the scanner to bail after nr_to_reclaim
cache pages, and in low cache situations it might scan up to 2MB worth
of anon pages, a small amount of which it might swap.

I don't particularly like the decisions the current code makes, but it
should work.  We have put in a lot of effort to prevent overreclaim in
the last few years, and a big part of this was decoupling the priority
level from the actual reclaim results.  Nowadays, the priority level
should merely dictate the scan window and have no impact on the number
of pages actually reclaimed.  I don't expect that it will, but if it
does, that's a reclaim bug that needs to be addressed.  If we ask for
N pages, it should never reclaim significantly more than that,
regardless of how aggressively it has to scan to accomplish that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
