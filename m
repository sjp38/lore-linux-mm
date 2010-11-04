Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6A6B86B00B2
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 16:28:25 -0400 (EDT)
Date: Thu, 4 Nov 2010 21:17:27 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH v2] cgroup: prefer [kv]zalloc[_node] over [kv]malloc+memset
 in memory controller code.
Message-ID: <alpine.LNX.2.00.1011042104140.15349@swampdragon.chaosbits.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, containers@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,

In mem_cgroup_alloc() we currently do either kmalloc() or vmalloc() then 
followed by memset() to zero the memory. This can be more efficiently 
achieved by using kzalloc() and vzalloc().
There's also one situation where we can use kzalloc_node() - this is 
what's new in this version of the patch.

The original patch was:

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

Here's version 2. I'd appreciate it if someone could merge it, but I don't 
know who that someone would be.


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 memcontrol.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9a99cfa..4f4e676 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4169,13 +4169,11 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 	 */
 	if (!node_state(node, N_NORMAL_MEMORY))
 		tmp = -1;
-	pn = kmalloc_node(sizeof(*pn), GFP_KERNEL, tmp);
+	pn = kzalloc_node(sizeof(*pn), GFP_KERNEL, tmp);
 	if (!pn)
 		return 1;
 
 	mem->info.nodeinfo[node] = pn;
-	memset(pn, 0, sizeof(*pn));
-
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
 		for_each_lru(l)
@@ -4199,14 +4197,13 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 
 	/* Can be very big if MAX_NUMNODES is very big */
 	if (size < PAGE_SIZE)
-		mem = kmalloc(size, GFP_KERNEL);
+		mem = kzalloc(size, GFP_KERNEL);
 	else
-		mem = vmalloc(size);
+		mem = vzalloc(size);
 
 	if (!mem)
 		return NULL;
 
-	memset(mem, 0, size);
 	mem->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
 	if (!mem->stat) {
 		if (size < PAGE_SIZE)


-- 
Jesper Juhl <jj@chaosbits.net>             http://www.chaosbits.net/
Plain text mails only, please      http://www.expita.com/nomime.html
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
