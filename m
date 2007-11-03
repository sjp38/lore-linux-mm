Date: Sat, 3 Nov 2007 19:04:46 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC PATCH 9/10] split VM and memory controllers
Message-ID: <20071103190446.722dffa3@bree.surriel.com>
In-Reply-To: <20071103184229.3f20e2f0@bree.surriel.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The memory controller code is still quite simple, so don't do
anything fancy for now trying to make it work better with the
split VM code.

Will be merged into 6/10 soon.

Signed-off-by: Rik van Riel <riel@redhat.com>

Index: linux-2.6.23-mm1/mm/memcontrol.c
===================================================================
--- linux-2.6.23-mm1.orig/mm/memcontrol.c
+++ linux-2.6.23-mm1/mm/memcontrol.c
@@ -210,7 +210,6 @@ unsigned long mem_cgroup_isolate_pages(u
 	struct list_head *src;
 	struct page_cgroup *pc;
 
-//TODO:  memory container maintain separate file/anon lists?
 	if (active)
 		src = &mem_cont->active_list;
 	else
@@ -222,6 +221,9 @@ unsigned long mem_cgroup_isolate_pages(u
 		page = pc->page;
 		VM_BUG_ON(!pc);
 
+		/*
+		 * TODO: play better with lumpy reclaim, grabbing anything.
+		 */
 		if (PageActive(page) && !active) {
 			__mem_cgroup_move_lists(pc, true);
 			scan--;
@@ -240,6 +242,9 @@ unsigned long mem_cgroup_isolate_pages(u
 		if (page_zone(page) != z)
 			continue;
 
+		if (file != !!page_file_cache(page))
+			continue;
+
 		/*
 		 * Check if the meta page went away from under us
 		 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
