Date: Wed, 8 Mar 2006 15:37:46 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Page migration documentation update
Message-ID: <Pine.LNX.4.64.0603081537010.10438@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

Update the documentation for page migration.

- Fix up bits and pieces in cpusets.txt

- Rework text in vm/page-migration to be clearer and reflect the final
  version of page migration in 2.6.16. Mention Andi Kleen's numactl
  package that contains user space tools for page migration via
  libnuma. Add reference to numa_maps and to the manpage in numactl.

- Add todo list for outstanding issues

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc5-mm3/Documentation/cpusets.txt
===================================================================
--- linux-2.6.16-rc5-mm3.orig/Documentation/cpusets.txt	2006-03-07 09:17:22.000000000 -0800
+++ linux-2.6.16-rc5-mm3/Documentation/cpusets.txt	2006-03-08 14:38:29.000000000 -0800
@@ -4,8 +4,9 @@
 Copyright (C) 2004 BULL SA.
 Written by Simon.Derr@bull.net
 
-Portions Copyright (c) 2004 Silicon Graphics, Inc.
+Portions Copyright (c) 2004-2006 Silicon Graphics, Inc.
 Modified by Paul Jackson <pj@sgi.com>
+Modified by Christoph Lameter <clameter@sgi.com>
 
 CONTENTS:
 =========
@@ -91,7 +92,8 @@ This can be especially valuable on:
 
 These subsets, or "soft partitions" must be able to be dynamically
 adjusted, as the job mix changes, without impacting other concurrently
-executing jobs.
+executing jobs. The location of the running jobs pages may also be moved
+when the memory locations are changed.
 
 The kernel cpuset patch provides the minimum essential kernel
 mechanisms required to efficiently implement such subsets.  It
@@ -103,8 +105,8 @@ memory allocator code.
 1.3 How are cpusets implemented ?
 ---------------------------------
 
-Cpusets provide a Linux kernel (2.6.7 and above) mechanism to constrain
-which CPUs and Memory Nodes are used by a process or set of processes.
+Cpusets provide a Linux kernel mechanism to constrain which CPUs and
+Memory Nodes are used by a process or set of processes.
 
 The Linux kernel already has a pair of mechanisms to specify on which
 CPUs a task may be scheduled (sched_setaffinity) and on which Memory
@@ -443,22 +445,17 @@ cpusets memory placement policy 'mems' s
 If the cpuset flag file 'memory_migrate' is set true, then when
 tasks are attached to that cpuset, any pages that task had
 allocated to it on nodes in its previous cpuset are migrated
-to the tasks new cpuset.  Depending on the implementation,
-this migration may either be done by swapping the page out,
-so that the next time the page is referenced, it will be paged
-into the tasks new cpuset, usually on the node where it was
-referenced, or this migration may be done by directly copying
-the pages from the tasks previous cpuset to the new cpuset,
-where possible to the same node, relative to the new cpuset,
-as the node that held the page, relative to the old cpuset.
+to the tasks new cpuset. The relative placement of the page within
+the cpuset is preserved during these migration operations if possible.
+For example if the page was on the second valid node of the prior cpuset
+then the page will be placed on the second valid node of the new cpuset.
+
 Also if 'memory_migrate' is set true, then if that cpusets
 'mems' file is modified, pages allocated to tasks in that
 cpuset, that were on nodes in the previous setting of 'mems',
-will be moved to nodes in the new setting of 'mems.'  Again,
-depending on the implementation, this might be done by swapping,
-or by direct copying.  In either case, pages that were not in
-the tasks prior cpuset, or in the cpusets prior 'mems' setting,
-will not be moved.
+will be moved to nodes in the new setting of 'mems.'
+Pages that were not in the tasks prior cpuset, or in the cpusets
+prior 'mems' setting, will not be moved.
 
 There is an exception to the above.  If hotplug functionality is used
 to remove all the CPUs that are currently assigned to a cpuset,
@@ -506,16 +503,6 @@ and then start a subshell 'sh' in that c
   # The next line should display '/Charlie'
   cat /proc/self/cpuset
 
