Subject: Re: [PATCH] Document Linux Memory Policy - V2
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070731151434.GA18506@skynet.ie>
References: <20070725111646.GA9098@skynet.ie>
	 <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
	 <20070726132336.GA18825@skynet.ie>
	 <Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com>
	 <20070726225920.GA10225@skynet.ie>
	 <Pine.LNX.4.64.0707261819530.18210@schroedinger.engr.sgi.com>
	 <20070727082046.GA6301@skynet.ie> <20070727154519.GA21614@skynet.ie>
	 <Pine.LNX.4.64.0707271026040.15990@schroedinger.engr.sgi.com>
	 <1185559260.5069.40.camel@localhost>  <20070731151434.GA18506@skynet.ie>
Content-Type: text/plain
Date: Tue, 31 Jul 2007 12:34:46 -0400
Message-Id: <1185899686.6240.64.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com, Michael Kerrisk <mtk-manpages@gmx.net>, Randy Dunlap <randy.dunlap@oracle.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Thanks for the review, Mel.

On Tue, 2007-07-31 at 16:14 +0100, Mel Gorman wrote:
> On (27/07/07 14:00), Lee Schermerhorn didst pronounce:
> > Here's a second attempt to document the existing Linux Memory Policy.
> > I've tried to address comments on the first cut from Christoph and Andi.
> > I've removed the details of the APIs and referenced the man pages "for
> > more details".  I've made a stab at addressing the interaction with
> > cpusets, but more could be done here.
> > 
> > I'm hoping we can get this merged in some form, and then update it with
> > all of the policy changes that are in the queue and/or being
> > worked--memoryless nodes, interaction with ZONE_MOVABLE, ... .
> > 
> > Lee
> > 
> > ----------------
> > 
> > [PATCH] Document Linux Memory Policy - V2
> > 
> > I couldn't find any memory policy documentation in the Documentation
> > directory, so here is my attempt to document it.
> > 
> > There's lots more that could be written about the internal design--including
> > data structures, functions, etc.  However, if you agree that this is better
> > that the nothing that exists now, perhaps it could be merged.  This will
> > provide a baseline for updates to document the many policy patches that are
> > currently being worked.
> > 
> 
> As pointed out elsewhere, you are better off describing how the policies
> appear to behave from outside. If you describe the internals to any decent
> level of detail, it'll be obsolete in 6 months time.

OK.  I'll try to do that, without losing what I consider important
semantics.  However, it'll only be obsolete if people post patches that
change the behavior w/o updating the doc.  That NEVER happens,
right? ;-)

