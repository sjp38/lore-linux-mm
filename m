Date: Tue, 5 Apr 2005 21:16:33 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050406041633.25060.64831.21849@jackhammer.engr.sgi.com>
Subject: [PATCH_FOR_REVIEW 2.6.12-rc1 0/3] mm: manual page migration-rc1 -- overview
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Marcello Tosatti <marcello@cyclades.com>
Cc: Ray Bryant <raybry@sgi.com>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Summary
-------

This set of patches is an initial implementation (hence the -rc1)
of the manual page migration facility that I proposed in February
and that was discussed on the linux-mm mailing list.  Rationale
for the manual page migration facility, etc, can be obtained from
that thread, available at the following URL:

http://marc.theaimsgroup.com/?l=linux-mm&m=110817907931126&w=2

and subsequently, at:

http://marc.theaimsgroup.com/?l=linux-mm&m=110820716826294&w=2

and the subsequent messages on that thread.  This material is
included, in an condensed and updated form, under "Background", below.

The implementation meets the interface that Andi Kleen and I agreed
on at that time, AFAIK.

This patch depends on the page migration patches from
the Memory Hotplug project.  This particular patchset is built
on top of:

http://www.sr71.net/patches/2.6.12/2.6.12-rc1-mhp2/page_migration/patch-2.6.12-rc1-mhp3-pm.gz 

but it may appy on subsequent page migration patches as well.

Thus, in order for this patch to be meaningfully considered for
merging, the above patch needs to be merged first.  Alternatively,
we may decide to merge this patch (or peices thereof) with the
above patch.  That is a decision for the Memory Hotplug Project.
Either approach is acceptable as far as I am concerned provided
that the functionality is eventually merged.  :-)

Interface Description
---------------------

After much discussion on the linux-mm mailing list, we have agreed
to use the following kernel interface:

     migrate_pages(pid, count, old_nodes, new_nodes);

The arguments are described as follows:

pid       -- process id of the process to be migrated
count     -- number of entries in the old_nodes, new_nodes arrays
old_nodes -- array of short
new_nodes -- array of short

The way the old_nodes[] and new_nodes[] arguments are interpreted
is as follows:  each migratable page (for a definition of that term,
see below) that is found on node "old_nodes[i]" is migrated to 
"new_nodes[i]".

A page is migratable unless one of the following conditions
are true:

(1)  The page is part of a mapped file and that file has
     the extended attribute "system.migration" set to
     "none".  In this case, none of the pages of the
     mapped file are migratable.

(2)  The page is part of a mapped file and that file has
     the extended attribute "system.migration" set to
     "libr", and the page is a shared page.  (Any page
     that has been written by the process is considered
     private data associated with the process and will
     be migrated.)

Note:  At the present time we only have a patch for XFS
       to support the extended system attribute "migration".
       Until we agree that this is the correct approach,
       there is no point in creating patches for other
       file systems.  See "Issues", below.

For this system call, the set of nodes specified by the old_nodes and
new_nodes lists must be disjoint.  It is the responsibility of a user
space library to convert a migration where the old_nodes and new_nodes
sets are not disjoint into a series of smaller migrations for which
the sets are disjoint.  The system call will return with -EINVAL if the
old_nodes and new_nodes sets are not disjoint.

The system call itself does not support a gather mode (previously
we had talked about using the special value -1 for old_node[0] to
indicate that all migratable pages found would be migrated to
new_node[0]).  Instead this functionality is supported by the
user space library.

Interaction of memory policies with migrate_pages()
---------------------------------------------------

As part of the execution of this system call, memory policy structures
are updated as they are encountered and these structures are modified as
needed to reflect the migration.  For example, if the memory policy is
MPOL_BIND and the bound node is found at old_nodes[i], then the bound
node is replaced by new_nodes[i].  (To preserve atomicity, actually
what happens is that a new memory policy structure is created with the
new bound node and a pointer to the new policy is stored in the process
structure or vma struct; the old mempolicy structure is released.)

