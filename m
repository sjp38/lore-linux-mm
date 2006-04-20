Subject: [PATCH/RFC] Page Cache Policy V0.0 0/5 Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Thu, 20 Apr 2006 16:39:32 -0400
Message-Id: <1145565572.5214.33.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Resend with subject!

Page Cache Policy V0.0 0/5 Overview

Work in progress -- for comment.  Christoph wanted to see
this addressed before migrate-on-fault goes any farther.
So, here's a cut.  Series to follow...

Note:  tested atop recently posted add-shmem-migratepage-a_op
patch on 2.6.17-rc1-mm2
----------------------

Basic "problem":  currently [2.6.17-rc1], file mmap()ed SHARED
do not follow policy applied to the mapped regions.  Instead, 
shared file backed pages are allocated using the allocating
tasks' task policy.  This is inconsistent with the way that anon
and shmem pages are handled.

One reason for this is that down where pages are allocated for
file backed pages, the faulting (mm, vma, address) are not 
available to compute the policy.  However, we do have the inode
[via the address space] and file index/offset available.  If the
applicable policy could be determined from just this info, the
vma and address would not be required.

The following series of patches against 2.6.17-rc1-mm2 implements
numa memory policy for shared, mmap()ed files.   Because files
mmap()ed SHARED are shared between tasks just like shared memory
regions, I've used the shared_policy infrastructure from shmem.
This infrastructure applies policies directly to ranges of a file
using a prio tree.

The patches break out as follows:

1 - add-offset-arg-to-migrate_pages_to

	A minor preparatory patch:  adds the page offset/index
	arg to migrate_pages_to() for properly computing nodes
	for interleaved policies.  Used by subsequent patch.

2 - move-shared-policy-to-inode

	This patch generalizes the shared_policy infrastructure
	for use by generic files.   First, it adds a shared_policy
	pointer to the struct address_space.  This pointer is
	initialized to NULL on inode allocation, indicating the
	default policy.  The shared memory subsystem is then
	modified to use the shared policy struct out of the
	address_space [a.k.a. mapping] instead of explicitly
	using one embedded in the shmem inode info struct.

	Note, however, at this point we still use the embedded
	shared_policy.  We just point the mapping spolicy pointer
	at the embedded struct at init time.

	One BIG side-effect of this patch:  we no longer split
	vm areas to apply sub-range policies if the vma has
	a set_policy vm_op.  Only shmem currently has a set_policy
	op, and it knows how to handle subranges via the prio tree.
	So, I'm proposing to adopt this semantic:  if a vma has
	set_policy() op, it must know to handle subranges and must
	have a get_policy() op that also knows how to handle sub-
	ranges.

	Tested to ensure shared policies still work for shmem.

	TODO:  check effects on numa maps of not splitting vmas.

3 - alloc-shared-policies

	This patch removes the shared_policy structs embedded in
	the shmem and hugetlbfs inode info structs, and dynamically
	allocates them, from a new kmem cache, when needed.

	Shmem will allocate a shared policy at segment init if
	the superblock [mount] specifies non-default policy.
	Otherwise, the shared_policy struct will only be allocated
	if a task mbind()s a range of the segment.

	Hugetlbfs just leaves the spolicy pointer NULL [default].
	It will be allocated by the shmem set_policy() vm_op if
	a task mbinds a range of the hugetlb segment.

4 - generic-file-policy-vm-ops

	This patch clones the shmem set/get_policy vm_ops for use
	by generic mmap()ed files.  The functions are added to the
	generic_file_vm_ops struct. These functions operate on the
	shared_policy prio tree associated with the inode, allocating
	one if necessary.

	Note:   these turned out to be indentical in all but name to
	the shmem '_policy ops.  Maybe eliminate one copy and share?

5 - use-file-policy-for-page-cache

	This patch enhances page_cache_alloc[_cold]() to take an
	offset/index argument.  It uses this to lookup the policy
	using a new function get_file_policy() which is just a
	wrapper around mpol_shared_policy_lookup().  If the inode's
	[mapping's] shared_policy pointer is NULL, just returns the
	default policy.

	Then page_cache_alloc[_cold]() calls a new function,
	alloc_page_pol() to evaluate the policy [at a specified
	offset] and allocate an appropriate page.  alloc_page_pol()
	shares some code with alloc_page_vma(), so this area is
	reworked to minimize duplication.  

	All callers of page_cache_alloc[_cold]() are modified to
	pass the file index/offset for which a page is requested.
	The index/offset is available at all call sites as it will
	be used to insert the page into the mapping's radix tree.

Cursory testing with memtoy for shm segments, shared and privately
mapped files; single task and 2 tasks mmap()ing same file.  When
the file is mmap()ed shared, either task's policy changes are seen
by both tasks.  When one maps shared and the other private, the
private mapper's policies apply only to its mapping.

Lots more testing needed.

Lee Schermerhorn




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
