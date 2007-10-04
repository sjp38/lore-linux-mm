Date: Thu, 4 Oct 2007 02:04:34 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 3/6] cpuset write throttle
Message-Id: <20071004020434.ce5dbd0c.pj@sgi.com>
In-Reply-To: <1191485705.5574.1.camel@lappy>
References: <469D3342.3080405@google.com>
	<46E741B1.4030100@google.com>
	<46E7434F.9040506@google.com>
	<20070914161517.5ea3847f.akpm@linux-foundation.org>
	<4702E49D.2030206@google.com>
	<Pine.LNX.4.64.0710031045290.3525@schroedinger.engr.sgi.com>
	<4703FF89.4000601@google.com>
	<Pine.LNX.4.64.0710032055120.4560@schroedinger.engr.sgi.com>
	<1191483450.13204.96.camel@twins>
	<20071004005658.732b96cc.pj@sgi.com>
	<1191485705.5574.1.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: clameter@sgi.com, solo@google.com, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Peter wrote:
> Ugh, yeah. Its a statistical thing, but task_lock is quite a big lock to
> take. Are cpusets RCU freed?

Yes, current->cpuset is rcu freed.  And on the one hottest code path
that wants to look inside a cpuset, once per memory page allocation,
we look inside the current tasks cpuset to see if it has been modified
since last we looked (if it has, we go into slow path code to update
the current->mems_allowed nodemask.)   The code that does this, from
kernel/cpuset.c, is:

	rcu_read_lock();
	my_cpusets_mem_gen = task_cs(current)->mems_generation;
	rcu_read_unlock();

Sadly, I just noticed now, that with the new cgroup (aka container)
code in *-mm (and soon to be in 2.6.24), that 'task_cs' macro got
added, to deal with the fact that what used to be a single pointer in
the task struct directly to the tasks cpuset is now perhaps two more
dereferences and a second, buried, rcu guarded access away:

static inline struct cpuset *task_cs(struct task_struct *task)
{
        return container_of(task_subsys_state(task, cpuset_subsys_id),
                            struct cpuset, css);
}

static inline struct cgroup_subsys_state *task_subsys_state(
        struct task_struct *task, int subsys_id)
{
        return rcu_dereference(task->cgroups->subsys[subsys_id]);
}

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