-In the case that a change of cpuset includes wanting to move already
-allocated memory pages, consider further the work of IWAMOTO
-Toshihiro <iwamoto@valinux.co.jp> for page remapping and memory
-hotremoval, which can be found at:
-
-  http://people.valinux.co.jp/~iwamoto/mh.html
-
-The integration of cpusets with such memory migration is not yet
-available.
-
 In the future, a C library interface to cpusets will likely be
 available.  For now, the only way to query or modify cpusets is
 via the cpuset file system, using the various cd, mkdir, echo, cat,
Index: linux-2.6.16-rc5-mm3/Documentation/vm/page_migration
===================================================================
--- linux-2.6.16-rc5-mm3.orig/Documentation/vm/page_migration	2006-02-26 21:09:35.000000000 -0800
+++ linux-2.6.16-rc5-mm3/Documentation/vm/page_migration	2006-03-08 15:20:41.000000000 -0800
@@ -12,12 +12,18 @@ is running.
 
 Page migration allows a process to manually relocate the node on which its
 pages are located through the MF_MOVE and MF_MOVE_ALL options while setting
-a new memory policy. The pages of process can also be relocated
+a new memory policy via mbind(). The pages of process can also be relocated
 from another process using the sys_migrate_pages() function call. The
 migrate_pages function call takes two sets of nodes and moves pages of a
 process that are located on the from nodes to the destination nodes.
