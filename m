Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8BFF06B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 03:42:07 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id g6so12310154obn.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 00:42:07 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0121.outbound.protection.outlook.com. [104.47.1.121])
        by mx.google.com with ESMTPS id a63si1109590oif.224.2016.05.24.00.42.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 May 2016 00:42:06 -0700 (PDT)
Date: Tue, 24 May 2016 10:41:56 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 8/8] af_unix: charge buffers to kmemcg
Message-ID: <20160524074156.GG7917@esperanza>
References: <cover.1463997354.git.vdavydov@virtuozzo.com>
 <ba7e91e4f7aaea4e4d3b4ce60bf8bb2a3eceba0a.1463997354.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <ba7e91e4f7aaea4e4d3b4ce60bf8bb2a3eceba0a.1463997354.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "David S. Miller" <davem@davemloft.net>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

[adding netdev to Cc]

On Mon, May 23, 2016 at 01:20:29PM +0300, Vladimir Davydov wrote:
> Unix sockets can consume a significant amount of system memory, hence
> they should be accounted to kmemcg.
> 
> Since unix socket buffers are always allocated from process context,
> all we need to do to charge them to kmemcg is set __GFP_ACCOUNT in
> sock->sk_allocation mask.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> ---
>  net/unix/af_unix.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 80aa6a3e6817..022bdd3ab7d9 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -769,6 +769,7 @@ static struct sock *unix_create1(struct net *net, struct socket *sock, int kern)
>  	lockdep_set_class(&sk->sk_receive_queue.lock,
>  				&af_unix_sk_receive_queue_lock_key);
>  
> +	sk->sk_allocation	= GFP_KERNEL_ACCOUNT;
>  	sk->sk_write_space	= unix_write_space;
>  	sk->sk_max_ack_backlog	= net->unx.sysctl_max_dgram_qlen;
>  	sk->sk_destruct		= unix_sock_destructor;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
