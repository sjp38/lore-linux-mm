Date: Fri, 23 Mar 2007 16:55:37 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: Subject: [PATCH RESEND 1/1] cpusets/sched_domain reconciliation
Message-Id: <20070323165537.3d953f7b.pj@sgi.com>
In-Reply-To: <460362B7.1070700@yahoo.com.au>
References: <20070322231559.GA22656@sgi.com>
	<46033311.1000101@yahoo.com.au>
	<20070322204720.cd3a51c9.pj@sgi.com>
	<4603504A.1000805@yahoo.com.au>
	<460362B7.1070700@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: cpw@sgi.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick wrote:
> Hmm, there will be still some problems with kernel thread like
> pdflush in the root cpuset, preventing the partitioning to be
> actually activated...

Yeah - that concerns me too, in addition to the performance
implications of considering sched domain partitions every time a task
exits or moves.  Both seem to me to be serious problems with that
approach.

> However, the same algorithm can be implemented using the cpusets
> topology instead of cpus_allowed, and it will be much cheaper >
(and cpusets already has a task exit hook).

On the plus side, we wouldn't have to do this at task exit, if we
drove it off the cpuset cpus_allowed values.  We would only need to
adjust the sched domains when the cpusets changed, which is a much
less frequent operation.

On the down side, it doesn't work ;)

The root cpuset includes all online cpus, so would prevent any
partitioning.

Simply excluding the root cpuset from the calculation isn't necessarily
sufficient either.  Fairly often we have big systems divide, at the
level just below the root cpuset, into two cpusets: one small cpuset
for the classic Unix daemon and user login load, and one huge cpuset
managed by some such batch scheduler as PBS, LSF or SGE.

Partitioning the sched domains on a 512 CPU system into a 4 CPU
partition and a 508 CPU partition doesn't exactly help much.

The batch scheduler has knowledge, which it is usually quite willing to
leverage, as to which of the many child and grandchild cpusets it has
setup hold active jobs and need load balancing, and which don't need
balancing.  I doubt that the kernel can reliably intuit this.

But I think we've been here before, you and I <grin>.

If I recall correctly, you've been inclined to an implicit interface
for defining sched domain partitions, and certainly I've been inclined
to an explicit interface.

I'm still inclined to an explicit interface.  The folks who would
benefit from hard partitioning of the sched domains will have varied
and specific needs.  If we try to get away with some implicit interface
whereby the kernel intuits where to put those partitions based on a
natural partition of task->cpus_allowed or task->cpuset->cpus_allowed,
then those users will just have to quite consciously learn the magic
incantations needed to blindly define the partitioning they require.

Implicit interfaces are fine if they usually get the right answer,
and only rarely does user code have to second guess them.  They are
a pain in the backside when they have to be worked around.

The cpuset cpu_exclusive flag was the wrong hook for this explicit
interface, and I have had, for months now, a patch in Andrew's *-mm
tree, to disconnect the cpuset cpu_exclusive flag from any defining
role in sched domain partitions.  I never should have agreed to that
(ab)use of the cpu_exclusive in the first place.

I've been asking Andrew to hold off on sending that patch to Linus,
until we can get our act together somehow on an alternative mechanism
for defining sched domain partitions, as at least the real time folks
are already depending on having such a capability.  I'm willing to
impose on them a change in the API they use for this, but I am not
willing to remove that capability entirely from them.  The real time
folks need some way to mark certain CPUs as not being subject to
any scheduler load balancing at all.  This can also be done with a
kernel boot command option, but they really depend on being able to
dynamically (abeit infrequently) add or remove CPUs from the list of
"real-time" CPUs exempt from load balancing.

This explicit API should either be via the cpuset hierarchy, with a
new per-cpuset attribute, or else by a new and separate interface by
which user space can define a partition of the systems CPUs for the
scheduler (where a partition is a covering set of disjoint subsets,
and likely expressed as a list of cpumasks in this situation, one
cpumask for each element of the partition.)

If it is via a new per-cpuset flag, then that flag can either mark
those cpusets requiring load balancing, or those not requiring it.

If it is via cpumasks, then there would be a file or directory beneath
/proc, with one cpumask per line (or per file), such that the masks
were pairwise disjoint and such that their union equaled the set of
online cpus (not sure this last rule is necessary.)

I am inclined toward a cpuset flag here, and figure it can be done
with less kernel code this way, as we would just need one more
boolean flag bit.  But I recognize that I'm biased here, and that
others might need to partition sched domains without setting up an
entire cpuset hierarchy.

Either way, this flag is a hint to the kernel, allowing it to
improve load balancing performance by avoiding considering certain
possibilities.

Since defining a new partitioning is not an atomic operation (user
code will have to update possibly several cpusets or masks first),
perhaps there should be a separate trigger, and we only recalculate
when that trigger is fired.  This might make the kernel code easier,
in that it doesn't have to react to every change in the defining
flags or masks.  And it surely would make the user code easier,
as it would not have to carefully sequence a restructuring of the
partitioning into mini-steps, each one of which was a valid partition.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
