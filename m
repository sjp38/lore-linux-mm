Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 48794900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 10:44:15 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so94070934wib.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 07:44:14 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id t3si2303997wiy.29.2015.06.03.07.44.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 07:44:13 -0700 (PDT)
Received: by wiwd19 with SMTP id d19so55297051wiw.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 07:44:13 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
Subject: [PATCH v2 3/5] sunrpc: if we're closing down a socket, clear memalloc on it first
Date: Wed,  3 Jun 2015 10:43:50 -0400
Message-Id: <1433342632-16173-4-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1433342632-16173-1-git-send-email-jeff.layton@primarydata.com>
References: <1433342632-16173-1-git-send-email-jeff.layton@primarydata.com>
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
index a2861bbfd319..359446442112 100644
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
