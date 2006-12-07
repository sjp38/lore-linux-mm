Date: Thu, 7 Dec 2006 02:44:36 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC][PATCH] Allow Cpuset nodesets to expand under pressure
Message-Id: <20061207024436.2b24d418.pj@sgi.com>
In-Reply-To: <20061205114513.4D7A63D675D@localhost>
References: <20061205114513.4D7A63D675D@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, mbligh@google.com, winget@google.com, rohitseth@google.com, nickpiggin@yahoo.com.au, ckrm-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

> The following files are added:
> 
> - expansion_limit - the maximum size (in bytes) to which this cpuset's
> memory set can be expanded
> 
> - expansion_pressure - the abstract memory pressure for tasks within
> the cpuset, ranging from 0 (no pressure) to 100 (about to go OOM) at
> which expansion can occur
> 
> - unused_mems (read-only) - the set of memory nodes that are available
> to this cpuset and not assigned to the mems set of any of this
> cpuset's children; automatically maintained by the system
> 
> - expansion_mems - a vector of nodelists that determine which nodes
> should be considered as potential expansion nodes, if available, in
> priority order


I've been struggling with a couple of variations on this theme.

I have one site that needs to have jobs that start swapping get killed.

I have another site that needs to have jobs that are about to start
kicking in the OOM killer instead get more memory - though they don't
need to run nearly as tight or carefully metered a limiter on how much
extra memory the job can get as your expansion mechanism allows for,
and they don't want to set aside unused nodes to divy out for these
cases, but rather they want to allow the tasks to start taking from
the nodes allowed to other jobs (yes, sounds odd, but I think that's
a fair statement.)

In both cases, these are very important adaptions to the particular
memory needs and workloads of particular sites, and difficult to
accomplish with existing mechanisms.  And neither variation seems to
be easily answered with this patch proposal either.

This patch adds the single largest expansion of per-cpuset attributes
of any change we've proposed.  My sense is that it is a tad overly
specialized to a particular situation (granted, a popular situation.)

But it tries to address a significant cause of difficulty in using
cpusets, so I am most encouraged.

How about a loadable module?

Instead of calling out to cpuset code that can expand the jobs cpuset
from a pre-defined pool, rather call out to a routine that can be
provided by a loadable module.  Keep the expansion_pressure, keep the
callout, but drop the rest and make the callout pluggable.

Then sites with specialized needs at the point of a particular amount
of pressure can provide specialized solutions.

I can imagine two more per-cpuset files, instead of the four above:

  memory_expansion_pressure - level, 0-100, at which the callout is called
  memory_expansion_routine - string name of a registered callout.

A routine would be available to the init routine of loading modules,
that let them register a callback by a string name, which would be
matched to the 'memory_expansion_routine' name, when a memory request
was made in a cpuset exceeding that cpusets specified
memory_expansion_pressure.

This would make the API quite a bit more generic and simple, and meet a
greater variety of needs.

Don't invoke the callout if the task can't sleep at that point; coders
of such loadable modules are ill-prepared to deal with that case, and
would sooner let such memory requests be handled as they are now.

Right now, if I had to cast a final vote (there is no 'final' vote, and
I wouldn't have it if there was ;), I'd much prefer a loadable module
hook here, then this particular 'expansion_mems' mechanism.

I'm open to discussing changing the value reported by 'memory_pressure'
into being the unfiltered metric needed here, to consolidate these two
metrics.  Now that I have some more real world experience with this
memory_pressure value, it is proving to have worth about half way
between what I hoped it would have, providing a user accessible leading
indicator of heavy swapping, and the lesser worth that I'd guess Andrew
was predicting for it.  If 'memory_pressure' is low, it means we are not
swapping heavily.  But if it is high, then either we are swapping or we
are pushing dirty pages to the file system.  If I ended up with a
loadable module hook that could be called out at a specified pressure
level, that would be a huge improvement from my perspective, and having
just a single pressure metric exposed in the API is a worthy goal.  I'm
sure that Andrew would get a kick out of applying the patch to remove
the single-pole low-pass recursive (IIR) filter code in cpuset.c ;).

For API compatibility, we should continue to have a per-cpuset metric
called memory_pressure, that tends to get bigger the greater the
memory distress, but it's negotiable just what the recipe is for
calculating that metric.  And it could become a value that is both
readable and writable, instead of just the read-only value it is now.

Obligatory nit - some places you have code such as:

+	/* if expansion isn't configured, don't expand */
+	if (cs->expansion_pressure < 0) return 0;
+	/* if memory pressure isn't high enough, don't expand */
+	if (pressure < cs->expansion_pressure) return 0;
+	/* if we're at the limit, don't expand */
+	if (cs->total_pages >= cs->expansion_limit) return 0;

The "if (...)" and the "return 0;" should be on separate lines.

Back to the main line of thought.  The locking could get tricky.

Perhaps an analog of CAS (compare and swap) works.  Provide the
callout code with a routine it can invoke that states in affect:

  if my tasks mems_allowed is This
    then change it to That
  else
    return failure (update This in place?)

Then we can invoke the callout routine not holding either of the
cpuset locks, manage_mutex or callback_mutex, and we can keep our
intricate details of cpuset locking the private business of mainline
kernel code, as they should be.

If we could arrange to invoke these callout routines not holding any
significant global lock, so that the callout routine could even go
so far as to invoke a separate thread to run user space code to muck
with cpusets all before returning, then that would be great.

By the way, I just happened to notice that the 0..100 pressure value
in this patch seems strangely like the 'distress' value in the
mm/vmscan.c:shrink_active_list() code.  But I'm no vm guru, so perhaps
this is a superficial similarity.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
