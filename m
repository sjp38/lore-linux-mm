Subject: Re: [NUMA] Fix memory policy refcounting
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0710291438470.3475@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0710261638020.29369@schroedinger.engr.sgi.com>
	 <1193672929.5035.69.camel@localhost>
	 <Pine.LNX.4.64.0710291317060.1379@schroedinger.engr.sgi.com>
	 <1193693646.6244.51.camel@localhost>
	 <Pine.LNX.4.64.0710291438470.3475@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 30 Oct 2007 12:39:42 -0400
Message-Id: <1193762382.5039.41.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Rientjes <rientjes@google.com>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-10-29 at 14:43 -0700, Christoph Lameter wrote:
> On Mon, 29 Oct 2007, Lee Schermerhorn wrote:
> 
> > > > Yeah, yeah, yeah.  But I consider that to be cpusets' fault and not
> > > > shared memory policy.  I still have use for the latter.  We need to find
> > > > a way to accomodate all of our requirements, even if it means
> > > > documenting that shared memory policy must be used very carefully with
> > > > cpusets--or not at all with dynamically changing cpusets.  I can
> > > > certainly live with that.
> > > 
> > > There is no reason that this issue should exist. We can have your shared 
> > > policies with proper enforcement that no bad things happen if we get rid 
> > > of get_policy etc and instead use the vma policy pointer to point to the 
> > > shared policy. Take a refcount for each vma as it is setup to point to a 
> > > shared policy and you will not have to take the refcount in the hot paths.
> > 
> > We support different policies on different ranges of a shared memory
> > segment.  In the task which installs this policy, we split the vmas, but
> > any other tasks which already have the segment attached or which
> > subsequently attach don't split the vmas along policy bondaries.  This
> > also makes numa_maps lie when we have multiple subrange policies.
> 
> Which would also be fixed if we would split the vmas properly.

The problem I see with splitting vmas for shared policy is that, to be
correct, when you apply a sub-range policy to a shm segment that already
has tasks attached, you'd have to split those task's vmas as
well--either from outside the tasks, or somehow notify them to do it
themselves.  In general, I really want to avoid requiring every process
in a multi-task application to install policies on shared objects
uniformly to get correct behavior.  However, something you said
yesterday [about vma pointers to shared policies] got me thinking last
evening of another approach.  Here's an idea.

First, the situation we have today:

task1 creates [shmget()] and attaches [shmat()] a shm segment.  W/o
SHM_HUGETLB flag, we get a tmpfs mapping with shmem vm_ops.  These
vm_ops support shared mempolicy that maintains ranges of mempolicy in an
rbtree.  After task1 installs [mbind()] two mempolicies on subset ranges
of the shm segment, we get the vma connections shown below on the left
[vma1.[12]] in Figure 1 [please forgive the lame ascii art].  The
reference count of 1 on the mempolicies represents the reference held by
the shared policy rbtree itself.  The horizontal "arrows" do NOT
represent actual pointers.  Rather they represent the association
between the vm_start of the vma and the offset of the start of the
policy range.  The vertical "arrows" represent the length of the range
of virtual addresses mapped by each vma.  The original vma was split in
two when the mempolicies were installed.

Now task2 attaches [shmat] the segment, without installing any policy.
[NUMA layout and mempolicy installation is the responsibility of task1
in this mythical multi-task application.]  Because task2 attaches
[do_mmap*() internally] the entire segment--unlike mmap(), shmat() has
no provision to attach a subset of the segment--it gets a single vma
mapping the entire segment.   We get the vma connection shown on the
right in Figure 1.  [We'd get this same configuration if task2 were
already attached when task1 installs the policies.] Again, the vertical
arrow represents the range of virtual addresses mapped by the single
vma.  The attach does not increment the reference count.


                                    Figure 1

        task1,                   Shared Policy               task2,
      mm_struct1,                (w/ rb tree)              mm_struct2,
                              -------------------
       vma1.1---------------->|                 |<------------vma2.1
                            | |  mode, nodemask,| |
                            | |     ref = 1     | |
                            V |                 | |
                              ------------------- |
       vma1.2---------------->|                 | |
                            | |  mode, nodemask,| |
                            | |     ref = 1     | |
                            V |                 | V
                              -------------------


