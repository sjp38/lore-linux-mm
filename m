Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id E57566B7556
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 17:47:45 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id t9-v6so5960831ywg.8
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 14:47:45 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u7-v6si820744ywf.365.2018.09.05.14.47.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 14:47:45 -0700 (PDT)
Date: Wed, 5 Sep 2018 14:47:34 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2] mm: slowly shrink slabs with a relatively small
 number of objects
Message-ID: <20180905214731.GA30226@tower.DHCP.thefacebook.com>
References: <20180904224707.10356-1-guro@fb.com>
 <20180905135152.1238c7103b2ecd6da206733c@linux-foundation.org>
 <20180905212241.GA26422@tower.DHCP.thefacebook.com>
 <CALvZod4-7cMOqYR5dF82PWuB4qDr5QKu+ScersCVgp74jhvvWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CALvZod4-7cMOqYR5dF82PWuB4qDr5QKu+ScersCVgp74jhvvWA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Rik van Riel <riel@surriel.com>, jbacik@fb.com, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Sep 05, 2018 at 02:35:29PM -0700, Shakeel Butt wrote:
> On Wed, Sep 5, 2018 at 2:23 PM Roman Gushchin <guro@fb.com> wrote:
> >
> > On Wed, Sep 05, 2018 at 01:51:52PM -0700, Andrew Morton wrote:
> > > On Tue, 4 Sep 2018 15:47:07 -0700 Roman Gushchin <guro@fb.com> wrote:
> > >
> > > > Commit 9092c71bb724 ("mm: use sc->priority for slab shrink targets")
> > > > changed the way how the target slab pressure is calculated and
> > > > made it priority-based:
> > > >
> > > >     delta = freeable >> priority;
> > > >     delta *= 4;
> > > >     do_div(delta, shrinker->seeks);
> > > >
> > > > The problem is that on a default priority (which is 12) no pressure
> > > > is applied at all, if the number of potentially reclaimable objects
> > > > is less than 4096 (1<<12).
> > > >
> > > > This causes the last objects on slab caches of no longer used cgroups
> > > > to never get reclaimed, resulting in dead cgroups staying around forever.
> > >
> > > But this problem pertains to all types of objects, not just the cgroup
> > > cache, yes?
> >
> > Well, of course, but there is a dramatic difference in size.
> >
> > Most of these objects are taking few hundreds bytes (or less),
> > while a memcg can take few hundred kilobytes on a modern multi-CPU
> > machine. Mostly due to per-cpu stats and events counters.
> >
> 
> Beside memcg, all of its kmem caches, most empty, are stuck in memory
> as well. For SLAB even the memory overhead of an empty kmem cache is
> not negligible.

Right!

I mean the main part of the problem is not in these 4k (mostly vfs-cache related)
objects themselves, but in objects, which are referenced by these 4k objects.

Thanks!
