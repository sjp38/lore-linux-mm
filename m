Subject: [PATCH] Document Linux Memory Policy - V2
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0707271026040.15990@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
	 <20070725111646.GA9098@skynet.ie>
	 <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
	 <20070726132336.GA18825@skynet.ie>
	 <Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com>
	 <20070726225920.GA10225@skynet.ie>
	 <Pine.LNX.4.64.0707261819530.18210@schroedinger.engr.sgi.com>
	 <20070727082046.GA6301@skynet.ie> <20070727154519.GA21614@skynet.ie>
	 <Pine.LNX.4.64.0707271026040.15990@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 27 Jul 2007 14:00:59 -0400
Message-Id: <1185559260.5069.40.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <clameter@sgi.com>, ak@suse.de, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com, Michael Kerrisk <mtk-manpages@gmx.net>, Randy Dunlap <randy.dunlap@oracle.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Here's a second attempt to document the existing Linux Memory Policy.
I've tried to address comments on the first cut from Christoph and Andi.
I've removed the details of the APIs and referenced the man pages "for
more details".  I've made a stab at addressing the interaction with
cpusets, but more could be done here.

I'm hoping we can get this merged in some form, and then update it with
all of the policy changes that are in the queue and/or being
worked--memoryless nodes, interaction with ZONE_MOVABLE, ... .

Lee

----------------

[PATCH] Document Linux Memory Policy - V2

I couldn't find any memory policy documentation in the Documentation
directory, so here is my attempt to document it.

There's lots more that could be written about the internal design--including
data structures, functions, etc.  However, if you agree that this is better
that the nothing that exists now, perhaps it could be merged.  This will
provide a baseline for updates to document the many policy patches that are
currently being worked.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/vm/memory_policy.txt |  278 +++++++++++++++++++++++++++++++++++++
 1 file changed, 278 insertions(+)