+Page migration functions are provided by the numactl package by Andi Kleen
+(a version later than 0.9.3 is required. Get it from
+ftp://ftp.suse.com/pub/people/ak). numactl provided libnuma which
+provides an interface similar to other numa functionality for page migration.
+cat /proc/<pid>/numa_maps allows an easy review of where the pages of
+a process are located. See also the numa_maps manpage in the numactl package.
 
-Manual migration is very useful if for example the scheduler has relocated
+Manual migration is useful if for example the scheduler has relocated
 a process to a processor on a distant node. A batch scheduler or an
 administrator may detect the situation and move the pages of the process
 nearer to the new processor. At some point in the future we may have
@@ -25,10 +31,12 @@ some mechanism in the scheduler that wil
 
 Larger installations usually partition the system using cpusets into
 sections of nodes. Paul Jackson has equipped cpusets with the ability to
-move pages when a task is moved to another cpuset. This allows automatic
-control over locality of a process. If a task is moved to a new cpuset
-then also all its pages are moved with it so that the performance of the
-process does not sink dramatically (as is the case today).
+move pages when a task is moved to another cpuset (See ../cpusets.txt).
+Cpusets allows the automation of process locality. If a task is moved to
+a new cpuset then also all its pages are moved with it so that the
+performance of the process does not sink dramatically. Also the pages
+of processes in a cpuset are moved if the allowed memory nodes of a
+cpuset are changed.
 
 Page migration allows the preservation of the relative location of pages
 within a group of nodes for all migration techniques which will preserve a
@@ -37,22 +45,26 @@ process. This is necessary in order to p
 Processes will run with similar performance after migration.
 
 Page migration occurs in several steps. First a high level
-description for those trying to use migrate_pages() and then
-a low level description of how the low level details work.
+description for those trying to use migrate_pages() from the kernel
+(for userspace usage see the Andi Kleen's numactl package mentioned above)
+and then a low level description of how the low level details work.
 
-A. Use of migrate_pages()
--------------------------
+A. In kernel use of migrate_pages()
+-----------------------------------
 
 1. Remove pages from the LRU.
 
    Lists of pages to be migrated are generated by scanning over
    pages and moving them into lists. This is done by
-   calling isolate_lru_page() or __isolate_lru_page().
+   calling isolate_lru_page().
    Calling isolate_lru_page increases the references to the page
-   so that it cannot vanish under us.
-
-2. Generate a list of newly allocates page to move the contents
-   of the first list to.
+   so that it cannot vanish while the page migration occurs.
+   It also prevents the swapper or other scans to encounter
+   the page.
+
+2. Generate a list of newly allocates page. These pages will contain the
+   contents of the pages from the first list after page migration is
+   complete.
 
 3. The migrate_pages() function is called which attempts
    to do the migration. It returns the moved pages in the
@@ -63,13 +75,17 @@ A. Use of migrate_pages()
 4. The leftover pages of various types are returned
    to the LRU using putback_to_lru_pages() or otherwise
    disposed of. The pages will still have the refcount as
-   increased by isolate_lru_pages()!
-
-B. Operation of migrate_pages()
---------------------------------
-
-migrate_pages does several passes over its list of pages. A page is moved
-if all references to a page are removable at the time.
+   increased by isolate_lru_pages() if putback_to_lru_pages() is not
+   used! The kernel may want to handle the various cases of failures in
+   different ways.
+
+B. How migrate_pages() works
+----------------------------
+
+migrate_pages() does several passes over its list of pages. A page is moved
+if all references to a page are removable at the time. The page has
+already been removed from the LRU via isolate_lru_page() and the refcount
+is increased so that the page cannot be freed while page migration occurs.
 
 Steps:
 
@@ -79,36 +95,40 @@ Steps:
 
 3. Make sure that the page has assigned swap cache entry if
    it is an anonyous page. The swap cache reference is necessary
-   to preserve the information contain in the page table maps.
+   to preserve the information contain in the page table maps while
+   page migration occurs.
 
 4. Prep the new page that we want to move to. It is locked
    and set to not being uptodate so that all accesses to the new
-   page immediately lock while we are moving references.
+   page immediately lock while the move is in progress.
 
-5. All the page table references to the page are either dropped (file backed)
-   or converted to swap references (anonymous pages). This should decrease the
-   reference count.
+5. All the page table references to the page are either dropped (file
+   backed pages) or converted to swap references (anonymous pages).
+   This should decrease the reference count.
 
-6. The radix tree lock is taken
+6. The radix tree lock is taken. This will cause all processes trying
+   to reestablish a pte to block on the radix tree spinlock.
 
 7. The refcount of the page is examined and we back out if references remain
    otherwise we know that we are the only one referencing this page.
 
 8. The radix tree is checked and if it does not contain the pointer to this
-   page then we back out.
+   page then we back out because someone else modified the mapping first.
 
 9. The mapping is checked. If the mapping is gone then a truncate action may
    be in progress and we back out.
 
-10. The new page is prepped with some settings from the old page so that accesses
-   to the new page will be discovered to have the correct settings.
+10. The new page is prepped with some settings from the old page so that
+   accesses to the new page will be discovered to have the correct settings.
 
 11. The radix tree is changed to point to the new page.
 
-12. The reference count of the old page is dropped because the reference has now
-    been removed.
+12. The reference count of the old page is dropped because the radix tree
+    reference is gone.
 
-13. The radix tree lock is dropped.
+13. The radix tree lock is dropped. With that lookups become possible again
+    and other processes will move from spinning on the tree lock to sleeping on
+    the locked new page.
 
 14. The page contents are copied to the new page.
 
@@ -119,11 +139,37 @@ Steps:
 
 17. Queued up writeback on the new page is triggered.
 
-18. If swap pte's were generated for the page then remove them again.
+18. If swap pte's were generated for the page then replace them with real
+    ptes. This will reenable access for processes not blocked by the page lock.
+
+19. The page locks are dropped from the old and new page.
+    Processes waiting on the page lock can continue.
 
-19. The locks are dropped from the old and new page.
+20. The new page is moved to the LRU and can be scanned by the swapper
+    etc again.
 
-20. The new page is moved to the LRU.
+TODO list
+---------
+
+- Page migration requires the use of swap handles to preserve the
+  information of the anonymous page table entries. This means that swap
+  space is reserved but never used. The maximum number of swap handles used
+  is determined by CHUNK_SIZE (see mm/mempolicy.c) per ongoing migration.
+  Reservation of pages could be avoided by having a special type of swap
+  handle that does not require swap space and that would only track the page
+  references. Something like that was proposed by Marcelo Tosatti in the
+  past (search for migration cache on lkml or linux-mm@kvack.org).
+
+- Page migration unmaps ptes for file backed pages and requires page
+  faults to reestablish these ptes. This could be optimized by somehow
+  recording the references before migration and then reestablish them later.
+  However, there are several locking challenges that have to be overcome
+  before this is possible.
+
+- Page migration generates read ptes for anonymous pages. Dirty page
+  faults are required to make the pages writable again. It may be possible
+  to generate a pte marked dirty if it is known that the page is dirty and
+  that this process has the only reference to that page.
 
-Christoph Lameter, December 19, 2005.
+Christoph Lameter, March 8, 2006.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
