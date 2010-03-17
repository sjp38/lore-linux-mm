Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B133C6B013D
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:50:28 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 01/96] eclone (1/11): Factor out code to allocate pidmap page
Date: Wed, 17 Mar 2010 11:48:12 -0400
Message-Id: <1268840987-4400-2-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268840987-4400-1-git-send-email-orenl@cs.columbia.edu>
References: <1268840987-4400-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>

To simplify alloc_pidmap(), move code to allocate a pid map page to a
separate function.

Changelog[v4]:
	- [Oren Laadan] Adapt to kernel 2.6.33-rc5
Changelog[v3]:
	- Earlier version of patchset called alloc_pidmap_page() from two
	  places. But now its called from only one place. Even so, moving
	  this code out into a separate function simplifies alloc_pidmap().
Changelog[v2]:
	- (Matt Helsley, Dave Hansen) Have alloc_pidmap_page() return
	  -ENOMEM on error instead of -1.

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
Reviewed-by: Oren Laadan <orenl@cs.columbia.edu>
---
 kernel/pid.c |   41 ++++++++++++++++++++++++++---------------
 1 files changed, 26 insertions(+), 15 deletions(-)

diff --git a/kernel/pid.c b/kernel/pid.c
index 2e17c9c..39292e6 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -122,6 +122,30 @@ static void free_pidmap(struct upid *upid)
 	atomic_inc(&map->nr_free);
 }
 
+static int alloc_pidmap_page(struct pidmap *map)
+{
+	void *page;
+
+	if (likely(map->page))
+		return 0;
+
+	page = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	/*
+	 * Free the page if someone raced with us installing it:
+	 */
+	spin_lock_irq(&pidmap_lock);
+	if (!map->page) {
+		map->page = page;
+		page = NULL;
+	}
+	spin_unlock_irq(&pidmap_lock);
+	kfree(page);
+	if (unlikely(!map->page))
+		return -1;
+
+	return 0;
+}
+
 static int alloc_pidmap(struct pid_namespace *pid_ns)
 {
 	int i, offset, max_scan, pid, last = pid_ns->last_pid;
@@ -134,22 +158,9 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
 	max_scan = (pid_max + BITS_PER_PAGE - 1)/BITS_PER_PAGE - !offset;
 	for (i = 0; i <= max_scan; ++i) {
-		if (unlikely(!map->page)) {
-			void *page = kzalloc(PAGE_SIZE, GFP_KERNEL);
-			/*
-			 * Free the page if someone raced with us
-			 * installing it:
-			 */
-			spin_lock_irq(&pidmap_lock);
-			if (!map->page) {
-				map->page = page;
-				page = NULL;
-			}
-			spin_unlock_irq(&pidmap_lock);
-			kfree(page);
-			if (unlikely(!map->page))
+		if (unlikely(!map->page))
+			if (alloc_pidmap_page(map) < 0)
 				break;
-		}
 		if (likely(atomic_read(&map->nr_free))) {
 			do {
 				if (!test_and_set_bit(offset, map->page)) {
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
