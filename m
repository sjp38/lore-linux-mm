Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 008C46B0180
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 20:39:02 -0400 (EDT)
From: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Subject: [RFC] [PATCH 0/4] memcg: Kernel memory accounting.
Date: Fri, 14 Oct 2011 17:38:26 -0700
Message-Id: <1318639110-27714-1-git-send-email-ssouhlal@FreeBSD.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: glommer@parallels.com
Cc: gthelen@google.com, yinghan@google.com, kamezawa.hiroyu@jp.fujitsu.com, jbottomley@parallels.com, suleiman@google.com, linux-mm@kvack.org, Suleiman Souhlal <ssouhlal@FreeBSD.org>

This patch series introduces kernel memory accounting to memcg.
It currently only accounts for slab.

With this, kernel memory gets counted in a memcg's usage_in_bytes.

Slab gets accounted per-page, by using per-cgroup kmem_caches that
get created the first time an allocation of that type is done by
that cgroup.
This means that we only have to do charges/uncharges in the slow
path of the slab allocator, which should have low performance
impacts.

A per-cgroup kmem_cache will appear in slabinfo named like its
original cache, with the cgroup's name in parenthesis.
On cgroup deletion, the accounting gets moved to the root cgroup
and any existing cgroup kmem_cache gets "dead" appended to its
name, to indicate that its accounting was migrated.

TODO:
	- Per-memcg slab shrinking (we have patches for that already).
	- Make it support the other slab allocators.
	- Come up with a scheme that does not require holding
	  rcu_read_lock in the whole slab allocation path.
	- Account for other types of kernel memory than slab.
	- Migrate to the parent cgroup instead of root on cgroup
	  deletion.

---
 Documentation/cgroups/memory.txt |   33 +++
 include/linux/gfp.h              |    2 
 include/linux/memcontrol.h       |   35 +++
 include/linux/slab.h             |    1 
 include/linux/slab_def.h         |   47 ++++
 init/Kconfig                     |   10 -
 mm/memcontrol.c                  |  373 ++++++++++++++++++++++++++++++++++++++-
 mm/slab.c                        |  284 +++++++++++++++++++++++++++--
 8 files changed, 755 insertions(+), 30 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
