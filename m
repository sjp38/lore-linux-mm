Subject: Re: Some thoughts on memory policies
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706181257010.13154@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0706181257010.13154@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 19 Jun 2007 16:24:49 -0400
Message-Id: <1182284690.5055.128.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, wli@holomorphy.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-06-18 at 13:22 -0700, Christoph Lameter wrote:
> I think we are getting into more and more of a mess with the existing 
> memory policies. The refcount issue with shmem is just one bad symptom of 
> it. Memory policies were intended to be process based and 
> taking them out of that context causes various issues.

I don't think memory policies are in as much of a mess as Christoph
seems to.  Perhaps this is my ignorance showing.  Certainly, there are
issues to be addressed--especially in the interaction of memory policies
with containers, such as cpusets.  The shmem refcount issue may be one
of these issues--not sure how "bad" it is.  

I agree that the "process memory policy"--i.e., the one set by
set_mempolicy()--is "process based", but I don't see the system default
policy as process based.  The system default policy is, currently, the
policy of last resort for any allocation.  And, [as I've discussed with
Christoph], I view policies applied via mbind() as applying to [some
range of] the "memory object" mapped at a specific address range.  I
admit that this view is somewhat muddied by the fact that [private]
anonymous segments don't actually have any actual kernel structure to
represent them outside of a process's various anonymous VMAs and page
table [and sometimes the swap cache]; and by the fact that the kernel
currently ignores policy that one attempts to place on shared regular
file mappings.  However, I think "object-based policy" is a natural
extension of the current API and easily implemented with the current
infrastructure.  

> 
> I have thought for a long time that we need something to replace memory 
> policies especially since the requirements on memory policies go far 
> beyond just being process based. So some requirements and ideas about 
> memory policies.

Listing the requirements is a great idea.  But I won't go so far as to
agree that we need to "replace memory policies" so much as rationalize
them for all the desired uses/contexts...

> 
> 1. Memory policies must be attachable to a variety of objects
> 
> - Device drivers may need to control memory allocations in
>   devices either because their DMA engines can only reach a
>   subsection of the system or because memory transfer
>   performance is superior in certain nodes of the system.
> 
> - Process. This is the classic usage scenario
> 
> - File / Socket. One may have particular reasons to place
>   objects on a set of nodes because of how the threads of
>   an application are spread out in the system.

...how the tasks/threads are spread out and how the application accesses
the pages of the objects.  Some accesses--e.g., unmapped pages of
files--are implicit or transparent to task.  I guess any pages
associated with a socket would also be transparent to the application as
well?

> 
> - Cpuset / Container. Some simple support is there with
>   memory spreading today. That could be made more universal.

I've said before that I viewed cpusets as administrative contraints on
applications, where as policies are something that can be controlled by
the application or a non-privileged user.  As cpusets evolve into more
general "containers", I think they'll become less visible to the
applications running within them.  The application will see the
container as "the system"--at least, the set of system resources to
which the application has access.  

The current memory policy APIs can work in such a "containerized"
environment if we can reconcile the policy APIs' notion of nodes with
the set of nodes that container allows.  Perhaps we need to revisit the
"cpumemset" proposal that provides a separate node id namespace in each
container/cpuset.  As a minimum, I think a task should be able to query
the set of nodes that it can use and/or have the system "do the right
thing" if the application specifies "all possible nodes" for, say, and
interleave policy.

> 
> - System policies. The system policy is currently not
>   modifiable. It may be useful to be able to set this.
>   Small NUMA systems may want to run with interleave by default 

Agreed.  And, on our platforms, it would be useful to have a separately
specifiable system-wide [or container-wide] default page cache policy.

> 
> - Address range. For the virtual memory address range
>   this is included in todays functionality but one may also
>   want to control the physical address range to make sure
>   f.e. that memory is allocated in an area where a device
>   can reach it.

For application usage?  Does this mean something like an MPOL_MF_DMA
flag?  

One way to handle this w/o an explicit 'DMA flag for use space APIs is
to mmap() the device that would use the memory and allow the device
driver to allocate the memory internally with the appropriate DMA/32
flags and map that memory into the task's address space.  I think that
works today.

