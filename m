Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 78D7D6B025C
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 09:33:08 -0500 (EST)
Received: by wmuu63 with SMTP id u63so225008430wmu.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 06:33:08 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u9si11623054wje.237.2015.12.09.06.33.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 06:33:07 -0800 (PST)
Date: Wed, 9 Dec 2015 09:32:58 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 7/8] mm: memcontrol: account "kmem" consumers in cgroup2
 memory controller
Message-ID: <20151209143258.GA21506@cmpxchg.org>
References: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
 <1449599665-18047-8-git-send-email-hannes@cmpxchg.org>
 <20151209113037.GS11488@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151209113037.GS11488@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Dec 09, 2015 at 02:30:38PM +0300, Vladimir Davydov wrote:
> On Tue, Dec 08, 2015 at 01:34:24PM -0500, Johannes Weiner wrote:
> > The original cgroup memory controller has an extension to account slab
> > memory (and other "kernel memory" consumers) in a separate "kmem"
> > counter, once the user set an explicit limit on that "kmem" pool.
> > 
> > However, this includes various consumers whose sizes are directly
> > linked to userspace activity. Accounting them as an optional "kmem"
> > extension is problematic for several reasons:
> > 
> > 1. It leaves the main memory interface with incomplete semantics. A
> >    user who puts their workload into a cgroup and configures a memory
> >    limit does not expect us to leave holes in the containment as big
> >    as the dentry and inode cache, or the kernel stack pages.
> > 
> > 2. If the limit set on this random historical subgroup of consumers is
> >    reached, subsequent allocations will fail even when the main memory
> >    pool available to the cgroup is not yet exhausted and/or has
> >    reclaimable memory in it.
> > 
> > 3. Calling it 'kernel memory' is misleading. The dentry and inode
> >    caches are no more 'kernel' (or no less 'user') memory than the
> >    page cache itself. Treating these consumers as different classes is
> >    a historical implementation detail that should not leak to users.
> > 
> > So, in addition to page cache, anonymous memory, and network socket
> > memory, account the following memory consumers per default in the
> > cgroup2 memory controller:
> > 
> >      - threadinfo
> >      - task_struct
> >      - task_delay_info
> >      - pid
> >      - cred
> >      - mm_struct
> >      - vm_area_struct and vm_region (nommu)
> >      - anon_vma and anon_vma_chain
> >      - signal_struct
> >      - sighand_struct
> >      - fs_struct
> >      - files_struct
> >      - fdtable and fdtable->full_fds_bits
> >      - dentry and external_name
> >      - inode for all filesystems.
> > 
> > This should give us reasonable memory isolation for most common
> > workloads out of the box.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Thank you!

> The patch looks good to me, but I think we still need to add a boot-time
> knob to disable kmem accounting, as we do for sockets:
> 
> From: Vladimir Davydov <vdavydov@virtuozzo.com>
> Subject: [PATCH] mm: memcontrol: allow to disable kmem accounting for cgroup2
> 
> Kmem accounting might incur overhead that some users can't put up with.
> Besides, the implementation is still considered unstable. So let's
> provide a way to disable it for those users who aren't happy with it.
> 
> To disable kmem accounting for cgroup2, pass cgroup.memory=nokmem at
> boot time.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Especially in the early release phases, there might be birthing pain
that users in the field would want to work around. And I'd rather they
can selectively disable problematic parts during the transition than
switching back wholesale to the old cgroup interface.

For me that would be the prime reason: a temporary workaround for
legacy users until we get our stuff sorted out. Unacceptable overhead
or instability would be something we would have to address anyway.
And then it's fine too that the flag continues to use the historic
misnomer "kmem".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
