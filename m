Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5735C6B0003
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 16:04:32 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id u1-v6so1407817ywg.6
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:04:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b14-v6sor599796ybm.84.2018.07.26.13.04.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Jul 2018 13:04:28 -0700 (PDT)
Date: Thu, 26 Jul 2018 16:07:18 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory,
 and IO v2
Message-ID: <20180726200718.GA23307@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <CAKTCnzmt_CnfZMMdK9_-rBrL4kUmoE70nVbnE58CJp++FP0CCQ@mail.gmail.com>
 <20180724151519.GA11598@cmpxchg.org>
 <268c2b08-6c90-de2b-d693-1270bb186713@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <268c2b08-6c90-de2b-d693-1270bb186713@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Singh, Balbir" <bsingharora@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, surenb@google.com, Vinayak Menon <vinmenon@codeaurora.org>, Christoph Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm <linux-mm@kvack.org>, cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kernel-team@fb.com

On Thu, Jul 26, 2018 at 11:07:32AM +1000, Singh, Balbir wrote:
> On 7/25/18 1:15 AM, Johannes Weiner wrote:
> > On Tue, Jul 24, 2018 at 07:14:02AM +1000, Balbir Singh wrote:
> >> Does the mechanism scale? I am a little concerned about how frequently
> >> this infrastructure is monitored/read/acted upon.
> > 
> > I expect most users to poll in the frequency ballpark of the running
> > averages (10s, 1m, 5m). Our OOMD defaults to 5s polling of the 10s
> > average; we collect the 1m average once per minute from our machines
> > and cgroups to log the system/workload health trends in our fleet.
> > 
> > Suren has been experimenting with adaptive polling down to the
> > millisecond range on Android.
> > 
> 
> I think this is a bad way of doing things, polling only adds to
> overheads, there needs to be an event driven mechanism and the
> selection of the events need to happen in user space.

Of course, I'm not saying you should be doing this, and in fact Suren
and I were talking about notification/event infrastructure.

You asked if this scales and I'm telling you it's not impossible to
read at such frequencies.

Maybe you can clarify your question.

> >> Why aren't existing mechanisms sufficient
> > 
> > Our existing stuff gives a lot of indication when something *may* be
> > an issue, like the rate of page reclaim, the number of refaults, the
> > average number of active processes, one task waiting on a resource.
> > 
> > But the real difference between an issue and a non-issue is how much
> > it affects your overall goal of making forward progress or reacting to
> > a request in time. And that's the only thing users really care
> > about. It doesn't matter whether my system is doing 2314 or 6723 page
> > refaults per minute, or scanned 8495 pages recently. I need to know
> > whether I'm losing 1% or 20% of my time on overcommitted memory.
> > 
> > Delayacct is time-based, so it's a step in the right direction, but it
> > doesn't aggregate tasks and CPUs into compound productivity states to
> > tell you if only parts of your workload are seeing delays (which is
> > often tolerable for the purpose of ensuring maximum HW utilization) or
> > your system overall is not making forward progress. That aggregation
> > isn't something you can do in userspace with polled delayacct data.
> 
> By aggregation you mean cgroup aggregation?

System-wide and per cgroup.
