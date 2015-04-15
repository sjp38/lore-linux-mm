Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 118C36B006E
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 03:16:04 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so41882013pdb.2
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 00:16:03 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id kz11si5607924pab.98.2015.04.15.00.15.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 00:16:00 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NMU006PJ71BEQ20@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 15 Apr 2015 08:19:59 +0100 (BST)
From: Beata Michalska <b.michalska@samsung.com>
Subject: [RFC 1/4] fs: Add generic file system event notifications
Date: Wed, 15 Apr 2015 09:15:44 +0200
Message-id: <1429082147-4151-2-git-send-email-b.michalska@samsung.com>
In-reply-to: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

Introduce configurable generic interface for file
system-wide event notifications to provide file
systems with a common way of reporting any potential
issues as they emerge.

The notifications are to be issued through generic
netlink interface, by a dedicated, for file system
events, multicast group. The file systems might as
well use this group to send their own custom messages.

The events have been split into four base categories:
information, warnings, errors and threshold notifications,
with some very basic event types like running out of space
or file system being remounted as read-only.

Threshold notifications have been included to allow
triggering an event whenever the amount of free space
drops below a certain level - or levels to be more precise
as two of them are being supported: the lower and the upper
range. The notifications work both ways: once the threshold
level has been reached, an event shall be generated whenever
the number of available blocks goes up again re-activating
the threshold.

The interface has been exposed through a vfs. Once mounted,
it serves as an entry point for the set-up where one can
register for particular file system events.

Signed-off-by: Beata Michalska <b.michalska@samsung.com>
---
 Documentation/filesystems/events.txt |  254 +++++++++++
 fs/Makefile                          |    1 +
 fs/events/Makefile                   |    6 +
 fs/events/fs_event.c                 |  775 ++++++++++++++++++++++++++++++++++
 fs/events/fs_event.h                 |   27 ++
 fs/events/fs_event_netlink.c         |   94 +++++
 fs/namespace.c                       |    1 +
 include/linux/fs.h                   |    6 +-
 include/linux/fs_event.h             |   69 +++
 include/uapi/linux/fs_event.h        |   62 +++
 include/uapi/linux/genetlink.h       |    1 +
 net/netlink/genetlink.c              |    7 +-
 12 files changed, 1301 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/filesystems/events.txt
 create mode 100644 fs/events/Makefile
 create mode 100644 fs/events/fs_event.c
 create mode 100644 fs/events/fs_event.h
 create mode 100644 fs/events/fs_event_netlink.c
 create mode 100644 include/linux/fs_event.h
 create mode 100644 include/uapi/linux/fs_event.h

