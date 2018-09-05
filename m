Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id E5C086B753C
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 17:23:05 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id 1-v6so6024109ywd.9
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 14:23:05 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id o65-v6si788340ywf.623.2018.09.05.14.23.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 14:23:04 -0700 (PDT)
Date: Wed, 5 Sep 2018 14:22:44 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2] mm: slowly shrink slabs with a relatively small
 number of objects
Message-ID: <20180905212241.GA26422@tower.DHCP.thefacebook.com>
References: <20180904224707.10356-1-guro@fb.com>
 <20180905135152.1238c7103b2ecd6da206733c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180905135152.1238c7103b2ecd6da206733c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Rik van Riel <riel@surriel.com>, Josef Bacik <jbacik@fb.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Sep 05, 2018 at 01:51:52PM -0700, Andrew Morton wrote:
> On Tue, 4 Sep 2018 15:47:07 -0700 Roman Gushchin <guro@fb.com> wrote:
> 
> > Commit 9092c71bb724 ("mm: use sc->priority for slab shrink targets")
> > changed the way how the target slab pressure is calculated and
> > made it priority-based:
> > 
> >     delta = freeable >> priority;
> >     delta *= 4;
> >     do_div(delta, shrinker->seeks);
> > 
> > The problem is that on a default priority (which is 12) no pressure
> > is applied at all, if the number of potentially reclaimable objects
> > is less than 4096 (1<<12).
> > 
> > This causes the last objects on slab caches of no longer used cgroups
> > to never get reclaimed, resulting in dead cgroups staying around forever.
> 
> But this problem pertains to all types of objects, not just the cgroup
> cache, yes?

Well, of course, but there is a dramatic difference in size.

Most of these objects are taking few hundreds bytes (or less),
while a memcg can take few hundred kilobytes on a modern multi-CPU
machine. Mostly due to per-cpu stats and events counters.

> 
> > Slab LRU lists are reparented on memcg offlining, but corresponding
> > objects are still holding a reference to the dying cgroup.
> > If we don't scan them at all, the dying cgroup can't go away.
> > Most likely, the parent cgroup hasn't any directly associated objects,
> > only remaining objects from dying children cgroups. So it can easily
> > hold a reference to hundreds of dying cgroups.
> > 
> > If there are no big spikes in memory pressure, and new memory cgroups
> > are created and destroyed periodically, this causes the number of
> > dying cgroups grow steadily, causing a slow-ish and hard-to-detect
> > memory "leak". It's not a real leak, as the memory can be eventually
> > reclaimed, but it could not happen in a real life at all. I've seen
> > hosts with a steadily climbing number of dying cgroups, which doesn't
> > show any signs of a decline in months, despite the host is loaded
> > with a production workload.
> > 
> > It is an obvious waste of memory, and to prevent it, let's apply
> > a minimal pressure even on small shrinker lists. E.g. if there are
> > freeable objects, let's scan at least min(freeable, scan_batch)
> > objects.
> > 
> > This fix significantly improves a chance of a dying cgroup to be
> > reclaimed, and together with some previous patches stops the steady
> > growth of the dying cgroups number on some of our hosts.
> > 
> > ...
> >
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -476,6 +476,17 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> >  	delta = freeable >> priority;
> >  	delta *= 4;
> >  	do_div(delta, shrinker->seeks);
> > +
> > +	/*
> > +	 * Make sure we apply some minimal pressure even on
> > +	 * small cgroups. This is necessary because some of
> > +	 * belonging objects can hold a reference to a dying
> > +	 * child cgroup. If we don't scan them, the dying
> > +	 * cgroup can't go away unless the memory pressure
> > +	 * (and the scanning priority) raise significantly.
> > +	 */
> > +	delta = max(delta, min(freeable, batch_size));
> > +
> 
> If so I think the comment should be cast in more general terms.  Maybe
> with a final sentence "the cgroup cache is one such case".

So, I think that we have to leave explicitly explained memcg refcounting
case, but I'll add a line about other cases as well.

> 
> Also, please use all 80 columns in block comments to save a few display
> lines.
> 
> And `delta' has type ULL whereas the other two are longs.  We'll
> presumably hit warnings here, preventable with max_t.
>

Let me fix this in v3.

Thank you!
