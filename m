Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id A579A6B754E
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 17:35:41 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id t9-v6so5948550ywg.8
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 14:35:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 189-v6sor504318ywa.288.2018.09.05.14.35.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Sep 2018 14:35:40 -0700 (PDT)
MIME-Version: 1.0
References: <20180904224707.10356-1-guro@fb.com> <20180905135152.1238c7103b2ecd6da206733c@linux-foundation.org>
 <20180905212241.GA26422@tower.DHCP.thefacebook.com>
In-Reply-To: <20180905212241.GA26422@tower.DHCP.thefacebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 5 Sep 2018 14:35:29 -0700
Message-ID: <CALvZod4-7cMOqYR5dF82PWuB4qDr5QKu+ScersCVgp74jhvvWA@mail.gmail.com>
Subject: Re: [PATCH v2] mm: slowly shrink slabs with a relatively small number
 of objects
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Rik van Riel <riel@surriel.com>, jbacik@fb.com, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Sep 5, 2018 at 2:23 PM Roman Gushchin <guro@fb.com> wrote:
>
> On Wed, Sep 05, 2018 at 01:51:52PM -0700, Andrew Morton wrote:
> > On Tue, 4 Sep 2018 15:47:07 -0700 Roman Gushchin <guro@fb.com> wrote:
> >
> > > Commit 9092c71bb724 ("mm: use sc->priority for slab shrink targets")
> > > changed the way how the target slab pressure is calculated and
> > > made it priority-based:
> > >
> > >     delta = freeable >> priority;
> > >     delta *= 4;
> > >     do_div(delta, shrinker->seeks);
> > >
> > > The problem is that on a default priority (which is 12) no pressure
> > > is applied at all, if the number of potentially reclaimable objects
> > > is less than 4096 (1<<12).
> > >
> > > This causes the last objects on slab caches of no longer used cgroups
> > > to never get reclaimed, resulting in dead cgroups staying around forever.
> >
> > But this problem pertains to all types of objects, not just the cgroup
> > cache, yes?
>
> Well, of course, but there is a dramatic difference in size.
>
> Most of these objects are taking few hundreds bytes (or less),
> while a memcg can take few hundred kilobytes on a modern multi-CPU
> machine. Mostly due to per-cpu stats and events counters.
>

Beside memcg, all of its kmem caches, most empty, are stuck in memory
as well. For SLAB even the memory overhead of an empty kmem cache is
not negligible.

Shakeel
