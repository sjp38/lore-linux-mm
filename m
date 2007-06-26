Date: Tue, 26 Jun 2007 15:17:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
In-Reply-To: <20070625195224.21210.89898.sendpatchset@localhost>
Message-ID: <Pine.LNX.4.64.0706261506400.21844@schroedinger.engr.sgi.com>
References: <20070625195224.21210.89898.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 25 Jun 2007, Lee Schermerhorn wrote:

> With patches 1-3 applied, external behavior is, AFAICT, exactly
> the same as current behavior.  The internal differences are that
> shared policy is now a pointer in the address_space structure.
> A NULL value [the default] indicates default policy.  The shared
> policy is allocated on demand--when one mbind()s a virtual
> address range backed by a shmem memory object.

The cleanup patches introduce new fields in structures etc. And we 
do not have a clean way of handling policies that are modified from the 
task containing the policy itself without the later patches. Are the
fixes really first? Looks like you first introduce new features.

> Patch #3 eliminates the need for a pseudo-vma on the stack to 
> initialize policies for tmpfs inodes when the superblock has
> a non-default policy by changing the interface to
> mpol_set_shared_policy() to take a page offset and size in pages,
> computed in the shmem set_policy vm_op.  This cleanup addresses
> one complaint about the current shared policy infrastructure.

Introducing more locking problems? The policy comes from the context that 
is why the vma on the stack is needed. If you remove the vma then what 
protects the policy structures?

> The other internal difference is that linear mappings that support
> the 'set_policy' vm_op are mapped by a single VMA--not split on
> policy boundaries.  numa_maps needs to be able to handle this
> anyway because a task that attaches a shmem segment on which
> another task has already installed multiple shared policies will
> have a single vma mapping the entire segment.  Patch #4 fixes
> numa_maps to display these properly.

Hmmmm.... Does this display the ranges of pages in a shem area if
they have distinct policies? Looks like a mess: You need to scan
vmas for most vmas and then for some vmas you need to scan the shared 
memory policy tree.

How much overhead is added by having to lookup memory policies in the 
policy tree?

> [I hope patch #9 will alleviate Andi's concerns about an unspecified
> persistence model.  Note that the model implemented by patch #9 could
> easily be enhanced to persist beyond the last shared mapping--e.g.,
> via some additional mbind() flags, such as MPOL_MF_[NO]PERSIST--and
> possibly enhancements to numactl to set/remove shared policy on files.
> I didn't want to pursue that in this patch set because I don't have a
> use for it, and it will require some tool to list files with persistent
> shared policy--perhaps an enhancement to lsof(8).]

Its still the inderministic behavior: A process cannot know when all other
processes sharing the mapping terminates. Why would a policy continues to 
exist when the process that has established that policy terminates? That 
is a surprising change in semantics.

> Patch #10 adds a per cpuset control file--shared_file_policy--to
> explicitly enable/disable shared policy on shared file mappings.
> Default is disabled--current behavior.  That is, even with all 11
> patches applied, you'll have to explicitly enable shared file policy,
> else the kernel will continue to ignore mbind() of address ranges backed
> by a shared regular file mapping.  This preserves existing behavior for
> applications that might currently be installing memory policies on
> shared regular file mappings, not realizing that they are ignored.
> Such applications might break or behave unexpectedly if the kernel
> suddenly starts using the shared policy.   With the per cpuset control
> defaulting to current behavior, an explicit action by a privileged 
> user is required to enable the new behavior.

Hmmmm... This only works in a cpuset?

> [I hope patch #10 alleviates Christoph's concern about unexpected
> interaction of shared policies on mmap()ed files in one cpuset with
> file descriptor access from another cpuset.  This can only happen if
> the user/adminstrator explicitly enables shared file policies for an
> application.]

But a global switch for this? Isnt there some way to come up with clean 
policy semantics that covers all of this? Its complex enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
