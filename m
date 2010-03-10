Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 21C316B008A
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 05:41:24 -0500 (EST)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id o2AAfJB9006182
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 10:41:20 GMT
Received: from pzk29 (pzk29.prod.google.com [10.243.19.157])
	by spaceape10.eur.corp.google.com with ESMTP id o2AAfFuG018374
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 02:41:17 -0800
Received: by pzk29 with SMTP id 29so4808638pzk.27
        for <linux-mm@kvack.org>; Wed, 10 Mar 2010 02:41:15 -0800 (PST)
Date: Wed, 10 Mar 2010 02:41:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 00/10 -mm v3] oom killer rewrite
Message-ID: <alpine.DEB.2.00.1003100236510.30013@chino.kir.corp.google.com>
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

 - updated to mmotm-2010-03-09-19-15

 - schedule a timeout for current if it was not selected for oom kill
   when it has returned VM_FAULT_OOM so memory can freed to prevent
   needlessly recalling the oom killer and looping.

To apply, download the -mm tree from
http://userweb.kernel.org/~akpm/mmotm/broken-out.tar.gz first.

This patchset is also available for each kernel release from:

	http://www.kernel.org/pub/linux/kernel/people/rientjes/oom-killer-rewrite/

including broken out patches.
---
 Documentation/feature-removal-schedule.txt |   30 +
 Documentation/filesystems/proc.txt         |  100 +++--
 Documentation/sysctl/vm.txt                |   51 +-
 fs/proc/base.c                             |  106 +++++
 include/linux/memcontrol.h                 |    8 
 include/linux/mempolicy.h                  |   13 
 include/linux/oom.h                        |   24 +
 include/linux/sched.h                      |    3 
 kernel/exit.c                              |    8 
 kernel/fork.c                              |    1 
 kernel/sysctl.c                            |   15 
 mm/memcontrol.c                            |    8 
 mm/mempolicy.c                             |   44 ++
 mm/oom_kill.c                              |  567 +++++++++++++++--------------
 mm/page_alloc.c                            |   29 +
 15 files changed, 655 insertions(+), 352 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
