Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 03D8E82F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 04:06:17 -0500 (EST)
Received: by lbbkw15 with SMTP id kw15so47346889lbb.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 01:06:16 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id zz10si7421035lbb.56.2015.11.06.01.06.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 01:06:15 -0800 (PST)
Date: Fri, 6 Nov 2015 12:05:55 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151106090555.GK29259@esperanza>
References: <20151027122647.GG9891@dhcp22.suse.cz>
 <20151027154138.GA4665@cmpxchg.org>
 <20151027161554.GJ9891@dhcp22.suse.cz>
 <20151027164227.GB7749@cmpxchg.org>
 <20151029152546.GG23598@dhcp22.suse.cz>
 <20151029161009.GA9160@cmpxchg.org>
 <20151104104239.GG29607@dhcp22.suse.cz>
 <20151104195037.GA6872@cmpxchg.org>
 <20151105144002.GB15111@dhcp22.suse.cz>
 <20151105205522.GA1067@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151105205522.GA1067@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, David Miller <davem@davemloft.net>, akpm@linux-foundation.org, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Nov 05, 2015 at 03:55:22PM -0500, Johannes Weiner wrote:
> On Thu, Nov 05, 2015 at 03:40:02PM +0100, Michal Hocko wrote:
...
> > 3) keep only some (safe) cache types enabled by default with the current
> >    failing semantic and require an explicit enabling for the complete
> >    kmem accounting. [di]cache code paths should be quite robust to
> >    handle allocation failures.
> 
> Vladimir, what would be your opinion on this?

I'm all for this option. Actually, I've been thinking about this since I
introduced the __GFP_NOACCOUNT flag. Not because of the failing
semantics, since we can always let kmem allocations breach the limit.
This shouldn't be critical, because I don't think it's possible to issue
a series of kmem allocations w/o a single user page allocation, which
would reclaim/kill the excess.

The point is there are allocations that are shared system-wide and
therefore shouldn't go to any memcg. Most obvious examples are: mempool
users and radix_tree/idr preloads. Accounting them to memcg is likely to
result in noticeable memory overhead as memory cgroups are
created/destroyed, because they pin dead memory cgroups with all their
kmem caches, which aren't tiny.

Another funny example is objects destroyed lazily for performance
reasons, e.g. vmap_area. Such objects are usually very small, so
delaying destruction of a bunch of them will normally go unnoticed.
However, if kmemcg is used the effective memory consumption caused by
such objects can be multiplied by many times due to dangling kmem
caches.

We can, of course, mark all such allocations as __GFP_NOACCOUNT, but the
problem is they are tricky to identify, because they are scattered all
over the kernel source tree. E.g. Dave Chinner mentioned that XFS
internals do a lot of allocations that are shared among all XFS
filesystems and therefore should not be accounted (BTW that's why
list_lru's used by XFS are not marked as memcg-aware). There must be
more out there. Besides, kernel developers don't usually even know about
kmemcg (they just write the code for their subsys, so why should they?)
so they won't care thinking about using __GFP_NOACCOUNT, and hence new
falsely-accounted allocations are likely to appear.

That said, by switching from black-list (__GFP_NOACCOUNT) to white-list
(__GFP_ACCOUNT) kmem accounting policy we would make the system more
predictable and robust IMO. OTOH what would we lose? Security? Well,
containers aren't secure IMHO. In fact, I doubt they will ever be (as
secure as VMs). Anyway, if a runaway allocation is reported, it should
be trivial to fix by adding __GFP_ACCOUNT where appropriate.

If there are no objections, I'll prepare a patch switching to the
white-list approach. Let's start from obvious things like fs_struct,
mm_struct, task_struct, signal_struct, dentry, inode, which can be
easily allocated from user space. This should cover 90% of all
allocations that should be accounted AFAICS. The rest will be added
later if necessarily.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
