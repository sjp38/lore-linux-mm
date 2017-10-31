Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 999F26B0033
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 04:00:51 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id s66so7325313wmf.14
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 01:00:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 188si986761wmh.124.2017.10.31.01.00.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 01:00:50 -0700 (PDT)
Date: Tue, 31 Oct 2017 09:00:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171031080048.m4ajkq4g4uz4jwsh@dhcp22.suse.cz>
References: <20171024185854.GA6154@cmpxchg.org>
 <20171024201522.3z2fjnfywgx2egqx@dhcp22.suse.cz>
 <xr93r2tr67pp.fsf@gthelen.svl.corp.google.com>
 <20171025071522.xyw4lsvdv4xsbhbo@dhcp22.suse.cz>
 <20171025131151.GA8210@cmpxchg.org>
 <20171025141221.xm4cqp2z6nunr6vy@dhcp22.suse.cz>
 <20171025164402.GA11582@cmpxchg.org>
 <CALvZod5wiJvZw0yCS+KuDDYawUDAL=h0UBFXhY44FN84BsXrtA@mail.gmail.com>
 <20171030082916.x6xaqd4pgs2moy4y@dhcp22.suse.cz>
 <CALvZod65sU+wujxAR9AqTdbMHkHsMsOyfNXYf1t=w1BEpx5LHw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod65sU+wujxAR9AqTdbMHkHsMsOyfNXYf1t=w1BEpx5LHw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon 30-10-17 12:28:13, Shakeel Butt wrote:
> On Mon, Oct 30, 2017 at 1:29 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Fri 27-10-17 13:50:47, Shakeel Butt wrote:
> >> > Why is OOM-disabling a thing? Why isn't this simply a "kill everything
> >> > else before you kill me"? It's crashing the kernel in trying to
> >> > protect a userspace application. How is that not insane?
> >>
> >> In parallel to other discussion, I think we should definitely move
> >> from "completely oom-disabled" semantics to something similar to "kill
> >> me last" semantics. Is there any objection to this idea?
> >
> > Could you be more specific what you mean?
> >
> 
> I get the impression that the main reason behind the complexity of
> oom-killer is allowing processes to be protected from the oom-killer
> i.e. disabling oom-killing a process by setting
> /proc/[pid]/oom_score_adj to -1000. So, instead of oom-disabling, add
> an interface which will let users/admins to set a process to be
> oom-killed as a last resort.

If a process opts in to be oom disabled it needs CAP_SYS_RESOURCE and it
probably has a strong reason to do that. E.g. no unexpected SIGKILL
which could leave inconsistent data behind. We cannot simply break that
contract. Yes, it is a PITA configuration to support but it has its
reasons to exit. We are not guaranteeing it to 100% though, e.g. the
global case just panics if there is no eligible task. It is
responsibility of the userspace to make sure that the protected task
doesn't blow up completely otherwise they are on their own. We should do
something similar for the memcg case. Protect those tasks as long as we
are able to make forward progress and then either give them ENOMEM or
overcharge. Which one to go requires more discussion but I do not think
that unexpected SIGKILL is a way to go. We just want to give those tasks
a chance to do a graceful shutdown.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
