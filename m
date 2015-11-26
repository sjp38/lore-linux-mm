Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f50.google.com (mail-lf0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id A4A236B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 03:16:41 -0500 (EST)
Received: by lffu14 with SMTP id u14so88688972lff.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 00:16:41 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id e187si18134347lfg.203.2015.11.26.00.16.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 00:16:40 -0800 (PST)
Date: Thu, 26 Nov 2015 11:16:24 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] vmscan: do not throttle kthreads due to too_many_isolated
Message-ID: <20151126081624.GK29014@esperanza>
References: <1448465801-3280-1-git-send-email-vdavydov@virtuozzo.com>
 <5655D789.80201@suse.cz>
 <20151125162756.GJ29014@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151125162756.GJ29014@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 25, 2015 at 07:27:57PM +0300, Vladimir Davydov wrote:
> On Wed, Nov 25, 2015 at 04:45:13PM +0100, Vlastimil Babka wrote:
> > On 11/25/2015 04:36 PM, Vladimir Davydov wrote:
> > > Block device drivers often hand off io request processing to kernel
> > > threads (example: device mapper). If such a thread calls kmalloc, it can
> > > dive into direct reclaim path and end up waiting for too_many_isolated
> > > to return false, blocking writeback. This can lead to a dead lock if the
> > 
> > Shouldn't such allocation lack __GFP_IO to prevent this and other kinds of
> > deadlocks? And/or have mempools?
> 
> Not necessarily. loopback is an example: it can call
> grab_cache_write_begin -> add_to_page_cache_lru with GFP_KERNEL.

Anyway, kthreads that use GFP_NOIO and/or mempool aren't safe either,
because it isn't an allocation context problem: the reclaimer locks up
not because it tries to take an fs/io lock the caller holds, but because
it waits for isolated pages to be put back, which will never happen,
since processes that isolated them depend on the kthread making
progress. This is purely a reclaimer heuristic, which kmalloc users are
not aware of.

My point is that, in contrast to userspace processes, it is dangerous to
throttle kthreads in the reclaimer, because they might be responsible
for reclaimer progress (e.g. performing writeback).

Regarding side effects of this patch. Well, there aren't many kthreads
out there, so I don't believe this can put the system under the risk of
thrashing because of isolating too many reclaimable pages.

Thanks,
Vladimir

> 
> > PF_KTHREAD looks like a big hammer to me that will solve only one
> > potential problem...
> 
> This problem can result in processes hanging forever. Any ideas how this
> could be fixed in a better way?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
