Date: Mon, 14 Jul 2008 00:42:36 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH mm] mm: fix ever-decreasing swap priority
Message-ID: <Pine.LNX.4.64.0807140038540.30686@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Vegard Nossum <vegard.nossum@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Vegard Nossum has noticed the ever-decreasing negative priority in a swapon
/swapoff loop, which eventually would misprioritize when int wraps positive.
Not worth spending much code on, but probably better fixed.

It's easy to handle the swapping on and off of just one area, but there's
not much point if a pair or more still misbehave.  To handle the general
case, swapoff should compact negative priorities, keeping them always from
-1 to -MAX_SWAPFILES.  That's a change, but should cause no regression,
since these negative (unspecified) priorities are disjoint from the
the positive specified priorities 0 to 32767.

One small functional difference, which seems appropriate: when swapoff
fails to free all swap from a negative priority area, that area is now
reinserted at lowest priority, rather than at its original priority.

In moving down swapon's setting of priority, I notice that an area is
visible to /proc/swaps when it has swap_map set, yet that was being
set before all the visible fields were properly filled in: corrected.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
This one could go anywhere in the mm series, nothing worse than fuzz.

 mm/swapfile.c |   49 ++++++++++++++++++++++++------------------------
 1 file changed, 25 insertions(+), 24 deletions(-)

--- 2.6.26-rc9/mm/swapfile.c	2008-05-03 21:55:12.000000000 +0100
+++ linux/mm/swapfile.c	2008-07-11 17:25:41.000000000 +0100
@@ -37,6 +37,7 @@ DEFINE_SPINLOCK(swap_lock);
 unsigned int nr_swapfiles;
 long total_swap_pages;
 static int swap_overflow;
+static int least_priority;
 
 static const char Bad_file[] = "Bad swap file entry ";
 static const char Unused_file[] = "Unused swap file entry ";
@@ -1260,6 +1261,11 @@ asmlinkage long sys_swapoff(const char _
 		/* just pick something that's safe... */
 		swap_list.next = swap_list.head;
 	}
+	if (p->prio < 0) {
+		for (i = p->next; i >= 0; i = swap_info[i].next)
+			swap_info[i].prio = p->prio--;
+		least_priority++;
+	}
 	nr_swap_pages -= p->pages;
 	total_swap_pages -= p->pages;
 	p->flags &= ~SWP_WRITEOK;
@@ -1272,9 +1278,14 @@ asmlinkage long sys_swapoff(const char _
 	if (err) {
 		/* re-insert swap space back into swap_list */
 		spin_lock(&swap_lock);
-		for (prev = -1, i = swap_list.head; i >= 0; prev = i, i = swap_info[i].next)
+		if (p->prio < 0)
+			p->prio = --least_priority;
+		prev = -1;
+		for (i = swap_list.head; i >= 0; i = swap_info[i].next) {
 			if (p->prio >= swap_info[i].prio)
 				break;
+			prev = i;
+		}
 		p->next = i;
 		if (prev < 0)
 			swap_list.head = swap_list.next = p - swap_info;
@@ -1447,7 +1458,6 @@ asmlinkage long sys_swapon(const char __
 	unsigned int type;
 	int i, prev;
 	int error;
-	static int least_priority;
 	union swap_header *swap_header = NULL;
 	int swap_header_version;
 	unsigned int nr_good_pages = 0;
@@ -1455,7 +1465,7 @@ asmlinkage long sys_swapon(const char __
 	sector_t span;
 	unsigned long maxpages = 1;
 	int swapfilesize;
-	unsigned short *swap_map;
+	unsigned short *swap_map = NULL;
 	struct page *page = NULL;
 	struct inode *inode = NULL;
 	int did_down = 0;
@@ -1474,22 +1484,10 @@ asmlinkage long sys_swapon(const char __
 	}
 	if (type >= nr_swapfiles)
 		nr_swapfiles = type+1;
+	memset(p, 0, sizeof(*p));
 	INIT_LIST_HEAD(&p->extent_list);
 	p->flags = SWP_USED;
-	p->swap_file = NULL;
-	p->old_block_size = 0;
-	p->swap_map = NULL;
-	p->lowest_bit = 0;
-	p->highest_bit = 0;
-	p->cluster_nr = 0;
-	p->inuse_pages = 0;
 	p->next = -1;
-	if (swap_flags & SWAP_FLAG_PREFER) {
-		p->prio =
-		  (swap_flags & SWAP_FLAG_PRIO_MASK)>>SWAP_FLAG_PRIO_SHIFT;
-	} else {
-		p->prio = --least_priority;
-	}
 	spin_unlock(&swap_lock);
 	name = getname(specialfile);
 	error = PTR_ERR(name);
@@ -1632,19 +1630,20 @@ asmlinkage long sys_swapon(const char __
 			goto bad_swap;
 
 		/* OK, set up the swap map and apply the bad block list */
-		if (!(p->swap_map = vmalloc(maxpages * sizeof(short)))) {
+		swap_map = vmalloc(maxpages * sizeof(short));
+		if (!swap_map) {
 			error = -ENOMEM;
 			goto bad_swap;
 		}
 
 		error = 0;
-		memset(p->swap_map, 0, maxpages * sizeof(short));
+		memset(swap_map, 0, maxpages * sizeof(short));
 		for (i = 0; i < swap_header->info.nr_badpages; i++) {
 			int page_nr = swap_header->info.badpages[i];
 			if (page_nr <= 0 || page_nr >= swap_header->info.last_page)
 				error = -EINVAL;
 			else
-				p->swap_map[page_nr] = SWAP_MAP_BAD;
+				swap_map[page_nr] = SWAP_MAP_BAD;
 		}
 		nr_good_pages = swap_header->info.last_page -
 				swap_header->info.nr_badpages -
@@ -1654,7 +1653,7 @@ asmlinkage long sys_swapon(const char __
 	}
 
 	if (nr_good_pages) {
-		p->swap_map[0] = SWAP_MAP_BAD;
+		swap_map[0] = SWAP_MAP_BAD;
 		p->max = maxpages;
 		p->pages = nr_good_pages;
 		nr_extents = setup_swap_extents(p, &span);
@@ -1672,6 +1671,12 @@ asmlinkage long sys_swapon(const char __
 
 	mutex_lock(&swapon_mutex);
 	spin_lock(&swap_lock);
+	if (swap_flags & SWAP_FLAG_PREFER)
+		p->prio =
+		  (swap_flags & SWAP_FLAG_PRIO_MASK) >> SWAP_FLAG_PRIO_SHIFT;
+	else
+		p->prio = --least_priority;
+	p->swap_map = swap_map;
 	p->flags = SWP_ACTIVE;
 	nr_swap_pages += nr_good_pages;
 	total_swap_pages += nr_good_pages;
@@ -1707,12 +1712,8 @@ bad_swap:
 	destroy_swap_extents(p);
 bad_swap_2:
 	spin_lock(&swap_lock);
-	swap_map = p->swap_map;
 	p->swap_file = NULL;
-	p->swap_map = NULL;
 	p->flags = 0;
-	if (!(swap_flags & SWAP_FLAG_PREFER))
-		++least_priority;
 	spin_unlock(&swap_lock);
 	vfree(swap_map);
 	if (swap_file)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
