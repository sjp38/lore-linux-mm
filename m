From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Document Linux Memory Policy
Date: Tue, 29 May 2007 22:07:58 +0200
References: <1180467234.5067.52.camel@localhost>
In-Reply-To: <1180467234.5067.52.camel@localhost>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200705292207.58774.ak@suse.de>
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Michael Kerrisk <mtk-manpages@gmx.net>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 29 May 2007 21:33, Lee Schermerhorn wrote:
> [PATCH] Document Linux Memory Policy
>
> I couldn't find any memory policy documentation in the Documentation
> directory, so here is my attempt to document it.  My objectives are
> two fold:

The theory is that the comment at the top of mempolicy.c gives an brief 
internal oriented overview and the manpages describe the details. I must say 
I'm not a big fan of too much redundant documentation because the likelihood 
of bitrotting increases more with more redundancy.  We also normally don't 
keep  syscall documentation in Documentation/*

I see you got a few details that are right now missing in the manpages.
How about you just add them to the mbind/set_mempolicy/etc manpages 
(and perhaps a new numa.7)  and send a patch to the manpage
maintainer (cc'ed)?  I believe having everything in the manpages
is the most useful for userland programmers who hardly look
into Documentation/* (in fact it is often not installed on systems
without kernel source)

The comment in mempolicy.c could probably also be improved a bit
for anything internal.

-Andi

>
> 1) to provide missing documentation for anyone interested in this topic,
>
> 2) to explain my current understanding, on which I base proposed patches
>    to address what I see as missing or broken behavior.
>
> There's lots more that could be written about the internal
> design--including data structures, functions, etc.  And one could address
> the interaction of memory policy with cpusets.  I haven't tackled that yet.
>  However, if you agree that this is better that the nothing that exists
> now, perhaps it could be added to -mm.
>
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
>
>  Documentation/vm/memory_policy.txt |  339
> +++++++++++++++++++++++++++++++++++++ 1 files changed, 339 insertions(+)
>
> Index: Linux/Documentation/vm/memory_policy.txt
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ Linux/Documentation/vm/memory_policy.txt	2007-05-29 15:08:01.000000000
> -0400 @@ -0,0 +1,339 @@
> +
> +What is Linux Memory Policy?
> +
> +In the Linux kernel, "memory policy" determines from which node the kernel
> will +allocate memory in a NUMA system or in an emulated NUMA system. 
> Linux has +supported platforms with Non-Uniform Memory Access architectures
> since 2.4.?. +The current memory policy support was added to Linux 2.6
> around May 2004.  This +document attempts to describe the concepts and APIs
> of the 2.6 memory policy +support.
> +
> +	TODO:  try to describe internal design?
> +
> +MEMORY POLICY CONCEPTS
> +
> +Scope of Memory Policies
> +
> +The Linux kernel supports four more or less distinct scopes of memory
> policy: +
> +    System Default Policy:  this policy is "hard coded" into the kernel. 
> It +    is the policy that governs the all page allocations that aren't
> controlled +    by one of the more specific policy scopes discussed below.
> +
> +    Task/Process Policy:  this is an optional, per-task policy.  When
> defined +    for a specific task, this policy controls all page allocations
> made by or +    on behalf of the task that aren't controlled by a more
> specific scope. +    If a task does not define a task policy, then all page
> allocations that +    would have been controlled by the task policy "fall
> back" to the System +    Default Policy.
> +
> +	Because task policy applies to the entire address space of a task,
> +	it is inheritable across both fork() [clone() w/o the CLONE_VM flag]
> +	and exec*().  Thus, a parent task may establish the task policy for
> +	a child task exec()'d from an executable image that has no awareness
> +	of memory policy.
> +
> +	In a multi-threaded task, task policies apply only to the thread
> +	[Linux kernel task] that installs the policy and any threads
> +	subsequently created by that thread.  Any sibling threads existing
> +	at the time a new task policy is installed retain their current
> +	policy.
> +
> +	A task policy applies only to pages allocated after the policy is
> +	installed.  Any pages already faulted in by the task remain where
> +	they were allocated based on the policy at the time they were
> +	allocated.
> +
> +    VMA Policy:  A "VMA" or "Virtual Memory Area" refers to a range of a
> task's +    virtual adddress space.  A task may define a specific policy
> for a range +    of its virtual address space.  This VMA policy will govern
> the allocation +    of pages that back this region of the address space. 
> Any regions of the +    task's address space that don't have an explicit
> VMA policy will fall back +    to the task policy, which may itself fall
> back to the system default policy. +
> +	VMA policy applies ONLY to anonymous pages.  These include pages
> +	allocated for anonymous segments, such as the task stack and heap, and
> +	any regions of the address space mmap()ed with the MAP_ANONYMOUS flag.
> +	Anonymous pages copied from private file mappings [files mmap()ed with
> +	the MAP_PRIVATE flag] also obey VMA policy, if defined.
> +
> +	VMA policies are shared between all tasks that share a virtual address
> +	space--a.k.a. threads--independent of when the policy is installed; and
> +	they are inherited across fork().  However, because VMA policies refer
> +	to a specific region of a task's address space, and because the address
> +	space is discarded and recreated on exec*(), VMA policies are NOT
> +	inheritable across exec().  Thus, only NUMA-aware applications may
> +	use VMA policies.
> +
> +	A task may install a new VMA policy on a sub-range of a previously
> +	mmap()ed region.  When this happens, Linux splits the existing virtual
> +	memory area into 2 or 3 VMAs, each with it's own policy.
> +
> +	By default, VMA policy applies only to pages allocated after the policy
> +	is installed.  Any pages already faulted into the VMA range remain where
> +	they were allocated based on the policy at the time they were
> +	allocated.  However, since 2.6.16, Linux supports page migration so
> +	that page contents can be moved to match a newly installed policy.
> +
> +    Shared Policy:  This policy applies to "memory objects" mapped shared
> into +    one or more tasks' distinct address spaces.  Shared policies are
> applied +    directly to the shared object.  Thus, all tasks that attach to
> the object +    share the policy, and all pages allocated for the shared
> object, by any +    task, will obey the shared policy.
> +
> +	Currently [2.6.22], only shared memory segments, created by shmget(),
> +	support shared policy.  When shared policy support was added to Linux,
> +	the associated data structures were added to shared hugetlbfs segments.
> +	However, at the time, hugetlbfs did not support allocation at fault
> +	time--a.k.a lazy allocation--so hugetlbfs segments were never "hooked
> +	up" to the shared policy support.  Although hugetlbfs segments now
> +	support lazy allocation, their support for shared policy has not been
> +	completed.
> +
> +	Although internal to the kernel shared memory segments are really
> +	files backed by swap space that have been mmap()ed shared into tasks'
> +	address spaces, regular files mmap()ed shared do NOT support shared
> +	policy.  Rather, shared page cache pages, including pages backing
> +	private mappings that have not yet been written by the task, follow
> +	task policy, if any, else system default policy.
> +
> +	The shared policy infrastructure supports different policies on subset
> +	ranges of the shared object.  However, Linux still splits the VMA of
> +	the task that installs the policy for each range of distinct policy.
> +	Thus, different tasks that attach to a shared memory segment can have
> +	different VMA configurations mapping that one shared object.
> +
> +Components of Memory Policies
> +
> +    A Linux memory policy is a tuple consisting of a "mode" and an
> optional set +    of nodes.  The mode determine the behavior of the policy,
> while the optional +    set of nodes can be viewed as the arguments to the
> behavior.
> +
> +	Note:  in some functions, the mode is called "policy".  However, to
> +	avoid confusion with the policy tuple, this document will continue
> +	to use the term "mode".
> +
> +   Linux memory policy supports the following 4 modes:
> +
> +	Default Mode--MPOL_DEFAULT:  The behavior specified by this mode is
> +	context dependent.
> +
> +	    The system default policy is hard coded to contain the Default mode.
> +	    In this context, it means "local" allocation--that is attempt to
> +	    allocate the page from the node associated with the cpu where the
> +	    fault occurs.  If the "local" node has no memory, or the node's
> +	    memory can be exhausted [no free pages available], local allocation
> +	    will attempt to allocate pages from "nearby" nodes, using a per node
> +	    list of nodes--called zonelists--built at boot time.
> +
> +		TODO:  address runtime rebuild of node/zonelists when
> +		supported.
> +
> +	    When a task/process policy contains the Default mode, it means
> +	    "fall back to the system default mode".  And, as discussed above,
> +	    this means use "local" allocation.
> +
> +	    In the context of a VMA, Default mode means "fall back to task
> +	    policy"--which may, itself, fall back to system default policy.
> +	    In the context of shared policies, Default mode means fall back
> +	    directly to the system default policy.  Note:  the result of this
> +	    semantic is that if the task policy is something other than Default,
> +	    it is not possible to specify local allocation for a region of the
> +	    task's address space using a VMA policy.
> +
> +	    The Default mode does not use the optional set of nodes.
> +
> +	MPOL_BIND:  This mode specifies that memory must come from the
> +	set of nodes specified by the policy.  The kernel builds a custom
> +	zonelist containing just the nodes specified by the Bind policy.
> +	If the kernel is unable to allocate a page from the first node in the
> +	custom zonelist, it moves on to the next, and so forth.  If it is unable
> +	to allocate a page from any of the nodes in this list, the allocation
> +	will fail.
> +
> +	    The memory policy APIs do not specify an order in which the nodes
> +	    will be searched.  However, unlike the per node zonelists mentioned
> +	    above, the custom zonelist for the Bind policy do not consider the
> +	    distance between the nodes.  Rather, the lists are built in order
> +	    of numeric node id.
> +
> +
> +	MPOL_PREFERRED:  This mode specifies that the allocation should be
> +	attempted from the single node specified in the policy.  If that
> +	allocation fails, the kernel will search other nodes, exactly as
> +	it would for a local allocation that started at the preferred node--
> +	that is, using the per-node zonelists in increasing distance from
> +	the preferred node.
> +
> +	    If the Preferred policy specifies more than one node, the node
> +	    with the numerically lowest node id will be selected to start
> +	    the allocation scan.
> +
> +	MPOL_INTERLEAVED:  This mode specifies that page allocations be
> +	interleaved, on a page granularity, across the nodes specified in
> +	the policy.  This mode also behaves slightly differently, based on
> +	the context where it is used:
> +
> +	    For allocation of anonymous pages and shared memory pages,
> +	    Interleave mode indexes the set of nodes specified by the policy
> +	    using the page offset of the faulting address into the segment
> +	    [VMA] containing the address modulo the number of nodes specified
> +	    by the policy.  It then attempts to allocate a page, starting at
> +	    the selected node, as if the node had been specified by a Preferred
> +	    policy or had been selected by a local allocation.  That is,
> +	    allocation will follow the per node zonelist.
> +
> +	    For allocation of page cache pages, Interleave mode indexes the set
> +	    of nodes specified by the policy using a node counter maintained
> +	    per task.  This counter wraps around to the lowest specified node
> +	    after it reaches the highest specified node.  This will tend to
> +	    spread the pages out over the nodes specified by the policy based
> +	    on the order in which they are allocated, rather than based on any
> +	    page offset into an address range or file.
> +
> +MEMORY POLICY APIs
> +
> +Linux supports 3 system calls for controlling memory policy.  These APIS
> +always affect only the calling task, the calling task's address space, or
> +some shared object mapped into the calling task's address space.
> +
> +	Note:  the headers that define these APIs and the parameter data types
> +	for user space applications reside in a package that is not part of
> +	the Linux kernel.  The kernel system call interfaces, with the 'sys_'
> +	prefix, are defined in <linux/syscalls.h>; the mode and flag
> +	definitions are defined in <linux/mempolicy.h>.
> +
> +Set [Task] Memory Policy:
> +
> +	long set_mempolicy(int mode, const unsigned long *nmask,
> +					unsigned long maxnode);
> +
> +	Set's the calling task's "task/process memory policy" to mode
> +	specified by the 'mode' argument and the set of nodes defined
> +	by 'nmask'.  'nmask' points to a bit mask of node ids containing
> +	at least 'maxnode' ids.
> +
> +	If successful, the specified policy will control the allocation
> +	of all pages, by and on behalf of this task and its descendants,
> +	that aren't controlled by a more specific VMA or shared policy.
> +	If the calling task is part of a multi-threaded application, the
> +	task policy of other existing threads are unchanged.
> +
> +Get [Task] Memory Policy or Related Information
> +
> +	long get_mempolicy(int *mode,
> +			   const unsigned long *nmask, unsigned long maxnode,
> +			   void *addr, int flags);
> +
> +	Queries the "task/process memory policy" of the calling task, or
> +	the policy or location of a specified virtual address, depending
> +	on the 'flags' argument.
> +
> +	If 'flags' is 0, get_mempolicy() returns the calling task's policy
> +	as set by set_mempolicy() or inherited from its parent.  The mode
> +	is stored in the location pointed to by the 'mode' argument, if it
> +	is non-NULL.  The associated node mask, if any, is stored in the bit
> +	mask pointed to by a non-NULL 'nmask' argument.  When 'nmask' is
> +	non-NULL, 'maxnode' must specify one greater than the maximum bit
> +	number that can be stored in 'nmask'--i.e., the number of bits.
> +
> +	If 'flags' specifies MPOL_F_ADDR, get_mempolicy() returns similar
> +	policy information that governs the allocation of pages at the
> +	specified 'addr'.  This may be different from the task policy--
> +	i.e., if a VMA or shared policy applies to that address.
> +
> +	'flags' may also contain 'MPOL_F_NODE'.  This flag has been
> +	described in some get_mempolicy() man pages as "not for application
> +	use" and subject to change.  Applications are cautioned against
> +	using it.  However, for completeness and because it is useful for
> +	testing the kernel memory policy support, current behavior is
> +	documented here:
> +
> +	If 'flags' contains MPOL_F_NODE, but not MPOL_F_ADDR, and if
> +	the task policy of the calling task specifies the Intereleave
> +	mode [MPOL_INTERLEAVE], get_mempolicy() will return the next
> +	node on which a page cache page would be allocated by the calling
> +	task, in the location pointed to by a non-NULL 'mode'.
> +
> +	If 'flags' contains MPOL_F_NODE and MPOL_F_ADDR, and 'addr'
> +	contains a valid address in the calling task's address space,
> +	get_mempolicy() will return the node where the page backing that
> +	address resides.  If no page has currently been allocated for
> +	the specified address, a page will be allocated as if the task
> +	had performed a read/load from that address.  The node of the
> +	page allocated will be returned.
> +
> +	    Note:  if the address specifies an anonymous region of the
> +	    task's address space with no page currently allocated, the
> +	    resulting "read access fault" will likely just map the shared
> +	    ZEROPAGE.  It will NOT, for example, allocate a local page in
> +	    the case of default policy [unless the task happens to be
> +	    running on the node containing the ZEROPAGE], nor will it obey
> +	    VMA policy, if any.
> +
> +
> +Install VMA/Shared Policy for a Range of Task's Address Space
> +
> +	long mbind(void *start, unsigned long len, int mode,
> +		   const unsigned long *nmask, unsigned long maxnode,
> +		   unsigned flags);
> +
> +	mbind() applies the policy specified by (mode, nmask, maxnodes) to
> +	the range of the calling task's address space specified by the
> +	'start' and 'len' arguments.  Additional actions may be requested
> +	via the 'flags' argument.
> +
> +	If the address space range covers an anonymous region or a private
> +	mapping of a regular file, a VMA policy will be installed in this
> +	region.  This policy will govern all subsequent allocations of pages
> +	for that range for all threads in the task.
> +
> +	    For the case of a private mapping of a regular file, the
> +	    specified policy will only govern the allocation of anonymous
> +	    pages created when the task writes/stores to an address in the
> +	    range.  Pages allocated for read faults will use the faulting
> +	    task's task policy, if any, else the system default.
> +
> +	If the address space range maps a shared object, such as a shared
> +	memory segment, a shared policy will be installed on the specified
> +	range of the underlying shared object.  This policy will govern all
> +	subsequent allocates of pages for that range of the shared object,
> +	for all task that map/attach the shared object.
> +
> +	If the address space range maps a shared hugetlbfs segment, a VMA
> +	policy will be installed for that range.  This policy will govern
> +	subsequent huge page allocations from the calling task, but will
> +	be ignored by any subsequent huge page allocations from other tasks
> +	that attach to the hugetlb shared memory object.
> +
> +	If the address space range covers a shared mapping of a regular
> +	file, a VMA policy will be installed for that range.  This policy
> +	will be ignored for all page allocations by the calling task or
> +	by any other task.  Rather, all page allocations in that range will
> +	be allocated using the faulting task's task policy, if any, else
> +	the system default policy.
> +
> +	Before 2.6.16, Linux did not support page migration.  Therefore,
> +	if any pages were already allocated in the range specified by the
> +	mbind() call, the application was stuck with their existing location.
> +	However, mbind() did, and still does, support the MPOL_MF_STRICT flag.
> +	This flag causes mbind() to check the specified range for any
> +	existing pages that don't obey the specified policy.  If any such
> +	pages exist, the mbind() call fails with the EIO error number.
> +
> +	Since 2.6.16, Linux supports direct [synchronous] page migration
> +	via the mbind() system call.  When the 'flags' argument specifies
> +	MPOL_MF_MOVE, mbind() will attempt to migrate all existing pages
> +	in the range to match the specified policy.  However, the MPOL_MF_MOVE
> +	flag will migrate only those pages that are only referenced by the
> +	calling task's page tables [internally:  page's mapcount == 1].  The
> +	MPOL_MF_STRICT flag may be specified to detect whether any pages
> +	could not be migrated for this or other reasons.
> +
> +	A privileged task [with CAP_SYS_NICE] may specify the MPOL_MF_MOVE_ALL
> +	flag.  With this flag, mbind() will attempt to migrate pages in the
> +	range to match the specified policy, regardless of the number of page
> +	table entries referencing the page [regardless of mapcount].  Again,
> +	some conditions may still prevent pages from being migrated, and the
> +	MPOL_MF_STRICT flag may be specified to detect this condition.
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
