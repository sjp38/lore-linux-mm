Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF16A6B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 19:57:26 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 76so5436248pfr.3
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 16:57:26 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v68sor3664408pfb.42.2017.10.12.16.57.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Oct 2017 16:57:25 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
In-Reply-To: <20171012190312.GA5075@cmpxchg.org>
References: <20171005222144.123797-1-shakeelb@google.com> <20171006075900.icqjx5rr7hctn3zd@dhcp22.suse.cz> <CALvZod7YN4JCG7Anm2FViyZ0-APYy+nxEd3nyxe5LT_P0FC9wg@mail.gmail.com> <20171009062426.hmqedtqz5hkmhnff@dhcp22.suse.cz> <xr93a810xl77.fsf@gthelen.svl.corp.google.com> <20171009202613.GA15027@cmpxchg.org> <20171010091430.giflzlayvjblx5bu@dhcp22.suse.cz> <20171010141733.GB16710@cmpxchg.org> <20171010142434.bpiqmsbb7gttrlcb@dhcp22.suse.cz> <20171012190312.GA5075@cmpxchg.org>
Date: Thu, 12 Oct 2017 16:57:22 -0700
Message-ID: <xr937evzyl5p.fsf@gthelen.svl.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Tue, Oct 10, 2017 at 04:24:34PM +0200, Michal Hocko wrote:
>> On Tue 10-10-17 10:17:33, Johannes Weiner wrote:
>> > On Tue, Oct 10, 2017 at 11:14:30AM +0200, Michal Hocko wrote:
>> > > On Mon 09-10-17 16:26:13, Johannes Weiner wrote:
>> > > > It's consistent in the sense that only page faults enable the memcg
>> > > > OOM killer. It's not the type of memory that decides, it's whether the
>> > > > allocation context has a channel to communicate an error to userspace.
>> > > > 
>> > > > Whether userspace is able to handle -ENOMEM from syscalls was a voiced
>> > > > concern at the time this patch was merged, although there haven't been
>> > > > any reports so far,
>> > > 
>> > > Well, I remember reports about MAP_POPULATE breaking or at least having
>> > > an unexpected behavior.
>> > 
>> > Hm, that slipped past me. Did we do something about these? Or did they
>> > fix userspace?
>> 
>> Well it was mostly LTP complaining. I have tried to fix that but Linus
>> was against so we just documented that this is possible and MAP_POPULATE
>> is not a guarantee.
>
> Okay, makes sense. I wouldn't really count that as a regression.
>
>> > > Well, we should be able to do that with the oom_reaper. At least for v2
>> > > which doesn't have synchronous userspace oom killing.
>> > 
>> > I don't see how the OOM reaper is a guarantee as long as we have this:
>> > 
>> > 	if (!down_read_trylock(&mm->mmap_sem)) {
>> > 		ret = false;
>> > 		trace_skip_task_reaping(tsk->pid);
>> > 		goto unlock_oom;
>> > 	}
>> 
>> And we will simply mark the victim MMF_OOM_SKIP and hide it from the oom
>> killer if we fail to get the mmap_sem after several attempts. This will
>> allow to find a new victim. So we shouldn't deadlock.
>
> It's less likely to deadlock, but not exactly deadlock-free. There
> might not BE any other mm's holding significant amounts of memory.
>
>> > What do you mean by 'v2'?
>> 
>> cgroup v2 because the legacy memcg allowed sync wait for the oom killer
>> and that would be a bigger problem from a deep callchains for obevious
>> reasons.
>
> Actually, the async oom killing code isn't dependent on cgroup
> version. cgroup1 doesn't wait inside the charge context, either.
>
>> > > > > c) Overcharge kmem to oom memcg and queue an async memcg limit checker,
>> > > > >    which will oom kill if needed.
>> > > > 
>> > > > This makes the most sense to me. Architecturally, I imagine this would
>> > > > look like b), with an OOM handler at the point of return to userspace,
>> > > > except that we'd overcharge instead of retrying the syscall.
>> > > 
>> > > I do not think we should break the hard limit semantic if possible. We
>> > > can currently allow that for allocations which are very short term (oom
>> > > victims) or too important to fail but allowing that for kmem charges in
>> > > general sounds like too easy to runaway.
>> > 
>> > I'm not sure there is a convenient way out of this.
>> > 
>> > If we want to respect the hard limit AND guarantee allocation success,
>> > the OOM killer has to free memory reliably - which it doesn't. But if
>> > it did, we could also break the limit temporarily and have the OOM
>> > killer replenish the pool before that userspace app can continue. The
>> > allocation wouldn't have to be short-lived, since memory is fungible.
>> 
>> If we can guarantee the oom killer is started then we can allow temporal
>> access to reserves which is already implemented even for memcg. The
>> thing is we do not invoke the oom killer...
>
> You lost me here. Which reserves?
>
> All I'm saying is that, when the syscall-context fails to charge, we
> should do mem_cgroup_oom() to set up the async OOM killer, let the
> charge succeed over the hard limit - since the OOM killer will most
> likely get us back below the limit - then mem_cgroup_oom_synchronize()
> before the syscall returns to userspace.
>
> That would avoid returning -ENOMEM from syscalls without the risk of
> the hard limit deadlocking - at the risk of sometimes overrunning the
> hard limit, but that seems like the least problematic behavior out of
> the three.

Overcharging kmem with deferred reconciliation sounds good to me.

A few comments (not reasons to avoid this):

1) If a task is moved between memcg it seems possible to overcharge
   multiple oom memcg for different kmem/user allocations.
   mem_cgroup_oom_synchronize() would see at most one oom memcg in
   current->memcg_in_oom.  Thus it'd only reconcile a single memcg.  But
   that seems pretty rare and the next charge to any of the other memcg
   would reconcile them.

2) if a kernel thread charges kmem on behalf of a client mm then there
   is no good place to call mem_cgroup_oom_synchronize(), short of
   launching a work item in mem_cgroup_oom().  I don't we have anything
   like that yet.  So nothing to worry about.

3) it's debatable if mem_cgroup_oom_synchronize() should first attempt
   reclaim before killing.  But that's a whole 'nother thread.

4) overcharging with deferred reconciliation could also be used for user
   pages.  But I haven't looked at the code long enough to know if this
   would be a net win.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
