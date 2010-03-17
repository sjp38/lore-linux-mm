Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 41D8860023A
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 04:55:29 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o2H8tPBd029490
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 01:55:26 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by wpaz5.hot.corp.google.com with ESMTP id o2H8tOX8008984
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 01:55:24 -0700
Received: by pzk36 with SMTP id 36so558785pzk.8
        for <linux-mm@kvack.org>; Wed, 17 Mar 2010 01:55:24 -0700 (PDT)
Date: Wed, 17 Mar 2010 01:55:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 00/11 -mm v4] oom killer rewrite
Message-ID: <alpine.DEB.2.00.1003170151540.31796@chino.kir.corp.google.com>
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

Changes for version 4:

 - updated to mmotm-2010-03-11-13-13

 - rewrote mem_cgroup_get_limit() to respect swapless systems or those
   where users have not configured a swap limit (suggested by KAMEZAWA
   Hiroyuki).

 - added: [patch 11/11] oom: avoid race for oom killed tasks detaching mm
			prior to exit

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
 include/linux/oom.h                        |   20 -
 include/linux/sched.h                      |    3 
 kernel/exit.c                              |    8 
 kernel/fork.c                              |    1 
 kernel/sysctl.c                            |   19 
 mm/memcontrol.c                            |   18 
 mm/mempolicy.c                             |   44 ++
 mm/oom_kill.c                              |  579 +++++++++++++++--------------
 mm/page_alloc.c                            |   29 +
 15 files changed, 671 insertions(+), 358 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
