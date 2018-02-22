Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AFDB46B02DC
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 09:09:35 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id r29so3637869wra.13
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 06:09:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i130si297992wmf.178.2018.02.22.06.09.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Feb 2018 06:09:34 -0800 (PST)
Date: Thu, 22 Feb 2018 15:09:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 2/2] mm/memcontrol.c: Reduce reclaim retries in
 mem_cgroup_resize_limit()
Message-ID: <20180222140932.GL30681@dhcp22.suse.cz>
References: <20171220102429.31601-1-aryabinin@virtuozzo.com>
 <20180119132544.19569-1-aryabinin@virtuozzo.com>
 <20180119132544.19569-2-aryabinin@virtuozzo.com>
 <20180119133510.GD6584@dhcp22.suse.cz>
 <CALvZod7HS6P0OU6Rps8JeMJycaPd4dF5NjxV8k1y2-yosF2bdA@mail.gmail.com>
 <20180119151118.GE6584@dhcp22.suse.cz>
 <20180221121715.0233d34dda330c56e1a9db5f@linux-foundation.org>
 <f3893181-67a4-aec2-9514-f141fa78a6c0@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f3893181-67a4-aec2-9514-f141fa78a6c0@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Thu 22-02-18 16:50:33, Andrey Ryabinin wrote:
> On 02/21/2018 11:17 PM, Andrew Morton wrote:
> > On Fri, 19 Jan 2018 16:11:18 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> > 
> >> And to be honest, I do not really see why keeping retrying from
> >> mem_cgroup_resize_limit should be so much faster than keep retrying from
> >> the direct reclaim path. We are doing SWAP_CLUSTER_MAX batches anyway.
> >> mem_cgroup_resize_limit loop adds _some_ overhead but I am not really
> >> sure why it should be that large.
> > 
> > Maybe restarting the scan lots of times results in rescanning lots of
> > ineligible pages at the start of the list before doing useful work?
> > 
> > Andrey, are you able to determine where all that CPU time is being spent?
> > 
> 
> I should have been more specific about the test I did. The full script looks like this:
> 
> mkdir -p /sys/fs/cgroup/memory/test
> echo $$ > /sys/fs/cgroup/memory/test/tasks
> cat 4G_file > /dev/null
> while true; do cat 4G_file > /dev/null; done &
> loop_pid=$!
> perf stat echo 50M > /sys/fs/cgroup/memory/test/memory.limit_in_bytes
> echo -1 > /sys/fs/cgroup/memory/test/memory.limit_in_bytes
> kill $loop_pid
> 
> 
> I think the additional loops add some overhead and it's not that big by itself, but
> this small overhead allows task to refill slightly more pages, increasing
> the total amount of pages that mem_cgroup_resize_limit() need to reclaim.
> 
> By using the following commands to show the the amount of reclaimed pages:
> perf record -e vmscan:mm_vmscan_memcg_reclaim_end echo 50M > /sys/fs/cgroup/memory/test/memory.limit_in_bytes
> perf script|cut -d '=' -f 2| paste -sd+ |bc
> 
> I've got 1259841 pages (4.9G) with the patch vs 1394312 pages (5.4G) without it.

So how does the picture changes if you have multiple producers?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
