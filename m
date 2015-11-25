Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3A47D6B0254
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 11:28:13 -0500 (EST)
Received: by lfdl133 with SMTP id l133so66659955lfd.2
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 08:28:12 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id gj7si16501071lbc.183.2015.11.25.08.28.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 08:28:11 -0800 (PST)
Date: Wed, 25 Nov 2015 19:27:57 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] vmscan: do not throttle kthreads due to too_many_isolated
Message-ID: <20151125162756.GJ29014@esperanza>
References: <1448465801-3280-1-git-send-email-vdavydov@virtuozzo.com>
 <5655D789.80201@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <5655D789.80201@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 25, 2015 at 04:45:13PM +0100, Vlastimil Babka wrote:
> On 11/25/2015 04:36 PM, Vladimir Davydov wrote:
> > Block device drivers often hand off io request processing to kernel
> > threads (example: device mapper). If such a thread calls kmalloc, it can
> > dive into direct reclaim path and end up waiting for too_many_isolated
> > to return false, blocking writeback. This can lead to a dead lock if the
> 
> Shouldn't such allocation lack __GFP_IO to prevent this and other kinds of
> deadlocks? And/or have mempools?

Not necessarily. loopback is an example: it can call
grab_cache_write_begin -> add_to_page_cache_lru with GFP_KERNEL.

> PF_KTHREAD looks like a big hammer to me that will solve only one
> potential problem...

This problem can result in processes hanging forever. Any ideas how this
could be fixed in a better way?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
