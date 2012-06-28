Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 1D9316B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 08:50:19 -0400 (EDT)
Date: Thu, 28 Jun 2012 08:49:52 -0400
From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 10/12] nfs: enable swap on NFS
Message-ID: <20120628084952.6526f801@corrin.poochiereds.net>
In-Reply-To: <20120628123734.GH8271@suse.de>
References: <1340375468-22509-1-git-send-email-mgorman@suse.de>
	<1340375468-22509-11-git-send-email-mgorman@suse.de>
	<20120628082725.33b71097@corrin.poochiereds.net>
	<20120628123734.GH8271@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On Thu, 28 Jun 2012 13:37:34 +0100
Mel Gorman <mgorman@suse.de> wrote:

> On Thu, Jun 28, 2012 at 08:27:25AM -0400, Jeff Layton wrote:
> > > <SNIP>
> > > @@ -2108,11 +2156,15 @@ static void xs_tcp_setup_socket(struct work_struct *work)
> > >  		container_of(work, struct sock_xprt, connect_worker.work);
> > >  	struct socket *sock = transport->sock;
> > >  	struct rpc_xprt *xprt = &transport->xprt;
> > > +	unsigned long pflags = current->flags;
> > >  	int status = -EIO;
> > >  
> > >  	if (xprt->shutdown)
> > >  		goto out;
> > >  
> > > +	if (xprt->swapper)
> > > +		current->flags |= PF_MEMALLOC;
> > > +
> > >  	if (!sock) {
> > >  		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
> > >  		sock = xs_create_sock(xprt, transport,
> > > @@ -2174,6 +2226,7 @@ out_eagain:
> > >  out:
> > >  	xprt_clear_connecting(xprt);
> > >  	xprt_wake_pending_tasks(xprt, status);
> > > +	tsk_restore_flags(current, pflags, PF_MEMALLOC);
> > >  }
> > >  
> > >  /**
> > 
> > Apologies if this is fixed in another patch and I didn't see it...
> > 
> 
> No apologies necessary. Even if it was fixed in another patch, it would
> still be wrong for bisection reasons and for being rude to reviewers.
> 
> > There's a place in the above function that returns without going
> > through "out:". I think you also want to tsk_restore_flags() in that
> > spot too.
> > 
> 
> You're right. The case that it would trigger would be some corner case
> but very nicely spotted.
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index b84df34..3d58b92 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -2214,6 +2214,7 @@ static void xs_tcp_setup_socket(struct work_struct *work)
>  	case -EINPROGRESS:
>  	case -EALREADY:
>  		xprt_clear_connecting(xprt);
> +		tsk_restore_flags(current, pflags, PF_MEMALLOC);
>  		return;
>  	case -EINVAL:
>  		/* Happens, for instance, if the user specified a link

That looks correct.

Actually it's not obvious in this function, but it turns out that this
is the common case. xs_tcp_finish_connecting calls kernel_connect with
O_NONBLOCK set, and that almost always immediately returns with
-EINPROGRESS.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
