Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6F96C6B4DCF
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 17:30:29 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id l2-v6so3192351ywb.6
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 14:30:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b186-v6sor1278626ybg.35.2018.08.29.14.30.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 14:30:28 -0700 (PDT)
MIME-Version: 1.0
References: <20180821213559.14694-1-guro@fb.com> <CALvZod4HAf+iPXQx1v+dwJkTph3ySAiYo4kn4d2jRFNQS59Tgg@mail.gmail.com>
 <20180829212422.GA13097@castle>
In-Reply-To: <20180829212422.GA13097@castle>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 29 Aug 2018 14:30:16 -0700
Message-ID: <CALvZod5_kMtsiQqdEmktL3zMEf_3LL+_1khdr+TST2vFTChiVA@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] mm: rework memcg kernel stack accounting
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, luto@kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>

On Wed, Aug 29, 2018 at 2:24 PM Roman Gushchin <guro@fb.com> wrote:
>
> On Tue, Aug 21, 2018 at 03:10:52PM -0700, Shakeel Butt wrote:
> > On Tue, Aug 21, 2018 at 2:36 PM Roman Gushchin <guro@fb.com> wrote:
> > >
> > > If CONFIG_VMAP_STACK is set, kernel stacks are allocated
> > > using __vmalloc_node_range() with __GFP_ACCOUNT. So kernel
> > > stack pages are charged against corresponding memory cgroups
> > > on allocation and uncharged on releasing them.
> > >
> > > The problem is that we do cache kernel stacks in small
> > > per-cpu caches and do reuse them for new tasks, which can
> > > belong to different memory cgroups.
> > >
> > > Each stack page still holds a reference to the original cgroup,
> > > so the cgroup can't be released until the vmap area is released.
> > >
> > > To make this happen we need more than two subsequent exits
> > > without forks in between on the current cpu, which makes it
> > > very unlikely to happen. As a result, I saw a significant number
> > > of dying cgroups (in theory, up to 2 * number_of_cpu +
> > > number_of_tasks), which can't be released even by significant
> > > memory pressure.
> > >
> > > As a cgroup structure can take a significant amount of memory
> > > (first of all, per-cpu data like memcg statistics), it leads
> > > to a noticeable waste of memory.
> > >
> > > Signed-off-by: Roman Gushchin <guro@fb.com>
> >
> > Reviewed-by: Shakeel Butt <shakeelb@google.com>
> >
> > BTW this makes a very good use-case for optimizing kmem uncharging
> > similar to what you did for skmem uncharging.
>
> The only thing I'm slightly worried here is that it can make
> reclaiming of memory cgroups harder. Probably, it's still ok,
> but let me first finish the work I'm doing on optimizing the
> whole memcg reclaim process, and then return to this case.
>

Yes, maybe we can disable that optimization for offlined memcgs.
Anyways, we can discuss this later as you have suggested.

Shakeel
