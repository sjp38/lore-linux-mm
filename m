Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 584786B0038
	for <linux-mm@kvack.org>; Sat, 11 Oct 2014 19:28:19 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id h11so765891wiw.0
        for <linux-mm@kvack.org>; Sat, 11 Oct 2014 16:28:18 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id uo6si13060371wjc.30.2014.10.11.16.28.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Oct 2014 16:28:17 -0700 (PDT)
Date: Sat, 11 Oct 2014 19:27:59 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/3] mm: memcontrol: fix transparent huge page
 allocations under pressure
Message-ID: <20141011232759.GA10135@phnom.home.cmpxchg.org>
References: <1411571338-8178-1-git-send-email-hannes@cmpxchg.org>
 <1411571338-8178-4-git-send-email-hannes@cmpxchg.org>
 <20140929135707.GA25956@dhcp22.suse.cz>
 <20140929175700.GA20053@cmpxchg.org>
 <20141007135950.GD14243@dhcp22.suse.cz>
 <20141008011106.GA12339@cmpxchg.org>
 <20141008153329.GF4592@dhcp22.suse.cz>
 <20141008174725.GA31706@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141008174725.GA31706@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Dave Hansen <dave@sr71.net>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 08, 2014 at 01:47:25PM -0400, Johannes Weiner wrote:
> On Wed, Oct 08, 2014 at 05:33:29PM +0200, Michal Hocko wrote:
> > On Tue 07-10-14 21:11:06, Johannes Weiner wrote:
> > > On Tue, Oct 07, 2014 at 03:59:50PM +0200, Michal Hocko wrote:
> > > > Another part that matters is the size. Memcgs might be really small and
> > > > that changes the math. Large reclaim target will get to low prio reclaim
> > > > and thus the excessive reclaim.
> > > 
> > > I already addressed page size vs. memcg size before.
> > > 
> > > However, low priority reclaim does not result in excessive reclaim.
> > > The reclaim goal is checked every time it scanned SWAP_CLUSTER_MAX
> > > pages, and it exits if the goal has been met.  See shrink_lruvec(),
> > > shrink_zone() etc.
> > 
> > Now I am confused. shrink_zone will bail out but shrink_lruvec will loop
> > over nr[...] until they are empty and only updates the numbers to be
> > roughly proportional once:
> > 
> >                 if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
> >                         continue;
> > 
> >                 /*
> >                  * For kswapd and memcg, reclaim at least the number of pages
> >                  * requested. Ensure that the anon and file LRUs are scanned
> >                  * proportionally what was requested by get_scan_count(). We
> >                  * stop reclaiming one LRU and reduce the amount scanning
> >                  * proportional to the original scan target.
> >                  */
> > 		[...]
> > 		scan_adjusted = true;
> > 
> > Or do you rely on
> >                 /*
> >                  * It's just vindictive to attack the larger once the smaller
> >                  * has gone to zero.  And given the way we stop scanning the
> >                  * smaller below, this makes sure that we only make one nudge
> >                  * towards proportionality once we've got nr_to_reclaim.
> >                  */
> >                 if (!nr_file || !nr_anon)
> >                         break;
> > 
> > and SCAN_FILE because !inactive_file_is_low?
> 
> That function is indeed quite confusing.
> 
> Once nr_to_reclaim has been met, it looks at both LRUs and decides
> which one has the smaller scan target left, sets it to 0, and then
> scales the bigger target in proportion - that means if it scanned 10%
> of nr[file], it sets nr[anon] to 10% of its original size, minus the
> anon pages it already scanned.  Based on that alone, overscanning is
> limited to twice the requested size, i.e. 4MB for a 2MB THP page,
> regardless of how low the priority drops.

Sorry, this conclusion is incorrect.  The proportionality code can
indeed lead to more overreclaim than that, although I think this is
actually not intended: the comment says "this makes sure we only make
one nudge towards proportionality once we've got nr_to_reclaim," but
once scan_adjusted we never actually check anymore.  We we can end up
making a lot more nudges toward proportionality.

However, the following still applies, so it shouldn't matter:

