Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C8461900114
	for <linux-mm@kvack.org>; Thu,  5 May 2011 15:46:33 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 2/2] Allocate memory cgroup structures in local nodes v3
Date: Thu,  5 May 2011 12:46:02 -0700
Message-Id: <1304624762-27960-2-git-send-email-andi@firstfloor.org>
In-Reply-To: <1304624762-27960-1-git-send-email-andi@firstfloor.org>
References: <1304624762-27960-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Andi Kleen <ak@linux.intel.com>, rientjes@google.com, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>

From: Andi Kleen <ak@linux.intel.com>

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

v3: Really call the correct function now. Thanks for everyone who commented.
Reported-by: Doug Nelson
Cc: rientjes@google.com
CC: Michal Hocko <mhocko@suse.cz>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Balbir Singh <balbir@in.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/page_alloc.c  |    4 ++--
 mm/page_cgroup.c |    6 ++++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5219dac..44e175d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2317,7 +2317,7 @@ void free_pages(unsigned long addr, unsigned int order)
 
 EXPORT_SYMBOL(free_pages);
 
-static void *make_alloc_exact(void *addr, unsigned order, size_t size)
+static void *make_alloc_exact(unsigned long addr, unsigned order, size_t size)
 {
 	if (addr) {
 		unsigned long alloc_end = addr + (PAGE_SIZE << order);
@@ -2371,7 +2371,7 @@ void *alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
 	struct page *p = alloc_pages_node(nid, gfp_mask, order);
 	if (!p)
 		return NULL;
-	return make_alloc_exact(page_address(p), order, size);
+	return make_alloc_exact((unsigned long)page_address(p), order, size);
 }
 EXPORT_SYMBOL(alloc_pages_exact_nid);
 
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 9905501..347ab60 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -134,9 +134,11 @@ static void *__init_refok alloc_page_cgroup(size_t size, int nid)
 {
 	void *addr = NULL;
 
-	addr = alloc_pages_exact(size, GFP_KERNEL | __GFP_NOWARN);
-	if (addr)
+	addr = alloc_pages_exact_nid(nid, size, GFP_KERNEL | __GFP_NOWARN);
+	if (addr) {
+		printk("%s: allocated exact\n", __FUNCTION__);
 		return addr;
+	}
 
 	if (node_state(nid, N_HIGH_MEMORY))
 		addr = vmalloc_node(size, nid);
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
