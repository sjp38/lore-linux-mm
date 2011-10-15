Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 34A6C6B0184
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 20:39:05 -0400 (EDT)
From: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Subject: [RFC] [PATCH 4/4] memcg: Document kernel memory accounting.
Date: Fri, 14 Oct 2011 17:38:30 -0700
Message-Id: <1318639110-27714-5-git-send-email-ssouhlal@FreeBSD.org>
In-Reply-To: <1318639110-27714-4-git-send-email-ssouhlal@FreeBSD.org>
References: <1318639110-27714-1-git-send-email-ssouhlal@FreeBSD.org>
 <1318639110-27714-2-git-send-email-ssouhlal@FreeBSD.org>
 <1318639110-27714-3-git-send-email-ssouhlal@FreeBSD.org>
 <1318639110-27714-4-git-send-email-ssouhlal@FreeBSD.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: glommer@parallels.com
Cc: gthelen@google.com, yinghan@google.com, kamezawa.hiroyu@jp.fujitsu.com, jbottomley@parallels.com, suleiman@google.com, linux-mm@kvack.org, Suleiman Souhlal <ssouhlal@FreeBSD.org>

Signed-off-by: Suleiman Souhlal <suleiman@google.com>
---
 Documentation/cgroups/memory.txt |   33 ++++++++++++++++++++++++++++++++-
 1 files changed, 32 insertions(+), 1 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 06eb6d9..277cf25 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -220,7 +220,37 @@ caches are dropped. But as mentioned above, global LRU can do swapout memory
 from it for sanity of the system's memory management state. You can't forbid
 it by cgroup.
 
-2.5 Reclaim
+2.5 Kernel Memory
+
+A cgroup's kernel memory is accounted into its memory.usage_in_bytes and
+is also shown in memory.stat as kernel_memory. Kernel memory does not get
+counted towards the root cgroup's memory.usage_in_bytes, but still
+appears in its kernel_memory.
+
+Upon cgroup deletion, all the remaining kernel memory gets moved to the
+root cgroup.
+
+An accounted kernel memory allocation may trigger reclaim in that cgroup,
+and may also OOM.
+
+Currently only slab memory allocated without __GFP_NOACCOUNT and
+__GFP_NOFAIL gets accounted to the current process' cgroup.
+
+2.5.1 Slab
+
+Slab gets accounted on a per-page basis, which is done by using per-cgroup
+kmem_caches. These per-cgroup kmem_caches get created on-demand, the first
+time a specific kmem_cache gets used by a cgroup.
+
+Slab memory that cannot be attributed to a cgroup gets charged to the root
+cgroup.
+
+A per-cgroup kmem_cache is named like the original, with the cgroup's name
+in parethesis.
+When a kmem_cache gets migrated to the root cgroup, "dead" is appended to
+its name, to indicated that it is not going to be used for new allocations.
+
+2.6 Reclaim
 
 Each cgroup maintains a per cgroup LRU which has the same structure as
 global VM. When a cgroup goes over its limit, we first try
@@ -396,6 +426,7 @@ active_anon	- # of bytes of anonymous and swap cache memory on active
 inactive_file	- # of bytes of file-backed memory on inactive LRU list.
 active_file	- # of bytes of file-backed memory on active LRU list.
 unevictable	- # of bytes of memory that cannot be reclaimed (mlocked etc).
+kernel_memory   - # of bytes of kernel memory.
 
 # status considering hierarchy (see memory.use_hierarchy settings)
 
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
