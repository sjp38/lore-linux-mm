Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF3D56B0038
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 16:57:35 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id f26so2896441iob.13
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 13:57:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v65sor1249129ita.16.2018.01.11.13.57.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jan 2018 13:57:33 -0800 (PST)
Date: Thu, 11 Jan 2018 13:57:30 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v13 0/7] cgroup-aware OOM killer
In-Reply-To: <20180111090809.GW1732@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1801111230550.208084@chino.kir.corp.google.com>
References: <20171130152824.1591-1-guro@fb.com> <20171130123930.cf3217c816fd270fa35a40cb@linux-foundation.org> <alpine.DEB.2.10.1801091556490.173445@chino.kir.corp.google.com> <20180110131143.GB26913@castle.DHCP.thefacebook.com>
 <20180110113345.54dd571967fd6e70bfba68c3@linux-foundation.org> <20180111090809.GW1732@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 11 Jan 2018, Michal Hocko wrote:

> > > I find this problem quite minor, because I haven't seen any practical problems
> > > caused by accounting of the root cgroup memory.
> > > If it's a serious problem for you, it can be solved without switching to the
> > > hierarchical accounting: it's possible to sum up all leaf cgroup stats and
> > > substract them from global values. So, it can be a relatively small enhancement
> > > on top of the current mm tree. This has nothing to do with global victim selection
> > > approach.
> > 
> > It sounds like a significant shortcoming to me - the oom-killing
> > decisions which David describes are clearly incorrect?
> 
> Well, I would rather look at that from the use case POV. The primary
> user of the new OOM killer functionality are containers. I might be
> wrong but I _assume_ that root cgroup will only contain the basic system
> infrastructure there and all the workload will run containers (aka
> cgroups). The only oom tuning inside the root cgroup would be to disable
> oom for some of those processes. The current implementation should work
> reasonably well for that configuration.
>  

It's a decision made on the system level when cgroup2 is mounted, it 
affects all processes that get attached to a leaf cgroup, even regardless 
of whether or not it has the memory controller enabled for that subtree.  
In other words, mounting cgroup2 with the cgroup aware oom killer mount 
option immediately:

 - makes /proc/pid/oom_score_adj effective for all processes attached
   to the root cgroup only, and

 - makes /proc/pid/oom_score_adj a no-op for all processes attached to a
   non-root cgroup.

Note that there may be no active usage of any memory controller at the 
time of oom, yet this tunable inconsistency still exists for any process.

The initial response is correct: it clearly produces incorrect oom killing 
decisions.  This implementation detail either requires the entire system 
is not containerized at all (no processes attached to any leaf cgroup), or 
fully containerized (all processes attached to leaf cgroups).  It's a 
highly specialized usecase with very limited limited scope and is wrought 
with pitfalls if any oom_score_adj is tuned because it strictly depends on 
the cgroup to which those processes are attached at any given time to 
determine whether it is effective or not.

