Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 88E26900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 16:14:44 -0400 (EDT)
Received: by iebgx4 with SMTP id gx4so21839666ieb.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 13:14:44 -0700 (PDT)
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com. [209.85.223.182])
        by mx.google.com with ESMTPS id ka10si1665248igb.53.2015.06.03.13.14.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 13:14:43 -0700 (PDT)
Received: by iesa3 with SMTP id a3so21844587ies.2
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 13:14:43 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
Subject: [PATCH v3 3/5] sunrpc: if we're closing down a socket, clear memalloc on it first
Date: Wed,  3 Jun 2015 16:14:27 -0400
Message-Id: <1433362469-2615-4-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1433362469-2615-1-git-send-email-jeff.layton@primarydata.com>
References: <1433362469-2615-1-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Jerome Marchand <jmarchan@redhat.com>, Chuck Lever <chuck.lever@oracle.com>

We currently increment the memalloc_socks counter if we have a xprt that
is associated with a swapfile. That socket can be replaced however
during a reconnect event, and the memalloc_socks counter is never
decremented if that occurs.

When tearing down a xprt socket, check to see if the xprt is set up for
swapping and sk_clear_memalloc before releasing the socket if so.

Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 net/sunrpc/xprtsock.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3f34dbcbec6a..cb928ae4e8f4 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -827,6 +827,9 @@ static void xs_reset_transport(struct sock_xprt *transport)
 	if (sk == NULL)
 		return;
 
+	if (atomic_read(&transport->xprt.swapper))
+		sk_clear_memalloc(sk);
+
 	write_lock_bh(&sk->sk_callback_lock);
 	transport->inet = NULL;
 	transport->sock = NULL;
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
