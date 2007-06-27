Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706261506400.21844@schroedinger.engr.sgi.com>
References: <20070625195224.21210.89898.sendpatchset@localhost>
	 <Pine.LNX.4.64.0706261506400.21844@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 27 Jun 2007 09:43:38 -0400
Message-Id: <1182951818.6702.33.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, 2007-06-26 at 15:17 -0700, Christoph Lameter wrote:
> On Mon, 25 Jun 2007, Lee Schermerhorn wrote:
> 
> > With patches 1-3 applied, external behavior is, AFAICT, exactly
> > the same as current behavior.  The internal differences are that
> > shared policy is now a pointer in the address_space structure.
> > A NULL value [the default] indicates default policy.  The shared
> > policy is allocated on demand--when one mbind()s a virtual
> > address range backed by a shmem memory object.
> 
> The cleanup patches introduce new fields in structures etc. And we 
> do not have a clean way of handling policies that are modified from the 
> task containing the policy itself without the later patches. Are the
> fixes really first? Looks like you first introduce new features.

As I said, the "fixes" are atop the "cleanup" patches.  Yes, the first
three patches move the shared policy from being embedded in the shmem
and hugetlbfs inodes to being dynamically allocated as needed, anchored
by a pointer in the inode's address_space.  However, these patches
introduce no new behavior from the application's viewpoint.  They just
generalze the infrastructure to simplify the numa_maps fix and make the
hugetlbfs shmem hook up trivial.

The default case [no shared policy] is even faster because we only need
to note that no shared policy exists on the inode to fall back to task
or system policy, rather than do an rb-tree lookup for the single
default policy.

Not sure what you mean about "handling policies that are modified from
the task containing the policy itself".  Shared policies are not
"contained" by any task.  They are attached directly to the "shared
memory object" represented by the inode/address_space.  As far as
locking, see next response...


> 
> > Patch #3 eliminates the need for a pseudo-vma on the stack to 
> > initialize policies for tmpfs inodes when the superblock has
> > a non-default policy by changing the interface to
> > mpol_set_shared_policy() to take a page offset and size in pages,
> > computed in the shmem set_policy vm_op.  This cleanup addresses
> > one complaint about the current shared policy infrastructure.
> 
> Introducing more locking problems? The policy comes from the context that 
> is why the vma on the stack is needed. If you remove the vma then what 
> protects the policy structures?

