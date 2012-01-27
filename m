Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id C4FD06B0062
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 11:27:48 -0500 (EST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 3/6] staging: ramster: ramster-specific changes to cluster code
Date: Fri, 27 Jan 2012 08:27:39 -0800
Message-Id: <1327681659-9470-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, gregkh@suse.de, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, kurt.hackel@oracle.com, sjenning@linux.vnet.ibm.com, chris.mason@oracle.com, dan.magenheimer@oracle.com

Ramster-specific changes to ocfs2 cluster foundation, including:
A method for fooling the o2 heartbeat into starting without
an ocfs2 filesystem; a new message mechanism ("data magic") for handling
a reply to a message requesting data; a hack for keeping the cluster
alive even after timeouts so cluster machines can be rebooted separately.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/ramster/cluster/Makefile       |    3 +-
 drivers/staging/ramster/cluster/heartbeat.c    |    9 ++
 drivers/staging/ramster/cluster/heartbeat.h    |    3 +
 drivers/staging/ramster/cluster/tcp.c          |  112 ++++++++++++++++++++++++
 drivers/staging/ramster/cluster/tcp.h          |    6 ++
 drivers/staging/ramster/cluster/tcp_internal.h |    7 ++
 6 files changed, 139 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/ramster/cluster/Makefile b/drivers/staging/ramster/cluster/Makefile
index bc8c5e7..3fc8550 100644
--- a/drivers/staging/ramster/cluster/Makefile
+++ b/drivers/staging/ramster/cluster/Makefile
@@ -1,4 +1,5 @@
-obj-$(CONFIG_OCFS2_FS) += ocfs2_nodemanager.o
+#obj-$(CONFIG_OCFS2_FS) += ocfs2_nodemanager.o
+obj-$(CONFIG_RAMSTER) += ocfs2_nodemanager.o
 
 ocfs2_nodemanager-objs := heartbeat.o masklog.o sys.o nodemanager.o \
 	quorum.o tcp.o netdebug.o ver.o
diff --git a/drivers/staging/ramster/cluster/heartbeat.c b/drivers/staging/ramster/cluster/heartbeat.c
index a4e855e..1f72143 100644
--- a/drivers/staging/ramster/cluster/heartbeat.c
+++ b/drivers/staging/ramster/cluster/heartbeat.c
@@ -2676,3 +2676,12 @@ int o2hb_global_heartbeat_active(void)
 	return (o2hb_heartbeat_mode == O2HB_HEARTBEAT_GLOBAL);
 }
 EXPORT_SYMBOL(o2hb_global_heartbeat_active);
+
+#ifdef CONFIG_RAMSTER
+void o2hb_manual_set_node_heartbeating(int node_num)
+{
+	if (node_num < O2NM_MAX_NODES)
+		set_bit(node_num, o2hb_live_node_bitmap);
+}
+EXPORT_SYMBOL(o2hb_manual_set_node_heartbeating);
+#endif
diff --git a/drivers/staging/ramster/cluster/heartbeat.h b/drivers/staging/ramster/cluster/heartbeat.h
index 00ad8e8..cf1a164 100644
--- a/drivers/staging/ramster/cluster/heartbeat.h
+++ b/drivers/staging/ramster/cluster/heartbeat.h
@@ -85,5 +85,8 @@ int o2hb_check_local_node_heartbeating(void);
 void o2hb_stop_all_regions(void);
 int o2hb_get_all_regions(char *region_uuids, u8 numregions);
 int o2hb_global_heartbeat_active(void);
+#ifdef CONFIG_RAMSTER
+void o2hb_manual_set_node_heartbeating(int);
+#endif
 
 #endif /* O2CLUSTER_HEARTBEAT_H */
diff --git a/drivers/staging/ramster/cluster/tcp.c b/drivers/staging/ramster/cluster/tcp.c
index 044e7b5..e9bd00e 100644
--- a/drivers/staging/ramster/cluster/tcp.c
+++ b/drivers/staging/ramster/cluster/tcp.c
@@ -288,7 +288,11 @@ static inline int o2net_sys_err_to_errno(enum o2net_system_error err)
 	return trans;
 }
 
+#ifdef CONFIG_RAMSTER
+struct o2net_node *o2net_nn_from_num(u8 node_num)
+#else
 static struct o2net_node * o2net_nn_from_num(u8 node_num)
