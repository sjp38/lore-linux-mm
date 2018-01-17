Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 28212280286
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:23:10 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e185so14978043pfg.23
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:23:10 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 3si5056959pli.809.2018.01.17.12.23.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:23:08 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 98/99] qrtr: Convert to XArray
Date: Wed, 17 Jan 2018 12:22:02 -0800
Message-Id: <20180117202203.19756-99-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Moved the kref protection under the xa_lock too.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 net/qrtr/qrtr.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index 77ab05e23001..7de9a06d2aa2 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -104,10 +104,10 @@ static inline struct qrtr_sock *qrtr_sk(struct sock *sk)
 static unsigned int qrtr_local_nid = -1;
 
 /* for node ids */
-static RADIX_TREE(qrtr_nodes, GFP_KERNEL);
+static DEFINE_XARRAY(qrtr_nodes);
 /* broadcast list */
 static LIST_HEAD(qrtr_all_nodes);
-/* lock for qrtr_nodes, qrtr_all_nodes and node reference */
+/* lock for qrtr_all_nodes */
 static DEFINE_MUTEX(qrtr_node_lock);
 
 /* local port allocation management */
@@ -148,12 +148,15 @@ static int qrtr_bcast_enqueue(struct qrtr_node *node, struct sk_buff *skb,
  * kref_put_mutex.  As such, the node mutex is expected to be locked on call.
  */
 static void __qrtr_node_release(struct kref *kref)
+		__releases(qrtr_nodes.xa_lock)
 {
 	struct qrtr_node *node = container_of(kref, struct qrtr_node, ref);
 
 	if (node->nid != QRTR_EP_NID_AUTO)
-		radix_tree_delete(&qrtr_nodes, node->nid);
+		__xa_erase(&qrtr_nodes, node->nid);
+	xa_unlock(&qrtr_nodes);
 
+	mutex_lock(&qrtr_node_lock);
 	list_del(&node->item);
 	mutex_unlock(&qrtr_node_lock);
 
@@ -174,7 +177,7 @@ static void qrtr_node_release(struct qrtr_node *node)
 {
 	if (!node)
 		return;
-	kref_put_mutex(&node->ref, __qrtr_node_release, &qrtr_node_lock);
+	kref_put_lock(&node->ref, __qrtr_node_release, &qrtr_nodes.xa_lock);
 }
 
 /* Pass an outgoing packet socket buffer to the endpoint driver. */
@@ -217,10 +220,10 @@ static struct qrtr_node *qrtr_node_lookup(unsigned int nid)
 {
 	struct qrtr_node *node;
 
-	mutex_lock(&qrtr_node_lock);
-	node = radix_tree_lookup(&qrtr_nodes, nid);
+	xa_lock(&qrtr_nodes);
+	node = xa_load(&qrtr_nodes, nid);
 	node = qrtr_node_acquire(node);
-	mutex_unlock(&qrtr_node_lock);
+	xa_unlock(&qrtr_nodes);
 
 	return node;
 }
@@ -235,10 +238,8 @@ static void qrtr_node_assign(struct qrtr_node *node, unsigned int nid)
 	if (node->nid != QRTR_EP_NID_AUTO || nid == QRTR_EP_NID_AUTO)
 		return;
 
-	mutex_lock(&qrtr_node_lock);
-	radix_tree_insert(&qrtr_nodes, nid, node);
 	node->nid = nid;
-	mutex_unlock(&qrtr_node_lock);
+	xa_store(&qrtr_nodes, nid, node, GFP_KERNEL);
 }
 
 /**
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
