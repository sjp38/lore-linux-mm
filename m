Message-Id: <20070504103204.881538430@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:31 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 40/40] iscsi: support for swapping over iSCSI.
Content-Disposition: inline; filename=iscsi_vmio.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

Set blk_queue_swapdev for iSCSI. This method takes care of reserving the
extra memory needed and marking all relevant sockets with SOCK_VMIO.

When used for swapping, TCP socket creation is done under GFP_MEMALLOC and
the TCP connect is done with SOCK_VMIO to ensure their success. 

Also the netlink userspace interface is marked SOCK_VMIO, this will ensure
that even under pressure we can still communicate with the daemon (which
runs as mlockall() and needs no additional memory to operate).

Netlink requests are handled under the new PF_MEM_NOWAIT when a swapper is
present. This ensures that the netlink socket will not block. User-space
will need to retry failed requests.

The TCP receive path is handled under PF_MEMALLOC for SOCK_VMIO sockets.
This makes sure we do not block the critical socket, and that we do not
fail to process incoming data.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Mike Christie <michaelc@cs.wisc.edu>
---
 drivers/scsi/Kconfig                |   17 ++++++++
 drivers/scsi/iscsi_tcp.c            |   70 ++++++++++++++++++++++++++++++++---
 drivers/scsi/libiscsi.c             |   18 ++++++---
 drivers/scsi/qla4xxx/ql4_os.c       |    2 -
 drivers/scsi/scsi_transport_iscsi.c |   72 ++++++++++++++++++++++++++++++++----
 include/scsi/scsi_transport_iscsi.h |   12 +++++-
 6 files changed, 170 insertions(+), 21 deletions(-)

Index: linux-2.6-git/drivers/scsi/iscsi_tcp.c
===================================================================
--- linux-2.6-git.orig/drivers/scsi/iscsi_tcp.c	2007-03-26 12:59:39.000000000 +0200
+++ linux-2.6-git/drivers/scsi/iscsi_tcp.c	2007-03-26 13:07:54.000000000 +0200
@@ -42,6 +42,7 @@
 #include <scsi/scsi_host.h>
 #include <scsi/scsi.h>
 #include <scsi/scsi_transport_iscsi.h>
+#include <scsi/scsi_device.h>
 
 #include "iscsi_tcp.h"
 
