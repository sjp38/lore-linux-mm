Subject: Query re:  mempolicy for page cache pages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Thu, 18 May 2006 13:49:59 -0400
Message-Id: <1147974599.5195.96.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, Steve Longerbeam <stevel@mvista.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Below I've included an overview of a patch set that I've been working
on.  I submitted a previous version [then called Page Cache Policy] back
~20Apr.  I started working on this because Christoph seemed to consider
this a prerequisite for considering migrate-on-fault/lazy-migration/...
Since the previous post, I have addressed comments [from Christoph] and
kept the series up to date with the -mm tree.  

Just today, I was cleaning up some really old patches on my system and
came across a patch from Steve Longerbeam that passes a page index to
page_cache_alloc_cold()--exactly what my patch series does.  I took a
look back through the -mm archives [Yeah, I should have done this
earlier :-(] and found that back in Oct'04, Steve had posted a patch
[set] that takes essentially the same approach to solve the same
"problem".  

Since Steve's patches never made it into the kernel and don't exist in
the -mm tree either, I'm wondering why they were dropped.  I.e., is
there some fundamental objection to applying shared policy to memory
mapped files and using this policy for page cache allocations?  Rather
than bomb the mailing list with yet another set of dead-end patches, I'm
sending out just this overview, with the following questions:

1) What ever happened to Steve's patch set?

2) Is this even a problem that needs solving, as Christoph seem to think
at one time?

3) If so, is this the right approach?  I.e., should I post the actual
patches?

4) If you don't agree with this approach, how would you go about it?

Regards,
Lee

P.S., tarballs containing the entire series, along with my "lazy
migration" patches can be found at:
http://free.linux.hp.com/~lts/Patches/PageMigration/ in -rcX-mmY
subdirs.

=====================================================================
Mapped File Policy V0.1 0/7 Overview

Formerly "Page Cache Policy" series.

V0.1 -	renamed and revised the series.  I think this name and
	breakout makes more sense.
	Prevent migration of file backed pages with shared
	policy from private mappings thereof.
	Also, address impact on show_numa_map() of patch #3
	of this series.
	refreshed against 2.6.17-rc4-mm1.

Basic "problem":  currently [2.6.17-rcx], files mmap()ed SHARED
do not follow mem policy applied to the mapped regions.  Instead, 
shared, file backed pages are allocated using the allocating
tasks' task policy.  This is inconsistent with the way that anon
and shmem pages are handled.

One reason for this is that down where pages are allocated for
file backed pages, the faulting (mm, vma, address) are not 
available to compute the policy.  However, we do have the inode
[via the address space] and file index/offset available.  If the
applicable policy could be determined from just this info, the
vma and address would not be required.

The following series of patches against 2.6.17-rc4-mm1 implement
numa memory policy for shared, mmap()ed files.   Because files
mmap()ed SHARED are shared between tasks just like shared memory
regions, I've used the shared_policy infrastructure from shmem.
This infrastructure applies policies directly to ranges of a file
using an rb_tree.

These patches result in the following internal and external
semantics:

1) The vma get|set_policy ops handle mem policies on sub-vma
   address ranges for shared, linear mappings [shmem, files]
   without splitting the vmas at the policy boundaries. Private
   and non-linear mappings still split the vma to apply policy.
   However, vma policy is still not visible to the filemap_nopage()
   fault path.  

2) As with shmem segments, the shared policies applied to shared
   file mappings persist as long as the inode remains--i.e., until
   the file is deleted or the inode recycled--whether or not any
   task has the file mapped or even open.  We could, I suppose,
   free the map on last close.

3) Vma policy of private mappings of files only apply when the 
   task gets a private copy of the page--i.e., when do_wp_page()
   breaks the COW sharing and allocates a private page.  Private,
   read-only mappings of a file use the shared policy which 
   defaults, as before, to process policy, which itself defaults
   to, well... default policy.  This is how mapped files have
   always behaved.

	Could be addressed by passing vma,addr down to where
	page cache pages are allocated and use different policy
	for shared, linear vs private or nonlinear mappings.
	Worth the effort?

