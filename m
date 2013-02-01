Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id EE6146B002A
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 15:23:35 -0500 (EST)
Received: by mail-vc0-f178.google.com with SMTP id m8so2684236vcd.23
        for <linux-mm@kvack.org>; Fri, 01 Feb 2013 12:23:35 -0800 (PST)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH 13/15] frontswap: Get rid of swap_lock dependency
Date: Fri,  1 Feb 2013 15:23:02 -0500
Message-Id: <1359750184-23408-14-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
References: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, ngupta@vflare.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org
Cc: Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>

From: Minchan Kim <minchan@kernel.org>

Frontswap initialization routine depends on swap_lock, which want
to be atomic about frontswap's first appearance.
IOW, frontswap is not present and will fail all calls OR frontswap is
fully functional but if new swap_info_struct isn't registered
by enable_swap_info, swap subsystem doesn't start I/O so there is no
race
between init procedure and page I/O working on frontswap.

So let's remove unncessary swap_lock dependency.

Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
[v1: Rebased on my branch, reworked to work with backends loading late]
[v2: Added a check for !map]
Signed-off-by: Konrad Rzeszutek Wilk <konrad@darnok.org>

squash
---
 include/linux/frontswap.h |  6 +++---
 mm/frontswap.c            | 12 +++++++++---
 mm/swapfile.c             |  7 ++++++-
 3 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
index 612c176..3d72f14 100644
--- a/include/linux/frontswap.h
+++ b/include/linux/frontswap.h
@@ -20,7 +20,7 @@ extern void frontswap_writethrough(bool);
 #define FRONTSWAP_HAS_EXCLUSIVE_GETS
 extern void frontswap_tmem_exclusive_gets(bool);
 
-extern void __frontswap_init(unsigned type);
+extern void __frontswap_init(unsigned type, unsigned long *map);
 extern int __frontswap_store(struct page *page);
 extern int __frontswap_load(struct page *page);
 extern void __frontswap_invalidate_page(unsigned, pgoff_t);
@@ -122,9 +122,9 @@ static inline void frontswap_invalidate_area(unsigned type)
 	__frontswap_invalidate_area(type);
 }
 
-static inline void frontswap_init(unsigned type)
+static inline void frontswap_init(unsigned type, unsigned long *map)
 {
-	__frontswap_init(type);
+	__frontswap_init(type, map);
 }
 
 #endif /* _LINUX_FRONTSWAP_H */
diff --git a/mm/frontswap.c b/mm/frontswap.c
index ebf4c18..8254a6a 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -127,8 +127,13 @@ struct frontswap_ops *frontswap_register_ops(struct frontswap_ops *ops)
 	int i;
 
 	for (i = 0; i < MAX_SWAPFILES; i++) {
-		if (test_and_clear_bit(i, need_init))
+		if (test_and_clear_bit(i, need_init)) {
+			struct swap_info_struct *sis = swap_info[i];
+			/* enable_swap_info _should_ have set it! */
+			if (!sis->frontswap_map)
+				return ERR_PTR(-EINVAL);
 			ops->init(i);
+		}
 	}
 	/*
 	 * We MUST have frontswap_ops set _after_ the frontswap_init's
@@ -166,14 +171,15 @@ EXPORT_SYMBOL(frontswap_tmem_exclusive_gets);
  *
  * Can be called without any backend driver is registered.
  */
-void __frontswap_init(unsigned type)
+void __frontswap_init(unsigned type, unsigned long *map)
 {
 	struct swap_info_struct *sis = swap_info[type];
 
 	if (static_key_false(&frontswap_key)) {
 		BUG_ON(sis == NULL);
-		if (sis->frontswap_map == NULL)
+		if (!map)
 			return;
+		frontswap_map_set(sis, map);
 		frontswap_ops->init(type);
 	}
 	else {
diff --git a/mm/swapfile.c b/mm/swapfile.c
index e97a0e5..c1c3a62 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1454,6 +1454,10 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	else
 		p->prio = --least_priority;
 	p->swap_map = swap_map;
+	/*
+	 * This is required for frontswap to handle backends loading
+	 * after the swap has been activated.
+	 */
 	frontswap_map_set(p, frontswap_map);
 	p->flags |= SWP_WRITEOK;
 	nr_swap_pages += p->pages;
@@ -1477,9 +1481,9 @@ static void enable_swap_info(struct swap_info_struct *p, int prio,
 				unsigned char *swap_map,
 				unsigned long *frontswap_map)
 {
+	frontswap_init(p->type, frontswap_map);
 	spin_lock(&swap_lock);
 	_enable_swap_info(p, prio, swap_map, frontswap_map);
-	frontswap_init(p->type);
 	spin_unlock(&swap_lock);
 }
 
@@ -1589,6 +1593,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	p->swap_map = NULL;
 	p->flags = 0;
 	frontswap_invalidate_area(type);
+	frontswap_map_set(p, NULL);
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
