Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 83E986B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:24:36 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id t5so1494507lfe.1
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 07:24:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 26si5012372wrz.265.2017.10.10.07.24.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 07:24:35 -0700 (PDT)
Date: Tue, 10 Oct 2017 16:24:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171010142434.bpiqmsbb7gttrlcb@dhcp22.suse.cz>
References: <20171005222144.123797-1-shakeelb@google.com>
 <20171006075900.icqjx5rr7hctn3zd@dhcp22.suse.cz>
 <CALvZod7YN4JCG7Anm2FViyZ0-APYy+nxEd3nyxe5LT_P0FC9wg@mail.gmail.com>
 <20171009062426.hmqedtqz5hkmhnff@dhcp22.suse.cz>
 <xr93a810xl77.fsf@gthelen.svl.corp.google.com>
 <20171009202613.GA15027@cmpxchg.org>
 <20171010091430.giflzlayvjblx5bu@dhcp22.suse.cz>
 <20171010141733.GB16710@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171010141733.GB16710@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue 10-10-17 10:17:33, Johannes Weiner wrote:
> On Tue, Oct 10, 2017 at 11:14:30AM +0200, Michal Hocko wrote:
> > On Mon 09-10-17 16:26:13, Johannes Weiner wrote:
> > > It's consistent in the sense that only page faults enable the memcg
> > > OOM killer. It's not the type of memory that decides, it's whether the
> > > allocation context has a channel to communicate an error to userspace.
> > > 
> > > Whether userspace is able to handle -ENOMEM from syscalls was a voiced
> > > concern at the time this patch was merged, although there haven't been
> > > any reports so far,
> > 
> > Well, I remember reports about MAP_POPULATE breaking or at least having
> > an unexpected behavior.
> 
> Hm, that slipped past me. Did we do something about these? Or did they
> fix userspace?

Well it was mostly LTP complaining. I have tried to fix that but Linus
was against so we just documented that this is possible and MAP_POPULATE
is not a guarantee.

> > Well, we should be able to do that with the oom_reaper. At least for v2
> > which doesn't have synchronous userspace oom killing.
> 
> I don't see how the OOM reaper is a guarantee as long as we have this:
> 
> 	if (!down_read_trylock(&mm->mmap_sem)) {
> 		ret = false;
> 		trace_skip_task_reaping(tsk->pid);
> 		goto unlock_oom;
> 	}

And we will simply mark the victim MMF_OOM_SKIP and hide it from the oom
killer if we fail to get the mmap_sem after several attempts. This will
allow to find a new victim. So we shouldn't deadlock.

> What do you mean by 'v2'?

cgroup v2 because the legacy memcg allowed sync wait for the oom killer
and that would be a bigger problem from a deep callchains for obevious
reasons.

> > > > c) Overcharge kmem to oom memcg and queue an async memcg limit checker,
> > > >    which will oom kill if needed.
> > > 
> > > This makes the most sense to me. Architecturally, I imagine this would
> > > look like b), with an OOM handler at the point of return to userspace,
> > > except that we'd overcharge instead of retrying the syscall.
> > 
> > I do not think we should break the hard limit semantic if possible. We
> > can currently allow that for allocations which are very short term (oom
> > victims) or too important to fail but allowing that for kmem charges in
> > general sounds like too easy to runaway.
> 
> I'm not sure there is a convenient way out of this.
> 
> If we want to respect the hard limit AND guarantee allocation success,
> the OOM killer has to free memory reliably - which it doesn't. But if
> it did, we could also break the limit temporarily and have the OOM
> killer replenish the pool before that userspace app can continue. The
> allocation wouldn't have to be short-lived, since memory is fungible.

If we can guarantee the oom killer is started then we can allow temporal
access to reserves which is already implemented even for memcg. The
thing is we do not invoke the oom killer...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
