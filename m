Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 690D96B0253
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 16:42:41 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id f20so10690722ioj.2
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 13:42:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z187sor772510ioz.88.2017.11.01.13.42.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Nov 2017 13:42:40 -0700 (PDT)
Date: Wed, 1 Nov 2017 13:42:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RESEND v12 0/6] cgroup-aware OOM killer
In-Reply-To: <20171101073758.femijh7clfbwmqeg@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1711011329000.56485@chino.kir.corp.google.com>
References: <20171019185218.12663-1-guro@fb.com> <20171019194534.GA5502@cmpxchg.org> <alpine.DEB.2.10.1710221715010.70210@chino.kir.corp.google.com> <20171026142445.GA21147@cmpxchg.org> <alpine.DEB.2.10.1710261359550.75887@chino.kir.corp.google.com>
 <20171027093107.GA29492@castle.dhcp.TheFacebook.com> <alpine.DEB.2.10.1710301430170.105449@chino.kir.corp.google.com> <20171031075408.67au22uk6dkpu7vv@dhcp22.suse.cz> <alpine.DEB.2.10.1710311513590.123444@chino.kir.corp.google.com>
 <20171101073758.femijh7clfbwmqeg@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 1 Nov 2017, Michal Hocko wrote:

> > memory.oom_score_adj would never need to be permanently tuned, just as 
> > /proc/pid/oom_score_adj need never be permanently tuned.  My response was 
> > an answer to Roman's concern that "v8 has it's own limitations," but I 
> > haven't seen a concrete example where the oom killer is forced to kill 
> > from the non-preferred cgroup while the user has power of biasing against 
> > certain cgroups with memory.oom_score_adj.  Do you have such a concrete 
> > example that we can work with?
> 
> Yes, the one with structural requirements due to other controllers or
> due to general organizational purposes where hierarchical (sibling
> oriented) comparison just doesn't work.

You mean where an admin or user does

	for i in $(cat cgroup.procs); do mkdir $i; echo $i > $i/cgroup.procs; done

to place constraints on processes with other controllers but unknowingly 
completely circumvented oom kill selection?  That's one of my concerns 
that hasn't been addressed and I believe only can be done with 
hierarchical accounting.

> Take the students, teachers,
> admins example. You definitely do not want to kill from students
> subgroups by default just because this is the largest entity type.
> Tuning memory.oom_score_adj doesn't work for that usecase as soon as
> new subgroups come and go.
> 

With hierarchical accounting, that solves all three concerns that I have 
enumerated, the top-level organizer knows the limits imposed.  It is 
therefore *trivial* to prefer /students by biasing against it with 
memory.oom_score_adj over other top-level mem cgroups and still kill 
from /students if going over a certain threshold of memory.  With 
hierarchical accounting and memory.oom_score_adj, it could even be used 
for userspace to determine which student to kill from.  If /admins is 
using more memory than expected, it gets biased against with the same 
memory.oom_score_adj.  The point is that the top-level organizer that is 
structing the mem cgroup tree knows the limits imposed and the preference 
of /admins over /students, or vice versa.  It also doesn't allow /students 
to circumvent victim selection by creating child mem cgroups.

If this is missing your point, please draw the hierarchy you are 
suggesting and show which mem cgroup is preferred by the admin and does 
not allow the user to circumvent that priority.

> > We simply cannot determine if improvements can be implemented in the 
> > future without user-visible changes if those improvements are unknown or 
> > undecided at this time.
> 
> Come on. There have been at least two examples on how this could be
> achieved. One priority based which would use cumulative memory
> consumption if set on intermediate nodes which would allow you to
> compare siblings. And another one was to add a new knob which would make
> an intermediate node an aggregate for accounting purposes.
> 

We don't need a memory.oom_group, memory.oom_hierarchical_accounting, 
memory.oom_priority, and memory.oom_score_adj.  I believe 
memory.oom_score_adj suffices.  I don't think it is in our best interest 
or the users best interest to maintain many different combinations of how 
an oom victim is selected.  I believe all the power needed is by providing 
a memory.oom_score_adj since cgroup memory usage is being considered, just 
as /proc/pid/oom_score_adj exists when process memory usage is being 
considered.  It seems very intuitive.

In the interest of not polluting the namespace, not allowing users to 
circumvent the decisions of the oom killer, and to allow userspace to be 
able to influence oom victim selection, we need this to be implemented now 
rather than later since it may affect the heuristic under consideration 
and we should have a complete patchset without being backed into a corner 
based on decisions made earlier with the rationale that it can be figured 
out later, let's merge this now.

> And I am pretty sure we have already agreed that something like this is
> useful for some usecases and nobody objected this would get merged in
> future. All we are saying now is that this is not in scope of _this_
> patchseries because the vast majority of usecases simply do not care
> about influencing the oom selection. They only do care about having per
> cgroup behavior and/or kill all semantic. I really do not understand
> what is hard about that.
> 

I honestly do not believe what hurry we're in or what is so hard to 
understand about implementing the ability of userspace to influence the 
decisionmaking that works well together with the heuristic being 
introduced.

We can stop wasting time arguing about whether its appropriate to merge an 
incomplete patchset or not and actually fix the three fundamental flaws 
that have been outlined with this approach, or I can fork the patchset and 
introduce it myself as proposed if that is preferred.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
