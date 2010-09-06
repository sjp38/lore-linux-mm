Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 018CA6B0047
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 04:10:57 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o868AqsW029274
	for <linux-mm@kvack.org>; Mon, 6 Sep 2010 01:10:52 -0700
Received: from iwn33 (iwn33.prod.google.com [10.241.68.97])
	by kpbe20.cbf.corp.google.com with ESMTP id o868ApCu022134
	for <linux-mm@kvack.org>; Mon, 6 Sep 2010 01:10:51 -0700
Received: by iwn33 with SMTP id 33so5397758iwn.14
        for <linux-mm@kvack.org>; Mon, 06 Sep 2010 01:10:51 -0700 (PDT)
Date: Mon, 6 Sep 2010 01:10:55 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/4] swap: revert special hibernation allocation
Message-ID: <alpine.LSU.2.00.1009060104410.13600@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Ondrej Zary <linux@rainbow-software.org>, Andrea Gelmini <andrea.gelmini@gmail.com>, Balbir Singh <balbir@in.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Nigel Cunningham <nigel@tuxonice.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Please revert 2.6.36-rc commit d2997b1042ec150616c1963b5e5e919ffd0b0ebf
"hibernation: freeze swap at hibernation".  It complicated matters by
adding a second swap allocation path, just for hibernation; without in
any way fixing the issue that it was intended to address - page reclaim
after fixing the hibernation image might free swap from a page already
imaged as swapcache, letting its swap be reallocated to store a different
page of the image: resulting in data corruption if the imaged page were
freed as clean then swapped back in.  Pages freed to si->swap_map were
still in danger of being reallocated by the alternative allocation path.

I guess it inadvertently fixed slow SSD swap allocation for hibernation,
as reported by Nigel Cunningham: by missing out the discards that occur
on the usual swap allocation path; but that was unintentional, and needs
a separate fix.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Ondrej Zary <linux@rainbow-software.org>
Cc: Andrea Gelmini <andrea.gelmini@gmail.com>
Cc: Balbir Singh <balbir@in.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Nigel Cunningham <nigel@tuxonice.net>
---

 include/linux/swap.h     |    8 ---
 kernel/power/hibernate.c |    1 
 kernel/power/snapshot.c  |    1 
 kernel/power/swap.c      |    6 +-
 mm/swapfile.c            |   94 ++++++++-----------------------------
 5 files changed, 26 insertions(+), 84 deletions(-)

--- 2.6.36-rc3/include/linux/swap.h	2010-08-16 00:17:59.000000000 -0700
+++ swap1/include/linux/swap.h	2010-09-05 22:37:07.000000000 -0700
@@ -315,6 +315,7 @@ extern long nr_swap_pages;
 extern long total_swap_pages;
 extern void si_swapinfo(struct sysinfo *);
 extern swp_entry_t get_swap_page(void);
+extern swp_entry_t get_swap_page_of_type(int);
 extern int valid_swaphandles(swp_entry_t, unsigned long *);
 extern int add_swap_count_continuation(swp_entry_t, gfp_t);
 extern void swap_shmem_alloc(swp_entry_t);
