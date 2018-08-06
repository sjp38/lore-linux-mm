Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 640ED6B000E
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 05:48:30 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t17-v6so4014315edr.21
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 02:48:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b40-v6si899936edf.140.2018.08.06.02.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 02:48:29 -0700 (PDT)
Date: Mon, 6 Aug 2018 11:48:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WARNING in try_charge
Message-ID: <20180806094827.GH19540@dhcp22.suse.cz>
References: <0000000000005e979605729c1564@google.com>
 <20180806091552.GE19540@dhcp22.suse.cz>
 <CACT4Y+Ystnwv4M6Uh+HBKbdADAnJ6otfR0GoA20crzqV+b2onQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Ystnwv4M6Uh+HBKbdADAnJ6otfR0GoA20crzqV+b2onQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Mon 06-08-18 11:30:37, Dmitry Vyukov wrote:
> On Mon, Aug 6, 2018 at 11:15 AM, Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > More interesting stuff is higher in the kernel log
> > : [  366.435015] oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),cpuset=/,mems_allowed=0,oom_memcg=/ile0,task_memcg=/ile0,task=syz-executor3,pid=23766,uid=0
> > : [  366.449416] memory: usage 112kB, limit 0kB, failcnt 1605
> >
> > Are you sure you want to have hard limit set to 0?
> 
> syzkaller really does not mind to have it.

So what do you use it for? What do you actually test by this setting?

[...]
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 4603ad75c9a9..852cd3dbdcd9 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1388,6 +1388,8 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> >         bool ret;
> >
> >         mutex_lock(&oom_lock);
> > +       pr_info("task=%s pid=%d invoked memcg oom killer. oom_victim=%d\n",
> > +                       current->comm, current->pid, tsk_is_oom_victim(current));
> >         ret = out_of_memory(&oc);
> >         mutex_unlock(&oom_lock);
> >         return ret;
> >
> > Anyway your memcg setup is indeed misconfigured. Memcg with 0 hard limit
> > and basically no memory charged by existing tasks is not going to fly
> > and the warning is exactly to call that out.
> 
> 
> Please-please-please do not mix kernel bugs and notices to user into
> the same bucket:

Well, WARN_ON used to be a standard way to make user aware of a
misbehavior. In this case it warns about a pottential runaway when memcg
is misconfigured. I do not insist on using WARN_ON here of course. If
there is a general agreement that such a condition is better handled by
pr_err then I am fine with it. Users tend to be more sensitive on
WARN_ONs though.

Btw. running with the above diff on top might help us to ideantify
whether this is a pre-mature warning or a valid one. Still useful to
find out.
-- 
Michal Hocko
SUSE Labs
