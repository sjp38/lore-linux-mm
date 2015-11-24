Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 366726B0258
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 08:37:13 -0500 (EST)
Received: by wmvv187 with SMTP id v187so209738310wmv.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 05:37:12 -0800 (PST)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id o125si19783892wma.42.2015.11.24.05.37.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 05:37:12 -0800 (PST)
Received: by wmww144 with SMTP id w144so138909493wmw.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 05:37:11 -0800 (PST)
Date: Tue, 24 Nov 2015 14:37:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, vmscan: do not overestimate anonymous
 reclaimable pages
Message-ID: <20151124133710.GJ29472@dhcp22.suse.cz>
References: <1448366100-11023-1-git-send-email-mhocko@kernel.org>
 <1448366100-11023-3-git-send-email-mhocko@kernel.org>
 <20151124130740.GG29014@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151124130740.GG29014@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 24-11-15 16:07:40, Vladimir Davydov wrote:
> On Tue, Nov 24, 2015 at 12:55:00PM +0100, Michal Hocko wrote:
> > zone_reclaimable_pages considers all anonymous pages on LRUs reclaimable
> > if there is at least one entry on the swap storage left. This can be
> > really misleading when the swap is short on space and skew reclaim
> > decisions based on zone_reclaimable_pages. Fix this by clamping the
> > number to the minimum of the available swap space and anon LRU pages.
> 
> Suppose there's 100M of swap and 1G of anon pages. This patch makes
> zone_reclaimable_pages return 100M instead of 1G in this case. If you
> rotate 600M of oldest anon pages, which is quite possible,
> zone_reclaimable will start returning false, which is wrong, because
> there are still 400M pages that were not even scanned, besides those
> 600M of rotated pages could have become reclaimable after their ref bits
> got cleared.

Uhm, OK, I guess you are right. Making zone_reclaimable less
conservative can lead to hard to expect results. Scratch this patch
please.
 
> I think it is the name of zone_reclaimable_pages which is misleading. It
> should be called something like "zone_scannable_pages" judging by how it
> is used in zone_reclaimable.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
