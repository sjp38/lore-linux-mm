Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E53586B0005
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 13:55:26 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b23so2475536wme.3
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 10:55:26 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d7si652272edl.467.2018.04.05.10.55.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Apr 2018 10:55:25 -0700 (PDT)
Date: Thu, 5 Apr 2018 13:55:16 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: memcg: make sure memory.events is uptodate when waking
 pollers
Message-ID: <20180405175507.GA24817@cmpxchg.org>
References: <20180324160901.512135-1-tj@kernel.org>
 <20180324160901.512135-2-tj@kernel.org>
 <20180404140855.GA28966@cmpxchg.org>
 <20180404141850.GC28966@cmpxchg.org>
 <20180404143447.GJ6312@dhcp22.suse.cz>
 <20180404165829.GA3126663@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180404165829.GA3126663@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, vdavydov.dev@gmail.com, guro@fb.com, riel@surriel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 04, 2018 at 09:58:29AM -0700, Tejun Heo wrote:
> On Wed, Apr 04, 2018 at 04:34:47PM +0200, Michal Hocko wrote:
> > > > The lazy updates are neat, but I'm a little concerned at the memory
> > > > footprint. On a 64-cpu machine for example, this adds close to 9000
> > > > words to struct mem_cgroup. And we really only need the accuracy for
> > > > the 4 cgroup items in memory.events, not all VM events and stats.
> > > > 
> > > > Why not restrict the patch to those? It would also get rid of the
> > > > weird sharing between VM and cgroup enums.
> > > 
> > > In fact, I wonder if we need per-cpuness for MEMCG_LOW, MEMCG_HIGH
> > > etc. in the first place. They describe super high-level reclaim and
> > > OOM events, so they're not nearly as hot as other VM events and
> > > stats. We could probably just have a per-memcg array of atomics.
> > 
> > Agreed!
> 
> Ah, yeah, if we aren't worried about the update frequency of
> MEMCG_HIGH, which likely is the highest freq, we can just switch to
> atomic_t.  I'm gonna apply the cgroup stat refactoring patches to
> cgroup, so if we ever wanna switch the counter to rstat, we can easily
> do that later.

Yeah, that's still great to have as generalized infrastructure.

For memory.events, how about this instead?

---
