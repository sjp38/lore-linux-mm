Date: Sun, 17 Jul 2005 01:17:02 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [NUMA] Display and modify the memory policy of a process
 through /proc/<pid>/numa_policy
Message-Id: <20050717011702.23f8a269.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.62.0507162256180.28788@schroedinger.engr.sgi.com>
References: <20050715214700.GJ15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com>
	<20050715220753.GK15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com>
	<20050715223756.GL15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com>
	<20050715225635.GM15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151602390.12530@schroedinger.engr.sgi.com>
	<20050715234402.GN15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151647300.12832@schroedinger.engr.sgi.com>
	<20050716020141.GO15783@wotan.suse.de>
	<20050716163030.0147b6ba.pj@sgi.com>
	<Pine.LNX.4.62.0507162016470.27506@schroedinger.engr.sgi.com>
	<20050716215121.6c04ffb0.pj@sgi.com>
	<Pine.LNX.4.62.0507162256180.28788@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: ak@suse.de, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph wrote:
> Could you give me some more detail on how this should integrate with 
> cpusets? I am not aware of any thing that I would call "hard".

I can't speak to how "hard" it is, but what I have in mind is the
following lines from the mm/mempolicy.c get_nodes() routine:

        /* Update current mems_allowed */
        cpuset_update_current_mems_allowed();
        /* Ignore nodes not set in current->mems_allowed */
        cpuset_restrict_to_mems_allowed(nodes);

These lines insure that the current tasks mems_allowed is uptodate
with any constraints imposed by the tasks cpuset, and then they
restrict the nodes to that mems_allowed.

Offhand, I do not know a safe way to update a tasks mems_allowed
from its cpuset, except within the tasks context.  This is why
'mems_generation' and cpuset_update_current_mems_allowed() exist.

If you can find a way, more power to you.  I could simiply the
cpuset mems_generation apparatus if I had such a way.

The above get_nodes() routines is called by mbind() and set_mempolicy(),
when passing in a list of memory nodes as part of a memory policy.


> What do you mean by synchronously? 

Probably what Andi is referring to when he worries about locking.
If so, he certainly understands this better than I.

But for example, I notice that the check_range() routine is called
for mbind() requests.  The check_range() code does a bunch of poking
around in the current tasks vma structs.  How do you propose to allow
a separate task to do this safely?

Also, there are several derefences of the pointer 'current'. and to
further mm and vma state referenced via current, to pick up various
attributes of the current task and its memory.  Each one of these
has to be examined, I presume, in order to determine what accesses
can safely be done from an external task, and still obtain consistent
results.


> There is no transactional behavior that allows the changes of multiple
> items at once, nor is there any guarantee that the vma you are changing
> is still there after you have read /proc/<pid>/numa_maps. Why would
> such synchronicity be necessary?

I agree that such is not possible, present nor necessary.

I am worried about what happens within a single mbind or set_mempolicy
call attempted on an external task, not what happens between one such
call and the next.

Clearly the mm/mempolicy code for mbind and set_mempolicy was written
with the assumption that it applied to the current task, its mm
and vmas, and hence the current task was stuck inside this code.

A variety of task and memory state is read and written, without
need for much locking, because we are single threaded in the only
task that is allowed to modify this state.  The author of this code
repeatedly expresses concerns that external modification will fail
due to locking issues.

To me, that means it will take, at best, a careful and detailed
analysis to have any hope of safe external modification of this state,
if it is possible at all.

This is why I suspect we need a way to plug in code that executes in
the context of a task, to apply externally determined changes to the
tasks memory layout.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
