Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 58FFD6B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 16:26:22 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 136so29378022wmu.3
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 13:26:22 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g31si1024151edc.336.2017.10.09.13.26.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Oct 2017 13:26:21 -0700 (PDT)
Date: Mon, 9 Oct 2017 16:26:13 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171009202613.GA15027@cmpxchg.org>
References: <20171005222144.123797-1-shakeelb@google.com>
 <20171006075900.icqjx5rr7hctn3zd@dhcp22.suse.cz>
 <CALvZod7YN4JCG7Anm2FViyZ0-APYy+nxEd3nyxe5LT_P0FC9wg@mail.gmail.com>
 <20171009062426.hmqedtqz5hkmhnff@dhcp22.suse.cz>
 <xr93a810xl77.fsf@gthelen.svl.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93a810xl77.fsf@gthelen.svl.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 09, 2017 at 10:52:44AM -0700, Greg Thelen wrote:
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Fri 06-10-17 12:33:03, Shakeel Butt wrote:
> >> >>       names_cachep = kmem_cache_create("names_cache", PATH_MAX, 0,
> >> >> -                     SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
> >> >> +                     SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT, NULL);
> >> >
> >> > I might be wrong but isn't name cache only holding temporary objects
> >> > used for path resolution which are not stored anywhere?
> >> >
> >> 
> >> Even though they're temporary, many containers can together use a
> >> significant amount of transient uncharged memory. We've seen machines
> >> with 100s of MiBs in names_cache.
> >
> > Yes that might be possible but are we prepared for random ENOMEM from
> > vfs calls which need to allocate a temporary name?
> >
> >> 
> >> >>       filp_cachep = kmem_cache_create("filp", sizeof(struct file), 0,
> >> >> -                     SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
> >> >> +                     SLAB_HWCACHE_ALIGN | SLAB_PANIC | SLAB_ACCOUNT, NULL);
> >> >>       percpu_counter_init(&nr_files, 0, GFP_KERNEL);
> >> >>  }
> >> >
> >> > Don't we have a limit for the maximum number of open files?
> >> >
> >> 
> >> Yes, there is a system limit of maximum number of open files. However
> >> this limit is shared between different users on the system and one
> >> user can hog this resource. To cater that, we set the maximum limit
> >> very high and let the memory limit of each user limit the number of
> >> files they can open.
> >
> > Similarly here. Are all syscalls allocating a fd prepared to return
> > ENOMEM?
> >
> > -- 
> > Michal Hocko
> > SUSE Labs
> 
> Even before this patch I find memcg oom handling inconsistent.  Page
> cache pages trigger oom killer and may allow caller to succeed once the
> kernel retries.  But kmem allocations don't call oom killer.

It's consistent in the sense that only page faults enable the memcg
OOM killer. It's not the type of memory that decides, it's whether the
allocation context has a channel to communicate an error to userspace.

Whether userspace is able to handle -ENOMEM from syscalls was a voiced
concern at the time this patch was merged, although there haven't been
any reports so far, and it seemed like the lesser evil between that
and deadlocking the kernel.

If we could find a way to invoke the OOM killer safely, I would
welcome such patches.

> They surface errors to user space.  This makes memcg hard to use for
> memory overcommit because it's desirable for a high priority task to
> transparently kill a lower priority task using the memcg oom killer.
> 
> A few ideas on how to make it more flexible:
> 
> a) Go back to memcg oom killing within memcg charging.  This runs risk
>    of oom killing while caller holds locks which oom victim selection or
>    oom victim termination may need.  Google's been running this way for
>    a while.

We've had real-life reports of this breaking, so even if it works for
some people, I'd rather not revert to that way of doing things.

> b) Have every syscall return do something similar to page fault handler:
>    kmem allocations in oom memcg mark the current task as needing an oom
>    check return NULL.  If marked oom, syscall exit would use
>    mem_cgroup_oom_synchronize() before retrying the syscall.  Seems
>    risky.  I doubt every syscall is compatible with such a restart.

That sounds like a lateral move.

> c) Overcharge kmem to oom memcg and queue an async memcg limit checker,
>    which will oom kill if needed.

This makes the most sense to me. Architecturally, I imagine this would
look like b), with an OOM handler at the point of return to userspace,
except that we'd overcharge instead of retrying the syscall.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
