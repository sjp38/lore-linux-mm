Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id B69F282F64
	for <linux-mm@kvack.org>; Mon, 26 Oct 2015 13:22:28 -0400 (EDT)
Received: by wikq8 with SMTP id q8so174957321wik.1
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 10:22:28 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o8si44338608wjx.66.2015.10.26.10.22.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Oct 2015 10:22:27 -0700 (PDT)
Date: Mon, 26 Oct 2015 13:22:16 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/8] mm: memcontrol: account socket memory in unified
 hierarchy
Message-ID: <20151026172216.GC2214@cmpxchg.org>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <20151022184509.GM18351@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022184509.GM18351@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 22, 2015 at 09:45:10PM +0300, Vladimir Davydov wrote:
> Hi Johannes,
> 
> On Thu, Oct 22, 2015 at 12:21:28AM -0400, Johannes Weiner wrote:
> ...
> > Patch #5 adds accounting and tracking of socket memory to the unified
> > hierarchy memory controller, as described above. It uses the existing
> > per-cpu charge caches and triggers high limit reclaim asynchroneously.
> > 
> > Patch #8 uses the vmpressure extension to equalize pressure between
> > the pages tracked natively by the VM and socket buffer pages. As the
> > pool is shared, it makes sense that while natively tracked pages are
> > under duress the network transmit windows are also not increased.
> 
> First of all, I've no experience in networking, so I'm likely to be
> mistaken. Nevertheless I beg to disagree that this patch set is a step
> in the right direction. Here goes why.
> 
> I admit that your idea to get rid of explicit tcp window control knobs
> and size it dynamically basing on memory pressure instead does sound
> tempting, but I don't think it'd always work. The problem is that in
> contrast to, say, dcache, we can't shrink tcp buffers AFAIU, we can only
> stop growing them. Now suppose a system hasn't experienced memory
> pressure for a while. If we don't have explicit tcp window limit, tcp
> buffers on such a system might have eaten almost all available memory
> (because of network load/problems). If a user workload that needs a
> significant amount of memory is started suddenly then, the network code
> will receive a notification and surely stop growing buffers, but all
> those buffers accumulated won't disappear instantly. As a result, the
> workload might be unable to find enough free memory and have no choice
> but invoke OOM killer. This looks unexpected from the user POV.

I'm not getting rid of those knobs, I'm just reusing the old socket
accounting infrastructure in an attempt to make the memory accounting
feature useful to more people in cgroups v2 (unified hierarchy).

We can always come back to think about per-cgroup tcp window limits in
the unified hierarchy, my patches don't get in the way of this. I'm
not removing the knobs in cgroups v1 and I'm not preventing them in v2.

But regardless of tcp window control, we need to account socket memory
in the main memory accounting pool where pressure is shared (to the
best of our abilities) between all accounted memory consumers.

>From an interface standpoint alone, I don't think it's reasonable to
ask users per default to limit different consumers on a case by case
basis. I certainly have no problem with finetuning for scenarios you
describe above, but with memory.current, memory.high, memory.max we
are providing a generic interface to account and contain memory
consumption of workloads. This has to include all major memory
consumers to make semantical sense.

But also, there are people right now for whom the socket buffers cause
system OOM, but the existing memcg's hard tcp window limitq that
exists absolutely wrecks network performance for them. It's not usable
the way it is. It'd be much better to have the socket buffers exert
pressure on the shared pool, and then propagate the overall pressure
back to individual consumers with reclaim, shrinkers, vmpressure etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
