Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C13B6B0506
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 05:07:54 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u89so37945177wrc.1
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 02:07:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o184si12176765wma.37.2017.07.28.02.07.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 02:07:52 -0700 (PDT)
Date: Fri, 28 Jul 2017 11:07:51 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [4.13-rc1] /proc/meminfo reports that Slab: is little used.
Message-ID: <20170728090750.GH2274@dhcp22.suse.cz>
References: <201707260628.v6Q6SmaS030814@www262.sakura.ne.jp>
 <20170727162355.GA23896@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727162355.GA23896@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Josef Bacik <josef@toxicpanda.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

On Thu 27-07-17 12:23:55, Johannes Weiner wrote:
> >From 14e3d7647b3cf524dbb005faaea96b00b6909c12 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Thu, 27 Jul 2017 11:59:38 -0400
> Subject: [PATCH] mm: fix global NR_SLAB_.*CLAIMABLE counter reads
> 
> As Tetsuo points out:
> 
>     Commit 385386cff4c6f047 ("mm: vmstat: move slab statistics from
>     zone to node counters") broke "Slab:" field of /proc/meminfo . It
>     shows nearly 0kB.
> 
> In addition to /proc/meminfo, this problem also affects the slab
> counters OOM/allocation failure info dumps, can cause early -ENOMEM
> from overcommit protection, and miscalculate image size requirements
> during suspend-to-disk.
> 
> This is because the patch in question switched the slab counters from
> the zone level to the node level, but forgot to update the global
> accessor functions to read the aggregate node data instead of the
> aggregate zone data.
> 
> Use global_node_page_state() to access the global slab counters.
> 
> Fixes: 385386cff4c6 ("mm: vmstat: move slab statistics from zone to node counters")
> Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Looks good to me

Acked-by: Michal Hocko <mhocko@suse.com>

... but global_page_state still seems to be very confusing.  Do we want
s@global_page_state@global_zone_page_state@? This would be in line with
per-node statistics. Remaining callers
$ git grep "global_page_state(NR_" | sed 's@.*(\(NR_[A-Z_]*\)).*@\1@' | sort | uniq -c
      2 NR_BOUNCE
      2 NR_FREE_CMA_PAGES
     11 NR_FREE_PAGES
      1 NR_KERNEL_STACK_KB
      1 NR_MLOCK
      2 NR_PAGETABLE

seem to all be using it correctly. So what do you think about the follow
up?
---
