Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 480B96B0036
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 05:07:03 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id rr13so5697463pbb.35
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 02:07:02 -0800 (PST)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id yh9si10745708pab.295.2014.01.27.02.07.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 27 Jan 2014 02:07:01 -0800 (PST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N02008XZ1FM0N50@mailout3.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Jan 2014 19:06:58 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 5/8] mm/swap: drop useless and bug frontswap_shrink codes
Date: Mon, 27 Jan 2014 18:03:04 +0800
Message-id: <000a01cf1b47$838a7170$8a9f5450$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, 'Seth Jennings' <sjennings@variantweb.net>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Minchan Kim' <minchan@kernel.org>, shli@kernel.org, 'Bob Liu' <bob.liu@oracle.com>, weijie.yang.kh@gmail.com, 'Heesub Shin' <heesub.shin@samsung.com>, mquzik@redhat.com, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

The frontswap_shrink works as a "partial swapoff" by using try_to_unuse(),
but is has race condition with swapoff.

Of course we can fix this race issue, however, as this code is not used by
anyone and not efficient, I decide drop this code.

As to shrinker, a frontswap backend should implement its own shrinker if
there is a real-world need.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 include/linux/frontswap.h |    2 -
 include/linux/swapfile.h  |    3 --
 mm/frontswap.c            |  116 ---------------------------------------------
 mm/swapfile.c             |   19 ++------
 4 files changed, 4 insertions(+), 136 deletions(-)

diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
index 8293262..c00b429 100644
--- a/include/linux/frontswap.h
+++ b/include/linux/frontswap.h
@@ -16,8 +16,6 @@ struct frontswap_ops {
 extern bool frontswap_enabled;
 extern struct frontswap_ops *
 	frontswap_register_ops(struct frontswap_ops *ops);
-extern void frontswap_shrink(unsigned long);
-extern unsigned long frontswap_curr_pages(void);
 extern void frontswap_writethrough(bool);
 #define FRONTSWAP_HAS_EXCLUSIVE_GETS
 extern void frontswap_tmem_exclusive_gets(bool);
diff --git a/include/linux/swapfile.h b/include/linux/swapfile.h
index 1fd5494..5dc7c81 100644
--- a/include/linux/swapfile.h
+++ b/include/linux/swapfile.h
@@ -5,10 +5,7 @@
  * these were static in swapfile.c but frontswap.c needs them and we don't
  * want to expose them to the dozens of source files that include swap.h
  */
-extern spinlock_t swap_lock;
 extern struct mutex swapon_mutex;
-extern struct swap_list_t swap_list;
 extern struct swap_info_struct *swap_info[];
-extern int try_to_unuse(unsigned int, bool, unsigned long);
 
 #endif /* _LINUX_SWAPFILE_H */
diff --git a/mm/frontswap.c b/mm/frontswap.c
index a0c68db..df067f1 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -326,122 +326,6 @@ void __frontswap_invalidate_area(unsigned type)
 }
 EXPORT_SYMBOL(__frontswap_invalidate_area);
 
