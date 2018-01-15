Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1EA456B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 07:58:27 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 33so5762398wrs.3
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 04:58:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 71si5541570wrl.477.2018.01.15.04.58.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jan 2018 04:58:25 -0800 (PST)
Date: Mon, 15 Jan 2018 13:58:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4] mm/memcg: try harder to decrease
 [memory,memsw].limit_in_bytes
Message-ID: <20180115125824.GC22473@dhcp22.suse.cz>
References: <20180111104239.GZ1732@dhcp22.suse.cz>
 <4a8f667d-c2ae-e3df-00fd-edc01afe19e1@virtuozzo.com>
 <20180111124629.GA1732@dhcp22.suse.cz>
 <ce885a69-67af-5f4c-1116-9f6803fb45ee@virtuozzo.com>
 <20180111162947.GG1732@dhcp22.suse.cz>
 <560a77b5-02d7-cbae-35f3-0b20a1c384c2@virtuozzo.com>
 <20180112122405.GK1732@dhcp22.suse.cz>
 <7d1b5bfb-f602-8cf4-2de6-dd186484e55c@virtuozzo.com>
 <20180115124652.GB22473@dhcp22.suse.cz>
 <17c368ce-3a20-d776-bc11-65b6a5bb1ff7@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <17c368ce-3a20-d776-bc11-65b6a5bb1ff7@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

On Mon 15-01-18 15:53:35, Andrey Ryabinin wrote:
> 
> 
> On 01/15/2018 03:46 PM, Michal Hocko wrote:
> > On Mon 15-01-18 15:30:59, Andrey Ryabinin wrote:
> >>
> >>
> >> On 01/12/2018 03:24 PM, Michal Hocko wrote:
> >>> On Fri 12-01-18 00:59:38, Andrey Ryabinin wrote:
> >>>> On 01/11/2018 07:29 PM, Michal Hocko wrote:
> >>> [...]
> >>>>> I do not think so. Consider that this reclaim races with other
> >>>>> reclaimers. Now you are reclaiming a large chunk so you might end up
> >>>>> reclaiming more than necessary. SWAP_CLUSTER_MAX would reduce the over
> >>>>> reclaim to be negligible.
> >>>>>
> >>>>
> >>>> I did consider this. And I think, I already explained that sort of race in previous email.
> >>>> Whether "Task B" is really a task in cgroup or it's actually a bunch of reclaimers,
> >>>> doesn't matter. That doesn't change anything.
> >>>
> >>> I would _really_ prefer two patches here. The first one removing the
> >>> hard coded reclaim count. That thing is just dubious at best. If you
> >>> _really_ think that the higher reclaim target is meaningfull then make
> >>> it a separate patch. I am not conviced but I will not nack it it either.
> >>> But it will make our life much easier if my over reclaim concern is
> >>> right and we will need to revert it. Conceptually those two changes are
> >>> independent anywa.
> >>>
> >>
> >> Ok, fair point. But what about livelock than? Don't you think that we should
> >> go back to something like in V1 patch to prevent it?
> > 
> > I am not sure what do you mean by the livelock here.
> > 
> 
> Livelock is when tasks in cgroup constantly allocate reclaimable memory at high rate,
> and user asked to set too low unreachable limit e.g. 'echo 4096 > memory.limit_in_bytes'.

OK, I wasn't sure. The reclaim target, however, doesn't have a direct
influence on this, though.

> We will loop indefinitely in mem_cgroup_resize_limit(), because try_to_free_mem_cgroup_pages() != 0
> (as long as cgroup tasks generate new reclaimable pages fast enough).

I do not thing this is a real problem. The context is interruptible and
I would even consider it safer to keep retrying than simply failing
prematurely. My experience tells me that basically any hard coded retry
loop in the kernel is wrong.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
