Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0EE126B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 19:40:52 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id r10-v6so6821528itc.2
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 16:40:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d124-v6sor1723975iog.305.2018.07.27.16.40.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Jul 2018 16:40:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180726200718.GA23307@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org> <CAKTCnzmt_CnfZMMdK9_-rBrL4kUmoE70nVbnE58CJp++FP0CCQ@mail.gmail.com>
 <20180724151519.GA11598@cmpxchg.org> <268c2b08-6c90-de2b-d693-1270bb186713@gmail.com>
 <20180726200718.GA23307@cmpxchg.org>
From: Suren Baghdasaryan <surenb@google.com>
Date: Fri, 27 Jul 2018 16:40:49 -0700
Message-ID: <CAJuCfpEkCD3b+3T4R1TbyTMSajCv3_TXX64TYy7WRgt8tu3TTA@mail.gmail.com>
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory, and
 IO v2
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Singh, Balbir" <bsingharora@gmail.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Vinayak Menon <vinmenon@codeaurora.org>, Christoph Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm <linux-mm@kvack.org>, cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kernel-team@fb.com

On Thu, Jul 26, 2018 at 1:07 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Thu, Jul 26, 2018 at 11:07:32AM +1000, Singh, Balbir wrote:
>> On 7/25/18 1:15 AM, Johannes Weiner wrote:
>> > On Tue, Jul 24, 2018 at 07:14:02AM +1000, Balbir Singh wrote:
>> >> Does the mechanism scale? I am a little concerned about how frequently
>> >> this infrastructure is monitored/read/acted upon.
>> >
>> > I expect most users to poll in the frequency ballpark of the running
>> > averages (10s, 1m, 5m). Our OOMD defaults to 5s polling of the 10s
>> > average; we collect the 1m average once per minute from our machines
>> > and cgroups to log the system/workload health trends in our fleet.
>> >
>> > Suren has been experimenting with adaptive polling down to the
>> > millisecond range on Android.
>> >
>>
>> I think this is a bad way of doing things, polling only adds to
>> overheads, there needs to be an event driven mechanism and the
>> selection of the events need to happen in user space.
>
> Of course, I'm not saying you should be doing this, and in fact Suren
> and I were talking about notification/event infrastructure.

I implemented a psi-monitor prototype which allows userspace to
specify the max PSI stall it can tolerate (in terms of % of time spent
on memory management). When that threshold is breached an event to
userspace is generated. I'm still testing it but early results look
promising. I'm planning to send it upstream when it's ready and after
the main PSI patchset is merged.

>
> You asked if this scales and I'm telling you it's not impossible to
> read at such frequencies.
>

Yes it's doable. One usecase might be to poll at a higher rate for a
short period of time immediately after the initial event is received
to clarify the short-term signal dynamics.

> Maybe you can clarify your question.
>
>> >> Why aren't existing mechanisms sufficient
>> >
>> > Our existing stuff gives a lot of indication when something *may* be
>> > an issue, like the rate of page reclaim, the number of refaults, the
>> > average number of active processes, one task waiting on a resource.
>> >
>> > But the real difference between an issue and a non-issue is how much
>> > it affects your overall goal of making forward progress or reacting to
>> > a request in time. And that's the only thing users really care
>> > about. It doesn't matter whether my system is doing 2314 or 6723 page
>> > refaults per minute, or scanned 8495 pages recently. I need to know
>> > whether I'm losing 1% or 20% of my time on overcommitted memory.
>> >
>> > Delayacct is time-based, so it's a step in the right direction, but it
>> > doesn't aggregate tasks and CPUs into compound productivity states to
>> > tell you if only parts of your workload are seeing delays (which is
>> > often tolerable for the purpose of ensuring maximum HW utilization) or
>> > your system overall is not making forward progress. That aggregation
>> > isn't something you can do in userspace with polled delayacct data.
>>
>> By aggregation you mean cgroup aggregation?
>
> System-wide and per cgroup.
