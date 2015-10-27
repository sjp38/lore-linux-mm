Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9A59482F64
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 12:01:23 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so166438704wic.0
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 09:01:23 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id qs10si50883036wjc.129.2015.10.27.09.01.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 09:01:22 -0700 (PDT)
Date: Tue, 27 Oct 2015 09:01:08 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/8] mm: memcontrol: account socket memory in unified
 hierarchy
Message-ID: <20151027155833.GB4665@cmpxchg.org>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <20151022184509.GM18351@esperanza>
 <20151026172216.GC2214@cmpxchg.org>
 <20151027084320.GF13221@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151027084320.GF13221@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 27, 2015 at 11:43:21AM +0300, Vladimir Davydov wrote:
> On Mon, Oct 26, 2015 at 01:22:16PM -0400, Johannes Weiner wrote:
> > I'm not getting rid of those knobs, I'm just reusing the old socket
> > accounting infrastructure in an attempt to make the memory accounting
> > feature useful to more people in cgroups v2 (unified hierarchy).
> 
> My understanding is that in the meantime you effectively break the
> existing per memcg tcp window control logic.

That's not my intention, this stuff has to keep working. I'm assuming
you mean the changes to sk_enter_memory_pressure() when hitting the
charge limit; let me address this in the other subthread.

> > We can always come back to think about per-cgroup tcp window limits in
> > the unified hierarchy, my patches don't get in the way of this. I'm
> > not removing the knobs in cgroups v1 and I'm not preventing them in v2.
> > 
> > But regardless of tcp window control, we need to account socket memory
> > in the main memory accounting pool where pressure is shared (to the
> > best of our abilities) between all accounted memory consumers.
> > 
> 
> No objections to this point. However, I really don't like the idea to
> charge tcp window size to memory.current instead of charging individual
> pages consumed by the workload for storing socket buffers, because it is
> inconsistent with what we have now. Can't we charge individual skb pages
> as we do in case of other kmem allocations?

Absolutely, both work for me. I chose that route because it's where
the networking code already tracks and accounts memory consumed, so it
seemed like a better site to hook into.

But I understand your concerns. We want to track this stuff as close
to the memory allocators as possible.

> > But also, there are people right now for whom the socket buffers cause
> > system OOM, but the existing memcg's hard tcp window limitq that
> > exists absolutely wrecks network performance for them. It's not usable
> > the way it is. It'd be much better to have the socket buffers exert
> > pressure on the shared pool, and then propagate the overall pressure
> > back to individual consumers with reclaim, shrinkers, vmpressure etc.
> 
> This might or might not work. I'm not an expert to judge. But if you do
> this only for memcg leaving the global case as it is, networking people
> won't budge IMO. So could you please start such a major rework from the
> global case? Could you please try to deprecate the tcp window limits not
> only in the legacy memcg hierarchy, but also system-wide in order to
> attract attention of networking experts?

I'm definitely interested in addressing this globally as well.

The idea behind this was to use the memcg part as a testbed. cgroup2
is going to be new and people are prepared for hiccups when migrating
their applications to it; and they can roll back to cgroup1 and tcp
window limits at any time should they run into problems in production.

So this seemed like a good way to prove a new mechanism before rolling
it out to every single Linux setup, rather than switch everybody over
after the limited scope testing I can do as a developer on my own.

Keep in mind that my patches are not committing anything in terms of
interface, so we retain all the freedom to fix and tune the way this
is implemented, including the freedom to re-add tcp window limits in
case the pressure balancing is not a comprehensive solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