I will note, tho', that the cpuset.txt doc, for example, contains a
section entitled "How are cpusets implemented?"  And look at
sched_domains.txt or prio_tree.txt.  Granted, other docs just describe
the internal interface, but I don't understand why this document can't
expose some implementation details where they help to explain the
semantics. :-(

> 
> > Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> > 
> >  Documentation/vm/memory_policy.txt |  278 +++++++++++++++++++++++++++++++++++++
> >  1 file changed, 278 insertions(+)
> > 
> > Index: Linux/Documentation/vm/memory_policy.txt
> > ===================================================================
> > --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> > +++ Linux/Documentation/vm/memory_policy.txt	2007-07-27 13:40:45.000000000 -0400
> > @@ -0,0 +1,278 @@
> > +
> > +What is Linux Memory Policy?
> > +
> > +In the Linux kernel, "memory policy" determines from which node the kernel will
> > +allocate memory in a NUMA system or in an emulated NUMA system.  Linux has
> > +supported platforms with Non-Uniform Memory Access architectures since 2.4.?.
> > +The current memory policy support was added to Linux 2.6 around May 2004.  This
> > +document attempts to describe the concepts and APIs of the 2.6 memory policy
> > +support.
> > +
> > +See also Documentation/cpusets.txt which describes a higher level,
> > +administrative mechanism for restricting the set of nodes from which memory
> > +policy may allocate pages.  Also, see "MEMORY POLICIES AND CPUSETS" below.
> > +
> 
> hmm. This may conflate what cpusets and memory policies are. Try
> something like;
> 
> This should not be confused with cpusets (Documentation/cpusets.txt) which
> is an administrative mechanism for restricting the usable nodes memory be
> allocated from by a set of processes. Memory policies are a programming
> interface that a NUMA-aware application can take advantage of. When both
> cpusets and policies are applied to a task, the restrictions of the cpuset
> takes priority. See "MEMORY POLICIES AND CPUSETS" below for more details.

I like it, and will make the change.  Let's see if we get any push-back.
> 
> > +MEMORY POLICY CONCEPTS
> > +
> > +Scope of Memory Policies
> > +
> > +The Linux kernel supports four more or less distinct scopes of memory policy:
> > +
> 
> The sentence is too passive. State with certainity like
> 
> The Linux kernel supports four distinct scopes of memory policy:
> 
> Otherwise when I'm reading it I feel I must check if there are more or
> less than four types of policy.

OK.  I meant they were "more or less distinct".  I guess, really, they
are distinct...

> 
> > +    System Default Policy:  this policy is "hard coded" into the kernel.  It
> > +    is the policy that governs the all page allocations that aren't controlled
> > +    by one of the more specific policy scopes discussed below.
> > +
> 
> It's not stated what this policy means until much later. Forward
> references like that may be confusing so consider adding something like;
> 
> The default policy will allocate from the closest memory node to the currently
> running CPU and fallback to nodes in order of distance.

Well, here I'm trying to describe the "scopes", not the behavior.  I
think that the various policy scopes and their interaction is an
important semantic.  The "system default policy" just happens to
"MPOL_DEFAULT" when the system is up and running.  However, during boot,
it is MPOL_INTERLEAVE.  

> 
> > +    Task/Process Policy:  this is an optional, per-task policy.  When defined
> > +    for a specific task, this policy controls all page allocations made by or
> > +    on behalf of the task that aren't controlled by a more specific scope.
> > +    If a task does not define a task policy, then all page allocations that
> > +    would have been controlled by the task policy "fall back" to the System
> > +    Default Policy.
> > +
> 
> Consider reversing the order you are talking about the policies. If you
> discuss the policies with more restricted scope and finish with the
> default policy, you can avoid future references.

Again, I'm describing scope.  However, I could describe policies before
scope, but then, I'd need to forward reference VMA policy scope when
describing MPOL_DEFAULT, because MPOL_DEFAULT has
context/scope-dependent behavior.  Circular dependency!

> 
> > +	Because task policy applies to the entire address space of a task,
> > +	it is inheritable across both fork() [clone() w/o the CLONE_VM flag]
> > +	and exec*(). 
> 
> Remove "Because" here. The policy is not inherited across fork() because
> it applies to the address space. It's because policy is stored in the
> task_struct and it's not cleared by fork() or exec().
> 
> The use of inheritable here implies that the process must take some
> special action for the child to inherit the policy. Is that the case? If
> not, say inherited instead of inheritable.

I guess what I was trying to say is that it CAN be inherited ["is
inheritable"] because it applies to the entire address space.  And, not
everything in the task struct is inherited by the child, right?   And, I
wanted to emphasize that it is inheritED across exec.  I will try to
reword.

> 
> > Thus, a parent task may establish the task policy for
> > +	a child task exec()'d from an executable image that has no awareness
> > +	of memory policy.
> > +
> > +	In a multi-threaded task, task policies apply only to the thread
> > +	[Linux kernel task] that installs the policy and any threads
> > +	subsequently created by that thread.  Any sibling threads existing
> > +	at the time a new task policy is installed retain their current
> > +	policy.
> > +
> 
> Is it worth mentioning numactl here?

Actually, I tried not to mention numactl by name--just that that APIs
and headers reside in an "out of tree" package.  This is a kernel doc
and I wasn't sure about referencing out of tree "stuff"..  Andi
suggested that I not try to describe the syscalls in any detail [thus my
updates to the man pages], and I removed that.  But, I'll figure out a
way to forward reference the brief API descriptions later in the doc.

> 
> > +	A task policy applies only to pages allocated after the policy is
> > +	installed.  Any pages already faulted in by the task remain where
> > +	they were allocated based on the policy at the time they were
> > +	allocated.
> > +
> > +    VMA Policy:  A "VMA" or "Virtual Memory Area" refers to a range of a task's
> > +    virtual adddress space.  A task may define a specific policy for a range
> > +    of its virtual address space.  This VMA policy will govern the allocation
> > +    of pages that back this region of the address space.  Any regions of the
> > +    task's address space that don't have an explicit VMA policy will fall back
> > +    to the task policy, which may itself fall back to the system default policy.
> > +
> > +	VMA policy applies ONLY to anonymous pages.  These include pages
> > +	allocated for anonymous segments, such as the task stack and heap, and
> > +	any regions of the address space mmap()ed with the MAP_ANONYMOUS flag.
> > +	Anonymous pages copied from private file mappings [files mmap()ed with
> > +	the MAP_PRIVATE flag] also obey VMA policy, if defined.
> > +
> 
> The last sentence is confusing. Does it mean that policies can be
> applied to file mappings but only if they are MAP_PRIVATE and the policy
> only comes into play during COW?

Exactly!  I'll try to reword it.

> 
> > +	VMA policies are shared between all tasks that share a virtual address
> > +	space--a.k.a. threads--independent of when the policy is installed; and
> > +	they are inherited across fork().  However, because VMA policies refer
> > +	to a specific region of a task's address space, and because the address
> > +	space is discarded and recreated on exec*(), VMA policies are NOT
> > +	inheritable across exec().  Thus, only NUMA-aware applications may
> > +	use VMA policies.
> > +
> > +	A task may install a new VMA policy on a sub-range of a previously
> > +	mmap()ed region.  When this happens, Linux splits the existing virtual
> > +	memory area into 2 or 3 VMAs, each with it's own policy.
> > +
> > +	By default, VMA policy applies only to pages allocated after the policy
> > +	is installed.  Any pages already faulted into the VMA range remain where
> > +	they were allocated based on the policy at the time they were
> > +	allocated.  However, since 2.6.16, Linux supports page migration so
> > +	that page contents can be moved to match a newly installed policy.
> > +
> 
> State what system call is needed for the migration to take place.

OK.  I'll forward ref mbind().

> 
> > +    Shared Policy:  This policy applies to "memory objects" mapped shared into
> > +    one or more tasks' distinct address spaces.  Shared policies are applied
> > +    directly to the shared object.  Thus, all tasks that attach to the object
> > +    share the policy, and all pages allocated for the shared object, by any
> > +    task, will obey the shared policy.
> > +
> > +	Currently [2.6.22], only shared memory segments, created by shmget(),
> > +	support shared policy. 
> 
> This appears to contradict the previous paragram. The last paragraph
> would imply that the policy is applied to mappings that are mmaped
> MAP_SHARED where they really only apply to shmem mappings.

Conceptually, shared policies apply to shared "memory objects".
However, the implementation is incomplete--only shmem/shm object
currently support this concept.  [I'd REALLY like to fix this, but am
getting major push back... :-(]  

> 
> > +	When shared policy support was added to Linux,
> > +	the associated data structures were added to shared hugetlbfs segments.
> > +	However, at the time, hugetlbfs did not support allocation at fault
> > +	time--a.k.a lazy allocation--so hugetlbfs segments were never "hooked
> > +	up" to the shared policy support.  Although hugetlbfs segments now
> > +	support lazy allocation, their support for shared policy has not been
> > +	completed.
> > +
> > +	Although internal to the kernel shared memory segments are really
> > +	files backed by swap space that have been mmap()ed shared into tasks'
> > +	address spaces, regular files mmap()ed shared do NOT support shared
> > +	policy.  Rather, shared page cache pages, including pages backing
> > +	private mappings that have not yet been written by the task, follow
> > +	task policy, if any, else system default policy.
> > +
> > +	The shared policy infrastructure supports different policies on subset
> > +	ranges of the shared object.  However, Linux still splits the VMA of
> > +	the task that installs the policy for each range of distinct policy.
> > +	Thus, different tasks that attach to a shared memory segment can have
> > +	different VMA configurations mapping that one shared object.
> > +
> > +Components of Memory Policies
> > +
> > +    A Linux memory policy is a tuple consisting of a "mode" and an optional set
> > +    of nodes.  The mode determine the behavior of the policy, while the optional
> > +    set of nodes can be viewed as the arguments to the behavior.
> > +
> > +   Internally, memory policies are implemented by a reference counted structure,
> > +   struct mempolicy.  Details of this structure will be discussed in context,
> > +   below.
> > +
> > +	Note:  in some functions AND in the struct mempolicy, the mode is
> > +	called "policy".  However, to avoid confusion with the policy tuple,
> > +	this document will continue to use the term "mode".
> > +
> > +   Linux memory policy supports the following 4 modes:
> > +
> > +	Default Mode--MPOL_DEFAULT:  The behavior specified by this mode is
> > +	context dependent.
> > +
> > +	    During normal system operation, the system default policy is hard
> > +	    coded to contain the Default mode.  During system boot up, the
> > +	    system default policy is temporarily set to MPOL_INTERLEAVE [see
> > +	    below] to distribute boot time allocations across all nodes in
> > +	    the system, instead of using just the node containing the boot cpu.
> > +
> > +	    In this context, default mode means "local" allocation--that is
> > +	    attempt to allocate the page from the node associated with the cpu
> > +	    where the fault occurs.  If the "local" node has no memory, or the
> > +	    node's memory can be exhausted [no free pages available], local
> > +	    allocation will attempt to allocate pages from "nearby" nodes, using
> > +	    a per node list of nodes--called zonelists--built at boot time, or
> > +	    when nodes or memory are added or removed from the system [memory
> > +	    hotplug].
> > +
> > +	    When a task/process policy or a shared policy contains the Default
> > +	    mode, this also means local allocation, as described above.
> > +
> > +	    In the context of a VMA, Default mode means "fall back to task
> > +	    policy"--which may or may not specify Default mode.  Thus, Default
> > +	    mode can not be counted on to mean local allocation when used
> > +	    on a non-shared region of the address space.  However, see
> > +	    MPOL_PREFERRED below.
> > +
> > +	    The Default mode does not use the optional set of nodes.
> > +
> > +	MPOL_BIND:  This mode specifies that memory must come from the
> > +	set of nodes specified by the policy.  The kernel builds a custom
> > +	zonelist pointed to by the zonelist member of struct mempolicy,
> > +	containing just the nodes specified by the Bind policy.  If the kernel
> 
> Omit the implementation details here. Even now it is being considered to
> have just one zonelist per-node that is filtered based on the allocation
> requirements. For MPOL_BIND, this would involve __alloc_pages() taking a
> nodemask and ignoring nodes not allowed by the mask.
> 
> It's sufficent to say that MPOL_BIND will restrict the process to allocating
> pages within a set of nodes specified by a nodemask because the end result
> from the external observer will be similar.

OK.  But, I don't want to lose the idea that, with the BIND policy,
pages will be allocated first from one of the nodes [lowest #] and then
from the next and so on.  This is important, because I've had colleagues
complain to me that it was broken.  They thought that if they bound a
multithread application to cpus on several nodes and to the same nodes
memories, they would get local allocation with fall back only to the
nodes they specified.  They really wanted cpuset semantics, but these
were not available at the time.

For me, part of the problem is that BIND takes more than one node
without taking distance into account, nor allowing the user to specify
an explicit fallback order.

If the new zonelist filtering will change the behavior vis a vis what
node is selected from those specified with the policy, and what the
fallback order is, then we should update this doc when it changes.  I
can help...

> 
> > +	is unable to allocate a page from the first node in the custom zonelist,
> > +	it moves on to the next, and so forth.  If it is unable to allocate a
> > +	page from any of the nodes in this list, the allocation will fail.
> > +
> > +	    The memory policy APIs do not specify an order in which the nodes
> > +	    will be searched.  However, unlike the per node zonelists mentioned
> > +	    above, the custom zonelist for the Bind policy do not consider the
> > +	    distance between the nodes.  Rather, the lists are built in order
> > +	    of numeric node id.
> > +
> 
> Omit the last part as well because if we were filtering nodes based on a
> mask as described above, then MPOL_BIND would actually behave similar to
> the default policy except that is uses a subset of the available nodes.
> Arguably that is more sensible behaviour for MPOL_BIND than what it does today.

OK.  I'll rework this entire section.  Again, I don't want to lose what
I think are important semantics for a user.  And, maybe by documenting
ugly behavior for all to see, we'll do something about it?

> 
> > +	MPOL_PREFERRED:  This mode specifies that the allocation should be
> > +	attempted from the single node specified in the policy.  If that
> > +	allocation fails, the kernel will search other nodes, exactly as
> > +	it would for a local allocation that started at the preferred node--
> > +	that is, using the per-node zonelists in increasing distance from
> > +	the preferred node.
> > +
> > +	    Internally, the Preferred policy uses a single node--the
> > +	    preferred_node member of struct mempolicy.
> > +
> > +	    If the Preferred policy node is '-1', then at page allocation time,
> > +	    the kernel will use the "local node" as the starting point for the
> > +	    allocation.  This is the way to specify local allocation for a
> > +	    specific range of addresses--i.e. for VMA policies.
> > +
> 
> Again, consider omitting the implementation details here. They don't
> help as such.

OK.  I'll drop the '-1' bit.  I do want to maintain the notion of the
"local" variant of preferred.  This only works because the policy
contains a specific token for the preferred_node.  Not sure how to get
this concept across without mentioning something that smells of
implementation details.

> 
> > +	MPOL_INTERLEAVED:  This mode specifies that page allocations be
> > +	interleaved, on a page granularity, across the nodes specified in
> > +	the policy.  This mode also behaves slightly differently, based on
> > +	the context where it is used:
> > +
> > +	    For allocation of anonymous pages and shared memory pages,
> > +	    Interleave mode indexes the set of nodes specified by the policy
> > +	    using the page offset of the faulting address into the segment
> > +	    [VMA] containing the address modulo the number of nodes specified
> > +	    by the policy.  It then attempts to allocate a page, starting at
> > +	    the selected node, as if the node had been specified by a Preferred
> > +	    policy or had been selected by a local allocation.  That is,
> > +	    allocation will follow the per node zonelist.
> > +
> > +	    For allocation of page cache pages, Interleave mode indexes the set
> > +	    of nodes specified by the policy using a node counter maintained
> > +	    per task.  This counter wraps around to the lowest specified node
> > +	    after it reaches the highest specified node.  This will tend to
> > +	    spread the pages out over the nodes specified by the policy based
> > +	    on the order in which they are allocated, rather than based on any
> > +	    page offset into an address range or file.  During system boot up,
> > +	    the temporary interleaved system default policy works in this
> > +	    mode.
> > +
> 
> Oddly, these implementation details are really useful. Keep this one here
> but it would be great if they were in the manual pages.
> 
> > +MEMORY POLICIES AND CPUSETS
> > +
> > +Memory policies work within cpusets as described above.  For memory policies
> > +that require a node or set of nodes, the nodes are restricted to the set of
> > +nodes whose memories are allowed by the cpuset constraints.  This can be
> > +problematic for 2 reasons:
> > +
> > +1) the memory policy APIs take physical node id's as arguments.  However, the
> > +   memory policy APIs do not provide a way to determine what nodes are valid
> > +   in the context where the application is running.  An application MAY consult
> > +   the cpuset file system [directly or via an out of tree, and not generally
> > +   available, libcpuset API] to obtain this information, but then the
> > +   application must be aware that it is running in a cpuset and use what are
> > +   intended primarily as administrative APIs.
> > +
> > +2) when tasks in two cpusets share access to a memory region, such as shared
> > +   memory segments created by shmget() of mmap() with the MAP_ANONYMOUS and
> > +   MAP_SHARED flags, only nodes whose memories are allowed in both cpusets
> > +   may be used in the policies.  Again, obtaining this information requires
> > +   "stepping outside" the memory policy APIs to use the cpuset information.
> > +   Furthermore, if the cpusets' "allowed memory" sets are disjoint, "local"
> > +   allocation is the only valid policy.
> > +
> 
> Consider moving this section to the end. It reads better to keep the discussion
> in the context of policies for as long as possible. Otherwise it's
> 
> Section 1: policies
> Section 2: policies
> Section 3: policies + cpusets
> Section 4: policies
> 
> > +MEMORY POLICY APIs
> > +
> > +Linux supports 3 system calls for controlling memory policy.  These APIS
> 
> s/APIS/APIs/
> 
> > +always affect only the calling task, the calling task's address space, or
> > +some shared object mapped into the calling task's address space.
> > +
> > +	Note:  the headers that define these APIs and the parameter data types
> > +	for user space applications reside in a package that is not part of
> > +	the Linux kernel.  The kernel system call interfaces, with the 'sys_'
> > +	prefix, are defined in <linux/syscalls.h>; the mode and flag
> > +	definitions are defined in <linux/mempolicy.h>.
> > +
> > +Set [Task] Memory Policy:
> > +
> > +	long set_mempolicy(int mode, const unsigned long *nmask,
> > +					unsigned long maxnode);
> > +
> > +	Set's the calling task's "task/process memory policy" to mode
> > +	specified by the 'mode' argument and the set of nodes defined
> > +	by 'nmask'.  'nmask' points to a bit mask of node ids containing
> > +	at least 'maxnode' ids.
> > +
> > +	See the set_mempolicy(2) man page for more details
> > +
> > +
> > +Get [Task] Memory Policy or Related Information
> > +
> > +	long get_mempolicy(int *mode,
> > +			   const unsigned long *nmask, unsigned long maxnode,
> > +			   void *addr, int flags);
> > +
> > +	Queries the "task/process memory policy" of the calling task, or
> > +	the policy or location of a specified virtual address, depending
> > +	on the 'flags' argument.
> > +
> > +	See the get_mempolicy(2) man page for more details
> > +
> > +
> > +Install VMA/Shared Policy for a Range of Task's Address Space
> > +
> > +	long mbind(void *start, unsigned long len, int mode,
> > +		   const unsigned long *nmask, unsigned long maxnode,
> > +		   unsigned flags);
> > +
> > +	mbind() installs the policy specified by (mode, nmask, maxnodes) as
> > +	a VMA policy for the range of the calling task's address space
> > +	specified by the 'start' and 'len' arguments.  Additional actions
> > +	may be requested via the 'flags' argument.
> > +
> > +	See the mbind(2) man page for more details.
> > 
> 
> Despite the comments, this is good work and really useful. I'd be fairly
> happy with it even without further revisions. Thanks a lot for the read.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
