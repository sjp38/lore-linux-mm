Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id E707E8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 14:01:04 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id f10so25792ywc.21
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 11:01:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 23sor229667ywq.112.2019.01.14.11.01.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 11:01:03 -0800 (PST)
Date: Mon, 14 Jan 2019 14:01:00 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC v3 PATCH 0/5] mm: memcontrol: do memory reclaim when
 offlining
Message-ID: <20190114190100.GA8745@cmpxchg.org>
References: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190109193247.GA16319@cmpxchg.org>
 <d92912c7-511e-2ab5-39a6-38af3209fcaf@linux.alibaba.com>
 <20190109212334.GA18978@cmpxchg.org>
 <9de4bb4a-6bb7-e13a-0d9a-c1306e1b3e60@linux.alibaba.com>
 <20190109225143.GA22252@cmpxchg.org>
 <99843dad-608d-10cc-c28f-e5e63a793361@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <99843dad-608d-10cc-c28f-e5e63a793361@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@suse.com, shakeelb@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 09, 2019 at 05:47:41PM -0800, Yang Shi wrote:
> On 1/9/19 2:51 PM, Johannes Weiner wrote:
> > On Wed, Jan 09, 2019 at 02:09:20PM -0800, Yang Shi wrote:
> > > On 1/9/19 1:23 PM, Johannes Weiner wrote:
> > > > On Wed, Jan 09, 2019 at 12:36:11PM -0800, Yang Shi wrote:
> > > > > As I mentioned above, if we know some page caches from some memcgs
> > > > > are referenced one-off and unlikely shared, why just keep them
> > > > > around to increase memory pressure?
> > > > It's just not clear to me that your scenarios are generic enough to
> > > > justify adding two interfaces that we have to maintain forever, and
> > > > that they couldn't be solved with existing mechanisms.
> > > > 
> > > > Please explain:
> > > > 
> > > > - Unmapped clean page cache isn't expensive to reclaim, certainly
> > > >     cheaper than the IO involved in new application startup. How could
> > > >     recycling clean cache be a prohibitive part of workload warmup?
> > > It is nothing about recycling. Those page caches might be referenced by
> > > memcg just once, then nobody touch them until memory pressure is hit. And,
> > > they might be not accessed again at any time soon.
> > I meant recycling the page frames, not the cache in them. So the new
> > workload as it starts up needs to take those pages from the LRU list
> > instead of just the allocator freelist. While that's obviously not the
> > same cost, it's not clear why the difference would be prohibitive to
> > application startup especially since app startup tends to be dominated
> > by things like IO to fault in executables etc.
> 
> I'm a little bit confused here. Even though those page frames are not
> reclaimed by force_empty, they would be reclaimed by kswapd later when
> memory pressure is hit. For some usecases, they may prefer get recycled
> before kswapd kick them out LRU, but for some usecases avoiding memory
> pressure might outpace page frame recycling.

I understand that, but you're not providing data for the "may prefer"
part. You haven't shown that any proactive reclaim actually matters
and is a significant net improvement to a real workload in a real
hardware environment, and that the usecase is generic and widespread
enough to warrant an entirely new kernel interface.

> > > > - Why you couldn't set memory.high or memory.max to 0 after the
> > > >     application quits and before you call rmdir on the cgroup
> > > I recall I explained this in the review email for the first version. Set
> > > memory.high or memory.max to 0 would trigger direct reclaim which may stall
> > > the offline of memcg. But, we have "restarting the same name job" logic in
> > > our usecase (I'm not quite sure why they do so). Basically, it means to
> > > create memcg with the exact same name right after the old one is deleted,
> > > but may have different limit or other settings. The creation has to wait for
> > > rmdir is done.
> > This really needs a fix on your end. We cannot add new cgroup control
> > files because you cannot handle a delayed release in the cgroupfs
> > namespace while you're reclaiming associated memory. A simple serial
> > number would fix this.
> > 
> > Whether others have asked for this knob or not, these patches should
> > come with a solid case in the cover letter and changelogs that explain
> > why this ABI is necessary to solve a generic cgroup usecase. But it
> > sounds to me that setting the limit to 0 once the group is empty would
> > meet the functional requirement (use fork() if you don't want to wait)
> > of what you are trying to do.
> 
> Do you mean do something like the below:
> 
> echo 0 > cg1/memory.max &
> rmdir cg1 &
> mkdir cg1 &
>
> But, the latency is still there, even though memcg creation (mkdir) can be
> done very fast by using fork(), the latency would delay afterwards
> operations, i.e. attaching tasks (echo PID > cg1/cgroup.procs). When we
> calculating the time consumption of the container deployment, we would count
> from mkdir to the job is actually launched.

I'm saying that the same-name requirement is your problem, not the
kernel's. It's not unreasonable for the kernel to say that as long as
you want to do something with the cgroup, such as forcibly emptying
out the left-over cache, that the group name stays in the namespace.

Requiring the same exact cgroup name for another instance of the same
job sounds like a bogus requirement. Surely you can use serial numbers
to denote subsequent invocations of the same job and handle that from
whatever job management software you're using:

	( echo 0 > job1345-1/memory.max; rmdir job12345-1 ) &
	mkdir job12345-2

See, completely decoupled.
