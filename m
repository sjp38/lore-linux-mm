Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id A61219000C7
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 17:34:37 -0400 (EDT)
Date: Thu, 15 Sep 2011 14:34:06 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V10 3/6] mm: frontswap: core frontswap functionality
Message-ID: <20110915213406.GA26369@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, dan.magenheimer@oracle.com, sjenning@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V10 3/6] mm: frontswap: core frontswap functionality

(Note to earlier reviewers:  This patchset has been reorganized due to
feedback from Kame Hiroyuki and Andrew Morton. This patch contains part
of patch 3of4 from the previous series.)

This third patch of six in the frontswap series provides the core
frontswap code that interfaces between the hooks in the swap subsystem
and a frontswap backend via frontswap_ops.

[v10: sjenning@linux.vnet.ibm.com: fix debugfs calls on 32-bit]
[v9: akpm@linux-foundation.org: change "flush" to "invalidate", part 1]
[v9: akpm@linux-foundation.org: mark some statics __read_mostly]
[v9: akpm@linux-foundation.org: add clarifying comments]
[v9: akpm@linux-foundation.org: no need to loop repeating try_to_unuse]
[v9: error27@gmail.com: remove superfluous check for NULL]
[v8: rebase to 3.0-rc4]
[v8: kamezawa.hiroyu@jp.fujitsu.com: add comment to clarify find_next_to_unuse]
[v7: rebase to 3.0-rc3]
[v7: JBeulich@novell.com: use new static inlines, no-ops if not config'd]
[v6: rebase to 3.1-rc1]
[v6: lliubbo@gmail.com: use vzalloc]
[v6: lliubbo@gmail.com: fix null pointer deref if vzalloc fails]
[v6: konrad.wilk@oracl.com: various checks and code clarifications/comments]
[v4: rebase to 2.6.39]
Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Reviewed-by: Konrad Wilk <konrad.wilk@oracle.com>
Acked-by: Jan Beulich <JBeulich@novell.com>
Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Matthew Wilcox <matthew@wil.cx>
Cc: Chris Mason <chris.mason@oracle.com>
Cc: Rik Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>

--- linux/mm/frontswap.c	1969-12-31 17:00:00.000000000 -0700
+++ frontswap-v10/mm/frontswap.c	2011-09-15 14:50:27.283685916 -0600
@@ -0,0 +1,272 @@
+/*
+ * Frontswap frontend
+ *
+ * This code provides the generic "frontend" layer to call a matching
+ * "backend" driver implementation of frontswap.  See
+ * Documentation/vm/frontswap.txt for more information.
+ *
+ * Copyright (C) 2009-2010 Oracle Corp.  All rights reserved.
+ * Author: Dan Magenheimer
+ *
+ * This work is licensed under the terms of the GNU GPL, version 2.
+ */
+
+#include <linux/mm.h>
+#include <linux/mman.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
+#include <linux/proc_fs.h>
+#include <linux/security.h>
+#include <linux/capability.h>
+#include <linux/module.h>
+#include <linux/uaccess.h>
+#include <linux/debugfs.h>
+#include <linux/frontswap.h>
+#include <linux/swapfile.h>
+
+/*
+ * frontswap_ops is set by frontswap_register_ops to contain the pointers
+ * to the frontswap "backend" implementation functions.
+ */
+static struct frontswap_ops frontswap_ops __read_mostly;
+
+/*
+ * This global enablement flag reduces overhead on systems where frontswap_ops
+ * has not been registered, so is preferred to the slower alternative: a
+ * function call that checks a non-global.
+ */
+int frontswap_enabled __read_mostly;
+EXPORT_SYMBOL(frontswap_enabled);
+
+/*
+ * Counters available via /sys/kernel/debug/frontswap (if debugfs is
+ * properly configured.  These are for information only so are not protected
+ * against increment races.
+ */
+static u64 frontswap_gets;
+static u64 frontswap_succ_puts;
+static u64 frontswap_failed_puts;
+static u64 frontswap_invalidates;
+
+/*
+ * Register operations for frontswap, returning previous thus allowing
+ * detection of multiple backends and possible nesting
+ */
+struct frontswap_ops frontswap_register_ops(struct frontswap_ops *ops)
+{
+	struct frontswap_ops old = frontswap_ops;
+
+	frontswap_ops = *ops;
+	frontswap_enabled = 1;
+	return old;
+}
+EXPORT_SYMBOL(frontswap_register_ops);
+
+/* Called when a swap device is swapon'd */
+void __frontswap_init(unsigned type)
+{
+	struct swap_info_struct *sis = swap_info[type];
+
+	BUG_ON(sis == NULL);
+	if (sis->frontswap_map == NULL)
+		return;
+	if (frontswap_enabled)
+		(*frontswap_ops.init)(type);
+}
+EXPORT_SYMBOL(__frontswap_init);
+
+/*
+ * "Put" data from a page to frontswap and associate it with the page's
+ * swaptype and offset.  Page must be locked and in the swap cache.
+ * If frontswap already contains a page with matching swaptype and
+ * offset, the frontswap implmentation may either overwrite the data and
+ * return success or invalidate the page from frontswap and return failure
+ */
+int __frontswap_put_page(struct page *page)
+{
+	int ret = -1, dup = 0;
+	swp_entry_t entry = { .val = page_private(page), };
+	int type = swp_type(entry);
+	struct swap_info_struct *sis = swap_info[type];
+	pgoff_t offset = swp_offset(entry);
+
+	BUG_ON(!PageLocked(page));
+	BUG_ON(sis == NULL);
+	if (frontswap_test(sis, offset))
+		dup = 1;
+	ret = (*frontswap_ops.put_page)(type, offset, page);
+	if (ret == 0) {
+		frontswap_set(sis, offset);
+		frontswap_succ_puts++;
+		if (!dup)
+			atomic_inc(&sis->frontswap_pages);
+	} else if (dup) {
+		/*
+		  failed dup always results in automatic invalidate of
+		  the (older) page from frontswap
+		 */
+		frontswap_clear(sis, offset);
+		atomic_dec(&sis->frontswap_pages);
+		frontswap_failed_puts++;
+	} else
+		frontswap_failed_puts++;
+	return ret;
+}
+EXPORT_SYMBOL(__frontswap_put_page);
+
+/*
+ * "Get" data from frontswap associated with swaptype and offset that were
+ * specified when the data was put to frontswap and use it to fill the
+ * specified page with data. Page must be locked and in the swap cache
+ */
+int __frontswap_get_page(struct page *page)
+{
+	int ret = -1;
+	swp_entry_t entry = { .val = page_private(page), };
+	int type = swp_type(entry);
+	struct swap_info_struct *sis = swap_info[type];
+	pgoff_t offset = swp_offset(entry);
+
+	BUG_ON(!PageLocked(page));
+	BUG_ON(sis == NULL);
+	if (frontswap_test(sis, offset))
+		ret = (*frontswap_ops.get_page)(type, offset, page);
+	if (ret == 0)
+		frontswap_gets++;
+	return ret;
+}
+EXPORT_SYMBOL(__frontswap_get_page);
+
+/*
+ * Invalidate any data from frontswap associated with the specified swaptype
+ * and offset so that a subsequent "get" will fail.
+ */
+void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
+{
+	struct swap_info_struct *sis = swap_info[type];
+
+	BUG_ON(sis == NULL);
+	if (frontswap_test(sis, offset)) {
+		(*frontswap_ops.flush_page)(type, offset);
+		atomic_dec(&sis->frontswap_pages);
+		frontswap_clear(sis, offset);
+		frontswap_invalidates++;
+	}
+}
+EXPORT_SYMBOL(__frontswap_invalidate_page);
+
+/*
+ * Invalidate all data from frontswap associated with all offsets for the
+ * specified swaptype.
+ */
+void __frontswap_invalidate_area(unsigned type)
+{
+	struct swap_info_struct *sis = swap_info[type];
+
+	BUG_ON(sis == NULL);
+	if (sis->frontswap_map == NULL)
+		return;
+	(*frontswap_ops.flush_area)(type);
+	atomic_set(&sis->frontswap_pages, 0);
+	memset(sis->frontswap_map, 0, sis->max / sizeof(long));
+}
+EXPORT_SYMBOL(__frontswap_invalidate_area);
+
+/*
+ * Frontswap, like a true swap device, may unnecessarily retain pages
+ * under certain circumstances; "shrink" frontswap is essentially a
+ * "partial swapoff" and works by calling try_to_unuse to attempt to
+ * unuse enough frontswap pages to attempt to -- subject to memory
+ * constraints -- reduce the number of pages in frontswap to the
+ * number given in the parameter target_pages.
+ */
+void frontswap_shrink(unsigned long target_pages)
+{
+	struct swap_info_struct *si = NULL;
+	int si_frontswap_pages;
+	unsigned long total_pages = 0, total_pages_to_unuse;
+	unsigned long pages = 0, pages_to_unuse = 0;
+	int type;
+	bool locked = false;
+
+	/*
+	 * we don't want to hold swap_lock while doing a very
+	 * lengthy try_to_unuse, but swap_list may change
+	 * so restart scan from swap_list.head each time
+	 */
+	spin_lock(&swap_lock);
+	locked = true;
+	total_pages = 0;
+	for (type = swap_list.head; type >= 0; type = si->next) {
+		si = swap_info[type];
+		total_pages += atomic_read(&si->frontswap_pages);
+	}
+	if (total_pages <= target_pages)
+		goto out;
+	total_pages_to_unuse = total_pages - target_pages;
+	for (type = swap_list.head; type >= 0; type = si->next) {
+		si = swap_info[type];
+		si_frontswap_pages = atomic_read(&si->frontswap_pages);
+		if (total_pages_to_unuse < si_frontswap_pages)
+			pages = pages_to_unuse = total_pages_to_unuse;
+		else {
+			pages = si_frontswap_pages;
+			pages_to_unuse = 0; /* unuse all */
+		}
+		/* ensure there is enough RAM to fetch pages from frontswap */
+		if (security_vm_enough_memory_kern(pages))
+			continue;
+		vm_unacct_memory(pages);
+		break;
+	}
+	if (type < 0)
+		goto out;
+	locked = false;
+	spin_unlock(&swap_lock);
+	try_to_unuse(type, true, pages_to_unuse);
+out:
+	if (locked)
+		spin_unlock(&swap_lock);
+	return;
+}
+EXPORT_SYMBOL(frontswap_shrink);
+
+/*
+ * Count and return the number of frontswap pages across all
+ * swap devices.  This is exported so that backend drivers can
+ * determine current usage without reading debugfs.
+ */
+unsigned long frontswap_curr_pages(void)
+{
+	int type;
+	unsigned long totalpages = 0;
+	struct swap_info_struct *si = NULL;
+
+	spin_lock(&swap_lock);
+	for (type = swap_list.head; type >= 0; type = si->next) {
+		si = swap_info[type];
+		totalpages += atomic_read(&si->frontswap_pages);
+	}
+	spin_unlock(&swap_lock);
+	return totalpages;
+}
+EXPORT_SYMBOL(frontswap_curr_pages);
+
+static int __init init_frontswap(void)
+{
+	int err = 0;
+
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *root = debugfs_create_dir("frontswap", NULL);
+	if (root == NULL)
+		return -ENXIO;
+	debugfs_create_u64("gets", S_IRUGO, root, &frontswap_gets);
+	debugfs_create_u64("succ_puts", S_IRUGO, root, &frontswap_succ_puts);
+	debugfs_create_u64("puts", S_IRUGO, root, &frontswap_failed_puts);
+	debugfs_create_u64("invalidates", S_IRUGO,
+				root, &frontswap_invalidates);
+#endif
+	return err;
+}
+
+module_init(init_frontswap);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
