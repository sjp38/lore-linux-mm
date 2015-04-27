Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE276B0070
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 07:56:46 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so127030588pab.3
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 04:56:46 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id w10si29585643pas.114.2015.04.27.04.56.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Apr 2015 04:56:44 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NNG00200RUFA080@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Apr 2015 12:56:39 +0100 (BST)
From: Beata Michalska <b.michalska@samsung.com>
Subject: [RFC v2 1/4] fs: Add generic file system event notifications
Date: Mon, 27 Apr 2015 13:51:41 +0200
Message-id: <1430135504-24334-2-git-send-email-b.michalska@samsung.com>
In-reply-to: <1430135504-24334-1-git-send-email-b.michalska@samsung.com>
References: <1430135504-24334-1-git-send-email-b.michalska@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org
Cc: jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

Introduce configurable generic interface for file
system-wide event notifications, to provide file
systems with a common way of reporting any potential
issues as they emerge.

The notifications are to be issued through generic
netlink interface by newly introduced multicast group.

Threshold notifications have been included, allowing
triggering an event whenever the amount of free space drops
below a certain level - or levels to be more precise as two
of them are being supported: the lower and the upper range.
The notifications work both ways: once the threshold level
has been reached, an event shall be generated whenever
the number of available blocks goes up again re-activating
the threshold.

The interface has been exposed through a vfs. Once mounted,
it serves as an entry point for the set-up where one can
register for particular file system events.

Signed-off-by: Beata Michalska <b.michalska@samsung.com>
---
 Documentation/filesystems/events.txt |  231 ++++++++++
 fs/Makefile                          |    1 +
 fs/events/Makefile                   |    6 +
 fs/events/fs_event.c                 |  770 ++++++++++++++++++++++++++++++++++
 fs/events/fs_event.h                 |   25 ++
 fs/events/fs_event_netlink.c         |   99 +++++
 fs/namespace.c                       |    1 +
 include/linux/fs.h                   |    6 +-
 include/linux/fs_event.h             |   58 +++
 include/uapi/linux/fs_event.h        |   54 +++
 include/uapi/linux/genetlink.h       |    1 +
 net/netlink/genetlink.c              |    7 +-
 12 files changed, 1257 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/filesystems/events.txt
 create mode 100644 fs/events/Makefile
 create mode 100644 fs/events/fs_event.c
 create mode 100644 fs/events/fs_event.h
 create mode 100644 fs/events/fs_event_netlink.c
 create mode 100644 include/linux/fs_event.h
 create mode 100644 include/uapi/linux/fs_event.h