The vma was only used to define the start/end address of the range to
which the policy applied.  No longer needed, with patch #3.  Shared
policies, once they exist are protected by their embedded spin lock.
Once we can delete a shared policy before the inode is deleted [patch
#9], we have to protect the shared policy pointer via RCU.  I don't
think I've introduced any NEW locking problems.

> 
> > The other internal difference is that linear mappings that support
> > the 'set_policy' vm_op are mapped by a single VMA--not split on
> > policy boundaries.  numa_maps needs to be able to handle this
> > anyway because a task that attaches a shmem segment on which
> > another task has already installed multiple shared policies will
> > have a single vma mapping the entire segment.  Patch #4 fixes
> > numa_maps to display these properly.
> 
> Hmmmm.... Does this display the ranges of pages in a shem area if
> they have distinct policies? Looks like a mess: You need to scan
> vmas for most vmas and then for some vmas you need to scan the shared 
> memory policy tree.

Yes, each policy range is displayed separately.  This is how numa_maps
worked for the task that installed the policies [assuming only one task
installed policies on the segment].  If you looked at another task that
attaches a shmem with shared policy, numa_maps would only show the
policy for the single vma mapping the entire segment.  I made numa_maps
aware of the fact that a single vma can map a shared object with
multiple policy ranges.  

> 
> How much overhead is added by having to lookup memory policies in the 
> policy tree?

"None,"  he says glibly.  It already does this for shmem segments.  It's
just that now, instead of a new vma for each policy [at least for the
task that installed the policies], numa_maps gets a list of ranges that
have different policies for the object and iterates over those.

> 
> > [I hope patch #9 will alleviate Andi's concerns about an unspecified
> > persistence model.  Note that the model implemented by patch #9 could
> > easily be enhanced to persist beyond the last shared mapping--e.g.,
> > via some additional mbind() flags, such as MPOL_MF_[NO]PERSIST--and
> > possibly enhancements to numactl to set/remove shared policy on files.
> > I didn't want to pursue that in this patch set because I don't have a
> > use for it, and it will require some tool to list files with persistent
> > shared policy--perhaps an enhancement to lsof(8).]
> 
> Its still the inderministic behavior: A process cannot know when all other
> processes sharing the mapping terminates. Why would a policy continues to 
> exist when the process that has established that policy terminates? That 
> is a surprising change in semantics.

Because all of the files mapping the file shared are cooperating.  The
one that applies the policy may actually terminate after the actual
"worker bees" processes are started.  I would agree that, if unrelated
processes started mmap()ing files shared and installing policy for their
own purposes with no cooperation, some processes might be surprised by
the policy, if they noticed.  This can be avoided by only enabling the
feature [patch #10] for systems [or cpusets] running well-behaved,
cooperating processes.  The latter are, I think, well served by this
capability.

I'm not adverse to supporting a shared policy on regular files that
persists beyond any mappings--e.g., via the mbind() MPOL_MF_PERSIST flag
that I mentioned.  The persistent policy itself can add a reference to
the inode that pins it until the policy is removed and no processes have
the file open/mmap()ed.  As you and I discussed, this would argue for
some mechanism to list files hanging around only because they have a
persistent policy--something like an enhanced lsof command.  As I
mentioned, I don't have a use case for this type of persistence, but I'd
be happy to help implement it, if anyone does.

> 
> > Patch #10 adds a per cpuset control file--shared_file_policy--to
> > explicitly enable/disable shared policy on shared file mappings.
> > Default is disabled--current behavior.  That is, even with all 11
> > patches applied, you'll have to explicitly enable shared file policy,
> > else the kernel will continue to ignore mbind() of address ranges backed
> > by a shared regular file mapping.  This preserves existing behavior for
> > applications that might currently be installing memory policies on
> > shared regular file mappings, not realizing that they are ignored.
> > Such applications might break or behave unexpectedly if the kernel
> > suddenly starts using the shared policy.   With the per cpuset control
> > defaulting to current behavior, an explicit action by a privileged 
> > user is required to enable the new behavior.
> 
> Hmmmm... This only works in a cpuset?

At this point yes.  It's a convenient task grouping facility.  I figured
that platforms where locality, and therefore memory policy, really
matters are likely to have cpusets anyway, and one might not want to
enable the facility for the entire system.  However, I have thought
about what to do for systems with cpusets/containers configured out:

Note that the "shared_file_policy_enabled" flag is dependent on NUMA, as
is memory policy.  I need to add a way to initialize this task struct
field for the init task for systems w/o cpusets, and then all tasks will
inherit this state.  I can add a kernel command line option to control
this.  Not sure it's worth a run-time sysctl separate from the cpusets.
What do you think?

> 
> > [I hope patch #10 alleviates Christoph's concern about unexpected
> > interaction of shared policies on mmap()ed files in one cpuset with
> > file descriptor access from another cpuset.  This can only happen if
> > the user/adminstrator explicitly enables shared file policies for an
> > application.]
> 
> But a global switch for this? Isnt there some way to come up with clean 
> policy semantics that covers all of this? Its complex enough.

Global?  Well, could be, if you set it in the top level cpuset; or if I
provide the command line option for !CPUSET configs.

I think we'll always have some tension between containers/cpusets and
memory policies--because I think they serve different purposes for
different audiences.  But, I think we can come up with some additional
sematics that address some [but not all] of your issues that we've
discussed--e.g., with objects shared between disjoint cpusets and backup
tasks evicting an applications working set because policy restricts a
mmap'd files pages to the application's cpuset.  I think part of the
problem with this scenario is in the page cache reclaim area.  Let's
discuss in the NUMA BOF and go forward from there.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
