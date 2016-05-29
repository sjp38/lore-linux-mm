Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1296B0253
	for <linux-mm@kvack.org>; Sun, 29 May 2016 17:25:45 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id w185so153166003vkf.3
        for <linux-mm@kvack.org>; Sun, 29 May 2016 14:25:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x7si1167156qkb.24.2016.05.29.14.25.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 May 2016 14:25:44 -0700 (PDT)
Date: Sun, 29 May 2016 23:25:40 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: zone_reclaimable() leads to livelock in __alloc_pages_slowpath()
Message-ID: <20160529212540.GA15180@redhat.com>
References: <20160520202817.GA22201@redhat.com>
 <20160523072904.GC2278@dhcp22.suse.cz>
 <20160523151419.GA8284@redhat.com>
 <20160524071619.GB8259@dhcp22.suse.cz>
 <20160524224341.GA11961@redhat.com>
 <20160525120957.GH20132@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160525120957.GH20132@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

sorry for delay,

On 05/25, Michal Hocko wrote:
>
> On Wed 25-05-16 00:43:41, Oleg Nesterov wrote:
> >
> > But. It _seems to me_ that the kernel "leaks" some pages in LRU_INACTIVE_FILE
> > list because inactive_file_is_low() returns the wrong value. And do not even
> > ask me why I think so, unlikely I will be able to explain ;) to remind, I never
> > tried to read vmscan.c before.

No, this is not because of inactive_file_is_low(), but

> >
> > But. if I change lruvec_lru_size()
> >
> > 	-       return zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru);
> > 	+       return zone_page_state_snapshot(lruvec_zone(lruvec), NR_LRU_BASE + lru);
> >
> > the problem goes away too.

Yes,

> This is a bit surprising but my testing shows that the result shouldn't
> make much difference. I can see some discrepancies between lru_vec size
> and zone_reclaimable_pages but they are too small to actually matter.

Yes, the difference is small but it does matter.

I do not pretend I understand this all, but finally it seems I understand
whats going on on my system when it hangs. At least, why the change in
lruvec_lru_size() or calculate_normal_threshold() makes a difference.

This single change in get_scan_count() under for_each_evictable_lru() loop

	-	size = lruvec_lru_size(lruvec, lru);
	+	size = zone_page_state_snapshot(lruvec_zone(lruvec), NR_LRU_BASE + lru);

fixes the problem too.

Without this change shrink*() continues to scan the LRU_ACTIVE_FILE list
while it is empty. LRU_INACTIVE_FILE is not empty (just a few pages) but
we do not even try to scan it, lruvec_lru_size() returns zero.

Then later we recheck zone_reclaimable() and it notices the INACTIVE_FILE
counter because it uses the _snapshot variant, this leads to livelock.

I guess this doesn't really matter, but in my particular case these
ACTIVE/INACTIVE counters were screwed by the recent putback_inactive_pages()
logic. The pages we "leak" in INACTIVE list were recently moved from ACTIVE
to INACTIVE list, and this updated only the per-cpu ->vm_stat_diff[] counters,
so the "non snapshot" lruvec_lru_size() in get_scan_count() sees the "old"
numbers.

I even added more printk's, and yes when the system hangs I have something
like, say,

	->vm_stat[ACTIVE] 	 = NR;		// small number
	->vm_stat_diff[ACTIVE]	 = -NR;		// so it is actually zero but
						// get_scan_count() sees NR

	->vm_stat[INACTIVE]	 = 0;		// this is what get_scan_count() sees
	->vm_stat_diff[INACTIVE] = NR;		// and this is what zone_reclaimable()

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
