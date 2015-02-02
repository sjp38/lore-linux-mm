Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 395A16B0070
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 11:28:10 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id wp4so3398293obc.10
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 08:28:09 -0800 (PST)
Received: from smtp108.ord1c.emailsrvr.com (smtp108.ord1c.emailsrvr.com. [108.166.43.108])
        by mx.google.com with ESMTPS id o127si9477067oia.109.2015.02.02.08.28.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 08:28:09 -0800 (PST)
From: pasi.sjoholm@jolla.com
Subject: [PATCH] mm/swapfile.c: use spin_lock_bh with swap_lock to avoid deadlocks
Date: Mon,  2 Feb 2015 18:25:28 +0200
Message-Id: <1422894328-23051-1-git-send-email-pasi.sjoholm@jolla.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?Pasi=20Sj=C3=B6holm?= <pasi.sjoholm@jollamobile.com>

From: Pasi SjA?holm <pasi.sjoholm@jollamobile.com>

It is possible to get kernel in deadlock-state if swap_lock is not locked
with spin_lock_bh by calling si_swapinfo() simultaneously through
timer_function and registered vm shinker callback-function.

BUG: spinlock recursion on CPU#0, main/2447
lock: swap_lock+0x0/0x10, .magic: dead4ead, .owner: main/2447, .owner_cpu: 0
[<c010b938>] (unwind_backtrace+0x0/0x11c) from [<c03e9be0>] (do_raw_spin_lock+0x48/0x154)
[<c03e9be0>] (do_raw_spin_lock+0x48/0x154) from [<c0226e10>] (si_swapinfo+0x10/0x90)
[<c0226e10>] (si_swapinfo+0x10/0x90) from [<c04d7e18>] (timer_function+0x24/0x258)
[<c04d7e18>] (timer_function+0x24/0x258) from [<c0182a10>] (run_timer_softirq+0x27c/0x3c0)
[<c0182a10>] (run_timer_softirq+0x27c/0x3c0) from [<c017bd10>] (__do_softirq+0x12c/0x268)
[<c017bd10>] (__do_softirq+0x12c/0x268) from [<c017c25c>] (irq_exit+0x48/0xa0)
[<c017c25c>] (irq_exit+0x48/0xa0) from [<c01066a4>] (handle_IRQ+0x80/0xc0)
[<c01066a4>] (handle_IRQ+0x80/0xc0) from [<c0100474>] (gic_handle_irq+0x90/0x10c)
[<c0100474>] (gic_handle_irq+0x90/0x10c) from [<c08a9500>] (__irq_svc+0x40/0x70)
Exception stack(0xd3425a58 to 0xd3425aa0)
5a40:                                                       c20f628000000040
5a60: 0000005300000001c20f628000000bc5c0efb6c8c10b8be0000000d400000001
5a80: d3425bb40000000000000000d3425aa0c0228820c022820020000113ffffffff
[<c08a9500>] (__irq_svc+0x40/0x70) from [<c0228200>] (scan_swap_map+0x14/0x518)
[<c0228200>] (scan_swap_map+0x14/0x518) from [<c0228820>] (get_swap_page+0x98/0x108)
[<c0228820>] (get_swap_page+0x98/0x108) from [<c0226400>] (add_to_swap+0x20/0x74)
[<c0226400>] (add_to_swap+0x20/0x74) from [<c0208090>] (shrink_page_list+0x234/0x8a0)
[<c0208090>] (shrink_page_list+0x234/0x8a0) from [<c0208b14>] (shrink_inactive_list+0x214/0x4c4)
[<c0208b14>] (shrink_inactive_list+0x214/0x4c4) from [<c020919c>] (shrink_mem_cgroup_zone+0x3d8/0x534)

Signed-off-by: Pasi SjA?holm <pasi.sjoholm@jollamobile.com>
---
 mm/swapfile.c | 54 +++++++++++++++++++++++++++---------------------------
 1 file changed, 27 insertions(+), 27 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 63f55cc..b00a55e 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -993,7 +993,7 @@ int swap_type_of(dev_t device, sector_t offset, struct block_device **bdev_p)
 	if (device)
 		bdev = bdget(device);
 