diff --git a/Documentation/filesystems/events.txt b/Documentation/filesystems/events.txt
new file mode 100644
index 0000000..c85dd88
--- /dev/null
+++ b/Documentation/filesystems/events.txt
@@ -0,0 +1,254 @@
+
+	Generic file system event notification interface
+
+Document created 09 April 2015 by Beata Michalska <b.michalska@samsung.com>
+
+1. The reason behind:
+=====================
+
+There are many corner cases when things might get messy with the filesystems.
+And it is not always obvious what and when went wrong. Sometimes you might
+get some subtle hints that there is something going on - but by the time
+you realise it, it might be too late as you are already out-of-space
+or the filesystem has been remounted as read-only (i.e.). The generic
+interface for the filesystem events fills the gap by providing a rather
+easy way of real-time notifications triggered whenever something intreseting
+happens, allowing filesystems to report events in a common way, as they occur.
+
+2. How does it work:
+====================
+
+The interface itself has been exposed as fstrace-type Virtual File System,
+primarily to ease the process of setting up the configuration for the file
+system notifications. So for starters it needs to get mounted (obviously):
+
+	mount -t fstrace none /sys/fs/events
+
+This will unveil the single fstrace filesystem entry - the 'config' file,
+through which the notification are being set-up.
+
+Activating notifications for particular filesystem is as straightforward
+as writing into the 'config' file. Note that by default all events despite
+the actual filesystem type are being disregarded.
+
+Synopsis of config:
+------------------
+
+	MOUNT EVENT_TYPE [L1] [L2]
+
+ MOUNT      : the filesystem's mount point
+ EVENT_TYPE : type of events to be enabled: info,warn,err,thr;
+              at least one type needs to be specified;
+              note the comma delimiter and lack of spaces between
+	      those options
+ L1         : the threshold limit - lower range
+ L2         : the threshold limit - upper range
+ 	      case enabling threshold notifications the lower level is
+	      mandatory, whereas the upper one remains optional;
+	      note though, that as those refer to the number of available
+	      blocks, the lower level needs to be higher than the upper one
+
+Sample request could look like the follwoing:
+
+ echo /sample/mount/point warn,err,thr 710000 500000 > /sys/fs/events/config
+
+Multiple request might be specified provided they are separated with semicolon.
+
+The configuration itself might be modified at any time. One can add/remove
+particilar event types for given fielsystem, modify the threshold levels,
+and remove single or all entries from the 'config' file.
+
+ - Adding new event type:
+
+ $ echo MOUNT EVENT_TYPE > /sys/fs/events/config
+
+(Note that is is enough to provide the eventy type to be enabled without
+the already set ones.)
+
+ - Removing event type:
+
+ $ echo '!MOUNT EVENT_TYPE' > /sys/fs/events/config
+
+ - Updating threshold limits:
+
+ $ echo MOUNT thres L1 L2 > /sys/fs/events/config
+
+ - Removing single entry:
+
+ $ echo '!MOUNT' > /sys/fs/events/config
+
+ - Removing all entries:
+
+ $ echo > /sys/fs/events/config
+
+Reading the file will list all registered entries with their current set-up
+along with some additional info like the id of the entry (@see more on generic
+netlink section), the filesystem type and the backing device name if available.
+
+Final, though a very important note on the configuration: when and if the
+actual events are being triggered falls way beyond the scope of the generic
+filesystem events interface. It is up to a particular filesystem
+implementation which events are to be supported - if any at all. So if
+given filesystem does not support the event notifications, an attempt to
+enable those through 'config' file will fail.
+
+
+3. The generic netlink interface support:
+=========================================
+
+Whenever an event notification is triggered (by given filesystem) the current
+configuration is being validated to decide whether a userpsace notification
+should be launched. If there has been no request (in a mean of 'config' file
+entry) for given event, one will be silently disreagrded. If, on the other
+hand, someone is 'watching' given filesystem for specific events, a generic
+netlink message will be sent.
+
+A dedicated multicast group has been provided solely for the purpose of
+notifying any potential listeners of file system events. So in order to
+receive such notifications, one should subscribe to this new mutlicast group.
+
+Each message type reflects the actual type of generated event (FS_EVENT_TYPE*)
+Currently there are two supported message formats.
+
+There is a common message format representing an event generated by
+a filesystem. The type of the event itself will be stored within
+the generic netlink message header as the command filed. The messge
+payload will provide more detailed info: the indentifier of the filesystem
+trace (genereted upon registering the trace), the backing device major and
+minor numbers, the event identifier and the id of the proccess which action
+led to the event occurance. In case of threshold notifications, the current
+number of available blocks will be included in the payload.
+
+
+	 0                   1                   2                   3
+	 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+	|	            NETLINK MESSAGE HEADER			|
+	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+	| 		GENERIC NETLINK MESSAGE HEADER   		|
+	| 	   (with event type as genlmsghdr cdm field)		|
+	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+	| 	      Optional user specific message header		|
+	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+	| 		   GENERIC MESSAGE PAYLOAD:			|
+	+---------------------------------------------------------------+
+	|  		 FS_EVENT_ATR_FS_ID (NLA_U32)			|
+	+---------------------------------------------------------------+
+	|	  FS_EVENT_ATR_DEV_MAJOR (NLA_U32) (if available)	|
+	+---------------------------------------------------------------+
+	| 	  FS_EVENT_ATR_DEV_MINOR (NLA_U32) (if available)       |
+	+---------------------------------------------------------------+
+	| 		   FS_EVENT_ATR_ID (NLA_U32)			|
+	+---------------------------------------------------------------+
+	|  		FS_EVENT_ATR_CAUSED_ID (NLA_U32)		|
+	+---------------------------------------------------------------+
+	|  		  FS_EVENT_ATR_DATA (NLA_U64)			|
+	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+
+
+The second supported message format represents an event of a new trace being
+registered. It contains two attributes within the payload: the trace id and the
+mount point for which the trace has been registered. This message is of type
+FS_EVENT_TYPE_NEW_TRACE and is being sent regardless the actual event types
+being watched whenever new etnry for the 'config' file is being created. This
+is supposed to ease parsing the messages by userpsace applications and to help
+to identify the origin of the event. It also reduces the size of the payload
+as there is no need to send additional data such as mount point and the file
+system type for each possible event.
+
+	 0                   1                   2                   3
+	 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+	|	            NETLINK MESSAGE HEADER			|
+	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+	| 		GENERIC NETLINK MESSAGE HEADER   		|
+	| 	   (with event type as genlmsghdr cdm field)		|
+	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+	| 	      Optional user specific message header		|
+	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+	| 		   GENERIC MESSAGE PAYLOAD:			|
+	+ ------------------------------------------------------------- +
+	|  		 FS_EVENT_ATR_FS_ID (NLA_U32)			|
+	+ ------------------------------------------------------------- +
+	|  	        FS_EVENT_ATR_MOUNT (NLA_STRING)			|
+	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+
+The above figures are based on:
+ http://www.linuxfoundation.org/collaborate/workgroups/networking/generic_netlink_howto#Message_Format
+
+
+
+4. API Reference:
+=================
+
+ 4.1 Generic file system event interface operations
+
+ #include <linux/fs_event.h>
+
+ struct fs_trace_operations {
+	 int (*fs_trace_query)(struct super_block *, struct fs_trace_sdata *);
+ };
+
+ Each filesystem supporting the event notifications should register its
+ file system trace operations. This can be done through new entry in
+ the super_block structure: the s_trace_ops. The fs_trace_query shall
+ be called whenever new trace entry for given filesystem is being created
+ or when threshold notifications are being requested for the first time.
+ The filesystem should specify then, which event types are being supported.
+ In case of threshold notifications the current number of avaialble blocks
+ should be provided.
+
+ 4.2 Event notification:
+
+ #include <linux/fs_event.h>
+ void fs_event_notify(struct super_block *sb, unsigned int event_type,
+  			unsigned int event_id);
+
+ Notify the generic FS event interface of an occuring event.
+ This shall be used by any file system that wishes to inform any potenial
+ listeners/watchers of a particular event.
+ - sb:         the filesystem's super block
+ - event_type: the type of an event (one of the FS_EVENT_*)
+ - event_id:   an event identifier
+
+ 4.3 Threshold notifications:
+
+ #include <linux/fs_event.h>
+ void fs_event_alloc_space(struct super_block *sb, u64 ncount);
+ void fs_event_free_space(struct super_block *sb, u64 ncount);
+
+ Each filesystme supporting the treshold notifiactions should call
+ fs_event_alloc_space/fs_event_free_space repsectively whenever the
+ ammount of availbale blocks changes.
+ - sb:     the filesystem's super block
+ - ncount: number of blocks being acquired/released
+
+ Note that to properly handle the treshold notifiactions the fs events
+ interface needs to be keept up to date by the filesystems. Each should
+ register fs_trace_operations to enable querying the basic trace data,
+ among which, is the current number of the available blocks (fs_trace_query).
+
+ 4.4 Sending message through generic netlink interface
+
+ #include <linux/fs_event.h>
+ int fs_netlink_send_event(size_t size, unsigned int event_type,
+ 	int (*compose_msg)(struct sk_buff *skb, unsigned int event_id,
+		void *data),
+	unsigned int event_id, void *data);
+
+ Although the fs event interface is fully responsible for sending the messages
+ over the netlink, filesystems might use the FS_EVENT mutlicast group to send
+ their own custom messages.
+ - size:        the size of the message payload
+ - event_type:  the type of an event: stored as message header's command
+ - compose_msg: a custom callback handling composing the message payload
+ - event_id:    the event identifier
+ - data:        message custom data
+
+ Calling fs_netlink_send_event will result in a message being sent through
+ the FS_EVENT muslicast group. Note that the body of the message should be
+ prepared (set-up )by the caller - through compose_msg callback. The message's
+ sk_buff will be allocated on behalf of the caller (thus the size parameter).
+ The compose_msg should only fill the payload with proper data.
+
+
diff --git a/fs/Makefile b/fs/Makefile
index a88ac48..798021d 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -126,3 +126,4 @@ obj-y				+= exofs/ # Multiple modules
 obj-$(CONFIG_CEPH_FS)		+= ceph/
 obj-$(CONFIG_PSTORE)		+= pstore/
 obj-$(CONFIG_EFIVAR_FS)		+= efivarfs/
