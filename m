Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by omx3.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j61NFZJP017876
	for <linux-mm@kvack.org>; Fri, 1 Jul 2005 16:15:35 -0700
Date: Fri, 1 Jul 2005 15:40:38 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050701224038.542.60558.44109@jackhammer.engr.sgi.com>
Subject: [PATCH 2.6.13-rc1 0/11] mm: manual page migration-rc4 -- overview
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>, Paul Jackson <pj@sgi.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Summary
-------

This is the -rc4 version of the manual page migration facility
that I proposed in February and that was discussed on the
linux-mm mailing list.  This overview is relatively short since
the overview is effectively unchanged from what I submitted on
April 6, 2005.  For details, see the overview I sent out then at:

http://marc.theaimsgroup.com/?l=linux-mm&m=111276123522952&w=2

For details of the -rc2 version of this patcheset, see:

http://marc.theaimsgroup.com/?l=linux-mm&m=111578651020174&w=2

And the -rc3 version is at:

http://marc.theaimsgroup.com/?l=linux-mm&m=111945947315561&w=2

This patch set differs from the previous patchset in the following:

(1)  The previous patch was based on 2.6.12-rc5-mhp1, this patchset
     is based on patch-2.6.13-rc1-mhp1-pm.gz from www.sr71.net/patches/
     2.6.12 (of the Memory Hotplug project patchset maintained by
     Dave Hansen).

(2)  Changes suggested by Dave Hansen, Hirokazu Takahashi, and
     Andi Kleen have been incorporated into this patchset.

If this patch is acceptable to the Memory Hotplug Team, I'd like
to see it added to the page migration sequence of patches in
the memory hotplug patch.

This patch adds a parameter to try_to_migrate_pages().
The last patch of this series:

N1.2-add-nodemap-to-try_to_migrate_pages-call.patch

Should be inserted in the memory hotplug patcheset after the
patch:  N1.1-pass-page_list-to-steal_page.patch to fixup
the call to try_to_migrate_pages() from capture_page_range()
in mm/page_alloc.c.

This is the last version of the manual page migration patch
that I will be providing.  As of today, Christoph Lameter
(clameter@sgi.com), will be responsible for handling this
patchset from an SGI perspective.

Suggestions, flames, etc should be directed to Christoph
at clameter@sgi.com.  I can also continue to be reached
at raybry@austin.rr.com for discussion of this patchset.

Description of the patches in this patchset
-------------------------------------------

Recall that all of these patches apply to 2.6.13-rc1 with the
page-migration patches applied first.  The simplest way to do
this is to obtain the Memory Hotplug broken out patches from

http://sr71.net/patches/2.6.12/2.6.12-rc5-mhp1/broken-out-2.6.12-rc5-mhp1.tar.gz

And then to add patches 1-10 of this patchset to the series file
after the patch "AA-PM-99-x86_64-IMMOVABLE.patch".  (Patch 11
goes after N1.1-pass-page_list-to-steal_page.patch.) Then apply all
patches up through the 10th patch of this set and turn on the
CONFIG_MEMORY_MIGRATE option.  This works on Altix, at least;
that is the only NUMA machine I have access to at the moment.

The 11th patch is only needed if you want to try to build the
entire mhp1 patchset after applying the manual page migration
patches.

Patch 1: hirokazu-steal_page_from_lru.patch
	 This patch (due to Hirokazu Tokahashi) simplifies the interface
	 to steal_page_from_lru() and is not yet present in the 2.6.12-rc5-mhp1
	 patchset.  Unchanged since -rc3.

Patch 2: xfs-migrate-page-rc4.patch
	 This patch, due to Nathan Scott at SGI, provides a migrate_
	 page method for XFS.  EXT2 and EXT3 already have such methods.
	 Unchanged from -rc3.

Patch 3: add-node_map-arg-to-try_to_migrate_pages-rc4.patch
         This patch adds an additional argument to try_to_migrate_pages().
	 The additional argument controls where pages found on specific
	 nodes in the page_list passed into try_to_migrate_pages() are
	 migrated to.  Unchanged from -rc3.

