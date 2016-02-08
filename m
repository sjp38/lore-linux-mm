Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3C2D88309E
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 00:46:36 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id g62so100938622wme.0
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 21:46:36 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id kd7si40328845wjb.179.2016.02.07.21.46.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Feb 2016 21:46:35 -0800 (PST)
Date: Mon, 8 Feb 2016 00:46:16 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/5] mm: memcontrol: enable kmem accounting for all
 cgroups in the legacy hierarchy
Message-ID: <20160208054616.GA22202@cmpxchg.org>
References: <cover.1454864628.git.vdavydov@virtuozzo.com>
 <5e6c9361f901fbfae84fe51ad1d27694d2377bd3.1454864628.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5e6c9361f901fbfae84fe51ad1d27694d2377bd3.1454864628.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Feb 07, 2016 at 08:27:31PM +0300, Vladimir Davydov wrote:
> Currently, in the legacy hierarchy kmem accounting is off for all
> cgroups by default and must be enabled explicitly by writing something
> to memory.kmem.limit_in_bytes. Since we don't support reclaim on hitting
> kmem limit, nor do we have any plans to implement it, this is likely to
> be -1, just to enable kmem accounting and limit kernel memory
> consumption by the memory.limit_in_bytes along with user memory.
> 
> This user API was introduced when the implementation of kmem accounting
> lacked slab shrinker support and hence was useless in practice. Things
> have changed since then - slab shrinkers were made memcg aware, the
> accounting overhead seems to be negligible, and a failure to charge a
> kmem allocation should not have critical consequences, because we only
> account those kernel objects that should be safe to fail. That's why
> kmem accounting is enabled by default for all cgroups in the default
> hierarchy, which will eventually replace the legacy one.
> 
> The ability to enable kmem accounting for some cgroups while keeping it
> disabled for others is getting difficult to maintain. E.g. to make
> shadow node shrinker memcg aware (see mm/workingset.c), we need to know
> the relationship between the number of shadow nodes allocated for a
> cgroup and the size of its lru list. If kmem accounting is enabled for
> all cgroups there is no problem, but what should we do if kmem
> accounting is enabled only for half of cgroups? We've no other choice
> but use global lru stats while scanning root cgroup's shadow nodes, but
> that would be wrong if kmem accounting was enabled for all cgroups
> (which is the case if the unified hierarchy is used), in which case we
> should use lru stats of the root cgroup's lruvec.
> 
> That being said, let's enable kmem accounting for all memory cgroups by
> default. If one finds it unstable or too costly, it can always be
> disabled system-wide by passing cgroup.memory=nokmem to the kernel at
> boot time.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

A little bolder than I would have preferred for legacy memcg, but I
don't think we have another choice here. And you're right, accounting
costs are a far cry from what they once were. So I'm okay with this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