If the memory policy is MPOL_DEFAULT, then (obviously) no update
is needed.  However, if the user wishes new allocations to occur on
new_nodes, then the process must be migrated to one of the cpus associated
with one of the new_nodes before the migrate_pages() system call is
issued; otherwise allocations can continue to occur on the old_nodes
after the migrate_pages() system call returns.

Special Considerations for Migrating non-Suspended processes
------------------------------------------------------------

While our usage of this system call assumes that the migrated process has
been suspended (see "Background", below), nothing in the implementation
specifically requires the process to be suspended.  (The page migration
patch from the memory hotplug project supports migration without
suspending the process).  However, if the process being migrated is
actively allocating pages at the same time that migrate_pages() is
executed, there are certain edge conditions that can result in pages
still remaining on the old_nodes after the migrate_pages() system call
returns.  This is because the scan that looks for pages to be migrated
is not atomic with respect to page allocation and any page allocated in
a vma after the vma has been scanned will not be seen by migrate_pages().

For processes (or vma's) that use the memory policy MPOL_DEFAULT, this
problem can normally be overcome by first migrating the process to a
CPU associated with one of the new_nodes before calling migrate_pages().
This can either be done by using set_schedaffinity() or using cpusets.

If the per process mempolicy or a vma mempolicy is other than
MPOL_DEFAULT, then the since the policy is updated before the process
(or vma) is scanned, then in most cases no pages can be allocated on
old_nodes while the scan is in progress and no pages should be left over
on the old nodes.

There is one special case, however.  MPOL_INTERLEAVE uses a per process
variable (current->il_next) to specify which node is the next node to
allocate pages from.  This variable is updated after each allocation
and is separate from the mempolicy.  While updating of mempolicies is
atomic (a pointer to the new policy is stored in the process structure
or vma) there is no way to also atomically update current->il_next.
While current->ilnext is updated by the migrate_pages() system call,
if needed, this update is inherently racy and if the process is not
suspended before it is migrated, there is no way to guarantee that one
(or more?) pages won't be allocated on some old_nodes at the same time
that the migrate_pages() system call is executing.  There appears to be
no way to fix this with the current mempolicy implementation.

Interaction with cpusets
------------------------

On a cpusets enabled system, additional checking is performed to make
sure that the pid specified is allowed to allocate pages on each of the
new nodes.  In addition, normal rules of memory allocation for cpusets
require that the process that invokes the migrate_pages() call is able
to allocate pages on each of the new nodes.  This is required because
the new pages allocated on the new nodes will be allocated using the
cpuset mems_allowed of the current process.

For our intended use of this system call, this restriction is not a
significant limitation, since the process issuing the migrate_pages()
system call will normally be a batch manager of some kind that is 
managing job allocation to a number of cpusets.  The batch manager
will normally be running in a cpuset that is a parent cpuset of
the managed cpusets; hence the batch manager will be have the necessary
permissions to allocate pages in each of its managed cpusets.

Using Extended Attributes to Control Migration
----------------------------------------------

Alternatives to using extended attributes to control page migration have
been proposed, e. g. fixing the dynamic loader so it will mark libraries
as such when they are mapped, thus requiring no file system changes.
For files that should not be migrated, the proposal would be to add
a special mmap() flag (e. g. NOT_MIGRATABLE), and require trivial
application to mmap() the file so long as it is needed to be marked
not-migratable.  This needs to be discussed further and a resolution
reached.  The current patchset implements the extended attribute approach
for the XFS file system.

Description of the patches in this patchset
-------------------------------------------
Patch 1: nathan_scott_extended_attributes-rc1.patch
	 This patch, due to Nathan Scott at SGI, adds support to
	 XFS for the system.migration extended attribute.

Patch 2: add-node_map-arg-to-try_to_migrate_pages-rc1.patch
         This patch adds an additional argument to try_to_migrate_pages().
	 The additional argument is of type short * and is named node_map.
	 If node_map is NULL, then try_to_migrate_pages() works as it
	 used to.  If node_map is non-NULL, then it must point to an
	 array of size MAX_NUMNODES.  node_map[i] is either -1 (if pages
	 found on node "i" are not to be migrated, or the new node number
	 if pages on node "i" are to be migrated.

Patch 3: add-sys_migrate_pages-rc1.patch
	 This is the patch that adds the migrate_pages() system call.


Issues to be resolved:
---------------------

Here is a list (probably not comprehensive) of the issues that need
to be resolved:

(1)  Resolve whether the extended attribute approach for controlling
     which files are migrated is acceptable, and if not what the
     alternative approach should be.  The current patch includes
     the function:  is_mapped_file_migratable() and any changes in
     this area should be confined to rewriting that function.

(2)  At the moment, there is no access protection checking built
     into the extended attributes implementation.  Given the 
     discussion above, we propose to wait until the above is
     resolved before completing this part of the implementation.

(3)  We haven't done the extended attribute implementation for
     other file systems, for reasons similar to that of (2).

(4)  This implementation has chosen (arbitrarily) to use system call
     number 1279 as the system call number for sys_migrate_pages().
     Obviously, this system call number will need to be assigned.

(5)  We haven't resolved the "permissions" model -- i. e. which
     processes can migrate which threads.  Here are two possibilities:

     (a)  Only root processes are able to call migrate_pages().
          (Equivalently, we could define a CAP_MIGRATION capability
	  and require the sending process to have that capability.)

     (b)  A process is allowed to call migrate_pages(pid,...) for
          any pid that the process could signal.

(6)  As part of the discussion with Andi Kleen, we agreed to
     provide some memory migration support under MPOL_MF_STRICT.
     Currently, if one calls mbind() with the flag MPOL_MF_STRICT
     set, and pages are found that don't follow the memory policy,
     then the mbind() will return -EIO.  Andi would like to be
     able cause those pages to be migrated to the correct nodes.
     This feature is not yet part of this patchset.

Background
----------

The purpose of this set of patches is to introduce the necessary kernel
infrastructure to support "manual page migration".  That phrase is
intended to describe a facility whereby some user program (most likely
a batch scheduler) is given the responsibility of managing where jobs
run on a large NUMA system.  If it turns out that a job needs to be
run on a different set of nodes from where it is running now, then that
user program would invoke this facility to move the job to the new set
of nodes.

We use the word "manual" here to indicate that the facility is invoked
in a way that the kernel is told where to move things; we distinguish
this approach from "automatic page migration" facilities which have been
proposed in the past.  To us, "automatic page migration" implies using
hardware counters to determine where pages should reside and having the
O/S automatically move misplaced pages.  The utility of such facilities,
for example, on IRIX has, been mixed, and we are not currently proposing
such a facility for Linux.

The normal sequence of events would be as follows:  A job is running
on, say nodes 5-8, and a higher priority job arrives and the only place
it can be run, for whatever reason, is nodes 5-8.  Then the scheduler
would suspend the processes of the existing job (by, for example sending
them a SIGSTOP) and start the new job on those nodes.  At some point in
the future, other nodes become available for use, and at this point the
batch scheduler would invoke the manual page migration facility to move
the processes of the suspended job from nodes 5-8 to the new set of nodes.

Note that not all of the pages of all of the processes will need to (or
should) be moved.  For example, pages of shared libraries are likely to be
shared by many processes in the system; these pages should not be moved
merely because a few processes using these libraries have been migrated.
As discussed above, we use the extended attribute system.migration with
value "lib" to identify such files.  If a shared library file does not
have this attribute set, or the shared library is stored in a file system
that does not support extended attributes (e. g. XFS), then the entire
shared library will be migrated.

-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant                       raybry@sgi.com
The box said: "Requires Windows 98 or better",
           so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
