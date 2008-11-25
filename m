Date: Tue, 25 Nov 2008 21:37:02 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 2/9] swapfile: remove SWP_ACTIVE mask
In-Reply-To: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
Message-ID: <Pine.LNX.4.64.0811252136180.17555@blonde.site>
References: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Remove the SWP_ACTIVE mask: it just obscures the SWP_WRITEOK flag.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 include/linux/swap.h |    1 -
 mm/swapfile.c        |    4 ++--
 2 files changed, 2 insertions(+), 3 deletions(-)

--- swapfile1/include/linux/swap.h	2008-11-24 13:27:00.000000000 +0000
+++ swapfile2/include/linux/swap.h	2008-11-25 12:41:19.000000000 +0000
@@ -120,7 +120,6 @@ struct swap_extent {
 enum {
 	SWP_USED	= (1 << 0),	/* is slot in swap_info[] used? */
 	SWP_WRITEOK	= (1 << 1),	/* ok to write to this swap?	*/
-	SWP_ACTIVE	= (SWP_USED | SWP_WRITEOK),
 					/* add others here before... */
 	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
 };
--- swapfile1/mm/swapfile.c	2008-11-25 12:41:17.000000000 +0000
+++ swapfile2/mm/swapfile.c	2008-11-25 12:41:19.000000000 +0000
@@ -1222,7 +1222,7 @@ asmlinkage long sys_swapoff(const char _
 	spin_lock(&swap_lock);
 	for (type = swap_list.head; type >= 0; type = swap_info[type].next) {
 		p = swap_info + type;
-		if ((p->flags & SWP_ACTIVE) == SWP_ACTIVE) {
+		if (p->flags & SWP_WRITEOK) {
 			if (p->swap_file->f_mapping == mapping)
 				break;
 		}
@@ -1665,7 +1665,7 @@ asmlinkage long sys_swapon(const char __
 	else
 		p->prio = --least_priority;
 	p->swap_map = swap_map;
-	p->flags = SWP_ACTIVE;
+	p->flags |= SWP_WRITEOK;
 	nr_swap_pages += nr_good_pages;
 	total_swap_pages += nr_good_pages;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
