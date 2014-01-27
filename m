Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9A29F6B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 05:08:03 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so5675573pbb.20
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 02:08:03 -0800 (PST)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id g5si10807357pav.114.2014.01.27.02.08.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 27 Jan 2014 02:08:01 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N0200ICK1HB04E0@mailout2.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Jan 2014 19:07:59 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 4/8] mm/swap: fix race among frontswap_register_ops,
 swapoff and swapon
Date: Mon, 27 Jan 2014 18:03:04 +0800
Message-id: <000b01cf1b47$a7d31410$f7793c30$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Minchan Kim' <minchan@kernel.org>, shli@kernel.org, 'Bob Liu' <bob.liu@oracle.com>, weijie.yang.kh@gmail.com, 'Seth Jennings' <sjennings@variantweb.net>, 'Heesub Shin' <heesub.shin@samsung.com>, mquzik@redhat.com, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

A potential asynchronous frontswap_register_ops could happen while swapoff
or swapon is happening, there is a need to protect init frontswap type and
prevent NULL point reference to si->frontswap_map.

This patch utilize swapon_mutex to prevent this scenario, see comments of
frontswap_register_ops for detail.

This patch is just for a rare scenario, aim to correct of code.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 include/linux/swapfile.h |    1 +
 mm/frontswap.c           |    7 ++++---
 mm/swapfile.c            |   20 +++++++++++++++-----
 3 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/include/linux/swapfile.h b/include/linux/swapfile.h
index e282624..1fd5494 100644
--- a/include/linux/swapfile.h
+++ b/include/linux/swapfile.h
@@ -6,6 +6,7 @@
  * want to expose them to the dozens of source files that include swap.h
  */
 extern spinlock_t swap_lock;
+extern struct mutex swapon_mutex;
 extern struct swap_list_t swap_list;
 extern struct swap_info_struct *swap_info[];
 extern int try_to_unuse(unsigned int, bool, unsigned long);
diff --git a/mm/frontswap.c b/mm/frontswap.c
index 1b24bdc..a0c68db 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -88,10 +88,9 @@ static inline void inc_frontswap_invalidates(void) { }
  * bitmap) to create tmem_pools and set the respective poolids. All of that is
  * guarded by us using atomic bit operations on the 'need_init' bitmap.
  *
- * This would not guards us against the user deciding to call swapoff right as
+ * swapon_mutex guards us against the user deciding to call swapoff right as
  * we are calling the backend to initialize (so swapon is in action).
- * Fortunatly for us, the swapon_mutex has been taked by the callee so we are
- * OK. The other scenario where calls to frontswap_store (called via
+ * The other scenario where calls to frontswap_store (called via
  * swap_writepage) is racing with frontswap_invalidate_area (called via
  * swapoff) is again guarded by the swap subsystem.
  *
@@ -120,6 +119,7 @@ struct frontswap_ops *frontswap_register_ops(struct frontswap_ops *ops)
 	struct frontswap_ops *old = frontswap_ops;
 	int i;
 
+	mutex_lock(&swapon_mutex);
 	for (i = 0; i < MAX_SWAPFILES; i++) {
 		if (test_and_clear_bit(i, need_init)) {
 			struct swap_info_struct *sis = swap_info[i];
@@ -129,6 +129,7 @@ struct frontswap_ops *frontswap_register_ops(struct frontswap_ops *ops)
 			ops->init(i);
 		}
 	}
+	mutex_unlock(&swapon_mutex);
 	/*
 	 * We MUST have frontswap_ops set _after_ the frontswap_init's
 	 * have been called. Otherwise __frontswap_store might fail. Hence
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 413c213..5c8a086 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -112,7 +112,7 @@ struct swap_list_t swap_list = {-1, -1};
 
 struct swap_info_struct *swap_info[MAX_SWAPFILES];
 
-static DEFINE_MUTEX(swapon_mutex);
+DEFINE_MUTEX(swapon_mutex);
 
 static DECLARE_WAIT_QUEUE_HEAD(proc_poll_wait);
 /* Activity counter to indicate that a swapon or swapoff has occurred */
@@ -1954,11 +1954,9 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	if (p->flags & SWP_CONTINUED)
 		free_swap_count_continuations(p);
 
-	mutex_lock(&swapon_mutex);
 	spin_lock(&swap_lock);
 	spin_lock(&p->lock);
 	drain_mmlist();
-
 	/* wait for anyone still in scan_swap_map */
 	p->highest_bit = 0;		/* cuts scans short */
 	while (p->flags >= SWP_SCANNING) {
@@ -1968,7 +1966,16 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		spin_lock(&swap_lock);
 		spin_lock(&p->lock);
 	}
+	spin_unlock(&p->lock);
+	spin_unlock(&swap_lock);
 
+	/*
+	 * Now nobody use or allocate swap_entry from this swapfile,
+	 * there is no need to hold swap_lock or p->lock.
+	 * Use swapon_mutex to mutex against swap_start() and a potential
+	 * asynchronous frontswap_register_ops, which will init this swap type
+	 */
+	mutex_lock(&swapon_mutex);
 	swap_file = p->swap_file;
 	old_block_size = p->old_block_size;
 	p->swap_file = NULL;
@@ -1978,11 +1985,10 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	cluster_info = p->cluster_info;
 	p->cluster_info = NULL;
 	frontswap_map = frontswap_map_get(p);
-	spin_unlock(&p->lock);
-	spin_unlock(&swap_lock);
 	frontswap_invalidate_area(type);
 	frontswap_map_set(p, NULL);
 	mutex_unlock(&swapon_mutex);
+
 	free_percpu(p->percpu_cluster);
 	p->percpu_cluster = NULL;
 	vfree(swap_map);
@@ -2577,6 +2583,10 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		}
 	}
 
+	/*
+	 * Use swapon_mutex to mutex against swap_start() and a potential
+	 * asynchronous frontswap_register_ops, which will init this swap type
+	 */
 	mutex_lock(&swapon_mutex);
 	prio = -1;
 	if (swap_flags & SWAP_FLAG_PREFER)
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
