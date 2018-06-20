Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 916C26B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 11:20:21 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x22-v6so35723wmc.7
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 08:20:21 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id z24-v6si1449283edm.201.2018.06.20.08.20.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Jun 2018 08:20:18 -0700 (PDT)
Date: Wed, 20 Jun 2018 11:22:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/3] mm: memcg: remote memcg charging for kmem allocations
Message-ID: <20180620152235.GB2441@cmpxchg.org>
References: <20180619051327.149716-1-shakeelb@google.com>
 <20180619051327.149716-2-shakeelb@google.com>
 <20180619162429.GB27423@cmpxchg.org>
 <CALvZod7eq3WnMU8dzA+9CmbOuf-peaCyhLuMRW2n_VyOPqjZ7A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod7eq3WnMU8dzA+9CmbOuf-peaCyhLuMRW2n_VyOPqjZ7A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.com>, Greg Thelen <gthelen@google.com>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>

On Tue, Jun 19, 2018 at 04:31:18PM -0700, Shakeel Butt wrote:
> On Tue, Jun 19, 2018 at 9:22 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
> >
> > On Mon, Jun 18, 2018 at 10:13:25PM -0700, Shakeel Butt wrote:
> > > @@ -248,6 +248,30 @@ static inline void memalloc_noreclaim_restore(unsigned int flags)
> > >       current->flags = (current->flags & ~PF_MEMALLOC) | flags;
> > >  }
> > >
> > > +#ifdef CONFIG_MEMCG
> > > +static inline struct mem_cgroup *memalloc_memcg_save(struct mem_cgroup *memcg)
> > > +{
> > > +     struct mem_cgroup *old_memcg = current->target_memcg;
> > > +
> > > +     current->target_memcg = memcg;
> > > +     return old_memcg;
> > > +}
> > > +
> > > +static inline void memalloc_memcg_restore(struct mem_cgroup *memcg)
> > > +{
> > > +     current->target_memcg = memcg;
> > > +}
> >
> > The use_mm() and friends naming scheme would be better here:
> > memalloc_use_memcg(), memalloc_unuse_memcg(), current->active_memcg
> >
> 
> Ack. Though do you still think <linux/sched/mm.h> is the right place
> for these functions?

Yeah, since it has the memalloc_* prefix, we should keep it there.

If we did use_memcg(), unuse_memcg(), I'd put it into memcontrol.h,
but it seems a little terse; memalloc adds valuable context, IMO.

Thanks Shakeel!
