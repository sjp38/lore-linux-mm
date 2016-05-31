Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 409856B0253
	for <linux-mm@kvack.org>; Tue, 31 May 2016 19:56:31 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id g77so4643472qke.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 16:56:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o70si17440064qki.85.2016.05.31.16.56.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 16:56:30 -0700 (PDT)
Date: Wed, 1 Jun 2016 01:56:26 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: zone_reclaimable() leads to livelock in __alloc_pages_slowpath()
Message-ID: <20160531235626.GA24319@redhat.com>
References: <20160520202817.GA22201@redhat.com>
 <20160523072904.GC2278@dhcp22.suse.cz>
 <20160523151419.GA8284@redhat.com>
 <20160524071619.GB8259@dhcp22.suse.cz>
 <20160524224341.GA11961@redhat.com>
 <20160525120957.GH20132@dhcp22.suse.cz>
 <20160529212540.GA15180@redhat.com>
 <20160531125253.GK26128@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160531125253.GK26128@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/31, Michal Hocko wrote:
>
> On Sun 29-05-16 23:25:40, Oleg Nesterov wrote:
> >
> > This single change in get_scan_count() under for_each_evictable_lru() loop
> >
> > 	-	size = lruvec_lru_size(lruvec, lru);
> > 	+	size = zone_page_state_snapshot(lruvec_zone(lruvec), NR_LRU_BASE + lru);
> >
> > fixes the problem too.
> >
> > Without this change shrink*() continues to scan the LRU_ACTIVE_FILE list
> > while it is empty. LRU_INACTIVE_FILE is not empty (just a few pages) but
> > we do not even try to scan it, lruvec_lru_size() returns zero.
>
> OK, you seem to be really seeing a different issue than me.

quite possibly, but

> My debugging
> patch was showing when nothing was really isolated from the LRU lists
> (both for shrink_{in}active_list.

in my debugging session too. LRU_ACTIVE_FILE was empty, so there is nothing to
isolate even if shrink_active_list() is (wrongly called) with nr_to_scan != 0.
LRU_INACTIVE_FILE is not empty but it is not scanned because nr_to_scan == 0.

But I am afraid I misunderstood you, and you meant something else.

> > Then later we recheck zone_reclaimable() and it notices the INACTIVE_FILE
> > counter because it uses the _snapshot variant, this leads to livelock.
> >
> > I guess this doesn't really matter, but in my particular case these
> > ACTIVE/INACTIVE counters were screwed by the recent putback_inactive_pages()
> > logic. The pages we "leak" in INACTIVE list were recently moved from ACTIVE
> > to INACTIVE list, and this updated only the per-cpu ->vm_stat_diff[] counters,
> > so the "non snapshot" lruvec_lru_size() in get_scan_count() sees the "old"
> > numbers.
>
> Hmm. I am not really sure we can use the _snapshot version in lruvec_lru_size.

Yes, yes, I  understand,

> But I am thinking whether we should simply revert 0db2cb8da89d ("mm,
> vmscan: make zone_reclaimable_pages more precise") in 4.6 stable tree.
> Does that help as well?

I'll test this tomorrow, but even if it helps I am not sure... Yes, this
way zone_reclaimable() and get_scan_count() will see the same numbers, but
how this can help to make zone_reclaimable() == F at the end?

Again, suppose that (say) ACTIVE list is empty but zone->vm_stat != 0
because there is something in per-cpu counter (so that _snapshot == 0).
This means that we sill continue to try to scan this list for no reason.

But Michal, let me repeat that I do not understand this code, so I can
be easily wrong.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
