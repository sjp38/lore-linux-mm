Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 45B1D6B006C
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 18:36:04 -0400 (EDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 3/3] Move to new codebase for ramster, re-merged with new zcache codebase.
Date: Thu, 16 Aug 2012 15:31:33 -0700
Message-Id: <1345156293-18852-4-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1345156293-18852-1-git-send-email-dan.magenheimer@oracle.com>
References: <1345156293-18852-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, dan.magenheimer@oracle.com

This new ramster codebase is now built on and as a subdirectory of zcache.
Ramster extends zcache to allow pages compressed via zcache to be
"load-balanced" across machines in a cluster.  Control and data communication
is done via kernel sockets, and cluster configuration and management is
heavily leveraged from the ocfs2 cluster filesystem.

There are no new features since the codebase introduced into staging at 3.4.
Some cleanup was performed though:
 1) Interfaces directly with new zbud
 2) Debugfs now used instead of sysfs where possible.  Sysfs still
    used where necessary for userland cluster configuration.

Ramster is very much a work-in-progress but also does really work!

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/zcache/Kconfig                     |   18 +
 drivers/staging/zcache/Makefile                    |    4 +
 drivers/staging/zcache/ramster/heartbeat.c         |  462 ++++
 drivers/staging/zcache/ramster/heartbeat.h         |   87 +
 drivers/staging/zcache/ramster/masklog.c           |  155 ++
 drivers/staging/zcache/ramster/masklog.h           |  220 ++
 drivers/staging/zcache/ramster/nodemanager.c       |  995 +++++++++
 drivers/staging/zcache/ramster/nodemanager.h       |   88 +
 drivers/staging/zcache/ramster/r2net.c             |  414 ++++
 drivers/staging/zcache/ramster/ramster.c           |  985 +++++++++
 drivers/staging/zcache/ramster/ramster.h           |  161 ++
 .../staging/zcache/ramster/ramster_nodemanager.h   |   39 +
 drivers/staging/zcache/ramster/tcp.c               | 2253 ++++++++++++++++++++
 drivers/staging/zcache/ramster/tcp.h               |  159 ++
 drivers/staging/zcache/ramster/tcp_internal.h      |  248 +++
 15 files changed, 6288 insertions(+), 0 deletions(-)
 create mode 100644 drivers/staging/zcache/ramster/heartbeat.c
 create mode 100644 drivers/staging/zcache/ramster/heartbeat.h
 create mode 100644 drivers/staging/zcache/ramster/masklog.c
 create mode 100644 drivers/staging/zcache/ramster/masklog.h
 create mode 100644 drivers/staging/zcache/ramster/nodemanager.c
 create mode 100644 drivers/staging/zcache/ramster/nodemanager.h
 create mode 100644 drivers/staging/zcache/ramster/r2net.c
 create mode 100644 drivers/staging/zcache/ramster/ramster.c
 create mode 100644 drivers/staging/zcache/ramster/ramster.h
 create mode 100644 drivers/staging/zcache/ramster/ramster_nodemanager.h
 create mode 100644 drivers/staging/zcache/ramster/tcp.c
 create mode 100644 drivers/staging/zcache/ramster/tcp.h
 create mode 100644 drivers/staging/zcache/ramster/tcp_internal.h

diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kconfig
index 0cd7460..cb7f9dd 100644
--- a/drivers/staging/zcache/Kconfig
+++ b/drivers/staging/zcache/Kconfig
@@ -13,3 +13,21 @@ config ZCACHE
 	  compression and an in-kernel implementation of transcendent
 	  memory to store clean page cache pages and swap in RAM,
 	  providing a noticeable reduction in disk I/O.
+
+config RAMSTER
+	bool "Cross-machine RAM capacity sharing, aka peer-to-peer tmem"
+	depends on CRYPTO=y && CONFIGFS_FS=y && SYSFS=y && !HIGHMEM
+	select ZCACHE
+	select CLEANCACHE
+	select FRONTSWAP
+	select CRYPTO_LZO
+	# must ensure struct page is 8-byte aligned
+	select HAVE_ALIGNED_STRUCT_PAGE if !64_BIT
+	default n
+	help
+	  RAMster allows RAM on other machines in a cluster to be utilized
+	  dynamically and symmetrically instead of swapping to a local swap
+	  disk, thus improving performance on memory-constrained workloads
+	  while minimizing total RAM across the cluster.  RAMster, like
+	  zcache, compresses swap pages into local RAM, but then remotifies
+	  the compressed pages to another node in the RAMster cluster.
diff --git a/drivers/staging/zcache/Makefile b/drivers/staging/zcache/Makefile
index 30ac53b..4711049 100644
--- a/drivers/staging/zcache/Makefile
+++ b/drivers/staging/zcache/Makefile
@@ -1,2 +1,6 @@
 zcache-y	:=		zcache-main.o tmem.o zbud.o
+zcache-$(CONFIG_RAMSTER)	+=	ramster/ramster.o ramster/r2net.o
+zcache-$(CONFIG_RAMSTER)	+=	ramster/nodemanager.o ramster/tcp.o
+zcache-$(CONFIG_RAMSTER)	+=	ramster/heartbeat.o ramster/masklog.o
+
 obj-$(CONFIG_ZCACHE)	+=	zcache.o