diff --git a/Documentation/filesystems/events.txt b/Documentation/filesystems/events.txt
new file mode 100644
index 0000000..df0b0e2
--- /dev/null
+++ b/Documentation/filesystems/events.txt
@@ -0,0 +1,231 @@
+
+	Generic file system event notification interface
+
+Document created 23 April 2015 by Beata Michalska <b.michalska@samsung.com>
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
+easy way of real-time notifications triggered whenever something interesting
+happens, allowing filesystems to report events in a common way, as they occur.
+
+2. How does it work:
+====================
+
+The interface itself has been exposed as fstrace-type Virtual File System,
+primarily to ease the process of setting up the configuration for the
+notifications. So for starters, it needs to get mounted (obviously):
+
+	mount -t fstrace none /sys/fs/events
+
+This will unveil the single fstrace filesystem entry - the 'config' file,
+through which the notification are being set-up.
+
+Activating notifications for particular filesystem is as straightforward
+as writing into the 'config' file. Note that by default all events, despite
+the actual filesystem type, are being disregarded.
+
+Synopsis of config:
+------------------
+
+	MOUNT EVENT_TYPE [L1] [L2]
+
+ MOUNT      : the filesystem's mount point
+ EVENT_TYPE : event types - currently two of them are being supported:
+
+	      * generic events ("G") covering most common warnings
+	      and errors that might be reported by any filesystem;
+	      this option does not take any arguments;
+
+	      * threshold notifications ("T") - events sent whenever
+	      the amount of available space drops below certain level;
+	      it is possible to specify two threshold levels though
+	      only one is required to properly setup the notifications;
+	      as those refer to the number of available blocks, the lower
+	      level [L1] needs to be higher than the upper one [L2]
+
+Sample request could look like the following:
+
+ echo /sample/mount/point G T 710000 500000 > /sys/fs/events/config
+
+Multiple request might be specified provided they are separated with semicolon.
+
+The configuration itself might be modified at any time. One can add/remove
+particular event types for given fielsystem, modify the threshold levels,
+and remove single or all entries from the 'config' file.
+
+ - Adding new event type:
+
+ $ echo MOUNT EVENT_TYPE > /sys/fs/events/config
+
+(Note that is is enough to provide the event type to be enabled without
+the already set ones.)
+
+ - Removing event type:
+
+ $ echo '!MOUNT EVENT_TYPE' > /sys/fs/events/config
+
+ - Updating threshold limits:
+
+ $ echo MOUNT T L1 L2 > /sys/fs/events/config
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
+along with some additional info like the filesystem type and the backing device
+name if available.
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
+entry) for given event, one will be silently disregarded. If, on the other
+hand, someone is 'watching' given filesystem for specific events, a generic
+netlink message will be sent. A dedicated multicast group has been provided
+solely for this purpose so in order to receive such notifications, one should
+subscribe to this new multicast group.
+
+3.1 Message format
+
+The FS_NL_C_EVENT shall be stored within the generic netlink message header
+as the command field. The message payload will provide more detailed info:
+the backing device major and minor numbers, the event code and the id of
+the process which action led to the event occurrence. In case of threshold
+notifications, the current number of available blocks will be included
+in the payload as well.
+
+
+	 0                   1                   2                   3
+	 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+	|	            NETLINK MESSAGE HEADER			|
+	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+	| 		GENERIC NETLINK MESSAGE HEADER   		|
+	| 	   (with FS_NL_C_EVENT as genlmsghdr cdm field)		|
+	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+	| 	      Optional user specific message header		|
+	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+	|		   GENERIC MESSAGE PAYLOAD:			|
+	+---------------------------------------------------------------+
+	| 		  FS_NL_A_EVENT_ID  (NLA_U32)			|
+	+---------------------------------------------------------------+
+	|	  	  FS_NL_A_DEV_MAJOR (NLA_U32)			|
+	+---------------------------------------------------------------+
+	| 	  	  FS_NL_A_DEV_MINOR (NLA_U32) 			|
+	+---------------------------------------------------------------+
+	|  		  FS_NL_A_CAUSED_ID (NLA_U32)			|
+	+---------------------------------------------------------------+
+	|  		    FS_NL_A_DATA (NLA_U64)			|
+	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+
+
+The above figure is based on:
+ http://www.linuxfoundation.org/collaborate/workgroups/networking/generic_netlink_howto#Message_Format
+
+
+4. API Reference:
+=================
+
+ 4.1 Generic file system event interface data & operations
+
+ #include <linux/fs_event.h>
+
+ struct fs_trace_info {
+	void	__rcu	*e_priv		 /* READ ONLY */
+	unsigned int 	events_cap_mask; /* Supported notifications */
+	const struct fs_trace_operations *ops;
+ };
+
+ struct fs_trace_operations {
+	void (*query)(struct super_block *, u64 *);
+ };
+
+ In order to get the fireworks and stuff, each filesystem needs to setup
+ the events_cap_mask field of the fs_trace_info structure, which has been
+ embedded within the super_block structure. This should reflect the type of
+ events the filesystem wants to support. In case of threshold notifications,
+ apart from setting the FS_EVENT_THRESH flag, the 'query' callback should
+ be provided as this enables the events interface to get the up-to-date
+ state of the number of available blocks whenever those notifications are
+ being requested.
+
+ The 'e_priv' field of the fs_trace_info structure should be completely ignored
+ as it's for INTERNAL USE ONLY. So don't even think of messing with it, if you
+ do not want to get yourself into some real trouble. If still, you are tempted
+ to do so - feel free, it's gonna be pure fun. Consider yourself warned.
+
+
+ 4.2 Event notification:
+
+ #include <linux/fs_event.h>
+ void fs_event_notify(struct super_block *sb, unsigned int event_id);
+
+ Notify the generic FS event interface of an occurring event.
+ This shall be used by any file system that wishes to inform any potential
+ listeners/watchers of a particular event.
+ - sb:         the filesystem's super block
+ - event_id:   an event identifier
+
+ 4.3 Threshold notifications:
+
+ #include <linux/fs_event.h>
+ void fs_event_alloc_space(struct super_block *sb, u64 ncount);
+ void fs_event_free_space(struct super_block *sb, u64 ncount);
+
+ Each filesystme supporting the threshold notifications should call
+ fs_event_alloc_space/fs_event_free_space respectively whenever the
+ amount of available blocks changes.
+ - sb:     the filesystem's super block
+ - ncount: number of blocks being acquired/released
+
+ Note that to properly handle the threshold notifications the fs events
+ interface needs to be kept up to date by the filesystems. Each should
+ register fs_trace_operations to enable querying the current number of
+ available blocks.
+
+ 4.4 Sending message through generic netlink interface
+
+ #include <linux/fs_event.h>
+
+ int fs_netlink_send_event(size_t size, unsigned int event_id,
+	int (*compose_msg)(struct sk_buff *skb, void *data), void *cbdata);
+
+ Although the fs event interface is fully responsible for sending the messages
+ over the netlink, filesystems might use the FS_EVENT multicast group to send
+ their own custom messages.
+ - size:        the size of the message payload
+ - event_id:    the event identifier
+ - compose_msg: a callback responsible for filling-in the message payload
+ - cbdata:      message custom data
+
+ Calling fs_netlink_send_event will result in a message being sent by
+ the FS_EVENT multicast group. Note that the body of the message should be
+ prepared (set-up )by the caller - through compose_msg callback. The message's
+ sk_buff will be allocated on behalf of the caller (thus the size parameter).
+ The compose_msg should only fill the payload with proper data. Unless
+ the event id is specified as FS_EVENT_NONE, it's value shall be added
+ to the payload prior to calling the compose_msg.
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
index 0000000..ea6afdd
--- /dev/null
+++ b/fs/events/fs_event.c
@@ -0,0 +1,770 @@
+/*
+ * Generic File System Evens Interface
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
+#include <linux/module.h>
+#include <linux/mount.h>
+#include <linux/namei.h>
+#include <linux/parser.h>
+#include <linux/seq_file.h>
+#include <linux/slab.h>
+#include <linux/rcupdate.h>
+#include <net/genetlink.h>
+#include "../mount.h"
+#include "fs_event.h"
+
+static LIST_HEAD(fs_trace_list);
+static DEFINE_SPINLOCK(fs_trace_lock);
+
+static struct kmem_cache *fs_trace_cachep __read_mostly;
+
+static atomic_t stray_traces = ATOMIC_INIT(0);
+static DECLARE_WAIT_QUEUE_HEAD(trace_wq);
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
+	atomic_t	 count;
+	atomic_t	 active;
+	struct super_block *sb;
+	unsigned int	 notify;
+	struct path	 mnt_path;
+	struct list_head node;
+
+	struct fs_event_thresh {
+		u64		 avail_space;
+		u64		 lrange;
+		u64		 urange;
+		unsigned int	 state;
+	}		 th;
+	struct rcu_head	 rcu_head;
+	spinlock_t	 lock;
+};
+
+static const match_table_t fs_etypes = {
+	{ FS_EVENT_GENERIC, "G"   },
+	{ FS_EVENT_THRESH,  "T"   },
+	{ 0, NULL },
+};
+
+static __always_inline int fs_trace_query_data(struct super_block *sb,
+				       struct fs_trace_entry *en)
+{
+	if (sb->s_etrace.ops && sb->s_etrace.ops->query) {
+		sb->s_etrace.ops->query(sb, &en->th.avail_space);
+		return 0;
+	}
+
+	return -EINVAL;
+}
+
+static inline void fs_trace_entry_list_del(struct fs_trace_entry *en)
+{
+
+	lockdep_assert_held(&fs_trace_lock);
+
+	if (!atomic_add_unless(&en->active, -1, 0))
+		return;
+	/*
+	 * At this point the trace entry is being marked as inactive
+	 * so no new references will be allowed.
+	 */
+	list_del(&en->node);
+	atomic_inc(&stray_traces);
+}
+
+static inline void fs_trace_entry_free(struct fs_trace_entry *en)
+{
+	kmem_cache_free(fs_trace_cachep, en);
+}
+
+static void fs_destroy_trace_entry(struct rcu_head *rcu_head)
+{
+	struct fs_trace_entry *en = container_of(rcu_head,
+					struct fs_trace_entry, rcu_head);
+
+	WARN_ON(atomic_read(&en->active));
+	fs_trace_entry_free(en);
+	atomic_dec(&stray_traces);
+}
+
+static inline void fs_release_trace_entry(struct fs_trace_entry *en)
+{
+	struct super_block *sb = en->sb;
+
+	rcu_assign_pointer(sb->s_etrace.e_priv, NULL);
+	call_rcu(&en->rcu_head, fs_destroy_trace_entry);
+}
+
+static inline void fs_trace_entry_put(struct fs_trace_entry *en)
+{
+	if (en && atomic_dec_and_test(&en->count))
+		fs_release_trace_entry(en);
+}
+
+static inline
+struct fs_trace_entry *fs_trace_entry_get(struct fs_trace_entry *en)
+{
+	if (en) {
+		if (!atomic_inc_not_zero(&en->count))
+			return NULL;
+		/* Don't allow referencing inactive object */
+		if (!atomic_read(&en->active)) {
+			fs_trace_entry_put(en);
+			return NULL;
+		}
+	}
+	return en;
+}
+
+static struct fs_trace_entry *fetch_trace_entry(struct super_block *sb)
+{
+	struct fs_trace_entry *en;
+
+	if (!sb)
+		return NULL;
+
+	rcu_read_lock();
+	en = rcu_dereference(sb->s_etrace.e_priv);
+	en = fs_trace_entry_get(en);
+	rcu_read_unlock();
+
+	return en;
+}
+
+static int fs_remove_trace_entry(struct super_block *sb)
+{
+	struct fs_trace_entry *en;
+
+	en = fetch_trace_entry(sb);
+	if (!en)
+		return -EINVAL;
+
+	spin_lock(&fs_trace_lock);
+	/*
+	 * The trace entry might have already been removed
+	 * from the list of active traces with the proper
+	 * ref drop, though it was still in use handling
+	 * one of the fs events. This means that the object
+	 * has been already scheduled for being released.
+	 */
+	if (atomic_read(&en->active)) {
+		fs_trace_entry_list_del(en);
+		fs_trace_entry_put(en);
+	}
+	spin_unlock(&fs_trace_lock);
+	fs_trace_entry_put(en);
+	return 0;
+}
+
+static void fs_remove_all_traces(void)
+{
+	struct fs_trace_entry *en, *guard;
+
+	spin_lock(&fs_trace_lock);
+	list_for_each_entry_safe(en, guard, &fs_trace_list, node) {
+		fs_trace_entry_list_del(en);
+		fs_trace_entry_put(en);
+	}
+	spin_unlock(&fs_trace_lock);
+}
+
+static int create_common_msg(struct sk_buff *skb, void *data)
+{
+	struct fs_trace_entry *en = (struct fs_trace_entry *)data;
+	struct super_block *sb = en->sb;
+
+	if (nla_put_u32(skb, FS_NL_A_DEV_MAJOR, MAJOR(sb->s_dev))
+	||  nla_put_u32(skb, FS_NL_A_DEV_MINOR, MINOR(sb->s_dev)))
+		return -EINVAL;
+
+	if (nla_put_u64(skb, FS_NL_A_CAUSED_ID, pid_nr(task_pid(current))))
+		return -EINVAL;
+
+	return 0;
+}
+
+static int create_thresh_msg(struct sk_buff *skb, void *data)
+{
+	struct fs_trace_entry *en = (struct fs_trace_entry *)data;
+	int ret;
+
+	ret = create_common_msg(skb, data);
+	if (!ret)
+		ret = nla_put_u64(skb, FS_NL_A_DATA, en->th.avail_space);
+	return ret;
+}
+
+static void fs_event_send(struct fs_trace_entry *en, unsigned int event_id)
+{
+	size_t size = nla_total_size(sizeof(u32)) * 2 +
+		      nla_total_size(sizeof(u64));
+
+	fs_netlink_send_event(size, event_id, create_common_msg, en);
+}
+
+static void fs_event_send_thresh(struct fs_trace_entry *en,
+				  unsigned int event_id)
+{
+	size_t size = nla_total_size(sizeof(u32)) * 2 +
+		      nla_total_size(sizeof(u64)) * 2;
+
+	fs_netlink_send_event(size, event_id, create_thresh_msg, en);
+}
+
+void fs_event_notify(struct super_block *sb, unsigned int event_id)
+{
+	struct fs_trace_entry *en;
+
+	en = fetch_trace_entry(sb);
+	if (!en)
+		return;
+
+	spin_lock(&en->lock);
+	if (en->notify & FS_EVENT_GENERIC)
+		fs_event_send(en, event_id);
+	spin_unlock(&en->lock);
+	fs_trace_entry_put(en);
+}
+EXPORT_SYMBOL(fs_event_notify);
+
+void fs_event_alloc_space(struct super_block *sb, u64 ncount)
+{
+	struct fs_trace_entry *en;
+	s64 count;
+
+	en = fetch_trace_entry(sb);
+	if (!en)
+		return;
+
+	spin_lock(&en->lock);
+
+	if (!(en->notify & FS_EVENT_THRESH))
+		goto leave;
+	/* we shouldn't drop below 0 here,
+	 * unless there is a sync issue somewhere (?)
+	 */
+	count = en->th.avail_space - ncount;
+	en->th.avail_space = count < 0 ? 0 : count;
+
+	if (en->th.avail_space > en->th.lrange)
+		/* Not 'even' close - leave */
+		goto leave;
+
+	if (en->th.avail_space > en->th.urange) {
+		/* Close enough - the lower range has been reached */
+		if (!(en->th.state & THRESH_LR_BEYOND)) {
+			/* Send notification */
+			fs_event_send_thresh(en, FS_THR_LRBELOW);
+			en->th.state &= ~THRESH_LR_BELOW;
+			en->th.state |= THRESH_LR_BEYOND;
+		}
+		goto leave;
+	}
+	if (!(en->th.state & THRESH_UR_BEYOND)) {
+		fs_event_send_thresh(en, FS_THR_URBELOW);
+		en->th.state &=  ~THRESH_UR_BELOW;
+		en->th.state |= THRESH_UR_BEYOND;
+	}
+
+leave:
+	spin_unlock(&en->lock);
+	fs_trace_entry_put(en);
+}
+EXPORT_SYMBOL(fs_event_alloc_space);
+
+void fs_event_free_space(struct super_block *sb, u64 ncount)
+{
+	struct fs_trace_entry *en;
+
+	en = fetch_trace_entry(sb);
+	if (!en)
+		return;
+
+	spin_lock(&en->lock);
+
+	if (!(en->notify & FS_EVENT_THRESH))
+		goto leave;
+
+	en->th.avail_space += ncount;
+
+	if (en->th.avail_space > en->th.lrange) {
+		if (!(en->th.state & THRESH_LR_BELOW)
+		&& en->th.state & THRESH_LR_BEYOND) {
+			/* Send notification */
+			fs_event_send_thresh(en, FS_THR_LRABOVE);
+			en->th.state &= ~THRESH_LR_BEYOND;
+			en->th.state |= THRESH_LR_BELOW;
+			goto leave;
+		}
+	}
+	if (en->th.avail_space > en->th.urange) {
+		if (!(en->th.state & THRESH_UR_BELOW)
+		&& en->th.state & THRESH_UR_BEYOND) {
+			/* Notify */
+			fs_event_send_thresh(en, FS_THR_URABOVE);
+			en->th.state &= ~THRESH_UR_BEYOND;
+			en->th.state |= THRESH_UR_BELOW;
+		}
+	}
+leave:
+	spin_unlock(&en->lock);
+	fs_trace_entry_put(en);
+}
+EXPORT_SYMBOL(fs_event_free_space);
+
+void fs_event_mount_dropped(struct vfsmount *mnt)
+{
+	/*
+	 * This gets tricky here: the mount is dropped but the super
+	 * might not get released at once so there is very small chance
+	 * some notifications will come through.
+	 */
+	fs_remove_trace_entry(mnt->mnt_sb);
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
+	 * in time to perform appropriate clean-up
+	 */
+	r_mnt = real_mount(path->mnt);
+	en->mnt_path.dentry = r_mnt->mnt.mnt_root;
+	en->mnt_path.mnt = &r_mnt->mnt;
+
+	sb = path->mnt->mnt_sb;
+	en->sb = sb;
+
+	nmask &= sb->s_etrace.events_cap_mask;
+	if (!nmask)
+		goto leave;
+
+	spin_lock_init(&en->lock);
+	INIT_LIST_HEAD(&en->node);
+
+	en->notify = nmask;
+	memcpy(&en->th, thresh, offsetof(struct fs_event_thresh, state));
+	if (nmask & FS_EVENT_THRESH)
+		fs_trace_query_data(sb, en);
+
+	atomic_set(&en->count, 1);
+
+	if (rcu_access_pointer(sb->s_etrace.e_priv) != NULL) {
+		struct fs_trace_entry *prev_en;
+
+		prev_en = fetch_trace_entry(sb);
+		if (prev_en) {
+			fs_trace_entry_put(prev_en);
+			goto leave;
+		}
+	}
+	atomic_set(&en->active, 1);
+
+	spin_lock(&fs_trace_lock);
+	list_add(&en->node, &fs_trace_list);
+	spin_unlock(&fs_trace_lock);
+
+	rcu_assign_pointer(sb->s_etrace.e_priv, en);
+	synchronize_rcu();
+
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
+	struct super_block *sb = en->sb;
+
+	nmask &= ~FS_TRACE_ADD;
+	if (!(nmask & sb->s_etrace.events_cap_mask))
+		return -EINVAL;
+
+	if (nmask & FS_EVENT_THRESH) {
+		if (extend) {
+			/* Get the current state */
+			if (!(en->notify & FS_EVENT_THRESH))
+				if (fs_trace_query_data(sb, en))
+					return -EINVAL;
+
+			if (thresh->state & THRESH_LR_ON) {
+				en->th.lrange = thresh->lrange;
+				en->th.state &= ~THRESH_LR_ON;
+			}
+
+			if (thresh->state & THRESH_UR_ON) {
+				en->th.urange = thresh->urange;
+				en->th.state &= ~THRESH_UR_ON;
+			}
+		} else {
+			memset(&en->th, 0, sizeof(en->th));
+		}
+	}
+
+	if (extend)
+		en->notify |= nmask;
+	else
+		en->notify &= ~nmask;
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
+	en = fetch_trace_entry(path->mnt->mnt_sb);
+	if (!en)
+		return (nmask & FS_TRACE_ADD)
+			?  fs_new_trace_entry(path, thresh, nmask)
+			: -EINVAL;
+
+	spin_lock(&en->lock);
+	ret = fs_update_trace_entry_locked(en, thresh, nmask);
+	spin_unlock(&en->lock);
+
+	fs_trace_entry_put(en);
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
+	s = *(argv);
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
+repeat:
+	args[0].to = args[0].from = NULL;
+	token = match_token(*(++argv), fs_etypes, args);
+	if (!token && !nmask)
+		goto leave;
+
+	nmask |= token & FS_EVENTS_ALL;
+	--argc;
+	if ((token & FS_EVENT_THRESH)  && (nmask & FS_TRACE_ADD)) {
+		/*
+		 * Get the threshold config data:
+		 * lower range
+		 * upper range
+		 */
+		if (!argc)
+			goto leave;
+
+		ret = kstrtoull(*(++argv), 10, &thresh.lrange);
+		if (ret)
+			goto leave;
+		thresh.state |= THRESH_LR_ON;
+		if ((--argc)) {
+			ret = kstrtoull(*(++argv), 10, &thresh.urange);
+			if (ret)
+				goto leave;
+			thresh.state |= THRESH_UR_ON;
+			--argc;
+		}
+		/* The thresholds are based on number of available blocks */
+		if (thresh.lrange < thresh.urange) {
+			ret = -EINVAL;
+			goto leave;
+		}
+	}
+	if (argc)
+		goto repeat;
+
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
+	sb = en->sb;
+
+	seq_path(m, &en->mnt_path, "\t\n\\");
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
+		sb->s_op->show_devname(m, en->mnt_path.mnt->mnt_root);
+	} else {
+		r_mnt = real_mount(en->mnt_path.mnt);
+		seq_escape(m, r_mnt->mnt_devname ? r_mnt->mnt_devname : "none",
+				" \t\n\\");
+	}
+	seq_puts(m, " (");
+
+	nmask = en->notify;
+	for (match = fs_etypes; match->pattern; ++match) {
+		if (match->token & nmask) {
+			seq_puts(m, match->pattern);
+			nmask &= ~match->token;
+			if (nmask)
+				seq_putc(m, ',');
+		}
+	}
+	seq_printf(m, " %llu %llu", en->th.lrange, en->th.urange);
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
+	init_waitqueue_head(&trace_wq);
+	return 0;
+}
+
+/* VFS support */
+static int fs_trace_fill_super(struct super_block *sb, void *data, int silen)
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
+	/*
+	 * The rcu_barrier here will/should make sure all call_rcu
+	 * callbacks are completed - still there might be some active
+	 * trace objects in use, so the callbacks will not be triggered
+	 * for them at all (at this point), which makes calling the
+	 * kmem_cache_destroy unsafe. So we wait until all traces
+	 * are finally released.
+	 */
+	fs_remove_all_traces();
+	rcu_barrier();
+
+	wait_event(trace_wq, !atomic_read(&stray_traces));
+
+	kmem_cache_destroy(fs_trace_cachep);
+	kill_litter_super(sb);
+}
+
+static struct kset	*fs_trace_kset;
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
+		if (!fs_event_netlink_register())
+			return;
+		unregister_filesystem(&fs_trace_fstype);
+	}
+	kset_unregister(fs_trace_kset);
+}
+
+static int __init fs_trace_evens_init(void)
+{
+	fs_trace_vfs_init();
+	return 0;
+};
+module_init(fs_trace_evens_init);
+
diff --git a/fs/events/fs_event.h b/fs/events/fs_event.h
new file mode 100644
index 0000000..716a2dd
--- /dev/null
+++ b/fs/events/fs_event.h
@@ -0,0 +1,25 @@
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
+#else /* CONFIG_NET */
+static inline int  fs_event_netlink_register(void) { return -ENOSYS; }
+#endif /* CONFIG_NET */
+
+#endif /* __GENERIC_FS_EVENTS_H */
diff --git a/fs/events/fs_event_netlink.c b/fs/events/fs_event_netlink.c
new file mode 100644
index 0000000..b59c6dc
--- /dev/null
+++ b/fs/events/fs_event_netlink.c
@@ -0,0 +1,99 @@
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
+#include "fs_event.h"
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
+	.maxattr	= FS_NL_A_MAX,
+	.mcgrps		= fs_event_mcgroups,
+	.n_mcgrps	= ARRAY_SIZE(fs_event_mcgroups),
+};
+
+int fs_netlink_send_event(size_t size, unsigned int event_id,
+	int (*compose_msg)(struct sk_buff *skb,  void *data), void *cbdata)
+{
+	static atomic_t seq;
+	struct sk_buff *skb;
+	void *msg_head;
+	int ret = 0;
+
+	if (!size || !compose_msg)
+		return -EINVAL;
+
+	if (event_id != FS_EVENT_NONE)
+		size += nla_total_size(sizeof(u32));
+	size += nla_total_size(sizeof(u64));
+	skb = genlmsg_new(size, GFP_NOWAIT);
+
+	if (!skb) {
+		pr_err("Failed to allocate new FS generic netlink message\n");
+		return -ENOMEM;
+	}
+
+	msg_head = genlmsg_put(skb, 0, atomic_add_return(1, &seq),
+			&fs_event_family, 0, FS_NL_C_EVENT);
+	if (!msg_head)
+		goto cleanup;
+
+	if (event_id != FS_EVENT_NONE)
+		if (nla_put_u32(skb, FS_NL_A_EVENT_ID, event_id))
+			goto cancel;
+
+	ret = compose_msg(skb, cbdata);
+	if (ret)
+		goto cancel;
+
+	genlmsg_end(skb, msg_head);
+	ret = genlmsg_multicast(&fs_event_family, skb, 0, 0, GFP_NOWAIT);
+	if (ret && ret != -ENOBUFS && ret != -ESRCH)
+		goto cleanup;
+
+	return ret;
+cancel:
+	genlmsg_cancel(skb, msg_head);
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
index b4d71b5..b7dadd9 100644
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
@@ -1253,7 +1257,7 @@ struct super_block {
 	struct hlist_node	s_instances;
 	unsigned int		s_quota_types;	/* Bitmask of supported quota types */
 	struct quota_info	s_dquot;	/* Diskquota specific options */
-
+	struct fs_trace_info	s_etrace;
 	struct sb_writers	s_writers;
 
 	char s_id[32];				/* Informational name */
diff --git a/include/linux/fs_event.h b/include/linux/fs_event.h
new file mode 100644
index 0000000..aa182ec
--- /dev/null
+++ b/include/linux/fs_event.h
@@ -0,0 +1,58 @@
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
+ * Currently supported event types
+ */
+#define FS_EVENT_GENERIC 0x001
+#define FS_EVENT_THRESH	 0x002
+
+#define FS_EVENTS_ALL  (FS_EVENT_GENERIC | FS_EVENT_THRESH)
+
+struct fs_trace_operations {
+	void (*query)(struct super_block *, u64 *);
+};
+
+struct fs_trace_info {
+	void	__rcu	*e_priv;		 /* READ ONLY */
+	unsigned int	events_cap_mask; /* Supported notifications */
+	const struct fs_trace_operations *ops;
+};
+
+void fs_event_notify(struct super_block *sb, unsigned int event_id);
+void fs_event_alloc_space(struct super_block *sb, u64 ncount);
+void fs_event_free_space(struct super_block *sb, u64 ncount);
+void fs_event_mount_dropped(struct vfsmount *mnt);
+
+#ifdef CONFIG_NET
+int fs_netlink_send_event(size_t size, unsigned int event_id,
+	int (*compose_msg)(struct sk_buff *skb, void *data), void *cbdata);
+#else /* CONFIG_NET */
+static inline
+int fs_netlink_send_event(size_t size,  unsigned int event_id,
+	int (*compose_msig)(struct sk_buff *skb, void *data), void *cbdata)
+{
+	return -ENOSYS;
+}
+#endif /* CONFIG_NET */
+
+#endif /* _LINUX_GENERIC_FS_EVENTS_ */
+
diff --git a/include/uapi/linux/fs_event.h b/include/uapi/linux/fs_event.h
new file mode 100644
index 0000000..081c39b
--- /dev/null
+++ b/include/uapi/linux/fs_event.h
@@ -0,0 +1,54 @@
+/*
+ * Generic netlink support for Generic File System Events Interface
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
+ * Generic netlink attribute types
+ */
+enum {
+	FS_NL_A_NONE,
+	FS_NL_A_EVENT_ID,
+	FS_NL_A_DEV_MAJOR,
+	FS_NL_A_DEV_MINOR,
+	FS_NL_A_CAUSED_ID,
+	FS_NL_A_DATA,
+	__FS_NL_A_MAX,
+};
+#define FS_NL_A_MAX (__FS_NL_A_MAX - 1)
+/*
+ * Generic netlink commands
+ */
+#define FS_NL_C_EVENT		1
+
+/*
+ * Supported set of FS events
+ */
+enum {
+	FS_EVENT_NONE,
+	FS_WARN_ENOSPC,		/* No space left to reserve data blks */
+	FS_WARN_ENOSPC_META,	/* No space left for metadata */
+	FS_THR_LRBELOW,		/* The threshold lower range has been reached */
+	FS_THR_LRABOVE,		/* The threshold lower range re-activcated*/
+	FS_THR_URBELOW,
+	FS_THR_URABOVE,
+	FS_ERR_REMOUNT_RO,	/* The file system has been remounted as RO */
+	FS_ERR_CORRUPTED	/* Critical error - fs corrupted */
+
+};
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
