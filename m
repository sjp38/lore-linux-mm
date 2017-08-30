Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 491446B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 06:57:45 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id l2so7339315ywe.7
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 03:57:45 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id d10si1297960ybf.485.2017.08.30.03.57.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 03:57:43 -0700 (PDT)
Date: Wed, 30 Aug 2017 11:57:19 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: memcontrol: use per-cpu stocks for socket memory
 uncharging
Message-ID: <20170830105719.GB2852@castle.dhcp.TheFacebook.com>
References: <20170829100150.4580-1-guro@fb.com>
 <20170829192621.GA5447@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170829192621.GA5447@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Tue, Aug 29, 2017 at 03:26:21PM -0400, Johannes Weiner wrote:
> On Tue, Aug 29, 2017 at 11:01:50AM +0100, Roman Gushchin wrote:
> > We've noticed a quite sensible performance overhead on some hosts
> > with significant network traffic when socket memory accounting
> > is enabled.
> > 
> > Perf top shows that socket memory uncharging path is hot:
> >   2.13%  [kernel]                [k] page_counter_cancel
> >   1.14%  [kernel]                [k] __sk_mem_reduce_allocated
> >   1.14%  [kernel]                [k] _raw_spin_lock
> >   0.87%  [kernel]                [k] _raw_spin_lock_irqsave
> >   0.84%  [kernel]                [k] tcp_ack
> >   0.84%  [kernel]                [k] ixgbe_poll
> >   0.83%  < workload >
> >   0.82%  [kernel]                [k] enqueue_entity
> >   0.68%  [kernel]                [k] __fget
> >   0.68%  [kernel]                [k] tcp_delack_timer_handler
> >   0.67%  [kernel]                [k] __schedule
> >   0.60%  < workload >
> >   0.59%  [kernel]                [k] __inet6_lookup_established
> >   0.55%  [kernel]                [k] __switch_to
> >   0.55%  [kernel]                [k] menu_select
> >   0.54%  libc-2.20.so            [.] __memcpy_avx_unaligned
> > 
> > To address this issue, the existing per-cpu stock infrastructure
> > can be used.
> > 
> > refill_stock() can be called from mem_cgroup_uncharge_skmem()
> > to move charge to a per-cpu stock instead of calling atomic
> > page_counter_uncharge().
> > 
> > To prevent the uncontrolled growth of per-cpu stocks,
> > refill_stock() will explicitly drain the cached charge,
> > if the cached value exceeds CHARGE_BATCH.
> > 
> > This allows significantly optimize the load:
> >   1.21%  [kernel]                [k] _raw_spin_lock
> >   1.01%  [kernel]                [k] ixgbe_poll
> >   0.92%  [kernel]                [k] _raw_spin_lock_irqsave
> >   0.90%  [kernel]                [k] enqueue_entity
> >   0.86%  [kernel]                [k] tcp_ack
> >   0.85%  < workload >
> >   0.74%  perf-11120.map          [.] 0x000000000061bf24
> >   0.73%  [kernel]                [k] __schedule
> >   0.67%  [kernel]                [k] __fget
> >   0.63%  [kernel]                [k] __inet6_lookup_established
> >   0.62%  [kernel]                [k] menu_select
> >   0.59%  < workload >
> >   0.59%  [kernel]                [k] __switch_to
> >   0.57%  libc-2.20.so            [.] __memcpy_avx_unaligned
> > 
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> > Cc: cgroups@vger.kernel.org
> > Cc: kernel-team@fb.com
> > Cc: linux-mm@kvack.org
> > Cc: linux-kernel@vger.kernel.org
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Neat!

Hi, Andrew!

Can you, please, pull this patch?

Thank you!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
