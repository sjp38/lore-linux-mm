Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@digeo.com>) (for <felipe_alfaro@linuxmail.org>)
	(for <linux-kernel@vger.kernel.org>) (for <linux-mm@kvack.org>)
	(for <trond.myklebust@fys.uio.no>) By tone With Smtp ;
	Mon, 26 May 2003 09:16:15 +1000
From: Neil Brown <neilb@cse.unsw.edu.au>
Date: Mon, 26 May 2003 09:16:10 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16081.20154.686639.275401@notabene.cse.unsw.edu.au>
Subject: Re: 2.5.69-mm9
In-Reply-To: message from Andrew Morton on Sunday May 25
References: <20030525042759.6edacd62.akpm@digeo.com>
	<1053899811.750.1.camel@teapot.felipe-alfaro.com>
	<20030525154840.3ba7609b.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

On Sunday May 25, akpm@digeo.com wrote:
> >  EIP is at svc_udp_recvfrom+0x52b/0x560 [sunrpc]

> 
> OK, you have CONFIG_DEBUG_PAGEALLOC set.  That's the patch which unmaps
> pages from kernel virtual address space when they are freed.
> 
> That patch seems quite stable on uniprocessor at least - there are question
> marks over its honesty on SMP.
> 
> I would be inclined to say that this is a hitherto undiscovered
> use-after-free bug.

Good inclination.  See patch.

As far as I can tell, sock->stamp is only ever used for
SIOCGSTAMP, which probably doesn't need to be support for
these rpc sockets, but I guess it doesn't hurt..

NeilBrown

--------------------------------------------
Extract ->stamp from skb *before* freeing it in svcsock.c

As we sometime copy and free an skb, and sometime us it
in-place, we must be careful to extract information from
it *before* it might be freed, not after.

 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-05-21 13:17:52.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-05-26 09:11:32.000000000 +1000
@@ -589,6 +589,8 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_addr.sin_port = skb->h.uh->source;
 	rqstp->rq_addr.sin_addr.s_addr = skb->nh.iph->saddr;
 
+	svsk->sk_sk->stamp = skb->stamp;
+
 	if (skb_is_nonlinear(skb)) {
 		/* we have to copy */
 		local_bh_disable();
@@ -629,7 +631,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		serv->sv_stats->netudpcnt++;
 
 	/* One down, maybe more to go... */
-	svsk->sk_sk->stamp = skb->stamp;
 	svc_sock_received(svsk);
 
 	return len;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
