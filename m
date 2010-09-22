Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 095406B0082
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 17:01:55 -0400 (EDT)
Date: Wed, 22 Sep 2010 14:00:34 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V3 2/4] Frontswap: core code
Message-ID: <20100922210034.GA27514@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

[PATCH V3 2/4] Frontswap: core code

Core frontswap interface between swap subsystem hooks and
frontswap backend via frontswap_ops.

Credits: Frontswap_ops design derived from Jeremy Fitzhardinge
design for tmem; sysfs code modelled after mm/ksm.c

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Diffstat:
 include/linux/frontswap.h                |   86 +++++
 mm/frontswap.c                           |  331 +++++++++++++++++++++
 2 files changed, 417 insertions(+)

--- linux-2.6.36-rc5/include/linux/frontswap.h	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.36-rc5-frontswap/include/linux/frontswap.h	2010-09-21 13:58:02.000000000 -0600
@@ -0,0 +1,86 @@
+#ifndef _LINUX_FRONTSWAP_H
+#define _LINUX_FRONTSWAP_H
+
+#include <linux/swap.h>
+#include <linux/mm.h>
+
+struct frontswap_ops {
+	void (*init)(unsigned);
+	int (*put_page)(unsigned, pgoff_t, struct page *);
+	int (*get_page)(unsigned, pgoff_t, struct page *);
+	void (*flush_page)(unsigned, pgoff_t);
+	void (*flush_area)(unsigned);
+};
+
+extern int frontswap_enabled;
+extern struct frontswap_ops
+	frontswap_register_ops(struct frontswap_ops *ops);
+extern void frontswap_shrink(unsigned long);
+extern unsigned long frontswap_curr_pages(void);
+
+extern void frontswap_init(unsigned type);
+extern int __frontswap_put_page(struct page *page);
+extern int __frontswap_get_page(struct page *page);
+extern void __frontswap_flush_page(unsigned, pgoff_t);
+extern void __frontswap_flush_area(unsigned);
+
+#ifndef CONFIG_FRONTSWAP
+/* all inline routines become no-ops and all externs are ignored */
+#define frontswap_enabled (0)
+#endif
+
+static inline int frontswap_test(struct swap_info_struct *sis, pgoff_t offset)
+{
+	int ret = 0;
+
+	if (frontswap_enabled && sis->frontswap_map)
+		ret = test_bit(offset % BITS_PER_LONG,
+			&sis->frontswap_map[offset/BITS_PER_LONG]);
+	return ret;
+}
+
+static inline void frontswap_set(struct swap_info_struct *sis, pgoff_t offset)
+{
+	if (frontswap_enabled && sis->frontswap_map)
+		set_bit(offset % BITS_PER_LONG,
+			&sis->frontswap_map[offset/BITS_PER_LONG]);
+}
+
+static inline void frontswap_clear(struct swap_info_struct *sis, pgoff_t offset)
+{
+	if (frontswap_enabled && sis->frontswap_map)
+		clear_bit(offset % BITS_PER_LONG,
+			&sis->frontswap_map[offset/BITS_PER_LONG]);
+}
+
+static inline int frontswap_put_page(struct page *page)
+{
+	int ret = -1;
+
+	if (frontswap_enabled)
+		ret = __frontswap_put_page(page);
+	return ret;
+}
+
+static inline int frontswap_get_page(struct page *page)
+{
+	int ret = -1;
+
+	if (frontswap_enabled)
+		ret = __frontswap_get_page(page);
+	return ret;
+}
+
+static inline void frontswap_flush_page(unsigned type, pgoff_t offset)
+{
+	if (frontswap_enabled)
+		__frontswap_flush_page(type, offset);
+}
+
+static inline void frontswap_flush_area(unsigned type)
+{
+	if (frontswap_enabled)
+		__frontswap_flush_area(type);
+}
+
+#endif /* _LINUX_FRONTSWAP_H */
--- linux-2.6.36-rc5/mm/frontswap.c	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.36-rc5-frontswap/mm/frontswap.c	2010-09-22 09:29:51.000000000 -0600
@@ -0,0 +1,331 @@
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
+#include <linux/sysctl.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
+#include <linux/proc_fs.h>
+#include <linux/security.h>
+#include <linux/capability.h>
+#include <linux/module.h>
+#include <linux/uaccess.h>
+#include <linux/frontswap.h>
+#include <linux/swapfile.h>
+
+/*
+ * frontswap_ops is set by frontswap_register_ops to contain the pointers
+ * to the frontswap "backend" implementation functions.
+ */
+static struct frontswap_ops frontswap_ops;
+
+/*
+ * This global enablement flag reduces overhead on systems where frontswap_ops
+ * has not been registered, so is preferred to the slower alternative: a
+ * function call that checks a non-global.
+ */
+int frontswap_enabled;
+EXPORT_SYMBOL(frontswap_enabled);
+
+/* useful stats available in /sys/kernel/mm/frontswap */
+static unsigned long frontswap_gets;
+static unsigned long frontswap_succ_puts;
+static unsigned long frontswap_failed_puts;
+static unsigned long frontswap_flushes;
+
+/*
+ * register operations for frontswap, returning previous thus allowing
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
+void frontswap_init(unsigned type)
+{
+	if (frontswap_enabled)
+		(*frontswap_ops.init)(type);
+}
+EXPORT_SYMBOL(frontswap_init);
+
+/*
+ * "Put" data from a page to frontswap and associate it with the page's
+ * swaptype and offset.  Page must be locked and in the swap cache.
+ * If frontswap already contains a page with matching swaptype and
+ * offset, the frontswap implmentation may either overwrite the data
+ * and return success or flush the page from frontswap and return failure
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
+	if (frontswap_test(sis, offset))
+		dup = 1;
+	ret = (*frontswap_ops.put_page)(type, offset, page);
+	if (ret == 0) {
+		frontswap_set(sis, offset);
+		frontswap_succ_puts++;
+		if (!dup)
+			sis->frontswap_pages++;
+	} else if (dup) {
+		/*
+		  failed dup always results in automatic flush of
+		  the (older) page from frontswap
+		 */
+		frontswap_clear(sis, offset);
+		sis->frontswap_pages--;
+		frontswap_failed_puts++;
+	} else
+		frontswap_failed_puts++;
+	return ret;
+}
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
+	if (frontswap_test(sis, offset))
+		ret = (*frontswap_ops.get_page)(type, offset, page);
+	if (ret == 0)
+		frontswap_gets++;
+	return ret;
+}
+
+/*
+ * Flush any data from frontswap associated with the specified swaptype
+ * and offset so that a subsequent "get" will fail.
+ */
+void __frontswap_flush_page(unsigned type, pgoff_t offset)
+{
+	struct swap_info_struct *sis = swap_info[type];
+
+	if (frontswap_test(sis, offset)) {
+		(*frontswap_ops.flush_page)(type, offset);
+		sis->frontswap_pages--;
+		frontswap_clear(sis, offset);
+		frontswap_flushes++;
+	}
+}
+
+/*
+ * Flush all data from frontswap associated with all offsets for the
+ * specified swaptype.
+ */
+void __frontswap_flush_area(unsigned type)
+{
+	struct swap_info_struct *sis = swap_info[type];
+
+	(*frontswap_ops.flush_area)(type);
+	sis->frontswap_pages = 0;
+	memset(sis->frontswap_map, 0, sis->max / sizeof(long));
+}
+
+/*
+ * Frontswap, like a true swap device, may unnecessarily retain pages
+ * under certain circumstances; "shrink" frontswap is essentially a
+ * "partial swapoff" and works by calling try_to_unuse to attempt to
+ * unuse enough frontswap pages to attempt to -- subject to memory
+ * constraints -- reduce the number of pages in frontswap
+ */
+void frontswap_shrink(unsigned long target_pages)
+{
+	int wrapped = 0;
+	bool locked = false;
+
+	for (wrapped = 0; wrapped <= 3; wrapped++) {
+
+		struct swap_info_struct *si = NULL;
+		unsigned long total_pages = 0, total_pages_to_unuse;
+		unsigned long pages = 0, unuse_pages = 0;
+		int type;
+
+		/*
+		 * we don't want to hold swap_lock while doing a very
+		 * lengthy try_to_unuse, but swap_list may change
+		 * so restart scan from swap_list.head each time
+		 */
+		spin_lock(&swap_lock);
+		locked = true;
+		total_pages = 0;
+		for (type = swap_list.head; type >= 0; type = si->next) {
+			si = swap_info[type];
+			total_pages += si->frontswap_pages;
+		}
+		if (total_pages <= target_pages)
+			goto out;
+		total_pages_to_unuse = total_pages - target_pages;
+		for (type = swap_list.head; type >= 0; type = si->next) {
+			si = swap_info[type];
+			if (total_pages_to_unuse < si->frontswap_pages)
+				pages = unuse_pages = total_pages_to_unuse;
+			else {
+				pages = si->frontswap_pages;
+				unuse_pages = 0; /* unuse all */
+			}
+			if (security_vm_enough_memory_kern(pages))
+				continue;
+			vm_unacct_memory(pages);
+			break;
+		}
+		if (type < 0)
+			goto out;
+		locked = false;
+		spin_unlock(&swap_lock);
+		try_to_unuse(type, true, unuse_pages);
+	}
+
+out:
+	if (locked)
+		spin_unlock(&swap_lock);
+	return;
+}
+EXPORT_SYMBOL(frontswap_shrink);
+
+/*
+ * count and return the number of pages frontswap pages across all
+ * swap devices.  This is exported so that a kernel module can
+ * determine current usage without reading sysfs.
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
+		totalpages += si->frontswap_pages;
+	}
+	spin_unlock(&swap_lock);
+	return totalpages;
+}
+EXPORT_SYMBOL(frontswap_curr_pages);
+
+#ifdef CONFIG_SYSFS
+
+/* see Documentation/ABI/xxx/sysfs-kernel-mm-frontswap */
+
+#define FRONTSWAP_ATTR_RO(_name) \
+	static struct kobj_attribute _name##_attr = __ATTR_RO(_name)
+#define FRONTSWAP_ATTR(_name) \
+	static struct kobj_attribute _name##_attr = \
+		__ATTR(_name, 0644, _name##_show, _name##_store)
+
+static ssize_t curr_pages_show(struct kobject *kobj,
+			       struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", frontswap_curr_pages());
+}
+
+static ssize_t curr_pages_store(struct kobject *kobj,
+			       struct kobj_attribute *attr,
+			       const char *buf, size_t count)
+{
+	unsigned long target_pages;
+	int err;
+
+	err = strict_strtoul(buf, 10, &target_pages);
+	if (err)
+		return -EINVAL;
+
+	frontswap_shrink(target_pages);
+
+	return count;
+}
+FRONTSWAP_ATTR(curr_pages);
+
+static ssize_t succ_puts_show(struct kobject *kobj,
+			       struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", frontswap_succ_puts);
+}
+FRONTSWAP_ATTR_RO(succ_puts);
+
+static ssize_t failed_puts_show(struct kobject *kobj,
+			       struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", frontswap_failed_puts);
+}
+FRONTSWAP_ATTR_RO(failed_puts);
+
+static ssize_t gets_show(struct kobject *kobj,
+			       struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", frontswap_gets);
+}
+FRONTSWAP_ATTR_RO(gets);
+
+static ssize_t flushes_show(struct kobject *kobj,
+			       struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", frontswap_flushes);
+}
+FRONTSWAP_ATTR_RO(flushes);
+
+static struct attribute *frontswap_attrs[] = {
+	&curr_pages_attr.attr,
+	&succ_puts_attr.attr,
+	&failed_puts_attr.attr,
+	&gets_attr.attr,
+	&flushes_attr.attr,
+	NULL,
+};
+
+static struct attribute_group frontswap_attr_group = {
+	.attrs = frontswap_attrs,
+	.name = "frontswap",
+};
+
+#endif /* CONFIG_SYSFS */
+
+static int __init init_frontswap(void)
+{
+#ifdef CONFIG_SYSFS
+	int err;
+
+	err = sysfs_create_group(mm_kobj, &frontswap_attr_group);
+#endif /* CONFIG_SYSFS */
+	return 0;
+}
+
+static void __exit exit_frontswap(void)
+{
+	frontswap_shrink(0UL);
+}
+
+module_init(init_frontswap);
+module_exit(exit_frontswap);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
