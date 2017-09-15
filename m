Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B12C46B0038
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 15:55:58 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 188so6236111pgb.3
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 12:55:58 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f4sor698949pgr.191.2017.09.15.12.55.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Sep 2017 12:55:57 -0700 (PDT)
Date: Fri, 15 Sep 2017 12:55:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
In-Reply-To: <20170915152301.GA29379@castle>
Message-ID: <alpine.DEB.2.10.1709151249290.76069@chino.kir.corp.google.com>
References: <20170911131742.16482-1-guro@fb.com> <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com> <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz> <20170913215607.GA19259@castle> <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz>
 <20170914160548.GA30441@castle> <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz> <20170915152301.GA29379@castle>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 15 Sep 2017, Roman Gushchin wrote:

> > But then you just enforce a structural restriction on your configuration
> > because
> > 	root
> >         /  \
> >        A    D
> >       /\   
> >      B  C
> > 
> > is a different thing than
> > 	root
> >         / | \
> >        B  C  D
> >
> 
> I actually don't have a strong argument against an approach to select
> largest leaf or kill-all-set memcg. I think, in practice there will be
> no much difference.
> 
> The only real concern I have is that then we have to do the same with
> oom_priorities (select largest priority tree-wide), and this will limit
> an ability to enforce the priority by parent cgroup.
> 

Yes, oom_priority cannot select the largest priority tree-wide for exactly 
that reason.  We need the ability to control from which subtree the kill 
occurs in ancestor cgroups.  If multiple jobs are allocated their own 
cgroups and they can own memory.oom_priority for their own subcontainers, 
this becomes quite powerful so they can define their own oom priorities.   
Otherwise, they can easily override the oom priorities of other cgroups.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
