Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3AC936B0071
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 11:32:14 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o1AGW99m010798
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 16:32:09 GMT
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by wpaz9.hot.corp.google.com with ESMTP id o1AGW72d012899
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 08:32:08 -0800
Received: by pzk33 with SMTP id 33so216600pzk.2
        for <linux-mm@kvack.org>; Wed, 10 Feb 2010 08:32:07 -0800 (PST)
Date: Wed, 10 Feb 2010 08:32:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 0/7 -mm] oom killer rewrite
Message-ID: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patchset is a rewrite of the out of memory killer to address several
issues that have been raised recently.  The most notable change is a
complete rewrite of the badness heuristic that determines which task is
killed; the goal was to make it as simple and predictable as possible
while still addressing issues that plague the VM.

This patchset is based on mmotm-2010-02-05-15-06 because of the following
dependencies:

	[patch 4/7] oom: badness heuristic rewrite:
		mm-count-swap-usage.patch

	[patch 5/7] oom: replace sysctls with quick mode:
		sysctl-clean-up-vm-related-variable-delcarations.patch

To apply to mainline, download 2.6.33-rc7 and apply

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
 Documentation/filesystems/proc.txt |   78 ++++---
 Documentation/sysctl/vm.txt        |   51 ++---
 fs/proc/base.c                     |   13 +-
 include/linux/mempolicy.h          |   13 +-
 include/linux/oom.h                |   18 +-
 kernel/sysctl.c                    |   15 +-
 mm/mempolicy.c                     |   39 +++
 mm/oom_kill.c                      |  455 +++++++++++++++++++-----------------
 mm/page_alloc.c                    |    3 +
 9 files changed, 383 insertions(+), 302 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
