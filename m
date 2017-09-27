Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 953026B0038
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 14:12:05 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f3so19481142oia.4
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 11:12:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 124sor4396927oih.40.2017.09.27.11.12.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Sep 2017 11:12:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170927162300.GA5623@castle.DHCP.thefacebook.com>
References: <20170925181533.GA15918@castle> <20170925202442.lmcmvqwy2jj2tr5h@dhcp22.suse.cz>
 <20170926105925.GA23139@castle.dhcp.TheFacebook.com> <20170926112134.r5eunanjy7ogjg5n@dhcp22.suse.cz>
 <20170926121300.GB23139@castle.dhcp.TheFacebook.com> <20170926133040.uupv3ibkt3jtbotf@dhcp22.suse.cz>
 <20170926172610.GA26694@cmpxchg.org> <CAAAKZws88uF2dVrXwRV0V6AH5X68rWy7AfJxTxYjpuiyiNJFWA@mail.gmail.com>
 <20170927074319.o3k26kja43rfqmvb@dhcp22.suse.cz> <CAAAKZws2CFExeg6A9AzrGjiHnFHU1h2xdk6J5Jw2kqxy=V+_YQ@mail.gmail.com>
 <20170927162300.GA5623@castle.DHCP.thefacebook.com>
From: Tim Hockin <thockin@hockin.org>
Date: Wed, 27 Sep 2017 11:11:42 -0700
Message-ID: <CAAAKZwtApj-FgRc2V77nEb3BUd97Rwhgf-b-k0zhf1u+Y4fqxA@mail.gmail.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Sep 27, 2017 at 9:23 AM, Roman Gushchin <guro@fb.com> wrote:
> On Wed, Sep 27, 2017 at 08:35:50AM -0700, Tim Hockin wrote:
>> On Wed, Sep 27, 2017 at 12:43 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Tue 26-09-17 20:37:37, Tim Hockin wrote:
>> > [...]
>> >> I feel like David has offered examples here, and many of us at Google
>> >> have offered examples as long ago as 2013 (if I recall) of cases where
>> >> the proposed heuristic is EXACTLY WRONG.
>> >
>> > I do not think we have discussed anything resembling the current
>> > approach. And I would really appreciate some more examples where
>> > decisions based on leaf nodes would be EXACTLY WRONG.
>> >
>> >> We need OOM behavior to kill in a deterministic order configured by
>> >> policy.
>> >
>> > And nobody is objecting to this usecase. I think we can build a priority
>> > policy on top of leaf-based decision as well. The main point we are
>> > trying to sort out here is a reasonable semantic that would work for
>> > most workloads. Sibling based selection will simply not work on those
>> > that have to use deeper hierarchies for organizational purposes. I
>> > haven't heard a counter argument for that example yet.
>>
>
> Hi, Tim!
>
>> We have a priority-based, multi-user cluster.  That cluster runs a
>> variety of work, including critical things like search and gmail, as
>> well as non-critical things like batch work.  We try to offer our
>> users an SLA around how often they will be killed by factors outside
>> themselves, but we also want to get higher utilization.  We know for a
>> fact (data, lots of data) that most jobs have spare memory capacity,
>> set aside for spikes or simply because accurate sizing is hard.  We
>> can sell "guaranteed" resources to critical jobs, with a high SLA.  We
>> can sell "best effort" resources to non-critical jobs with a low SLA.
>> We achieve much better overall utilization this way.
>
> This is well understood.
>
>>
>> I need to represent the priority of these tasks in a way that gives me
>> a very strong promise that, in case of system OOM, the non-critical
>> jobs will be chosen before the critical jobs.  Regardless of size.
>> Regardless of how many non-critical jobs have to die.  I'd rather kill
>> *all* of the non-critical jobs than a single critical job.  Size of
>> the process or cgroup is simply not a factor, and honestly given 2
>> options of equal priority I'd say age matters more than size.
>>
>> So concretely I have 2 first-level cgroups, one for "guaranteed" and
>> one for "best effort" classes.  I always want to kill from "best
>> effort", even if that means killing 100 small cgroups, before touching
>> "guaranteed".
>>
>> I apologize if this is not as thorough as the rest of the thread - I
>> am somewhat out of touch with the guts of it all these days.  I just
>> feel compelled to indicate that, as a historical user (via Google
>> systems) and current user (via Kubernetes), some of the assertions
>> being made here do not ring true for our very real use cases.  I
>> desperately want cgroup-aware OOM handing, but it has to be
>> policy-based or it is just not useful to us.
>
> A policy-based approach was suggested by Michal at a very beginning of
> this discussion. Although nobody had any strong objections against it,
> we've agreed that this is out of scope of this patchset.
>
> The idea of this patchset is to introduce an ability to select a memcg
> as an OOM victim with the following optional killing of all belonging tasks.
> I believe, it's absolutely mandatory for _any_ further development
> of the OOM killer, which wants to deal with memory cgroups as OOM entities.
>
> If you think that it makes impossible to support some use cases in the future,
> let's discuss it. Otherwise, I'd prefer to finish this part of the work,
> and proceed to the following improvements on top of it.
>
> Thank you!

I am 100% in favor of killing whole groups.  We want that too.  I just
needed to express disagreement with statements that size-based
decisions could not produce bad results.  They can and do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
