Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 736E88E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 17:51:49 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id 196so4453828ybf.8
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 14:51:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w79sor13337939ybe.150.2019.01.09.14.51.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 14:51:45 -0800 (PST)
Date: Wed, 9 Jan 2019 17:51:43 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC v3 PATCH 0/5] mm: memcontrol: do memory reclaim when
 offlining
Message-ID: <20190109225143.GA22252@cmpxchg.org>
References: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190109193247.GA16319@cmpxchg.org>
 <d92912c7-511e-2ab5-39a6-38af3209fcaf@linux.alibaba.com>
 <20190109212334.GA18978@cmpxchg.org>
 <9de4bb4a-6bb7-e13a-0d9a-c1306e1b3e60@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9de4bb4a-6bb7-e13a-0d9a-c1306e1b3e60@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@suse.com, shakeelb@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 09, 2019 at 02:09:20PM -0800, Yang Shi wrote:
> On 1/9/19 1:23 PM, Johannes Weiner wrote:
> > On Wed, Jan 09, 2019 at 12:36:11PM -0800, Yang Shi wrote:
> > > As I mentioned above, if we know some page caches from some memcgs
> > > are referenced one-off and unlikely shared, why just keep them
> > > around to increase memory pressure?
> > It's just not clear to me that your scenarios are generic enough to
> > justify adding two interfaces that we have to maintain forever, and
> > that they couldn't be solved with existing mechanisms.
> > 
> > Please explain:
> > 
> > - Unmapped clean page cache isn't expensive to reclaim, certainly
> >    cheaper than the IO involved in new application startup. How could
> >    recycling clean cache be a prohibitive part of workload warmup?
> 
> It is nothing about recycling. Those page caches might be referenced by
> memcg just once, then nobody touch them until memory pressure is hit. And,
> they might be not accessed again at any time soon.

I meant recycling the page frames, not the cache in them. So the new
workload as it starts up needs to take those pages from the LRU list
instead of just the allocator freelist. While that's obviously not the
same cost, it's not clear why the difference would be prohibitive to
application startup especially since app startup tends to be dominated
by things like IO to fault in executables etc.

> > - Why you couldn't set memory.high or memory.max to 0 after the
> >    application quits and before you call rmdir on the cgroup
> 
> I recall I explained this in the review email for the first version. Set
> memory.high or memory.max to 0 would trigger direct reclaim which may stall
> the offline of memcg. But, we have "restarting the same name job" logic in
> our usecase (I'm not quite sure why they do so). Basically, it means to
> create memcg with the exact same name right after the old one is deleted,
> but may have different limit or other settings. The creation has to wait for
> rmdir is done.

This really needs a fix on your end. We cannot add new cgroup control
files because you cannot handle a delayed release in the cgroupfs
namespace while you're reclaiming associated memory. A simple serial
number would fix this.

Whether others have asked for this knob or not, these patches should
come with a solid case in the cover letter and changelogs that explain
why this ABI is necessary to solve a generic cgroup usecase. But it
sounds to me that setting the limit to 0 once the group is empty would
meet the functional requirement (use fork() if you don't want to wait)
of what you are trying to do.

I don't think the new interface bar is met here.
