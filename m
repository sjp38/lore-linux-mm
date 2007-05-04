Message-Id: <20070504103203.662512889@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:26 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 35/40] From: Mike Christie <mchristi@redhat.com>
Content-Disposition: inline; filename=iscsi_ep_connect.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Mike Christie <mchristi@redhat.com>
List-ID: <linux-mm.kvack.org>

This patch has iscsi_tcp implement a ep_connect callback. We only do the
connect for now and let userspace do the poll and close. I do not like
the lack of symmetry but doing sys_close in iscsi_tcp felt a little creepy.

This patch also fixes a bug where when iscsid restarts while sessions
are running, we leak the ep object. This occurs because iscsid, when it
restarts, does not know the connection and ep relationship. To fix this,
I just export the ep handle sysfs. Or I converted iser in this patch.

Signed-off-by: Mike Christie <mchristi@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 drivers/infiniband/ulp/iser/iscsi_iser.c |    4 -
 drivers/scsi/iscsi_tcp.c                 |   99 +++++++++++++++++--------------
 drivers/scsi/libiscsi.c                  |    8 ++
 drivers/scsi/scsi_transport_iscsi.c      |    4 -
 include/scsi/iscsi_if.h                  |    4 -
 include/scsi/libiscsi.h                  |    3 
 include/scsi/scsi_transport_iscsi.h      |    2 
 7 files changed, 75 insertions(+), 49 deletions(-)

Index: linux-2.6-git/drivers/infiniband/ulp/iser/iscsi_iser.c
===================================================================
--- linux-2.6-git.orig/drivers/infiniband/ulp/iser/iscsi_iser.c	2007-01-25 11:57:44.000000000 +0100
+++ linux-2.6-git/drivers/infiniband/ulp/iser/iscsi_iser.c	2007-01-25 13:58:45.000000000 +0100
@@ -332,7 +332,8 @@ iscsi_iser_conn_bind(struct iscsi_cls_se
 	struct iser_conn *ib_conn;
 	int error;
 
-	error = iscsi_conn_bind(cls_session, cls_conn, is_leading);
+	error = iscsi_conn_bind(cls_session, cls_conn, is_leading,
+				transport_eph);
 	if (error)
 		return error;
 
@@ -572,6 +573,7 @@ static struct iscsi_transport iscsi_iser
 				  ISCSI_PDU_INORDER_EN |
 				  ISCSI_DATASEQ_INORDER_EN |
 				  ISCSI_EXP_STATSN |
+				  ISCSI_PARAM_EP_HANDLE |
 				  ISCSI_PERSISTENT_PORT |
 				  ISCSI_PERSISTENT_ADDRESS |
 				  ISCSI_TARGET_NAME |
Index: linux-2.6-git/drivers/scsi/iscsi_tcp.c
===================================================================
--- linux-2.6-git.orig/drivers/scsi/iscsi_tcp.c	2007-01-25 13:29:02.000000000 +0100
+++ linux-2.6-git/drivers/scsi/iscsi_tcp.c	2007-01-25 13:58:45.000000000 +0100
@@ -35,6 +35,8 @@
 #include <linux/kfifo.h>
 #include <linux/scatterlist.h>
 #include <linux/mutex.h>
+#include <linux/net.h>
+#include <linux/file.h>
 #include <net/tcp.h>
 #include <scsi/scsi_cmnd.h>
 #include <scsi/scsi_host.h>
@@ -1064,21 +1066,6 @@ iscsi_conn_set_callbacks(struct iscsi_co
 	write_unlock_bh(&sk->sk_callback_lock);
 }
 
-static void
-iscsi_conn_restore_callbacks(struct iscsi_tcp_conn *tcp_conn)
-{
-	struct sock *sk = tcp_conn->sock->sk;
-
-	/* restore socket callbacks, see also: iscsi_conn_set_callbacks() */
-	write_lock_bh(&sk->sk_callback_lock);
-	sk->sk_user_data    = NULL;
-	sk->sk_data_ready   = tcp_conn->old_data_ready;
-	sk->sk_state_change = tcp_conn->old_state_change;
-	sk->sk_write_space  = tcp_conn->old_write_space;
-	sk->sk_no_check	 = 0;
-	write_unlock_bh(&sk->sk_callback_lock);
-}
-
 /**
  * iscsi_send - generic send routine
  * @sk: kernel's socket
@@ -1747,6 +1734,51 @@ iscsi_tcp_ctask_xmit(struct iscsi_conn *
 	return rc;
 }
 
+static int
+iscsi_tcp_ep_connect(struct sockaddr *dst_addr, int non_blocking,
+		     uint64_t *ep_handle)
+{
+	struct socket *sock;
+	int rc, size;
+
+	rc = sock_create_kern(dst_addr->sa_family, SOCK_STREAM, IPPROTO_TCP,
+			      &sock);
+	if (rc < 0) {
+		printk(KERN_ERR "Could not create socket %d.\n", rc);
+		return rc;
+	}
+	/* TODO: test this with GFP_NOIO */
+	sock->sk->sk_allocation = GFP_ATOMIC;
+
+	if (dst_addr->sa_family == PF_INET)
+		size = sizeof(struct sockaddr_in);
+	else if (dst_addr->sa_family == PF_INET6)
+		size = sizeof(struct sockaddr_in6);
+	else {
+		rc = -EINVAL;
+		goto release_sock;
+	}
+
+	rc = sock->ops->connect(sock, (struct sockaddr *)dst_addr, size,
+				O_NONBLOCK);
+	if (rc == -EINPROGRESS)
+		rc = 0;
+	else if (rc) {
+		printk(KERN_ERR "Could not connect %d\n", rc);
+		goto release_sock;
+	}
+
+	rc = sock_map_fd(sock);
+	if (rc < 0)
+		goto release_sock;
+	*ep_handle = (uint64_t)rc;
+	return 0;
+
+release_sock:
+	sock_release(sock);
+	return rc;
+}
+
 static struct iscsi_cls_conn *
 iscsi_tcp_conn_create(struct iscsi_cls_session *cls_session, uint32_t conn_idx)
 {
@@ -1798,31 +1830,12 @@ tcp_conn_alloc_fail:
 }
 
 static void
