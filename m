Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9658D6B0253
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 02:35:58 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q18so4986783wmg.18
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 23:35:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o67si426731wmg.104.2017.10.12.23.35.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Oct 2017 23:35:57 -0700 (PDT)
Date: Fri, 13 Oct 2017 08:35:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171013063555.pa7uco43mod7vrkn@dhcp22.suse.cz>
References: <20171005222144.123797-1-shakeelb@google.com>
 <20171006075900.icqjx5rr7hctn3zd@dhcp22.suse.cz>
 <CALvZod7YN4JCG7Anm2FViyZ0-APYy+nxEd3nyxe5LT_P0FC9wg@mail.gmail.com>
 <20171009062426.hmqedtqz5hkmhnff@dhcp22.suse.cz>
 <xr93a810xl77.fsf@gthelen.svl.corp.google.com>
 <20171009202613.GA15027@cmpxchg.org>
 <20171010091430.giflzlayvjblx5bu@dhcp22.suse.cz>
 <20171010141733.GB16710@cmpxchg.org>
 <20171010142434.bpiqmsbb7gttrlcb@dhcp22.suse.cz>
 <20171012190312.GA5075@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171012190312.GA5075@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu 12-10-17 15:03:12, Johannes Weiner wrote:
> On Tue, Oct 10, 2017 at 04:24:34PM +0200, Michal Hocko wrote:
[...]
> > And we will simply mark the victim MMF_OOM_SKIP and hide it from the oom
> > killer if we fail to get the mmap_sem after several attempts. This will
> > allow to find a new victim. So we shouldn't deadlock.
> 
> It's less likely to deadlock, but not exactly deadlock-free. There
> might not BE any other mm's holding significant amounts of memory.

true, try_charge would have to return with failure when out_of_memory
returns with false of course.

> > > What do you mean by 'v2'?
> > 
> > cgroup v2 because the legacy memcg allowed sync wait for the oom killer
> > and that would be a bigger problem from a deep callchains for obevious
> > reasons.
> 
> Actually, the async oom killing code isn't dependent on cgroup
> version. cgroup1 doesn't wait inside the charge context, either.

Sorry, I was just not clear. What I meant to say, would couldn't make v1
wait inside the try_charge path because async oom killing wouldn't help
for the oom disabled case (aka user space oom handling).

> > > > > > c) Overcharge kmem to oom memcg and queue an async memcg limit checker,
> > > > > >    which will oom kill if needed.
> > > > > 
> > > > > This makes the most sense to me. Architecturally, I imagine this would
> > > > > look like b), with an OOM handler at the point of return to userspace,
> > > > > except that we'd overcharge instead of retrying the syscall.
> > > > 
> > > > I do not think we should break the hard limit semantic if possible. We
> > > > can currently allow that for allocations which are very short term (oom
> > > > victims) or too important to fail but allowing that for kmem charges in
> > > > general sounds like too easy to runaway.
> > > 
> > > I'm not sure there is a convenient way out of this.
> > > 
> > > If we want to respect the hard limit AND guarantee allocation success,
> > > the OOM killer has to free memory reliably - which it doesn't. But if
> > > it did, we could also break the limit temporarily and have the OOM
> > > killer replenish the pool before that userspace app can continue. The
> > > allocation wouldn't have to be short-lived, since memory is fungible.
> > 
> > If we can guarantee the oom killer is started then we can allow temporal
> > access to reserves which is already implemented even for memcg. The
> > thing is we do not invoke the oom killer...
> 
> You lost me here. Which reserves?
> 
> All I'm saying is that, when the syscall-context fails to charge, we
> should do mem_cgroup_oom() to set up the async OOM killer, let the
> charge succeed over the hard limit - since the OOM killer will most
> likely get us back below the limit - then mem_cgroup_oom_synchronize()
> before the syscall returns to userspace.

OK, then we are on the same page now. Your initial wording didn't
mention async OOM killer. This makes more sense. Although I would argue
that we can retry the charge as long as out_of_memory finds a victim.
This would return ENOMEM to the pathological cases where no victims
could be found.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
