Date: Tue, 19 Jun 2007 15:30:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Some thoughts on memory policies
In-Reply-To: <1182284690.5055.128.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706191524080.7633@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0706181257010.13154@schroedinger.engr.sgi.com>
 <1182284690.5055.128.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, wli@holomorphy.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Jun 2007, Lee Schermerhorn wrote:

> > - File / Socket. One may have particular reasons to place
> >   objects on a set of nodes because of how the threads of
> >   an application are spread out in the system.
> 
> ...how the tasks/threads are spread out and how the application accesses
> the pages of the objects.  Some accesses--e.g., unmapped pages of
> files--are implicit or transparent to task.  I guess any pages
> associated with a socket would also be transparent to the application as
> well?

Not sure about the exact semantics that we should have.

> > - Cpuset / Container. Some simple support is there with
> >   memory spreading today. That could be made more universal.
> 
> I've said before that I viewed cpusets as administrative contraints on
> applications, where as policies are something that can be controlled by
> the application or a non-privileged user.  As cpusets evolve into more
> general "containers", I think they'll become less visible to the
> applications running within them.  The application will see the
> container as "the system"--at least, the set of system resources to
> which the application has access.  

An application may want to access memory from various pools of memory that 
may be different containers? The containers can then dynamically sized by 
system administrators.

> The current memory policy APIs can work in such a "containerized"
> environment if we can reconcile the policy APIs' notion of nodes with
> the set of nodes that container allows.  Perhaps we need to revisit the
> "cpumemset" proposal that provides a separate node id namespace in each
> container/cpuset.  As a minimum, I think a task should be able to query

Right.

> the set of nodes that it can use and/or have the system "do the right
> thing" if the application specifies "all possible nodes" for, say, and
> interleave policy.

I agree.

> > - Address range. For the virtual memory address range
> >   this is included in todays functionality but one may also
> >   want to control the physical address range to make sure
> >   f.e. that memory is allocated in an area where a device
> >   can reach it.
> 
> For application usage?  Does this mean something like an MPOL_MF_DMA
> flag?  

Mostly useful for memory policies attached to devices I think.

> > - Memory policies need to be attachable to types of pages.
> >   F.e. executable pages of a threaded application are best
> >   spread (or replicated) whereas the stack and the data may
> >   best be allocated in a node local way.
> >   Useful categories that I can think of
> >   Stack, Data, Filebacked pages, Anonymous Memory,
> >   Shared memory, Page tables, Slabs, Mlocked pages and
> >   huge pages.
> 
> Rather, I would say, to "types of objects".   I think all of the "types
> of pages" you mention [except, maybe, mlocked?] can be correlated to
> some structure/object to which policy can be attached.  Regarding
> "Mlocked pages"--are you suggesting that you might want to specify that
> mlocked pages have a different policy/locality than other pages in the
> same object?

One may not want mlocked pages to contaminate certain nodes?
 
> Christoph, I wish you wouldn't characterize Andi's shared policy
> infrastructure as a hack.  I think it provides an excellent base
> implementation for [shared] object-based policies.  It extends easily to
> any object that can be addressed by offset [page offset, hugepage
> offset, ...].  The main issue is the generic one of memory policy on
> object that can be shared by processes running in separate cpusets,
> whether the sharing is intentional or not.  

The refcount issues and the creation of vmas on the stack do suggest that 
this is not a clean implemenation.

> > 4. Policy combinations
> > 
> > We need some way to combine policies in a systematic way. The current
> > hieracy from System->cpuset->proces->memory range does not longer
> > work if a process can use policies set up in shmem or huge pages.
> > Some consistent scheme to combine memory policies would also need
> > to be able to synthesize different policies. I.e. automigrate
> > can be combined with node local or interleave and a cpuset constraint.
> 
> The big issue, here, for me, is the interaction of policy on shared
> objects [shmem and shared regular file mappings] referenced from
> different containers/cpusets.   Given that we want to allow this--almost
> can't prevent it in the case of regular file access--we need to specify
> the use cases, what the desired behavior is for each such case, and
> which scenarios to optimize for.

Right and we need some form of permissions management for policies.

> > 7. Allocators must change
> > 
> > Right now the policy is set by the process context which is bad because
> > one cannot specify a memory policy for an allocation. It must be possible
> > to pass a memory policy to the allocators and then get the memory 
> > requested.
> 
> Agreed.  In my shared/mapped file policy patches, I have factored an
> "allocate_page_pol() function out of alloc_page_vma().  The modified
> alloc_page_vma() calls get_vma_policy() [as does the current version] to
> obtain the policy at the specified address in the calling task's virtual
> address space or some default policy, and then calls alloc_page_pol() to
> allocate a page based on that policy.  I can then use the same
> alloc_page_pol() function to allocate page cache pages after looking up
> a shared policy on a mapped file or using the default policy for page
> cache allocations [currently process->system default].  Perhaps other of
> the page allocators could use alloc_page_pol() as well?

Think about how the slab allocators, uncached allocator and vmalloc could 
support policies. Somehow this needs to work in a consistent way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
