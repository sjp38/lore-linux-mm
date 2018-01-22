Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7B859800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 17:34:43 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id f67so11660570itf.2
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 14:34:43 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b70sor9254794ioj.132.2018.01.22.14.34.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 14:34:42 -0800 (PST)
Date: Mon, 22 Jan 2018 14:34:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
In-Reply-To: <20180120123251.GB1096857@devbig577.frc2.facebook.com>
Message-ID: <alpine.DEB.2.10.1801221420120.16871@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com> <alpine.DEB.2.10.1801161814130.28198@chino.kir.corp.google.com> <20180117154155.GU3460072@devbig577.frc2.facebook.com> <alpine.DEB.2.10.1801171348190.86895@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801191251080.177541@chino.kir.corp.google.com> <20180120123251.GB1096857@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 20 Jan 2018, Tejun Heo wrote:

> > Hearing no response, I'll implement this as a separate tunable in a v2 
> > series assuming there are no better ideas proposed before next week.  One 
> > of the nice things about a separate tunable is that an admin can control 
> > the overall policy and they can delegate the mechanism (killall vs one 
> > process) to a user subtree.  I agree with your earlier point that killall 
> > vs one process is a property of the workload and is better defined 
> > separately.
> 
> If I understood your arguments correctly, the reasons that you thought
> your selectdion policy changes must go together with Roman's victim
> action were two-fold.
> 
> 1. You didn't want a separate knob for group oom behavior and wanted
>    it to be combined with selection policy.  I'm glad that you now
>    recognize that this would be the wrong design choice.
> 

The memory.oom_action (or mechanism) file that I've proposed is different 
than memory.oom_group: we want to provide a non-binary tunable to specify 
what action that oom killer should effect.  That could be to kill all 
processes in the subtree, similar to memory.oom_group, the local cgroup, 
or a different mechanism.  I could propose the patchset backwards, if 
necessary, because memory.oom_group is currently built upon a broken 
selection heuristic.  In other words, I could propose a memory.oom_action 
that can specify two different mechanisms that would be useful outside of 
any different selection function.  However, since the mechanism is built 
on top of the cgroup aware oom killer's policy, we can't merge it 
currently without the broken logic.

> 2. The current selection policy may be exploited by delegatee and
>    strictly hierarchical seleciton should be available.  We can debate
>    the pros and cons of different heuristics; however, to me, the
>    followings are clear.
> 
>    * Strictly hierarchical approach can't replace the current policy.
>      It doesn't work well for a lot of use cases.
> 

-ECONFUSED.  I haven't proposed any strict hierarchical approach here, 
it's configurable by the user.

>    * OOM victim selection policy has always been subject to changes
>      and improvements.
> 

That's fine, but the selection policy introduced by any cgroup aware oom 
killer is being specified now and is pretty clear cut: compare the usage 
of cgroups equally based on certain criteria and choose the largest.  I 
don't see how that could be changed or improved once the end user starts 
using it, the heuristic has become a policy.  A single cgroup aware policy 
doesn't work, if you don't have localized, per-cgroup control you have 
Michal's /admins and /students example; if you don't have hierarchical, 
subtree control you have my example of users intentionally/unintentionally 
evading the selection logic based on using cgroups.  The policy needs to 
be defined for subtrees.  There hasn't been any objection to that, so 
introducing functionality that adds a completely unnecessary and broken 
mount option and forces users to configure cgroups in a certain manner 
that no longer exists with subtree control doesn't seem helpful.

> I don't see any blocker here.  The issue you're raising can and should
> be handled separately.
> 

It can't, because the current patchset locks the system into a single 
selection criteria that is unnecessary and the mount option would become a 
no-op after the policy per subtree becomes configurable by the user as 
part of the hierarchy itself.

> Here, whether a workload can survive being killed piece-wise or not is
> an inherent property of the workload and a pretty binary one at that.
> I'm not necessarily against changing it to take string inputs but
> don't see rationales for doing so yet.
> 

We don't need the unnecessary level in the cgroup hierarchy that enables 
memory.oom_group, as proposed, and serves no other purpose.  It's 
perfectly valid for subtrees to run user executors whereas a "killall" 
mechanism is valid for some workloads and not others.  We do not need 
ancestor cgroups locking that decision into place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