+obj-y				+= events/
diff --git a/fs/events/Makefile b/fs/events/Makefile
new file mode 100644
index 0000000..58d1454
--- /dev/null
+++ b/fs/events/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the Linux Generic File System Event Interface
+#
+
+obj-y := fs_event.o
+obj-$(CONFIG_NET) += fs_event_netlink.o
diff --git a/fs/events/fs_event.c b/fs/events/fs_event.c
new file mode 100644
index 0000000..8ebe371
--- /dev/null
+++ b/fs/events/fs_event.c
@@ -0,0 +1,775 @@
+/*
+ * Generic File System Events Interface
+ *
+ * Copyright(c) 2015 Samsung Electronics. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called COPYING.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
+ * more details.
+ */
+#include <linux/fs.h>
+#include <linux/hashtable.h>
+#include <linux/idr.h>
+#include <linux/module.h>
+#include <linux/mount.h>
+#include <linux/namei.h>
+#include <linux/parser.h>
+#include <linux/seq_file.h>
+#include <linux/slab.h>
+#include <net/genetlink.h>
+#include "../mount.h"
+#include "fs_event.h"
+
+#define FS_HASHTB_BITS		8
+#define FS_HASHTB_SIZE		(1 << FS_HASHTB_BITS)
+
+/**
+ * The FS event trace entries are being stored in a hashtable
+ * for fast entry look-up, and in a doubly-linked list
+ * to ease all the paths that need to go through all
+ * the entries.
+ */
+static DEFINE_HASHTABLE(fs_trace_hashtbl, FS_HASHTB_BITS);
+static LIST_HEAD(fs_trace_list);
+static DEFINE_SPINLOCK(fs_trace_lock);
+
+static struct kmem_cache *fs_trace_cachep __read_mostly;
+
+/*
+ * Each registered FS event trace is being marked with
+ * a unique identifier managed by IDR
+ */
+static struct idr fs_trace_idr;
+static DEFINE_SPINLOCK(fs_trace_idr_lock);
+
+/*
+ * Threshold notification state bits.
+ * Note the reverse as this refers to the number
+ * of available blocks.
+ */
+#define THRESH_LR_BELOW		0x0001 /* Falling below the lower range */
+#define THRESH_LR_BEYOND	0x0002
+#define THRESH_UR_BELOW		0x0004
+#define THRESH_UR_BEYOND	0x0008 /* Going beyond the upper range */
+
+#define THRESH_LR_ON	(THRESH_LR_BELOW | THRESH_LR_BEYOND)
+#define THRESH_UR_ON	(THRESH_UR_BELOW | THRESH_UR_BEYOND)
+
+#define FS_TRACE_ADD	0x100000
+
+struct fs_trace_entry {
+	struct list_head	node;
+	struct hlist_node	hnode;
+	struct path		path;
+	struct fs_trace_sdata	data;
+	int			mark;
+	unsigned int		notify_mask;
+	struct fs_event_thresh {
+		u64		lrange;
+		u64		urange;
+		unsigned int	state;
+	}			thresh;
+	spinlock_t		lock;
+};
+
+static const match_table_t fs_etypes = {
+	{ FS_EVENT_INFO,    "info"  },
+	{ FS_EVENT_WARN,    "warn"  },
+	{ FS_EVENT_THRESH,  "thr"   },
+	{ FS_EVENT_ERR,     "err"   },
+	{ 0, NULL },
+};
+
+#define fs_trace_sb(en) ((en)->path.mnt->mnt_sb)
+
+#define fs_trace_query_data(sb, arg)				 \
+	(((sb)->s_trace_ops && (sb)->s_trace_ops->fs_trace_query) ? \
+	(sb)->s_trace_ops->fs_trace_query((sb), arg) : -EINVAL)
+
+#define fs_event_type_cast(event_type)  (ffs(event_type))
+
+static inline unsigned int fs_trace_hasfn(const struct super_block *sb)
+{
+	return ((unsigned long)sb >> L1_CACHE_SHIFT) & (FS_HASHTB_SIZE - 1);
+}
+
+static struct fs_trace_entry *fs_find_trace_entry(struct super_block *sb)
+{
+	struct fs_trace_entry *en;
+	unsigned long hash;
+
+	if (list_empty(&fs_trace_list))
+		return ERR_PTR(-EINVAL);
+	hash = fs_trace_hasfn(sb);
+	hash_for_each_possible(fs_trace_hashtbl, en, hnode, hash)
+		if (fs_trace_sb(en) == sb)
+			return en;
+	return ERR_PTR(-EINVAL);
+}
+
+static inline void fs_trace_entry_list_del(struct fs_trace_entry *en)
+{
+	spin_lock(&en->lock);
+	list_del(&en->node);
+	hash_del(&en->hnode);
+	spin_unlock(&en->lock);
+}
+
+static inline void fs_trace_entry_idr_remove(struct fs_trace_entry *en)
+{
+	spin_lock(&fs_trace_idr_lock);
+	idr_remove(&fs_trace_idr, en->mark);
+	spin_unlock(&fs_trace_idr_lock);
+}
+
+static inline void fs_trace_entry_free(struct fs_trace_entry *en)
+{
+	kmem_cache_free(fs_trace_cachep, en);
+}
+
+static inline void fs_destroy_trace_entry(struct fs_trace_entry *en)
+{
+	fs_trace_entry_list_del(en);
+	fs_trace_entry_idr_remove(en);
+	fs_trace_entry_free(en);
+}
+
+static int fs_remove_trace_entry(struct super_block *sb)
+{
+	struct fs_trace_entry *en;
+	int ret = -EINVAL;
+
+	spin_lock(&fs_trace_lock);
+	en = fs_find_trace_entry(sb);
+	if (!IS_ERR(en)) {
+		fs_destroy_trace_entry(en);
+		ret = 0;
+	}
+	spin_unlock(&fs_trace_lock);
+	return ret;
+}
+
+static void fs_remove_all_traces(void)
+{
+	struct fs_trace_entry *en, *guard;
+
+	spin_lock(&fs_trace_lock);
+	list_for_each_entry_safe(en, guard, &fs_trace_list, node)
+		fs_destroy_trace_entry(en);
+	spin_unlock(&fs_trace_lock);
+}
+
+static int fs_event_new_trace_create_msg(struct sk_buff *skb,
+				unsigned int event_id, void *data)
+{
+	struct fs_trace_entry *en = (struct fs_trace_entry *)data;
+	char *path, *mount_dir;
+	int ret;
+
+	path = kzalloc(PATH_MAX, GFP_KERNEL);
+	if (!path)
+		return -EINVAL;
+	mount_dir = d_path(&en->path, path, PATH_MAX - 1);
+	if (IS_ERR(mount_dir))
+		mount_dir = "unknown";
+
+	ret = nla_put_u32(skb, FS_EVENT_ATR_FS_ID, en->mark);
+	if (ret)
+		goto leave;
+	ret = nla_put_string(skb, FS_EVENT_ATR_MOUNT, mount_dir);
+
+leave:
+	kfree(path);
+	return ret;
+}
+
+static int fs_event_common_create_msg(struct sk_buff *skb,
+				unsigned int event_id, void *data)
+{
+	struct fs_trace_entry *en = (struct fs_trace_entry *)data;
+	struct super_block *sb = fs_trace_sb(en);
+
+	if (nla_put_u32(skb, FS_EVENT_ATR_FS_ID, en->mark))
+		return -EINVAL;
+
+	/* In case there is no backing dev, so skip the followng */
+	if (sb->s_bdev && MAJOR(sb->s_dev))
+		if (nla_put_u32(skb, FS_EVENT_ATR_DEV_MAJOR, MAJOR(sb->s_dev))
+		||  nla_put_u32(skb, FS_EVENT_ATR_DEV_MINOR, MINOR(sb->s_dev)))
+			return -EINVAL;
+
+	if (nla_put_u32(skb, FS_EVENT_ATR_ID, event_id))
+		return -EINVAL;
+	if (nla_put_u64(skb, FS_EVENT_ATR_CAUSED_ID, pid_nr(task_pid(current))))
+		return -EINVAL;
+
+	if (event_id & (FS_THRESH_LR_REACHED | FS_THRESH_UR_REACHED))
+		return nla_put_u64(skb, FS_EVENT_ATR_DATA,
+					en->data.available_blks);
+
+	return 0;
+}
+
+static void fs_event_new_trace(struct fs_trace_entry *en)
+{
+	fs_netlink_send_event(GENLMSG_DEFAULT_SIZE, FS_EVENT_TYPE_NEW_TRACE,
+				fs_event_new_trace_create_msg, 0, en);
+}
+
+static void fs_event_send(struct fs_trace_entry *en,
+			  unsigned int event_type, unsigned int event_id)
+{
+	size_t size = nla_total_size(sizeof(u32)) * 4 +
+		      nla_total_size(sizeof(u64)) * 2;
+
+	fs_netlink_send_event(size, fs_event_type_cast(event_type),
+				fs_event_common_create_msg, event_id, en);
+}
+
+void fs_event_notify(struct super_block *sb, unsigned int event_type,
+				unsigned int event_id)
+{
+	struct fs_trace_entry *en;
+
+	spin_lock(&fs_trace_lock);
+	en = fs_find_trace_entry(sb);
+	if (IS_ERR(en)) {
+		spin_unlock(&fs_trace_lock);
+		return;
+	}
+
+	spin_lock(&en->lock);
+	/* Relase the main lock - it's enough to keep the entry lock here */
+	spin_unlock(&fs_trace_lock);
+	if (en->notify_mask & event_type)
+		fs_event_send(en, event_type, event_id);
+	spin_unlock(&en->lock);
+}
+EXPORT_SYMBOL(fs_event_notify);
+
+void fs_event_alloc_space(struct super_block *sb, u64 ncount)
+{
+	struct fs_trace_entry *en;
+	s64 count;
+
+	spin_lock(&fs_trace_lock);
+	en = fs_find_trace_entry(sb);
+	if (IS_ERR(en)) {
+		spin_unlock(&fs_trace_lock);
+		return;
+	}
+
+	spin_lock(&en->lock);
+	spin_unlock(&fs_trace_lock);
+
+	if (!(en->notify_mask & FS_EVENT_THRESH))
+		goto leave;
+	/* we shouldn't drop below 0 here, unless there is a sync issue
+	  somewhere (?) */
+	count = en->data.available_blks - ncount;
+	en->data.available_blks = count < 0 ? 0 : count;
+
+	if (en->data.available_blks > en->thresh.lrange)
+		/* Not 'even' close - leave */
+		goto leave;
+
+	if (en->data.available_blks > en->thresh.urange) {
+		/* Close enough - the lower range has been reached */
+		if (!(en->thresh.state & THRESH_LR_BEYOND)) {
+			/* Send notificaton */
+			fs_event_send(en, FS_EVENT_THRESH,
+				FS_THRESH_LR_REACHED);
+			en->thresh.state &= ~THRESH_LR_BELOW;
+			en->thresh.state |= THRESH_LR_BEYOND;
+		}
+		goto leave;
+	}
+	if (!(en->thresh.state & THRESH_UR_BEYOND)) {
+		fs_event_send(en, FS_EVENT_THRESH, FS_THRESH_UR_REACHED);
+		en->thresh.state &=  ~THRESH_UR_BELOW;
+		en->thresh.state |= THRESH_UR_BEYOND;
+	}
+
+leave:
+	spin_unlock(&en->lock);
+}
+EXPORT_SYMBOL(fs_event_alloc_space);
+
+void fs_event_free_space(struct super_block *sb, u64 ncount)
+{
+	struct fs_trace_entry *en;
+
+	spin_lock(&fs_trace_lock);
+	en = fs_find_trace_entry(sb);
+	if (IS_ERR(en)) {
+		spin_unlock(&fs_trace_lock);
+		return;
+	}
+
+	spin_lock(&en->lock);
+	spin_unlock(&fs_trace_lock);
+
+	if (!(en->notify_mask & FS_EVENT_THRESH))
+		goto leave;
+
+	en->data.available_blks += ncount;
+
+	if (en->data.available_blks > en->thresh.lrange) {
+		if (!(en->thresh.state & THRESH_LR_BELOW)
+		&& en->thresh.state & THRESH_LR_BEYOND) {
+			/* Send notificaton */
+			fs_event_send(en, FS_EVENT_THRESH,
+				FS_THRESH_LR_REACHED);
+			en->thresh.state &= ~THRESH_LR_BEYOND;
+			en->thresh.state |= THRESH_LR_BELOW;
+			goto leave;
+		}
+	}
+	if (en->data.available_blks > en->thresh.urange) {
+		if (!(en->thresh.state & THRESH_UR_BELOW)
+		&& en->thresh.state & THRESH_UR_BEYOND) {
+			/* Notify */
+			fs_event_send(en, FS_EVENT_THRESH,
+					FS_THRESH_UR_REACHED);
+			en->thresh.state &= ~THRESH_UR_BEYOND;
+			en->thresh.state |= THRESH_UR_BELOW;
+		}
+	}
+leave:
+	spin_unlock(&en->lock);
+}
+EXPORT_SYMBOL(fs_event_free_space);
+
+void fs_event_mount_dropped(struct vfsmount *mnt)
+{
+	struct fs_trace_entry *en;
+
+	spin_lock(&fs_trace_lock);
+	en = fs_find_trace_entry(mnt->mnt_sb);
+	if (!IS_ERR(en)) {
+		spin_lock(&en->lock);
+		if (en->notify_mask & FS_EVENT_INFO)
+			fs_event_send(en, FS_EVENT_TYPE_INFO, FS_INFO_UMOUNT);
+		spin_unlock(&en->lock);
+		fs_destroy_trace_entry(en);
+	}
+	spin_unlock(&fs_trace_lock);
+}
+
+static int fs_new_trace_entry(struct path *path, struct fs_event_thresh *thresh,
+				unsigned int nmask)
+{
+	struct fs_trace_entry *en;
+	struct super_block *sb;
+	struct mount *r_mnt;
+
+	en = kmem_cache_zalloc(fs_trace_cachep, GFP_KERNEL);
+	if (unlikely(!en))
+		return -ENOMEM;
+	/*
+	 * Note that no reference is being taken here for the path as it would
+	 * make the umount unnecessarily puzzling (due to an extra 'valid'
+	 * reference for the mnt).
+	 * This is *rather* safe as the notification on mount being dropped
+	 * will get called prior to releasing the super block - so right
+	 * in time to send the event and perform appropraite clean-up
+	 */
+	r_mnt = real_mount(path->mnt);
+	en->path.dentry = r_mnt->mnt.mnt_root;
+	en->path.mnt = &r_mnt->mnt;
+
+	sb = fs_trace_sb(en);
+	spin_lock_init(&en->lock);
+
+	spin_lock(&fs_trace_idr_lock);
+	idr_preload(GFP_KERNEL);
+	en->mark = idr_alloc_cyclic(&fs_trace_idr, en, 1, 0, GFP_KERNEL);
+	idr_preload_end();
+	spin_unlock(&fs_trace_idr_lock);
+
+	if (en->mark < 0)
+		goto leave;
+	if (fs_trace_query_data(sb, &en->data))
+		goto leave;
+
+	nmask = en->data.events_cap_mask & nmask;
+	if (!nmask)
+		goto leave;
+	en->notify_mask = nmask;
+	memcpy(&en->thresh, thresh, offsetof(struct fs_event_thresh, state));
+
+	spin_lock(&fs_trace_lock);
+	list_add(&en->node, &fs_trace_list);
+	hash_add(fs_trace_hashtbl, &en->hnode, fs_trace_hasfn(sb));
+	spin_unlock(&fs_trace_lock);
+
+	fs_event_new_trace(en);
+	return 0;
+leave:
+	kmem_cache_free(fs_trace_cachep, en);
+	return -EINVAL;
+}
+
+static int fs_update_trace_entry_locked(struct fs_trace_entry *en,
+				   struct fs_event_thresh *thresh,
+				    unsigned int nmask)
+{
+	int extend = nmask & FS_TRACE_ADD;
+
+	nmask &= en->data.events_cap_mask;
+	if (!nmask)
+		return -EINVAL;
+
+	if (nmask & FS_EVENT_THRESH) {
+		if (extend) {
+			/* Get the current state */
+			if (!(en->notify_mask & FS_EVENT_THRESH))
+				fs_trace_query_data(fs_trace_sb(en),
+						&en->data);
+			if (thresh->state & THRESH_LR_ON) {
+				en->thresh.lrange = thresh->lrange;
+				en->thresh.state &= ~THRESH_LR_ON;
+			}
+			if (thresh->state & THRESH_UR_ON) {
+				en->thresh.urange = thresh->urange;
+				en->thresh.state &= ~THRESH_UR_ON;
+			}
+		} else {
+			memset(&en->thresh, 0, sizeof(en->thresh));
+		}
+	}
+
+	if (extend)
+		en->notify_mask |= nmask;
+	else
+		en->notify_mask &= ~nmask;
+	return 0;
+}
+
+static int fs_update_trace_entry(struct path *path,
+				  struct fs_event_thresh *thresh,
+				  unsigned int nmask)
+{
+	struct fs_trace_entry *en;
+	int ret;
+
+	spin_lock(&fs_trace_lock);
+	en = fs_find_trace_entry(path->mnt->mnt_sb);
+	if (IS_ERR(en)) {
+		spin_unlock(&fs_trace_lock);
+		return (nmask & FS_TRACE_ADD)
+			?  fs_new_trace_entry(path, thresh, nmask)
+			: -EINVAL;
+	}
+	spin_lock(&en->lock);
+	spin_unlock(&fs_trace_lock);
+
+	ret = fs_update_trace_entry_locked(en, thresh, nmask);
+
+	spin_unlock(&en->lock);
+	return ret;
+}
+
+static int fs_parse_trace_request(int argc, char **argv)
+{
+	struct fs_event_thresh thresh = {0};
+	struct path path;
+	substring_t args[MAX_OPT_ARGS];
+	unsigned int nmask = FS_TRACE_ADD;
+	int token;
+	char *s;
+	int ret = -EINVAL;
+
+	if (!argc) {
+		fs_remove_all_traces();
+		return 0;
+	}
+
+	s = *(argv++);
+	if (*s == '!') {
+		/* Clear the trace entry */
+		nmask &= ~FS_TRACE_ADD;
+		++s;
+	}
+
+	if (kern_path_mountpoint(AT_FDCWD, s, &path, LOOKUP_FOLLOW))
+		return -EINVAL;
+
+	if (!(--argc)) {
+		if (!(nmask & FS_TRACE_ADD))
+			ret = fs_remove_trace_entry(path.mnt->mnt_sb);
+		goto leave;
+	}
+
+	while ((s = strsep(argv, ",")) != NULL) {
+		if (!*s)
+			continue;
+		args[0].to = args[0].from = NULL;
+		token = match_token(s, fs_etypes, args);
+		nmask |= (token & FS_EVENTS_ALL);
+	}
+
+	if (!(nmask & (~FS_TRACE_ADD)) ||
+	(!(--argc) && (nmask & FS_EVENT_THRESH && nmask & FS_TRACE_ADD)))
+		goto leave;
+
+	if ((nmask & FS_EVENT_THRESH) && (nmask & FS_TRACE_ADD)) {
+		/*
+		 * Get the threshold config data:
+		 * lower range
+		 * upper range
+		 */
+		ret = kstrtoull(*(++argv), 10, &thresh.lrange);
+		if (ret)
+			goto leave;
+
+		thresh.state |= THRESH_LR_ON;
+
+		if ((--argc)) {
+			ret = kstrtoull(*(++argv), 10, &thresh.urange);
+			if (ret)
+				goto leave;
+			thresh.state |= THRESH_UR_ON;
+		}
+		/* The thresholds are based on number of available blocks */
+		if (thresh.lrange < thresh.urange) {
+			ret = -EINVAL;
+			goto leave;
+		}
+
+	}
+	ret = fs_update_trace_entry(&path, &thresh, nmask);
+leave:
+	path_put(&path);
+	return ret;
+}
+
+#define DEFAULT_BUF_SIZE PAGE_SIZE
+
+static ssize_t fs_trace_write(struct file *file, const char __user *buffer,
+				size_t count, loff_t *ppos)
+{
+	char **argv;
+	char *kern_buf, *next, *cfg;
+	size_t size, dcount = 0;
+	int argc;
+
+	if (!count)
+		return 0;
+
+	kern_buf = kmalloc(DEFAULT_BUF_SIZE, GFP_KERNEL);
+	if (!kern_buf)
+		return -ENOMEM;
+
+	while (dcount < count) {
+
+		size = count - dcount;
+		if (size >= DEFAULT_BUF_SIZE)
+			size = DEFAULT_BUF_SIZE - 1;
+		if (copy_from_user(kern_buf, buffer + dcount, size)) {
+			dcount = -EINVAL;
+			goto leave;
+		}
+
+		kern_buf[size] = '\0';
+
+		next = cfg = kern_buf;
+
+		do {
+			next = strchr(cfg, ';');
+			if (next)
+				*next = '\0';
+
+			argv = argv_split(GFP_KERNEL, cfg, &argc);
+			if (!argv) {
+				dcount = -ENOMEM;
+				goto leave;
+			}
+
+			if (fs_parse_trace_request(argc, argv)) {
+				dcount = -EINVAL;
+				argv_free(argv);
+				goto leave;
+			}
+
+			argv_free(argv);
+			if (next)
+				cfg = ++next;
+
+		} while (next);
+		dcount += size;
+	}
+leave:
+	kfree(kern_buf);
+	return dcount;
+}
+
+static void *fs_trace_seq_start(struct seq_file *m, loff_t *pos)
+{
+	spin_lock(&fs_trace_lock);
+	return seq_list_start(&fs_trace_list, *pos);
+}
+
+static void *fs_trace_seq_next(struct seq_file *m, void *v, loff_t *pos)
+{
+	return seq_list_next(v, &fs_trace_list, pos);
+}
+
+static void fs_trace_seq_stop(struct seq_file *m, void *v)
+{
+	spin_unlock(&fs_trace_lock);
+}
+
+static int fs_trace_seq_show(struct seq_file *m, void *v)
+{
+	struct fs_trace_entry *en;
+	struct super_block *sb;
+	struct mount *r_mnt;
+	const struct match_token *match;
+	unsigned int nmask;
+
+	en = list_entry(v, struct fs_trace_entry, node);
+	sb = fs_trace_sb(en);
+
+	seq_printf(m, "%d ", en->mark);
+
+	seq_path(m, &en->path, "\t\n\\");
+	seq_putc(m, ' ');
+
+	seq_escape(m, sb->s_type->name, " \t\n\\");
+	if (sb->s_subtype && sb->s_subtype[0]) {
+		seq_putc(m, '.');
+		seq_escape(m, sb->s_subtype, " \t\n\\");
+	}
+
+	seq_putc(m, ' ');
+	if (sb->s_op->show_devname) {
+		sb->s_op->show_devname(m, en->path.mnt->mnt_root);
+	} else {
+		r_mnt = real_mount(en->path.mnt);
+		seq_escape(m, r_mnt->mnt_devname ? r_mnt->mnt_devname : "none",
+				" \t\n\\");
+	}
+	seq_puts(m, " (");
+
+	nmask = en->notify_mask;
+	for (match = fs_etypes; match->pattern; ++match) {
+		if (match->token & nmask) {
+			seq_puts(m, match->pattern);
+			nmask &= ~match->token;
+			if (nmask)
+				seq_putc(m, ',');
+		}
+	}
+	seq_printf(m, " %llu %llu", en->thresh.lrange,
+			en->thresh.urange);
+	seq_puts(m, ")\n");
+	return 0;
+}
+
+static const struct seq_operations fs_trace_seq_ops = {
+	.start	= fs_trace_seq_start,
+	.next	= fs_trace_seq_next,
+	.stop	= fs_trace_seq_stop,
+	.show	= fs_trace_seq_show,
+};
+
+static int fs_trace_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &fs_trace_seq_ops);
+}
+
+static const struct file_operations fs_trace_fops = {
+	.owner		= THIS_MODULE,
+	.open		= fs_trace_open,
+	.write		= fs_trace_write,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
+static int fs_trace_init(void)
+{
+	fs_trace_cachep = KMEM_CACHE(fs_trace_entry, 0);
+	if (!fs_trace_cachep)
+		return -EINVAL;
+	if (!fs_event_netlink_register()) {
+		idr_init(&fs_trace_idr);
+		return 0;
+	}
+	kmem_cache_destroy(fs_trace_cachep);
+	return -EINVAL;
+}
+
+/* VFS support */
+static int fs_trace_fill_super(struct super_block *sb, void *data, int silent)
+{
+	int ret;
+	static struct tree_descr desc[] = {
+		[2] = {
+			.name	= "config",
+			.ops	= &fs_trace_fops,
+			.mode	= S_IWUSR | S_IRUGO,
+		},
+		{""},
+	};
+
+	ret = simple_fill_super(sb, 0x7246332, desc);
+	return !ret ? fs_trace_init() : ret;
+}
+
+static struct dentry *fs_trace_do_mount(struct file_system_type *fs_type,
+		 int ntype, const char *dev_name, void *data)
+{
+	return mount_single(fs_type, ntype, data, fs_trace_fill_super);
+}
+
+static void fs_trace_kill_super(struct super_block *sb)
+{
+	fs_remove_all_traces();
+	idr_destroy(&fs_trace_idr);
+	fs_event_netlink_unregister();
+	kmem_cache_destroy(fs_trace_cachep);
+	kill_litter_super(sb);
+}
+
+static struct kset	*fs_trace_kset;
+static struct vfsmount	*fs_trace_mount;
+
+static struct file_system_type fs_trace_fstype = {
+	.name		= "fstrace",
+	.mount		= fs_trace_do_mount,
+	.kill_sb	= fs_trace_kill_super,
+};
+
+static void __init fs_trace_vfs_init(void)
+{
+	fs_trace_kset = kset_create_and_add("events", NULL, fs_kobj);
+
+	if (!fs_trace_kset)
+		return;
+
+	if (!register_filesystem(&fs_trace_fstype)) {
+		fs_trace_mount = kern_mount(&fs_trace_fstype);
+		if (!IS_ERR(fs_trace_mount))
+			return;
+
+		unregister_filesystem(&fs_trace_fstype);
+	}
+	kset_unregister(fs_trace_kset);
+}
+
+static int __init fs_trace_events_init(void)
+{
+	fs_trace_vfs_init();
+	return 0;
+};
+module_init(fs_trace_events_init);
+
diff --git a/fs/events/fs_event.h b/fs/events/fs_event.h
new file mode 100644
index 0000000..4260ce5
--- /dev/null
+++ b/fs/events/fs_event.h
@@ -0,0 +1,27 @@
+/*
+ * Copyright(c) 2015 Samsung Electronics. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called COPYING.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
+ * more details.
+ */
+
+#ifndef __GENERIC_FS_EVENTS_H
+#define __GENERIC_FS_EVENTS_H
+
+#ifdef CONFIG_NET
+int  fs_event_netlink_register(void);
+void fs_event_netlink_unregister(void);
+#else /* CONFIG_NET */
+static inline int  fs_event_netlink_register(void) { return -ENOSYS; }
+static inline void fs_event_netlink_unregister(void) {};
+#endif /* CONFIG_NET */
+
+#endif /* __GENERIC_FS_EVENTS_H */
diff --git a/fs/events/fs_event_netlink.c b/fs/events/fs_event_netlink.c
new file mode 100644
index 0000000..9c56e35
--- /dev/null
+++ b/fs/events/fs_event_netlink.c
@@ -0,0 +1,94 @@
+/*
+ * Copyright(c) 2015 Samsung Electronics. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called COPYING.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
+ * more details.
+ */
+#include <linux/fs.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <net/netlink.h>
+#include <net/genetlink.h>
+
+static const struct genl_multicast_group fs_event_mcgroups[] = {
+	{ .name = "event", },
+};
+
+static struct genl_family fs_event_family = {
+	.id		= GENL_ID_FS_EVENT,
+	.hdrsize	= 0,
+	.name		= "FS_EVENT",
+	.version	= 1,
+	.maxattr	= FS_EVENT_ATR_MAX,
+	.mcgrps		= fs_event_mcgroups,
+	.n_mcgrps	= ARRAY_SIZE(fs_event_mcgroups),
+};
+
+int fs_netlink_send_event(size_t size, unsigned int event_type,
+		int (*compose_msg)(struct sk_buff *skb,
+			unsigned int event_id, void *data),
+		unsigned int event_id, void *data)
+{
+	static atomic_t seq;
+	struct sk_buff *skb;
+	void *msg_head;
+	int ret = 0;
+
+	if (!size || !compose_msg)
+		return -EINVAL;
+
+	size += nla_total_size(sizeof(u64));
+	skb = genlmsg_new(size, GFP_NOFS);
+
+	if (!skb) {
+		pr_err("Failed to allocate new FS generic netlink message\n");
+		return -ENOMEM;
+	}
+
+	msg_head = genlmsg_put(skb, 0, atomic_add_return(1, &seq),
+			&fs_event_family, 0, event_type);
+	if (!msg_head)
+		goto cleanup;
+
+	ret = compose_msg(skb, event_id, data);
+	if (ret) {
+		genlmsg_cancel(skb, msg_head);
+		goto cleanup;
+	}
+
+	genlmsg_end(skb, msg_head);
+	ret = genlmsg_multicast(&fs_event_family, skb, 0, 0, GFP_NOWAIT);
+	if (ret && ret != -ENOBUFS && ret != -ESRCH)
+		goto cleanup;
+
+	return ret;
+cleanup:
+	nlmsg_free(skb);
+	return ret;
+}
+EXPORT_SYMBOL(fs_netlink_send_event);
+
+int fs_event_netlink_register(void)
+{
+	int ret;
+
+	ret = genl_register_family(&fs_event_family);
+	if (ret)
+		pr_err("Failed to register FS netlink interface\n");
+	return ret;
+}
+
+void fs_event_netlink_unregister(void)
+{
+	genl_unregister_family(&fs_event_family);
+}
diff --git a/fs/namespace.c b/fs/namespace.c
index 82ef140..ec6e2ef 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1031,6 +1031,7 @@ static void cleanup_mnt(struct mount *mnt)
 	if (unlikely(mnt->mnt_pins.first))
 		mnt_pin_kill(mnt);
 	fsnotify_vfsmount_delete(&mnt->mnt);
+	fs_event_mount_dropped(&mnt->mnt);
 	dput(mnt->mnt.mnt_root);
 	deactivate_super(mnt->mnt.mnt_sb);
 	mnt_free_id(mnt);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b4d71b5..bb529af 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -263,6 +263,10 @@ struct iattr {
  * Includes for diskquotas.
  */
 #include <linux/quota.h>
+/*
+ * Include for Generic File System Events Interface
+ */
+#include <linux/fs_event.h>
 
 /*
  * Maximum number of layers of fs stack.  Needs to be limited to
@@ -1233,6 +1237,7 @@ struct super_block {
 	const struct dquot_operations	*dq_op;
 	const struct quotactl_ops	*s_qcop;
 	const struct export_operations *s_export_op;
+	const struct fs_trace_operations *s_trace_ops;
 	unsigned long		s_flags;
 	unsigned long		s_magic;
 	struct dentry		*s_root;
@@ -1253,7 +1258,6 @@ struct super_block {
 	struct hlist_node	s_instances;
 	unsigned int		s_quota_types;	/* Bitmask of supported quota types */
 	struct quota_info	s_dquot;	/* Diskquota specific options */
-
 	struct sb_writers	s_writers;
 
 	char s_id[32];				/* Informational name */
diff --git a/include/linux/fs_event.h b/include/linux/fs_event.h
new file mode 100644
index 0000000..1e128d8
--- /dev/null
+++ b/include/linux/fs_event.h
@@ -0,0 +1,69 @@
+/*
+ * Generic File System Events Interface
+ *
+ * Copyright(c) 2015 Samsung Electronics. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called COPYING.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
+ * more details.
+ */
+#ifndef _LINUX_GENERIC_FS_EVETS_
+#define _LINUX_GENERIC_FS_EVETS_
+#include <net/netlink.h>
+#include <uapi/linux/fs_event.h>
+
+/*
+ * Those event flags match the event types send though the netlink interface
+ * so mind in case making any modifications.
+ */
+#define FS_EVENT_INFO	0x001
+#define FS_EVENT_WARN	0x002
+#define FS_EVENT_ERR	0x004
+#define FS_EVENT_THRESH	0x008
+
+#define FS_EVENTS_ALL \
+	(FS_EVENT_INFO | FS_EVENT_WARN | FS_EVENT_THRESH | FS_EVENT_ERR)
+
+struct fs_trace_sdata {
+	/* Supported notification types */
+	unsigned int	events_cap_mask;
+	/* Number of available/reachable blocks */
+	u64		available_blks;
+};
+
+struct fs_trace_operations {
+	int (*fs_trace_query)(struct super_block *, struct fs_trace_sdata *);
+};
+
+
+void fs_event_notify(struct super_block *sb, unsigned int event_type,
+		     unsigned int event_id);
+void fs_event_alloc_space(struct super_block *sb, u64 ncount);
+void fs_event_free_space(struct super_block *sb, u64 ncount);
+void fs_event_mount_dropped(struct vfsmount *mnt);
+
+#ifdef CONFIG_NET
+int fs_netlink_send_event(size_t size, unsigned int event_type,
+		int (*compose_msg)(struct sk_buff *skb, unsigned int event_id,
+		void *data),
+		unsigned int event_id, void *data);
+#else /* CONFIG_NET */
+static inline
+int fs_netlink_send_event(size_t size, unsigned int event_type,
+		int (*compose_msg)(struct sk_buff *skb, unsigned int event_id,
+		void *data),
+		unsigned int event_idid, void *data)
+{
+	return -ENOSYS;
+}
+#endif /* CONFIG_NET */
+
+#endif /* _LINUX_GENERIC_FS_EVENTS_ */
+
diff --git a/include/uapi/linux/fs_event.h b/include/uapi/linux/fs_event.h
new file mode 100644
index 0000000..dd79953
--- /dev/null
+++ b/include/uapi/linux/fs_event.h
@@ -0,0 +1,62 @@
+/*
+ * Generic netlink support for  Generic File System Events Interface
+ *
+ * Copyright(c) 2015 Samsung Electronics. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called COPYING.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
+ * more details.
+ */
+#ifndef _UAPI_LINUX_GENERIC_FS_EVENTS_
+#define _UAPI_LINUX_GENERIC_FS_EVENTS_
+/*
+ * Generic FS event types
+ */
+enum {
+	FS_EVENT_TYPE_NONE,
+	FS_EVENT_TYPE_INFO,
+	FS_EVENT_TYPE_WARN,
+	FS_EVENT_TYPE_ERR,
+	FS_EVENT_TYPE_THRESH,
+	FS_EVENT_TYPE_NEW_TRACE,
+	__FS_EVENT_TYPE_MAX,
+};
+#define FS_EVENT_TYPE_MAX (__FS_EVENT_TYPE_MAX - 1)
+/*
+ * Generic netlink attribute types
+ */
+enum {
+	FS_EVENT_ATR_NONE,
+	FS_EVENT_ATR_FS_ID,	/* An identifier of traced fs */
+	FS_EVENT_ATR_MOUNT,	/* Mount point directory name */
+	FS_EVENT_ATR_DEV_MAJOR,
+	FS_EVENT_ATR_DEV_MINOR,
+	FS_EVENT_ATR_ID,
+	FS_EVENT_ATR_CAUSED_ID,
+	FS_EVENT_ATR_DATA,
+	__FS_EVENT_ATR_MAX,
+};
+#define FS_EVENT_ATR_MAX (__FS_EVENT_ATR_MAX - 1)
+
+/*
+ * Supported set of FS events ids
+ */
+#define FS_INFO_UMOUNT		0x00000001	/* File system unmounted */
+#define FS_WARN_UNKNOWN		0x00000004	/* Unknown warning */
+#define FS_WARN_ENOSPC		0x00000008	/* No space left to reserve data blks */
+#define FS_WANR_ENOSPC_META	0x00000010	/* No space left for metadata */
+#define FS_THRESH_LR_REACHED	0x00000020	/* The lower range of threshold has been reached */
+#define FS_THRESH_UR_REACHED	0x00000040	/* The upper range of threshold has been reached */
+#define FS_ERR_UNKNOWN		0x00000080	/* Unknown error */
+#define FS_ERR_RO_REMOUT	0x00000100	/* The file system has been remounted as red-only */
+#define FS_ERR_ITERNAL		0x00000200	/* File system's internal error */
+
+#endif /* _UAPI_LINUX_GENERIC_FS_EVENTS_ */
+
diff --git a/include/uapi/linux/genetlink.h b/include/uapi/linux/genetlink.h
index c3363ba..6464129 100644
--- a/include/uapi/linux/genetlink.h
+++ b/include/uapi/linux/genetlink.h
@@ -29,6 +29,7 @@ struct genlmsghdr {
 #define GENL_ID_CTRL		NLMSG_MIN_TYPE
 #define GENL_ID_VFS_DQUOT	(NLMSG_MIN_TYPE + 1)
 #define GENL_ID_PMCRAID		(NLMSG_MIN_TYPE + 2)
+#define GENL_ID_FS_EVENT	(NLMSG_MIN_TYPE + 3)
 
 /**************************************************************************
  * Controller
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 2ed5f96..e8e0bd68 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -82,7 +82,8 @@ static struct list_head family_ht[GENL_FAM_TAB_SIZE];
  */
 static unsigned long mc_group_start = 0x3 | BIT(GENL_ID_CTRL) |
 				      BIT(GENL_ID_VFS_DQUOT) |
-				      BIT(GENL_ID_PMCRAID);
+				      BIT(GENL_ID_PMCRAID) |
+				      BIT(GENL_ID_FS_EVENT);
 static unsigned long *mc_groups = &mc_group_start;
 static unsigned long mc_groups_longs = 1;
 
@@ -146,6 +147,7 @@ static u16 genl_generate_id(void)
 	for (i = 0; i <= GENL_MAX_ID - GENL_MIN_ID; i++) {
 		if (id_gen_idx != GENL_ID_VFS_DQUOT &&
 		    id_gen_idx != GENL_ID_PMCRAID &&
+		    id_gen_idx != GENL_ID_FS_EVENT &&
 		    !genl_family_find_byid(id_gen_idx))
 			return id_gen_idx;
 		if (++id_gen_idx > GENL_MAX_ID)
@@ -249,6 +251,9 @@ static int genl_validate_assign_mc_groups(struct genl_family *family)
 	} else if (family->id == GENL_ID_PMCRAID) {
 		first_id = GENL_ID_PMCRAID;
 		BUG_ON(n_groups != 1);
+	} else if (family->id == GENL_ID_FS_EVENT) {
+		first_id = GENL_ID_FS_EVENT;
+		BUG_ON(n_groups != 1);
 	} else {
 		groups_allocated = true;
 		err = genl_allocate_reserve_groups(n_groups, &first_id);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
