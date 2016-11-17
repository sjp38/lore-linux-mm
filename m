Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9806B02C4
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:25:31 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id o1so73013525ito.7
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 14:25:31 -0800 (PST)
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net (p3plsmtps2ded01.prod.phx3.secureserver.net. [208.109.80.58])
        by mx.google.com with ESMTPS id u78si262180ita.9.2016.11.16.14.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 14:24:05 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 25/29] rxrpc: Abstract away knowledge of IDR internals
Date: Wed, 16 Nov 2016 16:16:53 -0800
Message-Id: <1479341856-30320-29-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Add idr_get_cursor() / idr_set_cursor() APIs, and remove the rounding
up to IDR_SIZE.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/idr.h     | 26 ++++++++++++++++++++++++++
 net/rxrpc/af_rxrpc.c    | 11 ++++++-----
 net/rxrpc/conn_client.c |  4 ++--
 3 files changed, 34 insertions(+), 7 deletions(-)

diff --git a/include/linux/idr.h b/include/linux/idr.h
index 3639a28..1eb755f 100644
--- a/include/linux/idr.h
+++ b/include/linux/idr.h
@@ -56,6 +56,32 @@ struct idr {
 #define DEFINE_IDR(name)	struct idr name = IDR_INIT(name)
 
 /**
+ * idr_get_cursor - Return the current position of the cyclic allocator
+ * @idr: idr handle
+ *
+ * The value returned is the value that will be next returned from
+ * idr_alloc_cyclic() if it is free (otherwise the search will start from
+ * this position).
+ */
+static inline unsigned int idr_get_cursor(struct idr *idr)
+{
+	return READ_ONCE(idr->cur);
+}
+
+/**
+ * idr_set_cursor - Set the current position of the cyclic allocator
+ * @idr: idr handle
+ * @val: new position
+ *
+ * The next call to idr_alloc_cyclic() will return @val if it is free
+ * (otherwise the search will start from this position).
+ */
+static inline void idr_set_cursor(struct idr *idr, unsigned int val)
+{
+	WRITE_ONCE(idr->cur, val);
+}
+
+/**
  * DOC: idr sync
  * idr synchronization (stolen from radix-tree.h)
  *
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 2d59c9b..5f63f6d 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -762,16 +762,17 @@ static const struct net_proto_family rxrpc_family_ops = {
 static int __init af_rxrpc_init(void)
 {
 	int ret = -1;
+	unsigned int tmp;
 
 	BUILD_BUG_ON(sizeof(struct rxrpc_skb_priv) > FIELD_SIZEOF(struct sk_buff, cb));
 
 	get_random_bytes(&rxrpc_epoch, sizeof(rxrpc_epoch));
 	rxrpc_epoch |= RXRPC_RANDOM_EPOCH;
-	get_random_bytes(&rxrpc_client_conn_ids.cur,
-			 sizeof(rxrpc_client_conn_ids.cur));
-	rxrpc_client_conn_ids.cur &= 0x3fffffff;
-	if (rxrpc_client_conn_ids.cur == 0)
-		rxrpc_client_conn_ids.cur = 1;
+	get_random_bytes(&tmp, sizeof(tmp));
+	tmp &= 0x3fffffff;
+	if (tmp == 0)
+		tmp = 1;
+	idr_set_cursor(&rxrpc_client_conn_ids, tmp);
 
 	ret = -ENOMEM;
 	rxrpc_call_jar = kmem_cache_create(
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 60ef960..9706f60 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -263,12 +263,12 @@ static bool rxrpc_may_reuse_conn(struct rxrpc_connection *conn)
 	 * times the maximum number of client conns away from the current
 	 * allocation point to try and keep the IDs concentrated.
 	 */
-	id_cursor = READ_ONCE(rxrpc_client_conn_ids.cur);
+	id_cursor = idr_get_cursor(&rxrpc_client_conn_ids);
 	id = conn->proto.cid >> RXRPC_CIDSHIFT;
 	distance = id - id_cursor;
 	if (distance < 0)
 		distance = -distance;
-	limit = round_up(rxrpc_max_client_connections, IDR_SIZE) * 4;
+	limit = rxrpc_max_client_connections * 4;
 	if (distance > limit)
 		goto mark_dont_reuse;
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
