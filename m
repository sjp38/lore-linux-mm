Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 82C0F6B005A
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 13:50:39 -0500 (EST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 5/6] staging: ramster: ramster-specific new files
Date: Tue, 27 Dec 2011 10:50:34 -0800
Message-Id: <1325011834-2158-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, kurt.hackel@oracle.com, sjenning@linux.vnet.ibm.com, chris.mason@oracle.com, dan.magenheimer@oracle.com

New files for ramster support:  The file ramster.h declares externs
and some pampd bitfield manipulation.  The file zcache.h declares
some zcache functions that now must be accessed from the ramster
glue code.  The file ramster_o2net.c is the glue between
zcache and the o2net messaging code, providing routines called
from zcache that initiate messages, and routines that handle
messages by calling zcache. TODO explains future plans for merging.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/ramster/TODO            |    9 +
 drivers/staging/ramster/ramster.h       |  117 +++++++++
 drivers/staging/ramster/ramster_o2net.c |  419 +++++++++++++++++++++++++++++++
 drivers/staging/ramster/zcache.h        |   22 ++
 4 files changed, 567 insertions(+), 0 deletions(-)
 create mode 100644 drivers/staging/ramster/TODO
 create mode 100644 drivers/staging/ramster/ramster.h
 create mode 100644 drivers/staging/ramster/ramster_o2net.c
 create mode 100644 drivers/staging/ramster/zcache.h