-iscsi_tcp_release_conn(struct iscsi_conn *conn)
-{
-	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
-
-	if (!tcp_conn->sock)
-		return;
-
-	sock_hold(tcp_conn->sock->sk);
-	iscsi_conn_restore_callbacks(tcp_conn);
-	sock_put(tcp_conn->sock->sk);
-
-	sock_release(tcp_conn->sock);
-	tcp_conn->sock = NULL;
-	conn->recv_lock = NULL;
-}
-
-static void
 iscsi_tcp_conn_destroy(struct iscsi_cls_conn *cls_conn)
 {
 	struct iscsi_conn *conn = cls_conn->dd_data;
 	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
 
-	iscsi_tcp_release_conn(conn);
 	iscsi_conn_teardown(cls_conn);
-
 	if (tcp_conn->tx_hash.tfm)
 		crypto_free_hash(tcp_conn->tx_hash.tfm);
 	if (tcp_conn->rx_hash.tfm)
@@ -1838,7 +1851,6 @@ iscsi_tcp_conn_stop(struct iscsi_cls_con
 	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
 
 	iscsi_conn_stop(cls_conn, flag);
-	iscsi_tcp_release_conn(conn);
 	tcp_conn->hdr_size = sizeof(struct iscsi_hdr);
 }
 
@@ -1860,9 +1872,9 @@ iscsi_tcp_conn_bind(struct iscsi_cls_ses
 		return -EEXIST;
 	}
 
-	err = iscsi_conn_bind(cls_session, cls_conn, is_leading);
+	err = iscsi_conn_bind(cls_session, cls_conn, is_leading, transport_eph);
 	if (err)
-		return err;
+		goto done;
 
 	/* bind iSCSI connection and socket */
 	tcp_conn->sock = sock;
@@ -1871,7 +1883,6 @@ iscsi_tcp_conn_bind(struct iscsi_cls_ses
 	sk = sock->sk;
 	sk->sk_reuse = 1;
 	sk->sk_sndtimeo = 15 * HZ; /* FIXME: make it configurable */
-	sk->sk_allocation = GFP_ATOMIC;
 
 	/* FIXME: disable Nagle's algorithm */
 
@@ -1887,7 +1898,9 @@ iscsi_tcp_conn_bind(struct iscsi_cls_ses
 	 */
 	tcp_conn->in_progress = IN_PROGRESS_WAIT_HEADER;
 
-	return 0;
+done:
+	sockfd_put(sock);
+	return err;
 }
 
 /* called with host lock */
@@ -2163,6 +2176,7 @@ static struct iscsi_transport iscsi_tcp_
 				  ISCSI_PDU_INORDER_EN |
 				  ISCSI_DATASEQ_INORDER_EN |
 				  ISCSI_ERL |
+				  ISCSI_EP_HANDLE |
 				  ISCSI_CONN_PORT |
 				  ISCSI_CONN_ADDRESS |
 				  ISCSI_EXP_STATSN |
@@ -2186,6 +2200,7 @@ static struct iscsi_transport iscsi_tcp_
 	.get_session_param	= iscsi_session_get_param,
 	.start_conn		= iscsi_conn_start,
 	.stop_conn		= iscsi_tcp_conn_stop,
+	.ep_connect		= iscsi_tcp_ep_connect,
 	/* IO */
 	.send_pdu		= iscsi_conn_send_pdu,
 	.get_stats		= iscsi_conn_get_stats,
Index: linux-2.6-git/drivers/scsi/libiscsi.c
===================================================================
--- linux-2.6-git.orig/drivers/scsi/libiscsi.c	2007-01-25 13:29:02.000000000 +0100
+++ linux-2.6-git/drivers/scsi/libiscsi.c	2007-01-25 13:58:45.000000000 +0100
@@ -1793,7 +1793,8 @@ void iscsi_conn_stop(struct iscsi_cls_co
 EXPORT_SYMBOL_GPL(iscsi_conn_stop);
 
 int iscsi_conn_bind(struct iscsi_cls_session *cls_session,
-		    struct iscsi_cls_conn *cls_conn, int is_leading)
+		    struct iscsi_cls_conn *cls_conn, int is_leading,
+		    uint64_t transport_eph)
 {
 	struct iscsi_session *session = class_to_transport_session(cls_session);
 	struct iscsi_conn *conn = cls_conn->dd_data;
@@ -1803,6 +1804,8 @@ int iscsi_conn_bind(struct iscsi_cls_ses
 		session->leadconn = conn;
 	spin_unlock_bh(&session->lock);
 
+	conn->ep_handle = transport_eph;
+
 	/*
 	 * Unblock xmitworker(), Login Phase will pass through.
 	 */
@@ -1983,6 +1986,9 @@ int iscsi_conn_get_param(struct iscsi_cl
 	case ISCSI_PARAM_PERSISTENT_ADDRESS:
 		len = sprintf(buf, "%s\n", conn->persistent_address);
 		break;
+	case ISCSI_PARAM_EP_HANDLE:
+		len = sprintf(buf, "%llu\n", conn->ep_handle);
+		break;
 	default:
 		return -ENOSYS;
 	}
Index: linux-2.6-git/drivers/scsi/scsi_transport_iscsi.c
===================================================================
--- linux-2.6-git.orig/drivers/scsi/scsi_transport_iscsi.c	2007-01-25 13:29:02.000000000 +0100
+++ linux-2.6-git/drivers/scsi/scsi_transport_iscsi.c	2007-01-25 13:58:45.000000000 +0100
@@ -31,7 +31,7 @@
 #include <scsi/iscsi_if.h>
 
 #define ISCSI_SESSION_ATTRS 11
-#define ISCSI_CONN_ATTRS 11
+#define ISCSI_CONN_ATTRS 12
 #define ISCSI_HOST_ATTRS 0
 #define ISCSI_TRANSPORT_VERSION "2.0-724"
 
@@ -1153,6 +1153,7 @@ iscsi_conn_attr(port, ISCSI_PARAM_CONN_P
 iscsi_conn_attr(exp_statsn, ISCSI_PARAM_EXP_STATSN);
 iscsi_conn_attr(persistent_address, ISCSI_PARAM_PERSISTENT_ADDRESS);
 iscsi_conn_attr(address, ISCSI_PARAM_CONN_ADDRESS);
+iscsi_conn_attr(ep_handle, ISCSI_PARAM_EP_HANDLE);
 
 #define iscsi_cdev_to_session(_cdev) \
 	iscsi_dev_to_session(_cdev->dev)
@@ -1343,6 +1344,7 @@ iscsi_register_transport(struct iscsi_tr
 	SETUP_CONN_RD_ATTR(exp_statsn, ISCSI_EXP_STATSN);
 	SETUP_CONN_RD_ATTR(persistent_address, ISCSI_PERSISTENT_ADDRESS);
 	SETUP_CONN_RD_ATTR(persistent_port, ISCSI_PERSISTENT_PORT);
+	SETUP_CONN_RD_ATTR(ep_handle, ISCSI_EP_HANDLE);
 
 	BUG_ON(count > ISCSI_CONN_ATTRS);
 	priv->conn_attrs[count] = NULL;
Index: linux-2.6-git/include/scsi/iscsi_if.h
===================================================================
--- linux-2.6-git.orig/include/scsi/iscsi_if.h	2007-01-25 11:57:44.000000000 +0100
+++ linux-2.6-git/include/scsi/iscsi_if.h	2007-01-25 13:58:45.000000000 +0100
@@ -219,9 +219,10 @@ enum iscsi_param {
 	ISCSI_PARAM_PERSISTENT_PORT,
 	ISCSI_PARAM_SESS_RECOVERY_TMO,
 
-	/* pased in through bind conn using transport_fd */
+	/* pased in through bind or ep callbacks */
 	ISCSI_PARAM_CONN_PORT,
 	ISCSI_PARAM_CONN_ADDRESS,
+	ISCSI_PARAM_EP_HANDLE,
 
 	/* must always be last */
 	ISCSI_PARAM_MAX,
@@ -249,6 +250,7 @@ enum iscsi_param {
 #define ISCSI_SESS_RECOVERY_TMO		(1 << ISCSI_PARAM_SESS_RECOVERY_TMO)
 #define ISCSI_CONN_PORT			(1 << ISCSI_PARAM_CONN_PORT)
 #define ISCSI_CONN_ADDRESS		(1 << ISCSI_PARAM_CONN_ADDRESS)
+#define ISCSI_EP_HANDLE			(1 << ISCSI_PARAM_EP_HANDLE)
 
 #define iscsi_ptr(_handle) ((void*)(unsigned long)_handle)
 #define iscsi_handle(_ptr) ((uint64_t)(unsigned long)_ptr)
Index: linux-2.6-git/include/scsi/libiscsi.h
===================================================================
--- linux-2.6-git.orig/include/scsi/libiscsi.h	2007-01-25 11:57:44.000000000 +0100
+++ linux-2.6-git/include/scsi/libiscsi.h	2007-01-25 13:58:45.000000000 +0100
@@ -123,6 +123,7 @@ struct iscsi_conn {
 	struct iscsi_cls_conn	*cls_conn;	/* ptr to class connection */
 	void			*dd_data;	/* iscsi_transport data */
 	struct iscsi_session	*session;	/* parent session */
+	uint64_t		ep_handle;	/* ep handle */
 	/*
 	 * LLDs should set this lock. It protects the transport recv
 	 * code
@@ -281,7 +282,7 @@ extern void iscsi_conn_teardown(struct i
 extern int iscsi_conn_start(struct iscsi_cls_conn *);
 extern void iscsi_conn_stop(struct iscsi_cls_conn *, int);
 extern int iscsi_conn_bind(struct iscsi_cls_session *, struct iscsi_cls_conn *,
-			   int);
+			   int, uint64_t transport_eph);
 extern void iscsi_conn_failure(struct iscsi_conn *conn, enum iscsi_err err);
 extern int iscsi_conn_get_param(struct iscsi_cls_conn *cls_conn,
 				enum iscsi_param param, char *buf);
Index: linux-2.6-git/include/scsi/scsi_transport_iscsi.h
===================================================================
--- linux-2.6-git.orig/include/scsi/scsi_transport_iscsi.h	2007-01-25 11:57:44.000000000 +0100
+++ linux-2.6-git/include/scsi/scsi_transport_iscsi.h	2007-01-25 13:58:45.000000000 +0100
@@ -79,7 +79,7 @@ struct iscsi_transport {
 	char *name;
 	unsigned int caps;
 	/* LLD sets this to indicate what values it can export to sysfs */
-	unsigned int param_mask;
+	uint64_t param_mask;
 	struct scsi_host_template *host_template;
 	/* LLD connection data size */
 	int conndata_size;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
