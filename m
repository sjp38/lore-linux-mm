Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5C96B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 03:29:08 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id ga2so72710969lbc.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 00:29:08 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id iq6si42327053wjb.116.2016.05.23.00.29.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 00:29:06 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id q62so12234452wmg.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 00:29:06 -0700 (PDT)
Date: Mon, 23 May 2016 09:29:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: zone_reclaimable() leads to livelock in __alloc_pages_slowpath()
Message-ID: <20160523072904.GC2278@dhcp22.suse.cz>
References: <20160520202817.GA22201@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160520202817.GA22201@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,
Tetsuo has already pointed you at my oom detection rework which removes
the zone_reclaimable ugliness (btw. one of the top reasons to rework
this area) and it is likely to fix your problem. I would still like to
understand what happens with your test case because we might want to
prepare a stable patch for older kernels.

On Fri 20-05-16 22:28:17, Oleg Nesterov wrote:
> I don't understand vmscan.c, and in fact I don't even understand NR_PAGES_SCANNED
[...]
> counter... why it has to be atomic/per-cpu? It is always updated under ->lru_lock
> except free_pcppages_bulk/free_one_page try to reset this counter. But note that
> they both do

It doesn't really have to be atomic/per-cpu because it is really updated
under the lock. It just uses the generic vmstat infrastructure...

> 	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
> 	if (nr_scanned)
> 		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
> 
> and this doesn't look exactly right: zone_page_state() ignores the per-cpu
> ->vm_stat_diff[] counters (and we probably do not want for_each_online_cpu()
> loop here). And I do not know if this is really bad or not, but note that if
> I change calculate_normal_threshold() to return 0, the problem goes away too.

You are absolutely right that this is racy. In the worst case we would
end up missing nr_cpus*threshold scanned pages which would stay behind.
But

bool zone_reclaimable(struct zone *zone)
{
	return zone_page_state_snapshot(zone, NR_PAGES_SCANNED) <
		zone_reclaimable_pages(zone) * 6;
}

So the left over shouldn't cause it to return true all the time. In
fact it could prematurely say false, right? (note that _snapshot variant
considers per-cpu diffs [1]).

That being said I am not really sure why would the 0 threshold help for
your test case. Could you add some tracing and see what are the numbers
above? Is it possible that zone_reclaimable_pages is some small number
which actuall prevents us to scan anything? Aka a bug is get_scan_count
or somewhere else?

[1] I am not really sure which kernel version have you tested - your
config says 4.6.0-rc7 but this is true since 0db2cb8da89d ("mm, vmscan:
make zone_reclaimable_pages more precise") which is 4.6-rc1.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
