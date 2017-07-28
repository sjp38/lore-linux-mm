Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 985E66B053F
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 09:05:31 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o201so14079937wmg.3
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 06:05:31 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e30si1078364eda.29.2017.07.28.06.05.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 28 Jul 2017 06:05:30 -0700 (PDT)
Date: Fri, 28 Jul 2017 09:05:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [4.13-rc1] /proc/meminfo reports that Slab: is little used.
Message-ID: <20170728130517.GA16849@cmpxchg.org>
References: <201707260628.v6Q6SmaS030814@www262.sakura.ne.jp>
 <20170727162355.GA23896@cmpxchg.org>
 <20170728090750.GH2274@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170728090750.GH2274@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Josef Bacik <josef@toxicpanda.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

On Fri, Jul 28, 2017 at 11:07:51AM +0200, Michal Hocko wrote:
> On Thu 27-07-17 12:23:55, Johannes Weiner wrote:
> > >From 14e3d7647b3cf524dbb005faaea96b00b6909c12 Mon Sep 17 00:00:00 2001
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Date: Thu, 27 Jul 2017 11:59:38 -0400
> > Subject: [PATCH] mm: fix global NR_SLAB_.*CLAIMABLE counter reads
> > 
> > As Tetsuo points out:
> > 
> >     Commit 385386cff4c6f047 ("mm: vmstat: move slab statistics from
> >     zone to node counters") broke "Slab:" field of /proc/meminfo . It
> >     shows nearly 0kB.
> > 
> > In addition to /proc/meminfo, this problem also affects the slab
> > counters OOM/allocation failure info dumps, can cause early -ENOMEM
> > from overcommit protection, and miscalculate image size requirements
> > during suspend-to-disk.
> > 
> > This is because the patch in question switched the slab counters from
> > the zone level to the node level, but forgot to update the global
> > accessor functions to read the aggregate node data instead of the
> > aggregate zone data.
> > 
> > Use global_node_page_state() to access the global slab counters.
> > 
> > Fixes: 385386cff4c6 ("mm: vmstat: move slab statistics from zone to node counters")
> > Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Looks good to me
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks

> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 28 Jul 2017 11:02:51 +0200
> Subject: [PATCH] mm: rename global_page_state to global_zone_page_state
> 
> global_page_state is error prone as a recent bug report pointed out [1].
> It only returns proper values for zone based counters as the enum it
> gets suggests. We already have global_node_page_state so let's rename
> global_page_state to global_zone_page_state to be more explicit here.
> All existing users seems to be correct
> $ git grep "global_page_state(NR_" | sed 's@.*(\(NR_[A-Z_]*\)).*@\1@' | sort | uniq -c
>       2 NR_BOUNCE
>       2 NR_FREE_CMA_PAGES
>      11 NR_FREE_PAGES
>       1 NR_KERNEL_STACK_KB
>       1 NR_MLOCK
>       2 NR_PAGETABLE
> 
> This patch shouldn't introduce any functional change.
> 
> [1] http://lkml.kernel.org/r/201707260628.v6Q6SmaS030814@www262.sakura.ne.jp
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Yeah I think that's a good idea. I suspect Mel wanted to keep churn in
unrelated callsites down when he introduced the node stuff, since that
was already a big patch series. It makes sense to clean this up now.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
