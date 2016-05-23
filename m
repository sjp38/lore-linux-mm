Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 29A97828E2
	for <linux-mm@kvack.org>; Mon, 23 May 2016 06:20:55 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id lp2so62743193igb.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 03:20:55 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0109.outbound.protection.outlook.com. [157.56.112.109])
        by mx.google.com with ESMTPS id l2si14504693obh.64.2016.05.23.03.20.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 May 2016 03:20:48 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 8/8] af_unix: charge buffers to kmemcg
Date: Mon, 23 May 2016 13:20:29 +0300
Message-ID: <ba7e91e4f7aaea4e4d3b4ce60bf8bb2a3eceba0a.1463997354.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1463997354.git.vdavydov@virtuozzo.com>
References: <cover.1463997354.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "David S. Miller" <davem@davemloft.net>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Unix sockets can consume a significant amount of system memory, hence
they should be accounted to kmemcg.

Since unix socket buffers are always allocated from process context,
all we need to do to charge them to kmemcg is set __GFP_ACCOUNT in
sock->sk_allocation mask.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: "David S. Miller" <davem@davemloft.net>
---
 net/unix/af_unix.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 80aa6a3e6817..022bdd3ab7d9 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -769,6 +769,7 @@ static struct sock *unix_create1(struct net *net, struct socket *sock, int kern)
 	lockdep_set_class(&sk->sk_receive_queue.lock,
 				&af_unix_sk_receive_queue_lock_key);
 
+	sk->sk_allocation	= GFP_KERNEL_ACCOUNT;
 	sk->sk_write_space	= unix_write_space;
 	sk->sk_max_ack_backlog	= net->unx.sysctl_max_dgram_qlen;
 	sk->sk_destruct		= unix_sock_destructor;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
