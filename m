Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id D05BD6B0072
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 11:33:33 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id a1so11772759wgh.35
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 08:33:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t3si303577wjz.143.2014.10.08.08.33.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Oct 2014 08:33:32 -0700 (PDT)
Date: Wed, 8 Oct 2014 17:33:29 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 3/3] mm: memcontrol: fix transparent huge page
 allocations under pressure
Message-ID: <20141008153329.GF4592@dhcp22.suse.cz>
References: <1411571338-8178-1-git-send-email-hannes@cmpxchg.org>
 <1411571338-8178-4-git-send-email-hannes@cmpxchg.org>
 <20140929135707.GA25956@dhcp22.suse.cz>
 <20140929175700.GA20053@cmpxchg.org>
 <20141007135950.GD14243@dhcp22.suse.cz>
 <20141008011106.GA12339@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141008011106.GA12339@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

[I do not have time to get over all points here and will be offline
until Monday - will get back to the rest then]

On Tue 07-10-14 21:11:06, Johannes Weiner wrote:
> On Tue, Oct 07, 2014 at 03:59:50PM +0200, Michal Hocko wrote:
[...]
> > I am completely missing any notes about potential excessive
> > swapouts or longer reclaim stalls which are a natural side effect of direct
> > reclaim with a larger target (or is this something we do not agree on?).
> 
> Yes, we disagree here.  Why is reclaiming 2MB once worse than entering
> reclaim 16 times to reclaim SWAP_CLUSTER_MAX?

You can enter DEF_PRIORITY reclaim 16 times and reclaim your target but
you need at least 512<<DEF_PRIORITY pages on your LRUs to do it in a
single run on that priority. So especially small groups will pay more
and would be subject to mentioned problems (e.g. over-reclaim).

> There is no inherent difference in reclaiming a big chunk and
> reclaiming many small chunks that add up to the same size.
 
[...]

> > Another part that matters is the size. Memcgs might be really small and
> > that changes the math. Large reclaim target will get to low prio reclaim
> > and thus the excessive reclaim.
> 
> I already addressed page size vs. memcg size before.
> 
> However, low priority reclaim does not result in excessive reclaim.
> The reclaim goal is checked every time it scanned SWAP_CLUSTER_MAX
> pages, and it exits if the goal has been met.  See shrink_lruvec(),
> shrink_zone() etc.

Now I am confused. shrink_zone will bail out but shrink_lruvec will loop
over nr[...] until they are empty and only updates the numbers to be
roughly proportional once:

                if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
                        continue;

                /*
                 * For kswapd and memcg, reclaim at least the number of pages
                 * requested. Ensure that the anon and file LRUs are scanned
                 * proportionally what was requested by get_scan_count(). We
                 * stop reclaiming one LRU and reduce the amount scanning
                 * proportional to the original scan target.
                 */
		[...]
		scan_adjusted = true;

Or do you rely on
                /*
                 * It's just vindictive to attack the larger once the smaller
                 * has gone to zero.  And given the way we stop scanning the
                 * smaller below, this makes sure that we only make one nudge
                 * towards proportionality once we've got nr_to_reclaim.
                 */
                if (!nr_file || !nr_anon)
                        break;

and SCAN_FILE because !inactive_file_is_low?

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
