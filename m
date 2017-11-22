Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2A76C6B0282
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:22 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id g75so15511574pfg.4
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:22 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n13si14266055pgc.433.2017.11.22.13.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:21 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 49/62] rxrpc: Remove IDR preloading
Date: Wed, 22 Nov 2017 13:07:26 -0800
Message-Id: <20171122210739.29916-50-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The IDR now handles its own locking, so if we remove the locking in
rxrpc, we can also remove the memory preloading.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 net/rxrpc/conn_client.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 7e8bf10fec86..d61fbd359bfa 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -91,7 +91,6 @@ __read_mostly unsigned int rxrpc_conn_idle_client_fast_expiry = 2 * HZ;
 /*
  * We use machine-unique IDs for our client connections.
  */
-static DEFINE_SPINLOCK(rxrpc_conn_id_lock);
 int rxrpc_client_conn_cursor;
 DEFINE_IDR(rxrpc_client_conn_ids);
 
@@ -111,12 +110,8 @@ static int rxrpc_get_client_connection_id(struct rxrpc_connection *conn,
 
 	_enter("");
 
-	idr_preload(gfp);
-	spin_lock(&rxrpc_conn_id_lock);
 	id = idr_alloc_cyclic(&rxrpc_client_conn_ids, &rxrpc_client_conn_cursor,
-				conn, 1, 0x40000000, GFP_NOWAIT);
-	spin_unlock(&rxrpc_conn_id_lock);
-	idr_preload_end();
+				conn, 1, 0x40000000, gfp);
 	if (id < 0)
 		goto error;
 
@@ -137,10 +132,8 @@ static int rxrpc_get_client_connection_id(struct rxrpc_connection *conn,
 static void rxrpc_put_client_connection_id(struct rxrpc_connection *conn)
 {
 	if (test_bit(RXRPC_CONN_HAS_IDR, &conn->flags)) {
-		spin_lock(&rxrpc_conn_id_lock);
 		idr_remove(&rxrpc_client_conn_ids,
 			   conn->proto.cid >> RXRPC_CIDSHIFT);
-		spin_unlock(&rxrpc_conn_id_lock);
 	}
 }
 
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
