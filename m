Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D58326B0006
	for <linux-mm@kvack.org>; Wed, 30 May 2018 19:32:54 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 201-v6so10442739itj.4
        for <linux-mm@kvack.org>; Wed, 30 May 2018 16:32:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w19-v6sor7979277ioc.87.2018.05.30.16.32.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 May 2018 16:32:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180529181616.GB28689@cmpxchg.org>
References: <20180507210135.1823-1-hannes@cmpxchg.org> <CAJuCfpF4q+1aSg4WQn_p-1-zEDhh-iqST6dc1DkxnDofSPBKGw@mail.gmail.com>
 <20180529181616.GB28689@cmpxchg.org>
From: Suren Baghdasaryan <surenb@google.com>
Date: Wed, 30 May 2018 16:32:52 -0700
Message-ID: <CAJuCfpGXSyu3SOky6jMhKjix=bbaPccg05VcepbvuJiv+bQgzw@mail.gmail.com>
Subject: Re: [PATCH 0/7] psi: pressure stall information for CPU, memory, and IO
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Tue, May 29, 2018 at 11:16 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Hi Suren,
>
> On Fri, May 25, 2018 at 05:29:30PM -0700, Suren Baghdasaryan wrote:
>> Hi Johannes,
>> I tried your previous memdelay patches before this new set was posted
>> and results were promising for predicting when Android system is close
>> to OOM. I'm definitely going to try this one after I backport it to
>> 4.9.
>
> I'm happy to hear that!
>
>> Would it make sense to split CONFIG_PSI into CONFIG_PSI_CPU,
>> CONFIG_PSI_MEM and CONFIG_PSI_IO since one might need only specific
>> subset of this feature?
>
> Yes, that should be doable. I'll split them out in the next version.
>
>> > The total= value gives the absolute stall time in microseconds. This
>> > allows detecting latency spikes that might be too short to sway the
>> > running averages. It also allows custom time averaging in case the
>> > 10s/1m/5m windows aren't adequate for the usecase (or are too coarse
>> > with future hardware).
>>
>> Any reasons these specific windows were chosen (empirical
>> data/historical reasons)? I'm worried that with the smallest window
>> being 10s the signal might be too inert to detect fast memory pressure
>> buildup before OOM kill happens. I'll have to experiment with that
>> first, however if you have some insights into this already please
>> share them.
>
> They were chosen empirically. We started out with the loadavg window
> sizes, but had to reduce them for exactly the reason you mention -
> they're way too coarse to detect acute pressure buildup.
>
> 10s has been working well for us. We could make it smaller, but there
> is some worry that we don't have enough samples then and the average
> becomes too erratic - whereas monitoring total= directly would allow
> you to detect accute spikes and handle this erraticness explicitly.

Unfortunately total= field is now updated only at 2sec intervals which
might be too late to react to mounting memory pressure. With previous
memdelay patchset md->aggregate which is reported as "total" was
calculated directly from inside memdelay_task_change, so it was always
up-to-date. Now group->some and group->full are updated from inside
psi_clock with up to 2sec delay. This prevents us from detecting these
acute pressure spikes immediately. I understand why you moved these
calculations out of the hot path but maybe we could keep updating
"total" inside psi_group_update? This would allow for custom averaging
and eliminate this delay for detecting spikes in the pressure signal.
More conceptually I would love to have a way to monitor the averages
at a slow rate and when they rise and cross some threshold to increase
the monitoring rate and react quickly in case they shoot up. Current
2sec delay poses a problem for doing that.

>
> Let me know how it works out in your tests.

I've done the backporting to 4.9 and running the tests but the 2sec
delay is problematic for getting a detailed look at the signal and its
usefulness. Thinking about workarounds if only for data collection but
don't want to deviate too much from your baseline. Would love to hear
from you if a good compromise can be reached here.

>
> Thanks for your feedback.
