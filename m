Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8C23E6B0055
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 18:04:00 -0400 (EDT)
Received: by mail-fx0-f220.google.com with SMTP id 20so1120606fxm.38
        for <linux-mm@kvack.org>; Wed, 09 Sep 2009 15:04:00 -0700 (PDT)
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
Subject: [PATCH 3/4] send callback when swap slot is freed
Date: Thu, 10 Sep 2009 03:20:36 +0530
References: <200909100215.36350.ngupta@vflare.org>
In-Reply-To: <200909100215.36350.ngupta@vflare.org>
MIME-Version: 1.0
Message-Id: <200909100320.36333.ngupta@vflare.org>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, Ed Tomlinson <edt@aei.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

Currently, we have "swap discard" mechanism which sends a discard bio request
when we find a free cluster during scan_swap_map(). This callback can come a
long time after swap slots are actually freed.

This delay in callback is a great problem when (compressed) RAM [1] is used
as a swap device. So, this change adds a callback which is called as
soon as a swap slot becomes free. For above mentioned case of swapping
over compressed RAM device, this is very useful since we can immediately
free memory allocated for this swap page.

This callback does not replace swap discard support. It is called with
swap_lock held, so it is meant to trigger action that finishes quickly.
However, swap discard is an I/O request and can be used for taking longer
actions.

It is preferred to use this callback for ramzswap case even if discard
mechanism could be improved such that it can be called as often as required.
This is because, allocation of 'bio'(s) is undesirable since ramzswap always
operates under low memory conditions (its a swap device). Also, batching of
discard bio requests is not optimal since stale data can accumulate very
quickly in ramzswap devices, pushing system further into low memory state.

Links:
[1] http://compcache.googlecode.com/

Signed-off-by: Nitin Gupta <ngupta@vflare.org>
---

 include/linux/swap.h |    5 +++++
 mm/swapfile.c        |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7c15334..64796fc 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -8,6 +8,7 @@
 #include <linux/memcontrol.h>
 #include <linux/sched.h>
 #include <linux/node.h>
+#include <linux/blkdev.h>
 
 #include <asm/atomic.h>
 #include <asm/page.h>
@@ -20,6 +21,8 @@ struct bio;
 #define SWAP_FLAG_PRIO_MASK	0x7fff
 #define SWAP_FLAG_PRIO_SHIFT	0
 
+typedef void (swap_free_notify_fn) (struct block_device *, unsigned long);
+
 static inline int current_is_kswapd(void)
 {
 	return current->flags & PF_KSWAPD;
@@ -155,6 +158,7 @@ struct swap_info_struct {
 	unsigned int max;
 	unsigned int inuse_pages;
 	unsigned int old_block_size;
+	swap_free_notify_fn *swap_free_notify_fn;
 };
 
 struct swap_list_t {
@@ -295,6 +299,7 @@ extern sector_t swapdev_block(int, pgoff_t);
 extern struct swap_info_struct *get_swap_info_struct(unsigned);
 extern int reuse_swap_page(struct page *);
 extern int try_to_free_swap(struct page *);
+extern void set_swap_free_notify(struct block_device *, swap_free_notify_fn *);
 struct backing_dev_info;
 
 /* linux/mm/thrash.c */
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8ffdc0d..fb6b8b2 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -552,6 +552,38 @@ out:
 	return NULL;
 }
 
+/*
+ * Sets callback for event when swap_map[offset] == 0
+ * i.e. page at this swap offset is no longer used.
+ */
+void set_swap_free_notify(struct block_device *bdev,
+			swap_free_notify_fn *notify_fn)
+{
+	unsigned int i;
+	struct swap_info_struct *sis;
+
+	spin_lock(&swap_lock);
+	for (i = 0; i <= nr_swapfiles; i++) {
+		sis = &swap_info[i];
+		if (!(sis->flags & SWP_USED))
+			continue;
+		if (sis->bdev == bdev)
+			break;
+	}
+
+	/* swap device not found */
+	if (i > nr_swapfiles) {
+		spin_unlock(&swap_lock);
+		return;
+	}
+
+	BUG_ON(!sis || sis->swap_free_notify_fn);
+	sis->swap_free_notify_fn = notify_fn;
+	spin_unlock(&swap_lock);
+	return;
+}
+EXPORT_SYMBOL_GPL(set_swap_free_notify);
+
 static int swap_entry_free(struct swap_info_struct *p,
 			   swp_entry_t ent, int cache)
 {
@@ -583,6 +615,8 @@ static int swap_entry_free(struct swap_info_struct *p,
 			swap_list.next = p - swap_info;
 		nr_swap_pages++;
 		p->inuse_pages--;
+		if (p->swap_free_notify_fn)
+			p->swap_free_notify_fn(p->bdev, offset);
 	}
 	if (!swap_count(count))
 		mem_cgroup_uncharge_swap(ent);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