> In practice, the VM is heavily biased to avoid swapping.  The forceful
> SCAN_FILE you point out is one condition that avoids the proportional
> scan most of the time.  But even the proportional scan is heavily
> biased towards cache - every cache insertion decreases the file
> recent_rotated/recent_scanned ratio, whereas anon faults do not.
> 
> On top of that, anon pages start out on the active list, whereas cache
> starts on the inactive, which means that the majority of the anon scan
> target - should there be one - usually translates to deactivation.
> 
> So in most cases, I'd expect the scanner to bail after nr_to_reclaim
> cache pages, and in low cache situations it might scan up to 2MB worth
> of anon pages, a small amount of which it might swap.
> 
> I don't particularly like the decisions the current code makes, but it
> should work.  We have put in a lot of effort to prevent overreclaim in
> the last few years, and a big part of this was decoupling the priority
> level from the actual reclaim results.  Nowadays, the priority level
> should merely dictate the scan window and have no impact on the number
> of pages actually reclaimed.  I don't expect that it will, but if it
> does, that's a reclaim bug that needs to be addressed.  If we ask for
> N pages, it should never reclaim significantly more than that,
> regardless of how aggressively it has to scan to accomplish that.

That being said, I don't get the rationale behind the proportionality
code in shrink_lruvec().  The patch that introduced it - e82e0561dae9
("mm: vmscan: obey proportional scanning requirements for kswapd") -
mentions respecting swappiness, but as per above we ignore swappiness
anyway until we run low on cache and into actual pressure.  And under
pressure, once we struggle to reclaim nr_to_reclaim, proportionality
enforces itself when one LRU type target hits zero and we continue to
scan the one for which more pressure was allocated.  But as long as we
scan both lists at the same SWAP_CLUSTER_MAX rate and have no problem
getting nr_to_reclaim pages with left-over todo for *both* LRU types,
what's the point of going on?

The justification for enforcing proportionality in direct reclaim is
particularly puzzling:

---

commit 1a501907bbea8e6ebb0b16cf6db9e9cbf1d2c813
Author: Mel Gorman <mgorman@suse.de>
Date:   Wed Jun 4 16:10:49 2014 -0700

    mm: vmscan: use proportional scanning during direct reclaim and full scan at DEF_PRIORITY

[...]

                                                  3.15.0-rc5            3.15.0-rc5
                                                    shrinker            proportion
    Unit  lru-file-readonce    elapsed      5.3500 (  0.00%)      5.4200 ( -1.31%)
    Unit  lru-file-readonce time_range      0.2700 (  0.00%)      0.1400 ( 48.15%)
    Unit  lru-file-readonce time_stddv      0.1148 (  0.00%)      0.0536 ( 53.33%)
    Unit lru-file-readtwice    elapsed      8.1700 (  0.00%)      8.1700 (  0.00%)
    Unit lru-file-readtwice time_range      0.4300 (  0.00%)      0.2300 ( 46.51%)
    Unit lru-file-readtwice time_stddv      0.1650 (  0.00%)      0.0971 ( 41.16%)
    
    The test cases are running multiple dd instances reading sparse files. The results are within
    the noise for the small test machine. The impact of the patch is more noticable from the vmstats
    
                                3.15.0-rc5  3.15.0-rc5
                                  shrinker  proportion
    Minor Faults                     35154       36784
    Major Faults                       611        1305
    Swap Ins                           394        1651
    Swap Outs                         4394        5891
    Allocation stalls               118616       44781
    Direct pages scanned           4935171     4602313
    Kswapd pages scanned          15921292    16258483
    Kswapd pages reclaimed        15913301    16248305
    Direct pages reclaimed         4933368     4601133
    Kswapd efficiency                  99%         99%
    Kswapd velocity             670088.047  682555.961
    Direct efficiency                  99%         99%
    Direct velocity             207709.217  193212.133
    Percentage direct scans            23%         22%
    Page writes by reclaim        4858.000    6232.000
    Page writes file                   464         341
    Page writes anon                  4394        5891
    
    Note that there are fewer allocation stalls even though the amount
    of direct reclaim scanning is very approximately the same.

---

The timings show nothing useful, but the statistics strongly speak
*against* this patch.  Sure, direct reclaim invocations are reduced,
but everything else worsened: minor faults increased, major faults
doubled(!), swapins quadrupled(!!), swapins increased, pages scanned
increased, pages reclaimed increased, reclaim page writes increased.

If direct reclaim is invoked at that rate, kswapd is failing at its
job, and the solution shouldn't be to overscan in direct reclaim.  On
the other hand, multi-threaded sparse readers are kind of expected to
overwhelm a single kswapd worker, I'm not sure we should be tuning
allocation latency to such a workload in the first place.

Mel, do you maybe remember details that are not in the changelogs?
Because based on them alone, I think we should look at other ways to
ensure we scan with the right amount of vigor...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