+#endif
 {
 	BUG_ON(node_num >= ARRAY_SIZE(o2net_nodes));
 	return &o2net_nodes[node_num];
@@ -1068,6 +1072,11 @@ int o2net_send_message_vec(u32 msg_type, u32 key, struct kvec *caller_vec,
 	};
 	struct o2net_send_tracking nst;
 
+#ifdef CONFIG_RAMSTER
+	/* this may be a general bug fix */
+	init_waitqueue_head(&nsw.ns_wq);
+#endif
+
 	o2net_init_nst(&nst, msg_type, key, current, target_node);
 
 	if (o2net_wq == NULL) {
@@ -1208,6 +1217,52 @@ static int o2net_send_status_magic(struct socket *sock, struct o2net_msg *hdr,
 	return o2net_send_tcp_msg(sock, &vec, 1, sizeof(struct o2net_msg));
 }
 
+#ifdef CONFIG_RAMSTER
+/*
+ * "data magic" is a long version of "status magic" where the message
+ * payload actually contains data to be passed in reply to certain messages
+ */
+static int o2net_send_data_magic(struct o2net_sock_container *sc,
+			  struct o2net_msg *hdr,
+			  void *data, size_t data_len,
+			  enum o2net_system_error syserr, int err)
+{
+	struct kvec vec[2];
+	int ret;
+
+	vec[0].iov_base = hdr;
+	vec[0].iov_len = sizeof(struct o2net_msg);
+	vec[1].iov_base = data;
+	vec[1].iov_len = data_len;
+
+	BUG_ON(syserr >= O2NET_ERR_MAX);
+
+	/* leave other fields intact from the incoming message, msg_num
+	 * in particular */
+	hdr->sys_status = cpu_to_be32(syserr);
+	hdr->status = cpu_to_be32(err);
+	hdr->magic = cpu_to_be16(O2NET_MSG_DATA_MAGIC);  /* twiddle magic */
+	hdr->data_len = cpu_to_be16(data_len);
+
+	msglog(hdr, "about to send data magic %d\n", err);
+	/* hdr has been in host byteorder this whole time */
+	ret = o2net_send_tcp_msg(sc->sc_sock, vec, 2,
+			sizeof(struct o2net_msg) + data_len);
+	return ret;
+}
+
+/*
+ * called by a message handler to convert an otherwise normal reply
+ * message into a "data magic" message
+ */
+void o2net_force_data_magic(struct o2net_msg *hdr, u16 msgtype, u32 msgkey)
+{
+	hdr->magic = cpu_to_be16(O2NET_MSG_DATA_MAGIC);
+	hdr->msg_type = cpu_to_be16(msgtype);
+	hdr->key = cpu_to_be32(msgkey);
+}
+#endif
+
 /* this returns -errno if the header was unknown or too large, etc.
  * after this is called the buffer us reused for the next message */
 static int o2net_process_message(struct o2net_sock_container *sc,
@@ -1218,6 +1273,9 @@ static int o2net_process_message(struct o2net_sock_container *sc,
 	enum  o2net_system_error syserr;
 	struct o2net_msg_handler *nmh = NULL;
 	void *ret_data = NULL;
+#ifdef CONFIG_RAMSTER
+	int data_magic = 0;
+#endif
 
 	msglog(hdr, "processing message\n");
 
@@ -1239,6 +1297,16 @@ static int o2net_process_message(struct o2net_sock_container *sc,
 			goto out;
 		case O2NET_MSG_MAGIC:
 			break;
+#ifdef CONFIG_RAMSTER
+		case O2NET_MSG_DATA_MAGIC:
+			/*
+			 * unlike a normal status magic, a data magic DOES
+			 * (MUST) have a handler, so the control flow is
+			 * a little funky here as a result
+			 */
+			data_magic = 1;
+			break;
+#endif
 		default:
 			msglog(hdr, "bad magic\n");
 			ret = -EINVAL;
@@ -1271,6 +1339,34 @@ static int o2net_process_message(struct o2net_sock_container *sc,
 	handler_status = (nmh->nh_func)(hdr, sizeof(struct o2net_msg) +
 					     be16_to_cpu(hdr->data_len),
 					nmh->nh_func_data, &ret_data);
+#ifdef CONFIG_RAMSTER
+	if (data_magic) {
+		/*
+		 * handler handled data sent in reply to request
+		 * so complete the transaction
+		 */
+		o2net_complete_nsw(nn, NULL, be32_to_cpu(hdr->msg_num),
+			be32_to_cpu(hdr->sys_status), handler_status);
+		goto out;
+	}
+	/*
+	 * handler changed magic to DATA_MAGIC to reply to request for data,
+	 * implies ret_data points to data to return and handler_status
+	 * is the number of bytes of data
+	 */
+	if (be16_to_cpu(hdr->magic) == O2NET_MSG_DATA_MAGIC) {
+		ret = o2net_send_data_magic(sc, hdr,
+						ret_data, handler_status,
+						syserr, 0);
+		hdr = NULL;
+		mlog(0, "sending data reply %d, syserr %d returned %d\n",
+			handler_status, syserr, ret);
+		o2net_set_func_stop_time(sc);
+
+		o2net_update_recv_stats(sc);
+		goto out;
+	}
+#endif
 	o2net_set_func_stop_time(sc);
 
 	o2net_update_recv_stats(sc);
@@ -1558,7 +1654,9 @@ static void o2net_sc_send_keep_req(struct work_struct *work)
 static void o2net_idle_timer(unsigned long data)
 {
 	struct o2net_sock_container *sc = (struct o2net_sock_container *)data;
+#ifndef CONFIG_RAMSTER
 	struct o2net_node *nn = o2net_nn_from_num(sc->sc_node->nd_num);
+#endif
 #ifdef CONFIG_DEBUG_FS
 	unsigned long msecs = ktime_to_ms(ktime_get()) -
 		ktime_to_ms(sc->sc_tv_timer);
@@ -1574,9 +1672,14 @@ static void o2net_idle_timer(unsigned long data)
 	 * Initialize the nn_timeout so that the next connection attempt
 	 * will continue in o2net_start_connect.
 	 */
+#ifdef CONFIG_RAMSTER
+	/* Avoid spurious shutdowns... not sure if this is still necessary */
+	pr_err("o2net_idle_timer, skipping shutdown work\n");
+#else
 	atomic_set(&nn->nn_timeout, 1);
 
 	o2net_sc_queue_work(sc, &sc->sc_shutdown_work);
+#endif
 }
 
 static void o2net_sc_reset_idle_timer(struct o2net_sock_container *sc)
@@ -2094,6 +2197,15 @@ void o2net_stop_listening(struct o2nm_node *node)
 	o2quo_conn_err(node->nd_num);
 }
 
+#ifdef CONFIG_RAMSTER
+void o2net_hb_node_up_manual(int node_num)
+{
+	struct o2nm_node dummy;
+	o2hb_manual_set_node_heartbeating(node_num);
+	o2net_hb_node_up_cb(&dummy, node_num, NULL);
+}
+#endif
+
 /* ------------------------------------------------------------ */
 
 int o2net_init(void)
diff --git a/drivers/staging/ramster/cluster/tcp.h b/drivers/staging/ramster/cluster/tcp.h
index 5bada2a..95a991f 100644
--- a/drivers/staging/ramster/cluster/tcp.h
+++ b/drivers/staging/ramster/cluster/tcp.h
@@ -108,6 +108,12 @@ void o2net_unregister_handler_list(struct list_head *list);
 
 void o2net_fill_node_map(unsigned long *map, unsigned bytes);
 
+#ifdef CONFIG_RAMSTER
+void o2net_force_data_magic(struct o2net_msg *, u16, u32);
+void o2net_hb_node_up_manual(int);
+struct o2net_node *o2net_nn_from_num(u8);
+#endif
+
 struct o2nm_node;
 int o2net_register_hb_callbacks(void);
 void o2net_unregister_hb_callbacks(void);
diff --git a/drivers/staging/ramster/cluster/tcp_internal.h b/drivers/staging/ramster/cluster/tcp_internal.h
index 4cbcb65..ce17135 100644
--- a/drivers/staging/ramster/cluster/tcp_internal.h
+++ b/drivers/staging/ramster/cluster/tcp_internal.h
@@ -26,6 +26,13 @@
 #define O2NET_MSG_STATUS_MAGIC    ((u16)0xfa56)
 #define O2NET_MSG_KEEP_REQ_MAGIC  ((u16)0xfa57)
 #define O2NET_MSG_KEEP_RESP_MAGIC ((u16)0xfa58)
+#ifdef CONFIG_RAMSTER
+/*
+ * "data magic" is a long version of "status magic" where the message
+ * payload actually contains data to be passed in reply to certain messages
+ */
+#define O2NET_MSG_DATA_MAGIC      ((u16)0xfa59)
+#endif
 
 /* we're delaying our quorum decision so that heartbeat will have timed
  * out truly dead nodes by the time we come around to making decisions
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
