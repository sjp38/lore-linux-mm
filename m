Subject: Re: [PATCH] Document Linux Memory Policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>
	 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 30 May 2007 12:55:03 -0400
Message-Id: <1180544104.5850.70.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-05-29 at 13:04 -0700, Christoph Lameter wrote:
> On Tue, 29 May 2007, Lee Schermerhorn wrote:
> 
> > +	A task policy applies only to pages allocated after the policy is
> > +	installed.  Any pages already faulted in by the task remain where
> > +	they were allocated based on the policy at the time they were
> > +	allocated.
> 
> You can use cpusets to automatically migrate pages and sys_migrate_pages 
> to manually migrate pages of a process though.

I consider cpusets, and the explicit migration APIs, orthogonal to
mempolicy.  Mempolicy is an application interface, while cpusets are an
administrative interface that restricts what mempolicy can ask for.  And
sys_migrate_pages/sys_move_pages seem to ignore mempolicy altogether.

I would agree, however, that they could be better integrated.  E.g., how
can a NUMA-aware application [one that uses the mempolicy APIs]
determine what memories it's allowed to use.  So far, all I've been able
to determine is that I try each node in the mask and the ones that don't
error out are valid.  Seems a bit awkward...

> 
> > +    VMA Policy:  A "VMA" or "Virtual Memory Area" refers to a range of a task's
> > +    virtual adddress space.  A task may define a specific policy for a range
> > +    of its virtual address space.  This VMA policy will govern the allocation
> > +    of pages that back this region of the address space.  Any regions of the
> > +    task's address space that don't have an explicit VMA policy will fall back
> > +    to the task policy, which may itself fall back to the system default policy.
> 
> The system default policy is always the same when the system is running. 
> There is no way to configure it. So it would be easier to avoid this layer 
> and say they fall back to node local

What you describe is, indeed, the effect, but I'm trying to explain why
it works that way.  
> 
> 
> > +	VMA policies are shared between all tasks that share a virtual address
> > +	space--a.k.a. threads--independent of when the policy is installed; and
> > +	they are inherited across fork().  However, because VMA policies refer
> > +	to a specific region of a task's address space, and because the address
> > +	space is discarded and recreated on exec*(), VMA policies are NOT
> > +	inheritable across exec().  Thus, only NUMA-aware applications may
> > +	use VMA policies.
> 
> Memory policies require NUMA. Drop the last sentence? You can set the task 
> policy via numactl though.

I disagree about dropping the last sentence.  I can/will define
NUMA-aware as applications that directly call the mempolicy APIs.  You
can run an unmodified, non-NUMA-aware program on a NUMA platform with or
without numactl and take whatever performance you get.  In some cases,
you'll be leaving performance on the table, but that may be a trade-off
some are willing to make not to have to modify their existing
applications.

> 
> > +    Shared Policy:  This policy applies to "memory objects" mapped shared into
> > +    one or more tasks' distinct address spaces.  Shared policies are applied
> > +    directly to the shared object.  Thus, all tasks that attach to the object
> > +    share the policy, and all pages allocated for the shared object, by any
> > +    task, will obey the shared policy.
> > +
> > +	Currently [2.6.22], only shared memory segments, created by shmget(),
> > +	support shared policy.  When shared policy support was added to Linux,
> > +	the associated data structures were added to shared hugetlbfs segments.
> > +	However, at the time, hugetlbfs did not support allocation at fault
> > +	time--a.k.a lazy allocation--so hugetlbfs segments were never "hooked
> > +	up" to the shared policy support.  Although hugetlbfs segments now
> > +	support lazy allocation, their support for shared policy has not been
> > +	completed.
> 
> I guess patches would be welcome to complete it. But that may only be 
> releveant if huge pages are shared between processes. We so far have no 
> case in which that support is required.

See response to Andi's mail re:  data base use of shmem & hugepages.

