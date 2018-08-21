Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 24E736B20FC
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 18:15:50 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l16-v6so94466edq.18
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 15:15:50 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id y27-v6si305750edi.180.2018.08.21.15.15.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 15:15:49 -0700 (PDT)
Date: Tue, 21 Aug 2018 15:15:32 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2 1/3] mm: rework memcg kernel stack accounting
Message-ID: <20180821221529.GA18627@tower.DHCP.thefacebook.com>
References: <20180821213559.14694-1-guro@fb.com>
 <CALvZod4HAf+iPXQx1v+dwJkTph3ySAiYo4kn4d2jRFNQS59Tgg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CALvZod4HAf+iPXQx1v+dwJkTph3ySAiYo4kn4d2jRFNQS59Tgg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, luto@kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>

On Tue, Aug 21, 2018 at 03:10:52PM -0700, Shakeel Butt wrote:
> On Tue, Aug 21, 2018 at 2:36 PM Roman Gushchin <guro@fb.com> wrote:
> >
> > If CONFIG_VMAP_STACK is set, kernel stacks are allocated
> > using __vmalloc_node_range() with __GFP_ACCOUNT. So kernel
> > stack pages are charged against corresponding memory cgroups
> > on allocation and uncharged on releasing them.
> >
> > The problem is that we do cache kernel stacks in small
> > per-cpu caches and do reuse them for new tasks, which can
> > belong to different memory cgroups.
> >
> > Each stack page still holds a reference to the original cgroup,
> > so the cgroup can't be released until the vmap area is released.
> >
> > To make this happen we need more than two subsequent exits
> > without forks in between on the current cpu, which makes it
> > very unlikely to happen. As a result, I saw a significant number
> > of dying cgroups (in theory, up to 2 * number_of_cpu +
> > number_of_tasks), which can't be released even by significant
> > memory pressure.
> >
> > As a cgroup structure can take a significant amount of memory
> > (first of all, per-cpu data like memcg statistics), it leads
> > to a noticeable waste of memory.
> >
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> 
> Reviewed-by: Shakeel Butt <shakeelb@google.com>

Thanks!

> 
> BTW this makes a very good use-case for optimizing kmem uncharging
> similar to what you did for skmem uncharging.

Good point!
Let me prepare the patch.
