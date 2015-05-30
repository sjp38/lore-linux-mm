Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 944A66B0070
	for <linux-mm@kvack.org>; Sat, 30 May 2015 08:03:41 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so38732261wic.0
        for <linux-mm@kvack.org>; Sat, 30 May 2015 05:03:41 -0700 (PDT)
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id 16si14877781wjs.1.2015.05.30.05.03.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 May 2015 05:03:38 -0700 (PDT)
Received: by wgez8 with SMTP id z8so81246735wge.0
        for <linux-mm@kvack.org>; Sat, 30 May 2015 05:03:37 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
Subject: [PATCH 3/4] sunrpc: if we're closing down a socket, clear memalloc on it first
Date: Sat, 30 May 2015 08:03:12 -0400
Message-Id: <1432987393-15604-4-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1432987393-15604-1-git-send-email-jeff.layton@primarydata.com>
References: <1432987393-15604-1-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Jerome Marchand <jmarchan@redhat.com>

We currently increment the memalloc_socks counter if we have a xprt that
is associated with a swapfile. That socket can be replaced however
during a reconnect event, and the memalloc_socks counter is never
decremented if that occurs.

When tearing down a xprt socket, check to see if the xprt is set up for
swapping and sk_clear_memalloc before releasing the socket if so.

Cc: Mel Gorman <mgorman@suse.de>
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
2.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
