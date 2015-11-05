Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id D04E082F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 09:40:05 -0500 (EST)
Received: by wmeg8 with SMTP id g8so15272560wme.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 06:40:05 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id wt9si8340359wjb.141.2015.11.05.06.40.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 06:40:04 -0800 (PST)
Received: by wmeg8 with SMTP id g8so16126094wme.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 06:40:04 -0800 (PST)
Date: Thu, 5 Nov 2015 15:40:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151105144002.GB15111@dhcp22.suse.cz>
References: <20151023.065957.1690815054807881760.davem@davemloft.net>
 <20151026165619.GB2214@cmpxchg.org>
 <20151027122647.GG9891@dhcp22.suse.cz>
 <20151027154138.GA4665@cmpxchg.org>
 <20151027161554.GJ9891@dhcp22.suse.cz>
 <20151027164227.GB7749@cmpxchg.org>
 <20151029152546.GG23598@dhcp22.suse.cz>
 <20151029161009.GA9160@cmpxchg.org>
 <20151104104239.GG29607@dhcp22.suse.cz>
 <20151104195037.GA6872@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151104195037.GA6872@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 04-11-15 14:50:37, Johannes Weiner wrote:
[...]
> Because it goes without saying that once the cgroupv2 interface is
> released, and people use it in production, there is no way we can then
> *add* dentry cache, inode cache, and others to memory.current. That
> would be an unacceptable change in interface behavior.

They would still have to _enable_ the config option _explicitly_. make
oldconfig wouldn't change it silently for them. I do not think
it is an unacceptable change of behavior if the config is changed
explicitly.

> On the other
> hand, people will be prepared for hiccups in the early stages of
> cgroupv2 release, and we're providing cgroup.memory=noslab to let them
> workaround severe problems in production until we fix it without
> forcing them to fully revert to cgroupv1.

This would be true if they moved on to the new cgroup API intentionally.
The reality is more complicated though. AFAIK sysmted is waiting for
cgroup2 already and privileged services enable all available resource
controllers by default as I've learned just recently. If we know that
the interface is not stable enough then we are basically forcing _most_
users to use the kernel boot parameter if we stay with the current
kmem semantic. More on that below.

> So if we agree that there are no fundamental architectural concerns
> with slab accounting, i.e. nothing that can't be addressed in the
> implementation, we have to make the call now.

We are on the same page here.

> And I maintain that not accounting dentry cache and inode cache is a
> gaping hole in memory isolation, so it should be included by default.
> (The rest of the slabs is arguable, but IMO the risk of missing
> something important is higher than the cost of including them.)

More on that below.
 
> As far as your allocation failure concerns go, I think the kmem code
> is currently not behaving as Glauber originally intended, which is to
> force charge if reclaim and OOM killing weren't able to make enough
> space. See this recently rewritten section of the kmem charge path:
> 
> -               /*
> -                * try_charge() chose to bypass to root due to OOM kill or
> -                * fatal signal.  Since our only options are to either fail
> -                * the allocation or charge it to this cgroup, do it as a
> -                * temporary condition. But we can't fail. From a kmem/slab
> -                * perspective, the cache has already been selected, by
> -                * mem_cgroup_kmem_get_cache(), so it is too late to change
> -                * our minds.
> -                *
> -                * This condition will only trigger if the task entered
> -                * memcg_charge_kmem in a sane state, but was OOM-killed
> -                * during try_charge() above. Tasks that were already dying
> -                * when the allocation triggers should have been already
> -                * directed to the root cgroup in memcontrol.h
> -                */
> -               page_counter_charge(&memcg->memory, nr_pages);
> -               if (do_swap_account)
> -                       page_counter_charge(&memcg->memsw, nr_pages);
> 
> It could be that this never properly worked as it was tied to the
> -EINTR bypass trick, but the idea was these charges never fail.

I have always understood this path as a corner case when the task is an
oom victim or exiting. So this would be only a temporal condition which
cannot cause a complete runaway.

> And this makes sense. If the allocator semantics are such that we
> never fail these page allocations for slab, and the callsites rely on
> that, surely we should not fail them in the memory controller, either.

Then we can only bypass them or loop inside the charge code for ever
like we do in the page allocator. The later one is really fragile and
it would be much more in the restricted environment as we have learned
with the memcg OOM killer in the past. 
 
> And it makes a lot more sense to account them in excess of the limit
> than pretend they don't exist. We might not be able to completely
> fullfill the containment part of the memory controller (although these
> slab charges will still create significant pressure before that), but
> at least we don't fail the accounting part on top of it.

Hmm, wouldn't that kill the whole purpose of the kmem accounting? Any
load could simply runaway via kernel allocations. What is even worse we
might even not trigger memcg OOM killer before we hit the global OOM. So
the whole containment goes straight to hell.

I can see four options here:
1) enable kmem by default with the current semantic which we know can
   BUG_ON (at least btrfs is known to hit this) or lead to other issues.
2) enable kmem by default and change the semantic for cgroup2 to allow
   runaway charges above the hard limit which would defeat the whole
   purpose of the containment for cgroup2. This can be a temporary
   workaround until we can afford kmem failures. This has a big risk
   that we will end up with this permanently because there is a strong
   pressure that GFP_KERNEL allocations should never fail. Yet this is
   the most common type of request. Or do we change the consistency with
   the global case at some point?
3) keep only some (safe) cache types enabled by default with the current
   failing semantic and require an explicit enabling for the complete
   kmem accounting. [di]cache code paths should be quite robust to
   handle allocation failures.
4) disable kmem by default and change the config default later to signal
   the accounting is safe as far as we are aware and let people enable
   the functionality on those basis. We would keep the current failing
   semantic.

To me 4) sounds like the safest option because it still keeps the
functionality available to those who can benefit from it in v1 already
while we are not exposing a potentially buggy behavior to the majority
(many of them even unintentionally).  Moreover we still allow to change
the default later on an explicit basis. 3) sounds like the second best
option but I am not really sure whether we can do that very easily
without bringing up a lot of unmaintainable mess. 2) sounds like the
third best approach but I am afraid it would render the basic use cases
unusable for a very long time and kill any interest in cgroup2 for even
longer (cargo cults are really hard to get rid of). 1) sounds like a
land mine approach which would force many/most users to simply keep
using the boot option and force us to re-evaluate the default hard way.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
