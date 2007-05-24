From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 24 May 2007 13:28:21 -0400
Message-Id: <20070524172821.13933.80093.sendpatchset@localhost>
Subject: [PATCH/RFC 0/8] Mapped File Policy Overview
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, nish.aravamudan@gmail.com, ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

[RFC] Mapped File Policy 0/8 

Against 2.6.22-rc2-mm1

I posted an earlier version of this series around a year ago to
a less than enthusiastic response.  I've maintained the series
out of tree, testing against occasional -mm trees.  Lately, I've
had the privilege of trying to explain how the existing Linux
memory policy works--with all the exceptions and gotchas vis a vis
shared file mappings--to various groups inside and outside of HP.
This experience has convinced me that it's time to post again...

Andrew:  I can fold this long-wided overview into the first patch
if the series ever gets accepted into mm.  I know you don't like
separate overviews, but the patch 1 description is already quite
long.

Nish:  I believe this series works for hugepages, but I've only
tested SHM_HUGETLB.  

Lee Schermerhorn

---

Basic "problem":  currently [~2.6.21], files mmap()ed SHARED
do not follow mem policy applied to the mapped regions.  Instead, 
shared, file backed pages are allocated using the allocating
tasks' task policy.  This is inconsistent with the way that anon
and shmem pages are handled, violating, for me, the Principle
of Least Astonishment.

One reason for this is that down where pages are allocated for
file backed pages, the faulting (mm, vma, address) are not 
available to compute the policy.  However, we do have the
address_space [a.k.a. mapping] and file index/offset available.
If the applicable policy could be determined from just this info,
the vma and address would not be required.

Note that hugepage shmem segments do not follow the vma policy even
tho' the hugetlbfs inode_info contains the shared policy struct.
This situation arises because the hugetlbfs vm_ops do not contain the
shmem_{get|set}_policy ops.  One can't just add these.  If you do,
a read/cat of /proc/<pid>/numa_maps will hang.  I haven't investigated
reason for the hang.  However, this series does not suffer that
problem.

This series of patches implements NUMA memory policy for shared,
mmap()ed files.   Because files mmap()ed SHARED are shared between
tasks just like shared memory regions, I've used the shared_policy
infrastructure from shmem.  This infrastructure applies policies
directly to ranges of a file using an rb_tree.  The tree is indexed
by the page offset, which we have in page cache allocation contexts.

Note that the method used is similar to one proposed by Steve Longerbeam
quite a few years ago, except that I dynamically allocate the shared
policy struct when needed, rather than embedding it directly in the
inode/address_space.

This series result in the following internal and external semantics:

1) The vma get|set_policy ops handle memory policies on sub-vma
   address ranges for shared, linear mappings [shmem, files]
   without splitting the vmas at the policy boundaries. Private
   and non-linear mappings still split the vma to apply policy.
   However, vma policy is still not visible to the nopage fault path.  

2) As with shmem segments, the shared policies applied to shared
   file mappings persist as long as the inode remains--i.e., until
   the file is deleted or the inode recycled--whether or not any
   task has the file mapped or even open.  We could, I suppose,
   free the shared policy on last close.

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

	Or, we could force a COW in the fault path for a read
	fault if the page cache page location does not match
	the private mapping's vma policy.
	Worth the overhead?

4) mbind(... 'MOVE*, ...) will not migrate page cache pages in
   a private mapping if the file has a shared policy.  Rather,
   only anon pages that the mapping task has "COWed" will be
   migrated.  If the mapped file does NOT have a shared policy
   or the file is mapped shared, then the pages will be migrated,
   subject to mapcount, preserving the existing semantics.

Impact On Kernel Build times

Parallel [-j4] kernel build on 1.8GHz 2 socket/single core/4GB
Opteron blade.  Average and standard deviation of 10 runs, after
an initial warmup run:

		Real	User	System
w/o patch	142.19	247.98	30.0	avg
		  0.73	  0.27	 0.14	std dev'n

w/  patch	142.28	247.57	30.74	avg
		  0.64	  0.36	 0.28	std dev'n

Impact On Kernel Size [2.6.22-rc2-mm1+]:

With CONFIG_NUMA [built, but not test w/o 'NUMA]

                      text    data     bss       dec
x86_64 w/o patch:  6280775  855146  612200   7748121
x86_64 w/  patch:  6283071  855146  612264   7750481
x86_64 diff:          2296       0      64      2360

ia64   w/o patch   9032530 1253999 1431020  11717549
ia64   w/  patch:  9037618 1254031 1431028  11722677
ia64 diff:            5088      32       8      5128

Impact On Inode Size

The series removes the shared policy structure from the shmem
and hugetlb 'inode_info structures, and replaces them with a
pointer in the address_space structure, conditional on 
CONFIG_NUMA.  This effectively increases the size of the inode
for all systems configured with NUMA support.  However, for the
2 architectures tested [ia64 and x86_64], this did not change
the number of objects/slab.  For 2.6.22-rc1-mm1:

            w/o patch		    w/ patch
	inode_size obj/slab	inode_size obj/slab
x86_64	   736        7     	   744        7

ia64	   584       27    	   592       27

Similary, many file system specific inode sizes increased by
one pointer's worth, but the number of objects/slab remained
the same--at least for those that showed up in my slabinfo.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