Note that if we cat /proc/<pid1>/numa_maps to display task1's numa maps,
we'll see both policies in the the rbtree.  If we display task2's numa
maps, we'll see only the policy at the front of the segment.  However,
we'll count the page stats over the entire range and report these.  I
can show you an example of this using memtoy, if you'd like, but it's
somewhat orthogonal to the reference counting issue.  Still, I can
imagine that it could confuse customers and result in unnecessary
service calls...

Next,

As part of my shared policy cleanup and enhancement series, I "fixed"
numa_maps to display the sub-ranges of policies in a shm segment mapped
by a single vma. As part of this fix, I also modified mempolicy.c so
that it does not split vmas that support set_policy vm_ops, because
handling both split vmas and non-split vmas for a single shm segment
would have complicated the code more than I thought necessary.  This is
still at prototype stage--altho' it works against 23-rc8-mm2.

With the these changes, the vma connections and ref counts, look like
this:

                                    Figure 2

        task1,                   Shared Policy               task2,
      mm_struct1,                (w/ rb tree)              mm_struct2,
                              -------------------
       vma1.1---------------->|                 |<------------vma2.1
                            | |  mode, nodemask,| |
                            | |     ref = 1     | |
                            | |                 | |
                            | ------------------- |
                            | |                 | |
                            | |  mode, nodemask,| |
                            | |     ref = 1     | |
                            V |                 | V
                              -------------------


With this config, my fix to numa_maps will show the same policy ranges
from either task.  And, of course, the get_policy() vm_op still gets the
correct policy based on the faulting address.

Now, if we modify the shmem mmap() file_op [mmap() vm_op for any
mmap()ed segment who's {set|get}_mempolicy() ops supports sub-range
policies and non-split vmas] to add a reference to shared policies for
each vma attached, we get the following picture:

                                   Figure 3

        task1,                   Shared Policy               task2,
      mm_struct1,                (w/ rb tree)              mm_struct2,
                              -------------------
       vma1.1---------------->|                 |<------------vma2.1
                            | |  mode, nodemask,| |
                            | |     ref = 3     | |
                            | |                 | |
                            | ------------------- |
                            | |                 | |
                            | |  mode, nodemask,| |
                            | |     ref = 3     | |
                            V |                 | V
                              -------------------

Re:  'ref = 3' -- One reference for the rbtree--the shm segment and it's
policies continue to exist independent of any vma mappings--and one for
each attached vma.  Because the vma references are protected by the
respective task/mm_struct's  mmap_sem, we won't need to add an
additional reference during lookup, nor release it when finished with
the policy.  And, we won't need to mess with any other task's mm data
structures when installing/removing shmem policies.  Of course, munmap()
of a vma will need to decrement the ref count of all policies in a
shared policy tree, but this is not a "fast path".  Unfortunately, we
don't have a unmap file operation, so I'd have to add one, or otherwise
arrange to remove the unmapping vma's ref--perhaps via a vm_op so that
we only need to call it on vmas that support it--i.e., that support
shared policy.

I could extract the parts of my shared policy series that gets us to
Figure 2 and add in the necessary mods to prototype Figure 3 if you
would be agreeable to this approach.  However, in that case, I should
produce a minimal patch to make the current reference counting correct,
if overkill.  This involves:  1) fixing do_set_mempolicy() to hold
mmap_sem for write over change, 2) fixing up reference counting for
interleaving for both normal [forgot unref] and huge [unconditional
unref should be conditional] and 3) adding ref to policy in
shm_get_policy() to match shmem_get_policy.  All 3 of these are required
to be correct w/o changing any of the rest of the current ref counting.

Then, once the vma-protected shared policy mechanism discussed above is
in mergable, we can back out all of the extra ref's on other task and
vma policies and the lookup-time ref on shared policies, along with all
of the matching unrefs.

Thoughts?

Lee





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
