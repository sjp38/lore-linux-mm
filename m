Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6479B6B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 08:46:23 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so1881995pdi.2
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 05:46:23 -0700 (PDT)
Received: from mx12.netapp.com (mx12.netapp.com. [216.240.18.77])
        by mx.google.com with ESMTPS id hw8si2639340pbc.77.2014.04.24.05.46.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 05:46:22 -0700 (PDT)
Message-ID: <53590798.80309@netapp.com>
Date: Thu, 24 Apr 2014 08:46:16 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] SUNRPC: track when a client connection is routed
 to the local host.
References: <20140423022441.4725.89693.stgit@notabene.brown>	<20140423024058.4725.7703.stgit@notabene.brown>	<5357C3AC.9090203@netapp.com> <20140424091419.0ba0cfd3@notabene.brown>
In-Reply-To: <20140424091419.0ba0cfd3@notabene.brown>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Dave Chinner <david@fromorbit.com>, "J.
 Bruce Fields" <bfields@fieldses.org>, Mel Gorman <mgorman@suse.com>, Andrew
 Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On 04/23/2014 07:14 PM, NeilBrown wrote:
> On Wed, 23 Apr 2014 09:44:12 -0400 Anna Schumaker <Anna.Schumaker@netapp.com>
> wrote:
> 
>> On 04/22/2014 10:40 PM, NeilBrown wrote:
>>> If requests are being sent to the local host, then NFS will
>>> need to take care to avoid deadlocks.
>>>
>>> So keep track when accepting a connection or sending a UDP request
>>> and set a flag in the svc_xprt when the peer connected to is local.
>>>
>>> The interface rpc_is_foreign() is provided to check is a given client
>>> is connected to a foreign server.  When it returns zero it is either
>>> not connected or connected to a local server and in either case
>>> greater care is needed.
>>>
>>> Signed-off-by: NeilBrown <neilb@suse.de>
>>> ---
>>>  include/linux/sunrpc/clnt.h |    1 +
>>>  include/linux/sunrpc/xprt.h |    1 +
>>>  net/sunrpc/clnt.c           |   25 +++++++++++++++++++++++++
>>>  net/sunrpc/xprtsock.c       |   17 +++++++++++++++++
>>>  4 files changed, 44 insertions(+)
>>>
>>> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
>>> index 8af2804bab16..5d626cc5ab01 100644
>>> --- a/include/linux/sunrpc/clnt.h
>>> +++ b/include/linux/sunrpc/clnt.h
>>> @@ -173,6 +173,7 @@ void		rpc_force_rebind(struct rpc_clnt *);
>>>  size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
>>>  const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
>>>  int		rpc_localaddr(struct rpc_clnt *, struct sockaddr *, size_t);
>>> +int		rpc_is_foreign(struct rpc_clnt *);
>>>  
>>>  #endif /* __KERNEL__ */
>>>  #endif /* _LINUX_SUNRPC_CLNT_H */
>>> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
>>> index 8097b9df6773..318ee37bc358 100644
>>> --- a/include/linux/sunrpc/xprt.h
>>> +++ b/include/linux/sunrpc/xprt.h
>>> @@ -340,6 +340,7 @@ int			xs_swapper(struct rpc_xprt *xprt, int enable);
>>>  #define XPRT_CONNECTION_ABORT	(7)
>>>  #define XPRT_CONNECTION_CLOSE	(8)
>>>  #define XPRT_CONGESTED		(9)
>>> +#define XPRT_LOCAL		(10)
>>>  
>>>  static inline void xprt_set_connected(struct rpc_xprt *xprt)
>>>  {
>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>> index 0edada973434..454cea69b373 100644
>>> --- a/net/sunrpc/clnt.c
>>> +++ b/net/sunrpc/clnt.c
>>> @@ -1109,6 +1109,31 @@ const char *rpc_peeraddr2str(struct rpc_clnt *clnt,
>>>  }
>>>  EXPORT_SYMBOL_GPL(rpc_peeraddr2str);
>>>  
>>> +/**
>>> + * rpc_is_foreign - report is rpc client was recently connected to
>>> + *                  remote host
>>> + * @clnt: RPC client structure
>>> + *
>>> + * If the client is not connected, or connected to the local host
>>> + * (any IP address), then return 0.  Only return non-zero if the
>>> + * most recent state was a connection to a remote host.
>>> + * For UDP the client always appears to be connected, and the
>>> + * remoteness of the host is of the destination of the last transmission.
>>> + */
>>> +int rpc_is_foreign(struct rpc_clnt *clnt)
>>> +{
>>> +	struct rpc_xprt *xprt;
>>> +	int conn_foreign;
>>> +
>>> +	rcu_read_lock();
>>> +	xprt = rcu_dereference(clnt->cl_xprt);
>>> +	conn_foreign = (xprt && xprt_connected(xprt)
>>> +			&& !test_bit(XPRT_LOCAL, &xprt->state));
>>> +	rcu_read_unlock();
>>> +	return conn_foreign;
>>> +}
>>> +EXPORT_SYMBOL_GPL(rpc_is_foreign);
>>> +
>>>  static const struct sockaddr_in rpc_inaddr_loopback = {
>>>  	.sin_family		= AF_INET,
>>>  	.sin_addr.s_addr	= htonl(INADDR_ANY),
>>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>>> index 0addefca8e77..74796cf37d5b 100644
>>> --- a/net/sunrpc/xprtsock.c
>>> +++ b/net/sunrpc/xprtsock.c
>>> @@ -642,6 +642,15 @@ static int xs_udp_send_request(struct rpc_task *task)
>>>  			xdr->len - req->rq_bytes_sent, status);
>>>  
>>>  	if (status >= 0) {
>>> +		struct dst_entry *dst;
>>> +		rcu_read_lock();
>>> +		dst = rcu_dereference(transport->sock->sk->sk_dst_cache);
>>> +		if (dst && dst->dev && (dst->dev->features & NETIF_F_LOOPBACK))
>>> +			set_bit(XPRT_LOCAL, &xprt->state);
>>> +		else
>>> +			clear_bit(XPRT_LOCAL, &xprt->state);
>>> +		rcu_read_unlock();
>>> +
>> You repeat this block of code a bit later.  Can you please make it an inline helper function?
> 
> Thanks for the suggestion.
> I've put
> 
> static inline int sock_is_loopback(struct sock *sk)
> {
> 	struct dst_entry *dst;
> 	int loopback = 0;
> 	rcu_read_lock();
> 	dst = rcu_dereference(sk->sk_dst_cache);
> 	if (dst && dst->dev &&
> 	    (dst->dev->features & NETIF_F_LOOPBACK))
> 		loopback = 1;
> 	rcu_read_unlock();
> 	return loopback;
> }
> 
> 
> in sunrpc.h, and used it for both the server-side and the client side.

Awesome, thanks!

Anna
> 
> NeilBrown
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
