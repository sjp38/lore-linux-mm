Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 139EA8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 17:55:40 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id r145so10005640qke.20
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 14:55:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z9sor44210221qka.72.2019.01.17.14.55.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 14:55:38 -0800 (PST)
MIME-Version: 1.0
References: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190109193247.GA16319@cmpxchg.org> <d92912c7-511e-2ab5-39a6-38af3209fcaf@linux.alibaba.com>
 <20190109212334.GA18978@cmpxchg.org> <9de4bb4a-6bb7-e13a-0d9a-c1306e1b3e60@linux.alibaba.com>
 <20190109225143.GA22252@cmpxchg.org> <99843dad-608d-10cc-c28f-e5e63a793361@linux.alibaba.com>
 <20190114190100.GA8745@cmpxchg.org>
In-Reply-To: <20190114190100.GA8745@cmpxchg.org>
From: Yang Shi <shy828301@gmail.com>
Date: Thu, 17 Jan 2019 14:55:25 -0800
Message-ID: <CAHbLzko=VWTmJWkveFCw42h1v0DTswwtSucAuNAZe0iAAhbJqA@mail.gmail.com>
Subject: Re: [RFC v3 PATCH 0/5] mm: memcontrol: do memory reclaim when offlining
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@suse.com>, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Not sure if you guys received my yesterday's reply or not. I sent
twice, but both got bounced back. Maybe my company email server has
some problems. So, I sent this with my personal email.


On Mon, Jan 14, 2019 at 11:01 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
&gt;
&gt; On Wed, Jan 09, 2019 at 05:47:41PM -0800, Yang Shi wrote:
&gt; &gt; On 1/9/19 2:51 PM, Johannes Weiner wrote:
&gt; &gt; &gt; On Wed, Jan 09, 2019 at 02:09:20PM -0800, Yang Shi wrote:
&gt; &gt; &gt; &gt; On 1/9/19 1:23 PM, Johannes Weiner wrote:
&gt; &gt; &gt; &gt; &gt; On Wed, Jan 09, 2019 at 12:36:11PM -0800,
Yang Shi wrote:
&gt; &gt; &gt; &gt; &gt; &gt; As I mentioned above, if we know some
page caches from some memcgs
&gt; &gt; &gt; &gt; &gt; &gt; are referenced one-off and unlikely
shared, why just keep them
&gt; &gt; &gt; &gt; &gt; &gt; around to increase memory pressure?
&gt; &gt; &gt; &gt; &gt; It's just not clear to me that your scenarios
are generic enough to
&gt; &gt; &gt; &gt; &gt; justify adding two interfaces that we have to
maintain forever, and
&gt; &gt; &gt; &gt; &gt; that they couldn't be solved with existing mechanisms.
&gt; &gt; &gt; &gt; &gt;
&gt; &gt; &gt; &gt; &gt; Please explain:
&gt; &gt; &gt; &gt; &gt;
&gt; &gt; &gt; &gt; &gt; - Unmapped clean page cache isn't expensive
to reclaim, certainly
&gt; &gt; &gt; &gt; &gt;     cheaper than the IO involved in new
application startup. How could
&gt; &gt; &gt; &gt; &gt;     recycling clean cache be a prohibitive
part of workload warmup?
&gt; &gt; &gt; &gt; It is nothing about recycling. Those page caches
might be referenced by
&gt; &gt; &gt; &gt; memcg just once, then nobody touch them until
memory pressure is hit. And,
&gt; &gt; &gt; &gt; they might be not accessed again at any time soon.
&gt; &gt; &gt; I meant recycling the page frames, not the cache in
them. So the new
&gt; &gt; &gt; workload as it starts up needs to take those pages from
the LRU list
&gt; &gt; &gt; instead of just the allocator freelist. While that's
obviously not the
&gt; &gt; &gt; same cost, it's not clear why the difference would be
prohibitive to
&gt; &gt; &gt; application startup especially since app startup tends
to be dominated
&gt; &gt; &gt; by things like IO to fault in executables etc.
&gt; &gt;
&gt; &gt; I'm a little bit confused here. Even though those page frames are not
&gt; &gt; reclaimed by force_empty, they would be reclaimed by kswapd later when
&gt; &gt; memory pressure is hit. For some usecases, they may prefer
get recycled
&gt; &gt; before kswapd kick them out LRU, but for some usecases avoiding memory
&gt; &gt; pressure might outpace page frame recycling.
&gt;
&gt; I understand that, but you're not providing data for the "may prefer"
&gt; part. You haven't shown that any proactive reclaim actually matters
&gt; and is a significant net improvement to a real workload in a real
&gt; hardware environment, and that the usecase is generic and widespread
&gt; enough to warrant an entirely new kernel interface.