@@ -331,13 +332,6 @@ extern int reuse_swap_page(struct page *
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
 
-#ifdef CONFIG_HIBERNATION
-void hibernation_freeze_swap(void);
-void hibernation_thaw_swap(void);
-swp_entry_t get_swap_for_hibernation(int type);
-void swap_free_for_hibernation(swp_entry_t val);
-#endif
-
 /* linux/mm/thrash.c */
 extern struct mm_struct *swap_token_mm;
 extern void grab_swap_token(struct mm_struct *);
--- 2.6.36-rc3/kernel/power/hibernate.c	2010-08-16 00:18:00.000000000 -0700
+++ swap1/kernel/power/hibernate.c	2010-09-05 22:37:07.000000000 -0700
@@ -338,7 +338,6 @@ int hibernation_snapshot(int platform_mo
 		goto Close;
 
 	suspend_console();
-	hibernation_freeze_swap();
 	saved_mask = clear_gfp_allowed_mask(GFP_IOFS);
 	error = dpm_suspend_start(PMSG_FREEZE);
 	if (error)
--- 2.6.36-rc3/kernel/power/snapshot.c	2010-08-16 00:18:00.000000000 -0700
+++ swap1/kernel/power/snapshot.c	2010-09-05 22:37:07.000000000 -0700
@@ -1086,7 +1086,6 @@ void swsusp_free(void)
 	buffer = NULL;
 	alloc_normal = 0;
 	alloc_highmem = 0;
-	hibernation_thaw_swap();
 }
 
 /* Helper functions used for the shrinking of memory. */
--- 2.6.36-rc3/kernel/power/swap.c	2010-08-16 00:18:00.000000000 -0700
+++ swap1/kernel/power/swap.c	2010-09-05 22:37:07.000000000 -0700
@@ -136,10 +136,10 @@ sector_t alloc_swapdev_block(int swap)
 {
 	unsigned long offset;
 
-	offset = swp_offset(get_swap_for_hibernation(swap));
+	offset = swp_offset(get_swap_page_of_type(swap));
 	if (offset) {
 		if (swsusp_extents_insert(offset))
-			swap_free_for_hibernation(swp_entry(swap, offset));
+			swap_free(swp_entry(swap, offset));
 		else
 			return swapdev_block(swap, offset);
 	}
@@ -163,7 +163,7 @@ void free_all_swap_pages(int swap)
 		ext = container_of(node, struct swsusp_extent, node);
 		rb_erase(node, &swsusp_extents);
 		for (offset = ext->start; offset <= ext->end; offset++)
-			swap_free_for_hibernation(swp_entry(swap, offset));
+			swap_free(swp_entry(swap, offset));
 
 		kfree(ext);
 	}
--- 2.6.36-rc3/mm/swapfile.c	2010-08-16 00:18:01.000000000 -0700
+++ swap1/mm/swapfile.c	2010-09-05 22:37:07.000000000 -0700
@@ -47,8 +47,6 @@ long nr_swap_pages;
 long total_swap_pages;
 static int least_priority;
 
-static bool swap_for_hibernation;
-
 static const char Bad_file[] = "Bad swap file entry ";
 static const char Unused_file[] = "Unused swap file entry ";
 static const char Bad_offset[] = "Bad swap offset entry ";
@@ -453,8 +451,6 @@ swp_entry_t get_swap_page(void)
 	spin_lock(&swap_lock);
 	if (nr_swap_pages <= 0)
 		goto noswap;
-	if (swap_for_hibernation)
-		goto noswap;
 	nr_swap_pages--;
 
 	for (type = swap_list.next; type >= 0 && wrapped < 2; type = next) {
@@ -487,6 +483,28 @@ noswap:
 	return (swp_entry_t) {0};
 }
 
+/* The only caller of this function is now susupend routine */
+swp_entry_t get_swap_page_of_type(int type)
+{
+	struct swap_info_struct *si;
+	pgoff_t offset;
+
+	spin_lock(&swap_lock);
+	si = swap_info[type];
+	if (si && (si->flags & SWP_WRITEOK)) {
+		nr_swap_pages--;
+		/* This is called for allocating swap entry, not cache */
+		offset = scan_swap_map(si, 1);
+		if (offset) {
+			spin_unlock(&swap_lock);
+			return swp_entry(type, offset);
+		}
+		nr_swap_pages++;
+	}
+	spin_unlock(&swap_lock);
+	return (swp_entry_t) {0};
+}
+
 static struct swap_info_struct *swap_info_get(swp_entry_t entry)
 {
 	struct swap_info_struct *p;
@@ -746,74 +764,6 @@ int mem_cgroup_count_swap_user(swp_entry
 #endif
 
 #ifdef CONFIG_HIBERNATION
-
-static pgoff_t hibernation_offset[MAX_SWAPFILES];
-/*
- * Once hibernation starts to use swap, we freeze swap_map[]. Otherwise,
- * saved swap_map[] image to the disk will be an incomplete because it's
- * changing without synchronization with hibernation snap shot.
- * At resume, we just make swap_for_hibernation=false. We can forget
- * used maps easily.
- */
-void hibernation_freeze_swap(void)
-{
-	int i;
-
-	spin_lock(&swap_lock);
-
-	printk(KERN_INFO "PM: Freeze Swap\n");
-	swap_for_hibernation = true;
-	for (i = 0; i < MAX_SWAPFILES; i++)
-		hibernation_offset[i] = 1;
-	spin_unlock(&swap_lock);
-}
-
-void hibernation_thaw_swap(void)
-{
-	spin_lock(&swap_lock);
-	if (swap_for_hibernation) {
-		printk(KERN_INFO "PM: Thaw Swap\n");
-		swap_for_hibernation = false;
-	}
-	spin_unlock(&swap_lock);
-}
-
-/*
- * Because updateing swap_map[] can make not-saved-status-change,
- * we use our own easy allocator.
- * Please see kernel/power/swap.c, Used swaps are recorded into
- * RB-tree.
- */
-swp_entry_t get_swap_for_hibernation(int type)
-{
-	pgoff_t off;
-	swp_entry_t val = {0};
-	struct swap_info_struct *si;
-
-	spin_lock(&swap_lock);
-
-	si = swap_info[type];
-	if (!si || !(si->flags & SWP_WRITEOK))
-		goto done;
-
-	for (off = hibernation_offset[type]; off < si->max; ++off) {
-		if (!si->swap_map[off])
-			break;
-	}
-	if (off < si->max) {
-		val = swp_entry(type, off);
-		hibernation_offset[type] = off + 1;
-	}
-done:
-	spin_unlock(&swap_lock);
-	return val;
-}
-
-void swap_free_for_hibernation(swp_entry_t ent)
-{
-	/* Nothing to do */
-}
-
 /*
  * Find the swap type that corresponds to given device (if any).
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