> > > We've discussed this a lot.
> > > Hierarchical approach has their own issues, which we've discussed during
> > > previous iterations of the patchset. If you know how to address them
> > > (I've no idea), please, go on and suggest your version.
> > 
> > Well, if a hierarchical approach isn't a workable fix for the problem
> > which David has identified then what *is* the fix?
> 
> Hierarchical approach basically hardcodes the oom decision into the
> hierarchy structure and that is simply a no go because that would turn
> into a massive configuration PITA (more on that below). I consider the above
> example rather artificial to be honest. Anyway, if we _really_ have to
> address it in the future we can do that by providing a mechanism to
> prioritize cgroups. It seems that this is required for some usecases
> anyway.
>  

I'll address the hierarchical accounting suggestion below.

The example is not artificial, it's not theoretical, it's a real-world 
example.  Users can attach processes to subcontainers purely for memory 
stats from a mem cgroup point of view without limiting usage, or to 
subcontainers for use with other controllers other than the memory 
controller.  We do this all the time: it's helpful to assign groups of 
processes to subcontainers simply to track statistics while the actual 
limitation is enforced by an ancestor.

So without hierarchical accounting, we can extend the above restriction, 
that a system is either fully containerized or not containerized at all, 
by saying that a fully containerized system must not use subcontainers to 
avoid the cgroup aware oom killer heuristic.  In other words, using this 
feature requires:

 - the entire system is not containerized at all, or

 - the entire system is fully containerized and no cgroup (any controller,
   not just memory) uses subcontainers to intentionally/unintentionally
   distribute usage to evade this heuristic.

Of course the second restriction severely limits the flexibility that 
cgroup v2 introduces as a whole as a caveat of an implementation detail of 
the memory cgroup aware oom killer.  Why not simply avoid using the cgroup 
aware oom killer?  It's not so easy since the it's a property of the 
machine itself: users probably have no control over it themselves and, in 
the worst case, can trivially evade ever being oom killed if used.

> > > The per-process oom_score_adj interface is not the nicest one, and I'm not
> > > sure we want to replicate it on cgroup level as is. If you have an idea of how
> > > it should look like, please, propose a patch; otherwise it's hard to discuss
> > > it without the code.
> > 
> > It does make sense to have some form of per-cgroup tunability.  Why is
> > the oom_score_adj approach inappropriate and what would be better?
> 
> oom_score_adj is basically unusable for any fine tuning on the process
> level for most setups except for very specialized ones. The only
> reasonable usage I've seen so far was to disable OOM killer for a
> process or make it a prime candidate. Using the same limited concept for
> cgroups sounds like repeating the same error to me.
> 

oom_score_adj is based on the heuristic that the oom killer uses to decide 
which process to kill, it kills the largest memory hogging process.  Being 
able to tune that based on a proportion of available memory, whether for 
the system as a whole or for a memory cgroup hierarchy makes sense for 
varying RAM capacities and memory cgroup limits.  It works quite well in 
practice, I'm not sure your experience with it based on the needs you have 
with overcommit.

The ability to protect important cgroups and bias against non-important 
cgroups is vital to any selection implementation.  Strictly requiring that 
important cgroups do not have majority usage is not a solution, which is 
what this patchset implements.  It's also insufficient to say that this 
can be added on later, even though the need is acknowledged, because any 
prioritization or userspace influence will require a change to the cgroup 
aware oom killer's core heuristic itself.  That needs to be decided now 
rather than later to avoid differing behavior between kernel versions for 
those who adopt this feature and carefully arrange their cgroup 
hierarchies to fit with the highly specialized usecase before it's 
completely changed out from under them.

> > How hard is it to graft such a thing onto the -mm patchset?
> 
> I think this should be thought through very well before we add another
> tuning. Moreover the current usecase doesn't seem to require it so I am
> not really sure why we should implement something right away and later
> suffer from API mistakes.
>  

The current usecase is so highly specialized that it's not usable for 
anybody else and will break that highly specialized usecase if we make it 
usable for anybody else in the future.

It's so highly specialized that you can't even protect an important 
process from oom kill, there is no remedy provided to userspace that still 
allows local mem cgroup oom to actually work.

# echo "+memory" > cgroup.subtree_control
# mkdir cg1
# echo $$ > cg1/cgroup.procs
<fork important process>
# echo -999 > /proc/$!/oom_score_adj
# echo f > /proc/sysrq-trigger

This kills the important process if cg1 has the highest usage, the user 
has no control other than purposefully evading the oom killer, if 
possible, by distributing the process's threads over subcontainers.

Because a highly specialized user is proposing this and it works well for 
them right now does not mean that it is in the best interest of Linux to 
merge, especially if it cannot become generally useful to others without 
core changes that affect the original highly specialized user.  This is 
why the patchset, as is, is currently incomplete.

> > > David, I _had_ hierarchical accounting implemented in one of the previous
> > > versions of this patchset. And there were _reasons_, why we went away from it.
> > 
> > Can you please summarize those issues for my understanding?
> 
> Because it makes the oom decision directly hardwired to the hierarchy
> structure. Just take a simple example of the cgroup structure which
> reflects a higher level organization
>          root
> 	/  |  \ 
>   admins   |   teachers
>         students
> 
> Now your students group will be most like the largest one. Why should we
> kill tasks/cgroups from that cgroup just because it is cumulatively the
> largest one. It might have been some of the teacher blowing up the
> memory usage.
> 

There's one thing missing here: the use of the proposed 
memory.oom_score_adj.  You can use it to either polarize the decision so 
that oom kills always originate from any of /admins, /students, or 
/teachers, or bias against them.  You can also proportionally prefer 
/admins or /teachers, if desired, so they are selected if their usage 
exceeds a certain threshold based on the limit of the ancestor even though 
that hierarchical usage does not exceed, or even approach the hierarchical 
usage of /students.

This requires that the entity setting up this hierarchy know only one 
thing: the allowed memory usage of /admins or /teachers compared to the 
very large usage of /students.  It can actually be tuned to a great 
detail.  I only suggest memory.oom_score_adj because it can work for all 
/root capacities, regardless of RAM capacity, as a proportion of the 
system that should be set aside for /admins, /students, and/or /teachers 
rather than hardcoded bytes which would change depending on the amount of 
RAM you have.

FWIW, we do this exact thing and it works quite well.  This doesn't mean 
that I'm advocating for my own usecase, or anticipated usecase for the 
cgroup aware oom killer, but that you've picked an example that I have 
personally worked with and the bias can work quite well for oom kill 
selection.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
