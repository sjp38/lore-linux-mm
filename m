Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C3A246B0009
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 05:11:12 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g69so2707168ita.9
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 02:11:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s126sor1068705itd.132.2018.02.01.02.11.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Feb 2018 02:11:11 -0800 (PST)
Date: Thu, 1 Feb 2018 02:11:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2 1/3] mm, memcg: introduce per-memcg oom policy
 tunable
In-Reply-To: <20180131094717.GR21609@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1802010159570.175600@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com> <alpine.DEB.2.10.1801251552320.161808@chino.kir.corp.google.com> <alpine.DEB.2.10.1801251552490.161808@chino.kir.corp.google.com> <20180126171548.GB16763@dhcp22.suse.cz>
 <alpine.DEB.2.10.1801291418150.29670@chino.kir.corp.google.com> <20180130085013.GP21609@dhcp22.suse.cz> <alpine.DEB.2.10.1801301413080.148885@chino.kir.corp.google.com> <20180131094717.GR21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 31 Jan 2018, Michal Hocko wrote:

> > > > >           root
> > > > >          / |  \
> > > > >         A  B   C
> > > > >        / \    / \
> > > > >       D   E  F   G
> > > > > 
> > > > > Assume A: cgroup, B: oom_group=1, C: tree, G: oom_group=1
> > > > > 
> > > > 
> > > > At each level of the hierarchy, memory.oom_policy compares immediate 
> > > > children, it's the only way that an admin can lock in a specific oom 
> > > > policy like "tree" and then delegate the subtree to the user.  If you've 
> > > > configured it as above, comparing A and C should be the same based on the 
> > > > cumulative usage of their child mem cgroups.
> > > 
> It seems I am still not clear with my question. What kind of difference
> does policy=cgroup vs. none on A? Also what kind of different does it
> make when a leaf node has cgroup policy?
> 

If A has an oom policy of "cgroup" it will be comparing the local usage of 
D vs E, "tree" would be the same since neither descendants have child 
cgroups.  If A has an oom policy of "none" it would compare processes 
attached to D and E and respect /proc/pid/oom_score_adj.  It allows for 
opting in and opting out of cgroup aware selection not only for the whole 
system but also per subtree.

> > Hmm, I'm not sure why we would limit memory.oom_group to any policy.  Even 
> > if we are selecting a process, even without selecting cgroups as victims, 
> > killing a process may still render an entire cgroup useless and it makes 
> > sense to kill all processes in that cgroup.  If an unlucky process is 
> > selected with today's heursitic of oom_badness() or with a "none" policy 
> > with my patchset, I don't see why we can't enable the user to kill all 
> > other processes in the cgroup.  It may not make sense for some trees, but 
> > but I think it could be useful for others.
> 
> My intuition screams here. I will think about this some more but I would
> be really curious about any sensible usecase when you want sacrifice the
> whole gang just because of one process compared to other processes or
> cgroups is too large. Do you see how you are mixing entities here?
> 

It's a property of the workload that has nothing to do with selection.  
Regardless of how a victim is selected, we need a victim.  That victim may 
be able to tolerate the loss of the process, and not even need to be the 
largest memory hogging process based on /proc/pid/oom_score_adj (periodic 
cleanups, logging, stat collection are what I'm most familiar with).  It 
may also be vital to the workload and it's better off to kill the entire 
job, it's highly dependent on what the job is.  There's a general usecase 
for memory.oom_group behavior without any selection changes, we've had a 
killall tunable for years and is used by many customers for the same 
reason.  There's no reason for it to be coupled, it can exist independent 
of any cgroup aware selection.

> I do not understand. Get back to our example. Are you saying that G
> with none will enforce the none policy to C and root? If yes then this
> doesn't make any sense because you are not really able to delegate the
> oom policy down the tree at all. It would effectively make tree policy
> pointless.
> 

The oom policy of G is pointless, it has no children cgroups.  It can be 
"none", "cgroup", or "tree", it's not the root of a subtree.  (The oom 
policy of the root mem cgroup is also irrelevant if there are no other 
cgroups, same thing.)  If G is oom, it kills the largest process or 
everything if memory.oom_group is set, which in your example it is.