@@ -1740,15 +1741,19 @@ iscsi_tcp_ep_connect(struct sockaddr *ds
 {
 	struct socket *sock;
 	int rc, size;
+	int swapper = sk_vmio_socks();
+	unsigned long pflags = current->flags;
+
+	if (swapper)
+		pflags |= PF_MEMALLOC;
 
 	rc = sock_create_kern(dst_addr->sa_family, SOCK_STREAM, IPPROTO_TCP,
 			      &sock);
 	if (rc < 0) {
 		printk(KERN_ERR "Could not create socket %d.\n", rc);
-		return rc;
+		goto out;
 	}
-	/* TODO: test this with GFP_NOIO */
-	sock->sk->sk_allocation = GFP_ATOMIC;
+	sock->sk->sk_allocation = GFP_NOIO;
 
 	if (dst_addr->sa_family == PF_INET)
 		size = sizeof(struct sockaddr_in);
@@ -1765,6 +1770,8 @@ iscsi_tcp_ep_connect(struct sockaddr *ds
 	 * we don't want it used by user-space at all.
 	 */
 	sock_set_flag(sock->sk, SOCK_KERNEL);
+	if (swapper)
+		sk_set_vmio(sock->sk);
 
 	rc = sock->ops->connect(sock, (struct sockaddr *)dst_addr, size,
 				O_NONBLOCK);
@@ -1779,11 +1786,14 @@ iscsi_tcp_ep_connect(struct sockaddr *ds
 	if (rc < 0)
 		goto release_sock;
 	*ep_handle = (uint64_t)rc;
-	return 0;
+	rc = 0;
+out:
+	current->flags = pflags;
+	return rc;
 
 release_sock:
 	sock_release(sock);
-	return rc;
+	goto out;
 }
 
 static struct iscsi_cls_conn *
@@ -1908,8 +1918,13 @@ iscsi_tcp_conn_bind(struct iscsi_cls_ses
 	sk->sk_reuse = 1;
 	sk->sk_sndtimeo = 15 * HZ; /* FIXME: make it configurable */
 
+	if (!cls_session->swapper && sk_has_vmio(sk))
+		sk_clear_vmio(sk);
+
 	/* FIXME: disable Nagle's algorithm */
 
+	BUG_ON(!sk_has_vmio(sk) && cls_session->swapper);
+
 	/*
 	 * Intercept TCP callbacks for sendfile like receive
 	 * processing.
@@ -2167,6 +2182,50 @@ static void iscsi_tcp_session_destroy(st
 	iscsi_session_teardown(cls_session);
 }
 
+#ifdef CONFIG_ISCSI_TCP_SWAP
+
+#define ISCSI_TCP_RESERVE_PAGES	(TX_RESERVE_PAGES)
+
+static int iscsi_tcp_swapdev(void *objp, int enable)
+{
+	int error = 0;
+	struct scsi_device *sdev = objp;
+	struct Scsi_Host *shost = sdev->host;
+	struct iscsi_session *session = iscsi_hostdata(shost->hostdata);
+
+	if (enable) {
+		iscsi_swapdev(session->tt, session_to_cls(session), 1);
+		sk_adjust_memalloc(1, ISCSI_TCP_RESERVE_PAGES);
+	}
+
+	spin_lock(&session->lock);
+	if (session->leadconn) {
+		struct iscsi_tcp_conn *tcp_conn = session->leadconn->dd_data;
+		if (enable)
+			sk_set_vmio(tcp_conn->sock->sk);
+		else
+			sk_clear_vmio(tcp_conn->sock->sk);
+	}
+	spin_unlock(&session->lock);
+
+	if (!enable) {
+		sk_adjust_memalloc(-1, -ISCSI_TCP_RESERVE_PAGES);
+		iscsi_swapdev(session->tt, session_to_cls(session), 0);
+	}
+
+	return error;
+}
+#endif
+
+static int iscsi_tcp_slave_configure(struct scsi_device *sdev)
+{
+#ifdef CONFIG_ISCSI_TCP_SWAP
+	if (sdev->type == TYPE_DISK)
+		blk_queue_swapdev(sdev->request_queue, iscsi_tcp_swapdev, sdev);
+#endif
+	return 0;
+}
+
 static struct scsi_host_template iscsi_sht = {
 	.name			= "iSCSI Initiator over TCP/IP",
 	.queuecommand           = iscsi_queuecommand,
@@ -2174,6 +2233,7 @@ static struct scsi_host_template iscsi_s
 	.can_queue		= ISCSI_XMIT_CMDS_MAX - 1,
 	.sg_tablesize		= ISCSI_SG_TABLESIZE,
 	.cmd_per_lun		= ISCSI_DEF_CMD_PER_LUN,
+	.slave_configure	= iscsi_tcp_slave_configure,
 	.eh_abort_handler       = iscsi_eh_abort,
 	.eh_host_reset_handler	= iscsi_eh_host_reset,
 	.use_clustering         = DISABLE_CLUSTERING,
Index: linux-2.6-git/drivers/scsi/scsi_transport_iscsi.c
===================================================================
--- linux-2.6-git.orig/drivers/scsi/scsi_transport_iscsi.c	2007-03-26 12:59:39.000000000 +0200
+++ linux-2.6-git/drivers/scsi/scsi_transport_iscsi.c	2007-03-26 13:15:15.000000000 +0200
@@ -498,6 +498,47 @@ iscsi_if_transport_lookup(struct iscsi_t
 	return NULL;
 }
 
+#ifdef CONFIG_ISCSI_SWAP
+static int iscsi_netlink_sk_vmio(u32 pid, int enable)
+{
+	int rc = -EINVAL;
+	struct sock *sk = netlink_lookup(NETLINK_ISCSI, pid);
+	if (sk) {
+		if (enable)
+			rc = sk_set_vmio(sk);
+		else
+			rc = sk_clear_vmio(sk);
+		sock_put(sk);
+	}
+	return rc;
+}
+
+#define ISCSI_NETLINK_RESERVE_PAGES	(5 + 2 * (5 + 31))
+
+int iscsi_swapdev(struct iscsi_transport *tt,
+		  struct iscsi_cls_session *cls_session, int enable)
+{
+	int pid = iscsi_if_transport_lookup(tt)->daemon_pid;
+
+	if (enable)
+		sk_adjust_memalloc(0, ISCSI_NETLINK_RESERVE_PAGES);
+	else
+		cls_session->swapper = 0;
+
+	iscsi_netlink_sk_vmio(0, enable);
+	iscsi_netlink_sk_vmio(pid, enable);
+
+	if (!enable)
+		sk_adjust_memalloc(0, -ISCSI_NETLINK_RESERVE_PAGES);
+	else
+		cls_session->swapper = 1;
+
+	return 0;
+}
+
+EXPORT_SYMBOL_GPL(iscsi_swapdev);
+#endif
+
 static int
 iscsi_broadcast_skb(struct sk_buff *skb, gfp_t gfp)
 {
@@ -527,7 +568,7 @@ iscsi_unicast_skb(struct sk_buff *skb, i
 }
 
 int iscsi_recv_pdu(struct iscsi_cls_conn *conn, struct iscsi_hdr *hdr,
-		   char *data, uint32_t data_size)
+		   char *data, uint32_t data_size, gfp_t gfp_mask)
 {
 	struct nlmsghdr	*nlh;
 	struct sk_buff *skb;
@@ -541,9 +582,9 @@ int iscsi_recv_pdu(struct iscsi_cls_conn
 	if (!priv)
 		return -EINVAL;
 
-	skb = alloc_skb(len, GFP_ATOMIC);
+	skb = alloc_skb(len, gfp_mask);
 	if (!skb) {
-		iscsi_conn_error(conn, ISCSI_ERR_CONN_FAILED);
+		iscsi_conn_error(conn, ISCSI_ERR_CONN_FAILED, gfp_mask);
 		dev_printk(KERN_ERR, &conn->dev, "iscsi: can not deliver "
 			   "control PDU: OOM\n");
 		return -ENOMEM;
@@ -564,7 +605,8 @@ int iscsi_recv_pdu(struct iscsi_cls_conn
 }
 EXPORT_SYMBOL_GPL(iscsi_recv_pdu);
 
-void iscsi_conn_error(struct iscsi_cls_conn *conn, enum iscsi_err error)
+void iscsi_conn_error(struct iscsi_cls_conn *conn, enum iscsi_err error,
+		      gfp_t gfp_mask)
 {
 	struct nlmsghdr	*nlh;
 	struct sk_buff	*skb;
@@ -576,7 +618,7 @@ void iscsi_conn_error(struct iscsi_cls_c
 	if (!priv)
 		return;
 
-	skb = alloc_skb(len, GFP_ATOMIC);
+	skb = alloc_skb(len, gfp_mask);
 	if (!skb) {
 		dev_printk(KERN_ERR, &conn->dev, "iscsi: gracefully ignored "
 			  "conn error (%d)\n", error);
@@ -591,7 +633,7 @@ void iscsi_conn_error(struct iscsi_cls_c
 	ev->r.connerror.cid = conn->cid;
 	ev->r.connerror.sid = iscsi_conn_get_sid(conn);
 
-	iscsi_broadcast_skb(skb, GFP_ATOMIC);
+	iscsi_broadcast_skb(skb, gfp_mask);
 
 	dev_printk(KERN_INFO, &conn->dev, "iscsi: detected conn error (%d)\n",
 		   error);
@@ -608,7 +650,7 @@ iscsi_if_send_reply(int pid, int seq, in
 	int flags = multi ? NLM_F_MULTI : 0;
 	int t = done ? NLMSG_DONE : type;
 
-	skb = alloc_skb(len, GFP_ATOMIC);
+	skb = alloc_skb(len, nls->sk_allocation);
 	/*
 	 * FIXME:
 	 * user is supposed to react on iferror == -ENOMEM;
@@ -686,6 +728,7 @@ iscsi_if_get_stats(struct iscsi_transpor
 	return err;
 }
 
+#if 0
 /**
  * iscsi_if_destroy_session_done - send session destr. completion event
  * @conn: last connection for session
@@ -806,6 +849,7 @@ int iscsi_if_create_session_done(struct 
 	return rc;
 }
 EXPORT_SYMBOL_GPL(iscsi_if_create_session_done);
+#endif
 
 static int
 iscsi_if_create_session(struct iscsi_internal *priv, struct iscsi_uevent *ev)
@@ -968,6 +1012,7 @@ iscsi_if_recv_msg(struct sk_buff *skb, s
 	struct iscsi_cls_session *session;
 	struct iscsi_cls_conn *conn;
 	unsigned long flags;
+	int pid;
 
 	priv = iscsi_if_transport_lookup(iscsi_ptr(ev->transport_handle));
 	if (!priv)
@@ -977,7 +1022,15 @@ iscsi_if_recv_msg(struct sk_buff *skb, s
 	if (!try_module_get(transport->owner))
 		return -EINVAL;
 
-	priv->daemon_pid = NETLINK_CREDS(skb)->pid;
+	pid = NETLINK_CREDS(skb)->pid;
+	if (priv->daemon_pid > 0 && priv->daemon_pid != pid) {
+		if (sk_has_vmio(nls)) {
+			struct sock * sk = netlink_lookup(NETLINK_ISCSI, pid);
+			BUG_ON(!sk);
+			WARN_ON(!sk_set_vmio(sk));
+		}
+	}
+	priv->daemon_pid = pid;
 
 	switch (nlh->nlmsg_type) {
 	case ISCSI_UEVENT_CREATE_SESSION:
@@ -1092,7 +1145,10 @@ iscsi_if_rx(struct sock *sk, int len)
 			if (rlen > skb->len)
 				rlen = skb->len;
 
+			if (sk_has_vmio(sk))
+				current->flags |= PF_MEM_NOWAIT;
 			err = iscsi_if_recv_msg(skb, nlh);
+			current->flags &= ~PF_MEM_NOWAIT;
 			if (err) {
 				ev->type = ISCSI_KEVENT_IF_ERROR;
 				ev->iferror = err;
Index: linux-2.6-git/include/scsi/scsi_transport_iscsi.h
===================================================================
--- linux-2.6-git.orig/include/scsi/scsi_transport_iscsi.h	2007-03-26 12:59:39.000000000 +0200
+++ linux-2.6-git/include/scsi/scsi_transport_iscsi.h	2007-03-26 12:59:39.000000000 +0200
@@ -137,9 +137,10 @@ extern int iscsi_unregister_transport(st
 /*
  * control plane upcalls
  */
-extern void iscsi_conn_error(struct iscsi_cls_conn *conn, enum iscsi_err error);
+extern void iscsi_conn_error(struct iscsi_cls_conn *conn, enum iscsi_err error,
+			     gfp_t gfp_mask);
 extern int iscsi_recv_pdu(struct iscsi_cls_conn *conn, struct iscsi_hdr *hdr,
-			  char *data, uint32_t data_size);
+			  char *data, uint32_t data_size, gfp_t gfp_mask);
 
 
 /* Connection's states */
@@ -183,6 +184,7 @@ struct iscsi_cls_session {
 	int sid;				/* session id */
 	void *dd_data;				/* LLD private data */
 	struct device dev;	/* sysfs transport/container device */
+	int swapper;				/* we are used to swap on */
 };
 
 #define iscsi_dev_to_session(_dev) \
@@ -194,6 +196,10 @@ struct iscsi_cls_session {
 #define starget_to_session(_stgt) \
 	iscsi_dev_to_session(_stgt->dev.parent)
 
+#define iscsi_session_gfp(_session) \
+	((in_interrupt() ? GFP_ATOMIC : GFP_NOIO) | \
+	 ((_session)->swapper ? __GFP_EMERGENCY : 0))
+
 struct iscsi_host {
 	struct list_head sessions;
 	struct mutex mutex;
@@ -217,6 +223,8 @@ extern int iscsi_destroy_session(struct 
 extern struct iscsi_cls_conn *iscsi_create_conn(struct iscsi_cls_session *sess,
 					    uint32_t cid);
 extern int iscsi_destroy_conn(struct iscsi_cls_conn *conn);
+extern int iscsi_swapdev(struct iscsi_transport *tt, struct iscsi_cls_session *,
+			 int enable);
 extern void iscsi_unblock_session(struct iscsi_cls_session *session);
 extern void iscsi_block_session(struct iscsi_cls_session *session);
 
Index: linux-2.6-git/drivers/scsi/libiscsi.c
===================================================================
--- linux-2.6-git.orig/drivers/scsi/libiscsi.c	2007-03-26 12:59:39.000000000 +0200
+++ linux-2.6-git/drivers/scsi/libiscsi.c	2007-03-26 12:59:39.000000000 +0200
@@ -361,10 +361,12 @@ int __iscsi_complete_pdu(struct iscsi_co
 			 char *data, int datalen)
 {
 	struct iscsi_session *session = conn->session;
+	struct iscsi_cls_session *cls_session = session_to_cls(session);
 	int opcode = hdr->opcode & ISCSI_OPCODE_MASK, rc = 0;
 	struct iscsi_cmd_task *ctask;
 	struct iscsi_mgmt_task *mtask;
 	uint32_t itt;
+	gfp_t gfp_mask = iscsi_session_gfp(cls_session);
 
 	if (hdr->itt != RESERVED_ITT)
 		itt = get_itt(hdr->itt);
@@ -423,7 +425,8 @@ int __iscsi_complete_pdu(struct iscsi_co
 			 * login related PDU's exp_statsn is handled in
 			 * userspace
 			 */
-			if (iscsi_recv_pdu(conn->cls_conn, hdr, data, datalen))
+			if (iscsi_recv_pdu(conn->cls_conn, hdr, data, datalen,
+						gfp_mask))
 				rc = ISCSI_ERR_CONN_FAILED;
 			list_del(&mtask->running);
 			if (conn->login_mtask != mtask)
@@ -445,7 +448,8 @@ int __iscsi_complete_pdu(struct iscsi_co
 			}
 			conn->exp_statsn = be32_to_cpu(hdr->statsn) + 1;
 
-			if (iscsi_recv_pdu(conn->cls_conn, hdr, data, datalen))
+			if (iscsi_recv_pdu(conn->cls_conn, hdr, data, datalen,
+						gfp_mask))
 				rc = ISCSI_ERR_CONN_FAILED;
 			list_del(&mtask->running);
 			if (conn->login_mtask != mtask)
@@ -472,7 +476,8 @@ int __iscsi_complete_pdu(struct iscsi_co
 			if (hdr->ttt == cpu_to_be32(ISCSI_RESERVED_TAG))
 				break;
 
-			if (iscsi_recv_pdu(conn->cls_conn, hdr, NULL, 0))
+			if (iscsi_recv_pdu(conn->cls_conn, hdr, NULL, 0,
+						gfp_mask))
 				rc = ISCSI_ERR_CONN_FAILED;
 			break;
 		case ISCSI_OP_REJECT:
@@ -480,7 +485,8 @@ int __iscsi_complete_pdu(struct iscsi_co
 			break;
 		case ISCSI_OP_ASYNC_EVENT:
 			conn->exp_statsn = be32_to_cpu(hdr->statsn) + 1;
-			if (iscsi_recv_pdu(conn->cls_conn, hdr, data, datalen))
+			if (iscsi_recv_pdu(conn->cls_conn, hdr, data, datalen,
+						gfp_mask))
 				rc = ISCSI_ERR_CONN_FAILED;
 			break;
 		default:
@@ -560,7 +566,9 @@ EXPORT_SYMBOL_GPL(iscsi_verify_itt);
 void iscsi_conn_failure(struct iscsi_conn *conn, enum iscsi_err err)
 {
 	struct iscsi_session *session = conn->session;
+	struct iscsi_cls_session *cls_session = session_to_cls(session);
 	unsigned long flags;
+	gfp_t gfp_mask = iscsi_session_gfp(cls_session);
 
 	spin_lock_irqsave(&session->lock, flags);
 	if (session->state == ISCSI_STATE_FAILED) {
@@ -573,7 +581,7 @@ void iscsi_conn_failure(struct iscsi_con
 	spin_unlock_irqrestore(&session->lock, flags);
 	set_bit(ISCSI_SUSPEND_BIT, &conn->suspend_tx);
 	set_bit(ISCSI_SUSPEND_BIT, &conn->suspend_rx);
-	iscsi_conn_error(conn->cls_conn, err);
+	iscsi_conn_error(conn->cls_conn, err, gfp_mask);
 }
 EXPORT_SYMBOL_GPL(iscsi_conn_failure);
 
Index: linux-2.6-git/drivers/scsi/qla4xxx/ql4_os.c
===================================================================
--- linux-2.6-git.orig/drivers/scsi/qla4xxx/ql4_os.c	2007-03-26 12:38:34.000000000 +0200
+++ linux-2.6-git/drivers/scsi/qla4xxx/ql4_os.c	2007-03-26 12:59:39.000000000 +0200
@@ -340,7 +340,7 @@ void qla4xxx_mark_device_missing(struct 
 	DEBUG3(printk("scsi%d:%d:%d: index [%d] marked MISSING\n",
 		      ha->host_no, ddb_entry->bus, ddb_entry->target,
 		      ddb_entry->fw_ddb_index));
-	iscsi_conn_error(ddb_entry->conn, ISCSI_ERR_CONN_FAILED);
+	iscsi_conn_error(ddb_entry->conn, ISCSI_ERR_CONN_FAILED, GFP_ATOMIC);
 }
 
 static struct srb* qla4xxx_get_new_srb(struct scsi_qla_host *ha,
Index: linux-2.6-git/drivers/scsi/Kconfig
===================================================================
--- linux-2.6-git.orig/drivers/scsi/Kconfig	2007-03-26 13:00:05.000000000 +0200
+++ linux-2.6-git/drivers/scsi/Kconfig	2007-03-26 13:14:25.000000000 +0200
@@ -268,6 +268,12 @@ config SCSI_ISCSI_ATTRS
 	  each attached iSCSI device to sysfs, say Y.
 	  Otherwise, say N.
 
+config ISCSI_SWAP
+	def_bool n
+	depends on SCSI_ISCSI_ATTRS
+	select SLAB_FAIR
+	select NETVM
+
 config SCSI_SAS_ATTRS
 	tristate "SAS Transport Attributes"
 	depends on SCSI
@@ -306,6 +312,17 @@ config ISCSI_TCP
 
 	 http://linux-iscsi.sf.net
 
+config ISCSI_TCP_SWAP
+	bool "Provide swap over iSCSI over TCP/IP"
+	default n
+	depends on ISCSI_TCP
+	select ISCSI_SWAP
+	help
+	  This option enables swapon to savely work with iSCSI over TCP/IP
+	  devices.
+
+	  If unsure, say N.
+
 config SGIWD93_SCSI
 	tristate "SGI WD93C93 SCSI Driver"
 	depends on SGI_IP22 && SCSI

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
