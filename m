Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id F2C076B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 12:58:34 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id h184-v6so13257818ybg.16
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 09:58:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 10-v6sor2262323yby.29.2018.04.04.09.58.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Apr 2018 09:58:34 -0700 (PDT)
Date: Wed, 4 Apr 2018 09:58:29 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/3] mm: memcontrol: Use cgroup_rstat for event accounting
Message-ID: <20180404165829.GA3126663@devbig577.frc2.facebook.com>
References: <20180324160901.512135-1-tj@kernel.org>
 <20180324160901.512135-2-tj@kernel.org>
 <20180404140855.GA28966@cmpxchg.org>
 <20180404141850.GC28966@cmpxchg.org>
 <20180404143447.GJ6312@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180404143447.GJ6312@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, vdavydov.dev@gmail.com, guro@fb.com, riel@surriel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

Hello,

On Wed, Apr 04, 2018 at 04:34:47PM +0200, Michal Hocko wrote:
> > > The lazy updates are neat, but I'm a little concerned at the memory
> > > footprint. On a 64-cpu machine for example, this adds close to 9000
> > > words to struct mem_cgroup. And we really only need the accuracy for
> > > the 4 cgroup items in memory.events, not all VM events and stats.
> > > 
> > > Why not restrict the patch to those? It would also get rid of the
> > > weird sharing between VM and cgroup enums.
> > 
> > In fact, I wonder if we need per-cpuness for MEMCG_LOW, MEMCG_HIGH
> > etc. in the first place. They describe super high-level reclaim and
> > OOM events, so they're not nearly as hot as other VM events and
> > stats. We could probably just have a per-memcg array of atomics.
> 
> Agreed!

Ah, yeah, if we aren't worried about the update frequency of
MEMCG_HIGH, which likely is the highest freq, we can just switch to
atomic_t.  I'm gonna apply the cgroup stat refactoring patches to
cgroup, so if we ever wanna switch the counter to rstat, we can easily
do that later.

Thasnks.

-- 
tejun
