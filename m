Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D99B6B0006
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 21:07:44 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id az8-v6so29381plb.15
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 18:07:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y4-v6sor4270986pgy.326.2018.07.25.18.07.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 18:07:40 -0700 (PDT)
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory, and
 IO v2
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <CAKTCnzmt_CnfZMMdK9_-rBrL4kUmoE70nVbnE58CJp++FP0CCQ@mail.gmail.com>
 <20180724151519.GA11598@cmpxchg.org>
From: "Singh, Balbir" <bsingharora@gmail.com>
Message-ID: <268c2b08-6c90-de2b-d693-1270bb186713@gmail.com>
Date: Thu, 26 Jul 2018 11:07:32 +1000
MIME-Version: 1.0
In-Reply-To: <20180724151519.GA11598@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, surenb@google.com, Vinayak Menon <vinmenon@codeaurora.org>, Christoph Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm <linux-mm@kvack.org>, cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kernel-team@fb.com



On 7/25/18 1:15 AM, Johannes Weiner wrote:
> Hi Balbir,
> 
> On Tue, Jul 24, 2018 at 07:14:02AM +1000, Balbir Singh wrote:
>> Does the mechanism scale? I am a little concerned about how frequently
>> this infrastructure is monitored/read/acted upon.
> 
> I expect most users to poll in the frequency ballpark of the running
> averages (10s, 1m, 5m). Our OOMD defaults to 5s polling of the 10s
> average; we collect the 1m average once per minute from our machines
> and cgroups to log the system/workload health trends in our fleet.
> 
> Suren has been experimenting with adaptive polling down to the
> millisecond range on Android.
> 

I think this is a bad way of doing things, polling only adds to overheads, there needs to be an event driven mechanism and the selection of the events need to happen in user space.

>> Why aren't existing mechanisms sufficient
> 
> Our existing stuff gives a lot of indication when something *may* be
> an issue, like the rate of page reclaim, the number of refaults, the
> average number of active processes, one task waiting on a resource.
> 
> But the real difference between an issue and a non-issue is how much
> it affects your overall goal of making forward progress or reacting to
> a request in time. And that's the only thing users really care
> about. It doesn't matter whether my system is doing 2314 or 6723 page
> refaults per minute, or scanned 8495 pages recently. I need to know
> whether I'm losing 1% or 20% of my time on overcommitted memory.
> 
> Delayacct is time-based, so it's a step in the right direction, but it
> doesn't aggregate tasks and CPUs into compound productivity states to
> tell you if only parts of your workload are seeing delays (which is
> often tolerable for the purpose of ensuring maximum HW utilization) or
> your system overall is not making forward progress. That aggregation
> isn't something you can do in userspace with polled delayacct data.

By aggregation you mean cgroup aggregation?

> 
>> -- why is the avg delay calculation in the kernel?
> 
> For one, as per above, most users will probably be using the standard
> averaging windows, and we already have this highly optimizd
> infrastructure from the load average. I don't see why we shouldn't use
> that instead of exporting an obscure number that requires most users
> to have an additional library or copy-paste the loadavg code.
> 
> I also mentioned the OOM killer as a likely in-kernel user of the
> pressure percentages to protect from memory livelocks out of the box,
> in which case we have to do this calculation in the kernel anyway.
> 
>> There is no talk about the overhead this introduces in general, may be
>> the details are in the patches. I'll read through them
> 
> I sent an email on benchmarks and overhead in one of the subthreads, I
> will include that information in the cover letter in v3.
> 
> https://lore.kernel.org/lkml/20180718215644.GB2838@cmpxchg.org/

Thanks, I'll take a look

Balbir Singh.
