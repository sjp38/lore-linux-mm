Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 543E16B0062
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 21:54:46 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so640408pbc.28
        for <linux-mm@kvack.org>; Tue, 08 Jan 2013 18:54:45 -0800 (PST)
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
From: Eric Dumazet <erdnetdev@gmail.com>
In-Reply-To: <1357698749.27446.6.camel@edumazet-glaptop>
References: <20121228014503.GA5017@dcvr.yhbt.net>
	 <20130102200848.GA4500@dcvr.yhbt.net> <20130104160148.GB3885@suse.de>
	 <20130106120700.GA24671@dcvr.yhbt.net> <20130107122516.GC3885@suse.de>
	 <20130107223850.GA21311@dcvr.yhbt.net> <20130108224313.GA13304@suse.de>
	 <20130108232325.GA5948@dcvr.yhbt.net>
	 <1357697647.18156.1217.camel@edumazet-glaptop>
	 <1357698749.27446.6.camel@edumazet-glaptop>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 08 Jan 2013 18:54:42 -0800
Message-ID: <1357700082.27446.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wong <normalperson@yhbt.net>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 2013-01-08 at 18:32 -0800, Eric Dumazet wrote:

> 
> Hmm, it seems sk_filter() can return -ENOMEM because skb has the
> pfmemalloc() set.

> 
> One TCP socket keeps retransmitting an SKB via loopback, and TCP stack 
> drops the packet again and again.

sock_init_data() sets sk->sk_allocation to GFP_KERNEL

Shouldnt it use (GFP_KERNEL | __GFP_NOMEMALLOC) instead ?



diff --git a/net/core/sock.c b/net/core/sock.c
index bc131d4..76c4b39 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -286,6 +286,7 @@ void sk_set_memalloc(struct sock *sk)
 {
 	sock_set_flag(sk, SOCK_MEMALLOC);
 	sk->sk_allocation |= __GFP_MEMALLOC;
+	sk->sk_allocation &= ~__GFP_NOMEMALLOC;
 	static_key_slow_inc(&memalloc_socks);
 }
 EXPORT_SYMBOL_GPL(sk_set_memalloc);
@@ -294,6 +295,7 @@ void sk_clear_memalloc(struct sock *sk)
 {
 	sock_reset_flag(sk, SOCK_MEMALLOC);
 	sk->sk_allocation &= ~__GFP_MEMALLOC;
+	sk->sk_allocation |= __GFP_NOMEMALLOC;
 	static_key_slow_dec(&memalloc_socks);
 
 	/*
@@ -2230,7 +2232,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 
 	init_timer(&sk->sk_timer);
 
-	sk->sk_allocation	=	GFP_KERNEL;
+	sk->sk_allocation	=	GFP_KERNEL | __GFP_NOMEMALLOC;
 	sk->sk_rcvbuf		=	sysctl_rmem_default;
 	sk->sk_sndbuf		=	sysctl_wmem_default;
 	sk->sk_state		=	TCP_CLOSE;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