-	spin_lock(&swap_lock);
+	spin_lock_bh(&swap_lock);
 	for (type = 0; type < nr_swapfiles; type++) {
 		struct swap_info_struct *sis = swap_info[type];
 
@@ -1004,7 +1004,7 @@ int swap_type_of(dev_t device, sector_t offset, struct block_device **bdev_p)
 			if (bdev_p)
 				*bdev_p = bdgrab(sis->bdev);
 
-			spin_unlock(&swap_lock);
+			spin_unlock_bh(&swap_lock);
 			return type;
 		}
 		if (bdev == sis->bdev) {
@@ -1014,13 +1014,13 @@ int swap_type_of(dev_t device, sector_t offset, struct block_device **bdev_p)
 				if (bdev_p)
 					*bdev_p = bdgrab(sis->bdev);
 
-				spin_unlock(&swap_lock);
+				spin_unlock_bh(&swap_lock);
 				bdput(bdev);
 				return type;
 			}
 		}
 	}
-	spin_unlock(&swap_lock);
+	spin_unlock_bh(&swap_lock);
 	if (bdev)
 		bdput(bdev);
 
@@ -1052,7 +1052,7 @@ unsigned int count_swap_pages(int type, int free)
 {
 	unsigned int n = 0;
 
-	spin_lock(&swap_lock);
+	spin_lock_bh(&swap_lock);
 	if ((unsigned int)type < nr_swapfiles) {
 		struct swap_info_struct *sis = swap_info[type];
 
@@ -1064,7 +1064,7 @@ unsigned int count_swap_pages(int type, int free)
 		}
 		spin_unlock(&sis->lock);
 	}
-	spin_unlock(&swap_lock);
+	spin_unlock_bh(&swap_lock);
 	return n;
 }
 #endif /* CONFIG_HIBERNATION */
@@ -1783,20 +1783,20 @@ static void enable_swap_info(struct swap_info_struct *p, int prio,
 				unsigned long *frontswap_map)
 {
 	frontswap_init(p->type, frontswap_map);
-	spin_lock(&swap_lock);
+	spin_lock_bh(&swap_lock);
 	spin_lock(&p->lock);
 	 _enable_swap_info(p, prio, swap_map, cluster_info);
 	spin_unlock(&p->lock);
-	spin_unlock(&swap_lock);
+	spin_unlock_bh(&swap_lock);
 }
 
 static void reinsert_swap_info(struct swap_info_struct *p)
 {
-	spin_lock(&swap_lock);
+	spin_lock_bh(&swap_lock);
 	spin_lock(&p->lock);
 	_enable_swap_info(p, p->prio, p->swap_map, p->cluster_info);
 	spin_unlock(&p->lock);
-	spin_unlock(&swap_lock);
+	spin_unlock_bh(&swap_lock);
 }
 
 SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
@@ -1827,7 +1827,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		goto out;
 
 	mapping = victim->f_mapping;
