Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 557D96B0024
	for <linux-mm@kvack.org>; Wed,  4 May 2011 16:26:41 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] Allocate memory cgroup structures in local nodes v2
Date: Wed,  4 May 2011 13:26:23 -0700
Message-Id: <1304540783-8247-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, rientjes@google.com, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>

From: Andi Kleen <ak@linux.intel.com>

[Andrew: since this is a regression and a very simple fix
could you still consider it for .39? Thanks]

dde79e005a769 added a regression that the memory cgroup data structures
all end up in node 0 because the first attempt at allocating them
would not pass in a node hint. Since the initialization runs on CPU #0
it would all end up node 0. This is a problem on large memory systems,
where node 0 would lose a lot of memory.

Change the alloc_pages_exact to alloc_pages_exact_node. This will
still fall back to other nodes if not enough memory is available.

[RED-PEN: right now it would fall back first before trying
vmalloc_node. Probably not the best strategy ... But I left it like
that for now.]

v2: Fix argument order. Thanks David Rientjes.
Reported-by: Doug Nelson
Cc: rientjes@google.com
CC: Michal Hocko <mhocko@suse.cz>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Balbir Singh <balbir@in.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/page_cgroup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 9905501..a362215 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -134,7 +134,7 @@ static void *__init_refok alloc_page_cgroup(size_t size, int nid)
 {
 	void *addr = NULL;
 
-	addr = alloc_pages_exact(size, GFP_KERNEL | __GFP_NOWARN);
+	addr = alloc_pages_exact_node(nid, GFP_KERNEL | __GFP_NOWARN, size);
 	if (addr)
 		return addr;
 
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