diff --git a/drivers/staging/ramster/TODO b/drivers/staging/ramster/TODO
new file mode 100644
index 0000000..d4268f0
--- /dev/null
+++ b/drivers/staging/ramster/TODO
@@ -0,0 +1,9 @@
+For this staging driver, RAMster duplicates code from fs/ocfs2/cluster
+and from drivers/staging/zcache, then incorporates changes to the local
+copy of the code.  Before RAMster can be promoted from staging, this code
+duplication must be resolved.  Specifically, we will first need to work with
+the ocfs2 maintainers to split out the ocfs2 core cluster code so that
+it can be easily included by another subsystem, even if ocfs2 is not
+configured, and also to merge the handful of functional changes required.
+Second, the zcache and RAMster drivers should be either merged or reorganized
+to separate out common code.
diff --git a/drivers/staging/ramster/ramster.h b/drivers/staging/ramster/ramster.h
new file mode 100644
index 0000000..3293512
--- /dev/null
+++ b/drivers/staging/ramster/ramster.h
@@ -0,0 +1,117 @@
+/*
+ * ramster.h
+ *
+ * Peer-to-peer transcendent memory
+ *
+ * Copyright (c) 2009-2012, Dan Magenheimer, Oracle Corp.
+ */
+
+#ifndef _RAMSTER_H_
+#define _RAMSTER_H_
+
+/*
+ * format of remote pampd:
+ *   bit 0 == intransit
+ *   bit 1 == is_remote... if this bit is set, then
+ *   bit 2-9 == remotenode
+ *   bit 10-22 == size
+ *   bit 23-30 == cksum
+ */
+#define FAKE_PAMPD_INTRANSIT_BITS	1
+#define FAKE_PAMPD_ISREMOTE_BITS	1
+#define FAKE_PAMPD_REMOTENODE_BITS	8
+#define FAKE_PAMPD_REMOTESIZE_BITS	13
+#define FAKE_PAMPD_CHECKSUM_BITS	8
+
+#define FAKE_PAMPD_INTRANSIT_SHIFT	0
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
+extern int ramster_remote_async_get(struct tmem_xhandle *,
+				bool, int, size_t, uint8_t, void *extra);
+extern int ramster_remote_put(struct tmem_xhandle *, char *, size_t,
+				bool, int *);
+extern int ramster_remote_flush(struct tmem_xhandle *, int);
+extern int ramster_remote_flush_object(struct tmem_xhandle *, int);
+extern int ramster_o2net_register_handlers(void);
+
+#endif /* _TMEM_H */
diff --git a/drivers/staging/ramster/ramster_o2net.c b/drivers/staging/ramster/ramster_o2net.c
new file mode 100644
index 0000000..ee6a9ed
--- /dev/null
+++ b/drivers/staging/ramster/ramster_o2net.c
@@ -0,0 +1,419 @@
+/*
+ * ramster_o2net.c
+ *
+ * Copyright (c) 2011, Dan Magenheimer, Oracle Corp.
+ *
+ * Ramster_o2net provides an interface between zcache and o2net.
+ *
+ * FIXME: support more than two nodes
+ */
+
+#include <linux/list.h>
+#include "cluster/tcp.h"
+#include "cluster/nodemanager.h"
+#include "tmem.h"
+#include "zcache.h"
+#include "ramster.h"
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
+#define RMSTR_O2NET_MAX_LEN \
+		(O2NET_MAX_PAYLOAD_BYTES - sizeof(struct tmem_xhandle))
+
+#include "cluster/tcp_internal.h"
+
+static struct o2nm_node *ramster_choose_node(int *nodenum,
+						struct tmem_xhandle *xh)
+{
+	struct o2nm_node *node = NULL;
+	int i;
+
+/* FIXME reproducibly pick a node based on xh that is NOT this node */
+	i = o2nm_this_node();
+	i = !i;		/* FIXME ONLY FOR TWO NODES */
+	node = o2nm_get_node_by_num(i);
+		/* WARNING: THIS DOES NOT CHECK TO ENSURE CONNECTED */
+	if (node != NULL)
+		*nodenum = i;
+	return node;
+}
+
+static void ramster_put_node(struct o2nm_node *node)
+{
+	o2nm_node_put(node);
+}
+
+/* FIXME following buffer should be per-cpu, protected by preempt_disable */
+static char ramster_async_get_buf[O2NET_MAX_PAYLOAD_BYTES];
+
+static int ramster_remote_async_get_request_handler(struct o2net_msg *msg,
+				u32 len, void *data, void **ret_data)
+{
+	char *pdata;
+	struct tmem_xhandle xh;
+	int found;
+	size_t size = RMSTR_O2NET_MAX_LEN;
+	u16 msgtype = be16_to_cpu(msg->msg_type);
+	bool get_and_free = (msgtype == RMSTR_TMEM_ASYNC_GET_AND_FREE_REQUEST);
+	unsigned long flags;
+
+	xh = *(struct tmem_xhandle *)msg->buf;
+	if (xh.xh_data_size > RMSTR_O2NET_MAX_LEN)
+		BUG();
+	pdata = ramster_async_get_buf;
+	*(struct tmem_xhandle *)pdata = xh;
+	pdata += sizeof(struct tmem_xhandle);
+	local_irq_save(flags);
+	found = zcache_get(xh.client_id, xh.pool_id, &xh.oid, xh.index,
+				pdata, &size, 1, get_and_free ? 1 : -1);
+	local_irq_restore(flags);
+	if (found < 0) {
+#if 0
+static unsigned long cnt;
+cnt++;
+if (!(cnt&(cnt-1)))
+pr_err("TESTING ArrgREQ zcache_get %s failed, assuming is this OK? cnt=%lu\n",
+	(get_and_free) ? "eph" : "pers", cnt);
+#endif
+		/* a zero size indicates the get failed */
+		size = 0;
+	}
+	if (size > RMSTR_O2NET_MAX_LEN)
+		BUG();
+#if 0
+if (size != 0) {
+/* DOH! RMSTR_O2NET_MAX_LEN==4032... means zcache_get is returning failure
+   which means maybe a race with a flush? */
+unsigned char cksum;
+int i;
+char *tmp;
+for (tmp = pdata, cksum = 0, i = 0; i < size; i++)
+	cksum += *tmp;
+if ((xh.xh_data_size != size) || (xh.xh_data_cksum != cksum))
+pr_err("TESTING ArrgREQ, HUH xh_data_size=%d, exp=%d, cksum=%d, exp=%d,"
+	"xh=(%d,0x%llx.0x%llx.0x%llx,%x), %s\n",
+	(int)xh.xh_data_size, (int)size, xh.xh_data_cksum, cksum,
+	xh.pool_id, xh.oid.oid[0], xh.oid.oid[1], xh.oid.oid[2],
+	xh.index, (get_and_free ? "eph" : "pers"));
+else {
+#if 0
+static unsigned long cnt;
+cnt++;
+if (!(cnt&(cnt-1)))
+pr_err("TESTING ArrgREQ cnt=%lu, xh_data_size=%d, exp=%d, cksum=%d, exp=%d\n",
+	cnt, (int)xh.xh_data_size, (int)size, xh.xh_data_cksum, cksum);
+#endif
+}
+}
+#endif
+	*ret_data = pdata - sizeof(struct tmem_xhandle);
+	/* now make caller (o2net_process_message) handle specially */
+	o2net_force_data_magic(msg, RMSTR_TMEM_ASYNC_GET_REPLY, RMSTR_KEY);
+	return size + sizeof(struct tmem_xhandle);
+}
+
+static int ramster_remote_async_get_reply_handler(struct o2net_msg *msg,
+				u32 len, void *data, void **ret_data)
+{
+	char *in = (char *)msg->buf;
+	int datalen = len - sizeof(struct o2net_msg);
+	int ret = -1;
+	struct tmem_xhandle *xh = (struct tmem_xhandle *)in;
+
+	in += sizeof(struct tmem_xhandle);
+	datalen -= sizeof(struct tmem_xhandle);
+	BUG_ON(datalen < 0 || datalen > PAGE_SIZE);
+	ret = zcache_localify(xh->pool_id, &xh->oid, xh->index,
+				in, datalen, xh->extra);
+#if 1
+if (ret == -EEXIST)
+pr_err("TESTING ArrgREP, aborted overwrite on racy put\n");
+#endif
+	return ret;
+}
+
+int ramster_remote_put_handler(struct o2net_msg *msg,
+				u32 len, void *data, void **ret_data)
+{
+	struct tmem_xhandle *xh;
+	char *p = (char *)msg->buf;
+	int datalen = len - sizeof(struct o2net_msg) -
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
+	ret = zcache_put(xh->client_id, xh->pool_id, &xh->oid, xh->index,
+				p, datalen, 1, ephemeral ? 1 : -1);
+	local_irq_restore(flags);
+	return ret;
+}
+
+int ramster_remote_flush_handler(struct o2net_msg *msg,
+				u32 len, void *data, void **ret_data)
+{
+	struct tmem_xhandle *xh;
+	char *p = (char *)msg->buf;
+
+	xh = (struct tmem_xhandle *)p;
+	p += sizeof(struct tmem_xhandle);
+	(void)zcache_flush(xh->client_id, xh->pool_id, &xh->oid, xh->index);
+	return 0;
+}
+
+int ramster_remote_flobj_handler(struct o2net_msg *msg,
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
+int ramster_remote_async_get(struct tmem_xhandle *xh, bool free, int remotenode,
+				size_t expect_size, uint8_t expect_cksum,
+				void *extra)
+{
+	int ret = -1, status;
+	struct o2nm_node *node = NULL;
+	struct kvec vec[1];
+	size_t veclen = 1;
+	u32 msg_type;
+
+	node = o2nm_get_node_by_num(remotenode);
+	if (node == NULL)
+		goto out;
+	xh->client_id = o2nm_this_node(); /* which node is getting */
+	xh->xh_data_cksum = expect_cksum;
+	xh->xh_data_size = expect_size;
+	xh->extra = extra;
+	vec[0].iov_len = sizeof(*xh);
+	vec[0].iov_base = xh;
+	if (free)
+		msg_type = RMSTR_TMEM_ASYNC_GET_AND_FREE_REQUEST;
+	else
+		msg_type = RMSTR_TMEM_ASYNC_GET_REQUEST;
+	ret = o2net_send_message_vec(msg_type, RMSTR_KEY,
+					vec, veclen, remotenode, &status);
+	ramster_put_node(node);
+	if (ret < 0) {
+		/* FIXME handle bad message possibilities here? */
+		pr_err("UNTESTED ret<0 in ramster_remote_async_get\n");
+	}
+	ret = status;
+out:
+	return ret;
+}
+
+int ramster_remote_put(struct tmem_xhandle *xh, char *data, size_t size,
+				bool ephemeral, int *remotenode)
+{
+	int nodenum, ret = -1, status;
+	struct o2nm_node *node = NULL;
+	struct kvec vec[2];
+	size_t veclen = 2;
+	u32 msg_type;
+
+	BUG_ON(size > RMSTR_O2NET_MAX_LEN);
+	xh->client_id = o2nm_this_node(); /* which node is putting */
+	vec[0].iov_len = sizeof(*xh);
+	vec[0].iov_base = xh;
+	vec[1].iov_len = size;
+	vec[1].iov_base = data;
+	node = ramster_choose_node(&nodenum, xh);
+	if (!node)
+		goto out;
+
+#if 1
+{
+	extern struct o2net_node *o2net_nn_from_num(u8);
+	struct o2net_node *nn = o2net_nn_from_num(nodenum);
+	WARN_ON_ONCE(nn->nn_persistent_error || !nn->nn_sc_valid);
+}
+#endif
+
+	if (ephemeral)
+		msg_type = RMSTR_TMEM_PUT_EPH;
+	else
+		msg_type = RMSTR_TMEM_PUT_PERS;
+#if 1
+/* leave me here to see if it catches a weird crash I've seen a couple times */
+{
+static int last_hardirq_cnt, last_softirq_cnt, last_preempt_cnt;
+int cur_hardirq_cnt, cur_softirq_cnt, cur_preempt_cnt;
+cur_hardirq_cnt = hardirq_count() >> HARDIRQ_SHIFT;
+if (cur_hardirq_cnt > last_hardirq_cnt) {
+	last_hardirq_cnt = cur_hardirq_cnt;
+	if (!(last_hardirq_cnt&(last_hardirq_cnt-1)))
+		pr_err("TESTING RRP hardirq_count=%d\n", last_hardirq_cnt);
+}
+cur_softirq_cnt = softirq_count() >> SOFTIRQ_SHIFT;
+if (cur_softirq_cnt > last_softirq_cnt) {
+	last_softirq_cnt = cur_softirq_cnt;
+	if (!(last_softirq_cnt&(last_softirq_cnt-1)))
+		pr_err("TESTING RRP softirq_count=%d\n", last_softirq_cnt);
+}
+cur_preempt_cnt = preempt_count() & PREEMPT_MASK;
+if (cur_preempt_cnt > last_preempt_cnt) {
+	last_preempt_cnt = cur_preempt_cnt;
+	if (!(last_preempt_cnt&(last_preempt_cnt-1)))
+		pr_err("TESTING RRP preempt_count=%d\n", last_preempt_cnt);
+}
+}
+#endif
+
+	ret = o2net_send_message_vec(msg_type, RMSTR_KEY,
+						vec, veclen, nodenum, &status);
+#if 1
+	if (ret != 0) {
+		pr_err("UNTESTED case in ramster_remote_put\n");
+		ret = -1;
+	}
+#endif
+	if (ret < 0)
+		ret = -1;
+	else {
+		ret = status;
+		*remotenode = nodenum;
+	}
+
+	ramster_put_node(node);
+out:
+	return ret;
+}
+
+int ramster_remote_flush(struct tmem_xhandle *xh, int remotenode)
+{
+	int ret = -1, status;
+	struct o2nm_node *node = NULL;
+	struct kvec vec[1];
+	size_t veclen = 1;
+
+	node = o2nm_get_node_by_num(remotenode);
+	BUG_ON(node == NULL);
+	xh->client_id = o2nm_this_node(); /* which node is flushing */
+	vec[0].iov_len = sizeof(*xh);
+	vec[0].iov_base = xh;
+	BUG_ON(irqs_disabled());
+	BUG_ON(in_softirq());
+	ret = o2net_send_message_vec(RMSTR_TMEM_FLUSH, RMSTR_KEY,
+					vec, veclen, remotenode, &status);
+	ramster_put_node(node);
+	return ret;
+}
+
+int ramster_remote_flush_object(struct tmem_xhandle *xh, int remotenode)
+{
+	int ret = -1, status;
+	struct o2nm_node *node = NULL;
+	struct kvec vec[1];
+	size_t veclen = 1;
+
+	node = o2nm_get_node_by_num(remotenode);
+	BUG_ON(node == NULL);
+	xh->client_id = o2nm_this_node(); /* which node is flobjing */
+	vec[0].iov_len = sizeof(*xh);
+	vec[0].iov_base = xh;
+	ret = o2net_send_message_vec(RMSTR_TMEM_FLOBJ, RMSTR_KEY,
+					vec, veclen, remotenode, &status);
+	ramster_put_node(node);
+	return ret;
+}
+
+/*
+ * Handler registration
+ */
+
+static LIST_HEAD(ramster_o2net_unreg_list);
+
+static void ramster_o2net_unregister_handlers(void)
+{
+	o2net_unregister_handler_list(&ramster_o2net_unreg_list);
+}
+
+int ramster_o2net_register_handlers(void)
+{
+	int status;
+
+	status = o2net_register_handler(RMSTR_TMEM_PUT_EPH, RMSTR_KEY,
+				RMSTR_O2NET_MAX_LEN,
+				ramster_remote_put_handler,
+				NULL, NULL, &ramster_o2net_unreg_list);
+	if (status)
+		goto bail;
+
+	status = o2net_register_handler(RMSTR_TMEM_PUT_PERS, RMSTR_KEY,
+				RMSTR_O2NET_MAX_LEN,
+				ramster_remote_put_handler,
+				NULL, NULL, &ramster_o2net_unreg_list);
+	if (status)
+		goto bail;
+
+	status = o2net_register_handler(RMSTR_TMEM_ASYNC_GET_REQUEST, RMSTR_KEY,
+				RMSTR_O2NET_MAX_LEN,
+				ramster_remote_async_get_request_handler,
+				NULL, NULL,
+				&ramster_o2net_unreg_list);
+	if (status)
+		goto bail;
+
+	status = o2net_register_handler(RMSTR_TMEM_ASYNC_GET_AND_FREE_REQUEST,
+				RMSTR_KEY, RMSTR_O2NET_MAX_LEN,
+				ramster_remote_async_get_request_handler,
+				NULL, NULL,
+				&ramster_o2net_unreg_list);
+	if (status)
+		goto bail;
+
+	status = o2net_register_handler(RMSTR_TMEM_ASYNC_GET_REPLY, RMSTR_KEY,
+				RMSTR_O2NET_MAX_LEN,
+				ramster_remote_async_get_reply_handler,
+				NULL, NULL,
+				&ramster_o2net_unreg_list);
+	if (status)
+		goto bail;
+
+	status = o2net_register_handler(RMSTR_TMEM_FLUSH, RMSTR_KEY,
+				RMSTR_O2NET_MAX_LEN,
+				ramster_remote_flush_handler,
+				NULL, NULL,
+				&ramster_o2net_unreg_list);
+	if (status)
+		goto bail;
+
+	status = o2net_register_handler(RMSTR_TMEM_FLOBJ, RMSTR_KEY,
+				RMSTR_O2NET_MAX_LEN,
+				ramster_remote_flobj_handler,
+				NULL, NULL,
+				&ramster_o2net_unreg_list);
+	if (status)
+		goto bail;
+
+	pr_info("ramster_o2net: handlers registered\n");
+
+bail:
+	if (status) {
+		ramster_o2net_unregister_handlers();
+		pr_err("ramster_o2net: couldn't register handlers\n");
+	}
+	return status;
+}
diff --git a/drivers/staging/ramster/zcache.h b/drivers/staging/ramster/zcache.h
new file mode 100644
index 0000000..250b121
--- /dev/null
+++ b/drivers/staging/ramster/zcache.h
@@ -0,0 +1,22 @@
+/*
+ * zcache.h
+ *
+ * External zcache functions
+ *
+ * Copyright (c) 2009-2012, Dan Magenheimer, Oracle Corp.
+ */
+
+#ifndef _ZCACHE_H_
+#define _ZCACHE_H_
+
+extern int zcache_put(int, int, struct tmem_oid *, uint32_t,
+			char *, size_t, bool, int);
+extern int zcache_autocreate_pool(int, int, bool);
+extern int zcache_get(int, int, struct tmem_oid *, uint32_t,
+			char *, size_t *, bool, int);
+extern int zcache_flush(int, int, struct tmem_oid *, uint32_t);
+extern int zcache_flush_object(int, int, struct tmem_oid *);
+extern int zcache_localify(int, struct tmem_oid *, uint32_t,
+			char *, size_t, void *);
+
+#endif /* _ZCACHE_H */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
