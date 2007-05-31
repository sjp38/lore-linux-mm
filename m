Date: Thu, 31 May 2007 12:25:44 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] Document Linux Memory Policy
Message-Id: <20070531122544.fd561de4.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0705301042320.1195@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>
	<Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
	<1180544104.5850.70.camel@localhost>
	<Pine.LNX.4.64.0705301042320.1195@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee.Schermerhorn@hp.com, linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

> They have to since they may be used to change page locations when policies 
> are active. There is a libcpuset library that can be used for application 
> control of cpusets. I think Paul would disagree with you here.

In the most common usage, a batch scheduler uses cpusets to control
a jobs memory and  placement, and application code within the job uses
the memory policy calls (mbind, set_mempolicy) and scheduler policy
call (set_schedaffinity) to manage its detailed placement.

In particular, the memory policy calls can only be applied to the
current task, so any larger scope control has to be done by cpusets.

The cpuset file system, with its traditional file system hierarchy
and permission model, allows as much control as desired to be passed
on to specific applications, and over time, I expect this to happen
more.

However, there will always be a different focus here.

The primary purpose of the memory and scheduler policy mechanisms is to
maximize the efficient usage of available resources by a co-operating
set of tasks - get tasks close to their memory and things like that.
The mind set is "we own the machine - how can we best use it."  For
example tightly coupled MPI jobs will need to place one compute bound
thread on each processor, insure that nothing else is actively running
on those processors, and place data close to task accessing it.  The
expectation is that a jobs code may have to be modified, perhaps even
radically rewritten with a new algorithm, to optimize processor and
memory usage, as relative speeds of processor, memory and bus change.

The primary purpose of cpusets is job isolation, ensuring that one job
does not interfere with another, by keeping the jobs on separate cpus
and memory nodes.  The mind set is "how can we keep these several jobs
out of each others hair, minimizing any impact of one jobs resource
usage on the runtime of another."  The expectation is that jobs must
be controlled externally, without any change to the jobs code or even
any expertise in the fine grained memory or scheduler policy behaviour
of the job.

It may well make sense to document memory policy, for the developers
of large applications that need to use the scheduler or memory policy
routines to manage their multi-threaded, or multiple memory node (NUMA)
placement, -separate- from documenting cpuset placement of jobs on cpus
and memory.  It's a quite different audience.  In so far as possible,
the cpuset code was designed to enable controlling the placement of
jobs without the developer of those jobs, who might be using the
scheduler and memory placement calls, being aware of cpusets -- it's
just a smaller machine available to their job.  Migration should also
be transparent to them -- their machine moved, that's all.

Unfortunately there are a couple of details that leak through:
 1) big apps using scheduler and memory policy calls often want to
    know how "big" their machine is, which changes under cpusets
    from the physical size of the system, and
 2) the sched_setaffinity, mbind and set_mempolicy calls take hard
    physical CPU and Memory Node numbers, which change under migration
    non-transparently.

Therefore I have in libcpuset two kinds of routines:
 1) a large powerful set used by heavy weight batch schedulers to
    provide sophisticated job placement, and
 2) a small simple set used by applications that provide an interface
    to sched_setaffinity, mbind and set_mempolicy that is virtualized
    to the cpuset, providing cpuset relative CPU and Memory Node
    numbering and cpuset relative sizes, safely usable from an
    application across a migration to different nodes, without
    application awareness.

The ancient, Linux 2.4 kernel based, libcpuset on oss.sgi.com is
really ancient and not relevant here.  The cpuset mechanism in
Linux 2.6 is a complete redesign from SGI's cpumemset mechanism
for Linux 2.4 kernels.

SGI releases libcpuset under GPL license, though currently I've just
set this up for customers of SGI's software.  Someday I hope to get
the current libcpuset up on oss.sgi.com, for all to use.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
