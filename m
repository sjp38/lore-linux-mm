Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7FBCC6B0069
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 06:34:07 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id o32so6052892wrf.20
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 03:34:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 64si14096280wri.143.2017.12.20.03.34.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 03:34:06 -0800 (PST)
Date: Wed, 20 Dec 2017 12:34:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm/memcg: try harder to decrease
 [memory,memsw].limit_in_bytes
Message-ID: <20171220113404.GN4831@dhcp22.suse.cz>
References: <20171220102429.31601-1-aryabinin@virtuozzo.com>
 <20171220103337.GL4831@dhcp22.suse.cz>
 <6e9ee949-c203-621d-890f-25a432bd4bb3@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6e9ee949-c203-621d-890f-25a432bd4bb3@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 20-12-17 14:32:19, Andrey Ryabinin wrote:
> On 12/20/2017 01:33 PM, Michal Hocko wrote:
> > On Wed 20-12-17 13:24:28, Andrey Ryabinin wrote:
> >> mem_cgroup_resize_[memsw]_limit() tries to free only 32 (SWAP_CLUSTER_MAX)
> >> pages on each iteration. This makes practically impossible to decrease
> >> limit of memory cgroup. Tasks could easily allocate back 32 pages,
> >> so we can't reduce memory usage, and once retry_count reaches zero we return
> >> -EBUSY.
> >>
> >> It's easy to reproduce the problem by running the following commands:
> >>
> >>   mkdir /sys/fs/cgroup/memory/test
> >>   echo $$ >> /sys/fs/cgroup/memory/test/tasks
> >>   cat big_file > /dev/null &
> >>   sleep 1 && echo $((100*1024*1024)) > /sys/fs/cgroup/memory/test/memory.limit_in_bytes
> >>   -bash: echo: write error: Device or resource busy
> >>
> >> Instead of trying to free small amount of pages, it's much more
> >> reasonable to free 'usage - limit' pages.
> > 
> > But that only makes the issue less probable. It doesn't fix it because 
> > 		if (curusage >= oldusage)
> > 			retry_count--;
> > can still be true because allocator might be faster than the reclaimer.
> > Wouldn't it be more reasonable to simply remove the retry count and keep
> > trying until interrupted or we manage to update the limit.
> 
> But does it makes sense to continue reclaiming even if reclaimer can't
> make any progress? I'd say no. "Allocator is faster than reclaimer"
> may be not the only reason for failed reclaim. E.g. we could try to
> set limit lower than amount of mlock()ed memory in cgroup, retrying
> reclaim would be just a waste of machine's resources.  Or we simply
> don't have any swap, and anon > new_limit. Should be burn the cpu in
> that case?

We can check the number of reclaimed pages and go EBUSY if it is 0.
 
> > Another option would be to commit the new limit and allow temporal overcommit
> > of the hard limit. New allocations and the limit update paths would
> > reclaim to the hard limit.
> > 
> 
> It sounds a bit fragile and tricky to me. I wouldn't go that way
> without unless we have a very good reason for this.

I haven't explored this, to be honest, so there may be dragons that way.
I've just mentioned that option for completness.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