> I am skipping the rest of the following text because it is picking
> on details and the whole design is not clear to me. So could you start
> over documenting semantic and requirements. Ideally by describing:
> - how does the policy on the root of the OOM hierarchy controls the
>   selection policy

If "none", there's no difference than Linus's tree right now.  If 
"cgroup", it enables cgroup aware selection: it compares all cgroups on 
the system wrt local usage unless that cgroup has "tree" set in which case 
its usage is hierarchical.

> - how does the per-memcg policy act during the tree walk - for both
>   intermediate nodes and leafs

The oom policy is determined by the mem cgroup under oom, that is the root 
of the subtree under oom and its policy dictates how to select a victim 
mem cgroup.

> - how does the oom killer act based on the selected memcg

That's the point about memory.oom_group: once it has selected a cgroup (if 
cgroup aware behavior is enabled for the oom subtree [could be root]), a 
memory hogging process attached to that subtree is killed or everything is 
killed if memory.oom_group is enabled.

> - how do you compare tasks with memcgs
> 

You don't, I think the misunderstanding is what happens if the root of a 
subtree is "cgroup", for example, and a descendant has "none" enabled.  
The root is under oom, it is comparing cgroups :)  "None" is only 
effective if that subtree root is oom where process usage is considered.

The point is that all the functionality available in -mm is still 
available, just dictate "cgroup" everywhere and make it a decision that 
can change per subtree, if necessary, without any mount option that would 
become obsoleted.  Then, make memory.oom_group possible without any 
specific selection policy since its useful on its own.

Let me give you a concrete example based on your earlier /admins, 
/teachers, /students example.  We oversubscribe the /students subtree in 
the case where /admins and /teachers aren't using the memory.  We say 100 
students can use 1GB each, but the limit of /students is actually 200GB.  
100 students using 1GB each won't cause a system oom, we control that by 
the limit of /admins and /teachers.  But we allow using memory that isn't 
in use by /admins and /teachers if it's there, opening up overconsumers to 
the possibility of oom kill.  (This is a real world example with batch job 
scheduling, it's anything but hypothetical.)

/students/michal logs in, and he has complete control over his subtree.  
He's going to start several jobs, all in their own cgroups, with usage 
well over 1GB, but if he's oom killed he wants the right thing oom killed.  

Obviously this completely breaks down if the -mm functionality is used if 
you have 10 jobs using 512MB each, because another student using more than 
1GB who isn't using cgroups is going to be oom killed instead, although 
you are using 5GB.  We've discussed that ad nauseam, and is why I 
introduced "tree".

But now look at the API.  /students/michal is using child cgroups but 
which selection policy is in effect?  Will it kill the most memory hogging 
process in his subtree or the most memory hogging process from the most 
memory hogging cgroup?  It's an important distinction because it's 
directly based on how he constructs his hierarchy: if locked into one 
selection logic, the least important job *must* be in the highest 
consuming cgroup; otherwise, his /proc/pid/oom_score_adj is respected.  He 
*must* query the mount option.

But now let's say that memory.oom_policy is merged to give this control to 
him to do per process, per cgroup, or per subtree oom killing based on how 
he defines it.  The mount option doesn't mean anything anymore, in fact, 
it can mean the complete opposite of what actually happens.  That's the 
direct objection to the mount option.  Since I have systems with thousands 
of cgroups in hundreds of cgroups and over 100 workgroups that define, 
sometimes very creatively, how to select oom victims, I'm an advocate for 
an extensible interface that is useful for general purpose, doesn't remove 
any functionality, and doesn't have contradicting specifications.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
