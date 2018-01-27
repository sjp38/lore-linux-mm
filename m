Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id ECFC96B002C
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 19:17:39 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 31so1134442wri.9
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 16:17:39 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o189si3331098wmo.187.2018.01.26.16.17.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jan 2018 16:17:38 -0800 (PST)
Date: Fri, 26 Jan 2018 16:17:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm v2 2/3] mm, memcg: replace cgroup aware oom killer
 mount option with tunable
Message-Id: <20180126161735.b999356fbe96c0acd33aaa66@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1801261441340.20954@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1801251552320.161808@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1801251553030.161808@chino.kir.corp.google.com>
	<20180125160016.30e019e546125bb13b5b6b4f@linux-foundation.org>
	<alpine.DEB.2.10.1801261415090.15318@chino.kir.corp.google.com>
	<20180126143950.719912507bd993d92188877f@linux-foundation.org>
	<alpine.DEB.2.10.1801261441340.20954@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 26 Jan 2018 14:52:59 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> On Fri, 26 Jan 2018, Andrew Morton wrote:
> 
> > > -ECONFUSED.  We want to have a mount option that has the sole purpose of 
> > > doing echo cgroup > /mnt/cgroup/memory.oom_policy?
> > 
> > Approximately.  Let me put it another way: can we modify your patchset
> > so that the mount option remains, and continues to have a sufficiently
> > same effect?  For backward compatibility.
> > 
> 
> The mount option would exist solely to set the oom policy of the root mem 
> cgroup, it would lose its effect of mandating that policy for any subtree 
> since it would become configurable by the user if delegated.

Why can't we propagate the mount option into the subtrees?

If the user then alters that behaviour with new added-by-David tunables
then fine, that's still backward compatible.

> Let me put it another way: if the cgroup aware oom killer is merged for 
> 4.16 without this patchset, userspace can reasonably infer the oom policy 
> from checking how cgroups were mounted.  If my followup patchset were 
> merged for 4.17, that's invalid and it becomes dependent on kernel 
> version: it could have the "groupoom" mount option but configured through 
> the root mem cgroup's memory.oom_policy to not be cgroup aware at all.

That concern seems unreasonable to me.  Is an application *really*
going to peek at the mount options to figure out what its present oom
policy is?  Well, maybe.  But that's a pretty dopey thing to do and I
wouldn't lose much sleep over breaking any such application in the very
unlikely case that such a thing was developed in that two-month window.

If that's really a concern then let's add (to Roman's patchset) a
proper interface for an application to query its own oom policy.

> That inconsistency, to me, is unfair to burden userspace with.
> 
> > > This, and fixes to fairly compare the root mem cgroup with leaf mem 
> > > cgroups, are essential before the feature is merged otherwise it yields 
> > > wildly unpredictable (and unexpected, since its interaction with 
> > > oom_score_adj isn't documented) results as I already demonstrated where 
> > > cgroups with 1GB of usage are killed instead of 6GB workers outside of 
> > > that subtree.
> > 
> > OK, so Roman's new feature is incomplete: it satisfies some use cases
> > but not others.  And we kinda have a plan to address the other use
> > cases in the future.
> > 
> 
> Those use cases are also undocumented such that the user doesn't know the 
> behavior they are opting into.  Nowhere in the patchset does it mention 
> anything about oom_score_adj other than being oom disabled.  It doesn't 
> mention that a per-process tunable now depends strictly on whether it is 
> attached to root or not.  It specifies a fair comparison between the root 
> mem cgroup and leaf mem cgroups, which is obviously incorrect by the 
> implementation itself.  So I'm not sure the user would know which use 
> cases it is valid for, which is why I've been trying to make it generally 
> purposeful and documented.

Documentation patches are nice.  We can cc:stable them too, so no huge
hurry.

> > There's nothing wrong with that!  As long as we don't break existing
> > setups while evolving the feature.  How do we do that?
> > 
> 
> We'd break the setups that actually configure their cgroups and processes 
> to abide by the current implementation since we'd need to discount 
> oom_score_adj from the the root mem cgroup usage to fix it.

Am having trouble understanding that.  Expand, please?

Can we address this (and other such) issues in the (interim)
documentation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
