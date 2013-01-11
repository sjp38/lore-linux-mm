Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id C09C06B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 21:18:50 -0500 (EST)
Received: by mail-da0-f45.google.com with SMTP id w4so530126dam.4
        for <linux-mm@kvack.org>; Thu, 10 Jan 2013 18:18:50 -0800 (PST)
Subject: Re: 3.8-rc2/rc3 write() blocked on CLOSE_WAIT TCP socket
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <1357869675.27446.2962.camel@edumazet-glaptop>
References: <20130111004915.GA15415@dcvr.yhbt.net>
	 <1357869675.27446.2962.camel@edumazet-glaptop>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 10 Jan 2013 18:18:47 -0800
Message-ID: <1357870727.27446.2988.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wong <normalperson@yhbt.net>, David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

From: Eric Dumazet <edumazet@google.com>

On Thu, 2013-01-10 at 18:01 -0800, Eric Dumazet wrote:

> Hmm, it might be commit c3ae62af8e755ea68380fb5ce682e60079a4c388
> tcp: should drop incoming frames without ACK flag set
> 
> It seems RST should be allowed to not have ACK set.
> 
> I'll send a fix, thanks !

Yes, thats definitely the problem, sorry for that.


[PATCH] tcp: accept RST without ACK flag

commit c3ae62af8e755 (tcp: should drop incoming frames without ACK flag
set) added a regression on the handling of RST messages.

RST should be allowed to come even without ACK bit set. We validate
the RST by checking the exact sequence, as requested by RFC 793 and 
5961 3.2, in tcp_validate_incoming()

Reported-by: Eric Wong <normalperson@yhbt.net>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 38e1184..0905997 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5541,7 +5541,7 @@ slow_path:
 	if (len < (th->doff << 2) || tcp_checksum_complete_user(sk, skb))
 		goto csum_error;
 
-	if (!th->ack)
+	if (!th->ack && !th->rst)
 		goto discard;
 
 	/*
@@ -5986,7 +5986,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 			goto discard;
 	}
 
-	if (!th->ack)
+	if (!th->ack && !th->rst)
 		goto discard;
 
 	if (!tcp_validate_incoming(sk, skb, th, 0))


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
