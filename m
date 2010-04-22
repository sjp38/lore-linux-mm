Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 64C466B01F4
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 09:43:54 -0400 (EDT)
Date: Thu, 22 Apr 2010 06:43:29 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Frontswap [PATCH 2/4] (was Transcendent Memory): core code
Message-ID: <20100422134329.GA3024@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Frontswap [PATCH 2/4] (was Transcendent Memory): core code

Core frontswap_ops structure and functions

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Diffstat:
 include/linux/frontswap.h                |   98 ++++++
 mm/frontswap.c                           |  301 +++++++++++++++++++++
 2 files changed, 399 insertions(+)

--- linux-2.6.34-rc5/include/linux/frontswap.h	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.34-rc5-frontswap/include/linux/frontswap.h	2010-04-21 08:59:40.000000000 -0600
@@ -0,0 +1,98 @@
+#ifndef _LINUX_FRONTSWAP_H
+#define _LINUX_FRONTSWAP_H
+
+#include <linux/swap.h>
+#include <linux/mm.h>
+
+struct frontswap_ops {
+	int (*init)(unsigned long);
+	int (*put_page)(int, unsigned, unsigned long, struct page *);
+	int (*get_page)(int, unsigned, unsigned long, struct page *);
+	void (*flush_page)(int, unsigned, unsigned long);
+	void (*flush_area)(int, unsigned);
+};
+
+extern int frontswap_poolid;
+
+extern struct frontswap_ops *frontswap_ops;
+extern void frontswap_shrink(unsigned long);
+extern unsigned long frontswap_curr_pages(void);
+
+extern int __frontswap_put_page(struct page *page);
+extern int __frontswap_get_page(struct page *page);
+extern void __frontswap_flush_page(unsigned type, unsigned long offset);
+extern void __frontswap_flush_area(unsigned type);
+
+#ifndef CONFIG_FRONTSWAP
+/* all inline routines become no-ops and all externs are ignored */
+#define frontswap_ops ((struct frontswap_ops *)NULL)
+#endif
+
+static inline int frontswap_test(struct swap_info_struct *sis,
+				unsigned long offset)
+{
+	int ret = 0;
+
+	if (frontswap_ops && sis->frontswap_map)
+		ret = test_bit(offset % BITS_PER_LONG,
+			&sis->frontswap_map[offset/BITS_PER_LONG]);
+	return ret;
+}
+
+static inline void frontswap_set(struct swap_info_struct *sis,
+				unsigned long offset)
+{
+	if (frontswap_ops && sis->frontswap_map)
+		set_bit(offset % BITS_PER_LONG,
+			&sis->frontswap_map[offset/BITS_PER_LONG]);
+}
+
+static inline void frontswap_clear(struct swap_info_struct *sis,
+				unsigned long offset)
+{
+	if (frontswap_ops && sis->frontswap_map)
+		clear_bit(offset % BITS_PER_LONG,
+			&sis->frontswap_map[offset/BITS_PER_LONG]);
+}
+
+
+static inline void frontswap_init(void)
+{
+	if (frontswap_ops) {
+		/* only need one poolid regardless of number of swap types */
+		if (frontswap_poolid < 0)
+			frontswap_poolid = (*frontswap_ops->init)(PAGE_SIZE);
+	}
+}
+
+static inline int frontswap_put_page(struct page *page)
+{
+	int ret = 0;
+
+	if (frontswap_ops && frontswap_poolid >= 0)
+		ret = __frontswap_put_page(page);
+	return ret;
+}
+
+static inline int frontswap_get_page(struct page *page)
+{
+	int ret = 0;
+
+	if (frontswap_ops && frontswap_poolid >= 0)
+		ret = __frontswap_get_page(page);
+	return ret;
+}
+
+static inline void frontswap_flush_page(unsigned type, unsigned long offset)
+{
+	if (frontswap_ops && frontswap_poolid >= 0)
+		__frontswap_flush_page(type, offset);
+}
+
+static inline void frontswap_flush_area(unsigned type)
+{
+	if (frontswap_ops && frontswap_poolid >= 0)
+		__frontswap_flush_area(type);
+}
+
+#endif /* _LINUX_FRONTSWAP_H */
--- linux-2.6.34-rc5/mm/frontswap.c	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.34-rc5-frontswap/mm/frontswap.c	2010-04-21 08:59:40.000000000 -0600
@@ -0,0 +1,301 @@
+/* mm/frontswap.c
+
+ Copyright (C) 2009-2010 Oracle Corp.  All rights reserved.
+ Author: Dan Magenheimer
+
+ Frontswap is so named because it can be thought of as the opposite of
+ a "backing" store for a swap device.  The storage is assumed to be
+ a synchronous concurrency-safe page-oriented pseudo-RAM device (such as
+ Xen's Transcendent Memory, aka "tmem", or in-kernel compressed memory,
+ aka "zmem", or other RAM-like devices) which is not directly accessible
+ or addressable by the kernel and is of unknown and possibly time-varying
+ size.  This pseudo-RAM device links itself to frontswap by setting the
+ frontswap_ops pointer appropriately and the functions it provides must
+ conform to certain policies as follows:
+
+ An "init" prepares the pseudo-RAM to receive frontswap pages and returns
+ a non-negative pool id, used for all swap device numbers (aka "type").
+ A "put_page" will copy the page to pseudo-RAM and associate it with
+ the type and offset associated with the page. A "get_page" will copy the
+ page, if found, from pseudo-RAM into kernel memory, but will NOT remove
+ the page from pseudo-RAM.  A "flush_page" will remove the page from
+ pseudo-RAM and a "flush_area" will remove ALL pages associated with the
+ swap type (e.g., like swapoff) and notify the pseudo-RAM device to refuse
+ further puts with that swap type.
+
+ Once a page is successfully put, a matching get on the page will always
+ succeed.  So when the kernel finds itself in a situation where it needs
+ to swap out a page, it first attempts to use frontswap.  If the put returns
+ non-zero, the data has been successfully saved to pseudo-RAM and
+ a disk write and, if the data is later read back, a disk read are avoided.
+ If a put returns zero, pseudo-RAM has rejected the data, and the page can
+ be written to swap as usual.
+
+ Note that if a page is put and the page already exists in pseudo-RAM
+ (a "duplicate" put), either the put succeeds and the data is overwritten,
+ or the put fails AND the page is flushed.  This ensures stale data may
+ never be obtained from psuedo-RAM.
+
+ This work is licensed under the terms of the GNU GPL, version 2.
+
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
+#include <linux/frontswap.h>
+#include <linux/swapfile.h>
+
+struct frontswap_ops *frontswap_ops;
+EXPORT_SYMBOL(frontswap_ops);
+
+int frontswap_poolid = -1;
+EXPORT_SYMBOL(frontswap_poolid);
+
+/* useful stats available via /sys/kernel/mm/frontswap */
+static unsigned long gets;
+static unsigned long succ_puts;
+static unsigned long failed_puts;
+static unsigned long flushes;
+
+int __frontswap_put_page(struct page *page)
+{
+	int ret = 0, dup = 0;
+	swp_entry_t entry = { .val = page_private(page), };
+	int type = swp_type(entry);
+	struct swap_info_struct *sis = swap_info[type];
+	unsigned long offset = (unsigned long)swp_offset(entry);
+
+	if (frontswap_test(sis, offset))
+		dup = 1;
+	ret = (*frontswap_ops->put_page)(frontswap_poolid, type, offset, page);
+	if (ret == 1) {
+		frontswap_set(sis, offset);
+		succ_puts++;
+		if (!dup)
+			sis->frontswap_pages++;
+	} else if (dup) {
+		/*
+		  failed dup always results in automatic flush of
+		  the (older) page from frontswap
+		 */
+		frontswap_clear(sis, offset);
+		sis->frontswap_pages--;
+		failed_puts++;
+	} else
+		failed_puts++;
+	return ret;
+}
+
+int __frontswap_get_page(struct page *page)
+{
+	int ret = 0;
+	swp_entry_t entry = { .val = page_private(page), };
+	int type = swp_type(entry);
+	struct swap_info_struct *sis = swap_info[type];
+	unsigned long offset = (unsigned long)swp_offset(entry);
+
+	if (frontswap_test(sis, offset))
+		ret = (*frontswap_ops->get_page)(frontswap_poolid,
+						 type, offset, page);
+	if (ret == 1)
+		gets++;
+	return ret;
+}
+
+void __frontswap_flush_page(unsigned type, unsigned long offset)
+{
+	struct swap_info_struct *sis = swap_info[type];
+
+	if (frontswap_test(sis, offset)) {
+		(*frontswap_ops->flush_page)(frontswap_poolid, type, offset);
+		sis->frontswap_pages--;
+		frontswap_clear(sis, offset);
+		flushes++;
+	}
+}
+
+void __frontswap_flush_area(unsigned type)
+{
+	struct swap_info_struct *sis = swap_info[type];
+
+	(*frontswap_ops->flush_area)(frontswap_poolid, type);
+	sis->frontswap_pages = 0;
+	memset(sis->frontswap_map, 0, sis->max / sizeof(long));
+}
+
+/*
+ * frontswap_shrink - try_to_unuse frontswap pages to target.  Frontswap,
+ *  like a true swapdisk, may unnecessarily retain pages under certain
+ *  circumstances; shrinking can be periodically done to reduce this but
+ *  target_pages should be ramped down slowly and judiciously to avoid OOMs
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
+		current->flags |= PF_OOM_ORIGIN;
+		try_to_unuse(type, true, unuse_pages);
+		current->flags &= ~PF_OOM_ORIGIN;
+	}
+
+out:
+	if (locked)
+		spin_unlock(&swap_lock);
+	return;
+}
+EXPORT_SYMBOL(frontswap_shrink);
+
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
+	return sprintf(buf, "%lu\n", succ_puts);
+}
+FRONTSWAP_ATTR_RO(succ_puts);
+
+static ssize_t failed_puts_show(struct kobject *kobj,
+			       struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", failed_puts);
+}
+FRONTSWAP_ATTR_RO(failed_puts);
+
+static ssize_t gets_show(struct kobject *kobj,
+			       struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", gets);
+}
+FRONTSWAP_ATTR_RO(gets);
+
+static ssize_t flushes_show(struct kobject *kobj,
+			       struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", flushes);
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
