Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 15EB56B006C
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 05:37:11 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id b6so358937lbj.31
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 02:37:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m8si1140607lam.108.2014.10.17.02.37.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Oct 2014 02:37:10 -0700 (PDT)
Date: Fri, 17 Oct 2014 10:37:02 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 3/3] mm: memcontrol: fix transparent huge page
 allocations under pressure
Message-ID: <20141017093702.GF23874@suse.de>
References: <1411571338-8178-1-git-send-email-hannes@cmpxchg.org>
 <1411571338-8178-4-git-send-email-hannes@cmpxchg.org>
 <20140929135707.GA25956@dhcp22.suse.cz>
 <20140929175700.GA20053@cmpxchg.org>
 <20141007135950.GD14243@dhcp22.suse.cz>
 <20141008011106.GA12339@cmpxchg.org>
 <20141008153329.GF4592@dhcp22.suse.cz>
 <20141008174725.GA31706@cmpxchg.org>
 <20141011232759.GA10135@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20141011232759.GA10135@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Dave Hansen <dave@sr71.net>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, Oct 11, 2014 at 07:27:59PM -0400, Johannes Weiner wrote:
> > I don't particularly like the decisions the current code makes, but it
> > should work.  We have put in a lot of effort to prevent overreclaim in
> > the last few years, and a big part of this was decoupling the priority
> > level from the actual reclaim results.  Nowadays, the priority level
> > should merely dictate the scan window and have no impact on the number
> > of pages actually reclaimed.  I don't expect that it will, but if it
> > does, that's a reclaim bug that needs to be addressed.  If we ask for
> > N pages, it should never reclaim significantly more than that,
> > regardless of how aggressively it has to scan to accomplish that.
> 
> That being said, I don't get the rationale behind the proportionality
> code in shrink_lruvec().  The patch that introduced it - e82e0561dae9
> ("mm: vmscan: obey proportional scanning requirements for kswapd") -
> mentions respecting swappiness, but as per above we ignore swappiness
> anyway until we run low on cache and into actual pressure. 

Swappiness is ignored until active < inactive which is not necessarily
indicative of pressure. Filesystems may mark pages active and move them
to the active list in the absense of pressure for example.

The changelog does not mention it but a big motivator for the patch was
this result https://lkml.org/lkml/2014/5/22/420 and the opening paragraph
mentions "The intent was to minimse direct reclaim latency but Yuanhan
Liu pointer out that it substitutes one long stall for many small stalls
and distorts aging for normal workloads like streaming readers/writers."

> And under
> pressure, once we struggle to reclaim nr_to_reclaim, proportionality
> enforces itself when one LRU type target hits zero and we continue to
> scan the one for which more pressure was allocated.  But as long as we
> scan both lists at the same SWAP_CLUSTER_MAX rate and have no problem
> getting nr_to_reclaim pages with left-over todo for *both* LRU types,
> what's the point of going on?
> 

If we always scanned evenly then it risks reintroducing the long-lived
problem where starting a large amount of IO in the background pushed
everything into swap

> The justification for enforcing proportionality in direct reclaim is
> particularly puzzling:
> 
> ---
> 
> commit 1a501907bbea8e6ebb0b16cf6db9e9cbf1d2c813
> Author: Mel Gorman <mgorman@suse.de>
> Date:   Wed Jun 4 16:10:49 2014 -0700
> 
>     mm: vmscan: use proportional scanning during direct reclaim and full scan at DEF_PRIORITY
> 
> [...]
> 
>                                                   3.15.0-rc5            3.15.0-rc5
>                                                     shrinker            proportion
>     Unit  lru-file-readonce    elapsed      5.3500 (  0.00%)      5.4200 ( -1.31%)
>     Unit  lru-file-readonce time_range      0.2700 (  0.00%)      0.1400 ( 48.15%)
>     Unit  lru-file-readonce time_stddv      0.1148 (  0.00%)      0.0536 ( 53.33%)
>     Unit lru-file-readtwice    elapsed      8.1700 (  0.00%)      8.1700 (  0.00%)
>     Unit lru-file-readtwice time_range      0.4300 (  0.00%)      0.2300 ( 46.51%)
>     Unit lru-file-readtwice time_stddv      0.1650 (  0.00%)      0.0971 ( 41.16%)
>     
>     The test cases are running multiple dd instances reading sparse files. The results are within
>     the noise for the small test machine. The impact of the patch is more noticable from the vmstats
>     
>                                 3.15.0-rc5  3.15.0-rc5
>                                   shrinker  proportion
>     Minor Faults                     35154       36784
>     Major Faults                       611        1305
>     Swap Ins                           394        1651
>     Swap Outs                         4394        5891
>     Allocation stalls               118616       44781
>     Direct pages scanned           4935171     4602313
>     Kswapd pages scanned          15921292    16258483
>     Kswapd pages reclaimed        15913301    16248305
>     Direct pages reclaimed         4933368     4601133
>     Kswapd efficiency                  99%         99%
>     Kswapd velocity             670088.047  682555.961
>     Direct efficiency                  99%         99%
>     Direct velocity             207709.217  193212.133
>     Percentage direct scans            23%         22%
>     Page writes by reclaim        4858.000    6232.000
>     Page writes file                   464         341
>     Page writes anon                  4394        5891
>     
>     Note that there are fewer allocation stalls even though the amount
>     of direct reclaim scanning is very approximately the same.
> 
> ---
> 
> The timings show nothing useful, but the statistics strongly speak
> *against* this patch.  Sure, direct reclaim invocations are reduced,
> but everything else worsened: minor faults increased, major faults
> doubled(!), swapins quadrupled(!!), swapins increased, pages scanned
> increased, pages reclaimed increased, reclaim page writes increased.
> 

Direct reclaim invocations reducing was in line with the intent to
prevent many small stalls.

The increase in minor faults is marginal in absolute terms and very
likely within the noise.

Major faults might have doubled but in absolute terms is about the size
of a THP allocation or roughly a 25ms stall (depending on disk obviously)
overall in a long-lived test.

Differences in swap figures are also large in relative terms but very
small in absolute terms. Again, I suspected it was within the noise.

Same rational for the others. The changes in reclaim stats in absolute
terms are small considering the type of test being executed. The reclaim
figure changes look terrifying but if you look at the sum of direct and
kswapd reclaimed pages you'll see that the difference is marginal and all
that changed was who did the work. Same for scanning. Total scanning and
reclaim work was approximately similar, all that changed in this test is
what process did the work.

What was more important in this case was Yuanhan Liu report that the patch
addressed a major regression.

> Mel, do you maybe remember details that are not in the changelogs?

The link to Yuanhan Liu's report was missing but that happened after the
changelog was written so that is hardly a surprise. Nothing else springs
to mind.

> Because based on them alone, I think we should look at other ways to
> ensure we scan with the right amount of vigor...

I'm not against it per-se but avoid over-reacting about changes in stats
that are this small in absolute terms. If you do change this area, I
strongly suggest you also test with the parallelio-memcachetest configs
from mmtests and watch for IO causing excessive swap.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