Proactive reclaim could prevent from getting offline memcgs
accumulated. In our production environment, we saw offline memcgs
could reach over 450K (just a few hundred online memcgs) in some
cases. kswapd is supposed to help to remove offline memcgs when memory
pressure hit, but with such huge number of offline memcgs, kswapd
would take very long time to iterate all of them. Such huge number of
offline memcgs could bring in other latency problems whenever
iterating memcgs is needed, i.e. show memory.stat, direct reclaim,
oom, etc.

So, we also use force_empty to keep reasonable number of offline memcgs.

And, Fam Zheng from Bytedance noticed delayed force_empty gets things
done more effectively. Please see the discussion here
https://www.spinics.net/lists/cgroups/msg21259.html

Thanks,
Yang

</hannes@cmpxchg.org>>
> > > > > - Why you couldn't set memory.high or memory.max to 0 after the
> > > > >     application quits and before you call rmdir on the cgroup
> > > > I recall I explained this in the review email for the first version. Set
> > > > memory.high or memory.max to 0 would trigger direct reclaim which may stall
> > > > the offline of memcg. But, we have "restarting the same name job" logic in
> > > > our usecase (I'm not quite sure why they do so). Basically, it means to
> > > > create memcg with the exact same name right after the old one is deleted,
> > > > but may have different limit or other settings. The creation has to wait for
> > > > rmdir is done.
> > > This really needs a fix on your end. We cannot add new cgroup control
> > > files because you cannot handle a delayed release in the cgroupfs
> > > namespace while you're reclaiming associated memory. A simple serial
> > > number would fix this.
> > >
> > > Whether others have asked for this knob or not, these patches should
> > > come with a solid case in the cover letter and changelogs that explain
> > > why this ABI is necessary to solve a generic cgroup usecase. But it
> > > sounds to me that setting the limit to 0 once the group is empty would
> > > meet the functional requirement (use fork() if you don't want to wait)
> > > of what you are trying to do.
> >
> > Do you mean do something like the below:
> >
> > echo 0 > cg1/memory.max &
> > rmdir cg1 &
> > mkdir cg1 &
> >
> > But, the latency is still there, even though memcg creation (mkdir) can be
> > done very fast by using fork(), the latency would delay afterwards
> > operations, i.e. attaching tasks (echo PID > cg1/cgroup.procs). When we
> > calculating the time consumption of the container deployment, we would count
> > from mkdir to the job is actually launched.
>
> I'm saying that the same-name requirement is your problem, not the
> kernel's. It's not unreasonable for the kernel to say that as long as
> you want to do something with the cgroup, such as forcibly emptying
> out the left-over cache, that the group name stays in the namespace.
>
> Requiring the same exact cgroup name for another instance of the same
> job sounds like a bogus requirement. Surely you can use serial numbers
> to denote subsequent invocations of the same job and handle that from
> whatever job management software you're using:
>
>         ( echo 0 > job1345-1/memory.max; rmdir job12345-1 ) &
>         mkdir job12345-2
>
> See, completely decoupled.
>
