Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C38A66B0253
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 12:50:07 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g90so10243317wrd.14
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 09:50:07 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n26si1823898edn.393.2017.10.31.09.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 31 Oct 2017 09:50:06 -0700 (PDT)
Date: Tue, 31 Oct 2017 12:49:59 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171031164959.GB32246@cmpxchg.org>
References: <20171024201522.3z2fjnfywgx2egqx@dhcp22.suse.cz>
 <xr93r2tr67pp.fsf@gthelen.svl.corp.google.com>
 <20171025071522.xyw4lsvdv4xsbhbo@dhcp22.suse.cz>
 <20171025131151.GA8210@cmpxchg.org>
 <20171025141221.xm4cqp2z6nunr6vy@dhcp22.suse.cz>
 <20171025164402.GA11582@cmpxchg.org>
 <CALvZod5wiJvZw0yCS+KuDDYawUDAL=h0UBFXhY44FN84BsXrtA@mail.gmail.com>
 <20171030082916.x6xaqd4pgs2moy4y@dhcp22.suse.cz>
 <CALvZod65sU+wujxAR9AqTdbMHkHsMsOyfNXYf1t=w1BEpx5LHw@mail.gmail.com>
 <20171031080048.m4ajkq4g4uz4jwsh@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171031080048.m4ajkq4g4uz4jwsh@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Oct 31, 2017 at 09:00:48AM +0100, Michal Hocko wrote:
> On Mon 30-10-17 12:28:13, Shakeel Butt wrote:
> > On Mon, Oct 30, 2017 at 1:29 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > > On Fri 27-10-17 13:50:47, Shakeel Butt wrote:
> > >> > Why is OOM-disabling a thing? Why isn't this simply a "kill everything
> > >> > else before you kill me"? It's crashing the kernel in trying to
> > >> > protect a userspace application. How is that not insane?
> > >>
> > >> In parallel to other discussion, I think we should definitely move
> > >> from "completely oom-disabled" semantics to something similar to "kill
> > >> me last" semantics. Is there any objection to this idea?
> > >
> > > Could you be more specific what you mean?
> > 
> > I get the impression that the main reason behind the complexity of
> > oom-killer is allowing processes to be protected from the oom-killer
> > i.e. disabling oom-killing a process by setting
> > /proc/[pid]/oom_score_adj to -1000. So, instead of oom-disabling, add
> > an interface which will let users/admins to set a process to be
> > oom-killed as a last resort.
> 
> If a process opts in to be oom disabled it needs CAP_SYS_RESOURCE and it
> probably has a strong reason to do that. E.g. no unexpected SIGKILL
> which could leave inconsistent data behind. We cannot simply break that
> contract. Yes, it is a PITA configuration to support but it has its
> reasons to exit.

I don't think that's true. The most prominent users are things like X
and sshd, and all they wanted to say was "kill me last."

If sshd were to have a bug and swell up, currently the system would
kill everything and then panic. It'd be much better to kill sshd at
the end and let the init system restart it.

Can you describe a scenario in which the NEVERKILL semantics actually
make sense? You're still OOM-killing the task anyway, it's not like it
can run without the kernel. So why kill the kernel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
