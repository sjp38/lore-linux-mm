Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0B0C56B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 23:38:01 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id l74so16363859oih.5
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 20:38:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v31sor1253939ota.98.2017.09.26.20.37.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Sep 2017 20:37:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170926172610.GA26694@cmpxchg.org>
References: <20170918061405.pcrf5vauvul4c2nr@dhcp22.suse.cz>
 <20170920215341.GA5382@castle> <20170925122400.4e7jh5zmuzvbggpe@dhcp22.suse.cz>
 <20170925170004.GA22704@cmpxchg.org> <20170925181533.GA15918@castle>
 <20170925202442.lmcmvqwy2jj2tr5h@dhcp22.suse.cz> <20170926105925.GA23139@castle.dhcp.TheFacebook.com>
 <20170926112134.r5eunanjy7ogjg5n@dhcp22.suse.cz> <20170926121300.GB23139@castle.dhcp.TheFacebook.com>
 <20170926133040.uupv3ibkt3jtbotf@dhcp22.suse.cz> <20170926172610.GA26694@cmpxchg.org>
From: Tim Hockin <thockin@hockin.org>
Date: Tue, 26 Sep 2017 20:37:37 -0700
Message-ID: <CAAAKZws88uF2dVrXwRV0V6AH5X68rWy7AfJxTxYjpuiyiNJFWA@mail.gmail.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

I'm excited to see this being discussed again - it's been years since
the last attempt.  I've tried to stay out of the conversation, but I
feel obligated say something and then go back to lurking.

On Tue, Sep 26, 2017 at 10:26 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Tue, Sep 26, 2017 at 03:30:40PM +0200, Michal Hocko wrote:
>> On Tue 26-09-17 13:13:00, Roman Gushchin wrote:
>> > On Tue, Sep 26, 2017 at 01:21:34PM +0200, Michal Hocko wrote:
>> > > On Tue 26-09-17 11:59:25, Roman Gushchin wrote:
>> > > > On Mon, Sep 25, 2017 at 10:25:21PM +0200, Michal Hocko wrote:
>> > > > > On Mon 25-09-17 19:15:33, Roman Gushchin wrote:
>> > > > > [...]
>> > > > > > I'm not against this model, as I've said before. It feels logical,
>> > > > > > and will work fine in most cases.
>> > > > > >
>> > > > > > In this case we can drop any mount/boot options, because it preserves
>> > > > > > the existing behavior in the default configuration. A big advantage.
>> > > > >
>> > > > > I am not sure about this. We still need an opt-in, ragardless, because
>> > > > > selecting the largest process from the largest memcg != selecting the
>> > > > > largest task (just consider memcgs with many processes example).
>> > > >
>> > > > As I understand Johannes, he suggested to compare individual processes with
>> > > > group_oom mem cgroups. In other words, always select a killable entity with
>> > > > the biggest memory footprint.
>> > > >
>> > > > This is slightly different from my v8 approach, where I treat leaf memcgs
>> > > > as indivisible memory consumers independent on group_oom setting, so
>> > > > by default I'm selecting the biggest task in the biggest memcg.
>> > >
>> > > My reading is that he is actually proposing the same thing I've been
>> > > mentioning. Simply select the biggest killable entity (leaf memcg or
>> > > group_oom hierarchy) and either kill the largest task in that entity
>> > > (for !group_oom) or the whole memcg/hierarchy otherwise.
>> >
>> > He wrote the following:
>> > "So I'm leaning toward the second model: compare all oomgroups and
>> > standalone tasks in the system with each other, independent of the
>> > failed hierarchical control structure. Then kill the biggest of them."
>>
>> I will let Johannes to comment but I believe this is just a
>> misunderstanding. If we compared only the biggest task from each memcg
>> then we are basically losing our fairness objective, aren't we?
>
> Sorry about the confusion.
>
> Yeah I was making the case for what Michal proposed, to kill the
> biggest terminal consumer, which is either a task or an oomgroup.
>
> You'd basically iterate through all the tasks and cgroups in the
> system and pick the biggest task that isn't in an oom group or the
> biggest oom group and then kill that.
>
> Yeah, you'd have to compare the memory footprints of tasks with the
> memory footprints of cgroups. These aren't defined identically, and
> tasks don't get attributed every type of allocation that a cgroup
> would. But it should get us in the ballpark, and I cannot picture a
> scenario where this would lead to a completely undesirable outcome.

That last sentence:

> I cannot picture a scenario where this would lead to a completely undesirable outcome.

I feel like David has offered examples here, and many of us at Google
have offered examples as long ago as 2013 (if I recall) of cases where
the proposed heuristic is EXACTLY WRONG.  We need OOM behavior to kill
in a deterministic order configured by policy.  Sometimes, I would
literally prefer to kill every other cgroup before killing "the big
one".  The policy is *all* that matters for shared clusters of varying
users and priorities.

We did this in Borg, and it works REALLY well.  Has for years.  Now
that the world is adopting Kubernetes we need it again, only it's much
harder to carry a kernel patch in this case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