What other usage scenarios are you thinking of?

> 
> - Memory policies need to be attachable to types of pages.
>   F.e. executable pages of a threaded application are best
>   spread (or replicated) whereas the stack and the data may
>   best be allocated in a node local way.
>   Useful categories that I can think of
>   Stack, Data, Filebacked pages, Anonymous Memory,
>   Shared memory, Page tables, Slabs, Mlocked pages and
>   huge pages.

Rather, I would say, to "types of objects".   I think all of the "types
of pages" you mention [except, maybe, mlocked?] can be correlated to
some structure/object to which policy can be attached.  Regarding
"Mlocked pages"--are you suggesting that you might want to specify that
mlocked pages have a different policy/locality than other pages in the
same object?

Stack and data/heap can easily be handled by always defaulting the
process policy to node local [or perhaps interleaved across the nodes in
the container, if node local results in hot spots or other problems],
and explicitly binding other objects of interest, if performance
considerations warrant, using the mbind() API or by using fixed or
heuristic defaults.

> 
>   Maybe a set of global policies would be useful for these
>   categories. Andy hacked subsystem memory policies into
>   shmem and it seems that we are now trying to do the same
>   for hugepages. Maybe we could get to a consistent scheme
>   here?

Christoph, I wish you wouldn't characterize Andi's shared policy
infrastructure as a hack.  I think it provides an excellent base
implementation for [shared] object-based policies.  It extends easily to
any object that can be addressed by offset [page offset, hugepage
offset, ...].  The main issue is the generic one of memory policy on
object that can be shared by processes running in separate cpusets,
whether the sharing is intentional or not.  

> 
> 2. Memory policies need to support additional constraints
> 
> - Restriction to a set of nodes. That is what we have today.

See "locality placement" below.

> 
> - Restriction to a container or cpuset. Maybe restriction
>   to a set of containers?

I don't know about a "set of containers", but perhaps you are referring
to sharing of objects between applications running in different
containers with potentially disjoint memory resources?  That is
problematic.  We need to enumerate the use cases for this and what the
desired behavior should be.

Christoph and I discussed one scenario:  backup running in a separate
cpuset, disjoint from an application that mmap()s a file shared and
installs a shared policy on it [my "mapped file policy" patches would
enable this].  If the application's cpuset contains sufficient memory
for the application's working set, but NOT enough to hold the entire
file, the backup running in another cpuset reading the entire file may
push out pages of the application from it's cpuset because the object
policy constrains the pages to be located in the application's cpuset.  

> 
> - Strict vs no strict allocations. A strict allocation needs
>   to fail if the constraints cannot be met. A non strict
>   allocation can fall back.

Agreed.  And I think this needs to be explicit in the allocation
request.  Callers requesting strict allocation [including "no wait"]
should be prepared to handle failure of the allocation.

> 
> - Order of allocation. Higher order pages may require
>   different allocation constraints? This is like a
>   generalization of huge page policies.

Agreed.  On our platform, I'd like to keep default huge page allocations
and interleave requests off the "hardware interleaved pseudo-node" as
that is "special" memory.  I'd like to reserve it for access only by
explicit request.  The current model doesn't support this, but I think
it could, with a few "small" enhancements. [TODO]

> 
> - Locality placement. These are node local, interleave etc.

How is this different from "restriction to a set of nodes" in the
context of memory policies [1st bullet in section 2]?  I tend to think
of memory policies--whether default or explicit--as "locality placement"
and cpusets as "constraints" or restrictions on what policies can do.

> 
> 3. Additional flags
> 
> - Automigrate flag so that memory touched by a process
>   is moved to a memory location that has best performance.

Automigration can be turned on/off in the environment--e.g., per
container/cpuset, but perhaps there is a use case for more explicit
control over automigration of specific pages of an object?

"Lazy migration" or "migrate on fault" is fairly easy to achieve atop
the existing migration infrastructure.  However, it requires a fault to
trigger the migration.  One can arrange for these faults to occur
explicitly--e.g., via a straightforward extension to mbind() with
MPOL_MF_MOVE and a new MPOL_MF_LAZY flag to remove the page translations
from all page tables resulting in a fault, and possible migration, on
next touch.  Or, one can arrange to automatically "unmap" [remove ptes
referencing] selected types of pages when the load balancer moves a task
to a new node.

