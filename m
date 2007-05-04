Message-Id: <20070504103204.149997643@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:28 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 37/40] iscsi: ensure the iscsi kernel fd is not usable in userspace
Content-Disposition: inline; filename=iscsi_ep_connect_SOCK_KERNEL.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Mike Christie <mchristi@redhat.com>
List-ID: <linux-mm.kvack.org>

We expose the iSCSI connection fd to userspace for reference tracking, but we
do not want userspace to actually have access to the data; mark it with
SOCK_KERNEL.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Mike Christie <mchristi@redhat.com>
---
 drivers/scsi/iscsi_tcp.c |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux-2.6-git/drivers/scsi/iscsi_tcp.c
===================================================================
--- linux-2.6-git.orig/drivers/scsi/iscsi_tcp.c	2007-03-22 11:29:08.000000000 +0100
+++ linux-2.6-git/drivers/scsi/iscsi_tcp.c	2007-03-22 12:00:14.000000000 +0100
@@ -1759,6 +1759,13 @@ iscsi_tcp_ep_connect(struct sockaddr *ds
 		goto release_sock;
 	}
 
+	/*
+	 * Even though we're going to expose this socket to user-space
+	 * (as an identifier for the connection and for tracking life times)
+	 * we don't want it used by user-space at all.
+	 */
+	sock_set_flag(sock->sk, SOCK_KERNEL);
+
 	rc = sock->ops->connect(sock, (struct sockaddr *)dst_addr, size,
 				O_NONBLOCK);
 	if (rc == -EINPROGRESS)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
