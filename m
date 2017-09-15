Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 17EC56B0038
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 17:08:32 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o77so4795613qke.1
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 14:08:32 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id n18si1854118qtf.239.2017.09.15.14.08.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 14:08:31 -0700 (PDT)
Date: Fri, 15 Sep 2017 14:08:07 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170915210807.GA5238@castle>
References: <20170911131742.16482-1-guro@fb.com>
 <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com>
 <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz>
 <20170913215607.GA19259@castle>
 <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz>
 <20170914160548.GA30441@castle>
 <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz>
 <20170915152301.GA29379@castle>
 <alpine.DEB.2.10.1709151249290.76069@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1709151249290.76069@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Sep 15, 2017 at 12:55:55PM -0700, David Rientjes wrote:
> On Fri, 15 Sep 2017, Roman Gushchin wrote:
> 
> > > But then you just enforce a structural restriction on your configuration
> > > because
> > > 	root
> > >         /  \
> > >        A    D
> > >       /\   
> > >      B  C
> > > 
> > > is a different thing than
> > > 	root
> > >         / | \
> > >        B  C  D
> > >
> > 
> > I actually don't have a strong argument against an approach to select
> > largest leaf or kill-all-set memcg. I think, in practice there will be
> > no much difference.
> > 
> > The only real concern I have is that then we have to do the same with
> > oom_priorities (select largest priority tree-wide), and this will limit
> > an ability to enforce the priority by parent cgroup.
> > 
> 
> Yes, oom_priority cannot select the largest priority tree-wide for exactly 
> that reason.  We need the ability to control from which subtree the kill 
> occurs in ancestor cgroups.  If multiple jobs are allocated their own 
> cgroups and they can own memory.oom_priority for their own subcontainers, 
> this becomes quite powerful so they can define their own oom priorities.   
> Otherwise, they can easily override the oom priorities of other cgroups.

I believe, it's a solvable problem: we can require CAP_SYS_RESOURCE to set
the oom_priority below parent's value, or something like this.

But it looks more complex, and I'm not sure there are real examples,
when we have to compare memcgs, which are on different levels
(or in different subtrees).

In any case, oom_priorities and size-based comparison should share the
same tree-walking policy. And I still would prefer comparing sizes and
priorities independently on each level.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