I've seen fairly dramatic reductions in real, user and system time in,
e.g., kernel builds on a heavily loaded [STREAMS benchmark running] NUMA
platform with automatic/lazy migration patches:   ~14% real, ~4.7% user
and ~22% system time reductions.

> 
> - Page order flag that determines the preferred allocation
>   order. Maybe useful in connection with the large blocksize
>   patch to control anonymous memory orders.

Agreed.  "requested page order" could be a component of policy, along
with locality.

> 
> - Replicate flags so that memory is replicated.

This could be a different policy mode, MPOL_REPLICATE.  Or, as with
Nick's prototype, it could be the default behavior for read-only access
to page cache pages when no explicit policy exists on the object [file].

For "automatic, lazy replication, one would also need a fault to trigger
the replication.  This could be achieved by removing the pte from only
the calling task's page table via mbind(MOVE+LAZY) or automatically on
inter-node task migration.  The resulting fault, when that corresponding
virtual address is touched, would cause Nick's page cache replication
infrastructure to create/use a local copy of the page.  It's "on my
list" ...
> 
> 4. Policy combinations
> 
> We need some way to combine policies in a systematic way. The current
> hieracy from System->cpuset->proces->memory range does not longer
> work if a process can use policies set up in shmem or huge pages.
> Some consistent scheme to combine memory policies would also need
> to be able to synthesize different policies. I.e. automigrate
> can be combined with node local or interleave and a cpuset constraint.

The big issue, here, for me, is the interaction of policy on shared
objects [shmem and shared regular file mappings] referenced from
different containers/cpusets.   Given that we want to allow this--almost
can't prevent it in the case of regular file access--we need to specify
the use cases, what the desired behavior is for each such case, and
which scenarios to optimize for.

> 
> 5. Management tools
> 
> If we make the policies more versatile then we need the proper
> management tools in user space to set and display these policies
> in such a way that they can be managed by the end user. The esoteric
> nature of memory policy semantics makes them difficult to comprehend.

/proc/<pid>/numa_maps works well [with my patches] for object mapped
into a task's address space.  What it doesn't work so well for are:
1) shared policy on currently unattached shmem segments and 2) shared
policy on unmapped regular files, should my patches be accepted.  [Note,
however, we need not retain shared policy on regular files after the
last shared mapping is removed--my recommended persistence model.]


> 6. GFP_xx flags may actually be considered as a form of policy

Agreed.  For kernel internal allocation requests...

> 
> i.e. GFP_THISNODE is essentially a one node cpuset.

sort of behaves like one, I agree.  Or like an explicit MPOL_BIND with a
single node.

> 
> GFP_DMA and GFP_DMA32 are physical address range constraints.

with platform specific locality implications...

> 
> GFP_HARDWALL is a strict vs. nonstrict distinction.
> 
> 
> 7. Allocators must change
> 
> Right now the policy is set by the process context which is bad because
> one cannot specify a memory policy for an allocation. It must be possible
> to pass a memory policy to the allocators and then get the memory 
> requested.

Agreed.  In my shared/mapped file policy patches, I have factored an
"allocate_page_pol() function out of alloc_page_vma().  The modified
alloc_page_vma() calls get_vma_policy() [as does the current version] to
obtain the policy at the specified address in the calling task's virtual
address space or some default policy, and then calls alloc_page_pol() to
allocate a page based on that policy.  I can then use the same
alloc_page_pol() function to allocate page cache pages after looking up
a shared policy on a mapped file or using the default policy for page
cache allocations [currently process->system default].  Perhaps other of
the page allocators could use alloc_page_pol() as well?

> 
> 
> I wish we could come up with some universal scheme that encompasses all
> of the functionality we want and that makes memory more manageable....

I think it's possible and that the current mempolicy support can be
evolved with not too much effort.  Again, the biggest issue for me is
the reconciliation of the policies with the administrative constraints
imposed by subsetting the system via containers/cpusets--especially for
objects that can be referenced from more than one container.  I think
that any reasonable, let alone "correct", solution would be
workload/application dependent.


Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
