Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 631686B0038
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 04:43:40 -0400 (EDT)
Received: by lffz202 with SMTP id z202so168951015lff.3
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 01:43:39 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 100si24010201lft.42.2015.10.27.01.43.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 01:43:38 -0700 (PDT)
Date: Tue, 27 Oct 2015 11:43:21 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 0/8] mm: memcontrol: account socket memory in unified
 hierarchy
Message-ID: <20151027084320.GF13221@esperanza>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <20151022184509.GM18351@esperanza>
 <20151026172216.GC2214@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151026172216.GC2214@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Oct 26, 2015 at 01:22:16PM -0400, Johannes Weiner wrote:
> On Thu, Oct 22, 2015 at 09:45:10PM +0300, Vladimir Davydov wrote:
> > Hi Johannes,
> > 
> > On Thu, Oct 22, 2015 at 12:21:28AM -0400, Johannes Weiner wrote:
> > ...
> > > Patch #5 adds accounting and tracking of socket memory to the unified
> > > hierarchy memory controller, as described above. It uses the existing
> > > per-cpu charge caches and triggers high limit reclaim asynchroneously.
> > > 
> > > Patch #8 uses the vmpressure extension to equalize pressure between
> > > the pages tracked natively by the VM and socket buffer pages. As the
> > > pool is shared, it makes sense that while natively tracked pages are
> > > under duress the network transmit windows are also not increased.
> > 
> > First of all, I've no experience in networking, so I'm likely to be
> > mistaken. Nevertheless I beg to disagree that this patch set is a step
> > in the right direction. Here goes why.
> > 
> > I admit that your idea to get rid of explicit tcp window control knobs
> > and size it dynamically basing on memory pressure instead does sound
> > tempting, but I don't think it'd always work. The problem is that in
> > contrast to, say, dcache, we can't shrink tcp buffers AFAIU, we can only
> > stop growing them. Now suppose a system hasn't experienced memory
> > pressure for a while. If we don't have explicit tcp window limit, tcp
> > buffers on such a system might have eaten almost all available memory
> > (because of network load/problems). If a user workload that needs a
> > significant amount of memory is started suddenly then, the network code
> > will receive a notification and surely stop growing buffers, but all
> > those buffers accumulated won't disappear instantly. As a result, the
> > workload might be unable to find enough free memory and have no choice
> > but invoke OOM killer. This looks unexpected from the user POV.
> 
> I'm not getting rid of those knobs, I'm just reusing the old socket
> accounting infrastructure in an attempt to make the memory accounting
> feature useful to more people in cgroups v2 (unified hierarchy).
> 

My understanding is that in the meantime you effectively break the
existing per memcg tcp window control logic.

> We can always come back to think about per-cgroup tcp window limits in
> the unified hierarchy, my patches don't get in the way of this. I'm
> not removing the knobs in cgroups v1 and I'm not preventing them in v2.
> 
> But regardless of tcp window control, we need to account socket memory
> in the main memory accounting pool where pressure is shared (to the
> best of our abilities) between all accounted memory consumers.
> 

No objections to this point. However, I really don't like the idea to
charge tcp window size to memory.current instead of charging individual
pages consumed by the workload for storing socket buffers, because it is
inconsistent with what we have now. Can't we charge individual skb pages
as we do in case of other kmem allocations?

> From an interface standpoint alone, I don't think it's reasonable to
> ask users per default to limit different consumers on a case by case
> basis. I certainly have no problem with finetuning for scenarios you
> describe above, but with memory.current, memory.high, memory.max we
> are providing a generic interface to account and contain memory
> consumption of workloads. This has to include all major memory
> consumers to make semantical sense.

We can propose a reasonable default as we do in the global case.

> 
> But also, there are people right now for whom the socket buffers cause
> system OOM, but the existing memcg's hard tcp window limitq that
> exists absolutely wrecks network performance for them. It's not usable
> the way it is. It'd be much better to have the socket buffers exert
> pressure on the shared pool, and then propagate the overall pressure
> back to individual consumers with reclaim, shrinkers, vmpressure etc.
> 

This might or might not work. I'm not an expert to judge. But if you do
this only for memcg leaving the global case as it is, networking people
won't budge IMO. So could you please start such a major rework from the
global case? Could you please try to deprecate the tcp window limits not
only in the legacy memcg hierarchy, but also system-wide in order to
attract attention of networking experts?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