> 
> > +	Although internal to the kernel shared memory segments are really
> > +	files backed by swap space that have been mmap()ed shared into tasks'
> > +	address spaces, regular files mmap()ed shared do NOT support shared
> > +	policy.  Rather, shared page cache pages, including pages backing
> > +	private mappings that have not yet been written by the task, follow
> > +	task policy, if any, else system default policy.
> 
> Yes. shared memory segments do not represent file content. The file 
> content of mmap pages may exist before the mmap. Also there may be regular
> buffered I/O going on which will also use the task policy. 

Unix/Posix/Linux semantics are very flexible with respect to file
description access [read, write, et al] and memory mapped access to
files.  One CAN access files via both of these interfaces, and the
system jumps through hoops backwards [e.g., consider truncation] to make
it work.  However, some applications just access the files via mmap()
and want to control the NUMA placement like any other component of their
address space.   Read/write access to such a file, while I agree it
should work, is, IMO, secondary to load/store access.  In such a case,
the performance of the load/store access shouldn't be sacrificed for the
read/write case, which already has to go through system calls, buffer
copies, ...

> 
> Having no vma policy support insures that pagecache pages regardless if 
> they are mmapped or not will get the task policy applied.

Which is fine if that's what you want.  If you're using a memory mapped
file as a persistent shared memory area that faults pages in where you
specified, as you access them, maybe that's not what you want.  I
guarantee that's not what I want.

However, it seems to me, this is our other discussion.  What I've tried
to do with this patch is document the existing concepts and behavior, as
I understand them.  

> 
> > +   Linux memory policy supports the following 4 modes:
> > +
> > +	Default Mode--MPOL_DEFAULT:  The behavior specified by this mode is
> > +	context dependent.
> > +
> > +	    The system default policy is hard coded to contain the Default mode.
> > +	    In this context, it means "local" allocation--that is attempt to
> > +	    allocate the page from the node associated with the cpu where the
> > +	    fault occurs.  If the "local" node has no memory, or the node's
> > +	    memory can be exhausted [no free pages available], local allocation
> > +	    will attempt to allocate pages from "nearby" nodes, using a per node
> > +	    list of nodes--called zonelists--built at boot time.
> > +
> > +		TODO:  address runtime rebuild of node/zonelists when
> > +		supported.
> 
> Why?

Because "built at boot time" is then not strictly correct, is it?  
> 
> > +	    When a task/process policy contains the Default mode, it means
> > +	    "fall back to the system default mode".  And, as discussed above,
> > +	    this means use "local" allocation.
> 
> This would be easier if you would drop the system default mode and simply 
> say its node local.

I'm trying to build the reader's mental map.  
> 
> > +	    In the context of a VMA, Default mode means "fall back to task
> > +	    policy"--which may, itself, fall back to system default policy.
> > +	    In the context of shared policies, Default mode means fall back
> > +	    directly to the system default policy.  Note:  the result of this
> > +	    semantic is that if the task policy is something other than Default,
> > +	    it is not possible to specify local allocation for a region of the
> > +	    task's address space using a VMA policy.
> > +
> > +	    The Default mode does not use the optional set of nodes.
> 
> Neither does the preferred node mode.

Actually, it does take the node mask argument.  It just selects the
first node therein.  See response to Andi.

> 
> > +	MPOL_BIND:  This mode specifies that memory must come from the
> > +	set of nodes specified by the policy.  The kernel builds a custom
> > +	zonelist containing just the nodes specified by the Bind policy.
> > +	If the kernel is unable to allocate a page from the first node in the
> > +	custom zonelist, it moves on to the next, and so forth.  If it is unable
> > +	to allocate a page from any of the nodes in this list, the allocation
> > +	will fail.
> > +
> > +	    The memory policy APIs do not specify an order in which the nodes
> > +	    will be searched.  However, unlike the per node zonelists mentioned
> > +	    above, the custom zonelist for the Bind policy do not consider the
> > +	    distance between the nodes.  Rather, the lists are built in order
> > +	    of numeric node id.
> 
> Right. TODO: MPOL_BIND needs to pick the best node.
> 
> > +	MPOL_PREFERRED:  This mode specifies that the allocation should be
> > +	attempted from the single node specified in the policy.  If that
> > +	allocation fails, the kernel will search other nodes, exactly as
> > +	it would for a local allocation that started at the preferred node--
> > +	that is, using the per-node zonelists in increasing distance from
> > +	the preferred node.
> > +
> > +	    If the Preferred policy specifies more than one node, the node
> > +	    with the numerically lowest node id will be selected to start
> > +	    the allocation scan.
> 
> AFAIK perferred policy was only intended to specify one node.

