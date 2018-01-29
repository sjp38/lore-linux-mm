Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id F3ABD6B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 17:16:27 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id t192so9360234iof.6
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 14:16:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 77sor7095445ioo.124.2018.01.29.14.16.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jan 2018 14:16:26 -0800 (PST)
Date: Mon, 29 Jan 2018 14:16:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2 2/3] mm, memcg: replace cgroup aware oom killer
 mount option with tunable
In-Reply-To: <20180126161735.b999356fbe96c0acd33aaa66@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1801291404060.29670@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com> <alpine.DEB.2.10.1801251552320.161808@chino.kir.corp.google.com> <alpine.DEB.2.10.1801251553030.161808@chino.kir.corp.google.com> <20180125160016.30e019e546125bb13b5b6b4f@linux-foundation.org>
 <alpine.DEB.2.10.1801261415090.15318@chino.kir.corp.google.com> <20180126143950.719912507bd993d92188877f@linux-foundation.org> <alpine.DEB.2.10.1801261441340.20954@chino.kir.corp.google.com> <20180126161735.b999356fbe96c0acd33aaa66@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 26 Jan 2018, Andrew Morton wrote:

> > > > -ECONFUSED.  We want to have a mount option that has the sole purpose of 
> > > > doing echo cgroup > /mnt/cgroup/memory.oom_policy?
> > > 
> > > Approximately.  Let me put it another way: can we modify your patchset
> > > so that the mount option remains, and continues to have a sufficiently
> > > same effect?  For backward compatibility.
> > > 
> > 
> > The mount option would exist solely to set the oom policy of the root mem 
> > cgroup, it would lose its effect of mandating that policy for any subtree 
> > since it would become configurable by the user if delegated.
> 
> Why can't we propagate the mount option into the subtrees?
> 
> If the user then alters that behaviour with new added-by-David tunables
> then fine, that's still backward compatible.
> 

It's not, if you look for the "groupoom" mount option it will specify two 
different things: the entire hierarchy is locked into a single per-cgroup 
usage comparison (Roman's original patchset), and entire hierarchy had an 
initial oom policy set which could have subsequently changed (my 
extension).  With memory.oom_policy you need to query what the effective 
policy is, checking for "groupoom" is entirely irrelevant, it was only the 
initial setting.

Thus, if memory.oom_policy is going to be merged in the future, it 
necessarily obsoletes the mount option.  It would depend on the kernel 
version to determine its meaning.

I'm struggling to see the benefit of simply not reviewing patches that 
build off the original and merging a patchset early.  What are we gaining?

> > Let me put it another way: if the cgroup aware oom killer is merged for 
> > 4.16 without this patchset, userspace can reasonably infer the oom policy 
> > from checking how cgroups were mounted.  If my followup patchset were 
> > merged for 4.17, that's invalid and it becomes dependent on kernel 
> > version: it could have the "groupoom" mount option but configured through 
> > the root mem cgroup's memory.oom_policy to not be cgroup aware at all.
> 
> That concern seems unreasonable to me.  Is an application *really*
> going to peek at the mount options to figure out what its present oom
> policy is?  Well, maybe.  But that's a pretty dopey thing to do and I
> wouldn't lose much sleep over breaking any such application in the very
> unlikely case that such a thing was developed in that two-month window.
> 

It's not dopey, it's the only way that any userspace can determine what 
process is going to be oom killed!  That policy will dictate how the 
cgroup hierarchy is configured without my extension, there's no other way 
to prefer or bias processes.

How can a userspace cgroup manager possibly construct a cgroup v2 
hierarchy with expected oom kill behavior if it is not peeking at the 
mount option?

My concern is that if extended with my patchset the mount option itself 
becomes obsolete and then peeking at it is irrelevant to the runtime 
behavior!

> > > There's nothing wrong with that!  As long as we don't break existing
> > > setups while evolving the feature.  How do we do that?
> > 
> > We'd break the setups that actually configure their cgroups and processes 
> > to abide by the current implementation since we'd need to discount 
> > oom_score_adj from the the root mem cgroup usage to fix it.
> 
> Am having trouble understanding that.  Expand, please?
> 
> Can we address this (and other such) issues in the (interim)
> documentation?
> 

This point isn't a documentation issue at all, this is the fact that 
oom_score_adj is only effective for the root mem cgroup.  If the user is 
fully aware of the implementation, it does not change the fact that he or 
she will construct their cgroup hierarchy and attach processes to it to 
abide by the behavior.  That is the breakage that I am concerned about.

An example: you have a log scraper that is running with 
/proc/pid/oom_score_adj == 999.  It's best effort, it can be killed, we'll 
retry the next time if the system has memory available.  This is partly 
why oom_adj and oom_score_adj exist and is used on production systems.

If you attach that process to an unlimited mem cgroup dedicated to system 
daemons purely for the rich stats that mem cgroup provides, this breaks 
the oom_score_adj setting solely because it's attached to the cgroup.  On 
system-wide oom, it is no longer the killed process merely because it is 
attached to an unlimited child cgroup.  This is not the only such example: 
this occurs for any process attached to a cgroup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