-static unsigned long __frontswap_curr_pages(void)
-{
-	int type;
-	unsigned long totalpages = 0;
-	struct swap_info_struct *si = NULL;
-
-	assert_spin_locked(&swap_lock);
-	for (type = swap_list.head; type >= 0; type = si->next) {
-		si = swap_info[type];
-		totalpages += atomic_read(&si->frontswap_pages);
-	}
-	return totalpages;
-}
-
-static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
-					int *swapid)
-{
-	int ret = -EINVAL;
-	struct swap_info_struct *si = NULL;
-	int si_frontswap_pages;
-	unsigned long total_pages_to_unuse = total;
-	unsigned long pages = 0, pages_to_unuse = 0;
-	int type;
-
-	assert_spin_locked(&swap_lock);
-	for (type = swap_list.head; type >= 0; type = si->next) {
-		si = swap_info[type];
-		si_frontswap_pages = atomic_read(&si->frontswap_pages);
-		if (total_pages_to_unuse < si_frontswap_pages) {
-			pages = pages_to_unuse = total_pages_to_unuse;
-		} else {
-			pages = si_frontswap_pages;
-			pages_to_unuse = 0; /* unuse all */
-		}
-		/* ensure there is enough RAM to fetch pages from frontswap */
-		if (security_vm_enough_memory_mm(current->mm, pages)) {
-			ret = -ENOMEM;
-			continue;
-		}
-		vm_unacct_memory(pages);
-		*unused = pages_to_unuse;
-		*swapid = type;
-		ret = 0;
-		break;
-	}
-
-	return ret;
-}
-
-/*
- * Used to check if it's necessory and feasible to unuse pages.
- * Return 1 when nothing to do, 0 when need to shink pages,
- * error code when there is an error.
- */
-static int __frontswap_shrink(unsigned long target_pages,
-				unsigned long *pages_to_unuse,
-				int *type)
-{
-	unsigned long total_pages = 0, total_pages_to_unuse;
-
-	assert_spin_locked(&swap_lock);
-
-	total_pages = __frontswap_curr_pages();
-	if (total_pages <= target_pages) {
-		/* Nothing to do */
-		*pages_to_unuse = 0;
-		return 1;
-	}
-	total_pages_to_unuse = total_pages - target_pages;
-	return __frontswap_unuse_pages(total_pages_to_unuse, pages_to_unuse, type);
-}
-
-/*
- * Frontswap, like a true swap device, may unnecessarily retain pages
- * under certain circumstances; "shrink" frontswap is essentially a
- * "partial swapoff" and works by calling try_to_unuse to attempt to
- * unuse enough frontswap pages to attempt to -- subject to memory
- * constraints -- reduce the number of pages in frontswap to the
- * number given in the parameter target_pages.
- */
-void frontswap_shrink(unsigned long target_pages)
-{
-	unsigned long pages_to_unuse = 0;
-	int uninitialized_var(type), ret;
-
-	/*
-	 * we don't want to hold swap_lock while doing a very
-	 * lengthy try_to_unuse, but swap_list may change
-	 * so restart scan from swap_list.head each time
-	 */
-	spin_lock(&swap_lock);
-	ret = __frontswap_shrink(target_pages, &pages_to_unuse, &type);
-	spin_unlock(&swap_lock);
-	if (ret == 0)
-		try_to_unuse(type, true, pages_to_unuse);
-	return;
-}
-EXPORT_SYMBOL(frontswap_shrink);
-
-/*
- * Count and return the number of frontswap pages across all
- * swap devices.  This is exported so that backend drivers can
- * determine current usage without reading debugfs.
- */
-unsigned long frontswap_curr_pages(void)
-{
-	unsigned long totalpages = 0;
-
-	spin_lock(&swap_lock);
-	totalpages = __frontswap_curr_pages();
-	spin_unlock(&swap_lock);
-
-	return totalpages;
-}
-EXPORT_SYMBOL(frontswap_curr_pages);
-
 static int __init init_frontswap(void)
 {
 #ifdef CONFIG_DEBUG_FS
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 5c8a086..3023172 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1353,7 +1353,7 @@ static int unuse_mm(struct mm_struct *mm,
  * Recycle to start on reaching the end, returning 0 when empty.
  */
 static unsigned int find_next_to_unuse(struct swap_info_struct *si,
-					unsigned int prev, bool frontswap)
+					unsigned int prev)
 {
 	unsigned int max = si->max;
 	unsigned int i = prev;
@@ -1379,12 +1379,6 @@ static unsigned int find_next_to_unuse(struct swap_info_struct *si,
 			prev = 0;
 			i = 1;
 		}
-		if (frontswap) {
-			if (frontswap_test(si, i))
-				break;
-			else
-				continue;
-		}
 		count = ACCESS_ONCE(si->swap_map[i]);
 		if (count && swap_count(count) != SWAP_MAP_BAD)
 			break;
@@ -1400,8 +1394,7 @@ static unsigned int find_next_to_unuse(struct swap_info_struct *si,
  * if the boolean frontswap is true, only unuse pages_to_unuse pages;
  * pages_to_unuse==0 means all pages; ignored if frontswap is false
  */
-int try_to_unuse(unsigned int type, bool frontswap,
-		 unsigned long pages_to_unuse)
+int try_to_unuse(unsigned int type)
 {
 	struct swap_info_struct *si = swap_info[type];
 	struct mm_struct *start_mm;
@@ -1438,7 +1431,7 @@ int try_to_unuse(unsigned int type, bool frontswap,
 	 * one pass through swap_map is enough, but not necessarily:
 	 * there are races when an instance of an entry might be missed.
 	 */
-	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
+	while ((i = find_next_to_unuse(si, i)) != 0) {
 		if (signal_pending(current)) {
 			retval = -EINTR;
 			break;
@@ -1613,10 +1606,6 @@ int try_to_unuse(unsigned int type, bool frontswap,
 		 * interactive performance.
 		 */
 		cond_resched();
-		if (frontswap && pages_to_unuse > 0) {
-			if (!--pages_to_unuse)
-				break;
-		}
 	}
 
 	mmput(start_mm);
@@ -1939,7 +1928,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	spin_unlock(&swap_lock);
 
 	set_current_oom_origin();
-	err = try_to_unuse(type, false, 0); /* force all pages to be unused */
+	err = try_to_unuse(type); /* force all pages to be unused */
 	clear_current_oom_origin();
 
 	if (err) {
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
