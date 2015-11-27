Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id D599A6B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 07:50:07 -0500 (EST)
Received: by wmuu63 with SMTP id u63so54503269wmu.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 04:50:07 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id k125si10354537wmd.16.2015.11.27.04.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 04:50:06 -0800 (PST)
Received: by wmuu63 with SMTP id u63so54502754wmu.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 04:50:06 -0800 (PST)
Date: Fri, 27 Nov 2015 13:50:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmscan: do not throttle kthreads due to too_many_isolated
Message-ID: <20151127125005.GH2493@dhcp22.suse.cz>
References: <1448465801-3280-1-git-send-email-vdavydov@virtuozzo.com>
 <5655D789.80201@suse.cz>
 <20151125162756.GJ29014@esperanza>
 <20151126081624.GK29014@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151126081624.GK29014@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 26-11-15 11:16:24, Vladimir Davydov wrote:
> On Wed, Nov 25, 2015 at 07:27:57PM +0300, Vladimir Davydov wrote:
> > On Wed, Nov 25, 2015 at 04:45:13PM +0100, Vlastimil Babka wrote:
> > > On 11/25/2015 04:36 PM, Vladimir Davydov wrote:
> > > > Block device drivers often hand off io request processing to kernel
> > > > threads (example: device mapper). If such a thread calls kmalloc, it can
> > > > dive into direct reclaim path and end up waiting for too_many_isolated
> > > > to return false, blocking writeback. This can lead to a dead lock if the
> > > 
> > > Shouldn't such allocation lack __GFP_IO to prevent this and other kinds of
> > > deadlocks? And/or have mempools?
> > 
> > Not necessarily. loopback is an example: it can call
> > grab_cache_write_begin -> add_to_page_cache_lru with GFP_KERNEL.

AFAIR loop driver reduces the gfp_maks via inode mapping.
 
> Anyway, kthreads that use GFP_NOIO and/or mempool aren't safe either,
> because it isn't an allocation context problem: the reclaimer locks up
> not because it tries to take an fs/io lock the caller holds, but because
> it waits for isolated pages to be put back, which will never happen,
> since processes that isolated them depend on the kthread making
> progress. This is purely a reclaimer heuristic, which kmalloc users are
> not aware of.
> 
> My point is that, in contrast to userspace processes, it is dangerous to
> throttle kthreads in the reclaimer, because they might be responsible
> for reclaimer progress (e.g. performing writeback).

Wouldn't it be better if your writeback kthread did PF_MEMALLOC/__GFP_MEMALLOC
instead because it is in fact a reclaimer so it even get to the reclaim.

There way too many allocations done from the kernel thread context to be
not throttled (just look at worker threads).

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
