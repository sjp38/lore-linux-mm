Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id E31DD6B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 15:45:15 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id b7-v6so18179946ybn.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 12:45:15 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y138sor2828966ywg.378.2018.04.05.12.45.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Apr 2018 12:45:15 -0700 (PDT)
Date: Thu, 5 Apr 2018 12:45:12 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: memcg: make sure memory.events is uptodate when
 waking pollers
Message-ID: <20180405194512.GD3126663@devbig577.frc2.facebook.com>
References: <20180324160901.512135-1-tj@kernel.org>
 <20180324160901.512135-2-tj@kernel.org>
 <20180404140855.GA28966@cmpxchg.org>
 <20180404141850.GC28966@cmpxchg.org>
 <20180404143447.GJ6312@dhcp22.suse.cz>
 <20180404165829.GA3126663@devbig577.frc2.facebook.com>
 <20180405175507.GA24817@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405175507.GA24817@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, vdavydov.dev@gmail.com, guro@fb.com, riel@surriel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu, Apr 05, 2018 at 01:55:16PM -0400, Johannes Weiner wrote:
> From 4369ce161a9085aa408f2eca54f9de72909ee1b1 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Thu, 5 Apr 2018 11:53:55 -0400
> Subject: [PATCH] mm: memcg: make sure memory.events is uptodate when waking
>  pollers
> 
> a983b5ebee57 ("mm: memcontrol: fix excessive complexity in memory.stat
> reporting") added per-cpu drift to all memory cgroup stats and events
> shown in memory.stat and memory.events.
> 
> For memory.stat this is acceptable. But memory.events issues file
> notifications, and somebody polling the file for changes will be
> confused when the counters in it are unchanged after a wakeup.
> 
> Luckily, the events in memory.events - MEMCG_LOW, MEMCG_HIGH,
> MEMCG_MAX, MEMCG_OOM - are sufficiently rare and high-level that we
> don't need per-cpu buffering for them: MEMCG_HIGH and MEMCG_MAX would
> be the most frequent, but they're counting invocations of reclaim,
> which is a complex operation that touches many shared cachelines.
> 
> This splits memory.events from the generic VM events and tracks them
> in their own, unbuffered atomic counters. That's also cleaner, as it
> eliminates the ugly enum nesting of VM and cgroup events.
> 
> Fixes: a983b5ebee57 ("mm: memcontrol: fix excessive complexity in memory.stat reporting")
> Reported-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Yeah, that works.  FWIW,

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
