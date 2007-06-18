Date: Mon, 18 Jun 2007 13:22:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Some thoughts on memory policies
Message-ID: <Pine.LNX.4.64.0706181257010.13154@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, wli@holomorphy.com, lee.schermerhorn@hp.com
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I think we are getting into more and more of a mess with the existing 
memory policies. The refcount issue with shmem is just one bad symptom of 
it. Memory policies were intended to be process based and 
taking them out of that context causes various issues.

I have thought for a long time that we need something to replace memory 
policies especially since the requirements on memory policies go far 
beyond just being process based. So some requirements and ideas about 
memory policies.

1. Memory policies must be attachable to a variety of objects

- Device drivers may need to control memory allocations in
  devices either because their DMA engines can only reach a
  subsection of the system or because memory transfer
  performance is superior in certain nodes of the system.

- Process. This is the classic usage scenario

- File / Socket. One may have particular reasons to place
  objects on a set of nodes because of how the threads of
  an application are spread out in the system.

- Cpuset / Container. Some simple support is there with
  memory spreading today. That could be made more universal.

- System policies. The system policy is currently not
  modifiable. It may be useful to be able to set this.
  Small NUMA systems may want to run with interleave by default 

- Address range. For the virtual memory address range
  this is included in todays functionality but one may also
  want to control the physical address range to make sure
  f.e. that memory is allocated in an area where a device
  can reach it.

- Memory policies need to be attachable to types of pages.
  F.e. executable pages of a threaded application are best
  spread (or replicated) whereas the stack and the data may
  best be allocated in a node local way.
  Useful categories that I can think of
  Stack, Data, Filebacked pages, Anonymous Memory,
  Shared memory, Page tables, Slabs, Mlocked pages and
  huge pages.

  Maybe a set of global policies would be useful for these
  categories. Andy hacked subsystem memory policies into
  shmem and it seems that we are now trying to do the same
  for hugepages. Maybe we could get to a consistent scheme
  here?

2. Memory policies need to support additional constraints

- Restriction to a set of nodes. That is what we have today.

- Restriction to a container or cpuset. Maybe restriction
  to a set of containers?

- Strict vs no strict allocations. A strict allocation needs
  to fail if the constraints cannot be met. A non strict
  allocation can fall back.

- Order of allocation. Higher order pages may require
  different allocation constraints? This is like a
  generalization of huge page policies.

- Locality placement. These are node local, interleave etc.

3. Additional flags

- Automigrate flag so that memory touched by a process
  is moved to a memory location that has best performance.

- Page order flag that determines the preferred allocation
  order. Maybe useful in connection with the large blocksize
  patch to control anonymous memory orders.

- Replicate flags so that memory is replicated.

4. Policy combinations

We need some way to combine policies in a systematic way. The current
hieracy from System->cpuset->proces->memory range does not longer
work if a process can use policies set up in shmem or huge pages.
Some consistent scheme to combine memory policies would also need
to be able to synthesize different policies. I.e. automigrate
can be combined with node local or interleave and a cpuset constraint.

5. Management tools

If we make the policies more versatile then we need the proper
management tools in user space to set and display these policies
in such a way that they can be managed by the end user. The esoteric
nature of memory policy semantics makes them difficult to comprehend.

6. GFP_xx flags may actually be considered as a form of policy

i.e. GFP_THISNODE is essentially a one node cpuset.

GFP_DMA and GFP_DMA32 are physical address range constraints.

GFP_HARDWALL is a strict vs. nonstrict distinction.


7. Allocators must change

Right now the policy is set by the process context which is bad because
one cannot specify a memory policy for an allocation. It must be possible
to pass a memory policy to the allocators and then get the memory 
requested.


I wish we could come up with some universal scheme that encompasses all
of the functionality we want and that makes memory more manageable....


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
