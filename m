Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA686B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 06:00:24 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id j12so7056940lbo.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 03:00:24 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id lz8si56093507wjb.35.2016.06.01.03.00.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 03:00:23 -0700 (PDT)
Received: by mail-wm0-f47.google.com with SMTP id n184so23054663wmn.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 03:00:22 -0700 (PDT)
Date: Wed, 1 Jun 2016 12:00:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: zone_reclaimable() leads to livelock in __alloc_pages_slowpath()
Message-ID: <20160601100020.GK26601@dhcp22.suse.cz>
References: <20160520202817.GA22201@redhat.com>
 <20160523072904.GC2278@dhcp22.suse.cz>
 <20160523151419.GA8284@redhat.com>
 <20160524071619.GB8259@dhcp22.suse.cz>
 <20160524224341.GA11961@redhat.com>
 <20160525120957.GH20132@dhcp22.suse.cz>
 <20160529212540.GA15180@redhat.com>
 <20160531125253.GK26128@dhcp22.suse.cz>
 <20160531235626.GA24319@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160531235626.GA24319@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 01-06-16 01:56:26, Oleg Nesterov wrote:
> On 05/31, Michal Hocko wrote:
> >
> > On Sun 29-05-16 23:25:40, Oleg Nesterov wrote:
> > >
> > > This single change in get_scan_count() under for_each_evictable_lru() loop
> > >
> > > 	-	size = lruvec_lru_size(lruvec, lru);
> > > 	+	size = zone_page_state_snapshot(lruvec_zone(lruvec), NR_LRU_BASE + lru);
> > >
> > > fixes the problem too.
> > >
> > > Without this change shrink*() continues to scan the LRU_ACTIVE_FILE list
> > > while it is empty. LRU_INACTIVE_FILE is not empty (just a few pages) but
> > > we do not even try to scan it, lruvec_lru_size() returns zero.
> >
> > OK, you seem to be really seeing a different issue than me.
> 
> quite possibly, but
> 
> > My debugging
> > patch was showing when nothing was really isolated from the LRU lists
> > (both for shrink_{in}active_list.
> 
> in my debugging session too. LRU_ACTIVE_FILE was empty, so there is nothing to
> isolate even if shrink_active_list() is (wrongly called) with nr_to_scan != 0.
> LRU_INACTIVE_FILE is not empty but it is not scanned because nr_to_scan == 0.
> 
> But I am afraid I misunderstood you, and you meant something else.

What I wanted to say is that my debugging hasn't shown a single case
when nothing would be isolated. Which seems to be the case for you.

[...]

> > But I am thinking whether we should simply revert 0db2cb8da89d ("mm,
> > vmscan: make zone_reclaimable_pages more precise") in 4.6 stable tree.
> > Does that help as well?
> 
> I'll test this tomorrow, but even if it helps I am not sure... Yes, this
> way zone_reclaimable() and get_scan_count() will see the same numbers, but
> how this can help to make zone_reclaimable() == F at the end?

It won't in some cases. And that has been the case for ages so I do not
think we need any steps for the stable. What meant to address is a
potential regression caused by 0db2cb8da89d which would make this more
likely because of the mismatch because the patch really makes much more
sense for the oom detection rework which really wants more precise
numbers. If the revert doesn't help then I would just leave it as it is
and just note that the zone_reclaimable was a bad decision which
fortunatelly didn't blow up that often...

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