diff --git a/drivers/staging/zcache/ramster/heartbeat.c b/drivers/staging/zcache/ramster/heartbeat.c
new file mode 100644
index 0000000..75d3fe8
--- /dev/null
+++ b/drivers/staging/zcache/ramster/heartbeat.c
@@ -0,0 +1,462 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * Copyright (C) 2004, 2005, 2012 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/configfs.h>
+
+#include "heartbeat.h"
+#include "tcp.h"
+#include "nodemanager.h"
+
+#include "masklog.h"
+
+/*
+ * The first heartbeat pass had one global thread that would serialize all hb
+ * callback calls.  This global serializing sem should only be removed once
+ * we've made sure that all callees can deal with being called concurrently
+ * from multiple hb region threads.
+ */
+static DECLARE_RWSEM(r2hb_callback_sem);
+
+/*
+ * multiple hb threads are watching multiple regions.  A node is live
+ * whenever any of the threads sees activity from the node in its region.
+ */
+static DEFINE_SPINLOCK(r2hb_live_lock);
+static unsigned long r2hb_live_node_bitmap[BITS_TO_LONGS(R2NM_MAX_NODES)];
+
+static struct r2hb_callback {
+	struct list_head list;
+} r2hb_callbacks[R2HB_NUM_CB];
+
+enum r2hb_heartbeat_modes {
+	R2HB_HEARTBEAT_LOCAL		= 0,
+	R2HB_HEARTBEAT_GLOBAL,
+	R2HB_HEARTBEAT_NUM_MODES,
+};
+
+char *r2hb_heartbeat_mode_desc[R2HB_HEARTBEAT_NUM_MODES] = {
+		"local",	/* R2HB_HEARTBEAT_LOCAL */
+		"global",	/* R2HB_HEARTBEAT_GLOBAL */
+};
+
+unsigned int r2hb_dead_threshold = R2HB_DEFAULT_DEAD_THRESHOLD;
+unsigned int r2hb_heartbeat_mode = R2HB_HEARTBEAT_LOCAL;
+
+/* Only sets a new threshold if there are no active regions.
+ *
+ * No locking or otherwise interesting code is required for reading
+ * r2hb_dead_threshold as it can't change once regions are active and
+ * it's not interesting to anyone until then anyway. */
+static void r2hb_dead_threshold_set(unsigned int threshold)
+{
+	if (threshold > R2HB_MIN_DEAD_THRESHOLD) {
+		spin_lock(&r2hb_live_lock);
+		r2hb_dead_threshold = threshold;
+		spin_unlock(&r2hb_live_lock);
+	}
+}
+
+static int r2hb_global_hearbeat_mode_set(unsigned int hb_mode)
+{
+	int ret = -1;
+
+	if (hb_mode < R2HB_HEARTBEAT_NUM_MODES) {
+		spin_lock(&r2hb_live_lock);
+		r2hb_heartbeat_mode = hb_mode;
+		ret = 0;
+		spin_unlock(&r2hb_live_lock);
+	}
+
+	return ret;
+}
+
+void r2hb_exit(void)
+{
+}
+
+int r2hb_init(void)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(r2hb_callbacks); i++)
+		INIT_LIST_HEAD(&r2hb_callbacks[i].list);
+
+	memset(r2hb_live_node_bitmap, 0, sizeof(r2hb_live_node_bitmap));
+
+	return 0;
+}
+
+/* if we're already in a callback then we're already serialized by the sem */
+static void r2hb_fill_node_map_from_callback(unsigned long *map,
+					     unsigned bytes)
+{
+	BUG_ON(bytes < (BITS_TO_LONGS(R2NM_MAX_NODES) * sizeof(unsigned long)));
+
+	memcpy(map, &r2hb_live_node_bitmap, bytes);
+}
+
+/*
+ * get a map of all nodes that are heartbeating in any regions
+ */
+void r2hb_fill_node_map(unsigned long *map, unsigned bytes)
+{
+	/* callers want to serialize this map and callbacks so that they
+	 * can trust that they don't miss nodes coming to the party */
+	down_read(&r2hb_callback_sem);
+	spin_lock(&r2hb_live_lock);
+	r2hb_fill_node_map_from_callback(map, bytes);
+	spin_unlock(&r2hb_live_lock);
+	up_read(&r2hb_callback_sem);
+}
+EXPORT_SYMBOL_GPL(r2hb_fill_node_map);
+
+/*
+ * heartbeat configfs bits.  The heartbeat set is a default set under
+ * the cluster set in nodemanager.c.
+ */
+
+/* heartbeat set */
+
+struct r2hb_hb_group {
+	struct config_group hs_group;
+	/* some stuff? */
+};
+
+static struct r2hb_hb_group *to_r2hb_hb_group(struct config_group *group)
+{
+	return group ?
+		container_of(group, struct r2hb_hb_group, hs_group)
+		: NULL;
+}
+
+static struct config_item r2hb_config_item;
+
+static struct config_item *r2hb_hb_group_make_item(struct config_group *group,
+							  const char *name)
+{
+	int ret;
+
+	if (strlen(name) > R2HB_MAX_REGION_NAME_LEN) {
+		ret = -ENAMETOOLONG;
+		goto free;
+	}
+
+	config_item_put(&r2hb_config_item);
+
+	return &r2hb_config_item;
+free:
+	return ERR_PTR(ret);
+}
+
+static void r2hb_hb_group_drop_item(struct config_group *group,
+					   struct config_item *item)
+{
+	if (r2hb_global_heartbeat_active()) {
+		pr_notice("ramster: Heartbeat %s on region %s (%s)\n",
+			"stopped/aborted", config_item_name(item),
+			"no region");
+	}
+
+	config_item_put(item);
+}
+
+struct r2hb_hb_group_attribute {
+	struct configfs_attribute attr;
+	ssize_t (*show)(struct r2hb_hb_group *, char *);
+	ssize_t (*store)(struct r2hb_hb_group *, const char *, size_t);
+};
+
+static ssize_t r2hb_hb_group_show(struct config_item *item,
+					 struct configfs_attribute *attr,
+					 char *page)
+{
+	struct r2hb_hb_group *reg = to_r2hb_hb_group(to_config_group(item));
+	struct r2hb_hb_group_attribute *r2hb_hb_group_attr =
+		container_of(attr, struct r2hb_hb_group_attribute, attr);
+	ssize_t ret = 0;
+
+	if (r2hb_hb_group_attr->show)
+		ret = r2hb_hb_group_attr->show(reg, page);
+	return ret;
+}
+
+static ssize_t r2hb_hb_group_store(struct config_item *item,
+					  struct configfs_attribute *attr,
+					  const char *page, size_t count)
+{
+	struct r2hb_hb_group *reg = to_r2hb_hb_group(to_config_group(item));
+	struct r2hb_hb_group_attribute *r2hb_hb_group_attr =
+		container_of(attr, struct r2hb_hb_group_attribute, attr);
+	ssize_t ret = -EINVAL;
+
+	if (r2hb_hb_group_attr->store)
+		ret = r2hb_hb_group_attr->store(reg, page, count);
+	return ret;
+}
+
+static ssize_t r2hb_hb_group_threshold_show(struct r2hb_hb_group *group,
+						     char *page)
+{
+	return sprintf(page, "%u\n", r2hb_dead_threshold);
+}
+
+static ssize_t r2hb_hb_group_threshold_store(struct r2hb_hb_group *group,
+						    const char *page,
+						    size_t count)
+{
+	unsigned long tmp;
+	char *p = (char *)page;
+	int err;
+
+	err = kstrtoul(p, 10, &tmp);
+	if (err)
+		return err;
+
+	/* this will validate ranges for us. */
+	r2hb_dead_threshold_set((unsigned int) tmp);
+
+	return count;
+}
+
+static
+ssize_t r2hb_hb_group_mode_show(struct r2hb_hb_group *group,
+				       char *page)
+{
+	return sprintf(page, "%s\n",
+		       r2hb_heartbeat_mode_desc[r2hb_heartbeat_mode]);
+}
+
+static
+ssize_t r2hb_hb_group_mode_store(struct r2hb_hb_group *group,
+					const char *page, size_t count)
+{
+	unsigned int i;
+	int ret;
+	size_t len;
+
+	len = (page[count - 1] == '\n') ? count - 1 : count;
+	if (!len)
+		return -EINVAL;
+
+	for (i = 0; i < R2HB_HEARTBEAT_NUM_MODES; ++i) {
+		if (strnicmp(page, r2hb_heartbeat_mode_desc[i], len))
+			continue;
+
+		ret = r2hb_global_hearbeat_mode_set(i);
+		if (!ret)
+			pr_notice("ramster: Heartbeat mode set to %s\n",
+			       r2hb_heartbeat_mode_desc[i]);
+		return count;
+	}
+
+	return -EINVAL;
+
+}
+
+static struct r2hb_hb_group_attribute r2hb_hb_group_attr_threshold = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "dead_threshold",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= r2hb_hb_group_threshold_show,
+	.store	= r2hb_hb_group_threshold_store,
+};
+
+static struct r2hb_hb_group_attribute r2hb_hb_group_attr_mode = {
+	.attr   = { .ca_owner = THIS_MODULE,
+		.ca_name = "mode",
+		.ca_mode = S_IRUGO | S_IWUSR },
+	.show   = r2hb_hb_group_mode_show,
+	.store  = r2hb_hb_group_mode_store,
+};
+
+static struct configfs_attribute *r2hb_hb_group_attrs[] = {
+	&r2hb_hb_group_attr_threshold.attr,
+	&r2hb_hb_group_attr_mode.attr,
+	NULL,
+};
+
+static struct configfs_item_operations r2hb_hearbeat_group_item_ops = {
+	.show_attribute		= r2hb_hb_group_show,
+	.store_attribute	= r2hb_hb_group_store,
+};
+
+static struct configfs_group_operations r2hb_hb_group_group_ops = {
+	.make_item	= r2hb_hb_group_make_item,
+	.drop_item	= r2hb_hb_group_drop_item,
+};
+
+static struct config_item_type r2hb_hb_group_type = {
+	.ct_group_ops	= &r2hb_hb_group_group_ops,
+	.ct_item_ops	= &r2hb_hearbeat_group_item_ops,
+	.ct_attrs	= r2hb_hb_group_attrs,
+	.ct_owner	= THIS_MODULE,
+};
+
+/* this is just here to avoid touching group in heartbeat.h which the
+ * entire damn world #includes */
+struct config_group *r2hb_alloc_hb_set(void)
+{
+	struct r2hb_hb_group *hs = NULL;
+	struct config_group *ret = NULL;
+
+	hs = kzalloc(sizeof(struct r2hb_hb_group), GFP_KERNEL);
+	if (hs == NULL)
+		goto out;
+
+	config_group_init_type_name(&hs->hs_group, "heartbeat",
+				    &r2hb_hb_group_type);
+
+	ret = &hs->hs_group;
+out:
+	if (ret == NULL)
+		kfree(hs);
+	return ret;
+}
+
+void r2hb_free_hb_set(struct config_group *group)
+{
+	struct r2hb_hb_group *hs = to_r2hb_hb_group(group);
+	kfree(hs);
+}
+
+/* hb callback registration and issuing */
+
+static struct r2hb_callback *hbcall_from_type(enum r2hb_callback_type type)
+{
+	if (type == R2HB_NUM_CB)
+		return ERR_PTR(-EINVAL);
+
+	return &r2hb_callbacks[type];
+}
+
+void r2hb_setup_callback(struct r2hb_callback_func *hc,
+			 enum r2hb_callback_type type,
+			 r2hb_cb_func *func,
+			 void *data,
+			 int priority)
+{
+	INIT_LIST_HEAD(&hc->hc_item);
+	hc->hc_func = func;
+	hc->hc_data = data;
+	hc->hc_priority = priority;
+	hc->hc_type = type;
+	hc->hc_magic = R2HB_CB_MAGIC;
+}
+EXPORT_SYMBOL_GPL(r2hb_setup_callback);
+
+int r2hb_register_callback(const char *region_uuid,
+			   struct r2hb_callback_func *hc)
+{
+	struct r2hb_callback_func *tmp;
+	struct list_head *iter;
+	struct r2hb_callback *hbcall;
+	int ret;
+
+	BUG_ON(hc->hc_magic != R2HB_CB_MAGIC);
+	BUG_ON(!list_empty(&hc->hc_item));
+
+	hbcall = hbcall_from_type(hc->hc_type);
+	if (IS_ERR(hbcall)) {
+		ret = PTR_ERR(hbcall);
+		goto out;
+	}
+
+	down_write(&r2hb_callback_sem);
+
+	list_for_each(iter, &hbcall->list) {
+		tmp = list_entry(iter, struct r2hb_callback_func, hc_item);
+		if (hc->hc_priority < tmp->hc_priority) {
+			list_add_tail(&hc->hc_item, iter);
+			break;
+		}
+	}
+	if (list_empty(&hc->hc_item))
+		list_add_tail(&hc->hc_item, &hbcall->list);
+
+	up_write(&r2hb_callback_sem);
+	ret = 0;
+out:
+	mlog(ML_CLUSTER, "returning %d on behalf of %p for funcs %p\n",
+	     ret, __builtin_return_address(0), hc);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(r2hb_register_callback);
+
+void r2hb_unregister_callback(const char *region_uuid,
+			      struct r2hb_callback_func *hc)
+{
+	BUG_ON(hc->hc_magic != R2HB_CB_MAGIC);
+
+	mlog(ML_CLUSTER, "on behalf of %p for funcs %p\n",
+	     __builtin_return_address(0), hc);
+
+	/* XXX Can this happen _with_ a region reference? */
+	if (list_empty(&hc->hc_item))
+		return;
+
+	down_write(&r2hb_callback_sem);
+
+	list_del_init(&hc->hc_item);
+
+	up_write(&r2hb_callback_sem);
+}
+EXPORT_SYMBOL_GPL(r2hb_unregister_callback);
+
+int r2hb_check_node_heartbeating_from_callback(u8 node_num)
+{
+	unsigned long testing_map[BITS_TO_LONGS(R2NM_MAX_NODES)];
+
+	r2hb_fill_node_map_from_callback(testing_map, sizeof(testing_map));
+	if (!test_bit(node_num, testing_map)) {
+		mlog(ML_HEARTBEAT,
+		     "node (%u) does not have heartbeating enabled.\n",
+		     node_num);
+		return 0;
+	}
+
+	return 1;
+}
+EXPORT_SYMBOL_GPL(r2hb_check_node_heartbeating_from_callback);
+
+void r2hb_stop_all_regions(void)
+{
+}
+EXPORT_SYMBOL_GPL(r2hb_stop_all_regions);
+
+/*
+ * this is just a hack until we get the plumbing which flips file systems
+ * read only and drops the hb ref instead of killing the node dead.
+ */
+int r2hb_global_heartbeat_active(void)
+{
+	return (r2hb_heartbeat_mode == R2HB_HEARTBEAT_GLOBAL);
+}
+EXPORT_SYMBOL(r2hb_global_heartbeat_active);
+
+/* added for RAMster */
+void r2hb_manual_set_node_heartbeating(int node_num)
+{
+	if (node_num < R2NM_MAX_NODES)
+		set_bit(node_num, r2hb_live_node_bitmap);
+}
+EXPORT_SYMBOL(r2hb_manual_set_node_heartbeating);
diff --git a/drivers/staging/zcache/ramster/heartbeat.h b/drivers/staging/zcache/ramster/heartbeat.h
new file mode 100644
index 0000000..6cbc775
--- /dev/null
+++ b/drivers/staging/zcache/ramster/heartbeat.h
@@ -0,0 +1,87 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * heartbeat.h
+ *
+ * Function prototypes
+ *
+ * Copyright (C) 2004 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ */
+
+#ifndef R2CLUSTER_HEARTBEAT_H
+#define R2CLUSTER_HEARTBEAT_H
+
+#define R2HB_REGION_TIMEOUT_MS		2000
+
+#define R2HB_MAX_REGION_NAME_LEN	32
+
+/* number of changes to be seen as live */
+#define R2HB_LIVE_THRESHOLD	   2
+/* number of equal samples to be seen as dead */
+extern unsigned int r2hb_dead_threshold;
+#define R2HB_DEFAULT_DEAD_THRESHOLD	   31
+/* Otherwise MAX_WRITE_TIMEOUT will be zero... */
+#define R2HB_MIN_DEAD_THRESHOLD	  2
+#define R2HB_MAX_WRITE_TIMEOUT_MS \
+	(R2HB_REGION_TIMEOUT_MS * (r2hb_dead_threshold - 1))
+
+#define R2HB_CB_MAGIC		0x51d1e4ec
+
+/* callback stuff */
+enum r2hb_callback_type {
+	R2HB_NODE_DOWN_CB = 0,
+	R2HB_NODE_UP_CB,
+	R2HB_NUM_CB
+};
+
+struct r2nm_node;
+typedef void (r2hb_cb_func)(struct r2nm_node *, int, void *);
+
+struct r2hb_callback_func {
+	u32			hc_magic;
+	struct list_head	hc_item;
+	r2hb_cb_func		*hc_func;
+	void			*hc_data;
+	int			hc_priority;
+	enum r2hb_callback_type hc_type;
+};
+
+struct config_group *r2hb_alloc_hb_set(void);
+void r2hb_free_hb_set(struct config_group *group);
+
+void r2hb_setup_callback(struct r2hb_callback_func *hc,
+			 enum r2hb_callback_type type,
+			 r2hb_cb_func *func,
+			 void *data,
+			 int priority);
+int r2hb_register_callback(const char *region_uuid,
+			   struct r2hb_callback_func *hc);
+void r2hb_unregister_callback(const char *region_uuid,
+			      struct r2hb_callback_func *hc);
+void r2hb_fill_node_map(unsigned long *map,
+			unsigned bytes);
+void r2hb_exit(void);
+int r2hb_init(void);
+int r2hb_check_node_heartbeating_from_callback(u8 node_num);
+void r2hb_stop_all_regions(void);
+int r2hb_get_all_regions(char *region_uuids, u8 numregions);
+int r2hb_global_heartbeat_active(void);
+void r2hb_manual_set_node_heartbeating(int);
+
+#endif /* R2CLUSTER_HEARTBEAT_H */
diff --git a/drivers/staging/zcache/ramster/masklog.c b/drivers/staging/zcache/ramster/masklog.c
new file mode 100644
index 0000000..1261d85
--- /dev/null
+++ b/drivers/staging/zcache/ramster/masklog.c
@@ -0,0 +1,155 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * Copyright (C) 2004, 2005, 2012 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <linux/string.h>
+#include <linux/uaccess.h>
+
+#include "masklog.h"
+
+struct mlog_bits r2_mlog_and_bits = MLOG_BITS_RHS(MLOG_INITIAL_AND_MASK);
+EXPORT_SYMBOL_GPL(r2_mlog_and_bits);
+struct mlog_bits r2_mlog_not_bits = MLOG_BITS_RHS(0);
+EXPORT_SYMBOL_GPL(r2_mlog_not_bits);
+
+static ssize_t mlog_mask_show(u64 mask, char *buf)
+{
+	char *state;
+
+	if (__mlog_test_u64(mask, r2_mlog_and_bits))
+		state = "allow";
+	else if (__mlog_test_u64(mask, r2_mlog_not_bits))
+		state = "deny";
+	else
+		state = "off";
+
+	return snprintf(buf, PAGE_SIZE, "%s\n", state);
+}
+
+static ssize_t mlog_mask_store(u64 mask, const char *buf, size_t count)
+{
+	if (!strnicmp(buf, "allow", 5)) {
+		__mlog_set_u64(mask, r2_mlog_and_bits);
+		__mlog_clear_u64(mask, r2_mlog_not_bits);
+	} else if (!strnicmp(buf, "deny", 4)) {
+		__mlog_set_u64(mask, r2_mlog_not_bits);
+		__mlog_clear_u64(mask, r2_mlog_and_bits);
+	} else if (!strnicmp(buf, "off", 3)) {
+		__mlog_clear_u64(mask, r2_mlog_not_bits);
+		__mlog_clear_u64(mask, r2_mlog_and_bits);
+	} else
+		return -EINVAL;
+
+	return count;
+}
+
+struct mlog_attribute {
+	struct attribute attr;
+	u64 mask;
+};
+
+#define to_mlog_attr(_attr) container_of(_attr, struct mlog_attribute, attr)
+
+#define define_mask(_name) {			\
+	.attr = {				\
+		.name = #_name,			\
+		.mode = S_IRUGO | S_IWUSR,	\
+	},					\
+	.mask = ML_##_name,			\
+}
+
+static struct mlog_attribute mlog_attrs[MLOG_MAX_BITS] = {
+	define_mask(TCP),
+	define_mask(MSG),
+	define_mask(SOCKET),
+	define_mask(HEARTBEAT),
+	define_mask(HB_BIO),
+	define_mask(DLMFS),
+	define_mask(DLM),
+	define_mask(DLM_DOMAIN),
+	define_mask(DLM_THREAD),
+	define_mask(DLM_MASTER),
+	define_mask(DLM_RECOVERY),
+	define_mask(DLM_GLUE),
+	define_mask(VOTE),
+	define_mask(CONN),
+	define_mask(QUORUM),
+	define_mask(BASTS),
+	define_mask(CLUSTER),
+	define_mask(ERROR),
+	define_mask(NOTICE),
+	define_mask(KTHREAD),
+};
+
+static struct attribute *mlog_attr_ptrs[MLOG_MAX_BITS] = {NULL, };
+
+static ssize_t mlog_show(struct kobject *obj, struct attribute *attr,
+			 char *buf)
+{
+	struct mlog_attribute *mlog_attr = to_mlog_attr(attr);
+
+	return mlog_mask_show(mlog_attr->mask, buf);
+}
+
+static ssize_t mlog_store(struct kobject *obj, struct attribute *attr,
+			  const char *buf, size_t count)
+{
+	struct mlog_attribute *mlog_attr = to_mlog_attr(attr);
+
+	return mlog_mask_store(mlog_attr->mask, buf, count);
+}
+
+static const struct sysfs_ops mlog_attr_ops = {
+	.show  = mlog_show,
+	.store = mlog_store,
+};
+
+static struct kobj_type mlog_ktype = {
+	.default_attrs = mlog_attr_ptrs,
+	.sysfs_ops     = &mlog_attr_ops,
+};
+
+static struct kset mlog_kset = {
+	.kobj   = {.ktype = &mlog_ktype},
+};
+
+int r2_mlog_sys_init(struct kset *r2cb_kset)
+{
+	int i = 0;
+
+	while (mlog_attrs[i].attr.mode) {
+		mlog_attr_ptrs[i] = &mlog_attrs[i].attr;
+		i++;
+	}
+	mlog_attr_ptrs[i] = NULL;
+
+	kobject_set_name(&mlog_kset.kobj, "logmask");
+	mlog_kset.kobj.kset = r2cb_kset;
+	return kset_register(&mlog_kset);
+}
+
+void r2_mlog_sys_shutdown(void)
+{
+	kset_unregister(&mlog_kset);
+}
diff --git a/drivers/staging/zcache/ramster/masklog.h b/drivers/staging/zcache/ramster/masklog.h
new file mode 100644
index 0000000..918ae11
--- /dev/null
+++ b/drivers/staging/zcache/ramster/masklog.h
@@ -0,0 +1,220 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * Copyright (C) 2005, 2012 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ */
+
+#ifndef R2CLUSTER_MASKLOG_H
+#define R2CLUSTER_MASKLOG_H
+
+/*
+ * For now this is a trivial wrapper around printk() that gives the critical
+ * ability to enable sets of debugging output at run-time.  In the future this
+ * will almost certainly be redirected to relayfs so that it can pay a
+ * substantially lower heisenberg tax.
+ *
+ * Callers associate the message with a bitmask and a global bitmask is
+ * maintained with help from /proc.  If any of the bits match the message is
+ * output.
+ *
+ * We must have efficient bit tests on i386 and it seems gcc still emits crazy
+ * code for the 64bit compare.  It emits very good code for the dual unsigned
+ * long tests, though, completely avoiding tests that can never pass if the
+ * caller gives a constant bitmask that fills one of the longs with all 0s.  So
+ * the desire is to have almost all of the calls decided on by comparing just
+ * one of the longs.  This leads to having infrequently given bits that are
+ * frequently matched in the high bits.
+ *
+ * _ERROR and _NOTICE are used for messages that always go to the console and
+ * have appropriate KERN_ prefixes.  We wrap these in our function instead of
+ * just calling printk() so that this can eventually make its way through
+ * relayfs along with the debugging messages.  Everything else gets KERN_DEBUG.
+ * The inline tests and macro dance give GCC the opportunity to quite cleverly
+ * only emit the appropriage printk() when the caller passes in a constant
+ * mask, as is almost always the case.
+ *
+ * All this bitmask nonsense is managed from the files under
+ * /sys/fs/r2cb/logmask/.  Reading the files gives a straightforward
+ * indication of which bits are allowed (allow) or denied (off/deny).
+ *	ENTRY deny
+ *	EXIT deny
+ *	TCP off
+ *	MSG off
+ *	SOCKET off
+ *	ERROR allow
+ *	NOTICE allow
+ *
+ * Writing changes the state of a given bit and requires a strictly formatted
+ * single write() call:
+ *
+ *	write(fd, "allow", 5);
+ *
+ * Echoing allow/deny/off string into the logmask files can flip the bits
+ * on or off as expected; here is the bash script for example:
+ *
+ * log_mask="/sys/fs/r2cb/log_mask"
+ * for node in ENTRY EXIT TCP MSG SOCKET ERROR NOTICE; do
+ *	echo allow >"$log_mask"/"$node"
+ * done
+ *
+ * The debugfs.ramster tool can also flip the bits with the -l option:
+ *
+ * debugfs.ramster -l TCP allow
+ */
+
+/* for task_struct */
+#include <linux/sched.h>
+
+/* bits that are frequently given and infrequently matched in the low word */
+/* NOTE: If you add a flag, you need to also update masklog.c! */
+#define ML_TCP		0x0000000000000001ULL /* net cluster/tcp.c */
+#define ML_MSG		0x0000000000000002ULL /* net network messages */
+#define ML_SOCKET	0x0000000000000004ULL /* net socket lifetime */
+#define ML_HEARTBEAT	0x0000000000000008ULL /* hb all heartbeat tracking */
+#define ML_HB_BIO	0x0000000000000010ULL /* hb io tracing */
+#define ML_DLMFS	0x0000000000000020ULL /* dlm user dlmfs */
+#define ML_DLM		0x0000000000000040ULL /* dlm general debugging */
+#define ML_DLM_DOMAIN	0x0000000000000080ULL /* dlm domain debugging */
+#define ML_DLM_THREAD	0x0000000000000100ULL /* dlm domain thread */
+#define ML_DLM_MASTER	0x0000000000000200ULL /* dlm master functions */
+#define ML_DLM_RECOVERY	0x0000000000000400ULL /* dlm master functions */
+#define ML_DLM_GLUE	0x0000000000000800ULL /* ramster dlm glue layer */
+#define ML_VOTE		0x0000000000001000ULL /* ramster node messaging  */
+#define ML_CONN		0x0000000000002000ULL /* net connection management */
+#define ML_QUORUM	0x0000000000004000ULL /* net connection quorum */
+#define ML_BASTS	0x0000000000008000ULL /* dlmglue asts and basts */
+#define ML_CLUSTER	0x0000000000010000ULL /* cluster stack */
+
+/* bits that are infrequently given and frequently matched in the high word */
+#define ML_ERROR	0x1000000000000000ULL /* sent to KERN_ERR */
+#define ML_NOTICE	0x2000000000000000ULL /* setn to KERN_NOTICE */
+#define ML_KTHREAD	0x4000000000000000ULL /* kernel thread activity */
+
+#define MLOG_INITIAL_AND_MASK (ML_ERROR|ML_NOTICE)
+#ifndef MLOG_MASK_PREFIX
+#define MLOG_MASK_PREFIX 0
+#endif
+
+/*
+ * When logging is disabled, force the bit test to 0 for anything other
+ * than errors and notices, allowing gcc to remove the code completely.
+ * When enabled, allow all masks.
+ */
+#if defined(CONFIG_RAMSTER_DEBUG_MASKLOG)
+#define ML_ALLOWED_BITS (~0)
+#else
+#define ML_ALLOWED_BITS (ML_ERROR|ML_NOTICE)
+#endif
+
+#define MLOG_MAX_BITS 64
+
+struct mlog_bits {
+	unsigned long words[MLOG_MAX_BITS / BITS_PER_LONG];
+};
+
+extern struct mlog_bits r2_mlog_and_bits, r2_mlog_not_bits;
+
+#if BITS_PER_LONG == 32
+
+#define __mlog_test_u64(mask, bits)			\
+	((u32)(mask & 0xffffffff) & bits.words[0] ||	\
+	  ((u64)(mask) >> 32) & bits.words[1])
+#define __mlog_set_u64(mask, bits) do {			\
+	bits.words[0] |= (u32)(mask & 0xffffffff);	\
+	bits.words[1] |= (u64)(mask) >> 32;		\
+} while (0)
+#define __mlog_clear_u64(mask, bits) do {		\
+	bits.words[0] &= ~((u32)(mask & 0xffffffff));	\
+	bits.words[1] &= ~((u64)(mask) >> 32);		\
+} while (0)
+#define MLOG_BITS_RHS(mask) {				\
+	{						\
+		[0] = (u32)(mask & 0xffffffff),		\
+		[1] = (u64)(mask) >> 32,		\
+	}						\
+}
+
+#else /* 32bit long above, 64bit long below */
+
+#define __mlog_test_u64(mask, bits)	((mask) & bits.words[0])
+#define __mlog_set_u64(mask, bits) do {		\
+	bits.words[0] |= (mask);		\
+} while (0)
+#define __mlog_clear_u64(mask, bits) do {	\
+	bits.words[0] &= ~(mask);		\
+} while (0)
+#define MLOG_BITS_RHS(mask) { { (mask) } }
+
+#endif
+
+/*
+ * smp_processor_id() "helpfully" screams when called outside preemptible
+ * regions in current kernels.  sles doesn't have the variants that don't
+ * scream.  just do this instead of trying to guess which we're building
+ * against.. *sigh*.
+ */
+#define __mlog_cpu_guess ({		\
+	unsigned long _cpu = get_cpu();	\
+	put_cpu();			\
+	_cpu;				\
+})
+
+/* In the following two macros, the whitespace after the ',' just
+ * before ##args is intentional. Otherwise, gcc 2.95 will eat the
+ * previous token if args expands to nothing.
+ */
+#define __mlog_printk(level, fmt, args...)				\
+	printk(level "(%s,%u,%lu):%s:%d " fmt, current->comm,		\
+	       task_pid_nr(current), __mlog_cpu_guess,			\
+	       __PRETTY_FUNCTION__, __LINE__ , ##args)
+
+#define mlog(mask, fmt, args...) do {					\
+	u64 __m = MLOG_MASK_PREFIX | (mask);				\
+	if ((__m & ML_ALLOWED_BITS) &&					\
+	    __mlog_test_u64(__m, r2_mlog_and_bits) &&			\
+	    !__mlog_test_u64(__m, r2_mlog_not_bits)) {			\
+		if (__m & ML_ERROR)					\
+			__mlog_printk(KERN_ERR, "ERROR: "fmt , ##args);	\
+		else if (__m & ML_NOTICE)				\
+			__mlog_printk(KERN_NOTICE, fmt , ##args);	\
+		else							\
+			__mlog_printk(KERN_INFO, fmt , ##args);		\
+	}								\
+} while (0)
+
+#define mlog_errno(st) do {						\
+	int _st = (st);							\
+	if (_st != -ERESTARTSYS && _st != -EINTR &&			\
+	    _st != AOP_TRUNCATED_PAGE && _st != -ENOSPC)		\
+		mlog(ML_ERROR, "status = %lld\n", (long long)_st);	\
+} while (0)
+
+#define mlog_bug_on_msg(cond, fmt, args...) do {			\
+	if (cond) {							\
+		mlog(ML_ERROR, "bug expression: " #cond "\n");		\
+		mlog(ML_ERROR, fmt, ##args);				\
+		BUG();							\
+	}								\
+} while (0)
+
+#include <linux/kobject.h>
+#include <linux/sysfs.h>
+int r2_mlog_sys_init(struct kset *r2cb_subsys);
+void r2_mlog_sys_shutdown(void);
+
+#endif /* R2CLUSTER_MASKLOG_H */
diff --git a/drivers/staging/zcache/ramster/nodemanager.c b/drivers/staging/zcache/ramster/nodemanager.c
new file mode 100644
index 0000000..c0f4815
--- /dev/null
+++ b/drivers/staging/zcache/ramster/nodemanager.c
@@ -0,0 +1,995 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * Copyright (C) 2004, 2005, 2012 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ */
+
+#include <linux/slab.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/configfs.h>
+
+#include "tcp.h"
+#include "nodemanager.h"
+#include "heartbeat.h"
+#include "masklog.h"
+
+/* for now we operate under the assertion that there can be only one
+ * cluster active at a time.  Changing this will require trickling
+ * cluster references throughout where nodes are looked up */
+struct r2nm_cluster *r2nm_single_cluster;
+
+char *r2nm_fence_method_desc[R2NM_FENCE_METHODS] = {
+		"reset",	/* R2NM_FENCE_RESET */
+		"panic",	/* R2NM_FENCE_PANIC */
+};
+
+struct r2nm_node *r2nm_get_node_by_num(u8 node_num)
+{
+	struct r2nm_node *node = NULL;
+
+	if (node_num >= R2NM_MAX_NODES || r2nm_single_cluster == NULL)
+		goto out;
+
+	read_lock(&r2nm_single_cluster->cl_nodes_lock);
+	node = r2nm_single_cluster->cl_nodes[node_num];
+	if (node)
+		config_item_get(&node->nd_item);
+	read_unlock(&r2nm_single_cluster->cl_nodes_lock);
+out:
+	return node;
+}
+EXPORT_SYMBOL_GPL(r2nm_get_node_by_num);
+
+int r2nm_configured_node_map(unsigned long *map, unsigned bytes)
+{
+	struct r2nm_cluster *cluster = r2nm_single_cluster;
+
+	BUG_ON(bytes < (sizeof(cluster->cl_nodes_bitmap)));
+
+	if (cluster == NULL)
+		return -EINVAL;
+
+	read_lock(&cluster->cl_nodes_lock);
+	memcpy(map, cluster->cl_nodes_bitmap, sizeof(cluster->cl_nodes_bitmap));
+	read_unlock(&cluster->cl_nodes_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(r2nm_configured_node_map);
+
+static struct r2nm_node *r2nm_node_ip_tree_lookup(struct r2nm_cluster *cluster,
+						  __be32 ip_needle,
+						  struct rb_node ***ret_p,
+						  struct rb_node **ret_parent)
+{
+	struct rb_node **p = &cluster->cl_node_ip_tree.rb_node;
+	struct rb_node *parent = NULL;
+	struct r2nm_node *node, *ret = NULL;
+
+	while (*p) {
+		int cmp;
+
+		parent = *p;
+		node = rb_entry(parent, struct r2nm_node, nd_ip_node);
+
+		cmp = memcmp(&ip_needle, &node->nd_ipv4_address,
+				sizeof(ip_needle));
+		if (cmp < 0)
+			p = &(*p)->rb_left;
+		else if (cmp > 0)
+			p = &(*p)->rb_right;
+		else {
+			ret = node;
+			break;
+		}
+	}
+
+	if (ret_p != NULL)
+		*ret_p = p;
+	if (ret_parent != NULL)
+		*ret_parent = parent;
+
+	return ret;
+}
+
+struct r2nm_node *r2nm_get_node_by_ip(__be32 addr)
+{
+	struct r2nm_node *node = NULL;
+	struct r2nm_cluster *cluster = r2nm_single_cluster;
+
+	if (cluster == NULL)
+		goto out;
+
+	read_lock(&cluster->cl_nodes_lock);
+	node = r2nm_node_ip_tree_lookup(cluster, addr, NULL, NULL);
+	if (node)
+		config_item_get(&node->nd_item);
+	read_unlock(&cluster->cl_nodes_lock);
+
+out:
+	return node;
+}
+EXPORT_SYMBOL_GPL(r2nm_get_node_by_ip);
+
+void r2nm_node_put(struct r2nm_node *node)
+{
+	config_item_put(&node->nd_item);
+}
+EXPORT_SYMBOL_GPL(r2nm_node_put);
+
+void r2nm_node_get(struct r2nm_node *node)
+{
+	config_item_get(&node->nd_item);
+}
+EXPORT_SYMBOL_GPL(r2nm_node_get);
+
+u8 r2nm_this_node(void)
+{
+	u8 node_num = R2NM_MAX_NODES;
+
+	if (r2nm_single_cluster && r2nm_single_cluster->cl_has_local)
+		node_num = r2nm_single_cluster->cl_local_node;
+
+	return node_num;
+}
+EXPORT_SYMBOL_GPL(r2nm_this_node);
+
+/* node configfs bits */
+
+static struct r2nm_cluster *to_r2nm_cluster(struct config_item *item)
+{
+	return item ?
+		container_of(to_config_group(item), struct r2nm_cluster,
+			     cl_group)
+		: NULL;
+}
+
+static struct r2nm_node *to_r2nm_node(struct config_item *item)
+{
+	return item ? container_of(item, struct r2nm_node, nd_item) : NULL;
+}
+
+static void r2nm_node_release(struct config_item *item)
+{
+	struct r2nm_node *node = to_r2nm_node(item);
+	kfree(node);
+}
+
+static ssize_t r2nm_node_num_read(struct r2nm_node *node, char *page)
+{
+	return sprintf(page, "%d\n", node->nd_num);
+}
+
+static struct r2nm_cluster *to_r2nm_cluster_from_node(struct r2nm_node *node)
+{
+	/* through the first node_set .parent
+	 * mycluster/nodes/mynode == r2nm_cluster->r2nm_node_group->r2nm_node */
+	return to_r2nm_cluster(node->nd_item.ci_parent->ci_parent);
+}
+
+enum {
+	R2NM_NODE_ATTR_NUM = 0,
+	R2NM_NODE_ATTR_PORT,
+	R2NM_NODE_ATTR_ADDRESS,
+	R2NM_NODE_ATTR_LOCAL,
+};
+
+static ssize_t r2nm_node_num_write(struct r2nm_node *node, const char *page,
+				   size_t count)
+{
+	struct r2nm_cluster *cluster = to_r2nm_cluster_from_node(node);
+	unsigned long tmp;
+	char *p = (char *)page;
+	int err;
+
+	err = kstrtoul(p, 10, &tmp);
+	if (err)
+		return err;
+
+	if (tmp >= R2NM_MAX_NODES)
+		return -ERANGE;
+
+	/* once we're in the cl_nodes tree networking can look us up by
+	 * node number and try to use our address and port attributes
+	 * to connect to this node.. make sure that they've been set
+	 * before writing the node attribute? */
+	if (!test_bit(R2NM_NODE_ATTR_ADDRESS, &node->nd_set_attributes) ||
+	    !test_bit(R2NM_NODE_ATTR_PORT, &node->nd_set_attributes))
+		return -EINVAL; /* XXX */
+
+	write_lock(&cluster->cl_nodes_lock);
+	if (cluster->cl_nodes[tmp])
+		p = NULL;
+	else  {
+		cluster->cl_nodes[tmp] = node;
+		node->nd_num = tmp;
+		set_bit(tmp, cluster->cl_nodes_bitmap);
+	}
+	write_unlock(&cluster->cl_nodes_lock);
+	if (p == NULL)
+		return -EEXIST;
+
+	return count;
+}
+static ssize_t r2nm_node_ipv4_port_read(struct r2nm_node *node, char *page)
+{
+	return sprintf(page, "%u\n", ntohs(node->nd_ipv4_port));
+}
+
+static ssize_t r2nm_node_ipv4_port_write(struct r2nm_node *node,
+					 const char *page, size_t count)
+{
+	unsigned long tmp;
+	char *p = (char *)page;
+	int err;
+
+	err = kstrtoul(p, 10, &tmp);
+	if (err)
+		return err;
+
+	if (tmp == 0)
+		return -EINVAL;
+	if (tmp >= (u16)-1)
+		return -ERANGE;
+
+	node->nd_ipv4_port = htons(tmp);
+
+	return count;
+}
+
+static ssize_t r2nm_node_ipv4_address_read(struct r2nm_node *node, char *page)
+{
+	return sprintf(page, "%pI4\n", &node->nd_ipv4_address);
+}
+
+static ssize_t r2nm_node_ipv4_address_write(struct r2nm_node *node,
+					    const char *page,
+					    size_t count)
+{
+	struct r2nm_cluster *cluster = to_r2nm_cluster_from_node(node);
+	int ret, i;
+	struct rb_node **p, *parent;
+	unsigned int octets[4];
+	__be32 ipv4_addr = 0;
+
+	ret = sscanf(page, "%3u.%3u.%3u.%3u", &octets[3], &octets[2],
+		     &octets[1], &octets[0]);
+	if (ret != 4)
+		return -EINVAL;
+
+	for (i = 0; i < ARRAY_SIZE(octets); i++) {
+		if (octets[i] > 255)
+			return -ERANGE;
+		be32_add_cpu(&ipv4_addr, octets[i] << (i * 8));
+	}
+
+	ret = 0;
+	write_lock(&cluster->cl_nodes_lock);
+	if (r2nm_node_ip_tree_lookup(cluster, ipv4_addr, &p, &parent))
+		ret = -EEXIST;
+	else {
+		rb_link_node(&node->nd_ip_node, parent, p);
+		rb_insert_color(&node->nd_ip_node, &cluster->cl_node_ip_tree);
+	}
+	write_unlock(&cluster->cl_nodes_lock);
+	if (ret)
+		return ret;
+
+	memcpy(&node->nd_ipv4_address, &ipv4_addr, sizeof(ipv4_addr));
+
+	return count;
+}
+
+static ssize_t r2nm_node_local_read(struct r2nm_node *node, char *page)
+{
+	return sprintf(page, "%d\n", node->nd_local);
+}
+
+static ssize_t r2nm_node_local_write(struct r2nm_node *node, const char *page,
+				     size_t count)
+{
+	struct r2nm_cluster *cluster = to_r2nm_cluster_from_node(node);
+	unsigned long tmp;
+	char *p = (char *)page;
+	ssize_t ret;
+	int err;
+
+	err = kstrtoul(p, 10, &tmp);
+	if (err)
+		return err;
+
+	tmp = !!tmp; /* boolean of whether this node wants to be local */
+
+	/* setting local turns on networking rx for now so we require having
+	 * set everything else first */
+	if (!test_bit(R2NM_NODE_ATTR_ADDRESS, &node->nd_set_attributes) ||
+	    !test_bit(R2NM_NODE_ATTR_NUM, &node->nd_set_attributes) ||
+	    !test_bit(R2NM_NODE_ATTR_PORT, &node->nd_set_attributes))
+		return -EINVAL; /* XXX */
+
+	/* the only failure case is trying to set a new local node
+	 * when a different one is already set */
+	if (tmp && tmp == cluster->cl_has_local &&
+	    cluster->cl_local_node != node->nd_num)
+		return -EBUSY;
+
+	/* bring up the rx thread if we're setting the new local node. */
+	if (tmp && !cluster->cl_has_local) {
+		ret = r2net_start_listening(node);
+		if (ret)
+			return ret;
+	}
+
+	if (!tmp && cluster->cl_has_local &&
+	    cluster->cl_local_node == node->nd_num) {
+		r2net_stop_listening(node);
+		cluster->cl_local_node = R2NM_INVALID_NODE_NUM;
+	}
+
+	node->nd_local = tmp;
+	if (node->nd_local) {
+		cluster->cl_has_local = tmp;
+		cluster->cl_local_node = node->nd_num;
+	}
+
+	return count;
+}
+
+struct r2nm_node_attribute {
+	struct configfs_attribute attr;
+	ssize_t (*show)(struct r2nm_node *, char *);
+	ssize_t (*store)(struct r2nm_node *, const char *, size_t);
+};
+
+static struct r2nm_node_attribute r2nm_node_attr_num = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "num",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= r2nm_node_num_read,
+	.store	= r2nm_node_num_write,
+};
+
+static struct r2nm_node_attribute r2nm_node_attr_ipv4_port = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "ipv4_port",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= r2nm_node_ipv4_port_read,
+	.store	= r2nm_node_ipv4_port_write,
+};
+
+static struct r2nm_node_attribute r2nm_node_attr_ipv4_address = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "ipv4_address",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= r2nm_node_ipv4_address_read,
+	.store	= r2nm_node_ipv4_address_write,
+};
+
+static struct r2nm_node_attribute r2nm_node_attr_local = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "local",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= r2nm_node_local_read,
+	.store	= r2nm_node_local_write,
+};
+
+static struct configfs_attribute *r2nm_node_attrs[] = {
+	[R2NM_NODE_ATTR_NUM] = &r2nm_node_attr_num.attr,
+	[R2NM_NODE_ATTR_PORT] = &r2nm_node_attr_ipv4_port.attr,
+	[R2NM_NODE_ATTR_ADDRESS] = &r2nm_node_attr_ipv4_address.attr,
+	[R2NM_NODE_ATTR_LOCAL] = &r2nm_node_attr_local.attr,
+	NULL,
+};
+
+static int r2nm_attr_index(struct configfs_attribute *attr)
+{
+	int i;
+	for (i = 0; i < ARRAY_SIZE(r2nm_node_attrs); i++) {
+		if (attr == r2nm_node_attrs[i])
+			return i;
+	}
+	BUG();
+	return 0;
+}
+
+static ssize_t r2nm_node_show(struct config_item *item,
+			      struct configfs_attribute *attr,
+			      char *page)
+{
+	struct r2nm_node *node = to_r2nm_node(item);
+	struct r2nm_node_attribute *r2nm_node_attr =
+		container_of(attr, struct r2nm_node_attribute, attr);
+	ssize_t ret = 0;
+
+	if (r2nm_node_attr->show)
+		ret = r2nm_node_attr->show(node, page);
+	return ret;
+}
+
+static ssize_t r2nm_node_store(struct config_item *item,
+			       struct configfs_attribute *attr,
+			       const char *page, size_t count)
+{
+	struct r2nm_node *node = to_r2nm_node(item);
+	struct r2nm_node_attribute *r2nm_node_attr =
+		container_of(attr, struct r2nm_node_attribute, attr);
+	ssize_t ret;
+	int attr_index = r2nm_attr_index(attr);
+
+	if (r2nm_node_attr->store == NULL) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (test_bit(attr_index, &node->nd_set_attributes))
+		return -EBUSY;
+
+	ret = r2nm_node_attr->store(node, page, count);
+	if (ret < count)
+		goto out;
+
+	set_bit(attr_index, &node->nd_set_attributes);
+out:
+	return ret;
+}
+
+static struct configfs_item_operations r2nm_node_item_ops = {
+	.release		= r2nm_node_release,
+	.show_attribute		= r2nm_node_show,
+	.store_attribute	= r2nm_node_store,
+};
+
+static struct config_item_type r2nm_node_type = {
+	.ct_item_ops	= &r2nm_node_item_ops,
+	.ct_attrs	= r2nm_node_attrs,
+	.ct_owner	= THIS_MODULE,
+};
+
+/* node set */
+
+struct r2nm_node_group {
+	struct config_group ns_group;
+	/* some stuff? */
+};
+
+#if 0
+static struct r2nm_node_group *to_r2nm_node_group(struct config_group *group)
+{
+	return group ?
+		container_of(group, struct r2nm_node_group, ns_group)
+		: NULL;
+}
+#endif
+
+struct r2nm_cluster_attribute {
+	struct configfs_attribute attr;
+	ssize_t (*show)(struct r2nm_cluster *, char *);
+	ssize_t (*store)(struct r2nm_cluster *, const char *, size_t);
+};
+
+static ssize_t r2nm_cluster_attr_write(const char *page, ssize_t count,
+					unsigned int *val)
+{
+	unsigned long tmp;
+	char *p = (char *)page;
+	int err;
+
+	err = kstrtoul(p, 10, &tmp);
+	if (err)
+		return err;
+
+	if (tmp == 0)
+		return -EINVAL;
+	if (tmp >= (u32)-1)
+		return -ERANGE;
+
+	*val = tmp;
+
+	return count;
+}
+
+static ssize_t r2nm_cluster_attr_idle_timeout_ms_read(
+	struct r2nm_cluster *cluster, char *page)
+{
+	return sprintf(page, "%u\n", cluster->cl_idle_timeout_ms);
+}
+
+static ssize_t r2nm_cluster_attr_idle_timeout_ms_write(
+	struct r2nm_cluster *cluster, const char *page, size_t count)
+{
+	ssize_t ret;
+	unsigned int val = 0;
+
+	ret =  r2nm_cluster_attr_write(page, count, &val);
+
+	if (ret > 0) {
+		if (cluster->cl_idle_timeout_ms != val
+			&& r2net_num_connected_peers()) {
+			mlog(ML_NOTICE,
+			     "r2net: cannot change idle timeout after "
+			     "the first peer has agreed to it."
+			     "  %d connected peers\n",
+			     r2net_num_connected_peers());
+			ret = -EINVAL;
+		} else if (val <= cluster->cl_keepalive_delay_ms) {
+			mlog(ML_NOTICE,
+			     "r2net: idle timeout must be larger "
+			     "than keepalive delay\n");
+			ret = -EINVAL;
+		} else {
+			cluster->cl_idle_timeout_ms = val;
+		}
+	}
+
+	return ret;
+}
+
+static ssize_t r2nm_cluster_attr_keepalive_delay_ms_read(
+	struct r2nm_cluster *cluster, char *page)
+{
+	return sprintf(page, "%u\n", cluster->cl_keepalive_delay_ms);
+}
+
+static ssize_t r2nm_cluster_attr_keepalive_delay_ms_write(
+	struct r2nm_cluster *cluster, const char *page, size_t count)
+{
+	ssize_t ret;
+	unsigned int val = 0;
+
+	ret =  r2nm_cluster_attr_write(page, count, &val);
+
+	if (ret > 0) {
+		if (cluster->cl_keepalive_delay_ms != val
+		    && r2net_num_connected_peers()) {
+			mlog(ML_NOTICE,
+			     "r2net: cannot change keepalive delay after"
+			     " the first peer has agreed to it."
+			     "  %d connected peers\n",
+			     r2net_num_connected_peers());
+			ret = -EINVAL;
+		} else if (val >= cluster->cl_idle_timeout_ms) {
+			mlog(ML_NOTICE,
+			     "r2net: keepalive delay must be "
+			     "smaller than idle timeout\n");
+			ret = -EINVAL;
+		} else {
+			cluster->cl_keepalive_delay_ms = val;
+		}
+	}
+
+	return ret;
+}
+
+static ssize_t r2nm_cluster_attr_reconnect_delay_ms_read(
+	struct r2nm_cluster *cluster, char *page)
+{
+	return sprintf(page, "%u\n", cluster->cl_reconnect_delay_ms);
+}
+
+static ssize_t r2nm_cluster_attr_reconnect_delay_ms_write(
+	struct r2nm_cluster *cluster, const char *page, size_t count)
+{
+	return r2nm_cluster_attr_write(page, count,
+					&cluster->cl_reconnect_delay_ms);
+}
+
+static ssize_t r2nm_cluster_attr_fence_method_read(
+	struct r2nm_cluster *cluster, char *page)
+{
+	ssize_t ret = 0;
+
+	if (cluster)
+		ret = sprintf(page, "%s\n",
+			      r2nm_fence_method_desc[cluster->cl_fence_method]);
+	return ret;
+}
+
+static ssize_t r2nm_cluster_attr_fence_method_write(
+	struct r2nm_cluster *cluster, const char *page, size_t count)
+{
+	unsigned int i;
+
+	if (page[count - 1] != '\n')
+		goto bail;
+
+	for (i = 0; i < R2NM_FENCE_METHODS; ++i) {
+		if (count != strlen(r2nm_fence_method_desc[i]) + 1)
+			continue;
+		if (strncasecmp(page, r2nm_fence_method_desc[i], count - 1))
+			continue;
+		if (cluster->cl_fence_method != i) {
+			pr_info("ramster: Changing fence method to %s\n",
+			       r2nm_fence_method_desc[i]);
+			cluster->cl_fence_method = i;
+		}
+		return count;
+	}
+
+bail:
+	return -EINVAL;
+}
+
+static struct r2nm_cluster_attribute r2nm_cluster_attr_idle_timeout_ms = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "idle_timeout_ms",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= r2nm_cluster_attr_idle_timeout_ms_read,
+	.store	= r2nm_cluster_attr_idle_timeout_ms_write,
+};
+
+static struct r2nm_cluster_attribute r2nm_cluster_attr_keepalive_delay_ms = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "keepalive_delay_ms",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= r2nm_cluster_attr_keepalive_delay_ms_read,
+	.store	= r2nm_cluster_attr_keepalive_delay_ms_write,
+};
+
+static struct r2nm_cluster_attribute r2nm_cluster_attr_reconnect_delay_ms = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "reconnect_delay_ms",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= r2nm_cluster_attr_reconnect_delay_ms_read,
+	.store	= r2nm_cluster_attr_reconnect_delay_ms_write,
+};
+
+static struct r2nm_cluster_attribute r2nm_cluster_attr_fence_method = {
+	.attr	= { .ca_owner = THIS_MODULE,
+		    .ca_name = "fence_method",
+		    .ca_mode = S_IRUGO | S_IWUSR },
+	.show	= r2nm_cluster_attr_fence_method_read,
+	.store	= r2nm_cluster_attr_fence_method_write,
+};
+
+static struct configfs_attribute *r2nm_cluster_attrs[] = {
+	&r2nm_cluster_attr_idle_timeout_ms.attr,
+	&r2nm_cluster_attr_keepalive_delay_ms.attr,
+	&r2nm_cluster_attr_reconnect_delay_ms.attr,
+	&r2nm_cluster_attr_fence_method.attr,
+	NULL,
+};
+static ssize_t r2nm_cluster_show(struct config_item *item,
+					struct configfs_attribute *attr,
+					char *page)
+{
+	struct r2nm_cluster *cluster = to_r2nm_cluster(item);
+	struct r2nm_cluster_attribute *r2nm_cluster_attr =
+		container_of(attr, struct r2nm_cluster_attribute, attr);
+	ssize_t ret = 0;
+
+	if (r2nm_cluster_attr->show)
+		ret = r2nm_cluster_attr->show(cluster, page);
+	return ret;
+}
+
+static ssize_t r2nm_cluster_store(struct config_item *item,
+					struct configfs_attribute *attr,
+					const char *page, size_t count)
+{
+	struct r2nm_cluster *cluster = to_r2nm_cluster(item);
+	struct r2nm_cluster_attribute *r2nm_cluster_attr =
+		container_of(attr, struct r2nm_cluster_attribute, attr);
+	ssize_t ret;
+
+	if (r2nm_cluster_attr->store == NULL) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ret = r2nm_cluster_attr->store(cluster, page, count);
+	if (ret < count)
+		goto out;
+out:
+	return ret;
+}
+
+static struct config_item *r2nm_node_group_make_item(struct config_group *group,
+						     const char *name)
+{
+	struct r2nm_node *node = NULL;
+
+	if (strlen(name) > R2NM_MAX_NAME_LEN)
+		return ERR_PTR(-ENAMETOOLONG);
+
+	node = kzalloc(sizeof(struct r2nm_node), GFP_KERNEL);
+	if (node == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	strcpy(node->nd_name, name); /* use item.ci_namebuf instead? */
+	config_item_init_type_name(&node->nd_item, name, &r2nm_node_type);
+	spin_lock_init(&node->nd_lock);
+
+	mlog(ML_CLUSTER, "r2nm: Registering node %s\n", name);
+
+	return &node->nd_item;
+}
+
+static void r2nm_node_group_drop_item(struct config_group *group,
+				      struct config_item *item)
+{
+	struct r2nm_node *node = to_r2nm_node(item);
+	struct r2nm_cluster *cluster =
+				to_r2nm_cluster(group->cg_item.ci_parent);
+
+	r2net_disconnect_node(node);
+
+	if (cluster->cl_has_local &&
+	    (cluster->cl_local_node == node->nd_num)) {
+		cluster->cl_has_local = 0;
+		cluster->cl_local_node = R2NM_INVALID_NODE_NUM;
+		r2net_stop_listening(node);
+	}
+
+	/* XXX call into net to stop this node from trading messages */
+
+	write_lock(&cluster->cl_nodes_lock);
+
+	/* XXX sloppy */
+	if (node->nd_ipv4_address)
+		rb_erase(&node->nd_ip_node, &cluster->cl_node_ip_tree);
+
+	/* nd_num might be 0 if the node number hasn't been set.. */
+	if (cluster->cl_nodes[node->nd_num] == node) {
+		cluster->cl_nodes[node->nd_num] = NULL;
+		clear_bit(node->nd_num, cluster->cl_nodes_bitmap);
+	}
+	write_unlock(&cluster->cl_nodes_lock);
+
+	mlog(ML_CLUSTER, "r2nm: Unregistered node %s\n",
+	     config_item_name(&node->nd_item));
+
+	config_item_put(item);
+}
+
+static struct configfs_group_operations r2nm_node_group_group_ops = {
+	.make_item	= r2nm_node_group_make_item,
+	.drop_item	= r2nm_node_group_drop_item,
+};
+
+static struct config_item_type r2nm_node_group_type = {
+	.ct_group_ops	= &r2nm_node_group_group_ops,
+	.ct_owner	= THIS_MODULE,
+};
+
+/* cluster */
+
+static void r2nm_cluster_release(struct config_item *item)
+{
+	struct r2nm_cluster *cluster = to_r2nm_cluster(item);
+
+	kfree(cluster->cl_group.default_groups);
+	kfree(cluster);
+}
+
+static struct configfs_item_operations r2nm_cluster_item_ops = {
+	.release	= r2nm_cluster_release,
+	.show_attribute		= r2nm_cluster_show,
+	.store_attribute	= r2nm_cluster_store,
+};
+
+static struct config_item_type r2nm_cluster_type = {
+	.ct_item_ops	= &r2nm_cluster_item_ops,
+	.ct_attrs	= r2nm_cluster_attrs,
+	.ct_owner	= THIS_MODULE,
+};
+
+/* cluster set */
+
+struct r2nm_cluster_group {
+	struct configfs_subsystem cs_subsys;
+	/* some stuff? */
+};
+
+#if 0
+static struct r2nm_cluster_group *
+to_r2nm_cluster_group(struct config_group *group)
+{
+	return group ?
+		container_of(to_configfs_subsystem(group),
+				struct r2nm_cluster_group, cs_subsys)
+	       : NULL;
+}
+#endif
+
+static struct config_group *
+r2nm_cluster_group_make_group(struct config_group *group,
+							  const char *name)
+{
+	struct r2nm_cluster *cluster = NULL;
+	struct r2nm_node_group *ns = NULL;
+	struct config_group *r2hb_group = NULL, *ret = NULL;
+	void *defs = NULL;
+
+	/* this runs under the parent dir's i_mutex; there can be only
+	 * one caller in here at a time */
+	if (r2nm_single_cluster)
+		return ERR_PTR(-ENOSPC);
+
+	cluster = kzalloc(sizeof(struct r2nm_cluster), GFP_KERNEL);
+	ns = kzalloc(sizeof(struct r2nm_node_group), GFP_KERNEL);
+	defs = kcalloc(3, sizeof(struct config_group *), GFP_KERNEL);
+	r2hb_group = r2hb_alloc_hb_set();
+	if (cluster == NULL || ns == NULL || r2hb_group == NULL || defs == NULL)
+		goto out;
+
+	config_group_init_type_name(&cluster->cl_group, name,
+				    &r2nm_cluster_type);
+	config_group_init_type_name(&ns->ns_group, "node",
+				    &r2nm_node_group_type);
+
+	cluster->cl_group.default_groups = defs;
+	cluster->cl_group.default_groups[0] = &ns->ns_group;
+	cluster->cl_group.default_groups[1] = r2hb_group;
+	cluster->cl_group.default_groups[2] = NULL;
+	rwlock_init(&cluster->cl_nodes_lock);
+	cluster->cl_node_ip_tree = RB_ROOT;
+	cluster->cl_reconnect_delay_ms = R2NET_RECONNECT_DELAY_MS_DEFAULT;
+	cluster->cl_idle_timeout_ms    = R2NET_IDLE_TIMEOUT_MS_DEFAULT;
+	cluster->cl_keepalive_delay_ms = R2NET_KEEPALIVE_DELAY_MS_DEFAULT;
+	cluster->cl_fence_method       = R2NM_FENCE_RESET;
+
+	ret = &cluster->cl_group;
+	r2nm_single_cluster = cluster;
+
+out:
+	if (ret == NULL) {
+		kfree(cluster);
+		kfree(ns);
+		r2hb_free_hb_set(r2hb_group);
+		kfree(defs);
+		ret = ERR_PTR(-ENOMEM);
+	}
+
+	return ret;
+}
+
+static void r2nm_cluster_group_drop_item(struct config_group *group,
+						struct config_item *item)
+{
+	struct r2nm_cluster *cluster = to_r2nm_cluster(item);
+	int i;
+	struct config_item *killme;
+
+	BUG_ON(r2nm_single_cluster != cluster);
+	r2nm_single_cluster = NULL;
+
+	for (i = 0; cluster->cl_group.default_groups[i]; i++) {
+		killme = &cluster->cl_group.default_groups[i]->cg_item;
+		cluster->cl_group.default_groups[i] = NULL;
+		config_item_put(killme);
+	}
+
+	config_item_put(item);
+}
+
+static struct configfs_group_operations r2nm_cluster_group_group_ops = {
+	.make_group	= r2nm_cluster_group_make_group,
+	.drop_item	= r2nm_cluster_group_drop_item,
+};
+
+static struct config_item_type r2nm_cluster_group_type = {
+	.ct_group_ops	= &r2nm_cluster_group_group_ops,
+	.ct_owner	= THIS_MODULE,
+};
+
+static struct r2nm_cluster_group r2nm_cluster_group = {
+	.cs_subsys = {
+		.su_group = {
+			.cg_item = {
+				.ci_namebuf = "cluster",
+				.ci_type = &r2nm_cluster_group_type,
+			},
+		},
+	},
+};
+
+int r2nm_depend_item(struct config_item *item)
+{
+	return configfs_depend_item(&r2nm_cluster_group.cs_subsys, item);
+}
+
+void r2nm_undepend_item(struct config_item *item)
+{
+	configfs_undepend_item(&r2nm_cluster_group.cs_subsys, item);
+}
+
+int r2nm_depend_this_node(void)
+{
+	int ret = 0;
+	struct r2nm_node *local_node;
+
+	local_node = r2nm_get_node_by_num(r2nm_this_node());
+	if (!local_node) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ret = r2nm_depend_item(&local_node->nd_item);
+	r2nm_node_put(local_node);
+
+out:
+	return ret;
+}
+
+void r2nm_undepend_this_node(void)
+{
+	struct r2nm_node *local_node;
+
+	local_node = r2nm_get_node_by_num(r2nm_this_node());
+	BUG_ON(!local_node);
+
+	r2nm_undepend_item(&local_node->nd_item);
+	r2nm_node_put(local_node);
+}
+
+
+static void __exit exit_r2nm(void)
+{
+	/* XXX sync with hb callbacks and shut down hb? */
+	r2net_unregister_hb_callbacks();
+	configfs_unregister_subsystem(&r2nm_cluster_group.cs_subsys);
+
+	r2net_exit();
+	r2hb_exit();
+}
+
+static int __init init_r2nm(void)
+{
+	int ret = -1;
+
+	ret = r2hb_init();
+	if (ret)
+		goto out;
+
+	ret = r2net_init();
+	if (ret)
+		goto out_r2hb;
+
+	ret = r2net_register_hb_callbacks();
+	if (ret)
+		goto out_r2net;
+
+	config_group_init(&r2nm_cluster_group.cs_subsys.su_group);
+	mutex_init(&r2nm_cluster_group.cs_subsys.su_mutex);
+	ret = configfs_register_subsystem(&r2nm_cluster_group.cs_subsys);
+	if (ret) {
+		pr_err("nodemanager: Registration returned %d\n", ret);
+		goto out_callbacks;
+	}
+
+	if (!ret)
+		goto out;
+
+	configfs_unregister_subsystem(&r2nm_cluster_group.cs_subsys);
+out_callbacks:
+	r2net_unregister_hb_callbacks();
+out_r2net:
+	r2net_exit();
+out_r2hb:
+	r2hb_exit();
+out:
+	return ret;
+}
+
+MODULE_AUTHOR("Oracle");
+MODULE_LICENSE("GPL");
+
+/* module_init(init_r2nm) */
+late_initcall(init_r2nm);
+/* module_exit(exit_r2nm) */
diff --git a/drivers/staging/zcache/ramster/nodemanager.h b/drivers/staging/zcache/ramster/nodemanager.h
new file mode 100644
index 0000000..41a04df
--- /dev/null
+++ b/drivers/staging/zcache/ramster/nodemanager.h
@@ -0,0 +1,88 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * nodemanager.h
+ *
+ * Function prototypes
+ *
+ * Copyright (C) 2004 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ */
+
+#ifndef R2CLUSTER_NODEMANAGER_H
+#define R2CLUSTER_NODEMANAGER_H
+
+#include "ramster_nodemanager.h"
+
+/* This totally doesn't belong here. */
+#include <linux/configfs.h>
+#include <linux/rbtree.h>
+
+enum r2nm_fence_method {
+	R2NM_FENCE_RESET	= 0,
+	R2NM_FENCE_PANIC,
+	R2NM_FENCE_METHODS,	/* Number of fence methods */
+};
+
+struct r2nm_node {
+	spinlock_t		nd_lock;
+	struct config_item	nd_item;
+	char			nd_name[R2NM_MAX_NAME_LEN+1]; /* replace? */
+	__u8			nd_num;
+	/* only one address per node, as attributes, for now. */
+	__be32			nd_ipv4_address;
+	__be16			nd_ipv4_port;
+	struct rb_node		nd_ip_node;
+	/* there can be only one local node for now */
+	int			nd_local;
+
+	unsigned long		nd_set_attributes;
+};
+
+struct r2nm_cluster {
+	struct config_group	cl_group;
+	unsigned		cl_has_local:1;
+	u8			cl_local_node;
+	rwlock_t		cl_nodes_lock;
+	struct r2nm_node	*cl_nodes[R2NM_MAX_NODES];
+	struct rb_root		cl_node_ip_tree;
+	unsigned int		cl_idle_timeout_ms;
+	unsigned int		cl_keepalive_delay_ms;
+	unsigned int		cl_reconnect_delay_ms;
+	enum r2nm_fence_method	cl_fence_method;
+
+	/* part of a hack for disk bitmap.. will go eventually. - zab */
+	unsigned long	cl_nodes_bitmap[BITS_TO_LONGS(R2NM_MAX_NODES)];
+};
+
+extern struct r2nm_cluster *r2nm_single_cluster;
+
+u8 r2nm_this_node(void);
+
+int r2nm_configured_node_map(unsigned long *map, unsigned bytes);
+struct r2nm_node *r2nm_get_node_by_num(u8 node_num);
+struct r2nm_node *r2nm_get_node_by_ip(__be32 addr);
+void r2nm_node_get(struct r2nm_node *node);
+void r2nm_node_put(struct r2nm_node *node);
+
+int r2nm_depend_item(struct config_item *item);
+void r2nm_undepend_item(struct config_item *item);
+int r2nm_depend_this_node(void);
+void r2nm_undepend_this_node(void);
+
+#endif /* R2CLUSTER_NODEMANAGER_H */
diff --git a/drivers/staging/zcache/ramster/r2net.c b/drivers/staging/zcache/ramster/r2net.c
new file mode 100644
index 0000000..34818dc
--- /dev/null
+++ b/drivers/staging/zcache/ramster/r2net.c
@@ -0,0 +1,414 @@
+/*
+ * r2net.c
+ *
+ * Copyright (c) 2011-2012, Dan Magenheimer, Oracle Corp.
+ *
+ * Ramster_r2net provides an interface between zcache and r2net.
+ *
+ * FIXME: support more than two nodes
+ */
+
+#include <linux/list.h>
+#include "tcp.h"
+#include "nodemanager.h"
+#include "../tmem.h"
+#include "../zcache.h"
+#include "ramster.h"
+
+#define RAMSTER_TESTING
+
+#define RMSTR_KEY	0x77347734
+
+enum {
+	RMSTR_TMEM_PUT_EPH = 100,
+	RMSTR_TMEM_PUT_PERS,
+	RMSTR_TMEM_ASYNC_GET_REQUEST,
+	RMSTR_TMEM_ASYNC_GET_AND_FREE_REQUEST,
+	RMSTR_TMEM_ASYNC_GET_REPLY,
+	RMSTR_TMEM_FLUSH,
+	RMSTR_TMEM_FLOBJ,
+	RMSTR_TMEM_DESTROY_POOL,
+};
+
+#define RMSTR_R2NET_MAX_LEN \
+		(R2NET_MAX_PAYLOAD_BYTES - sizeof(struct tmem_xhandle))
+
+#include "tcp_internal.h"
+
+static struct r2nm_node *r2net_target_node;
+static int r2net_target_nodenum;
+
+int r2net_remote_target_node_set(int node_num)
+{
+	int ret = -1;
+
+	r2net_target_node = r2nm_get_node_by_num(node_num);
+	if (r2net_target_node != NULL) {
+		r2net_target_nodenum = node_num;
+		r2nm_node_put(r2net_target_node);
+		ret = 0;
+	}
+	return ret;
+}
+
+/* FIXME following buffer should be per-cpu, protected by preempt_disable */
+static char ramster_async_get_buf[R2NET_MAX_PAYLOAD_BYTES];
+
+static int ramster_remote_async_get_request_handler(struct r2net_msg *msg,
+				u32 len, void *data, void **ret_data)
+{
+	char *pdata;
+	struct tmem_xhandle xh;
+	int found;
+	size_t size = RMSTR_R2NET_MAX_LEN;
+	u16 msgtype = be16_to_cpu(msg->msg_type);
+	bool get_and_free = (msgtype == RMSTR_TMEM_ASYNC_GET_AND_FREE_REQUEST);
+	unsigned long flags;
+
+	xh = *(struct tmem_xhandle *)msg->buf;
+	if (xh.xh_data_size > RMSTR_R2NET_MAX_LEN)
+		BUG();
+	pdata = ramster_async_get_buf;
+	*(struct tmem_xhandle *)pdata = xh;
+	pdata += sizeof(struct tmem_xhandle);
+	local_irq_save(flags);
+	found = zcache_get_page(xh.client_id, xh.pool_id, &xh.oid, xh.index,
+				pdata, &size, true, get_and_free ? 1 : -1);
+	local_irq_restore(flags);
+	if (found < 0) {
+		/* a zero size indicates the get failed */
+		size = 0;
+	}
+	if (size > RMSTR_R2NET_MAX_LEN)
+		BUG();
+	*ret_data = pdata - sizeof(struct tmem_xhandle);
+	/* now make caller (r2net_process_message) handle specially */
+	r2net_force_data_magic(msg, RMSTR_TMEM_ASYNC_GET_REPLY, RMSTR_KEY);
+	return size + sizeof(struct tmem_xhandle);
+}
+
+static int ramster_remote_async_get_reply_handler(struct r2net_msg *msg,
+				u32 len, void *data, void **ret_data)
+{
+	char *in = (char *)msg->buf;
+	int datalen = len - sizeof(struct r2net_msg);
+	int ret = -1;
+	struct tmem_xhandle *xh = (struct tmem_xhandle *)in;
+
+	in += sizeof(struct tmem_xhandle);
+	datalen -= sizeof(struct tmem_xhandle);
+	BUG_ON(datalen < 0 || datalen > PAGE_SIZE);
+	ret = ramster_localify(xh->pool_id, &xh->oid, xh->index,
+				in, datalen, xh->extra);
+#ifdef RAMSTER_TESTING
+	if (ret == -EEXIST)
+		pr_err("TESTING ArrgREP, aborted overwrite on racy put\n");
+#endif
+	return ret;
+}
+
+int ramster_remote_put_handler(struct r2net_msg *msg,
+				u32 len, void *data, void **ret_data)
+{
+	struct tmem_xhandle *xh;
+	char *p = (char *)msg->buf;
+	int datalen = len - sizeof(struct r2net_msg) -
+				sizeof(struct tmem_xhandle);
+	u16 msgtype = be16_to_cpu(msg->msg_type);
+	bool ephemeral = (msgtype == RMSTR_TMEM_PUT_EPH);
+	unsigned long flags;
+	int ret;
+
+	xh = (struct tmem_xhandle *)p;
+	p += sizeof(struct tmem_xhandle);
+	zcache_autocreate_pool(xh->client_id, xh->pool_id, ephemeral);
+	local_irq_save(flags);
+	ret = zcache_put_page(xh->client_id, xh->pool_id, &xh->oid, xh->index,
+				p, datalen, true, ephemeral);
+	local_irq_restore(flags);
+	return ret;
+}
+
+int ramster_remote_flush_handler(struct r2net_msg *msg,
+				u32 len, void *data, void **ret_data)
+{
+	struct tmem_xhandle *xh;
+	char *p = (char *)msg->buf;
+
+	xh = (struct tmem_xhandle *)p;
+	p += sizeof(struct tmem_xhandle);
+	(void)zcache_flush_page(xh->client_id, xh->pool_id,
+					&xh->oid, xh->index);
+	return 0;
+}
+
+int ramster_remote_flobj_handler(struct r2net_msg *msg,
+				u32 len, void *data, void **ret_data)
+{
+	struct tmem_xhandle *xh;
+	char *p = (char *)msg->buf;
+
+	xh = (struct tmem_xhandle *)p;
+	p += sizeof(struct tmem_xhandle);
+	(void)zcache_flush_object(xh->client_id, xh->pool_id, &xh->oid);
+	return 0;
+}
+
+int r2net_remote_async_get(struct tmem_xhandle *xh, bool free, int remotenode,
+				size_t expect_size, uint8_t expect_cksum,
+				void *extra)
+{
+	int nodenum, ret = -1, status;
+	struct r2nm_node *node = NULL;
+	struct kvec vec[1];
+	size_t veclen = 1;
+	u32 msg_type;
+	struct r2net_node *nn;
+
+	node = r2nm_get_node_by_num(remotenode);
+	if (node == NULL)
+		goto out;
+	xh->client_id = r2nm_this_node(); /* which node is getting */
+	xh->xh_data_cksum = expect_cksum;
+	xh->xh_data_size = expect_size;
+	xh->extra = extra;
+	vec[0].iov_len = sizeof(*xh);
+	vec[0].iov_base = xh;
+
+	node = r2net_target_node;
+	if (!node)
+		goto out;
+
+	nodenum = r2net_target_nodenum;
+
+	r2nm_node_get(node);
+	nn = r2net_nn_from_num(nodenum);
+	if (nn->nn_persistent_error || !nn->nn_sc_valid) {
+		ret = -ENOTCONN;
+		r2nm_node_put(node);
+		goto out;
+	}
+
+	if (free)
+		msg_type = RMSTR_TMEM_ASYNC_GET_AND_FREE_REQUEST;
+	else
+		msg_type = RMSTR_TMEM_ASYNC_GET_REQUEST;
+	ret = r2net_send_message_vec(msg_type, RMSTR_KEY,
+					vec, veclen, remotenode, &status);
+	r2nm_node_put(node);
+	if (ret < 0) {
+		if (ret == -ENOTCONN || ret == -EHOSTDOWN)
+			goto out;
+		if (ret == -EAGAIN)
+			goto out;
+		/* FIXME handle bad message possibilities here? */
+		pr_err("UNTESTED ret<0 in ramster_remote_async_get: ret=%d\n",
+				ret);
+	}
+	ret = status;
+out:
+	return ret;
+}
+
+#ifdef RAMSTER_TESTING
+/* leave me here to see if it catches a weird crash */
+static void ramster_check_irq_counts(void)
+{
+	static int last_hardirq_cnt, last_softirq_cnt, last_preempt_cnt;
+	int cur_hardirq_cnt, cur_softirq_cnt, cur_preempt_cnt;
+
+	cur_hardirq_cnt = hardirq_count() >> HARDIRQ_SHIFT;
+	if (cur_hardirq_cnt > last_hardirq_cnt) {
+		last_hardirq_cnt = cur_hardirq_cnt;
+		if (!(last_hardirq_cnt&(last_hardirq_cnt-1)))
+			pr_err("RAMSTER TESTING RRP hardirq_count=%d\n",
+				last_hardirq_cnt);
+	}
+	cur_softirq_cnt = softirq_count() >> SOFTIRQ_SHIFT;
+	if (cur_softirq_cnt > last_softirq_cnt) {
+		last_softirq_cnt = cur_softirq_cnt;
+		if (!(last_softirq_cnt&(last_softirq_cnt-1)))
+			pr_err("RAMSTER TESTING RRP softirq_count=%d\n",
+				last_softirq_cnt);
+	}
+	cur_preempt_cnt = preempt_count() & PREEMPT_MASK;
+	if (cur_preempt_cnt > last_preempt_cnt) {
+		last_preempt_cnt = cur_preempt_cnt;
+		if (!(last_preempt_cnt&(last_preempt_cnt-1)))
+			pr_err("RAMSTER TESTING RRP preempt_count=%d\n",
+				last_preempt_cnt);
+	}
+}
+#endif
+
+int r2net_remote_put(struct tmem_xhandle *xh, char *data, size_t size,
+				bool ephemeral, int *remotenode)
+{
+	int nodenum, ret = -1, status;
+	struct r2nm_node *node = NULL;
+	struct kvec vec[2];
+	size_t veclen = 2;
+	u32 msg_type;
+	struct r2net_node *nn;
+
+	BUG_ON(size > RMSTR_R2NET_MAX_LEN);
+	xh->client_id = r2nm_this_node(); /* which node is putting */
+	vec[0].iov_len = sizeof(*xh);
+	vec[0].iov_base = xh;
+	vec[1].iov_len = size;
+	vec[1].iov_base = data;
+
+	node = r2net_target_node;
+	if (!node)
+		goto out;
+
+	nodenum = r2net_target_nodenum;
+
+	r2nm_node_get(node);
+
+	nn = r2net_nn_from_num(nodenum);
+	if (nn->nn_persistent_error || !nn->nn_sc_valid) {
+		ret = -ENOTCONN;
+		r2nm_node_put(node);
+		goto out;
+	}
+
+	if (ephemeral)
+		msg_type = RMSTR_TMEM_PUT_EPH;
+	else
+		msg_type = RMSTR_TMEM_PUT_PERS;
+#ifdef RAMSTER_TESTING
+	/* leave me here to see if it catches a weird crash */
+	ramster_check_irq_counts();
+#endif
+
+	ret = r2net_send_message_vec(msg_type, RMSTR_KEY, vec, veclen,
+						nodenum, &status);
+	if (ret < 0)
+		ret = -1;
+	else {
+		ret = status;
+		*remotenode = nodenum;
+	}
+
+	r2nm_node_put(node);
+out:
+	return ret;
+}
+
+int r2net_remote_flush(struct tmem_xhandle *xh, int remotenode)
+{
+	int ret = -1, status;
+	struct r2nm_node *node = NULL;
+	struct kvec vec[1];
+	size_t veclen = 1;
+
+	node = r2nm_get_node_by_num(remotenode);
+	BUG_ON(node == NULL);
+	xh->client_id = r2nm_this_node(); /* which node is flushing */
+	vec[0].iov_len = sizeof(*xh);
+	vec[0].iov_base = xh;
+	BUG_ON(irqs_disabled());
+	BUG_ON(in_softirq());
+	ret = r2net_send_message_vec(RMSTR_TMEM_FLUSH, RMSTR_KEY,
+					vec, veclen, remotenode, &status);
+	r2nm_node_put(node);
+	return ret;
+}
+
+int r2net_remote_flush_object(struct tmem_xhandle *xh, int remotenode)
+{
+	int ret = -1, status;
+	struct r2nm_node *node = NULL;
+	struct kvec vec[1];
+	size_t veclen = 1;
+
+	node = r2nm_get_node_by_num(remotenode);
+	BUG_ON(node == NULL);
+	xh->client_id = r2nm_this_node(); /* which node is flobjing */
+	vec[0].iov_len = sizeof(*xh);
+	vec[0].iov_base = xh;
+	ret = r2net_send_message_vec(RMSTR_TMEM_FLOBJ, RMSTR_KEY,
+					vec, veclen, remotenode, &status);
+	r2nm_node_put(node);
+	return ret;
+}
+
+/*
+ * Handler registration
+ */
+
+static LIST_HEAD(r2net_unreg_list);
+
+static void r2net_unregister_handlers(void)
+{
+	r2net_unregister_handler_list(&r2net_unreg_list);
+}
+
+int r2net_register_handlers(void)
+{
+	int status;
+
+	status = r2net_register_handler(RMSTR_TMEM_PUT_EPH, RMSTR_KEY,
+				RMSTR_R2NET_MAX_LEN,
+				ramster_remote_put_handler,
+				NULL, NULL, &r2net_unreg_list);
+	if (status)
+		goto bail;
+
+	status = r2net_register_handler(RMSTR_TMEM_PUT_PERS, RMSTR_KEY,
+				RMSTR_R2NET_MAX_LEN,
+				ramster_remote_put_handler,
+				NULL, NULL, &r2net_unreg_list);
+	if (status)
+		goto bail;
+
+	status = r2net_register_handler(RMSTR_TMEM_ASYNC_GET_REQUEST, RMSTR_KEY,
+				RMSTR_R2NET_MAX_LEN,
+				ramster_remote_async_get_request_handler,
+				NULL, NULL,
+				&r2net_unreg_list);
+	if (status)
+		goto bail;
+
+	status = r2net_register_handler(RMSTR_TMEM_ASYNC_GET_AND_FREE_REQUEST,
+				RMSTR_KEY, RMSTR_R2NET_MAX_LEN,
+				ramster_remote_async_get_request_handler,
+				NULL, NULL,
+				&r2net_unreg_list);
+	if (status)
+		goto bail;
+
+	status = r2net_register_handler(RMSTR_TMEM_ASYNC_GET_REPLY, RMSTR_KEY,
+				RMSTR_R2NET_MAX_LEN,
+				ramster_remote_async_get_reply_handler,
+				NULL, NULL,
+				&r2net_unreg_list);
+	if (status)
+		goto bail;
+
+	status = r2net_register_handler(RMSTR_TMEM_FLUSH, RMSTR_KEY,
+				RMSTR_R2NET_MAX_LEN,
+				ramster_remote_flush_handler,
+				NULL, NULL,
+				&r2net_unreg_list);
+	if (status)
+		goto bail;
+
+	status = r2net_register_handler(RMSTR_TMEM_FLOBJ, RMSTR_KEY,
+				RMSTR_R2NET_MAX_LEN,
+				ramster_remote_flobj_handler,
+				NULL, NULL,
+				&r2net_unreg_list);
+	if (status)
+		goto bail;
+
+	pr_info("ramster: r2net handlers registered\n");
+
+bail:
+	if (status) {
+		r2net_unregister_handlers();
+		pr_err("ramster: couldn't register r2net handlers\n");
+	}
+	return status;
+}
diff --git a/drivers/staging/zcache/ramster/ramster.c b/drivers/staging/zcache/ramster/ramster.c
new file mode 100644
index 0000000..c06709f
--- /dev/null
+++ b/drivers/staging/zcache/ramster/ramster.c
@@ -0,0 +1,985 @@
+/*
+ * ramster.c
+ *
+ * Copyright (c) 2010-2012, Dan Magenheimer, Oracle Corp.
+ *
+ * RAMster implements peer-to-peer transcendent memory, allowing a "cluster" of
+ * kernels to dynamically pool their RAM so that a RAM-hungry workload on one
+ * machine can temporarily and transparently utilize RAM on another machine
+ * which is presumably idle or running a non-RAM-hungry workload.
+ *
+ * RAMster combines a clustering and messaging foundation based on the ocfs2
+ * cluster layer with the in-kernel compression implementation of zcache, and
+ * adds code to glue them together.  When a page is "put" to RAMster, it is
+ * compressed and stored locally.  Periodically, a thread will "remotify" these
+ * pages by sending them via messages to a remote machine.  When the page is
+ * later needed as indicated by a page fault, a "get" is issued.  If the data
+ * is local, it is uncompressed and the fault is resolved.  If the data is
+ * remote, a message is sent to fetch the data and the faulting thread sleeps;
+ * when the data arrives, the thread awakens, the data is decompressed and
+ * the fault is resolved.
+
+ * As of V5, clusters up to eight nodes are supported; each node can remotify
+ * pages to one specified node, so clusters can be configured as clients to
+ * a "memory server".  Some simple policy is in place that will need to be
+ * refined over time.  Larger clusters and fault-resistant protocols can also
+ * be added over time.
+ */
+
+#include <linux/module.h>
+#include <linux/cpu.h>
+#include <linux/highmem.h>
+#include <linux/list.h>
+#include <linux/lzo.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/types.h>
+#include <linux/atomic.h>
+#include <linux/frontswap.h>
+#include "../tmem.h"
+#include "../zcache.h"
+#include "../zbud.h"
+#include "ramster.h"
+#include "ramster_nodemanager.h"
+#include "tcp.h"
+
+#define RAMSTER_TESTING
+
+#ifndef CONFIG_SYSFS
+#error "ramster needs sysfs to define cluster nodes to use"
+#endif
+
+static bool use_cleancache __read_mostly;
+static bool use_frontswap __read_mostly;
+static bool use_frontswap_exclusive_gets __read_mostly;
+
+/* These must be sysfs not debugfs as they are checked/used by userland!! */
+static unsigned long ramster_interface_revision __read_mostly =
+	R2NM_API_VERSION; /* interface revision must match userspace! */
+static unsigned long ramster_pers_remotify_enable __read_mostly;
+static unsigned long ramster_eph_remotify_enable __read_mostly;
+static atomic_t ramster_remote_pers_pages = ATOMIC_INIT(0);
+#define MANUAL_NODES 8
+static bool ramster_nodes_manual_up[MANUAL_NODES] __read_mostly;
+static int ramster_remote_target_nodenum __read_mostly = -1;
+
+/* these counters are made available via debugfs */
+static long ramster_flnodes;
+static atomic_t ramster_flnodes_atomic = ATOMIC_INIT(0);
+static unsigned long ramster_flnodes_max;
+static long ramster_foreign_eph_pages;
+static atomic_t ramster_foreign_eph_pages_atomic = ATOMIC_INIT(0);
+static unsigned long ramster_foreign_eph_pages_max;
+static long ramster_foreign_pers_pages;
+static atomic_t ramster_foreign_pers_pages_atomic = ATOMIC_INIT(0);
+static unsigned long ramster_foreign_pers_pages_max;
+static unsigned long ramster_eph_pages_remoted;
+static unsigned long ramster_pers_pages_remoted;
+static unsigned long ramster_eph_pages_remote_failed;
+static unsigned long ramster_pers_pages_remote_failed;
+static unsigned long ramster_remote_eph_pages_succ_get;
+static unsigned long ramster_remote_pers_pages_succ_get;
+static unsigned long ramster_remote_eph_pages_unsucc_get;
+static unsigned long ramster_remote_pers_pages_unsucc_get;
+static unsigned long ramster_pers_pages_remote_nomem;
+static unsigned long ramster_remote_objects_flushed;
+static unsigned long ramster_remote_object_flushes_failed;
+static unsigned long ramster_remote_pages_flushed;
+static unsigned long ramster_remote_page_flushes_failed;
+/* FIXME frontswap selfshrinking knobs in debugfs? */
+
+#ifdef CONFIG_DEBUG_FS
+#include <linux/debugfs.h>
+#define	zdfs	debugfs_create_size_t
+#define	zdfs64	debugfs_create_u64
+static int __init ramster_debugfs_init(void)
+{
+	struct dentry *root = debugfs_create_dir("ramster", NULL);
+	if (root == NULL)
+		return -ENXIO;
+
+	zdfs("eph_pages_remoted", S_IRUGO, root, &ramster_eph_pages_remoted);
+	zdfs("pers_pages_remoted", S_IRUGO, root, &ramster_pers_pages_remoted);
+	zdfs("eph_pages_remote_failed", S_IRUGO, root,
+			&ramster_eph_pages_remote_failed);
+	zdfs("pers_pages_remote_failed", S_IRUGO, root,
+			&ramster_pers_pages_remote_failed);
+	zdfs("remote_eph_pages_succ_get", S_IRUGO, root,
+			&ramster_remote_eph_pages_succ_get);
+	zdfs("remote_pers_pages_succ_get", S_IRUGO, root,
+			&ramster_remote_pers_pages_succ_get);
+	zdfs("remote_eph_pages_unsucc_get", S_IRUGO, root,
+			&ramster_remote_eph_pages_unsucc_get);
+	zdfs("remote_pers_pages_unsucc_get", S_IRUGO, root,
+			&ramster_remote_pers_pages_unsucc_get);
+	zdfs("pers_pages_remote_nomem", S_IRUGO, root,
+			&ramster_pers_pages_remote_nomem);
+	zdfs("remote_objects_flushed", S_IRUGO, root,
+			&ramster_remote_objects_flushed);
+	zdfs("remote_pages_flushed", S_IRUGO, root,
+			&ramster_remote_pages_flushed);
+	zdfs("remote_object_flushes_failed", S_IRUGO, root,
+			&ramster_remote_object_flushes_failed);
+	zdfs("remote_page_flushes_failed", S_IRUGO, root,
+			&ramster_remote_page_flushes_failed);
+	zdfs("foreign_eph_pages", S_IRUGO, root,
+			&ramster_foreign_eph_pages);
+	zdfs("foreign_eph_pages_max", S_IRUGO, root,
+			&ramster_foreign_eph_pages_max);
+	zdfs("foreign_pers_pages", S_IRUGO, root,
+			&ramster_foreign_pers_pages);
+	zdfs("foreign_pers_pages_max", S_IRUGO, root,
+			&ramster_foreign_pers_pages_max);
+	return 0;
+}
+#undef	zdebugfs
+#undef	zdfs64
+#endif
+
+static LIST_HEAD(ramster_rem_op_list);
+static DEFINE_SPINLOCK(ramster_rem_op_list_lock);
+static DEFINE_PER_CPU(struct ramster_preload, ramster_preloads);
+
+static DEFINE_PER_CPU(unsigned char *, ramster_remoteputmem1);
+static DEFINE_PER_CPU(unsigned char *, ramster_remoteputmem2);
+
+static struct kmem_cache *ramster_flnode_cache __read_mostly;
+
+static struct flushlist_node *ramster_flnode_alloc(struct tmem_pool *pool)
+{
+	struct flushlist_node *flnode = NULL;
+	struct ramster_preload *kp;
+
+	kp = &__get_cpu_var(ramster_preloads);
+	flnode = kp->flnode;
+	BUG_ON(flnode == NULL);
+	kp->flnode = NULL;
+	ramster_flnodes = atomic_inc_return(&ramster_flnodes_atomic);
+	if (ramster_flnodes > ramster_flnodes_max)
+		ramster_flnodes_max = ramster_flnodes;
+	return flnode;
+}
+
+/* the "flush list" asynchronously collects pages to remotely flush */
+#define FLUSH_ENTIRE_OBJECT ((uint32_t)-1)
+static void ramster_flnode_free(struct flushlist_node *flnode,
+				struct tmem_pool *pool)
+{
+	int flnodes;
+
+	flnodes = atomic_dec_return(&ramster_flnodes_atomic);
+	BUG_ON(flnodes < 0);
+	kmem_cache_free(ramster_flnode_cache, flnode);
+}
+
+int ramster_do_preload_flnode(struct tmem_pool *pool)
+{
+	struct ramster_preload *kp;
+	struct flushlist_node *flnode;
+	int ret = -ENOMEM;
+
+	BUG_ON(!irqs_disabled());
+	if (unlikely(ramster_flnode_cache == NULL))
+		BUG();
+	kp = &__get_cpu_var(ramster_preloads);
+	flnode = kmem_cache_alloc(ramster_flnode_cache, GFP_ATOMIC);
+	if (unlikely(flnode == NULL) && kp->flnode == NULL)
+		BUG();  /* FIXME handle more gracefully, but how??? */
+	else if (kp->flnode == NULL)
+		kp->flnode = flnode;
+	else
+		kmem_cache_free(ramster_flnode_cache, flnode);
+	return ret;
+}
+
+/*
+ * Called by the message handler after a (still compressed) page has been
+ * fetched from the remote machine in response to an "is_remote" tmem_get
+ * or persistent tmem_localify.  For a tmem_get, "extra" is the address of
+ * the page that is to be filled to successfully resolve the tmem_get; for
+ * a (persistent) tmem_localify, "extra" is NULL (as the data is placed only
+ * in the local zcache).  "data" points to "size" bytes of (compressed) data
+ * passed in the message.  In the case of a persistent remote get, if
+ * pre-allocation was successful (see ramster_repatriate_preload), the page
+ * is placed into both local zcache and at "extra".
+ */
+int ramster_localify(int pool_id, struct tmem_oid *oidp, uint32_t index,
+			char *data, unsigned int size, void *extra)
+{
+	int ret = -ENOENT;
+	unsigned long flags;
+	struct tmem_pool *pool;
+	bool eph, delete = false;
+	void *pampd, *saved_hb;
+	struct tmem_obj *obj;
+
+	pool = zcache_get_pool_by_id(LOCAL_CLIENT, pool_id);
+	if (unlikely(pool == NULL))
+		/* pool doesn't exist anymore */
+		goto out;
+	eph = is_ephemeral(pool);
+	local_irq_save(flags);  /* FIXME: maybe only disable softirqs? */
+	pampd = tmem_localify_get_pampd(pool, oidp, index, &obj, &saved_hb);
+	if (pampd == NULL) {
+		/* hmmm... must have been a flush while waiting */
+#ifdef RAMSTER_TESTING
+		pr_err("UNTESTED pampd==NULL in ramster_localify\n");
+#endif
+		if (eph)
+			ramster_remote_eph_pages_unsucc_get++;
+		else
+			ramster_remote_pers_pages_unsucc_get++;
+		obj = NULL;
+		goto finish;
+	} else if (unlikely(!pampd_is_remote(pampd))) {
+		/* hmmm... must have been a dup put while waiting */
+#ifdef RAMSTER_TESTING
+		pr_err("UNTESTED dup while waiting in ramster_localify\n");
+#endif
+		if (eph)
+			ramster_remote_eph_pages_unsucc_get++;
+		else
+			ramster_remote_pers_pages_unsucc_get++;
+		obj = NULL;
+		pampd = NULL;
+		ret = -EEXIST;
+		goto finish;
+	} else if (size == 0) {
+		/* no remote data, delete the local is_remote pampd */
+		pampd = NULL;
+		if (eph)
+			ramster_remote_eph_pages_unsucc_get++;
+		else
+			BUG();
+		delete = true;
+		goto finish;
+	}
+	if (pampd_is_intransit(pampd)) {
+		/*
+		 *  a pampd is marked intransit if it is remote and space has
+		 *  been allocated for it locally (note, only happens for
+		 *  persistent pages, in which case the remote copy is freed)
+		 */
+		BUG_ON(eph);
+		pampd = pampd_mask_intransit_and_remote(pampd);
+		zbud_copy_to_zbud(pampd, data, size);
+	} else {
+		/*
+		 * setting pampd to NULL tells tmem_localify_finish to leave
+		 * pampd alone... meaning it is left pointing to the
+		 * remote copy
+		 */
+		pampd = NULL;
+		obj = NULL;
+	}
+	/*
+	 * but in all cases, we decompress direct-to-memory to complete
+	 * the remotify and return success
+	 */
+	BUG_ON(extra == NULL);
+	zcache_decompress_to_page(data, size, (struct page *)extra);
+	if (eph)
+		ramster_remote_eph_pages_succ_get++;
+	else
+		ramster_remote_pers_pages_succ_get++;
+	ret = 0;
+finish:
+	tmem_localify_finish(obj, index, pampd, saved_hb, delete);
+	zcache_put_pool(pool);
+	local_irq_restore(flags);
+out:
+	return ret;
+}
+
+void ramster_pampd_new_obj(struct tmem_obj *obj)
+{
+	obj->extra = NULL;
+}
+
+void ramster_pampd_free_obj(struct tmem_pool *pool, struct tmem_obj *obj,
+				bool pool_destroy)
+{
+	struct flushlist_node *flnode;
+
+	BUG_ON(preemptible());
+	if (obj->extra == NULL)
+		return;
+	if (pool_destroy && is_ephemeral(pool))
+		/* FIXME don't bother with remote eph data for now */
+		return;
+	BUG_ON(!pampd_is_remote(obj->extra));
+	flnode = ramster_flnode_alloc(pool);
+	flnode->xh.client_id = pampd_remote_node(obj->extra);
+	flnode->xh.pool_id = pool->pool_id;
+	flnode->xh.oid = obj->oid;
+	flnode->xh.index = FLUSH_ENTIRE_OBJECT;
+	flnode->rem_op.op = RAMSTER_REMOTIFY_FLUSH_OBJ;
+	spin_lock(&ramster_rem_op_list_lock);
+	list_add(&flnode->rem_op.list, &ramster_rem_op_list);
+	spin_unlock(&ramster_rem_op_list_lock);
+}
+
+/*
+ * Called on a remote persistent tmem_get to attempt to preallocate
+ * local storage for the data contained in the remote persistent page.
+ * If successfully preallocated, returns the pampd, marked as remote and
+ * in_transit.  Else returns NULL.  Note that the appropriate tmem data
+ * structure must be locked.
+ */
+void *ramster_pampd_repatriate_preload(void *pampd, struct tmem_pool *pool,
+					struct tmem_oid *oidp, uint32_t index,
+					bool *intransit)
+{
+	int clen = pampd_remote_size(pampd), c;
+	void *ret_pampd = NULL;
+	unsigned long flags;
+	struct tmem_handle th;
+
+	BUG_ON(!pampd_is_remote(pampd));
+	BUG_ON(is_ephemeral(pool));
+	if (use_frontswap_exclusive_gets)
+		/* don't need local storage */
+		goto out;
+	if (pampd_is_intransit(pampd)) {
+		/*
+		 * to avoid multiple allocations (and maybe a memory leak)
+		 * don't preallocate if already in the process of being
+		 * repatriated
+		 */
+		*intransit = true;
+		goto out;
+	}
+	*intransit = false;
+	local_irq_save(flags);
+	th.client_id = pampd_remote_node(pampd);
+	th.pool_id = pool->pool_id;
+	th.oid = *oidp;
+	th.index = index;
+	ret_pampd = zcache_pampd_create(NULL, clen, true, false, &th);
+	if (ret_pampd != NULL) {
+		/*
+		 *  a pampd is marked intransit if it is remote and space has
+		 *  been allocated for it locally (note, only happens for
+		 *  persistent pages, in which case the remote copy is freed)
+		 */
+		ret_pampd = pampd_mark_intransit(ret_pampd);
+		c = atomic_dec_return(&ramster_remote_pers_pages);
+		WARN_ON_ONCE(c < 0);
+	} else {
+		ramster_pers_pages_remote_nomem++;
+	}
+	local_irq_restore(flags);
+out:
+	return ret_pampd;
+}
+
+/*
+ * Called on a remote tmem_get to invoke a message to fetch the page.
+ * Might sleep so no tmem locks can be held.  "extra" is passed
+ * all the way through the round-trip messaging to ramster_localify.
+ */
+int ramster_pampd_repatriate(void *fake_pampd, void *real_pampd,
+				struct tmem_pool *pool,
+				struct tmem_oid *oid, uint32_t index,
+				bool free, void *extra)
+{
+	struct tmem_xhandle xh;
+	int ret;
+
+	if (pampd_is_intransit(real_pampd))
+		/* have local space pre-reserved, so free remote copy */
+		free = true;
+	xh = tmem_xhandle_fill(LOCAL_CLIENT, pool, oid, index);
+	/* unreliable request/response for now */
+	ret = r2net_remote_async_get(&xh, free,
+					pampd_remote_node(fake_pampd),
+					pampd_remote_size(fake_pampd),
+					pampd_remote_cksum(fake_pampd),
+					extra);
+	return ret;
+}
+
+bool ramster_pampd_is_remote(void *pampd)
+{
+	return pampd_is_remote(pampd);
+}
+
+int ramster_pampd_replace_in_obj(void *new_pampd, struct tmem_obj *obj)
+{
+	int ret = -1;
+
+	if (new_pampd != NULL) {
+		if (obj->extra == NULL)
+			obj->extra = new_pampd;
+		/* enforce that all remote pages in an object reside
+		 * in the same node! */
+		else if (pampd_remote_node(new_pampd) !=
+				pampd_remote_node((void *)(obj->extra)))
+			BUG();
+		ret = 0;
+	}
+	return ret;
+}
+
+void *ramster_pampd_free(void *pampd, struct tmem_pool *pool,
+			      struct tmem_oid *oid, uint32_t index, bool acct)
+{
+	bool eph = is_ephemeral(pool);
+	void *local_pampd = NULL;
+	int c;
+
+	BUG_ON(preemptible());
+	BUG_ON(!pampd_is_remote(pampd));
+	WARN_ON(acct == false);
+	if (oid == NULL) {
+		/*
+		 * a NULL oid means to ignore this pampd free
+		 * as the remote freeing will be handled elsewhere
+		 */
+	} else if (eph) {
+		/* FIXME remote flush optional but probably good idea */
+	} else if (pampd_is_intransit(pampd)) {
+		/* did a pers remote get_and_free, so just free local */
+		local_pampd = pampd_mask_intransit_and_remote(pampd);
+	} else {
+		struct flushlist_node *flnode =
+			ramster_flnode_alloc(pool);
+
+		flnode->xh.client_id = pampd_remote_node(pampd);
+		flnode->xh.pool_id = pool->pool_id;
+		flnode->xh.oid = *oid;
+		flnode->xh.index = index;
+		flnode->rem_op.op = RAMSTER_REMOTIFY_FLUSH_PAGE;
+		spin_lock(&ramster_rem_op_list_lock);
+		list_add(&flnode->rem_op.list, &ramster_rem_op_list);
+		spin_unlock(&ramster_rem_op_list_lock);
+		c = atomic_dec_return(&ramster_remote_pers_pages);
+		WARN_ON_ONCE(c < 0);
+	}
+	return local_pampd;
+}
+
+void ramster_count_foreign_pages(bool eph, int count)
+{
+	int c;
+
+	BUG_ON(count != 1 && count != -1);
+	if (eph) {
+		if (count > 0) {
+			c = atomic_inc_return(
+					&ramster_foreign_eph_pages_atomic);
+			if (c > ramster_foreign_eph_pages_max)
+				ramster_foreign_eph_pages_max = c;
+		} else {
+			c = atomic_dec_return(&ramster_foreign_eph_pages_atomic);
+			WARN_ON_ONCE(c < 0);
+		}
+		ramster_foreign_eph_pages = c;
+	} else {
+		if (count > 0) {
+			c = atomic_inc_return(
+					&ramster_foreign_pers_pages_atomic);
+			if (c > ramster_foreign_pers_pages_max)
+				ramster_foreign_pers_pages_max = c;
+		} else {
+			c = atomic_dec_return(
+					&ramster_foreign_pers_pages_atomic);
+			WARN_ON_ONCE(c < 0);
+		}
+		ramster_foreign_pers_pages = c;
+	}
+}
+
+/*
+ * For now, just push over a few pages every few seconds to
+ * ensure that it basically works
+ */
+static struct workqueue_struct *ramster_remotify_workqueue;
+static void ramster_remotify_process(struct work_struct *work);
+static DECLARE_DELAYED_WORK(ramster_remotify_worker,
+		ramster_remotify_process);
+
+static void ramster_remotify_queue_delayed_work(unsigned long delay)
+{
+	if (!queue_delayed_work(ramster_remotify_workqueue,
+				&ramster_remotify_worker, delay))
+		pr_err("ramster_remotify: bad workqueue\n");
+}
+
+static void ramster_remote_flush_page(struct flushlist_node *flnode)
+{
+	struct tmem_xhandle *xh;
+	int remotenode, ret;
+
+	preempt_disable();
+	xh = &flnode->xh;
+	remotenode = flnode->xh.client_id;
+	ret = r2net_remote_flush(xh, remotenode);
+	if (ret >= 0)
+		ramster_remote_pages_flushed++;
+	else
+		ramster_remote_page_flushes_failed++;
+	preempt_enable_no_resched();
+	ramster_flnode_free(flnode, NULL);
+}
+
+static void ramster_remote_flush_object(struct flushlist_node *flnode)
+{
+	struct tmem_xhandle *xh;
+	int remotenode, ret;
+
+	preempt_disable();
+	xh = &flnode->xh;
+	remotenode = flnode->xh.client_id;
+	ret = r2net_remote_flush_object(xh, remotenode);
+	if (ret >= 0)
+		ramster_remote_objects_flushed++;
+	else
+		ramster_remote_object_flushes_failed++;
+	preempt_enable_no_resched();
+	ramster_flnode_free(flnode, NULL);
+}
+
+int ramster_remotify_pageframe(bool eph)
+{
+	struct tmem_xhandle xh;
+	unsigned int size;
+	int remotenode, ret, zbuds;
+	struct tmem_pool *pool;
+	unsigned long flags;
+	unsigned char cksum;
+	char *p;
+	int i, j;
+	unsigned char *tmpmem[2];
+	struct tmem_handle th[2];
+	unsigned int zsize[2];
+
+	tmpmem[0] = __get_cpu_var(ramster_remoteputmem1);
+	tmpmem[1] = __get_cpu_var(ramster_remoteputmem2);
+	local_bh_disable();
+	zbuds = zbud_make_zombie_lru(&th[0], &tmpmem[0], &zsize[0], eph);
+	/* now OK to release lock set in caller */
+	local_bh_enable();
+	if (zbuds == 0)
+		goto out;
+	BUG_ON(zbuds > 2);
+	for (i = 0; i < zbuds; i++) {
+		xh.client_id = th[i].client_id;
+		xh.pool_id = th[i].pool_id;
+		xh.oid = th[i].oid;
+		xh.index = th[i].index;
+		size = zsize[i];
+		BUG_ON(size == 0 || size > zbud_max_buddy_size());
+		for (p = tmpmem[i], cksum = 0, j = 0; j < size; j++)
+			cksum += *p++;
+		ret = r2net_remote_put(&xh, tmpmem[i], size, eph, &remotenode);
+		if (ret != 0) {
+		/*
+		 * This is some form of a memory leak... if the remote put
+		 * fails, there will never be another attempt to remotify
+		 * this page.  But since we've dropped the zv pointer,
+		 * the page may have been freed or the data replaced
+		 * so we can't just "put it back" in the remote op list.
+		 * Even if we could, not sure where to put it in the list
+		 * because there may be flushes that must be strictly
+		 * ordered vs the put.  So leave this as a FIXME for now.
+		 * But count them so we know if it becomes a problem.
+		 */
+			if (eph)
+				ramster_eph_pages_remote_failed++;
+			else
+				ramster_pers_pages_remote_failed++;
+			break;
+		} else {
+			if (!eph)
+				atomic_inc(&ramster_remote_pers_pages);
+		}
+		if (eph)
+			ramster_eph_pages_remoted++;
+		else
+			ramster_pers_pages_remoted++;
+		/*
+		 * data was successfully remoted so change the local version to
+		 * point to the remote node where it landed
+		 */
+		local_bh_disable();
+		pool = zcache_get_pool_by_id(LOCAL_CLIENT, xh.pool_id);
+		local_irq_save(flags);
+		(void)tmem_replace(pool, &xh.oid, xh.index,
+				pampd_make_remote(remotenode, size, cksum));
+		local_irq_restore(flags);
+		zcache_put_pool(pool);
+		local_bh_enable();
+	}
+out:
+	return zbuds;
+}
+
+static void zcache_do_remotify_flushes(void)
+{
+	struct ramster_remotify_hdr *rem_op;
+	union remotify_list_node *u;
+
+	while (1) {
+		spin_lock(&ramster_rem_op_list_lock);
+		if (list_empty(&ramster_rem_op_list)) {
+			spin_unlock(&ramster_rem_op_list_lock);
+			goto out;
+		}
+		rem_op = list_first_entry(&ramster_rem_op_list,
+				struct ramster_remotify_hdr, list);
+		list_del_init(&rem_op->list);
+		spin_unlock(&ramster_rem_op_list_lock);
+		u = (union remotify_list_node *)rem_op;
+		switch (rem_op->op) {
+		case RAMSTER_REMOTIFY_FLUSH_PAGE:
+			ramster_remote_flush_page((struct flushlist_node *)u);
+			break;
+		case RAMSTER_REMOTIFY_FLUSH_OBJ:
+			ramster_remote_flush_object((struct flushlist_node *)u);
+			break;
+		default:
+			BUG();
+		}
+	}
+out:
+	return;
+}
+
+static void ramster_remotify_process(struct work_struct *work)
+{
+	static bool remotify_in_progress;
+	int i;
+
+	BUG_ON(irqs_disabled());
+	if (remotify_in_progress)
+		goto requeue;
+	if (ramster_remote_target_nodenum == -1)
+		goto requeue;
+	remotify_in_progress = true;
+	if (use_cleancache && ramster_eph_remotify_enable) {
+		for (i = 0; i < 100; i++) {
+			zcache_do_remotify_flushes();
+			(void)ramster_remotify_pageframe(true);
+		}
+	}
+	if (use_frontswap && ramster_pers_remotify_enable) {
+		for (i = 0; i < 100; i++) {
+			zcache_do_remotify_flushes();
+			(void)ramster_remotify_pageframe(false);
+		}
+	}
+	remotify_in_progress = false;
+requeue:
+	ramster_remotify_queue_delayed_work(HZ);
+}
+
+void __init ramster_remotify_init(void)
+{
+	unsigned long n = 60UL;
+	ramster_remotify_workqueue =
+		create_singlethread_workqueue("ramster_remotify");
+	ramster_remotify_queue_delayed_work(n * HZ);
+}
+
+static ssize_t ramster_manual_node_up_show(struct kobject *kobj,
+				struct kobj_attribute *attr, char *buf)
+{
+	int i;
+	char *p = buf;
+	for (i = 0; i < MANUAL_NODES; i++)
+		if (ramster_nodes_manual_up[i])
+			p += sprintf(p, "%d ", i);
+	p += sprintf(p, "\n");
+	return p - buf;
+}
+
+static ssize_t ramster_manual_node_up_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	int err;
+	unsigned long node_num;
+
+	err = kstrtoul(buf, 10, &node_num);
+	if (err) {
+		pr_err("ramster: bad strtoul?\n");
+		return -EINVAL;
+	}
+	if (node_num >= MANUAL_NODES) {
+		pr_err("ramster: bad node_num=%lu?\n", node_num);
+		return -EINVAL;
+	}
+	if (ramster_nodes_manual_up[node_num]) {
+		pr_err("ramster: node %d already up, ignoring\n",
+							(int)node_num);
+	} else {
+		ramster_nodes_manual_up[node_num] = true;
+		r2net_hb_node_up_manual((int)node_num);
+	}
+	return count;
+}
+
+static struct kobj_attribute ramster_manual_node_up_attr = {
+	.attr = { .name = "manual_node_up", .mode = 0644 },
+	.show = ramster_manual_node_up_show,
+	.store = ramster_manual_node_up_store,
+};
+
+static ssize_t ramster_remote_target_nodenum_show(struct kobject *kobj,
+				struct kobj_attribute *attr, char *buf)
+{
+	if (ramster_remote_target_nodenum == -1UL)
+		return sprintf(buf, "unset\n");
+	else
+		return sprintf(buf, "%d\n", ramster_remote_target_nodenum);
+}
+
+static ssize_t ramster_remote_target_nodenum_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	int err;
+	unsigned long node_num;
+
+	err = kstrtoul(buf, 10, &node_num);
+	if (err) {
+		pr_err("ramster: bad strtoul?\n");
+		return -EINVAL;
+	} else if (node_num == -1UL) {
+		pr_err("ramster: disabling all remotification, "
+			"data may still reside on remote nodes however\n");
+		return -EINVAL;
+	} else if (node_num >= MANUAL_NODES) {
+		pr_err("ramster: bad node_num=%lu?\n", node_num);
+		return -EINVAL;
+	} else if (!ramster_nodes_manual_up[node_num]) {
+		pr_err("ramster: node %d not up, ignoring setting "
+			"of remotification target\n", (int)node_num);
+	} else if (r2net_remote_target_node_set((int)node_num) >= 0) {
+		pr_info("ramster: node %d set as remotification target\n",
+				(int)node_num);
+		ramster_remote_target_nodenum = (int)node_num;
+	} else {
+		pr_err("ramster: bad num to node node_num=%d?\n",
+				(int)node_num);
+		return -EINVAL;
+	}
+	return count;
+}
+
+static struct kobj_attribute ramster_remote_target_nodenum_attr = {
+	.attr = { .name = "remote_target_nodenum", .mode = 0644 },
+	.show = ramster_remote_target_nodenum_show,
+	.store = ramster_remote_target_nodenum_store,
+};
+
+#define RAMSTER_SYSFS_RO(_name) \
+	static ssize_t ramster_##_name##_show(struct kobject *kobj, \
+				struct kobj_attribute *attr, char *buf) \
+	{ \
+		return sprintf(buf, "%lu\n", ramster_##_name); \
+	} \
+	static struct kobj_attribute ramster_##_name##_attr = { \
+		.attr = { .name = __stringify(_name), .mode = 0444 }, \
+		.show = ramster_##_name##_show, \
+	}
+
+#define RAMSTER_SYSFS_RW(_name) \
+	static ssize_t ramster_##_name##_show(struct kobject *kobj, \
+				struct kobj_attribute *attr, char *buf) \
+	{ \
+		return sprintf(buf, "%lu\n", ramster_##_name); \
+	} \
+	static ssize_t ramster_##_name##_store(struct kobject *kobj, \
+		struct kobj_attribute *attr, const char *buf, size_t count) \
+	{ \
+		int err; \
+		unsigned long enable; \
+		err = kstrtoul(buf, 10, &enable); \
+		if (err) \
+			return -EINVAL; \
+		ramster_##_name = enable; \
+		return count; \
+	} \
+	static struct kobj_attribute ramster_##_name##_attr = { \
+		.attr = { .name = __stringify(_name), .mode = 0644 }, \
+		.show = ramster_##_name##_show, \
+		.store = ramster_##_name##_store, \
+	}
+
+#define RAMSTER_SYSFS_RO_ATOMIC(_name) \
+	static ssize_t ramster_##_name##_show(struct kobject *kobj, \
+				struct kobj_attribute *attr, char *buf) \
+	{ \
+	    return sprintf(buf, "%d\n", atomic_read(&ramster_##_name)); \
+	} \
+	static struct kobj_attribute ramster_##_name##_attr = { \
+		.attr = { .name = __stringify(_name), .mode = 0444 }, \
+		.show = ramster_##_name##_show, \
+	}
+
+RAMSTER_SYSFS_RO(interface_revision);
+RAMSTER_SYSFS_RO_ATOMIC(remote_pers_pages);
+RAMSTER_SYSFS_RW(pers_remotify_enable);
+RAMSTER_SYSFS_RW(eph_remotify_enable);
+
+static struct attribute *ramster_attrs[] = {
+	&ramster_interface_revision_attr.attr,
+	&ramster_remote_pers_pages_attr.attr,
+	&ramster_manual_node_up_attr.attr,
+	&ramster_remote_target_nodenum_attr.attr,
+	&ramster_pers_remotify_enable_attr.attr,
+	&ramster_eph_remotify_enable_attr.attr,
+	NULL,
+};
+
+static struct attribute_group ramster_attr_group = {
+	.attrs = ramster_attrs,
+	.name = "ramster",
+};
+
+/*
+ * frontswap selfshrinking
+ */
+
+/* In HZ, controls frequency of worker invocation. */
+static unsigned int selfshrink_interval __read_mostly = 5;
+/* Enable/disable with sysfs. */
+static bool frontswap_selfshrinking __read_mostly;
+
+static void selfshrink_process(struct work_struct *work);
+static DECLARE_DELAYED_WORK(selfshrink_worker, selfshrink_process);
+
+/* Enable/disable with kernel boot option. */
+static bool use_frontswap_selfshrink __initdata = true;
+
+/*
+ * The default values for the following parameters were deemed reasonable
+ * by experimentation, may be workload-dependent, and can all be
+ * adjusted via sysfs.
+ */
+
+/* Control rate for frontswap shrinking. Higher hysteresis is slower. */
+static unsigned int frontswap_hysteresis __read_mostly = 20;
+
+/*
+ * Number of selfshrink worker invocations to wait before observing that
+ * frontswap selfshrinking should commence. Note that selfshrinking does
+ * not use a separate worker thread.
+ */
+static unsigned int frontswap_inertia __read_mostly = 3;
+
+/* Countdown to next invocation of frontswap_shrink() */
+static unsigned long frontswap_inertia_counter;
+
+/*
+ * Invoked by the selfshrink worker thread, uses current number of pages
+ * in frontswap (frontswap_curr_pages()), previous status, and control
+ * values (hysteresis and inertia) to determine if frontswap should be
+ * shrunk and what the new frontswap size should be.  Note that
+ * frontswap_shrink is essentially a partial swapoff that immediately
+ * transfers pages from the "swap device" (frontswap) back into kernel
+ * RAM; despite the name, frontswap "shrinking" is very different from
+ * the "shrinker" interface used by the kernel MM subsystem to reclaim
+ * memory.
+ */
+static void frontswap_selfshrink(void)
+{
+	static unsigned long cur_frontswap_pages;
+	static unsigned long last_frontswap_pages;
+	static unsigned long tgt_frontswap_pages;
+
+	last_frontswap_pages = cur_frontswap_pages;
+	cur_frontswap_pages = frontswap_curr_pages();
+	if (!cur_frontswap_pages ||
+			(cur_frontswap_pages > last_frontswap_pages)) {
+		frontswap_inertia_counter = frontswap_inertia;
+		return;
+	}
+	if (frontswap_inertia_counter && --frontswap_inertia_counter)
+		return;
+	if (cur_frontswap_pages <= frontswap_hysteresis)
+		tgt_frontswap_pages = 0;
+	else
+		tgt_frontswap_pages = cur_frontswap_pages -
+			(cur_frontswap_pages / frontswap_hysteresis);
+	frontswap_shrink(tgt_frontswap_pages);
+}
+
+static int __init ramster_nofrontswap_selfshrink_setup(char *s)
+{
+	use_frontswap_selfshrink = false;
+	return 1;
+}
+
+__setup("noselfshrink", ramster_nofrontswap_selfshrink_setup);
+
+static void selfshrink_process(struct work_struct *work)
+{
+	if (frontswap_selfshrinking && frontswap_enabled) {
+		frontswap_selfshrink();
+		schedule_delayed_work(&selfshrink_worker,
+			selfshrink_interval * HZ);
+	}
+}
+
+void ramster_cpu_up(int cpu)
+{
+	unsigned char *p1 = kzalloc(PAGE_SIZE, GFP_KERNEL | __GFP_REPEAT);
+	unsigned char *p2 = kzalloc(PAGE_SIZE, GFP_KERNEL | __GFP_REPEAT);
+	BUG_ON(!p1 || !p2);
+	per_cpu(ramster_remoteputmem1, cpu) = p1;
+	per_cpu(ramster_remoteputmem2, cpu) = p2;
+}
+
+void ramster_cpu_down(int cpu)
+{
+	struct ramster_preload *kp;
+
+	kfree(per_cpu(ramster_remoteputmem1, cpu));
+	per_cpu(ramster_remoteputmem1, cpu) = NULL;
+	kfree(per_cpu(ramster_remoteputmem2, cpu));
+	per_cpu(ramster_remoteputmem2, cpu) = NULL;
+	kp = &per_cpu(ramster_preloads, cpu);
+	if (kp->flnode) {
+		kmem_cache_free(ramster_flnode_cache, kp->flnode);
+		kp->flnode = NULL;
+	}
+}
+
+void ramster_register_pamops(struct tmem_pamops *pamops)
+{
+	pamops->free_obj = ramster_pampd_free_obj;
+	pamops->new_obj = ramster_pampd_new_obj;
+	pamops->replace_in_obj = ramster_pampd_replace_in_obj;
+	pamops->is_remote = ramster_pampd_is_remote;
+	pamops->repatriate = ramster_pampd_repatriate;
+	pamops->repatriate_preload = ramster_pampd_repatriate_preload;
+}
+
+void __init ramster_init(bool cleancache, bool frontswap,
+				bool frontswap_exclusive_gets)
+{
+	int ret = 0;
+
+	if (cleancache)
+		use_cleancache = true;
+	if (frontswap)
+		use_frontswap = true;
+	if (frontswap_exclusive_gets)
+		use_frontswap_exclusive_gets = true;
+	ramster_debugfs_init();
+	ret = sysfs_create_group(mm_kobj, &ramster_attr_group);
+	if (ret)
+		pr_err("ramster: can't create sysfs for ramster\n");
+	(void)r2net_register_handlers();
+	INIT_LIST_HEAD(&ramster_rem_op_list);
+	ramster_flnode_cache = kmem_cache_create("ramster_flnode",
+				sizeof(struct flushlist_node), 0, 0, NULL);
+	frontswap_selfshrinking = use_frontswap_selfshrink;
+	if (frontswap_selfshrinking) {
+		pr_info("ramster: Initializing frontswap selfshrink driver.\n");
+		schedule_delayed_work(&selfshrink_worker,
+					selfshrink_interval * HZ);
+	}
+	ramster_remotify_init();
+}
diff --git a/drivers/staging/zcache/ramster/ramster.h b/drivers/staging/zcache/ramster/ramster.h
new file mode 100644
index 0000000..12ae56f
--- /dev/null
+++ b/drivers/staging/zcache/ramster/ramster.h
@@ -0,0 +1,161 @@
+/*
+ * ramster.h
+ *
+ * Peer-to-peer transcendent memory
+ *
+ * Copyright (c) 2009-2012, Dan Magenheimer, Oracle Corp.
+ */
+
+#ifndef _RAMSTER_RAMSTER_H_
+#define _RAMSTER_RAMSTER_H_
+
+#include "../tmem.h"
+
+enum ramster_remotify_op {
+	RAMSTER_REMOTIFY_FLUSH_PAGE,
+	RAMSTER_REMOTIFY_FLUSH_OBJ,
+};
+
+struct ramster_remotify_hdr {
+	enum ramster_remotify_op op;
+	struct list_head list;
+};
+
+struct flushlist_node {
+	struct ramster_remotify_hdr rem_op;
+	struct tmem_xhandle xh;
+};
+
+struct ramster_preload {
+	struct flushlist_node *flnode;
+};
+
+union remotify_list_node {
+	struct ramster_remotify_hdr rem_op;
+	struct {
+		struct ramster_remotify_hdr rem_op;
+		struct tmem_handle th;
+	} zbud_hdr;
+	struct flushlist_node flist;
+};
+
+/*
+ * format of remote pampd:
+ *   bit 0 is reserved for zbud (in-page buddy selection)
+ *   bit 1 == intransit
+ *   bit 2 == is_remote... if this bit is set, then
+ *   bit 3-10 == remotenode
+ *   bit 11-23 == size
+ *   bit 24-31 == cksum
+ */
+#define FAKE_PAMPD_INTRANSIT_BITS	1
+#define FAKE_PAMPD_ISREMOTE_BITS	1
+#define FAKE_PAMPD_REMOTENODE_BITS	8
+#define FAKE_PAMPD_REMOTESIZE_BITS	13
+#define FAKE_PAMPD_CHECKSUM_BITS	8
+
+#define FAKE_PAMPD_INTRANSIT_SHIFT	1
+#define FAKE_PAMPD_ISREMOTE_SHIFT	(FAKE_PAMPD_INTRANSIT_SHIFT + \
+					 FAKE_PAMPD_INTRANSIT_BITS)
+#define FAKE_PAMPD_REMOTENODE_SHIFT	(FAKE_PAMPD_ISREMOTE_SHIFT + \
+					 FAKE_PAMPD_ISREMOTE_BITS)
+#define FAKE_PAMPD_REMOTESIZE_SHIFT	(FAKE_PAMPD_REMOTENODE_SHIFT + \
+					 FAKE_PAMPD_REMOTENODE_BITS)
+#define FAKE_PAMPD_CHECKSUM_SHIFT	(FAKE_PAMPD_REMOTESIZE_SHIFT + \
+					 FAKE_PAMPD_REMOTESIZE_BITS)
+
+#define FAKE_PAMPD_MASK(x)		((1UL << (x)) - 1)
+
+static inline void *pampd_make_remote(int remotenode, size_t size,
+					unsigned char cksum)
+{
+	unsigned long fake_pampd = 0;
+	fake_pampd |= 1UL << FAKE_PAMPD_ISREMOTE_SHIFT;
+	fake_pampd |= ((unsigned long)remotenode &
+			FAKE_PAMPD_MASK(FAKE_PAMPD_REMOTENODE_BITS)) <<
+				FAKE_PAMPD_REMOTENODE_SHIFT;
+	fake_pampd |= ((unsigned long)size &
+			FAKE_PAMPD_MASK(FAKE_PAMPD_REMOTESIZE_BITS)) <<
+				FAKE_PAMPD_REMOTESIZE_SHIFT;
+	fake_pampd |= ((unsigned long)cksum &
+			FAKE_PAMPD_MASK(FAKE_PAMPD_CHECKSUM_BITS)) <<
+				FAKE_PAMPD_CHECKSUM_SHIFT;
+	return (void *)fake_pampd;
+}
+
+static inline unsigned int pampd_remote_node(void *pampd)
+{
+	unsigned long fake_pampd = (unsigned long)pampd;
+	return (fake_pampd >> FAKE_PAMPD_REMOTENODE_SHIFT) &
+		FAKE_PAMPD_MASK(FAKE_PAMPD_REMOTENODE_BITS);
+}
+
+static inline unsigned int pampd_remote_size(void *pampd)
+{
+	unsigned long fake_pampd = (unsigned long)pampd;
+	return (fake_pampd >> FAKE_PAMPD_REMOTESIZE_SHIFT) &
+		FAKE_PAMPD_MASK(FAKE_PAMPD_REMOTESIZE_BITS);
+}
+
+static inline unsigned char pampd_remote_cksum(void *pampd)
+{
+	unsigned long fake_pampd = (unsigned long)pampd;
+	return (fake_pampd >> FAKE_PAMPD_CHECKSUM_SHIFT) &
+		FAKE_PAMPD_MASK(FAKE_PAMPD_CHECKSUM_BITS);
+}
+
+static inline bool pampd_is_remote(void *pampd)
+{
+	unsigned long fake_pampd = (unsigned long)pampd;
+	return (fake_pampd >> FAKE_PAMPD_ISREMOTE_SHIFT) &
+		FAKE_PAMPD_MASK(FAKE_PAMPD_ISREMOTE_BITS);
+}
+
+static inline bool pampd_is_intransit(void *pampd)
+{
+	unsigned long fake_pampd = (unsigned long)pampd;
+	return (fake_pampd >> FAKE_PAMPD_INTRANSIT_SHIFT) &
+		FAKE_PAMPD_MASK(FAKE_PAMPD_INTRANSIT_BITS);
+}
+
+/* note that it is a BUG for intransit to be set without isremote also set */
+static inline void *pampd_mark_intransit(void *pampd)
+{
+	unsigned long fake_pampd = (unsigned long)pampd;
+
+	fake_pampd |= 1UL << FAKE_PAMPD_ISREMOTE_SHIFT;
+	fake_pampd |= 1UL << FAKE_PAMPD_INTRANSIT_SHIFT;
+	return (void *)fake_pampd;
+}
+
+static inline void *pampd_mask_intransit_and_remote(void *marked_pampd)
+{
+	unsigned long pampd = (unsigned long)marked_pampd;
+
+	pampd &= ~(1UL << FAKE_PAMPD_INTRANSIT_SHIFT);
+	pampd &= ~(1UL << FAKE_PAMPD_ISREMOTE_SHIFT);
+	return (void *)pampd;
+}
+
+extern int r2net_remote_async_get(struct tmem_xhandle *,
+				bool, int, size_t, uint8_t, void *extra);
+extern int r2net_remote_put(struct tmem_xhandle *, char *, size_t,
+				bool, int *);
+extern int r2net_remote_flush(struct tmem_xhandle *, int);
+extern int r2net_remote_flush_object(struct tmem_xhandle *, int);
+extern int r2net_register_handlers(void);
+extern int r2net_remote_target_node_set(int);
+
+extern int ramster_remotify_pageframe(bool);
+extern void ramster_init(bool, bool, bool);
+extern void ramster_register_pamops(struct tmem_pamops *);
+extern int ramster_localify(int, struct tmem_oid *oidp, uint32_t, char *,
+				unsigned int, void *);
+extern void *ramster_pampd_free(void *, struct tmem_pool *, struct tmem_oid *,
+				uint32_t, bool);
+extern void ramster_count_foreign_pages(bool, int);
+extern int ramster_do_preload_flnode(struct tmem_pool *);
+extern void ramster_cpu_up(int);
+extern void ramster_cpu_down(int);
+
+#endif /* _RAMSTER_RAMSTER_H */
diff --git a/drivers/staging/zcache/ramster/ramster_nodemanager.h b/drivers/staging/zcache/ramster/ramster_nodemanager.h
new file mode 100644
index 0000000..49f879d
--- /dev/null
+++ b/drivers/staging/zcache/ramster/ramster_nodemanager.h
@@ -0,0 +1,39 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * ramster_nodemanager.h
+ *
+ * Header describing the interface between userspace and the kernel
+ * for the ramster_nodemanager module.
+ *
+ * Copyright (C) 2002, 2004, 2012 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ */
+
+#ifndef _RAMSTER_NODEMANAGER_H
+#define _RAMSTER_NODEMANAGER_H
+
+#define R2NM_API_VERSION	5
+
+#define R2NM_MAX_NODES		255
+#define R2NM_INVALID_NODE_NUM	255
+
+/* host name, group name, cluster name all 64 bytes */
+#define R2NM_MAX_NAME_LEN        64    /* __NEW_UTS_LEN */
+
+#endif /* _RAMSTER_NODEMANAGER_H */
diff --git a/drivers/staging/zcache/ramster/tcp.c b/drivers/staging/zcache/ramster/tcp.c
new file mode 100644
index 0000000..aa2a1a7
--- /dev/null
+++ b/drivers/staging/zcache/ramster/tcp.c
@@ -0,0 +1,2253 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ *
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * Copyright (C) 2004 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ * ----
+ *
+ * Callers for this were originally written against a very simple synchronus
+ * API.  This implementation reflects those simple callers.  Some day I'm sure
+ * we'll need to move to a more robust posting/callback mechanism.
+ *
+ * Transmit calls pass in kernel virtual addresses and block copying this into
+ * the socket's tx buffers via a usual blocking sendmsg.  They'll block waiting
+ * for a failed socket to timeout.  TX callers can also pass in a poniter to an
+ * 'int' which gets filled with an errno off the wire in response to the
+ * message they send.
+ *
+ * Handlers for unsolicited messages are registered.  Each socket has a page
+ * that incoming data is copied into.  First the header, then the data.
+ * Handlers are called from only one thread with a reference to this per-socket
+ * page.  This page is destroyed after the handler call, so it can't be
+ * referenced beyond the call.  Handlers may block but are discouraged from
+ * doing so.
+ *
+ * Any framing errors (bad magic, large payload lengths) close a connection.
+ *
+ * Our sock_container holds the state we associate with a socket.  It's current
+ * framing state is held there as well as the refcounting we do around when it
+ * is safe to tear down the socket.  The socket is only finally torn down from
+ * the container when the container loses all of its references -- so as long
+ * as you hold a ref on the container you can trust that the socket is valid
+ * for use with kernel socket APIs.
+ *
+ * Connections are initiated between a pair of nodes when the node with the
+ * higher node number gets a heartbeat callback which indicates that the lower
+ * numbered node has started heartbeating.  The lower numbered node is passive
+ * and only accepts the connection if the higher numbered node is heartbeating.
+ */
+
+#include <linux/kernel.h>
+#include <linux/jiffies.h>
+#include <linux/slab.h>
+#include <linux/idr.h>
+#include <linux/kref.h>
+#include <linux/net.h>
+#include <linux/export.h>
+#include <linux/uaccess.h>
+#include <net/tcp.h>
+
+
+#include "heartbeat.h"
+#include "tcp.h"
+#include "nodemanager.h"
+#define MLOG_MASK_PREFIX ML_TCP
+#include "masklog.h"
+
+#include "tcp_internal.h"
+
+#define SC_NODEF_FMT "node %s (num %u) at %pI4:%u"
+
+/*
+ * In the following two log macros, the whitespace after the ',' just
+ * before ##args is intentional. Otherwise, gcc 2.95 will eat the
+ * previous token if args expands to nothing.
+ */
+#define msglog(hdr, fmt, args...) do {					\
+	typeof(hdr) __hdr = (hdr);					\
+	mlog(ML_MSG, "[mag %u len %u typ %u stat %d sys_stat %d "	\
+	     "key %08x num %u] " fmt,					\
+	be16_to_cpu(__hdr->magic), be16_to_cpu(__hdr->data_len),	\
+	     be16_to_cpu(__hdr->msg_type), be32_to_cpu(__hdr->status),	\
+	     be32_to_cpu(__hdr->sys_status), be32_to_cpu(__hdr->key),	\
+	     be32_to_cpu(__hdr->msg_num) ,  ##args);			\
+} while (0)
+
+#define sclog(sc, fmt, args...) do {					\
+	typeof(sc) __sc = (sc);						\
+	mlog(ML_SOCKET, "[sc %p refs %d sock %p node %u page %p "	\
+	     "pg_off %zu] " fmt, __sc,					\
+	     atomic_read(&__sc->sc_kref.refcount), __sc->sc_sock,	\
+	    __sc->sc_node->nd_num, __sc->sc_page, __sc->sc_page_off ,	\
+	    ##args);							\
+} while (0)
+
+static DEFINE_RWLOCK(r2net_handler_lock);
+static struct rb_root r2net_handler_tree = RB_ROOT;
+
+static struct r2net_node r2net_nodes[R2NM_MAX_NODES];
+
+/* XXX someday we'll need better accounting */
+static struct socket *r2net_listen_sock;
+
+/*
+ * listen work is only queued by the listening socket callbacks on the
+ * r2net_wq.  teardown detaches the callbacks before destroying the workqueue.
+ * quorum work is queued as sock containers are shutdown.. stop_listening
+ * tears down all the node's sock containers, preventing future shutdowns
+ * and queued quorum work, before canceling delayed quorum work and
+ * destroying the work queue.
+ */
+static struct workqueue_struct *r2net_wq;
+static struct work_struct r2net_listen_work;
+
+static struct r2hb_callback_func r2net_hb_up, r2net_hb_down;
+#define R2NET_HB_PRI 0x1
+
+static struct r2net_handshake *r2net_hand;
+static struct r2net_msg *r2net_keep_req, *r2net_keep_resp;
+
+static int r2net_sys_err_translations[R2NET_ERR_MAX] = {
+		[R2NET_ERR_NONE]	= 0,
+		[R2NET_ERR_NO_HNDLR]	= -ENOPROTOOPT,
+		[R2NET_ERR_OVERFLOW]	= -EOVERFLOW,
+		[R2NET_ERR_DIED]	= -EHOSTDOWN,};
+
+/* can't quite avoid *all* internal declarations :/ */
+static void r2net_sc_connect_completed(struct work_struct *work);
+static void r2net_rx_until_empty(struct work_struct *work);
+static void r2net_shutdown_sc(struct work_struct *work);
+static void r2net_listen_data_ready(struct sock *sk, int bytes);
+static void r2net_sc_send_keep_req(struct work_struct *work);
+static void r2net_idle_timer(unsigned long data);
+static void r2net_sc_postpone_idle(struct r2net_sock_container *sc);
+static void r2net_sc_reset_idle_timer(struct r2net_sock_container *sc);
+
+#ifdef CONFIG_DEBUG_FS
+static void r2net_init_nst(struct r2net_send_tracking *nst, u32 msgtype,
+			   u32 msgkey, struct task_struct *task, u8 node)
+{
+	INIT_LIST_HEAD(&nst->st_net_debug_item);
+	nst->st_task = task;
+	nst->st_msg_type = msgtype;
+	nst->st_msg_key = msgkey;
+	nst->st_node = node;
+}
+
+static inline void r2net_set_nst_sock_time(struct r2net_send_tracking *nst)
+{
+	nst->st_sock_time = ktime_get();
+}
+
+static inline void r2net_set_nst_send_time(struct r2net_send_tracking *nst)
+{
+	nst->st_send_time = ktime_get();
+}
+
+static inline void r2net_set_nst_status_time(struct r2net_send_tracking *nst)
+{
+	nst->st_status_time = ktime_get();
+}
+
+static inline void r2net_set_nst_sock_container(struct r2net_send_tracking *nst,
+						struct r2net_sock_container *sc)
+{
+	nst->st_sc = sc;
+}
+
+static inline void r2net_set_nst_msg_id(struct r2net_send_tracking *nst,
+					u32 msg_id)
+{
+	nst->st_id = msg_id;
+}
+
+static inline void r2net_set_sock_timer(struct r2net_sock_container *sc)
+{
+	sc->sc_tv_timer = ktime_get();
+}
+
+static inline void r2net_set_data_ready_time(struct r2net_sock_container *sc)
+{
+	sc->sc_tv_data_ready = ktime_get();
+}
+
+static inline void r2net_set_advance_start_time(struct r2net_sock_container *sc)
+{
+	sc->sc_tv_advance_start = ktime_get();
+}
+
+static inline void r2net_set_advance_stop_time(struct r2net_sock_container *sc)
+{
+	sc->sc_tv_advance_stop = ktime_get();
+}
+
+static inline void r2net_set_func_start_time(struct r2net_sock_container *sc)
+{
+	sc->sc_tv_func_start = ktime_get();
+}
+
+static inline void r2net_set_func_stop_time(struct r2net_sock_container *sc)
+{
+	sc->sc_tv_func_stop = ktime_get();
+}
+
+#else  /* CONFIG_DEBUG_FS */
+# define r2net_init_nst(a, b, c, d, e)
+# define r2net_set_nst_sock_time(a)
+# define r2net_set_nst_send_time(a)
+# define r2net_set_nst_status_time(a)
+# define r2net_set_nst_sock_container(a, b)
+# define r2net_set_nst_msg_id(a, b)
+# define r2net_set_sock_timer(a)
+# define r2net_set_data_ready_time(a)
+# define r2net_set_advance_start_time(a)
+# define r2net_set_advance_stop_time(a)
+# define r2net_set_func_start_time(a)
+# define r2net_set_func_stop_time(a)
+#endif /* CONFIG_DEBUG_FS */
+
+#ifdef CONFIG_RAMSTER_FS_STATS
+static ktime_t r2net_get_func_run_time(struct r2net_sock_container *sc)
+{
+	return ktime_sub(sc->sc_tv_func_stop, sc->sc_tv_func_start);
+}
+
+static void r2net_update_send_stats(struct r2net_send_tracking *nst,
+				    struct r2net_sock_container *sc)
+{
+	sc->sc_tv_status_total = ktime_add(sc->sc_tv_status_total,
+					   ktime_sub(ktime_get(),
+						     nst->st_status_time));
+	sc->sc_tv_send_total = ktime_add(sc->sc_tv_send_total,
+					 ktime_sub(nst->st_status_time,
+						   nst->st_send_time));
+	sc->sc_tv_acquiry_total = ktime_add(sc->sc_tv_acquiry_total,
+					    ktime_sub(nst->st_send_time,
+						      nst->st_sock_time));
+	sc->sc_send_count++;
+}
+
+static void r2net_update_recv_stats(struct r2net_sock_container *sc)
+{
+	sc->sc_tv_process_total = ktime_add(sc->sc_tv_process_total,
+					    r2net_get_func_run_time(sc));
+	sc->sc_recv_count++;
+}
+
+#else
+
+# define r2net_update_send_stats(a, b)
+
+# define r2net_update_recv_stats(sc)
+
+#endif /* CONFIG_RAMSTER_FS_STATS */
+
+static inline int r2net_reconnect_delay(void)
+{
+	return r2nm_single_cluster->cl_reconnect_delay_ms;
+}
+
+static inline int r2net_keepalive_delay(void)
+{
+	return r2nm_single_cluster->cl_keepalive_delay_ms;
+}
+
+static inline int r2net_idle_timeout(void)
+{
+	return r2nm_single_cluster->cl_idle_timeout_ms;
+}
+
+static inline int r2net_sys_err_to_errno(enum r2net_system_error err)
+{
+	int trans;
+	BUG_ON(err >= R2NET_ERR_MAX);
+	trans = r2net_sys_err_translations[err];
+
+	/* Just in case we mess up the translation table above */
+	BUG_ON(err != R2NET_ERR_NONE && trans == 0);
+	return trans;
+}
+
+struct r2net_node *r2net_nn_from_num(u8 node_num)
+{
+	BUG_ON(node_num >= ARRAY_SIZE(r2net_nodes));
+	return &r2net_nodes[node_num];
+}
+
+static u8 r2net_num_from_nn(struct r2net_node *nn)
+{
+	BUG_ON(nn == NULL);
+	return nn - r2net_nodes;
+}
+
+/* ------------------------------------------------------------ */
+
+static int r2net_prep_nsw(struct r2net_node *nn, struct r2net_status_wait *nsw)
+{
+	int ret = 0;
+
+	do {
+		if (!idr_pre_get(&nn->nn_status_idr, GFP_ATOMIC)) {
+			ret = -EAGAIN;
+			break;
+		}
+		spin_lock(&nn->nn_lock);
+		ret = idr_get_new(&nn->nn_status_idr, nsw, &nsw->ns_id);
+		if (ret == 0)
+			list_add_tail(&nsw->ns_node_item,
+				      &nn->nn_status_list);
+		spin_unlock(&nn->nn_lock);
+	} while (ret == -EAGAIN);
+
+	if (ret == 0)  {
+		init_waitqueue_head(&nsw->ns_wq);
+		nsw->ns_sys_status = R2NET_ERR_NONE;
+		nsw->ns_status = 0;
+	}
+
+	return ret;
+}
+
+static void r2net_complete_nsw_locked(struct r2net_node *nn,
+				      struct r2net_status_wait *nsw,
+				      enum r2net_system_error sys_status,
+				      s32 status)
+{
+	assert_spin_locked(&nn->nn_lock);
+
+	if (!list_empty(&nsw->ns_node_item)) {
+		list_del_init(&nsw->ns_node_item);
+		nsw->ns_sys_status = sys_status;
+		nsw->ns_status = status;
+		idr_remove(&nn->nn_status_idr, nsw->ns_id);
+		wake_up(&nsw->ns_wq);
+	}
+}
+
+static void r2net_complete_nsw(struct r2net_node *nn,
+			       struct r2net_status_wait *nsw,
+			       u64 id, enum r2net_system_error sys_status,
+			       s32 status)
+{
+	spin_lock(&nn->nn_lock);
+	if (nsw == NULL) {
+		if (id > INT_MAX)
+			goto out;
+
+		nsw = idr_find(&nn->nn_status_idr, id);
+		if (nsw == NULL)
+			goto out;
+	}
+
+	r2net_complete_nsw_locked(nn, nsw, sys_status, status);
+
+out:
+	spin_unlock(&nn->nn_lock);
+	return;
+}
+
+static void r2net_complete_nodes_nsw(struct r2net_node *nn)
+{
+	struct r2net_status_wait *nsw, *tmp;
+	unsigned int num_kills = 0;
+
+	assert_spin_locked(&nn->nn_lock);
+
+	list_for_each_entry_safe(nsw, tmp, &nn->nn_status_list, ns_node_item) {
+		r2net_complete_nsw_locked(nn, nsw, R2NET_ERR_DIED, 0);
+		num_kills++;
+	}
+
+	mlog(0, "completed %d messages for node %u\n", num_kills,
+	     r2net_num_from_nn(nn));
+}
+
+static int r2net_nsw_completed(struct r2net_node *nn,
+			       struct r2net_status_wait *nsw)
+{
+	int completed;
+	spin_lock(&nn->nn_lock);
+	completed = list_empty(&nsw->ns_node_item);
+	spin_unlock(&nn->nn_lock);
+	return completed;
+}
+
+/* ------------------------------------------------------------ */
+
+static void sc_kref_release(struct kref *kref)
+{
+	struct r2net_sock_container *sc = container_of(kref,
+					struct r2net_sock_container, sc_kref);
+	BUG_ON(timer_pending(&sc->sc_idle_timeout));
+
+	sclog(sc, "releasing\n");
+
+	if (sc->sc_sock) {
+		sock_release(sc->sc_sock);
+		sc->sc_sock = NULL;
+	}
+
+	r2nm_undepend_item(&sc->sc_node->nd_item);
+	r2nm_node_put(sc->sc_node);
+	sc->sc_node = NULL;
+
+	r2net_debug_del_sc(sc);
+	kfree(sc);
+}
+
+static void sc_put(struct r2net_sock_container *sc)
+{
+	sclog(sc, "put\n");
+	kref_put(&sc->sc_kref, sc_kref_release);
+}
+static void sc_get(struct r2net_sock_container *sc)
+{
+	sclog(sc, "get\n");
+	kref_get(&sc->sc_kref);
+}
+static struct r2net_sock_container *sc_alloc(struct r2nm_node *node)
+{
+	struct r2net_sock_container *sc, *ret = NULL;
+	struct page *page = NULL;
+	int status = 0;
+
+	page = alloc_page(GFP_NOFS);
+	sc = kzalloc(sizeof(*sc), GFP_NOFS);
+	if (sc == NULL || page == NULL)
+		goto out;
+
+	kref_init(&sc->sc_kref);
+	r2nm_node_get(node);
+	sc->sc_node = node;
+
+	/* pin the node item of the remote node */
+	status = r2nm_depend_item(&node->nd_item);
+	if (status) {
+		mlog_errno(status);
+		r2nm_node_put(node);
+		goto out;
+	}
+	INIT_WORK(&sc->sc_connect_work, r2net_sc_connect_completed);
+	INIT_WORK(&sc->sc_rx_work, r2net_rx_until_empty);
+	INIT_WORK(&sc->sc_shutdown_work, r2net_shutdown_sc);
+	INIT_DELAYED_WORK(&sc->sc_keepalive_work, r2net_sc_send_keep_req);
+
+	init_timer(&sc->sc_idle_timeout);
+	sc->sc_idle_timeout.function = r2net_idle_timer;
+	sc->sc_idle_timeout.data = (unsigned long)sc;
+
+	sclog(sc, "alloced\n");
+
+	ret = sc;
+	sc->sc_page = page;
+	r2net_debug_add_sc(sc);
+	sc = NULL;
+	page = NULL;
+
+out:
+	if (page)
+		__free_page(page);
+	kfree(sc);
+
+	return ret;
+}
+
+/* ------------------------------------------------------------ */
+
+static void r2net_sc_queue_work(struct r2net_sock_container *sc,
+				struct work_struct *work)
+{
+	sc_get(sc);
+	if (!queue_work(r2net_wq, work))
+		sc_put(sc);
+}
+static void r2net_sc_queue_delayed_work(struct r2net_sock_container *sc,
+					struct delayed_work *work,
+					int delay)
+{
+	sc_get(sc);
+	if (!queue_delayed_work(r2net_wq, work, delay))
+		sc_put(sc);
+}
+static void r2net_sc_cancel_delayed_work(struct r2net_sock_container *sc,
+					 struct delayed_work *work)
+{
+	if (cancel_delayed_work(work))
+		sc_put(sc);
+}
+
+static atomic_t r2net_connected_peers = ATOMIC_INIT(0);
+
+int r2net_num_connected_peers(void)
+{
+	return atomic_read(&r2net_connected_peers);
+}
+
+static void r2net_set_nn_state(struct r2net_node *nn,
+			       struct r2net_sock_container *sc,
+			       unsigned valid, int err)
+{
+	int was_valid = nn->nn_sc_valid;
+	int was_err = nn->nn_persistent_error;
+	struct r2net_sock_container *old_sc = nn->nn_sc;
+
+	assert_spin_locked(&nn->nn_lock);
+
+	if (old_sc && !sc)
+		atomic_dec(&r2net_connected_peers);
+	else if (!old_sc && sc)
+		atomic_inc(&r2net_connected_peers);
+
+	/* the node num comparison and single connect/accept path should stop
+	 * an non-null sc from being overwritten with another */
+	BUG_ON(sc && nn->nn_sc && nn->nn_sc != sc);
+	mlog_bug_on_msg(err && valid, "err %d valid %u\n", err, valid);
+	mlog_bug_on_msg(valid && !sc, "valid %u sc %p\n", valid, sc);
+
+	if (was_valid && !valid && err == 0)
+		err = -ENOTCONN;
+
+	mlog(ML_CONN, "node %u sc: %p -> %p, valid %u -> %u, err %d -> %d\n",
+	     r2net_num_from_nn(nn), nn->nn_sc, sc, nn->nn_sc_valid, valid,
+	     nn->nn_persistent_error, err);
+
+	nn->nn_sc = sc;
+	nn->nn_sc_valid = valid ? 1 : 0;
+	nn->nn_persistent_error = err;
+
+	/* mirrors r2net_tx_can_proceed() */
+	if (nn->nn_persistent_error || nn->nn_sc_valid)
+		wake_up(&nn->nn_sc_wq);
+
+	if (!was_err && nn->nn_persistent_error) {
+		queue_delayed_work(r2net_wq, &nn->nn_still_up,
+				   msecs_to_jiffies(R2NET_QUORUM_DELAY_MS));
+	}
+
+	if (was_valid && !valid) {
+		pr_notice("ramster: No longer connected to " SC_NODEF_FMT "\n",
+			old_sc->sc_node->nd_name, old_sc->sc_node->nd_num,
+			&old_sc->sc_node->nd_ipv4_address,
+			ntohs(old_sc->sc_node->nd_ipv4_port));
+		r2net_complete_nodes_nsw(nn);
+	}
+
+	if (!was_valid && valid) {
+		cancel_delayed_work(&nn->nn_connect_expired);
+		pr_notice("ramster: %s " SC_NODEF_FMT "\n",
+		       r2nm_this_node() > sc->sc_node->nd_num ?
+		       "Connected to" : "Accepted connection from",
+		       sc->sc_node->nd_name, sc->sc_node->nd_num,
+			&sc->sc_node->nd_ipv4_address,
+			ntohs(sc->sc_node->nd_ipv4_port));
+	}
+
+	/* trigger the connecting worker func as long as we're not valid,
+	 * it will back off if it shouldn't connect.  This can be called
+	 * from node config teardown and so needs to be careful about
+	 * the work queue actually being up. */
+	if (!valid && r2net_wq) {
+		unsigned long delay;
+		/* delay if we're within a RECONNECT_DELAY of the
+		 * last attempt */
+		delay = (nn->nn_last_connect_attempt +
+			 msecs_to_jiffies(r2net_reconnect_delay()))
+			- jiffies;
+		if (delay > msecs_to_jiffies(r2net_reconnect_delay()))
+			delay = 0;
+		mlog(ML_CONN, "queueing conn attempt in %lu jiffies\n", delay);
+		queue_delayed_work(r2net_wq, &nn->nn_connect_work, delay);
+
+		/*
+		 * Delay the expired work after idle timeout.
+		 *
+		 * We might have lots of failed connection attempts that run
+		 * through here but we only cancel the connect_expired work when
+		 * a connection attempt succeeds.  So only the first enqueue of
+		 * the connect_expired work will do anything.  The rest will see
+		 * that it's already queued and do nothing.
+		 */
+		delay += msecs_to_jiffies(r2net_idle_timeout());
+		queue_delayed_work(r2net_wq, &nn->nn_connect_expired, delay);
+	}
+
+	/* keep track of the nn's sc ref for the caller */
+	if ((old_sc == NULL) && sc)
+		sc_get(sc);
+	if (old_sc && (old_sc != sc)) {
+		r2net_sc_queue_work(old_sc, &old_sc->sc_shutdown_work);
+		sc_put(old_sc);
+	}
+}
+
+/* see r2net_register_callbacks() */
+static void r2net_data_ready(struct sock *sk, int bytes)
+{
+	void (*ready)(struct sock *sk, int bytes);
+
+	read_lock(&sk->sk_callback_lock);
+	if (sk->sk_user_data) {
+		struct r2net_sock_container *sc = sk->sk_user_data;
+		sclog(sc, "data_ready hit\n");
+		r2net_set_data_ready_time(sc);
+		r2net_sc_queue_work(sc, &sc->sc_rx_work);
+		ready = sc->sc_data_ready;
+	} else {
+		ready = sk->sk_data_ready;
+	}
+	read_unlock(&sk->sk_callback_lock);
+
+	ready(sk, bytes);
+}
+
+/* see r2net_register_callbacks() */
+static void r2net_state_change(struct sock *sk)
+{
+	void (*state_change)(struct sock *sk);
+	struct r2net_sock_container *sc;
+
+	read_lock(&sk->sk_callback_lock);
+	sc = sk->sk_user_data;
+	if (sc == NULL) {
+		state_change = sk->sk_state_change;
+		goto out;
+	}
+
+	sclog(sc, "state_change to %d\n", sk->sk_state);
+
+	state_change = sc->sc_state_change;
+
+	switch (sk->sk_state) {
+
+	/* ignore connecting sockets as they make progress */
+	case TCP_SYN_SENT:
+	case TCP_SYN_RECV:
+		break;
+	case TCP_ESTABLISHED:
+		r2net_sc_queue_work(sc, &sc->sc_connect_work);
+		break;
+	default:
+		pr_info("ramster: Connection to "
+			SC_NODEF_FMT " shutdown, state %d\n",
+			sc->sc_node->nd_name, sc->sc_node->nd_num,
+			&sc->sc_node->nd_ipv4_address,
+			ntohs(sc->sc_node->nd_ipv4_port), sk->sk_state);
+		r2net_sc_queue_work(sc, &sc->sc_shutdown_work);
+		break;
+
+	}
+out:
+	read_unlock(&sk->sk_callback_lock);
+	state_change(sk);
+}
+
+/*
+ * we register callbacks so we can queue work on events before calling
+ * the original callbacks.  our callbacks are careful to test user_data
+ * to discover when they've reaced with r2net_unregister_callbacks().
+ */
+static void r2net_register_callbacks(struct sock *sk,
+				     struct r2net_sock_container *sc)
+{
+	write_lock_bh(&sk->sk_callback_lock);
+
+	/* accepted sockets inherit the old listen socket data ready */
+	if (sk->sk_data_ready == r2net_listen_data_ready) {
+		sk->sk_data_ready = sk->sk_user_data;
+		sk->sk_user_data = NULL;
+	}
+
+	BUG_ON(sk->sk_user_data != NULL);
+	sk->sk_user_data = sc;
+	sc_get(sc);
+
+	sc->sc_data_ready = sk->sk_data_ready;
+	sc->sc_state_change = sk->sk_state_change;
+	sk->sk_data_ready = r2net_data_ready;
+	sk->sk_state_change = r2net_state_change;
+
+	mutex_init(&sc->sc_send_lock);
+
+	write_unlock_bh(&sk->sk_callback_lock);
+}
+
+static int r2net_unregister_callbacks(struct sock *sk,
+					struct r2net_sock_container *sc)
+{
+	int ret = 0;
+
+	write_lock_bh(&sk->sk_callback_lock);
+	if (sk->sk_user_data == sc) {
+		ret = 1;
+		sk->sk_user_data = NULL;
+		sk->sk_data_ready = sc->sc_data_ready;
+		sk->sk_state_change = sc->sc_state_change;
+	}
+	write_unlock_bh(&sk->sk_callback_lock);
+
+	return ret;
+}
+
+/*
+ * this is a little helper that is called by callers who have seen a problem
+ * with an sc and want to detach it from the nn if someone already hasn't beat
+ * them to it.  if an error is given then the shutdown will be persistent
+ * and pending transmits will be canceled.
+ */
+static void r2net_ensure_shutdown(struct r2net_node *nn,
+					struct r2net_sock_container *sc,
+				   int err)
+{
+	spin_lock(&nn->nn_lock);
+	if (nn->nn_sc == sc)
+		r2net_set_nn_state(nn, NULL, 0, err);
+	spin_unlock(&nn->nn_lock);
+}
+
+/*
+ * This work queue function performs the blocking parts of socket shutdown.  A
+ * few paths lead here.  set_nn_state will trigger this callback if it sees an
+ * sc detached from the nn.  state_change will also trigger this callback
+ * directly when it sees errors.  In that case we need to call set_nn_state
+ * ourselves as state_change couldn't get the nn_lock and call set_nn_state
+ * itself.
+ */
+static void r2net_shutdown_sc(struct work_struct *work)
+{
+	struct r2net_sock_container *sc =
+		container_of(work, struct r2net_sock_container,
+			     sc_shutdown_work);
+	struct r2net_node *nn = r2net_nn_from_num(sc->sc_node->nd_num);
+
+	sclog(sc, "shutting down\n");
+
+	/* drop the callbacks ref and call shutdown only once */
+	if (r2net_unregister_callbacks(sc->sc_sock->sk, sc)) {
+		/* we shouldn't flush as we're in the thread, the
+		 * races with pending sc work structs are harmless */
+		del_timer_sync(&sc->sc_idle_timeout);
+		r2net_sc_cancel_delayed_work(sc, &sc->sc_keepalive_work);
+		sc_put(sc);
+		kernel_sock_shutdown(sc->sc_sock, SHUT_RDWR);
+	}
+
+	/* not fatal so failed connects before the other guy has our
+	 * heartbeat can be retried */
+	r2net_ensure_shutdown(nn, sc, 0);
+	sc_put(sc);
+}
+
+/* ------------------------------------------------------------ */
+
+static int r2net_handler_cmp(struct r2net_msg_handler *nmh, u32 msg_type,
+			     u32 key)
+{
+	int ret = memcmp(&nmh->nh_key, &key, sizeof(key));
+
+	if (ret == 0)
+		ret = memcmp(&nmh->nh_msg_type, &msg_type, sizeof(msg_type));
+
+	return ret;
+}
+
+static struct r2net_msg_handler *
+r2net_handler_tree_lookup(u32 msg_type, u32 key, struct rb_node ***ret_p,
+				struct rb_node **ret_parent)
+{
+	struct rb_node **p = &r2net_handler_tree.rb_node;
+	struct rb_node *parent = NULL;
+	struct r2net_msg_handler *nmh, *ret = NULL;
+	int cmp;
+
+	while (*p) {
+		parent = *p;
+		nmh = rb_entry(parent, struct r2net_msg_handler, nh_node);
+		cmp = r2net_handler_cmp(nmh, msg_type, key);
+
+		if (cmp < 0)
+			p = &(*p)->rb_left;
+		else if (cmp > 0)
+			p = &(*p)->rb_right;
+		else {
+			ret = nmh;
+			break;
+		}
+	}
+
+	if (ret_p != NULL)
+		*ret_p = p;
+	if (ret_parent != NULL)
+		*ret_parent = parent;
+
+	return ret;
+}
+
+static void r2net_handler_kref_release(struct kref *kref)
+{
+	struct r2net_msg_handler *nmh;
+	nmh = container_of(kref, struct r2net_msg_handler, nh_kref);
+
+	kfree(nmh);
+}
+
+static void r2net_handler_put(struct r2net_msg_handler *nmh)
+{
+	kref_put(&nmh->nh_kref, r2net_handler_kref_release);
+}
+
+/* max_len is protection for the handler func.  incoming messages won't
+ * be given to the handler if their payload is longer than the max. */
+int r2net_register_handler(u32 msg_type, u32 key, u32 max_len,
+			   r2net_msg_handler_func *func, void *data,
+			   r2net_post_msg_handler_func *post_func,
+			   struct list_head *unreg_list)
+{
+	struct r2net_msg_handler *nmh = NULL;
+	struct rb_node **p, *parent;
+	int ret = 0;
+
+	if (max_len > R2NET_MAX_PAYLOAD_BYTES) {
+		mlog(0, "max_len for message handler out of range: %u\n",
+			max_len);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (!msg_type) {
+		mlog(0, "no message type provided: %u, %p\n", msg_type, func);
+		ret = -EINVAL;
+		goto out;
+
+	}
+	if (!func) {
+		mlog(0, "no message handler provided: %u, %p\n",
+		       msg_type, func);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	nmh = kzalloc(sizeof(struct r2net_msg_handler), GFP_NOFS);
+	if (nmh == NULL) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	nmh->nh_func = func;
+	nmh->nh_func_data = data;
+	nmh->nh_post_func = post_func;
+	nmh->nh_msg_type = msg_type;
+	nmh->nh_max_len = max_len;
+	nmh->nh_key = key;
+	/* the tree and list get this ref.. they're both removed in
+	 * unregister when this ref is dropped */
+	kref_init(&nmh->nh_kref);
+	INIT_LIST_HEAD(&nmh->nh_unregister_item);
+
+	write_lock(&r2net_handler_lock);
+	if (r2net_handler_tree_lookup(msg_type, key, &p, &parent))
+		ret = -EEXIST;
+	else {
+		rb_link_node(&nmh->nh_node, parent, p);
+		rb_insert_color(&nmh->nh_node, &r2net_handler_tree);
+		list_add_tail(&nmh->nh_unregister_item, unreg_list);
+
+		mlog(ML_TCP, "registered handler func %p type %u key %08x\n",
+		     func, msg_type, key);
+		/* we've had some trouble with handlers seemingly vanishing. */
+		mlog_bug_on_msg(r2net_handler_tree_lookup(msg_type, key, &p,
+							  &parent) == NULL,
+				"couldn't find handler we *just* registered "
+				"for type %u key %08x\n", msg_type, key);
+	}
+	write_unlock(&r2net_handler_lock);
+	if (ret)
+		goto out;
+
+out:
+	if (ret)
+		kfree(nmh);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(r2net_register_handler);
+
+void r2net_unregister_handler_list(struct list_head *list)
+{
+	struct r2net_msg_handler *nmh, *n;
+
+	write_lock(&r2net_handler_lock);
+	list_for_each_entry_safe(nmh, n, list, nh_unregister_item) {
+		mlog(ML_TCP, "unregistering handler func %p type %u key %08x\n",
+		     nmh->nh_func, nmh->nh_msg_type, nmh->nh_key);
+		rb_erase(&nmh->nh_node, &r2net_handler_tree);
+		list_del_init(&nmh->nh_unregister_item);
+		kref_put(&nmh->nh_kref, r2net_handler_kref_release);
+	}
+	write_unlock(&r2net_handler_lock);
+}
+EXPORT_SYMBOL_GPL(r2net_unregister_handler_list);
+
+static struct r2net_msg_handler *r2net_handler_get(u32 msg_type, u32 key)
+{
+	struct r2net_msg_handler *nmh;
+
+	read_lock(&r2net_handler_lock);
+	nmh = r2net_handler_tree_lookup(msg_type, key, NULL, NULL);
+	if (nmh)
+		kref_get(&nmh->nh_kref);
+	read_unlock(&r2net_handler_lock);
+
+	return nmh;
+}
+
+/* ------------------------------------------------------------ */
+
+static int r2net_recv_tcp_msg(struct socket *sock, void *data, size_t len)
+{
+	int ret;
+	mm_segment_t oldfs;
+	struct kvec vec = {
+		.iov_len = len,
+		.iov_base = data,
+	};
+	struct msghdr msg = {
+		.msg_iovlen = 1,
+		.msg_iov = (struct iovec *)&vec,
+		.msg_flags = MSG_DONTWAIT,
+	};
+
+	oldfs = get_fs();
+	set_fs(get_ds());
+	ret = sock_recvmsg(sock, &msg, len, msg.msg_flags);
+	set_fs(oldfs);
+
+	return ret;
+}
+
+static int r2net_send_tcp_msg(struct socket *sock, struct kvec *vec,
+			      size_t veclen, size_t total)
+{
+	int ret;
+	mm_segment_t oldfs;
+	struct msghdr msg = {
+		.msg_iov = (struct iovec *)vec,
+		.msg_iovlen = veclen,
+	};
+
+	if (sock == NULL) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	oldfs = get_fs();
+	set_fs(get_ds());
+	ret = sock_sendmsg(sock, &msg, total);
+	set_fs(oldfs);
+	if (ret != total) {
+		mlog(ML_ERROR, "sendmsg returned %d instead of %zu\n", ret,
+		     total);
+		if (ret >= 0)
+			ret = -EPIPE; /* should be smarter, I bet */
+		goto out;
+	}
+
+	ret = 0;
+out:
+	if (ret < 0)
+		mlog(0, "returning error: %d\n", ret);
+	return ret;
+}
+
+static void r2net_sendpage(struct r2net_sock_container *sc,
+			   void *kmalloced_virt,
+			   size_t size)
+{
+	struct r2net_node *nn = r2net_nn_from_num(sc->sc_node->nd_num);
+	ssize_t ret;
+
+	while (1) {
+		mutex_lock(&sc->sc_send_lock);
+		ret = sc->sc_sock->ops->sendpage(sc->sc_sock,
+					virt_to_page(kmalloced_virt),
+					(long)kmalloced_virt & ~PAGE_MASK,
+					size, MSG_DONTWAIT);
+		mutex_unlock(&sc->sc_send_lock);
+		if (ret == size)
+			break;
+		if (ret == (ssize_t)-EAGAIN) {
+			mlog(0, "sendpage of size %zu to " SC_NODEF_FMT
+			     " returned EAGAIN\n", size, sc->sc_node->nd_name,
+				sc->sc_node->nd_num,
+				&sc->sc_node->nd_ipv4_address,
+				ntohs(sc->sc_node->nd_ipv4_port));
+			cond_resched();
+			continue;
+		}
+		mlog(ML_ERROR, "sendpage of size %zu to " SC_NODEF_FMT
+		     " failed with %zd\n", size, sc->sc_node->nd_name,
+			sc->sc_node->nd_num, &sc->sc_node->nd_ipv4_address,
+			ntohs(sc->sc_node->nd_ipv4_port), ret);
+		r2net_ensure_shutdown(nn, sc, 0);
+		break;
+	}
+}
+
+static void r2net_init_msg(struct r2net_msg *msg, u16 data_len,
+				u16 msg_type, u32 key)
+{
+	memset(msg, 0, sizeof(struct r2net_msg));
+	msg->magic = cpu_to_be16(R2NET_MSG_MAGIC);
+	msg->data_len = cpu_to_be16(data_len);
+	msg->msg_type = cpu_to_be16(msg_type);
+	msg->sys_status = cpu_to_be32(R2NET_ERR_NONE);
+	msg->status = 0;
+	msg->key = cpu_to_be32(key);
+}
+
+static int r2net_tx_can_proceed(struct r2net_node *nn,
+				struct r2net_sock_container **sc_ret,
+				int *error)
+{
+	int ret = 0;
+
+	spin_lock(&nn->nn_lock);
+	if (nn->nn_persistent_error) {
+		ret = 1;
+		*sc_ret = NULL;
+		*error = nn->nn_persistent_error;
+	} else if (nn->nn_sc_valid) {
+		kref_get(&nn->nn_sc->sc_kref);
+
+		ret = 1;
+		*sc_ret = nn->nn_sc;
+		*error = 0;
+	}
+	spin_unlock(&nn->nn_lock);
+
+	return ret;
+}
+
+/* Get a map of all nodes to which this node is currently connected to */
+void r2net_fill_node_map(unsigned long *map, unsigned bytes)
+{
+	struct r2net_sock_container *sc;
+	int node, ret;
+
+	BUG_ON(bytes < (BITS_TO_LONGS(R2NM_MAX_NODES) * sizeof(unsigned long)));
+
+	memset(map, 0, bytes);
+	for (node = 0; node < R2NM_MAX_NODES; ++node) {
+		r2net_tx_can_proceed(r2net_nn_from_num(node), &sc, &ret);
+		if (!ret) {
+			set_bit(node, map);
+			sc_put(sc);
+		}
+	}
+}
+EXPORT_SYMBOL_GPL(r2net_fill_node_map);
+
+int r2net_send_message_vec(u32 msg_type, u32 key, struct kvec *caller_vec,
+			   size_t caller_veclen, u8 target_node, int *status)
+{
+	int ret = 0;
+	struct r2net_msg *msg = NULL;
+	size_t veclen, caller_bytes = 0;
+	struct kvec *vec = NULL;
+	struct r2net_sock_container *sc = NULL;
+	struct r2net_node *nn = r2net_nn_from_num(target_node);
+	struct r2net_status_wait nsw = {
+		.ns_node_item = LIST_HEAD_INIT(nsw.ns_node_item),
+	};
+	struct r2net_send_tracking nst;
+
+	/* this may be a general bug fix */
+	init_waitqueue_head(&nsw.ns_wq);
+
+	r2net_init_nst(&nst, msg_type, key, current, target_node);
+
+	if (r2net_wq == NULL) {
+		mlog(0, "attempt to tx without r2netd running\n");
+		ret = -ESRCH;
+		goto out;
+	}
+
+	if (caller_veclen == 0) {
+		mlog(0, "bad kvec array length\n");
+		ret = -EINVAL;
+		goto out;
+	}
+
+	caller_bytes = iov_length((struct iovec *)caller_vec, caller_veclen);
+	if (caller_bytes > R2NET_MAX_PAYLOAD_BYTES) {
+		mlog(0, "total payload len %zu too large\n", caller_bytes);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (target_node == r2nm_this_node()) {
+		ret = -ELOOP;
+		goto out;
+	}
+
+	r2net_debug_add_nst(&nst);
+
+	r2net_set_nst_sock_time(&nst);
+
+	wait_event(nn->nn_sc_wq, r2net_tx_can_proceed(nn, &sc, &ret));
+	if (ret)
+		goto out;
+
+	r2net_set_nst_sock_container(&nst, sc);
+
+	veclen = caller_veclen + 1;
+	vec = kmalloc(sizeof(struct kvec) * veclen, GFP_ATOMIC);
+	if (vec == NULL) {
+		mlog(0, "failed to %zu element kvec!\n", veclen);
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	msg = kmalloc(sizeof(struct r2net_msg), GFP_ATOMIC);
+	if (!msg) {
+		mlog(0, "failed to allocate a r2net_msg!\n");
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	r2net_init_msg(msg, caller_bytes, msg_type, key);
+
+	vec[0].iov_len = sizeof(struct r2net_msg);
+	vec[0].iov_base = msg;
+	memcpy(&vec[1], caller_vec, caller_veclen * sizeof(struct kvec));
+
+	ret = r2net_prep_nsw(nn, &nsw);
+	if (ret)
+		goto out;
+
+	msg->msg_num = cpu_to_be32(nsw.ns_id);
+	r2net_set_nst_msg_id(&nst, nsw.ns_id);
+
+	r2net_set_nst_send_time(&nst);
+
+	/* finally, convert the message header to network byte-order
+	 * and send */
+	mutex_lock(&sc->sc_send_lock);
+	ret = r2net_send_tcp_msg(sc->sc_sock, vec, veclen,
+				 sizeof(struct r2net_msg) + caller_bytes);
+	mutex_unlock(&sc->sc_send_lock);
+	msglog(msg, "sending returned %d\n", ret);
+	if (ret < 0) {
+		mlog(0, "error returned from r2net_send_tcp_msg=%d\n", ret);
+		goto out;
+	}
+
+	/* wait on other node's handler */
+	r2net_set_nst_status_time(&nst);
+	wait_event(nsw.ns_wq, r2net_nsw_completed(nn, &nsw) ||
+			nn->nn_persistent_error || !nn->nn_sc_valid);
+
+	r2net_update_send_stats(&nst, sc);
+
+	/* Note that we avoid overwriting the callers status return
+	 * variable if a system error was reported on the other
+	 * side. Callers beware. */
+	ret = r2net_sys_err_to_errno(nsw.ns_sys_status);
+	if (status && !ret)
+		*status = nsw.ns_status;
+
+	mlog(0, "woken, returning system status %d, user status %d\n",
+	     ret, nsw.ns_status);
+out:
+	r2net_debug_del_nst(&nst); /* must be before dropping sc and node */
+	if (sc)
+		sc_put(sc);
+	kfree(vec);
+	kfree(msg);
+	r2net_complete_nsw(nn, &nsw, 0, 0, 0);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(r2net_send_message_vec);
+
+int r2net_send_message(u32 msg_type, u32 key, void *data, u32 len,
+		       u8 target_node, int *status)
+{
+	struct kvec vec = {
+		.iov_base = data,
+		.iov_len = len,
+	};
+	return r2net_send_message_vec(msg_type, key, &vec, 1,
+				      target_node, status);
+}
+EXPORT_SYMBOL_GPL(r2net_send_message);
+
+static int r2net_send_status_magic(struct socket *sock, struct r2net_msg *hdr,
+				   enum r2net_system_error syserr, int err)
+{
+	struct kvec vec = {
+		.iov_base = hdr,
+		.iov_len = sizeof(struct r2net_msg),
+	};
+
+	BUG_ON(syserr >= R2NET_ERR_MAX);
+
+	/* leave other fields intact from the incoming message, msg_num
+	 * in particular */
+	hdr->sys_status = cpu_to_be32(syserr);
+	hdr->status = cpu_to_be32(err);
+	/* twiddle the magic */
+	hdr->magic = cpu_to_be16(R2NET_MSG_STATUS_MAGIC);
+	hdr->data_len = 0;
+
+	msglog(hdr, "about to send status magic %d\n", err);
+	/* hdr has been in host byteorder this whole time */
+	return r2net_send_tcp_msg(sock, &vec, 1, sizeof(struct r2net_msg));
+}
+
+/*
+ * "data magic" is a long version of "status magic" where the message
+ * payload actually contains data to be passed in reply to certain messages
+ */
+static int r2net_send_data_magic(struct r2net_sock_container *sc,
+			  struct r2net_msg *hdr,
+			  void *data, size_t data_len,
+			  enum r2net_system_error syserr, int err)
+{
+	struct kvec vec[2];
+	int ret;
+
+	vec[0].iov_base = hdr;
+	vec[0].iov_len = sizeof(struct r2net_msg);
+	vec[1].iov_base = data;
+	vec[1].iov_len = data_len;
+
+	BUG_ON(syserr >= R2NET_ERR_MAX);
+
+	/* leave other fields intact from the incoming message, msg_num
+	 * in particular */
+	hdr->sys_status = cpu_to_be32(syserr);
+	hdr->status = cpu_to_be32(err);
+	hdr->magic = cpu_to_be16(R2NET_MSG_DATA_MAGIC);  /* twiddle magic */
+	hdr->data_len = cpu_to_be16(data_len);
+
+	msglog(hdr, "about to send data magic %d\n", err);
+	/* hdr has been in host byteorder this whole time */
+	ret = r2net_send_tcp_msg(sc->sc_sock, vec, 2,
+			sizeof(struct r2net_msg) + data_len);
+	return ret;
+}
+
+/*
+ * called by a message handler to convert an otherwise normal reply
+ * message into a "data magic" message
+ */
+void r2net_force_data_magic(struct r2net_msg *hdr, u16 msgtype, u32 msgkey)
+{
+	hdr->magic = cpu_to_be16(R2NET_MSG_DATA_MAGIC);
+	hdr->msg_type = cpu_to_be16(msgtype);
+	hdr->key = cpu_to_be32(msgkey);
+}
+
+/* this returns -errno if the header was unknown or too large, etc.
+ * after this is called the buffer us reused for the next message */
+static int r2net_process_message(struct r2net_sock_container *sc,
+				 struct r2net_msg *hdr)
+{
+	struct r2net_node *nn = r2net_nn_from_num(sc->sc_node->nd_num);
+	int ret = 0, handler_status;
+	enum  r2net_system_error syserr;
+	struct r2net_msg_handler *nmh = NULL;
+	void *ret_data = NULL;
+	int data_magic = 0;
+
+	msglog(hdr, "processing message\n");
+
+	r2net_sc_postpone_idle(sc);
+
+	switch (be16_to_cpu(hdr->magic)) {
+
+	case R2NET_MSG_STATUS_MAGIC:
+		/* special type for returning message status */
+		r2net_complete_nsw(nn, NULL, be32_to_cpu(hdr->msg_num),
+						be32_to_cpu(hdr->sys_status),
+						be32_to_cpu(hdr->status));
+		goto out;
+	case R2NET_MSG_KEEP_REQ_MAGIC:
+		r2net_sendpage(sc, r2net_keep_resp, sizeof(*r2net_keep_resp));
+		goto out;
+	case R2NET_MSG_KEEP_RESP_MAGIC:
+		goto out;
+	case R2NET_MSG_MAGIC:
+		break;
+	case R2NET_MSG_DATA_MAGIC:
+		/*
+		 * unlike a normal status magic, a data magic DOES
+		 * (MUST) have a handler, so the control flow is
+		 * a little funky here as a result
+		 */
+		data_magic = 1;
+		break;
+	default:
+		msglog(hdr, "bad magic\n");
+		ret = -EINVAL;
+		goto out;
+		break;
+	}
+
+	/* find a handler for it */
+	handler_status = 0;
+	nmh = r2net_handler_get(be16_to_cpu(hdr->msg_type),
+				be32_to_cpu(hdr->key));
+	if (!nmh) {
+		mlog(ML_TCP, "couldn't find handler for type %u key %08x\n",
+		     be16_to_cpu(hdr->msg_type), be32_to_cpu(hdr->key));
+		syserr = R2NET_ERR_NO_HNDLR;
+		goto out_respond;
+	}
+
+	syserr = R2NET_ERR_NONE;
+
+	if (be16_to_cpu(hdr->data_len) > nmh->nh_max_len)
+		syserr = R2NET_ERR_OVERFLOW;
+
+	if (syserr != R2NET_ERR_NONE) {
+		pr_err("ramster_r2net, message length problem\n");
+		goto out_respond;
+	}
+
+	r2net_set_func_start_time(sc);
+	sc->sc_msg_key = be32_to_cpu(hdr->key);
+	sc->sc_msg_type = be16_to_cpu(hdr->msg_type);
+	handler_status = (nmh->nh_func)(hdr, sizeof(struct r2net_msg) +
+					     be16_to_cpu(hdr->data_len),
+					nmh->nh_func_data, &ret_data);
+	if (data_magic) {
+		/*
+		 * handler handled data sent in reply to request
+		 * so complete the transaction
+		 */
+		r2net_complete_nsw(nn, NULL, be32_to_cpu(hdr->msg_num),
+			be32_to_cpu(hdr->sys_status), handler_status);
+		goto out;
+	}
+	/*
+	 * handler changed magic to DATA_MAGIC to reply to request for data,
+	 * implies ret_data points to data to return and handler_status
+	 * is the number of bytes of data
+	 */
+	if (be16_to_cpu(hdr->magic) == R2NET_MSG_DATA_MAGIC) {
+		ret = r2net_send_data_magic(sc, hdr,
+						ret_data, handler_status,
+						syserr, 0);
+		hdr = NULL;
+		mlog(0, "sending data reply %d, syserr %d returned %d\n",
+			handler_status, syserr, ret);
+		r2net_set_func_stop_time(sc);
+
+		r2net_update_recv_stats(sc);
+		goto out;
+	}
+	r2net_set_func_stop_time(sc);
+
+	r2net_update_recv_stats(sc);
+
+out_respond:
+	/* this destroys the hdr, so don't use it after this */
+	mutex_lock(&sc->sc_send_lock);
+	ret = r2net_send_status_magic(sc->sc_sock, hdr, syserr,
+				      handler_status);
+	mutex_unlock(&sc->sc_send_lock);
+	hdr = NULL;
+	mlog(0, "sending handler status %d, syserr %d returned %d\n",
+	     handler_status, syserr, ret);
+
+	if (nmh) {
+		BUG_ON(ret_data != NULL && nmh->nh_post_func == NULL);
+		if (nmh->nh_post_func)
+			(nmh->nh_post_func)(handler_status, nmh->nh_func_data,
+					    ret_data);
+	}
+
+out:
+	if (nmh)
+		r2net_handler_put(nmh);
+	return ret;
+}
+
+static int r2net_check_handshake(struct r2net_sock_container *sc)
+{
+	struct r2net_handshake *hand = page_address(sc->sc_page);
+	struct r2net_node *nn = r2net_nn_from_num(sc->sc_node->nd_num);
+
+	if (hand->protocol_version != cpu_to_be64(R2NET_PROTOCOL_VERSION)) {
+		pr_notice("ramster: " SC_NODEF_FMT " Advertised net "
+		       "protocol version %llu but %llu is required. "
+		       "Disconnecting.\n", sc->sc_node->nd_name,
+			sc->sc_node->nd_num, &sc->sc_node->nd_ipv4_address,
+			ntohs(sc->sc_node->nd_ipv4_port),
+		       (unsigned long long)be64_to_cpu(hand->protocol_version),
+		       R2NET_PROTOCOL_VERSION);
+
+		/* don't bother reconnecting if its the wrong version. */
+		r2net_ensure_shutdown(nn, sc, -ENOTCONN);
+		return -1;
+	}
+
+	/*
+	 * Ensure timeouts are consistent with other nodes, otherwise
+	 * we can end up with one node thinking that the other must be down,
+	 * but isn't. This can ultimately cause corruption.
+	 */
+	if (be32_to_cpu(hand->r2net_idle_timeout_ms) !=
+				r2net_idle_timeout()) {
+		pr_notice("ramster: " SC_NODEF_FMT " uses a network "
+		       "idle timeout of %u ms, but we use %u ms locally. "
+		       "Disconnecting.\n", sc->sc_node->nd_name,
+			sc->sc_node->nd_num, &sc->sc_node->nd_ipv4_address,
+			ntohs(sc->sc_node->nd_ipv4_port),
+		       be32_to_cpu(hand->r2net_idle_timeout_ms),
+		       r2net_idle_timeout());
+		r2net_ensure_shutdown(nn, sc, -ENOTCONN);
+		return -1;
+	}
+
+	if (be32_to_cpu(hand->r2net_keepalive_delay_ms) !=
+			r2net_keepalive_delay()) {
+		pr_notice("ramster: " SC_NODEF_FMT " uses a keepalive "
+		       "delay of %u ms, but we use %u ms locally. "
+		       "Disconnecting.\n", sc->sc_node->nd_name,
+			sc->sc_node->nd_num, &sc->sc_node->nd_ipv4_address,
+			ntohs(sc->sc_node->nd_ipv4_port),
+		       be32_to_cpu(hand->r2net_keepalive_delay_ms),
+		       r2net_keepalive_delay());
+		r2net_ensure_shutdown(nn, sc, -ENOTCONN);
+		return -1;
+	}
+
+	if (be32_to_cpu(hand->r2hb_heartbeat_timeout_ms) !=
+			R2HB_MAX_WRITE_TIMEOUT_MS) {
+		pr_notice("ramster: " SC_NODEF_FMT " uses a heartbeat "
+		       "timeout of %u ms, but we use %u ms locally. "
+		       "Disconnecting.\n", sc->sc_node->nd_name,
+			sc->sc_node->nd_num, &sc->sc_node->nd_ipv4_address,
+			ntohs(sc->sc_node->nd_ipv4_port),
+		       be32_to_cpu(hand->r2hb_heartbeat_timeout_ms),
+		       R2HB_MAX_WRITE_TIMEOUT_MS);
+		r2net_ensure_shutdown(nn, sc, -ENOTCONN);
+		return -1;
+	}
+
+	sc->sc_handshake_ok = 1;
+
+	spin_lock(&nn->nn_lock);
+	/* set valid and queue the idle timers only if it hasn't been
+	 * shut down already */
+	if (nn->nn_sc == sc) {
+		r2net_sc_reset_idle_timer(sc);
+		atomic_set(&nn->nn_timeout, 0);
+		r2net_set_nn_state(nn, sc, 1, 0);
+	}
+	spin_unlock(&nn->nn_lock);
+
+	/* shift everything up as though it wasn't there */
+	sc->sc_page_off -= sizeof(struct r2net_handshake);
+	if (sc->sc_page_off)
+		memmove(hand, hand + 1, sc->sc_page_off);
+
+	return 0;
+}
+
+/* this demuxes the queued rx bytes into header or payload bits and calls
+ * handlers as each full message is read off the socket.  it returns -error,
+ * == 0 eof, or > 0 for progress made.*/
+static int r2net_advance_rx(struct r2net_sock_container *sc)
+{
+	struct r2net_msg *hdr;
+	int ret = 0;
+	void *data;
+	size_t datalen;
+
+	sclog(sc, "receiving\n");
+	r2net_set_advance_start_time(sc);
+
+	if (unlikely(sc->sc_handshake_ok == 0)) {
+		if (sc->sc_page_off < sizeof(struct r2net_handshake)) {
+			data = page_address(sc->sc_page) + sc->sc_page_off;
+			datalen = sizeof(struct r2net_handshake) -
+							sc->sc_page_off;
+			ret = r2net_recv_tcp_msg(sc->sc_sock, data, datalen);
+			if (ret > 0)
+				sc->sc_page_off += ret;
+		}
+
+		if (sc->sc_page_off == sizeof(struct r2net_handshake)) {
+			r2net_check_handshake(sc);
+			if (unlikely(sc->sc_handshake_ok == 0))
+				ret = -EPROTO;
+		}
+		goto out;
+	}
+
+	/* do we need more header? */
+	if (sc->sc_page_off < sizeof(struct r2net_msg)) {
+		data = page_address(sc->sc_page) + sc->sc_page_off;
+		datalen = sizeof(struct r2net_msg) - sc->sc_page_off;
+		ret = r2net_recv_tcp_msg(sc->sc_sock, data, datalen);
+		if (ret > 0) {
+			sc->sc_page_off += ret;
+			/* only swab incoming here.. we can
+			 * only get here once as we cross from
+			 * being under to over */
+			if (sc->sc_page_off == sizeof(struct r2net_msg)) {
+				hdr = page_address(sc->sc_page);
+				if (be16_to_cpu(hdr->data_len) >
+				    R2NET_MAX_PAYLOAD_BYTES)
+					ret = -EOVERFLOW;
+				WARN_ON_ONCE(ret == -EOVERFLOW);
+			}
+		}
+		if (ret <= 0)
+			goto out;
+	}
+
+	if (sc->sc_page_off < sizeof(struct r2net_msg)) {
+		/* oof, still don't have a header */
+		goto out;
+	}
+
+	/* this was swabbed above when we first read it */
+	hdr = page_address(sc->sc_page);
+
+	msglog(hdr, "at page_off %zu\n", sc->sc_page_off);
+
+	/* do we need more payload? */
+	if (sc->sc_page_off - sizeof(struct r2net_msg) <
+					be16_to_cpu(hdr->data_len)) {
+		/* need more payload */
+		data = page_address(sc->sc_page) + sc->sc_page_off;
+		datalen = (sizeof(struct r2net_msg) +
+				be16_to_cpu(hdr->data_len)) -
+				sc->sc_page_off;
+		ret = r2net_recv_tcp_msg(sc->sc_sock, data, datalen);
+		if (ret > 0)
+			sc->sc_page_off += ret;
+		if (ret <= 0)
+			goto out;
+	}
+
+	if (sc->sc_page_off - sizeof(struct r2net_msg) ==
+						be16_to_cpu(hdr->data_len)) {
+		/* we can only get here once, the first time we read
+		 * the payload.. so set ret to progress if the handler
+		 * works out. after calling this the message is toast */
+		ret = r2net_process_message(sc, hdr);
+		if (ret == 0)
+			ret = 1;
+		sc->sc_page_off = 0;
+	}
+
+out:
+	sclog(sc, "ret = %d\n", ret);
+	r2net_set_advance_stop_time(sc);
+	return ret;
+}
+
+/* this work func is triggerd by data ready.  it reads until it can read no
+ * more.  it interprets 0, eof, as fatal.  if data_ready hits while we're doing
+ * our work the work struct will be marked and we'll be called again. */
+static void r2net_rx_until_empty(struct work_struct *work)
+{
+	struct r2net_sock_container *sc =
+		container_of(work, struct r2net_sock_container, sc_rx_work);
+	int ret;
+
+	do {
+		ret = r2net_advance_rx(sc);
+	} while (ret > 0);
+
+	if (ret <= 0 && ret != -EAGAIN) {
+		struct r2net_node *nn = r2net_nn_from_num(sc->sc_node->nd_num);
+		sclog(sc, "saw error %d, closing\n", ret);
+		/* not permanent so read failed handshake can retry */
+		r2net_ensure_shutdown(nn, sc, 0);
+	}
+	sc_put(sc);
+}
+
+static int r2net_set_nodelay(struct socket *sock)
+{
+	int ret, val = 1;
+	mm_segment_t oldfs;
+
+	oldfs = get_fs();
+	set_fs(KERNEL_DS);
+
+	/*
+	 * Dear unsuspecting programmer,
+	 *
+	 * Don't use sock_setsockopt() for SOL_TCP.  It doesn't check its level
+	 * argument and assumes SOL_SOCKET so, say, your TCP_NODELAY will
+	 * silently turn into SO_DEBUG.
+	 *
+	 * Yours,
+	 * Keeper of hilariously fragile interfaces.
+	 */
+	ret = sock->ops->setsockopt(sock, SOL_TCP, TCP_NODELAY,
+				    (char __user *)&val, sizeof(val));
+
+	set_fs(oldfs);
+	return ret;
+}
+
+static void r2net_initialize_handshake(void)
+{
+	r2net_hand->r2hb_heartbeat_timeout_ms = cpu_to_be32(
+		R2HB_MAX_WRITE_TIMEOUT_MS);
+	r2net_hand->r2net_idle_timeout_ms = cpu_to_be32(r2net_idle_timeout());
+	r2net_hand->r2net_keepalive_delay_ms = cpu_to_be32(
+		r2net_keepalive_delay());
+	r2net_hand->r2net_reconnect_delay_ms = cpu_to_be32(
+		r2net_reconnect_delay());
+}
+
+/* ------------------------------------------------------------ */
+
+/* called when a connect completes and after a sock is accepted.  the
+ * rx path will see the response and mark the sc valid */
+static void r2net_sc_connect_completed(struct work_struct *work)
+{
+	struct r2net_sock_container *sc =
+			container_of(work, struct r2net_sock_container,
+			     sc_connect_work);
+
+	mlog(ML_MSG, "sc sending handshake with ver %llu id %llx\n",
+		(unsigned long long)R2NET_PROTOCOL_VERSION,
+		(unsigned long long)be64_to_cpu(r2net_hand->connector_id));
+
+	r2net_initialize_handshake();
+	r2net_sendpage(sc, r2net_hand, sizeof(*r2net_hand));
+	sc_put(sc);
+}
+
+/* this is called as a work_struct func. */
+static void r2net_sc_send_keep_req(struct work_struct *work)
+{
+	struct r2net_sock_container *sc =
+		container_of(work, struct r2net_sock_container,
+			     sc_keepalive_work.work);
+
+	r2net_sendpage(sc, r2net_keep_req, sizeof(*r2net_keep_req));
+	sc_put(sc);
+}
+
+/* socket shutdown does a del_timer_sync against this as it tears down.
+ * we can't start this timer until we've got to the point in sc buildup
+ * where shutdown is going to be involved */
+static void r2net_idle_timer(unsigned long data)
+{
+	struct r2net_sock_container *sc = (struct r2net_sock_container *)data;
+	struct r2net_node *nn = r2net_nn_from_num(sc->sc_node->nd_num);
+#ifdef CONFIG_DEBUG_FS
+	unsigned long msecs = ktime_to_ms(ktime_get()) -
+		ktime_to_ms(sc->sc_tv_timer);
+#else
+	unsigned long msecs = r2net_idle_timeout();
+#endif
+
+	pr_notice("ramster: Connection to " SC_NODEF_FMT " has been "
+	       "idle for %lu.%lu secs, shutting it down.\n",
+		sc->sc_node->nd_name, sc->sc_node->nd_num,
+		&sc->sc_node->nd_ipv4_address, ntohs(sc->sc_node->nd_ipv4_port),
+	       msecs / 1000, msecs % 1000);
+
+	/*
+	 * Initialize the nn_timeout so that the next connection attempt
+	 * will continue in r2net_start_connect.
+	 */
+	atomic_set(&nn->nn_timeout, 1);
+	r2net_sc_queue_work(sc, &sc->sc_shutdown_work);
+}
+
+static void r2net_sc_reset_idle_timer(struct r2net_sock_container *sc)
+{
+	r2net_sc_cancel_delayed_work(sc, &sc->sc_keepalive_work);
+	r2net_sc_queue_delayed_work(sc, &sc->sc_keepalive_work,
+		      msecs_to_jiffies(r2net_keepalive_delay()));
+	r2net_set_sock_timer(sc);
+	mod_timer(&sc->sc_idle_timeout,
+	       jiffies + msecs_to_jiffies(r2net_idle_timeout()));
+}
+
+static void r2net_sc_postpone_idle(struct r2net_sock_container *sc)
+{
+	/* Only push out an existing timer */
+	if (timer_pending(&sc->sc_idle_timeout))
+		r2net_sc_reset_idle_timer(sc);
+}
+
+/* this work func is kicked whenever a path sets the nn state which doesn't
+ * have valid set.  This includes seeing hb come up, losing a connection,
+ * having a connect attempt fail, etc. This centralizes the logic which decides
+ * if a connect attempt should be made or if we should give up and all future
+ * transmit attempts should fail */
+static void r2net_start_connect(struct work_struct *work)
+{
+	struct r2net_node *nn =
+		container_of(work, struct r2net_node, nn_connect_work.work);
+	struct r2net_sock_container *sc = NULL;
+	struct r2nm_node *node = NULL, *mynode = NULL;
+	struct socket *sock = NULL;
+	struct sockaddr_in myaddr = {0, }, remoteaddr = {0, };
+	int ret = 0, stop;
+	unsigned int timeout;
+
+	/* if we're greater we initiate tx, otherwise we accept */
+	if (r2nm_this_node() <= r2net_num_from_nn(nn))
+		goto out;
+
+	/* watch for racing with tearing a node down */
+	node = r2nm_get_node_by_num(r2net_num_from_nn(nn));
+	if (node == NULL) {
+		ret = 0;
+		goto out;
+	}
+
+	mynode = r2nm_get_node_by_num(r2nm_this_node());
+	if (mynode == NULL) {
+		ret = 0;
+		goto out;
+	}
+
+	spin_lock(&nn->nn_lock);
+	/*
+	 * see if we already have one pending or have given up.
+	 * For nn_timeout, it is set when we close the connection
+	 * because of the idle time out. So it means that we have
+	 * at least connected to that node successfully once,
+	 * now try to connect to it again.
+	 */
+	timeout = atomic_read(&nn->nn_timeout);
+	stop = (nn->nn_sc ||
+		(nn->nn_persistent_error &&
+		(nn->nn_persistent_error != -ENOTCONN || timeout == 0)));
+	spin_unlock(&nn->nn_lock);
+	if (stop)
+		goto out;
+
+	nn->nn_last_connect_attempt = jiffies;
+
+	sc = sc_alloc(node);
+	if (sc == NULL) {
+		mlog(0, "couldn't allocate sc\n");
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	ret = sock_create(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
+	if (ret < 0) {
+		mlog(0, "can't create socket: %d\n", ret);
+		goto out;
+	}
+	sc->sc_sock = sock; /* freed by sc_kref_release */
+
+	sock->sk->sk_allocation = GFP_ATOMIC;
+
+	myaddr.sin_family = AF_INET;
+	myaddr.sin_addr.s_addr = mynode->nd_ipv4_address;
+	myaddr.sin_port = htons(0); /* any port */
+
+	ret = sock->ops->bind(sock, (struct sockaddr *)&myaddr,
+			      sizeof(myaddr));
+	if (ret) {
+		mlog(ML_ERROR, "bind failed with %d at address %pI4\n",
+		     ret, &mynode->nd_ipv4_address);
+		goto out;
+	}
+
+	ret = r2net_set_nodelay(sc->sc_sock);
+	if (ret) {
+		mlog(ML_ERROR, "setting TCP_NODELAY failed with %d\n", ret);
+		goto out;
+	}
+
+	r2net_register_callbacks(sc->sc_sock->sk, sc);
+
+	spin_lock(&nn->nn_lock);
+	/* handshake completion will set nn->nn_sc_valid */
+	r2net_set_nn_state(nn, sc, 0, 0);
+	spin_unlock(&nn->nn_lock);
+
+	remoteaddr.sin_family = AF_INET;
+	remoteaddr.sin_addr.s_addr = node->nd_ipv4_address;
+	remoteaddr.sin_port = node->nd_ipv4_port;
+
+	ret = sc->sc_sock->ops->connect(sc->sc_sock,
+					(struct sockaddr *)&remoteaddr,
+					sizeof(remoteaddr),
+					O_NONBLOCK);
+	if (ret == -EINPROGRESS)
+		ret = 0;
+
+out:
+	if (ret) {
+		pr_notice("ramster: Connect attempt to " SC_NODEF_FMT
+		       " failed with errno %d\n", sc->sc_node->nd_name,
+			sc->sc_node->nd_num, &sc->sc_node->nd_ipv4_address,
+			ntohs(sc->sc_node->nd_ipv4_port), ret);
+		/* 0 err so that another will be queued and attempted
+		 * from set_nn_state */
+		if (sc)
+			r2net_ensure_shutdown(nn, sc, 0);
+	}
+	if (sc)
+		sc_put(sc);
+	if (node)
+		r2nm_node_put(node);
+	if (mynode)
+		r2nm_node_put(mynode);
+
+	return;
+}
+
+static void r2net_connect_expired(struct work_struct *work)
+{
+	struct r2net_node *nn =
+		container_of(work, struct r2net_node, nn_connect_expired.work);
+
+	spin_lock(&nn->nn_lock);
+	if (!nn->nn_sc_valid) {
+		pr_notice("ramster: No connection established with "
+		       "node %u after %u.%u seconds, giving up.\n",
+		     r2net_num_from_nn(nn),
+		     r2net_idle_timeout() / 1000,
+		     r2net_idle_timeout() % 1000);
+
+		r2net_set_nn_state(nn, NULL, 0, -ENOTCONN);
+	}
+	spin_unlock(&nn->nn_lock);
+}
+
+static void r2net_still_up(struct work_struct *work)
+{
+}
+
+/* ------------------------------------------------------------ */
+
+void r2net_disconnect_node(struct r2nm_node *node)
+{
+	struct r2net_node *nn = r2net_nn_from_num(node->nd_num);
+
+	/* don't reconnect until it's heartbeating again */
+	spin_lock(&nn->nn_lock);
+	atomic_set(&nn->nn_timeout, 0);
+	r2net_set_nn_state(nn, NULL, 0, -ENOTCONN);
+	spin_unlock(&nn->nn_lock);
+
+	if (r2net_wq) {
+		cancel_delayed_work(&nn->nn_connect_expired);
+		cancel_delayed_work(&nn->nn_connect_work);
+		cancel_delayed_work(&nn->nn_still_up);
+		flush_workqueue(r2net_wq);
+	}
+}
+
+static void r2net_hb_node_down_cb(struct r2nm_node *node, int node_num,
+				  void *data)
+{
+	if (!node)
+		return;
+
+	if (node_num != r2nm_this_node())
+		r2net_disconnect_node(node);
+
+	BUG_ON(atomic_read(&r2net_connected_peers) < 0);
+}
+
+static void r2net_hb_node_up_cb(struct r2nm_node *node, int node_num,
+				void *data)
+{
+	struct r2net_node *nn = r2net_nn_from_num(node_num);
+
+	BUG_ON(!node);
+
+	/* ensure an immediate connect attempt */
+	nn->nn_last_connect_attempt = jiffies -
+		(msecs_to_jiffies(r2net_reconnect_delay()) + 1);
+
+	if (node_num != r2nm_this_node()) {
+		/* believe it or not, accept and node hearbeating testing
+		 * can succeed for this node before we got here.. so
+		 * only use set_nn_state to clear the persistent error
+		 * if that hasn't already happened */
+		spin_lock(&nn->nn_lock);
+		atomic_set(&nn->nn_timeout, 0);
+		if (nn->nn_persistent_error)
+			r2net_set_nn_state(nn, NULL, 0, 0);
+		spin_unlock(&nn->nn_lock);
+	}
+}
+
+void r2net_unregister_hb_callbacks(void)
+{
+	r2hb_unregister_callback(NULL, &r2net_hb_up);
+	r2hb_unregister_callback(NULL, &r2net_hb_down);
+}
+
+int r2net_register_hb_callbacks(void)
+{
+	int ret;
+
+	r2hb_setup_callback(&r2net_hb_down, R2HB_NODE_DOWN_CB,
+			    r2net_hb_node_down_cb, NULL, R2NET_HB_PRI);
+	r2hb_setup_callback(&r2net_hb_up, R2HB_NODE_UP_CB,
+			    r2net_hb_node_up_cb, NULL, R2NET_HB_PRI);
+
+	ret = r2hb_register_callback(NULL, &r2net_hb_up);
+	if (ret == 0)
+		ret = r2hb_register_callback(NULL, &r2net_hb_down);
+
+	if (ret)
+		r2net_unregister_hb_callbacks();
+
+	return ret;
+}
+
+/* ------------------------------------------------------------ */
+
+static int r2net_accept_one(struct socket *sock)
+{
+	int ret, slen;
+	struct sockaddr_in sin;
+	struct socket *new_sock = NULL;
+	struct r2nm_node *node = NULL;
+	struct r2nm_node *local_node = NULL;
+	struct r2net_sock_container *sc = NULL;
+	struct r2net_node *nn;
+
+	BUG_ON(sock == NULL);
+	ret = sock_create_lite(sock->sk->sk_family, sock->sk->sk_type,
+			       sock->sk->sk_protocol, &new_sock);
+	if (ret)
+		goto out;
+
+	new_sock->type = sock->type;
+	new_sock->ops = sock->ops;
+	ret = sock->ops->accept(sock, new_sock, O_NONBLOCK);
+	if (ret < 0)
+		goto out;
+
+	new_sock->sk->sk_allocation = GFP_ATOMIC;
+
+	ret = r2net_set_nodelay(new_sock);
+	if (ret) {
+		mlog(ML_ERROR, "setting TCP_NODELAY failed with %d\n", ret);
+		goto out;
+	}
+
+	slen = sizeof(sin);
+	ret = new_sock->ops->getname(new_sock, (struct sockaddr *) &sin,
+				       &slen, 1);
+	if (ret < 0)
+		goto out;
+
+	node = r2nm_get_node_by_ip(sin.sin_addr.s_addr);
+	if (node == NULL) {
+		pr_notice("ramster: Attempt to connect from unknown "
+		       "node at %pI4:%d\n", &sin.sin_addr.s_addr,
+		       ntohs(sin.sin_port));
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (r2nm_this_node() >= node->nd_num) {
+		local_node = r2nm_get_node_by_num(r2nm_this_node());
+		pr_notice("ramster: Unexpected connect attempt seen "
+		       "at node '%s' (%u, %pI4:%d) from node '%s' (%u, "
+		       "%pI4:%d)\n", local_node->nd_name, local_node->nd_num,
+		       &(local_node->nd_ipv4_address),
+		       ntohs(local_node->nd_ipv4_port), node->nd_name,
+		       node->nd_num, &sin.sin_addr.s_addr, ntohs(sin.sin_port));
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* this happens all the time when the other node sees our heartbeat
+	 * and tries to connect before we see their heartbeat */
+	if (!r2hb_check_node_heartbeating_from_callback(node->nd_num)) {
+		mlog(ML_CONN, "attempt to connect from node '%s' at "
+		     "%pI4:%d but it isn't heartbeating\n",
+		     node->nd_name, &sin.sin_addr.s_addr,
+		     ntohs(sin.sin_port));
+		ret = -EINVAL;
+		goto out;
+	}
+
+	nn = r2net_nn_from_num(node->nd_num);
+
+	spin_lock(&nn->nn_lock);
+	if (nn->nn_sc)
+		ret = -EBUSY;
+	else
+		ret = 0;
+	spin_unlock(&nn->nn_lock);
+	if (ret) {
+		pr_notice("ramster: Attempt to connect from node '%s' "
+		       "at %pI4:%d but it already has an open connection\n",
+		       node->nd_name, &sin.sin_addr.s_addr,
+		       ntohs(sin.sin_port));
+		goto out;
+	}
+
+	sc = sc_alloc(node);
+	if (sc == NULL) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	sc->sc_sock = new_sock;
+	new_sock = NULL;
+
+	spin_lock(&nn->nn_lock);
+	atomic_set(&nn->nn_timeout, 0);
+	r2net_set_nn_state(nn, sc, 0, 0);
+	spin_unlock(&nn->nn_lock);
+
+	r2net_register_callbacks(sc->sc_sock->sk, sc);
+	r2net_sc_queue_work(sc, &sc->sc_rx_work);
+
+	r2net_initialize_handshake();
+	r2net_sendpage(sc, r2net_hand, sizeof(*r2net_hand));
+
+out:
+	if (new_sock)
+		sock_release(new_sock);
+	if (node)
+		r2nm_node_put(node);
+	if (local_node)
+		r2nm_node_put(local_node);
+	if (sc)
+		sc_put(sc);
+	return ret;
+}
+
+static void r2net_accept_many(struct work_struct *work)
+{
+	struct socket *sock = r2net_listen_sock;
+	while (r2net_accept_one(sock) == 0)
+		cond_resched();
+}
+
+static void r2net_listen_data_ready(struct sock *sk, int bytes)
+{
+	void (*ready)(struct sock *sk, int bytes);
+
+	read_lock(&sk->sk_callback_lock);
+	ready = sk->sk_user_data;
+	if (ready == NULL) { /* check for teardown race */
+		ready = sk->sk_data_ready;
+		goto out;
+	}
+
+	/* ->sk_data_ready is also called for a newly established child socket
+	 * before it has been accepted and the acceptor has set up their
+	 * data_ready.. we only want to queue listen work for our listening
+	 * socket */
+	if (sk->sk_state == TCP_LISTEN) {
+		mlog(ML_TCP, "bytes: %d\n", bytes);
+		queue_work(r2net_wq, &r2net_listen_work);
+	}
+
+out:
+	read_unlock(&sk->sk_callback_lock);
+	ready(sk, bytes);
+}
+
+static int r2net_open_listening_sock(__be32 addr, __be16 port)
+{
+	struct socket *sock = NULL;
+	int ret;
+	struct sockaddr_in sin = {
+		.sin_family = PF_INET,
+		.sin_addr = { .s_addr = addr },
+		.sin_port = port,
+	};
+
+	ret = sock_create(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
+	if (ret < 0) {
+		pr_err("ramster: Error %d while creating socket\n", ret);
+		goto out;
+	}
+
+	sock->sk->sk_allocation = GFP_ATOMIC;
+
+	write_lock_bh(&sock->sk->sk_callback_lock);
+	sock->sk->sk_user_data = sock->sk->sk_data_ready;
+	sock->sk->sk_data_ready = r2net_listen_data_ready;
+	write_unlock_bh(&sock->sk->sk_callback_lock);
+
+	r2net_listen_sock = sock;
+	INIT_WORK(&r2net_listen_work, r2net_accept_many);
+
+	sock->sk->sk_reuse = /* SK_CAN_REUSE FIXME FOR 3.4 */ 1;
+	ret = sock->ops->bind(sock, (struct sockaddr *)&sin, sizeof(sin));
+	if (ret < 0) {
+		pr_err("ramster: Error %d while binding socket at %pI4:%u\n",
+			ret, &addr, ntohs(port));
+		goto out;
+	}
+
+	ret = sock->ops->listen(sock, 64);
+	if (ret < 0)
+		pr_err("ramster: Error %d while listening on %pI4:%u\n",
+		       ret, &addr, ntohs(port));
+
+out:
+	if (ret) {
+		r2net_listen_sock = NULL;
+		if (sock)
+			sock_release(sock);
+	}
+	return ret;
+}
+
+/*
+ * called from node manager when we should bring up our network listening
+ * socket.  node manager handles all the serialization to only call this
+ * once and to match it with r2net_stop_listening().  note,
+ * r2nm_this_node() doesn't work yet as we're being called while it
+ * is being set up.
+ */
+int r2net_start_listening(struct r2nm_node *node)
+{
+	int ret = 0;
+
+	BUG_ON(r2net_wq != NULL);
+	BUG_ON(r2net_listen_sock != NULL);
+
+	mlog(ML_KTHREAD, "starting r2net thread...\n");
+	r2net_wq = create_singlethread_workqueue("r2net");
+	if (r2net_wq == NULL) {
+		mlog(ML_ERROR, "unable to launch r2net thread\n");
+		return -ENOMEM; /* ? */
+	}
+
+	ret = r2net_open_listening_sock(node->nd_ipv4_address,
+					node->nd_ipv4_port);
+	if (ret) {
+		destroy_workqueue(r2net_wq);
+		r2net_wq = NULL;
+	}
+
+	return ret;
+}
+
+/* again, r2nm_this_node() doesn't work here as we're involved in
+ * tearing it down */
+void r2net_stop_listening(struct r2nm_node *node)
+{
+	struct socket *sock = r2net_listen_sock;
+	size_t i;
+
+	BUG_ON(r2net_wq == NULL);
+	BUG_ON(r2net_listen_sock == NULL);
+
+	/* stop the listening socket from generating work */
+	write_lock_bh(&sock->sk->sk_callback_lock);
+	sock->sk->sk_data_ready = sock->sk->sk_user_data;
+	sock->sk->sk_user_data = NULL;
+	write_unlock_bh(&sock->sk->sk_callback_lock);
+
+	for (i = 0; i < ARRAY_SIZE(r2net_nodes); i++) {
+		struct r2nm_node *node = r2nm_get_node_by_num(i);
+		if (node) {
+			r2net_disconnect_node(node);
+			r2nm_node_put(node);
+		}
+	}
+
+	/* finish all work and tear down the work queue */
+	mlog(ML_KTHREAD, "waiting for r2net thread to exit....\n");
+	destroy_workqueue(r2net_wq);
+	r2net_wq = NULL;
+
+	sock_release(r2net_listen_sock);
+	r2net_listen_sock = NULL;
+}
+
+void r2net_hb_node_up_manual(int node_num)
+{
+	struct r2nm_node dummy;
+	if (r2nm_single_cluster == NULL)
+		pr_err("ramster: cluster not alive, node_up_manual ignored\n");
+	else {
+		r2hb_manual_set_node_heartbeating(node_num);
+		r2net_hb_node_up_cb(&dummy, node_num, NULL);
+	}
+}
+
+/* ------------------------------------------------------------ */
+
+int r2net_init(void)
+{
+	unsigned long i;
+
+	if (r2net_debugfs_init())
+		return -ENOMEM;
+
+	r2net_hand = kzalloc(sizeof(struct r2net_handshake), GFP_KERNEL);
+	r2net_keep_req = kzalloc(sizeof(struct r2net_msg), GFP_KERNEL);
+	r2net_keep_resp = kzalloc(sizeof(struct r2net_msg), GFP_KERNEL);
+	if (!r2net_hand || !r2net_keep_req || !r2net_keep_resp) {
+		kfree(r2net_hand);
+		kfree(r2net_keep_req);
+		kfree(r2net_keep_resp);
+		return -ENOMEM;
+	}
+
+	r2net_hand->protocol_version = cpu_to_be64(R2NET_PROTOCOL_VERSION);
+	r2net_hand->connector_id = cpu_to_be64(1);
+
+	r2net_keep_req->magic = cpu_to_be16(R2NET_MSG_KEEP_REQ_MAGIC);
+	r2net_keep_resp->magic = cpu_to_be16(R2NET_MSG_KEEP_RESP_MAGIC);
+
+	for (i = 0; i < ARRAY_SIZE(r2net_nodes); i++) {
+		struct r2net_node *nn = r2net_nn_from_num(i);
+
+		atomic_set(&nn->nn_timeout, 0);
+		spin_lock_init(&nn->nn_lock);
+		INIT_DELAYED_WORK(&nn->nn_connect_work, r2net_start_connect);
+		INIT_DELAYED_WORK(&nn->nn_connect_expired,
+				  r2net_connect_expired);
+		INIT_DELAYED_WORK(&nn->nn_still_up, r2net_still_up);
+		/* until we see hb from a node we'll return einval */
+		nn->nn_persistent_error = -ENOTCONN;
+		init_waitqueue_head(&nn->nn_sc_wq);
+		idr_init(&nn->nn_status_idr);
+		INIT_LIST_HEAD(&nn->nn_status_list);
+	}
+
+	return 0;
+}
+
+void r2net_exit(void)
+{
+	kfree(r2net_hand);
+	kfree(r2net_keep_req);
+	kfree(r2net_keep_resp);
+	r2net_debugfs_exit();
+}
diff --git a/drivers/staging/zcache/ramster/tcp.h b/drivers/staging/zcache/ramster/tcp.h
new file mode 100644
index 0000000..9d05833
--- /dev/null
+++ b/drivers/staging/zcache/ramster/tcp.h
@@ -0,0 +1,159 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * tcp.h
+ *
+ * Function prototypes
+ *
+ * Copyright (C) 2004 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ */
+
+#ifndef R2CLUSTER_TCP_H
+#define R2CLUSTER_TCP_H
+
+#include <linux/socket.h>
+#ifdef __KERNEL__
+#include <net/sock.h>
+#include <linux/tcp.h>
+#else
+#include <sys/socket.h>
+#endif
+#include <linux/inet.h>
+#include <linux/in.h>
+
+struct r2net_msg {
+	__be16 magic;
+	__be16 data_len;
+	__be16 msg_type;
+	__be16 pad1;
+	__be32 sys_status;
+	__be32 status;
+	__be32 key;
+	__be32 msg_num;
+	__u8  buf[0];
+};
+
+typedef int (r2net_msg_handler_func)(struct r2net_msg *msg, u32 len, void *data,
+				     void **ret_data);
+typedef void (r2net_post_msg_handler_func)(int status, void *data,
+					   void *ret_data);
+
+#define R2NET_MAX_PAYLOAD_BYTES  (4096 - sizeof(struct r2net_msg))
+
+/* same as hb delay, we're waiting for another node to recognize our hb */
+#define R2NET_RECONNECT_DELAY_MS_DEFAULT	2000
+
+#define R2NET_KEEPALIVE_DELAY_MS_DEFAULT	2000
+#define R2NET_IDLE_TIMEOUT_MS_DEFAULT		30000
+
+
+/* TODO: figure this out.... */
+static inline int r2net_link_down(int err, struct socket *sock)
+{
+	if (sock) {
+		if (sock->sk->sk_state != TCP_ESTABLISHED &&
+			sock->sk->sk_state != TCP_CLOSE_WAIT)
+			return 1;
+	}
+
+	if (err >= 0)
+		return 0;
+	switch (err) {
+
+	/* ????????????????????????? */
+	case -ERESTARTSYS:
+	case -EBADF:
+	/* When the server has died, an ICMP port unreachable
+	 * message prompts ECONNREFUSED. */
+	case -ECONNREFUSED:
+	case -ENOTCONN:
+	case -ECONNRESET:
+	case -EPIPE:
+		return 1;
+
+	}
+	return 0;
+}
+
+enum {
+	R2NET_DRIVER_UNINITED,
+	R2NET_DRIVER_READY,
+};
+
+int r2net_send_message(u32 msg_type, u32 key, void *data, u32 len,
+		       u8 target_node, int *status);
+int r2net_send_message_vec(u32 msg_type, u32 key, struct kvec *vec,
+			   size_t veclen, u8 target_node, int *status);
+
+int r2net_register_handler(u32 msg_type, u32 key, u32 max_len,
+			   r2net_msg_handler_func *func, void *data,
+			   r2net_post_msg_handler_func *post_func,
+			   struct list_head *unreg_list);
+void r2net_unregister_handler_list(struct list_head *list);
+
+void r2net_fill_node_map(unsigned long *map, unsigned bytes);
+
+void r2net_force_data_magic(struct r2net_msg *, u16, u32);
+void r2net_hb_node_up_manual(int);
+struct r2net_node *r2net_nn_from_num(u8);
+
+struct r2nm_node;
+int r2net_register_hb_callbacks(void);
+void r2net_unregister_hb_callbacks(void);
+int r2net_start_listening(struct r2nm_node *node);
+void r2net_stop_listening(struct r2nm_node *node);
+void r2net_disconnect_node(struct r2nm_node *node);
+int r2net_num_connected_peers(void);
+
+int r2net_init(void);
+void r2net_exit(void);
+
+struct r2net_send_tracking;
+struct r2net_sock_container;
+
+#if 0
+int r2net_debugfs_init(void);
+void r2net_debugfs_exit(void);
+void r2net_debug_add_nst(struct r2net_send_tracking *nst);
+void r2net_debug_del_nst(struct r2net_send_tracking *nst);
+void r2net_debug_add_sc(struct r2net_sock_container *sc);
+void r2net_debug_del_sc(struct r2net_sock_container *sc);
+#else
+static inline int r2net_debugfs_init(void)
+{
+	return 0;
+}
+static inline void r2net_debugfs_exit(void)
+{
+}
+static inline void r2net_debug_add_nst(struct r2net_send_tracking *nst)
+{
+}
+static inline void r2net_debug_del_nst(struct r2net_send_tracking *nst)
+{
+}
+static inline void r2net_debug_add_sc(struct r2net_sock_container *sc)
+{
+}
+static inline void r2net_debug_del_sc(struct r2net_sock_container *sc)
+{
+}
+#endif	/* CONFIG_DEBUG_FS */
+
+#endif /* R2CLUSTER_TCP_H */
diff --git a/drivers/staging/zcache/ramster/tcp_internal.h b/drivers/staging/zcache/ramster/tcp_internal.h
new file mode 100644
index 0000000..4d8cc9f
--- /dev/null
+++ b/drivers/staging/zcache/ramster/tcp_internal.h
@@ -0,0 +1,248 @@
+/* -*- mode: c; c-basic-offset: 8; -*-
+ * vim: noexpandtab sw=8 ts=8 sts=0:
+ *
+ * Copyright (C) 2005 Oracle.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ */
+
+#ifndef R2CLUSTER_TCP_INTERNAL_H
+#define R2CLUSTER_TCP_INTERNAL_H
+
+#define R2NET_MSG_MAGIC           ((u16)0xfa55)
+#define R2NET_MSG_STATUS_MAGIC    ((u16)0xfa56)
+#define R2NET_MSG_KEEP_REQ_MAGIC  ((u16)0xfa57)
+#define R2NET_MSG_KEEP_RESP_MAGIC ((u16)0xfa58)
+/*
+ * "data magic" is a long version of "status magic" where the message
+ * payload actually contains data to be passed in reply to certain messages
+ */
+#define R2NET_MSG_DATA_MAGIC      ((u16)0xfa59)
+
+/* we're delaying our quorum decision so that heartbeat will have timed
+ * out truly dead nodes by the time we come around to making decisions
+ * on their number */
+#define R2NET_QUORUM_DELAY_MS	\
+		((r2hb_dead_threshold + 2) * R2HB_REGION_TIMEOUT_MS)
+
+/*
+ * This version number represents quite a lot, unfortunately.  It not
+ * only represents the raw network message protocol on the wire but also
+ * locking semantics of the file system using the protocol.  It should
+ * be somewhere else, I'm sure, but right now it isn't.
+ *
+ * With version 11, we separate out the filesystem locking portion.  The
+ * filesystem now has a major.minor version it negotiates.  Version 11
+ * introduces this negotiation to the r2dlm protocol, and as such the
+ * version here in tcp_internal.h should not need to be bumped for
+ * filesystem locking changes.
+ *
+ * New in version 11
+ *	- Negotiation of filesystem locking in the dlm join.
+ *
+ * New in version 10:
+ *	- Meta/data locks combined
+ *
+ * New in version 9:
+ *	- All votes removed
+ *
+ * New in version 8:
+ *	- Replace delete inode votes with a cluster lock
+ *
+ * New in version 7:
+ *	- DLM join domain includes the live nodemap
+ *
+ * New in version 6:
+ *	- DLM lockres remote refcount fixes.
+ *
+ * New in version 5:
+ *	- Network timeout checking protocol
+ *
+ * New in version 4:
+ *	- Remove i_generation from lock names for better stat performance.
+ *
+ * New in version 3:
+ *	- Replace dentry votes with a cluster lock
+ *
+ * New in version 2:
+ *	- full 64 bit i_size in the metadata lock lvbs
+ *	- introduction of "rw" lock and pushing meta/data locking down
+ */
+#define R2NET_PROTOCOL_VERSION 11ULL
+struct r2net_handshake {
+	__be64	protocol_version;
+	__be64	connector_id;
+	__be32  r2hb_heartbeat_timeout_ms;
+	__be32  r2net_idle_timeout_ms;
+	__be32  r2net_keepalive_delay_ms;
+	__be32  r2net_reconnect_delay_ms;
+};
+
+struct r2net_node {
+	/* this is never called from int/bh */
+	spinlock_t			nn_lock;
+
+	/* set the moment an sc is allocated and a connect is started */
+	struct r2net_sock_container	*nn_sc;
+	/* _valid is only set after the handshake passes and tx can happen */
+	unsigned			nn_sc_valid:1;
+	/* if this is set tx just returns it */
+	int				nn_persistent_error;
+	/* It is only set to 1 after the idle time out. */
+	atomic_t			nn_timeout;
+
+	/* threads waiting for an sc to arrive wait on the wq for generation
+	 * to increase.  it is increased when a connecting socket succeeds
+	 * or fails or when an accepted socket is attached. */
+	wait_queue_head_t		nn_sc_wq;
+
+	struct idr			nn_status_idr;
+	struct list_head		nn_status_list;
+
+	/* connects are attempted from when heartbeat comes up until either hb
+	 * goes down, the node is unconfigured, no connect attempts succeed
+	 * before R2NET_CONN_IDLE_DELAY, or a connect succeeds.  connect_work
+	 * is queued from set_nn_state both from hb up and from itself if a
+	 * connect attempt fails and so can be self-arming.  shutdown is
+	 * careful to first mark the nn such that no connects will be attempted
+	 * before canceling delayed connect work and flushing the queue. */
+	struct delayed_work		nn_connect_work;
+	unsigned long			nn_last_connect_attempt;
+
+	/* this is queued as nodes come up and is canceled when a connection is
+	 * established.  this expiring gives up on the node and errors out
+	 * transmits */
+	struct delayed_work		nn_connect_expired;
+
+	/* after we give up on a socket we wait a while before deciding
+	 * that it is still heartbeating and that we should do some
+	 * quorum work */
+	struct delayed_work		nn_still_up;
+};
+
+struct r2net_sock_container {
+	struct kref		sc_kref;
+	/* the next two are valid for the life time of the sc */
+	struct socket		*sc_sock;
+	struct r2nm_node	*sc_node;
+
+	/* all of these sc work structs hold refs on the sc while they are
+	 * queued.  they should not be able to ref a freed sc.  the teardown
+	 * race is with r2net_wq destruction in r2net_stop_listening() */
+
+	/* rx and connect work are generated from socket callbacks.  sc
+	 * shutdown removes the callbacks and then flushes the work queue */
+	struct work_struct	sc_rx_work;
+	struct work_struct	sc_connect_work;
+	/* shutdown work is triggered in two ways.  the simple way is
+	 * for a code path calls ensure_shutdown which gets a lock, removes
+	 * the sc from the nn, and queues the work.  in this case the
+	 * work is single-shot.  the work is also queued from a sock
+	 * callback, though, and in this case the work will find the sc
+	 * still on the nn and will call ensure_shutdown itself.. this
+	 * ends up triggering the shutdown work again, though nothing
+	 * will be done in that second iteration.  so work queue teardown
+	 * has to be careful to remove the sc from the nn before waiting
+	 * on the work queue so that the shutdown work doesn't remove the
+	 * sc and rearm itself.
+	 */
+	struct work_struct	sc_shutdown_work;
+
+	struct timer_list	sc_idle_timeout;
+	struct delayed_work	sc_keepalive_work;
+
+	unsigned		sc_handshake_ok:1;
+
+	struct page		*sc_page;
+	size_t			sc_page_off;
+
+	/* original handlers for the sockets */
+	void			(*sc_state_change)(struct sock *sk);
+	void			(*sc_data_ready)(struct sock *sk, int bytes);
+
+	u32			sc_msg_key;
+	u16			sc_msg_type;
+
+#ifdef CONFIG_DEBUG_FS
+	struct list_head        sc_net_debug_item;
+	ktime_t			sc_tv_timer;
+	ktime_t			sc_tv_data_ready;
+	ktime_t			sc_tv_advance_start;
+	ktime_t			sc_tv_advance_stop;
+	ktime_t			sc_tv_func_start;
+	ktime_t			sc_tv_func_stop;
+#endif
+#ifdef CONFIG_RAMSTER_FS_STATS
+	ktime_t			sc_tv_acquiry_total;
+	ktime_t			sc_tv_send_total;
+	ktime_t			sc_tv_status_total;
+	u32			sc_send_count;
+	u32			sc_recv_count;
+	ktime_t			sc_tv_process_total;
+#endif
+	struct mutex		sc_send_lock;
+};
+
+struct r2net_msg_handler {
+	struct rb_node		nh_node;
+	u32			nh_max_len;
+	u32			nh_msg_type;
+	u32			nh_key;
+	r2net_msg_handler_func	*nh_func;
+	r2net_msg_handler_func	*nh_func_data;
+	r2net_post_msg_handler_func
+				*nh_post_func;
+	struct kref		nh_kref;
+	struct list_head	nh_unregister_item;
+};
+
+enum r2net_system_error {
+	R2NET_ERR_NONE = 0,
+	R2NET_ERR_NO_HNDLR,
+	R2NET_ERR_OVERFLOW,
+	R2NET_ERR_DIED,
+	R2NET_ERR_MAX
+};
+
+struct r2net_status_wait {
+	enum r2net_system_error	ns_sys_status;
+	s32			ns_status;
+	int			ns_id;
+	wait_queue_head_t	ns_wq;
+	struct list_head	ns_node_item;
+};
+
+#ifdef CONFIG_DEBUG_FS
+/* just for state dumps */
+struct r2net_send_tracking {
+	struct list_head		st_net_debug_item;
+	struct task_struct		*st_task;
+	struct r2net_sock_container	*st_sc;
+	u32				st_id;
+	u32				st_msg_type;
+	u32				st_msg_key;
+	u8				st_node;
+	ktime_t				st_sock_time;
+	ktime_t				st_send_time;
+	ktime_t				st_status_time;
+};
+#else
+struct r2net_send_tracking {
+	u32	dummy;
+};
+#endif	/* CONFIG_DEBUG_FS */
+
+#endif /* R2CLUSTER_TCP_INTERNAL_H */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
