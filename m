Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id CD1CD6B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 16:12:16 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id p138so1664828itp.12
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 13:12:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x127sor1942726itf.78.2017.10.25.13.12.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Oct 2017 13:12:15 -0700 (PDT)
Date: Wed, 25 Oct 2017 13:12:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RESEND v12 0/6] cgroup-aware OOM killer
In-Reply-To: <20171023114948.qzmo7emqbigfff7h@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1710251308420.99765@chino.kir.corp.google.com>
References: <20171019185218.12663-1-guro@fb.com> <20171019194534.GA5502@cmpxchg.org> <alpine.DEB.2.10.1710221715010.70210@chino.kir.corp.google.com> <20171023114948.qzmo7emqbigfff7h@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>

On Mon, 23 Oct 2017, Michal Hocko wrote:

> On Sun 22-10-17 17:24:51, David Rientjes wrote:
> > On Thu, 19 Oct 2017, Johannes Weiner wrote:
> > 
> > > David would have really liked for this patchset to include knobs to
> > > influence how the algorithm picks cgroup victims. The rest of us
> > > agreed that this is beyond the scope of these patches, that the
> > > patches don't need it to be useful, and that there is nothing
> > > preventing anyone from adding configurability later on. David
> > > subsequently nacked the series as he considers it incomplete. Neither
> > > Michal nor I see technical merit in David's nack.
> > > 
> > 
> > The nack is for three reasons:
> > 
> >  (1) unfair comparison of root mem cgroup usage to bias against that mem 
> >      cgroup from oom kill in system oom conditions,
> 
> Most users who are going to use this feature right now will have
> most of the userspace in their containers rather than in the root
> memcg. The root memcg will always be special and as such there will
> never be a universal best way to handle it. We should to satisfy most of
> usecases. I would consider this something that is an open for a further
> discussion but nothing that should stand in the way.
>  
> >  (2) the ability of users to completely evade the oom killer by attaching
> >      all processes to child cgroups either purposefully or unpurposefully,
> >      and
> 
> This doesn't differ from the current state where a task can purposefully
> or unpurposefully hide itself from the global memory killer by spawning
> new processes.
>  

It cannot hide from the global oom killer if this patchset is used because 
it cannot hide its memory usage beneath cgroup levels.  This comment is in 
support of accounting memory usage up the hierarchy.

> >  (3) the inability of userspace to effectively control oom victim  
> >      selection.
> 
> this is not requested by the current usecase and it has been pointed out
> that this will be possible to implement on top of the foundation of this
> patchset.
> 

There's no reason to not present a complete patchset.  Userspace needs the 
ability to bias or prefer processes (or cgroups, in this case).  That's 
been the case with oom_adj in the past and oom_score_adj with the 
rewritten heuristic.  It's trivial to implement and the only pending 
suggestion to do this influence involves a slightly different scoring 
mechanism than this patchset; it goes back to accounting memory up the 
hierarchy as Roman initially implemented and then biasing between cgroups 
based on an oom_score_adj.  So the proposed influence mechanism cannot be 
implemented on top of this patchset as is, and that gives more reason why 
we cannot merge incomplete patches that can't be extended in the future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
