From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 25 Jun 2007 15:52:24 -0400
Message-Id: <20070625195224.21210.89898.sendpatchset@localhost>
Subject: [PATCH/RFC 0/11] Shared Policy Overview
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

[RFC] Shared Policy Fixex and Mapped File Policy 0/11 

Against 2.6.22-rc4-mm2

This is my former "Mapped File Policy" patch set, reordered to
move the fixes to numa_maps and the "hook up" of hugetlb shmem
policies to before the hook up of shared policy to shared mmap()ed
regular files.  ["Fixes first" per Christoph L.]

The 2 patches to fix up current behavior issues [#s 4 & 5] sit
atop 3 "cleanup" patches.  The clean up patches simplify the fixes
and, yes, support the generic mapped file policy patches [#s 6-11].

With patches 1-3 applied, external behavior is, AFAICT, exactly
the same as current behavior.  The internal differences are that
shared policy is now a pointer in the address_space structure.
A NULL value [the default] indicates default policy.  The shared
policy is allocated on demand--when one mbind()s a virtual
address range backed by a shmem memory object.

Patch #3 eliminates the need for a pseudo-vma on the stack to 
initialize policies for tmpfs inodes when the superblock has
a non-default policy by changing the interface to
mpol_set_shared_policy() to take a page offset and size in pages,
computed in the shmem set_policy vm_op.  This cleanup addresses
one complaint about the current shared policy infrastructure.

The other internal difference is that linear mappings that support
the 'set_policy' vm_op are mapped by a single VMA--not split on
policy boundaries.  numa_maps needs to be able to handle this
anyway because a task that attaches a shmem segment on which
another task has already installed multiple shared policies will
have a single vma mapping the entire segment.  Patch #4 fixes
numa_maps to display these properly.

Patch #5 hooks up SHM_HUGETLB segments to use the shmem get/set
policy vm_ops.  This "just works" with the fixes to numa_maps
in patch #4.  Without the numa_maps fixes, a cat of the numa_maps
of a task with a hugetlb shmem segment with shared policy attached
would hang.

Again, patches 6-11 define the generic file shared policy support,
They also prevent a private file mapping from affecting any shared
policy installed via a shared mapping, including preventing migrating
the shared pages to follow the address space private policy.
Policies installed via a private mapping apply only to the calling
task's address space--current behavior. 

Patches 6-8 add support for shared policy on regular files, factoring
alloc_page_vma() into vma policy lookup and allocation of a page
given a policy--alloc_page_pol().  Then, the page page cache alloc
function can lookup the shared file policy via page offset and use
the same alloc_page_pol() to allocate the page based on that policy.

Patch #9 defines an initial peristence model for shared policies on
shared mmap()ed files:   a shared policy can only be installed on generic
files via a shared mmap()ing.  Such a policy will persist as long as
any shared mmap()ings exist.  Shared mappings of a file are tracked
by the i_mmap_writable count in the struct address_space.  Patch #9
removes any existing policy when the i_mmap_writable count goes to zero.

Note that the existing shared policy persistence model for shmem segments
is different.  Once installed, the shared policies persist until the segment
is destroyed.  Because shmem goes through the same unmap path, shared
policies on shmem segments are marked with a SPOL_F_PERSIST flag to
prevent them from being removed on last detatch [unmap]--i.e., to preserve
existing behavior.

Also note that because we can remove a shared policy from a "live"
inode, we need to handle potential races with another task performing
a get_file_policy() on the same file via a file descriptor access
[read()/write()/...].  Patch #9 handles this by defining an RCU reader
critical region in get_file_policy() and by synchronizing with this
in mpol_free_shared_policy().

[I hope patch #9 will alleviate Andi's concerns about an unspecified
persistence model.  Note that the model implemented by patch #9 could
easily be enhanced to persist beyond the last shared mapping--e.g.,
via some additional mbind() flags, such as MPOL_MF_[NO]PERSIST--and
possibly enhancements to numactl to set/remove shared policy on files.
I didn't want to pursue that in this patch set because I don't have a
use for it, and it will require some tool to list files with persistent
shared policy--perhaps an enhancement to lsof(8).]

Patch #10 adds a per cpuset control file--shared_file_policy--to
explicitly enable/disable shared policy on shared file mappings.
Default is disabled--current behavior.  That is, even with all 11
patches applied, you'll have to explicitly enable shared file policy,
else the kernel will continue to ignore mbind() of address ranges backed
by a shared regular file mapping.  This preserves existing behavior for
applications that might currently be installing memory policies on
shared regular file mappings, not realizing that they are ignored.
Such applications might break or behave unexpectedly if the kernel
suddenly starts using the shared policy.   With the per cpuset control
defaulting to current behavior, an explicit action by a privileged 
user is required to enable the new behavior.

[I hope patch #10 alleviates Christoph's concern about unexpected
interaction of shared policies on mmap()ed files in one cpuset with
file descriptor access from another cpuset.  This can only happen if
the user/adminstrator explicitly enables shared file policies for an
application.]

Finally, patch #11 adds the generic file set|get_policy vm_ops to
actually hook up shared file mappings to memory policy.  Without this
patch, the shared policy infrastructure enhancements in the previous
patches remain mostly unused, except for the existing shmem and added
hugetlbfs usage.

---

Note:  testing/code sizes/... covered in previous posting:

	http://marc.info/?l=linux-mm&m=118002773528224&w=4

No sense in repeating this until we decide to go forward.
However, this series has been tested with 22-rc4-mm2 on ia64 and
x86_64 platforms.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