Patch 4: add-sys_migrate_pages-rc4.patch
	 This is the patch that adds the migrate_pages() system call.
	 This patch provides a simple version of the system call that
	 migrates all pages associated with a particular process, so
	 is really only useful for programs that are statically linked
	 (i. e. that don't map in any shared libraries).

	 The following changes have been made since -rc3:

	 	Suggestions from Dave Hansen and Hirokazu Takahashi
		have been incorporated.

Patch 5: sys_migrate_pages-mempolicy-migration-rc4.patch
         This patch updates the memory policy data structures
	 as they are encountered in accordance with the migration
	 request.  Unchanged from -rc3.

Patch 6: This patch is new in -rc4.  This patch fixes a problem
         with the mempolicy migration code for shared objects.
	 Andi Kleen pointed out this problem in -rc3.

Patch 7: add-mempolicy-control-rc4.patch
	 This patch extends the mbind() and get_mempolicy() system
	 calls to support the interface to override the default
	 kernel policy.  Unchanged from -rc3.

Patch 8: sys_migrate_pages-migration-selection-rc4.patch
	 This patch uses the migration policy bits set by the code
	 from the last patch to control which mapped files are
	 migrated (or not).  Unchanged from -rc3.

Patch 9: sys_migrate_pages-cpuset-support-rc4.patch
         This patch makes migrate_pages() cooperate better with
	 cpusets.  The following change has been made since -rc3:

		 The cpuset support has been split out entirely
		 to kernel/cpuset.c with only a single callout
		 from sys_migrate_pages().  This makes the 
		 sys_migrate_pages() code cleaner.  This change
		 was inspired by the changes Dave Hansen
		 suggested.

Patch 10: sys_migrate_pages-permissions-check.patch
         This patch adds a permission check to make sure the
	 invoking process has the necessary permissions to migrate
	 the target task.  Unchanged from -rc3.

Patch 11:N1.2-add-nodemap-to-try_to_migrate_pages-call.patch
	 This patch fixes the call to try_to_migrate_pages()
	 from capture_page_range() in mm/page_alloc.c that
	 is introduced in the N1.0-memsection_migrate.patch
	 of the memory hotplug series.  Unchanged from -rc3.


Unresolved issues
-----------------

(1)  This version of migrate_pages() works reliably only when the
     process to be migrated has been stopped (e. g., using SIGSTOP)
     before the migrate_pages() system call is executed. 
     (The system doesn't crash or oops, but sometimes the process
     being migrated will be "Killed by VM" when it starts up again.
     There may be a few messages put into the log as well at that time.)

     At the moment, I am proposing that processes need to be
     suspended before being migrated.  This really should not
     be a performance concern, since the delay imposed by page
     migration far exceeds any delay imposed by SIGSTOPing the
     processes before migration and SIGCONTinuing them afterward.

     The problem with this approach is that there is no good way
     to enforce this.  (i. e. even if the process is stopped at
     the start execution of the migrate_pages() system call,
     there is no way to ensure it doesn't get started during
     execution of the call.)

     Christoph Lameter has some ideas about using PF_FREEZE to handle
     this problem.  I will leave further work in this area to
     Christoph.  I have provided some sample code to Christoph
     to indicate one way to integrate his approach into the existing
     page migration code.

(2)  I'm still using system call #1279.  On ia64 this is the
     last slot in the system call table.  A system call number
     needs to be assigned to migrate_pages().

(3)  As part of the discussion with Andi Kleen, we agreed to
     provide some memory migration support under MPOL_MF_STRICT.
     Currently, if one calls mbind() with the flag MPOL_MF_STRICT
     set, and pages are found that don't follow the memory policy,
     then the mbind() will return -EIO.  Andi would like to be
     able cause those pages to be migrated to the correct nodes.
     This feature is not yet part of this patchset and will
     be added as a distinct set of patches.  I'm planning on
     providing some sample code to Christoph indicating how
     this might be done in the future.

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
As discussed above, the kernel code handles this by migrating all
anonymous VMAs and all VMAs with the VM_WRITE bit set.  VMAs that map
the code segments of a program don't have VM_WRITE set, so shared
library code segments will not be migrated (by default).  Read-only mapped
files (e. g. files in /usr/lib for National Language support) are also
not migrated by default.

The default migration decisions of the kernel migration code can be
overridden for mmap()'d files using the extensions provided for the
mbind() system call, as described in patches 7 and 8 above.  This call
can be used, for example, to cause the program executable to be migrated.
Similarly, if the user has a (non-system) data file mapped R/O, the
mbind() system call can be used to override the kernel default and cause
the mapped file to be migrated as well.

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
