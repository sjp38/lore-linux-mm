Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id A4D456B0062
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 17:38:38 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb11so10998931pad.24
        for <linux-mm@kvack.org>; Mon, 07 Jan 2013 14:38:37 -0800 (PST)
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20130107122516.GC3885@suse.de>
References: <20121228014503.GA5017@dcvr.yhbt.net>
	 <20130102200848.GA4500@dcvr.yhbt.net> <20130104160148.GB3885@suse.de>
	 <20130106120700.GA24671@dcvr.yhbt.net>  <20130107122516.GC3885@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 07 Jan 2013 14:38:35 -0800
Message-ID: <1357598315.6919.3969.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Eric Wong <normalperson@yhbt.net>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, 2013-01-07 at 12:25 +0000, Mel Gorman wrote:

> 
> > ===> 28014[28017]/stack <===
> > [<ffffffff8129fc1d>] release_sock+0xe5/0x11b
> > [<ffffffff812a642c>] sk_stream_wait_memory+0x1f7/0x1fc
> > [<ffffffff81040d5e>] autoremove_wake_function+0x0/0x2a
> > [<ffffffff812d8fc3>] tcp_sendmsg+0x710/0x86d
> > [<ffffffff8129a33e>] sock_sendmsg+0x7b/0x93
> > [<ffffffff8129a642>] sys_sendto+0xee/0x145
> > [<ffffffff8129a3bc>] sockfd_lookup_light+0x1a/0x50
> > [<ffffffff8129a668>] sys_sendto+0x114/0x145
> > [<ffffffff81000e34>] __switch_to+0x235/0x3c5
> > [<ffffffff81322769>] system_call_fastpath+0x16/0x1b
> > [<ffffffffffffffff>] 0xffffffffffffffff
> 
> This seems to be the guy that's stuck. It's waiting for more memory for
> the socket but who or what is allocating that memory? There are a few other
> bugs from over the weekend that I want to take a look at so I did not dig
> further or try to reproduce this bug yet. I'm adding Eric Dumazet back to
> the cc in case he has the quick answer.

Thanks Mel

It would not surprise me if sk_stream_wait_memory() have plain bug(s) or
race(s).

In 2010, in commit 482964e56e132 Nagendra Tomar fixed a pretty severe
long standing bug.

This path is not taken very often on most machines.

I would try the following patch :

diff --git a/net/core/stream.c b/net/core/stream.c
index f5df85d..6f09979 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -126,6 +126,7 @@ int sk_stream_wait_memory(struct sock *sk, long *timeo_p)
 
 	while (1) {
 		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 
@@ -139,7 +140,6 @@ int sk_stream_wait_memory(struct sock *sk, long *timeo_p)
 		if (sk_stream_memory_free(sk) && !vm_wait)
 			break;
 
-		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 		sk->sk_write_pending++;
 		sk_wait_event(sk, &current_timeo, sk->sk_err ||
 						  (sk->sk_shutdown & SEND_SHUTDOWN) ||




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