4) mbind(... 'MOVE*, ...) will not migrate non-anon file backed
   pages in a private mapping if the file has a shared policy.
   Rather, only anon pages that the mapping task has "COWed"
   will be migrated.  If the mapped file does NOT have a shared
   policy or the file is mapped shared, then the pages will be
   migrated, subject to mapcount, as before.  [patch 6]


The patches, to follow, break out as follows:

1 - move-shared-policy-to-inode

	This patch generalizes the shared_policy infrastructure
	for use by generic files.   First, it adds a shared_policy
	pointer to the struct address_space.  This pointer is
	initialized to NULL on inode allocation, indicating the
	process policy.  The shared memory subsystem is then
	modified to use the shared policy struct out of the
	address_space [a.k.a. mapping] instead of explicitly
	using one embedded in the shmem inode info struct.

	Note, however, at this point we still use the embedded
	shared_policy.  We just point the mapping spolicy pointer
	at the embedded struct at init time.

	Tested to ensure shared policies still work for shmem.

2 - alloc-shared-policies

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

	Note:  because the shared policy pointer in address_space
	is overhead incurred by every inode's address space, we
	only define it if CONFIG_NUMA.  Access it via wrappers
	to avoid excessive #ifdef in .c's.

3 - let-vma-policy-op-handle-subrange-policies

	Only shmem currently has a set_policy op, and it knows how
	to handle subranges via the rb_tree.  So, I'm proposing we
	adopt this semantic:  if a vma has set_policy() op, it must
	know to handle subranges and must have a get_policy() op that
	also knows how to handle sub-ranges.  These policy ops will
	ONLY be used for shared mappings [VM_SHARED] because we don't
	want private mappings mucking with the underlying object's
	shared policy.  Also, we can't let the policy ops handle
	it for nonlinear mappings [VM_NONLINEAR] without a lot more
	work.

	One BIG side-effect of this patch:  we no longer split
	vm areas to apply sub-range policies if the vma has
	a set_policy vm_op and is mapped linear, shared.
	However, for private mappings, the vma policy ops will not
	be used, even if they exist, and the vma will be split to
	bind a policy to a sub-range of the vma.

	Not splitting vma's for shared policies required mods
	to show_numa_map().  Handled by subsequent patch.

	migrate_pages_to() now uses page_address_in_vma() to 
	alloc destination page for each source page.  This is
	needed for shared policy subranges and gives a better
	location for each destination page now that Christoph
	is syncing from and to lists.

4 - generic-file-policy-vm-ops

	This patch clones the shmem set/get_policy vm_ops for use
	by generic mmap()ed files.  The functions are added to the
	generic_file_vm_ops struct. These functions operate on the
	shared_policy rb_tree associated with the inode, allocating
	one if necessary.

	Note:   these turned out to be indentical in all but name to
	the shmem '_policy ops.  Maybe eliminate one copy and share?

5 - use-file-policy-for-page-cache

	This patch enhances page_cache_alloc[_cold]() to take an
	offset/index argument.  It uses this to lookup the policy
	using a new function get_file_policy() which is just a
	wrapper around mpol_shared_policy_lookup().  If the inode's
	[mapping's] shared_policy pointer is NULL, just returns the
	process or default policy.

	Then page_cache_alloc[_cold]() calls a new function,
	alloc_page_pol() to evaluate the policy [at a specified
	offset] and allocate an appropriate page.  alloc_page_pol()
	shares some code with alloc_page_vma(), so this area is
	reworked to minimize duplication.  

	All callers of page_cache_alloc[_cold]() are modified to
	pass the file index/offset for which a page is requested.
	The index/offset is available at all call sites as it will
	be used to insert the page into the mapping's radix tree.

6 - fix migration of privately mapped files

	Prevent migration of non-anon pages in private mappings
	of files with shared policy.  Migration uses the mapping's
	vma policy.  vma policy does not apply to shared mmap()ed
	files.

7 - fix show_numa_map

	This patch fixes show_numa_map to correctly display numa
	maps of shmem and shared file mappings with sub-vma policies.
	The patch provides numa specific wrappers [nm_*] around
	the task map functions [m_*] in fs/proc/task_mmu.c to handle
	submaps and modifies show_numa_map() to use a passed in
	address range, instead of vm_start..vm_end.

Cursory testing with memtoy for shm segments, shared and privately
mapped files; single task and 2 tasks mmap()ing same file.  
Verified the semantics described above.

Tested numa maps with memtoy and multiple, disjoint ranges in 
submap--including situation where the buffer end occurs in the
middle of a submap.

Lots more testing needed--both functional and performance.

Lee Schermerhorn



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
