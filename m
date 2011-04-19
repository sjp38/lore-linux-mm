Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 896D48D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 19:37:52 -0400 (EDT)
Date: Wed, 20 Apr 2011 08:35:32 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH v2(resend)] memcg: update documentation to describe
 usage_in_bytes
Message-Id: <20110420083532.abd3ada5.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

resend the patch I sent in https://lkml.org/lkml/2011/3/28/560.

===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Since 569b846d(memcg: coalesce uncharge during unmap/truncate), we do batched
(delayed) uncharge at truncation/unmap. And since cdec2e42(memcg: coalesce
charging via percpu storage), we have percpu cache for res_counter.

These changes improved performance of memory cgroup very much, but made
res_counter->usage usually have a bigger value than the actual value of memory usage.
So, *.usage_in_bytes, which show res_counter->usage, are not desirable for precise
values of memory(and swap) usage anymore.

Instead of removing these files completely(because we cannot know res_counter->usage
without them), this patch updates the meaning of those files.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 Documentation/cgroups/memory.txt |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 7781857..4f49d91 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -52,8 +52,10 @@ Brief summary of control files.
  tasks				 # attach a task(thread) and show list of threads
  cgroup.procs			 # show list of processes
  cgroup.event_control		 # an interface for event_fd()
- memory.usage_in_bytes		 # show current memory(RSS+Cache) usage.
- memory.memsw.usage_in_bytes	 # show current memory+Swap usage
+ memory.usage_in_bytes		 # show current res_counter usage for memory
+				 (See 5.5 for details)
+ memory.memsw.usage_in_bytes	 # show current res_counter usage for memory+Swap
+				 (See 5.5 for details)
  memory.limit_in_bytes		 # set/show limit of memory usage
  memory.memsw.limit_in_bytes	 # set/show limit of memory+Swap usage
  memory.failcnt			 # show the number of memory usage hits limits
@@ -453,6 +455,15 @@ memory under it will be reclaimed.
 You can reset failcnt by writing 0 to failcnt file.
 # echo 0 > .../memory.failcnt
 
+5.5 usage_in_bytes
+
+For efficiency, as other kernel components, memory cgroup uses some optimization
+to avoid unnecessary cacheline false sharing. usage_in_bytes is affected by the
+method and doesn't show 'exact' value of memory(and swap) usage, it's an fuzz
+value for efficient access. (Of course, when necessary, it's synchronized.)
+If you want to know more exact memory usage, you should use RSS+CACHE(+SWAP)
+value in memory.stat(see 5.2).
+
 6. Hierarchy support
 
 The memory controller supports a deep hierarchy and hierarchical accounting.
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
