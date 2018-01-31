Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 00F456B0005
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 04:47:22 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 33so10419652wrs.3
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 01:47:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t185si4549915wmf.51.2018.01.31.01.47.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Jan 2018 01:47:20 -0800 (PST)
Date: Wed, 31 Jan 2018 10:47:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm v2 1/3] mm, memcg: introduce per-memcg oom policy
 tunable
Message-ID: <20180131094717.GR21609@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801251552320.161808@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801251552490.161808@chino.kir.corp.google.com>
 <20180126171548.GB16763@dhcp22.suse.cz>
 <alpine.DEB.2.10.1801291418150.29670@chino.kir.corp.google.com>
 <20180130085013.GP21609@dhcp22.suse.cz>
 <alpine.DEB.2.10.1801301413080.148885@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1801301413080.148885@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 30-01-18 14:38:40, David Rientjes wrote:
> On Tue, 30 Jan 2018, Michal Hocko wrote:
> 
> > > > So what is the actual semantic and scope of this policy. Does it apply
> > > > only down the hierarchy. Also how do you compare cgroups with different
> > > > policies? Let's say you have
> > > >           root
> > > >          / |  \
> > > >         A  B   C
> > > >        / \    / \
> > > >       D   E  F   G
> > > > 
> > > > Assume A: cgroup, B: oom_group=1, C: tree, G: oom_group=1
> > > > 
> > > 
> > > At each level of the hierarchy, memory.oom_policy compares immediate 
> > > children, it's the only way that an admin can lock in a specific oom 
> > > policy like "tree" and then delegate the subtree to the user.  If you've 
> > > configured it as above, comparing A and C should be the same based on the 
> > > cumulative usage of their child mem cgroups.
> > 
> > So cgroup == tree if we are memcg aware OOM killing, right? Why do we
> > need both then? Just to make memcg aware OOM killing possible?
> > 
> 
> We need "tree" to account the usage of the subtree rather than simply the 
> cgroup alone, but "cgroup" and "tree" are accounted with the same units.  
> In your example, D and E are treated as individual memory consumers and C 
> is treated as the sum of all subtree memory consumers.

It seems I am still not clear with my question. What kind of difference
does policy=cgroup vs. none on A? Also what kind of different does it
make when a leaf node has cgroup policy?

[...]

> > So now you have a killable cgroup selected by process criterion? That
> > just doesn't make any sense. So I guess it would at least require to
> > enforce (cgroup || tree) to allow oom_group.
> > 
> 
> Hmm, I'm not sure why we would limit memory.oom_group to any policy.  Even 
> if we are selecting a process, even without selecting cgroups as victims, 
> killing a process may still render an entire cgroup useless and it makes 
> sense to kill all processes in that cgroup.  If an unlucky process is 
> selected with today's heursitic of oom_badness() or with a "none" policy 
> with my patchset, I don't see why we can't enable the user to kill all 
> other processes in the cgroup.  It may not make sense for some trees, but 
> but I think it could be useful for others.

My intuition screams here. I will think about this some more but I would
be really curious about any sensible usecase when you want sacrifice the
whole gang just because of one process compared to other processes or
cgroups is too large. Do you see how you are mixing entities here?

> > > Right, a policy of "none" reverts its subtree back to per-process 
> > > comparison if you are either not using the cgroup aware oom killer or your 
> > > subtree is not using the cgroup aware oom killer.
> > 
> > So how are you going to compare none cgroups with those that consider
> > full memcg or hierarchy (cgroup, tree)? Are you going to consider
> > oom_score_adj?
> > 
> 
> No, I think it would make sense to make the restriction that to set 
> "none", the ancestor mem cgroups would also need the same policy,

I do not understand. Get back to our example. Are you saying that G
with none will enforce the none policy to C and root? If yes then this
doesn't make any sense because you are not really able to delegate the
oom policy down the tree at all. It would effectively make tree policy
pointless.

I am skipping the rest of the following text because it is picking
on details and the whole design is not clear to me. So could you start
over documenting semantic and requirements. Ideally by describing:
- how does the policy on the root of the OOM hierarchy controls the
  selection policy
- how does the per-memcg policy act during the tree walk - for both
  intermediate nodes and leafs
- how does the oom killer act based on the selected memcg
- how do you compare tasks with memcgs

[...]

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
