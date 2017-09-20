Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 88C406B02CD
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 18:24:32 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id i50so4692201qtf.0
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 15:24:32 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id p4si1194238qkc.285.2017.09.20.15.24.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 15:24:31 -0700 (PDT)
Date: Wed, 20 Sep 2017 15:24:03 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170920222403.GA4729@castle>
References: <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com>
 <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz>
 <20170913215607.GA19259@castle>
 <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz>
 <20170914160548.GA30441@castle>
 <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz>
 <20170915152301.GA29379@castle>
 <alpine.DEB.2.10.1709151249290.76069@chino.kir.corp.google.com>
 <20170915210807.GA5238@castle>
 <alpine.DEB.2.10.1709191351330.7458@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1709191351330.7458@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 19, 2017 at 01:54:48PM -0700, David Rientjes wrote:
> On Fri, 15 Sep 2017, Roman Gushchin wrote:
> 
> > > > > But then you just enforce a structural restriction on your configuration
> > > > > because
> > > > > 	root
> > > > >         /  \
> > > > >        A    D
> > > > >       /\   
> > > > >      B  C
> > > > > 
> > > > > is a different thing than
> > > > > 	root
> > > > >         / | \
> > > > >        B  C  D
> > > > >
> > > > 
> > > > I actually don't have a strong argument against an approach to select
> > > > largest leaf or kill-all-set memcg. I think, in practice there will be
> > > > no much difference.
> > > > 
> > > > The only real concern I have is that then we have to do the same with
> > > > oom_priorities (select largest priority tree-wide), and this will limit
> > > > an ability to enforce the priority by parent cgroup.
> > > > 
> > > 
> > > Yes, oom_priority cannot select the largest priority tree-wide for exactly 
> > > that reason.  We need the ability to control from which subtree the kill 
> > > occurs in ancestor cgroups.  If multiple jobs are allocated their own 
> > > cgroups and they can own memory.oom_priority for their own subcontainers, 
> > > this becomes quite powerful so they can define their own oom priorities.   
> > > Otherwise, they can easily override the oom priorities of other cgroups.
> > 
> > I believe, it's a solvable problem: we can require CAP_SYS_RESOURCE to set
> > the oom_priority below parent's value, or something like this.
> > 
> > But it looks more complex, and I'm not sure there are real examples,
> > when we have to compare memcgs, which are on different levels
> > (or in different subtrees).
> > 
> 
> It's actually much more complex because in our environment we'd need an 
> "activity manager" with CAP_SYS_RESOURCE to control oom priorities of user 
> subcontainers when today it need only be concerned with top-level memory 
> cgroups.  Users can create their own hierarchies with their own oom 
> priorities at will, it doesn't alter the selection heuristic for another 
> other user running on the same system and gives them full control over the 
> selection in their own subtree.  We shouldn't need to have a system-wide 
> daemon with CAP_SYS_RESOURCE be required to manage subcontainers when 
> nothing else requires it.  I believe it's also much easier to document: 
> oom_priority is considered for all sibling cgroups at each level of the 
> hierarchy and the cgroup with the lowest priority value gets iterated.

I do agree actually. System-wide OOM priorities make no sense.

Always compare sibling cgroups, either by priority or size, seems to be
simple, clear and powerful enough for all reasonable use cases. Am I right,
that it's exactly what you've used internally? This is a perfect confirmation,
I believe.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