Covered in response to Andi.
> 
> > +	    For allocation of page cache pages, Interleave mode indexes the set
> > +	    of nodes specified by the policy using a node counter maintained
> > +	    per task.  This counter wraps around to the lowest specified node
> > +	    after it reaches the highest specified node.  This will tend to
> > +	    spread the pages out over the nodes specified by the policy based
> > +	    on the order in which they are allocated, rather than based on any
> > +	    page offset into an address range or file.
> 
> Which is particularly important if random pages in a file are used.
> 
> > +Linux supports 3 system calls for controlling memory policy.  These APIS
> > +always affect only the calling task, the calling task's address space, or
> > +some shared object mapped into the calling task's address space.
> 
> These are wrapped by the numactl library. So these are not exposed to the 
> user.
> 
> > +	Note:  the headers that define these APIs and the parameter data types
> > +	for user space applications reside in a package that is not part of
> > +	the Linux kernel.  The kernel system call interfaces, with the 'sys_'
> > +	prefix, are defined in <linux/syscalls.h>; the mode and flag
> > +	definitions are defined in <linux/mempolicy.h>.
> 
> You need to mention the numactl library here.

I'm trying to describe kernel behavior.  I would expect this to be
picked up by the man pages at some time.  As I responded to Andi, I'll
work the maintainers... When I get the time.
> 
> > +	'flags' may also contain 'MPOL_F_NODE'.  This flag has been
> > +	described in some get_mempolicy() man pages as "not for application
> > +	use" and subject to change.  Applications are cautioned against
> > +	using it.  However, for completeness and because it is useful for
> > +	testing the kernel memory policy support, current behavior is
> > +	documented here:
> 
> The docs are wrong. This is fully supported.
> 
> > +	    Note:  if the address specifies an anonymous region of the
> > +	    task's address space with no page currently allocated, the
> > +	    resulting "read access fault" will likely just map the shared
> > +	    ZEROPAGE.  It will NOT, for example, allocate a local page in
> > +	    the case of default policy [unless the task happens to be
> > +	    running on the node containing the ZEROPAGE], nor will it obey
> > +	    VMA policy, if any.
> 
> Yes the intend for it was to be used on a mapped page.

Just pointing out that this might not be what you expect.  E.g., if you
mbind() an anonymous region to some node where the ZEROPAGE does NOT
reside [do we intend to do per node ZEROPAGEs, or was that idea
dropped?], fault in the pages via read access and then query the page
location, either via get_mempolicy() w/ '_ADDR|"_NODE or via numa_maps,
you'll see the pages on some node you don't expect and think it's
broken.  Well, not YOU, but someone not familiar with kernel internals
might.  

> 
> > +	If the address space range covers an anonymous region or a private
> > +	mapping of a regular file, a VMA policy will be installed in this
> > +	region.  This policy will govern all subsequent allocations of pages
> > +	for that range for all threads in the task.
> 
> Wont it be installed regardless if it is anonymous or not?

Yes, I suppose I could reword that and the next paragraph differently.

> 
> > +	If the address space range covers a shared mapping of a regular
> > +	file, a VMA policy will be installed for that range.  This policy
> > +	will be ignored for all page allocations by the calling task or
> > +	by any other task.  Rather, all page allocations in that range will
> > +	be allocated using the faulting task's task policy, if any, else
> > +	the system default policy.
> 
> The policy is going to be used for COW in that range.

You don't get COW if it's a shared mapping.  You use the page cache
pages which ignores my mbind().  That's my beef!  [;-)]

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
