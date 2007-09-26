Date: Tue, 25 Sep 2007 21:14:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 7/5] oom: filter tasklist dump by mem_cgroup
In-Reply-To: <20070925205632.47795637.pj@sgi.com>
Message-ID: <alpine.DEB.0.9999.0709252104180.30932@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709250037030.11015@chino.kir.corp.google.com> <6599ad830709251100n352028beraddaf2ac33ea8f6c@mail.gmail.com> <20070925181442.aeb7b205.pj@sgi.com>
 <alpine.DEB.0.9999.0709251819400.19627@chino.kir.corp.google.com> <20070925205632.47795637.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: menage@google.com, akpm@linux-foundation.org, clameter@sgi.com, balbir@linux.vnet.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Sep 2007, Paul Jackson wrote:

> > CONSTRAINT_CPUSET isn't as simple as just killing current anymore in -mm.  
> > For that behavior, you need
> > 
> > 	echo 1 > /proc/sys/vm/oom_kill_allocating_task
> 
> True.
> 
> ... but what about configs with overlappnig cpusets that don't set
> oom_kill_allocating_tasks ?
> 

The OOM killer in -mm no longer checks cpuset_excl_nodes_overlap() to 
select an overlapping task and, in fact, that function has been removed 
entirely from kernel/cpuset.c.

If oom_kill_allocating_tasks is zero (which it is by default), the 
tasklist is scanned and each task is checked for intersection with 
current's mems_allowed (task->mems_allowed, not dereferencing 
task->cpuset).  If it doesn't intersect, its "badness" score is divided by 
eight.

It is not necessarily eliminated from being a kill candidate, however, 
because it may have allocated memory on nodes that are not in 
task->mems_allowed in the past (such as GFP_ATOMIC allocations, tasks 
moved between cpusets, or cpusets with adjusted mems).

> > If an OOM was triggered as a result a cgroup's memory controller, the
> > tasklist shall be filtered to exclude tasks that are not a member of the
> > same group.
> 
> I would think that excluding tasks not in the same cpuset (if that's what
> "not a member of the same group" would mean here) wouldn't be the right
> thing to do, if the cpusets had overlapping mems_allowed and if we had
> not set oom_kill_allocating_task.
> 

Yes, absolutely.

I think Paul Menage is talking about filtering tasks that are not a member 
of the same cpuset because we're more familiar with mem_exclusive cpusets.  
So I think his suggestion was initially to filter based on overlapping 
mems_allowed instead, which makes sense.

	void dump_tasks(const struct mem_cgroup *mem)
	{
		struct task_struct *g, *p;

		do_each_thread(g, p) {
			...

			if (!task_in_mem_cgroup(p, mem)
				continue;
			if (!cpuset_mems_allowed_intersects(current, p))
				continue;

			/* show the task information */

		} while_each_thread(g, p);
	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