Index: Linux/Documentation/vm/memory_policy.txt
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ Linux/Documentation/vm/memory_policy.txt	2007-07-27 13:40:45.000000000 -0400
@@ -0,0 +1,278 @@
+
+What is Linux Memory Policy?
+
+In the Linux kernel, "memory policy" determines from which node the kernel will
+allocate memory in a NUMA system or in an emulated NUMA system.  Linux has
+supported platforms with Non-Uniform Memory Access architectures since 2.4.?.
+The current memory policy support was added to Linux 2.6 around May 2004.  This
+document attempts to describe the concepts and APIs of the 2.6 memory policy
+support.
+
+See also Documentation/cpusets.txt which describes a higher level,
+administrative mechanism for restricting the set of nodes from which memory
+policy may allocate pages.  Also, see "MEMORY POLICIES AND CPUSETS" below.
+
+MEMORY POLICY CONCEPTS
+
+Scope of Memory Policies
+
+The Linux kernel supports four more or less distinct scopes of memory policy:
+
+    System Default Policy:  this policy is "hard coded" into the kernel.  It
+    is the policy that governs the all page allocations that aren't controlled
+    by one of the more specific policy scopes discussed below.
+
+    Task/Process Policy:  this is an optional, per-task policy.  When defined
+    for a specific task, this policy controls all page allocations made by or
+    on behalf of the task that aren't controlled by a more specific scope.
+    If a task does not define a task policy, then all page allocations that
+    would have been controlled by the task policy "fall back" to the System
+    Default Policy.
+
+	Because task policy applies to the entire address space of a task,
+	it is inheritable across both fork() [clone() w/o the CLONE_VM flag]
+	and exec*().  Thus, a parent task may establish the task policy for
+	a child task exec()'d from an executable image that has no awareness
+	of memory policy.
+
+	In a multi-threaded task, task policies apply only to the thread
+	[Linux kernel task] that installs the policy and any threads
+	subsequently created by that thread.  Any sibling threads existing
+	at the time a new task policy is installed retain their current
+	policy.
+
+	A task policy applies only to pages allocated after the policy is
+	installed.  Any pages already faulted in by the task remain where
+	they were allocated based on the policy at the time they were
+	allocated.
+
+    VMA Policy:  A "VMA" or "Virtual Memory Area" refers to a range of a task's
+    virtual adddress space.  A task may define a specific policy for a range
+    of its virtual address space.  This VMA policy will govern the allocation
+    of pages that back this region of the address space.  Any regions of the
+    task's address space that don't have an explicit VMA policy will fall back
+    to the task policy, which may itself fall back to the system default policy.
+
+	VMA policy applies ONLY to anonymous pages.  These include pages
+	allocated for anonymous segments, such as the task stack and heap, and
+	any regions of the address space mmap()ed with the MAP_ANONYMOUS flag.
+	Anonymous pages copied from private file mappings [files mmap()ed with
+	the MAP_PRIVATE flag] also obey VMA policy, if defined.
+
+	VMA policies are shared between all tasks that share a virtual address
+	space--a.k.a. threads--independent of when the policy is installed; and
+	they are inherited across fork().  However, because VMA policies refer
+	to a specific region of a task's address space, and because the address
+	space is discarded and recreated on exec*(), VMA policies are NOT
+	inheritable across exec().  Thus, only NUMA-aware applications may
+	use VMA policies.
+
+	A task may install a new VMA policy on a sub-range of a previously
+	mmap()ed region.  When this happens, Linux splits the existing virtual
+	memory area into 2 or 3 VMAs, each with it's own policy.
+
+	By default, VMA policy applies only to pages allocated after the policy
+	is installed.  Any pages already faulted into the VMA range remain where
+	they were allocated based on the policy at the time they were
+	allocated.  However, since 2.6.16, Linux supports page migration so
+	that page contents can be moved to match a newly installed policy.
+
+    Shared Policy:  This policy applies to "memory objects" mapped shared into
+    one or more tasks' distinct address spaces.  Shared policies are applied
+    directly to the shared object.  Thus, all tasks that attach to the object
+    share the policy, and all pages allocated for the shared object, by any
+    task, will obey the shared policy.
+
+	Currently [2.6.22], only shared memory segments, created by shmget(),
+	support shared policy.  When shared policy support was added to Linux,
+	the associated data structures were added to shared hugetlbfs segments.
+	However, at the time, hugetlbfs did not support allocation at fault
+	time--a.k.a lazy allocation--so hugetlbfs segments were never "hooked
+	up" to the shared policy support.  Although hugetlbfs segments now
+	support lazy allocation, their support for shared policy has not been
+	completed.
+
+	Although internal to the kernel shared memory segments are really
+	files backed by swap space that have been mmap()ed shared into tasks'
+	address spaces, regular files mmap()ed shared do NOT support shared
+	policy.  Rather, shared page cache pages, including pages backing
+	private mappings that have not yet been written by the task, follow
+	task policy, if any, else system default policy.
+
+	The shared policy infrastructure supports different policies on subset
+	ranges of the shared object.  However, Linux still splits the VMA of
+	the task that installs the policy for each range of distinct policy.
+	Thus, different tasks that attach to a shared memory segment can have
+	different VMA configurations mapping that one shared object.
+
+Components of Memory Policies
+
+    A Linux memory policy is a tuple consisting of a "mode" and an optional set
+    of nodes.  The mode determine the behavior of the policy, while the optional
+    set of nodes can be viewed as the arguments to the behavior.
+
+   Internally, memory policies are implemented by a reference counted structure,
+   struct mempolicy.  Details of this structure will be discussed in context,
+   below.
+
+	Note:  in some functions AND in the struct mempolicy, the mode is
+	called "policy".  However, to avoid confusion with the policy tuple,
+	this document will continue to use the term "mode".
+
+   Linux memory policy supports the following 4 modes:
+
+	Default Mode--MPOL_DEFAULT:  The behavior specified by this mode is
+	context dependent.
+
+	    During normal system operation, the system default policy is hard
+	    coded to contain the Default mode.  During system boot up, the
+	    system default policy is temporarily set to MPOL_INTERLEAVE [see
+	    below] to distribute boot time allocations across all nodes in
+	    the system, instead of using just the node containing the boot cpu.
+
+	    In this context, default mode means "local" allocation--that is
+	    attempt to allocate the page from the node associated with the cpu
+	    where the fault occurs.  If the "local" node has no memory, or the
+	    node's memory can be exhausted [no free pages available], local
+	    allocation will attempt to allocate pages from "nearby" nodes, using
+	    a per node list of nodes--called zonelists--built at boot time, or
+	    when nodes or memory are added or removed from the system [memory
+	    hotplug].
+
+	    When a task/process policy or a shared policy contains the Default
+	    mode, this also means local allocation, as described above.
+
+	    In the context of a VMA, Default mode means "fall back to task
+	    policy"--which may or may not specify Default mode.  Thus, Default
+	    mode can not be counted on to mean local allocation when used
+	    on a non-shared region of the address space.  However, see
+	    MPOL_PREFERRED below.
+
+	    The Default mode does not use the optional set of nodes.
+
+	MPOL_BIND:  This mode specifies that memory must come from the
+	set of nodes specified by the policy.  The kernel builds a custom
+	zonelist pointed to by the zonelist member of struct mempolicy,
+	containing just the nodes specified by the Bind policy.  If the kernel
+	is unable to allocate a page from the first node in the custom zonelist,
+	it moves on to the next, and so forth.  If it is unable to allocate a
+	page from any of the nodes in this list, the allocation will fail.
+
+	    The memory policy APIs do not specify an order in which the nodes
+	    will be searched.  However, unlike the per node zonelists mentioned
+	    above, the custom zonelist for the Bind policy do not consider the
+	    distance between the nodes.  Rather, the lists are built in order
+	    of numeric node id.
+
+	MPOL_PREFERRED:  This mode specifies that the allocation should be
+	attempted from the single node specified in the policy.  If that
+	allocation fails, the kernel will search other nodes, exactly as
+	it would for a local allocation that started at the preferred node--
+	that is, using the per-node zonelists in increasing distance from
+	the preferred node.
+
+	    Internally, the Preferred policy uses a single node--the
+	    preferred_node member of struct mempolicy.
+
+	    If the Preferred policy node is '-1', then at page allocation time,
+	    the kernel will use the "local node" as the starting point for the
+	    allocation.  This is the way to specify local allocation for a
+	    specific range of addresses--i.e. for VMA policies.
+
+	MPOL_INTERLEAVED:  This mode specifies that page allocations be
+	interleaved, on a page granularity, across the nodes specified in
+	the policy.  This mode also behaves slightly differently, based on
+	the context where it is used:
+
+	    For allocation of anonymous pages and shared memory pages,
+	    Interleave mode indexes the set of nodes specified by the policy
+	    using the page offset of the faulting address into the segment
+	    [VMA] containing the address modulo the number of nodes specified
+	    by the policy.  It then attempts to allocate a page, starting at
+	    the selected node, as if the node had been specified by a Preferred
+	    policy or had been selected by a local allocation.  That is,
+	    allocation will follow the per node zonelist.
+
+	    For allocation of page cache pages, Interleave mode indexes the set
+	    of nodes specified by the policy using a node counter maintained
+	    per task.  This counter wraps around to the lowest specified node
+	    after it reaches the highest specified node.  This will tend to
+	    spread the pages out over the nodes specified by the policy based
+	    on the order in which they are allocated, rather than based on any
+	    page offset into an address range or file.  During system boot up,
+	    the temporary interleaved system default policy works in this
+	    mode.
+
+MEMORY POLICIES AND CPUSETS
+
+Memory policies work within cpusets as described above.  For memory policies
+that require a node or set of nodes, the nodes are restricted to the set of
+nodes whose memories are allowed by the cpuset constraints.  This can be
+problematic for 2 reasons:
+
+1) the memory policy APIs take physical node id's as arguments.  However, the
+   memory policy APIs do not provide a way to determine what nodes are valid
+   in the context where the application is running.  An application MAY consult
+   the cpuset file system [directly or via an out of tree, and not generally
+   available, libcpuset API] to obtain this information, but then the
+   application must be aware that it is running in a cpuset and use what are
+   intended primarily as administrative APIs.
+
+2) when tasks in two cpusets share access to a memory region, such as shared
+   memory segments created by shmget() of mmap() with the MAP_ANONYMOUS and
+   MAP_SHARED flags, only nodes whose memories are allowed in both cpusets
+   may be used in the policies.  Again, obtaining this information requires
+   "stepping outside" the memory policy APIs to use the cpuset information.
+   Furthermore, if the cpusets' "allowed memory" sets are disjoint, "local"
+   allocation is the only valid policy.
+
+MEMORY POLICY APIs
+
+Linux supports 3 system calls for controlling memory policy.  These APIS
+always affect only the calling task, the calling task's address space, or
+some shared object mapped into the calling task's address space.
+
+	Note:  the headers that define these APIs and the parameter data types
+	for user space applications reside in a package that is not part of
+	the Linux kernel.  The kernel system call interfaces, with the 'sys_'
+	prefix, are defined in <linux/syscalls.h>; the mode and flag
+	definitions are defined in <linux/mempolicy.h>.
+
+Set [Task] Memory Policy:
+
+	long set_mempolicy(int mode, const unsigned long *nmask,
+					unsigned long maxnode);
+
+	Set's the calling task's "task/process memory policy" to mode
+	specified by the 'mode' argument and the set of nodes defined
+	by 'nmask'.  'nmask' points to a bit mask of node ids containing
+	at least 'maxnode' ids.
+
+	See the set_mempolicy(2) man page for more details
+
+
+Get [Task] Memory Policy or Related Information
+
+	long get_mempolicy(int *mode,
+			   const unsigned long *nmask, unsigned long maxnode,
+			   void *addr, int flags);
+
+	Queries the "task/process memory policy" of the calling task, or
+	the policy or location of a specified virtual address, depending
+	on the 'flags' argument.
+
+	See the get_mempolicy(2) man page for more details
+
+
+Install VMA/Shared Policy for a Range of Task's Address Space
+
+	long mbind(void *start, unsigned long len, int mode,
+		   const unsigned long *nmask, unsigned long maxnode,
+		   unsigned flags);
+
+	mbind() installs the policy specified by (mode, nmask, maxnodes) as
+	a VMA policy for the range of the calling task's address space
+	specified by the 'start' and 'len' arguments.  Additional actions
+	may be requested via the 'flags' argument.
+
+	See the mbind(2) man page for more details.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
