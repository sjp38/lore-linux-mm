Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8365B6B0083
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:19:56 -0500 (EST)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id o1FMK20X003195
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 14:20:03 -0800
Received: from pzk41 (pzk41.prod.google.com [10.243.19.169])
	by spaceape14.eur.corp.google.com with ESMTP id o1FMK0ke020029
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 14:20:00 -0800
Received: by pzk41 with SMTP id 41so9919187pzk.0
        for <linux-mm@kvack.org>; Mon, 15 Feb 2010 14:19:59 -0800 (PST)
Date: Mon, 15 Feb 2010 14:19:57 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 0/9 v2] oom killer rewrite
Message-ID: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patchset is a rewrite of the out of memory killer to address several
issues that have been raised recently.  The most notable change is a
complete rewrite of the badness heuristic that determines which task is
killed; the goal was to make it as simple and predictable as possible
while still addressing issues that plague the VM.

Changes from version 1:

 - updated to mmotm-2010-02-11-21-55

 - when iterating the tasklist for mempolicy-constrained oom conditions,
   the node of the cpu that a MPOL_F_LOCAL task is running on is now
   intersected with the page allocator's nodemask to determine whether it
   should be a candidate for oom kill.

 - added: [patch 4/9] oom: remove compulsory panic_on_oom mode

 - /proc/pid/oom_score_adj was added to prevent ABI breakage for
   applications using /proc/pid/oom_adj.  /proc/pid/oom_adj may still be
   used with the old range but it is then scaled to oom_score_adj units
   for a rough linear approximation.  There is no loss in functionality
   from the old interface.

 - added: [patch 6/9] oom: deprecate oom_adj tunable

This patchset is based on mmotm-2010-02-11-21-55 because of the following
dependencies:

	[patch 5/9] oom: badness heuristic rewrite:
		mm-count-swap-usage.patch

	[patch 7/9] oom: replace sysctls with quick mode:
		sysctl-clean-up-vm-related-variable-delcarations.patch

To apply to mainline, download 2.6.33-rc8 and apply

	mm-clean-up-mm_counter.patch
	mm-avoid-false-sharing-of-mm_counter.patch
	mm-avoid-false_sharing-of-mm_counter-checkpatch-fixes.patch
	mm-count-swap-usage.patch
	mm-count-swap-usage-checkpatch-fixes.patch
	mm-introduce-dump_page-and-print-symbolic-flag-names.patch
	sysctl-clean-up-vm-related-variable-declarations.patch
	sysctl-clean-up-vm-related-variable-declarations-fix.patch

from http://userweb.kernel.org/~akpm/mmotm/broken-out.tar.gz first.
---
 Documentation/feature-removal-schedule.txt |   30 +
 Documentation/filesystems/proc.txt         |  100 +++---
 Documentation/sysctl/vm.txt                |   71 +---
 fs/proc/base.c                             |  106 ++++++
 include/linux/mempolicy.h                  |   13 
 include/linux/oom.h                        |   24 +
 include/linux/sched.h                      |    3 
 kernel/fork.c                              |    1 
 kernel/sysctl.c                            |   15 
 mm/mempolicy.c                             |   39 ++
 mm/oom_kill.c                              |  479 ++++++++++++++---------------
 mm/page_alloc.c                            |    3 
 12 files changed, 553 insertions(+), 331 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
