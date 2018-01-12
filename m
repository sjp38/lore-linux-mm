Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4582D6B0253
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 17:03:10 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id c11so5819461ioj.15
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 14:03:10 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k204sor2403404itk.122.2018.01.12.14.03.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jan 2018 14:03:08 -0800 (PST)
Date: Fri, 12 Jan 2018 14:03:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v13 0/7] cgroup-aware OOM killer
In-Reply-To: <20180111131845.GA13726@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.10.1801121331110.120129@chino.kir.corp.google.com>
References: <20171130152824.1591-1-guro@fb.com> <20171130123930.cf3217c816fd270fa35a40cb@linux-foundation.org> <alpine.DEB.2.10.1801091556490.173445@chino.kir.corp.google.com> <20180110131143.GB26913@castle.DHCP.thefacebook.com>
 <20180110113345.54dd571967fd6e70bfba68c3@linux-foundation.org> <20180111090809.GW1732@dhcp22.suse.cz> <20180111131845.GA13726@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 11 Jan 2018, Roman Gushchin wrote:

> Summarizing all this, following the hierarchy is good when it reflects
> the "importance" of cgroup's memory for a user, and bad otherwise.
> In generic case with unified hierarchy it's not true, so following
> the hierarchy unconditionally is bad.
> 
> Current version of the patchset allows common evaluation of cgroups
> by setting memory.groupoom to true. The only limitation is that it
> also changes the OOM action: all belonging processes will be killed.
> If we really want to preserve an option to evaluate cgroups
> together without forcing "kill all processes" action, we can
> convert memory.groupoom from being boolean to the multi-value knob.
> For instance, "disabled" and "killall". This will allow to add
> a third state ("evaluate", for example) later without breaking the API.
> 

No, this isn't how kernel features get introduced.  We don't design a new 
kernel feature with its own API for a highly specialized usecase and then 
claim we'll fix the problems later.  Users will work around the 
constraints of the new feature, if possible, and then we can end up 
breaking them later.  Or, we can pollute the mem cgroup v2 filesystem with 
even more tunables to cover up for mistakes in earlier designs.

The key point to all three of my objections: extensibility.

Both you and Michal have acknowledged blantently obvious shortcomings in 
the design.  We do not need to merge an incomplete patchset that forces us 
into a corner later so that we need to add more tunables and behaviors.  
It's also an incompletely documented patchset: the user has *no* insight 
other than reading the kernel code that with this functionality their 
/proc/pid/oom_score_adj values are effective when attached to the root 
cgroup and ineffective when attached to a non-root cgroup, regardless of 
whether the memory controller is enabled or not.

Extensibility when designing a new kernel feature is important.  If you 
see shortcomings, which I've enumerated and have been acknowledged, it 
needs to be fixed.

The main consideration here is two choices:

 (1) any logic to determine process(es) to be oom killed belongs only in
     userspace, and has no place in the kernel, or

 (2) such logic is complete, documented, extensible, and is generally
     useful.

This patchset obviously is neither.  I believe we can move toward (2), but 
it needs to be sanely designed and implemented such that it addresses the 
concerns I've enumerated that we are all familiar with.

The solution is to define the oom policy as a trait of the mem cgroup 
itself.  That needs to be complemented with a per mem cgroup value member 
to specify the policy for child mem cgroups.  We don't need any new 
memory.groupoom, which depends on only this policy decision and is 
otherwise a complete no-op, and we don't need any new mount option.

It's quite obvious the system cannot have a single cgroup aware oom 
policy.  That's when you get crazy inconsistencies and functionally broken 
behavior such as influencing oom kill selection based on whether a cgroup 
distributed processes over a set of child cgroups, even if they do not 
have memory in their memory.subtree_control.  It's also where you can give 
the ability to user to still prefer to protect important cgroups or bias 
against non-important cgroups.

The point is that the functionality needs to be complete and it needs to 
be extensible.

I'd propose to introduce a new memory.oom_policy and a new 
memory.oom_value.  All cgroups have these files, but memory.oom_value is a 
no-op for the root mem cgroup, just as you can't limit the memory usage on 
the root mem cgroup.

memory.oom_policy defines the policy for selection when that mem cgroup is 
oom; system oom conditions refer to the root mem cgroup's 
memory.oom_policy.

memory.oom_value defines any parameter that child mem cgroups should be 
considered with when effecting that policy.

There's three memory.oom_policy values I can envision at this time, but it 
can be extended in the future:

 - "adj": cgroup aware just as you have implemented based on how large a
   cgroup is.  oom_value can be used to define any adjustment made to that
   usage so that userspace can protect important cgroups or bias against
   non-important cgroups (I'd suggest using that same semantics as
   oom_score_adj for consistency, but wouldn't object to using a byte
   value).

 - "hierarchy": same as "adj" but based on hierarchical usage.  oom_value
   has the same semantics as "adj".  This prevents users from 
   intentionally or unintentionally affecting oom kill selection by
   limiting groups of their processes by the memory controller, or any
   other cgroup controller.

 - "priority": cgroup aware just as you implemented memory.oom_priority in
   the past.  oom_value is a strict priority value where usage is not
   considered and only the priority of the subtree is compared.

With cgroup v2 sematics of no internal process constraint, this is 
extremely straight forward.  All of your oom evaluation function can be 
reused with a simple comparison based on the policy to score individual 
cgroups.  In the simplest policy, "priority", this is like a 10 line 
function, but extremely useful to userspace.

This allows users to have full power over the decisionmaking in every 
subtree wrt oom kill selection and doesn't regress or allow for any 
pitfalls of the current patchset.  The goal is not to have one single oom 
policy for the entire system, but define the policy that makes useful 
sense.  This is how an extensible feature is designed and does not require 
any further pollution of the mem cgroup filesystem.

If you have additional features such as groupoom, you can make 
memory.oom_policy comma delimited, just as vmpressure modes are comma 
delimited.  You would want to use "adj,groupoom".  We don't need another 
file that is pointless in other policy decisions.  We don't need a mount 
option to lock the entire system into a single methodology.

Cgroup v2 is a very clean interface and I think it's the responsibility of 
every controller to maintain that.  We should not fall into a cgroup v1 
mentality which became very difficult to make extensible.  Let's make a 
feature that is generally useful, complete, and empowers the user rather 
than push them into a corner with a system wide policy with obvious 
downsides.

For these reasons, and the three concerns that I enumerated earlier which 
have been acknowledged of obvious shortcoming with this approach:

Nacked-by: David Rientjes <rientjes@google.com>

I'll be happy to implement the core functionality that allows oom policies 
to be written by the user and introduce memory.oom_value, and then rework 
the logic defined in your patchset as "adj" by giving the user an optional 
way of perferring or biasing that usage in a way that is clearly 
documented and extended.  Root mem cgroup usage is obviously wrong in this 
current patchset since it uses oom_score_adj whereas leaf cgroups do not, 
so that will be fixed.  But I'll ask that the current patchset is removed 
from -mm since it has obvious downsides, pollutes the mem cgroup v2 
filesystem, is not extensible, is not documented wrt to oom_score_adj, 
allows evasion of the heuristic, and doesn't allow the user to have any 
power in the important decision of which of their important processes is 
oom killed such that this feature is not useful outside very specialized 
usecases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