-	spin_lock(&swap_lock);
+	spin_lock_bh(&swap_lock);
 	plist_for_each_entry(p, &swap_active_head, list) {
 		if (p->flags & SWP_WRITEOK) {
 			if (p->swap_file->f_mapping == mapping) {
@@ -1838,14 +1838,14 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	}
 	if (!found) {
 		err = -EINVAL;
-		spin_unlock(&swap_lock);
+		spin_unlock_bh(&swap_lock);
 		goto out_dput;
 	}
 	if (!security_vm_enough_memory_mm(current->mm, p->pages))
 		vm_unacct_memory(p->pages);
 	else {
 		err = -ENOMEM;
-		spin_unlock(&swap_lock);
+		spin_unlock_bh(&swap_lock);
 		goto out_dput;
 	}
 	spin_lock(&swap_avail_lock);
@@ -1867,7 +1867,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	total_swap_pages -= p->pages;
 	p->flags &= ~SWP_WRITEOK;
 	spin_unlock(&p->lock);
-	spin_unlock(&swap_lock);
+	spin_unlock_bh(&swap_lock);
 
 	set_current_oom_origin();
 	err = try_to_unuse(p->type, false, 0); /* force unuse all pages */
@@ -1886,7 +1886,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		free_swap_count_continuations(p);
 
 	mutex_lock(&swapon_mutex);
-	spin_lock(&swap_lock);
+	spin_lock_bh(&swap_lock);
 	spin_lock(&p->lock);
 	drain_mmlist();
 
@@ -1894,9 +1894,9 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	p->highest_bit = 0;		/* cuts scans short */
 	while (p->flags >= SWP_SCANNING) {
 		spin_unlock(&p->lock);
-		spin_unlock(&swap_lock);
+		spin_unlock_bh(&swap_lock);
 		schedule_timeout_uninterruptible(1);
-		spin_lock(&swap_lock);
+		spin_lock_bh(&swap_lock);
 		spin_lock(&p->lock);
 	}
 
@@ -1910,7 +1910,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	p->cluster_info = NULL;
 	frontswap_map = frontswap_map_get(p);
 	spin_unlock(&p->lock);
-	spin_unlock(&swap_lock);
+	spin_unlock_bh(&swap_lock);
 	frontswap_invalidate_area(p->type);
 	frontswap_map_set(p, NULL);
 	mutex_unlock(&swapon_mutex);
@@ -1939,9 +1939,9 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	 * can reuse this swap_info in alloc_swap_info() safely.  It is ok to
 	 * not hold p->lock after we cleared its SWP_WRITEOK.
 	 */
-	spin_lock(&swap_lock);
+	spin_lock_bh(&swap_lock);
 	p->flags = 0;
-	spin_unlock(&swap_lock);
+	spin_unlock_bh(&swap_lock);
 
 	err = 0;
 	atomic_inc(&proc_poll_event);
@@ -2098,13 +2098,13 @@ static struct swap_info_struct *alloc_swap_info(void)
 	if (!p)
 		return ERR_PTR(-ENOMEM);
 
-	spin_lock(&swap_lock);
+	spin_lock_bh(&swap_lock);
 	for (type = 0; type < nr_swapfiles; type++) {
 		if (!(swap_info[type]->flags & SWP_USED))
 			break;
 	}
 	if (type >= MAX_SWAPFILES) {
-		spin_unlock(&swap_lock);
+		spin_unlock_bh(&swap_lock);
 		kfree(p);
 		return ERR_PTR(-EPERM);
 	}
@@ -2130,7 +2130,7 @@ static struct swap_info_struct *alloc_swap_info(void)
 	plist_node_init(&p->list, 0);
 	plist_node_init(&p->avail_list, 0);
 	p->flags = SWP_USED;
-	spin_unlock(&swap_lock);
+	spin_unlock_bh(&swap_lock);
 	spin_lock_init(&p->lock);
 
 	return p;
@@ -2536,10 +2536,10 @@ bad_swap:
 	}
 	destroy_swap_extents(p);
 	swap_cgroup_swapoff(p->type);
-	spin_lock(&swap_lock);
+	spin_lock_bh(&swap_lock);
 	p->swap_file = NULL;
 	p->flags = 0;
-	spin_unlock(&swap_lock);
+	spin_unlock_bh(&swap_lock);
 	vfree(swap_map);
 	vfree(cluster_info);
 	if (swap_file) {
@@ -2566,7 +2566,7 @@ void si_swapinfo(struct sysinfo *val)
 	unsigned int type;
 	unsigned long nr_to_be_unused = 0;
 
-	spin_lock(&swap_lock);
+	spin_lock_bh(&swap_lock);
 	for (type = 0; type < nr_swapfiles; type++) {
 		struct swap_info_struct *si = swap_info[type];
 
@@ -2575,7 +2575,7 @@ void si_swapinfo(struct sysinfo *val)
 	}
 	val->freeswap = atomic_long_read(&nr_swap_pages) + nr_to_be_unused;
 	val->totalswap = total_swap_pages + nr_to_be_unused;
-	spin_unlock(&swap_lock);
+	spin_unlock_bh(&swap_lock);
 }
 
 /*
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
