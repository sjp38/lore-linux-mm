Date: Tue, 10 May 2005 21:37:56 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>
Subject: [PATCH 2.6.12-rc3 0/8] mm: manual page migration-rc2 -- overview
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>
List-ID: <linux-mm.kvack.org>

Summary
-------

This set of patches is a more or less complete implementation
of the manual page migration facility that I proposed in February
and that was discussed on the linux-mm mailing list.  This overview
is relatively short since the overview is effectively unchanged
from what I submitted on April 6, 2005.  For details, see the
overview I sent out then at:

http://marc.theaimsgroup.com/?l=linux-mm&m=111276123522952&w=2

This patch set differs from the previous patchset in the following:

(1)  The previous patch was based on 2.6.12-rc1-mhp3, this patchset
     is based on patch-2.6.12-rc3-mhp1-pm.gz from www.sr71.net/patches/
     2.6.12 (of the Memory Hotplug project patchset maintained by
     Dave Hansen).

(2)  This patchset has been divided into a few more, smaller
     patches for easier digestion.

(3)  This patch set includes a permissions check, whereas the
     previous patch set did not.  The permissions check is
     effectively the following:  A process can issue the migrate_pages()
     system call against another process if the either (a) the
     first process has the permission to send a non-trivial signal
     to the second process or if (b) the calling process has the
     capability CAP_SYS_ADMIN.  See the last patch of this set
     (8/8) titled: sys_migrate_pages-permissions-check.patch
     for further details.

(4)  This patch set includes a patch (again due to Nathan Scott
     of SGI) that provides a migrate_page method for XFS.
     This patch is necessary to provide acceptable performance
     for migrations involving mapped files in XFS.  EXT2 and 
     EXT3 already have migrate_page methods.

(5)  Changes suggested by Dave Hansen have been incorporated
     into this patch set.

If this patch is acceptable to the Memory Hotplug Team, I'd like
to see it added to the page migration sequence of patches in
the memory hotplug patch.  (Hirokazu, in particular, could you
review the patches?  Thanks.)

As always, suggestions, flames, etc should be directed to me
at raybry@sgi.com.

Unresolved issues
-----------------

(1)  This version of migrate_pages() works reliably only when the
     process to be migrated has been stopped (e. g., using SIGSTOP)
     before the migrate_pages() system call is executed.  I am
     working on eliminating that restriction, however, at the
     present time the system call does not work reliably without
     the process first being stopped.  (The system doesn't crash
     or oops, but sometimes the process being migrated will be
     "Killed by VM" when it starts up again.  There may be a few
     messages put into the log as well at that time.)

     Of course, I could check to make sure the target process is
     stopped in the migrate_pages() system call, but there is no
     good way to make sure that the process remains stopped for
     the duration of the system call (at least that I am aware
     of) so that is a partial fix, at best.

(2)  I'm still using system call #1279.  On ia64 this is the
     last slot in the system call table.  A system call number
     needs to be assigned to migrate_pages().

(3)  This patch changes adds a parameter to try_to_migrate_pages().
     For other calls to try_to_migrate_pages() in the memory hotplug
     patch, the additional parameter may be passed in as NULL and
     the existing behavior will occur.  Later, I'll send out a
     patch updates the rest of the memory hotplug patch in accordance
     with this change.

(4)  system.migration extended attribute support should also be
     provided for other file systems.  This can be done incrementally.

(5)  As part of the discussion with Andi Kleen, we agreed to
     provide some memory migration support under MPOL_MF_STRICT.
     Currently, if one calls mbind() with the flag MPOL_MF_STRICT
     set, and pages are found that don't follow the memory policy,
     then the mbind() will return -EIO.  Andi would like to be
     able cause those pages to be migrated to the correct nodes.
     This feature is not yet part of this patchset and will
     probably be added as a distinct set of patches.

Description of the patches in this patchset
-------------------------------------------

Recall that all of these patches apply to 2.6.12-rc3 with the
following patch applied first:

http://sr71.net/patches/2.6.12/2.6.12-rc3-mhp1/patch-2.6.12-rc3-mhp1.gz

In addition, to get things to compile (for Altix), I applied:

http://sr71.net/patches/2.6.12/2.6.12-rc3-mhp1/broken-out/fudge-patch-2.patch

and manually added CONFIG_NEED_MULTIPLE_NODES=y to my .config file.

Patch 1: xfs_extended_attributes-rc2.patch
	 This patch, due to Nathan Scott at SGI, adds support to
	 XFS for the system.migration extended attribute.

Patch 2: xfs-migrate-page-rc2.patch
	 This patch, also due to Nathan Scott, provides a migrate_
	 page method for XFS.  EXT2 and EXT3 already have such methods.

Patch 3: add-node_map-arg-to-try_to_migrate_pages-rc2.patch
         This patch adds an additional argument to try_to_migrate_pages().
	 The additional argument controls where pages found on specific
	 nodes in the page_list passed into try_to_migrate_pages() are
	 migrated to.

Patch 4: add-sys_migrate_pages-rc2.patch
	 This is the patch that adds the migrate_pages() system call.
	 This patch provides is a simple version of the system call that
	 migrates all pages associated with a particular process, so
	 is really only useful for programs that are statically linked
	 (i. e. that don't map in any shared libraries).

Patch 5: sys_migrate_pages-xattr-support-rc2.patch
         This patch queries the system.migration extended attribute
	 associated with each mapped file.  The result of this query
	 is used to control which pages are migrated (e. g. if the
	 extended attribute has the value "libr", then it is assumed
	 the mapped file is a shared library, and shared pages are
	 not migrated.)

Patch 6: sys_migrate_pages-mempolicy-migration-rc2.patch
         This patch updates the memory policy data structures
	 as they are encountered in accordance with the migration
	 request.

Patch 7: sys_migrate_pages-cpuset-support.patch
         This patch makes migrate_pages() cooperate better with
	 cpusets.

Patch 8: sys_migrate_pages-permissions-check.patch
         This is the permissions check discussed earlier.

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
that does not support extended attributes (e. g. NFS), then the entire
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
