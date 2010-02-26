Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E9EE86B0047
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 18:53:09 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o1QNr1g4014378
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 23:53:02 GMT
Received: from pxi11 (pxi11.prod.google.com [10.243.27.11])
	by wpaz24.hot.corp.google.com with ESMTP id o1QNqckF011958
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:53:00 -0800
Received: by pxi11 with SMTP id 11so238751pxi.15
        for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:53:00 -0800 (PST)
Date: Fri, 26 Feb 2010 15:52:56 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm v2 00/10] oom killer rewrite
Message-ID: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patchset is a rewrite of the out of memory killer to address several
issues that have been raised recently.  The most notable change is a
complete rewrite of the badness heuristic that determines which task is
killed; the goal was to make it as simple and predictable as possible
while still addressing issues that plague the VM.

Changes from version 2:

 - updated to 2.6.33, no longer based on mmotm

 - removed "oom: remove compulsory panic_on_oom mode"

 - mempolicy detachment is now protected by task_lock(); otherwise, it is
   possible for a mempolicy to be freed out from under code that is using
   it.  This isn't necessary for current->mempolicy, but all other tasks
   require it.

 - tasks that have mempolicies of MPOL_PREFERED (or MPOL_F_LOCAL) are now
   always considered for oom kill when it is mempolicy constrained since
   they may allocate elsewhere as fallback when their preferred (or local)
   node is oom.

 - lowmem allocations that are __GFP_NOFAIL are now retried in the page
   allocator instead of returning NULL.

 - added: [patch 4/10] oom: remove special handling for pagefault ooms

 - added: [patch 10/10] oom: default to killing current for pagefault ooms

This patchset has two dependencies from the -mm tree:

	[patch 5/10] oom: badness heuristic rewrite:
		mm-count-swap-usage.patch

	[patch 7/10] oom: replace sysctls with quick mode:
		sysctl-clean-up-vm-related-variable-delcarations.patch

To apply to mainline, download 2.6.33 and apply

	mm-clean-up-mm_counter.patch
	mm-avoid-false-sharing-of-mm_counter.patch
	mm-avoid-false-sharing-of-mm_counter-checkpatch-fixes.patch
	mm-count-swap-usage.patch
	mm-count-swap-usage-checkpatch-fixes.patch
	mm-introduce-dump_page-and-print-symbolic-flag-names.patch
	sysctl-clean-up-vm-related-variable-declarations.patch
	sysctl-clean-up-vm-related-variable-declarations-fix.patch

from http://userweb.kernel.org/~akpm/mmotm/broken-out.tar.gz first.

This patchset is also available for each kernel release from:

	http://www.kernel.org/pub/linux/kernel/people/rientjes/oom-killer-rewrite/

including broken out patches and the prerequisite patches listed above.
---
 Documentation/feature-removal-schedule.txt |   30 +
 Documentation/filesystems/proc.txt         |  100 +++--
 Documentation/sysctl/vm.txt                |   51 +-
 fs/proc/base.c                             |  106 +++++
 include/linux/memcontrol.h                 |   14 
 include/linux/mempolicy.h                  |   13 
 include/linux/oom.h                        |   24 +
 include/linux/sched.h                      |    3 
 kernel/exit.c                              |    8 
 kernel/fork.c                              |    1 
 kernel/sysctl.c                            |   15 
 mm/memcontrol.c                            |   43 --
 mm/mempolicy.c                             |   44 ++
 mm/oom_kill.c                              |  572 +++++++++++++++--------------
 mm/page_alloc.c                            |   29 +
 15 files changed, 653 insertions(+), 400 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
