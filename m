Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 29D856B0260
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 05:14:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id q203so30805980wmb.0
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 02:14:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 20si6444904wms.91.2017.10.10.02.14.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 02:14:33 -0700 (PDT)
Date: Tue, 10 Oct 2017 11:14:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171010091430.giflzlayvjblx5bu@dhcp22.suse.cz>
References: <20171005222144.123797-1-shakeelb@google.com>
 <20171006075900.icqjx5rr7hctn3zd@dhcp22.suse.cz>
 <CALvZod7YN4JCG7Anm2FViyZ0-APYy+nxEd3nyxe5LT_P0FC9wg@mail.gmail.com>
 <20171009062426.hmqedtqz5hkmhnff@dhcp22.suse.cz>
 <xr93a810xl77.fsf@gthelen.svl.corp.google.com>
 <20171009202613.GA15027@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171009202613.GA15027@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon 09-10-17 16:26:13, Johannes Weiner wrote:
> On Mon, Oct 09, 2017 at 10:52:44AM -0700, Greg Thelen wrote:
> > Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > > On Fri 06-10-17 12:33:03, Shakeel Butt wrote:
> > >> >>       names_cachep = kmem_cache_create("names_cache", PATH_MAX, 0,
> > >> >> -                     SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
> > >> >> +                     SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT, NULL);
> > >> >
> > >> > I might be wrong but isn't name cache only holding temporary objects
> > >> > used for path resolution which are not stored anywhere?
> > >> >
> > >> 
> > >> Even though they're temporary, many containers can together use a
> > >> significant amount of transient uncharged memory. We've seen machines
> > >> with 100s of MiBs in names_cache.
> > >
> > > Yes that might be possible but are we prepared for random ENOMEM from
> > > vfs calls which need to allocate a temporary name?
> > >
> > >> 
> > >> >>       filp_cachep = kmem_cache_create("filp", sizeof(struct file), 0,
> > >> >> -                     SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
> > >> >> +                     SLAB_HWCACHE_ALIGN | SLAB_PANIC | SLAB_ACCOUNT, NULL);
> > >> >>       percpu_counter_init(&nr_files, 0, GFP_KERNEL);
> > >> >>  }
> > >> >
> > >> > Don't we have a limit for the maximum number of open files?
> > >> >
> > >> 
> > >> Yes, there is a system limit of maximum number of open files. However
> > >> this limit is shared between different users on the system and one
> > >> user can hog this resource. To cater that, we set the maximum limit
> > >> very high and let the memory limit of each user limit the number of
> > >> files they can open.
> > >
> > > Similarly here. Are all syscalls allocating a fd prepared to return
> > > ENOMEM?
> > >
> > > -- 
> > > Michal Hocko
> > > SUSE Labs
> > 
> > Even before this patch I find memcg oom handling inconsistent.  Page
> > cache pages trigger oom killer and may allow caller to succeed once the
> > kernel retries.  But kmem allocations don't call oom killer.
> 
> It's consistent in the sense that only page faults enable the memcg
> OOM killer. It's not the type of memory that decides, it's whether the
> allocation context has a channel to communicate an error to userspace.
> 
> Whether userspace is able to handle -ENOMEM from syscalls was a voiced
> concern at the time this patch was merged, although there haven't been
> any reports so far,

Well, I remember reports about MAP_POPULATE breaking or at least having
an unexpected behavior.

> and it seemed like the lesser evil between that
> and deadlocking the kernel.

agreed on this part though

> If we could find a way to invoke the OOM killer safely, I would
> welcome such patches.

Well, we should be able to do that with the oom_reaper. At least for v2
which doesn't have synchronous userspace oom killing.

[...]

> > c) Overcharge kmem to oom memcg and queue an async memcg limit checker,
> >    which will oom kill if needed.
> 
> This makes the most sense to me. Architecturally, I imagine this would
> look like b), with an OOM handler at the point of return to userspace,
> except that we'd overcharge instead of retrying the syscall.

I do not think we should break the hard limit semantic if possible. We
can currently allow that for allocations which are very short term (oom
victims) or too important to fail but allowing that for kmem charges in
general sounds like too easy to runaway.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
