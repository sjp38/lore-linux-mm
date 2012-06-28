Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 965956B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 08:27:48 -0400 (EDT)
Date: Thu, 28 Jun 2012 08:27:25 -0400
From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 10/12] nfs: enable swap on NFS
Message-ID: <20120628082725.33b71097@corrin.poochiereds.net>
In-Reply-To: <1340375468-22509-11-git-send-email-mgorman@suse.de>
References: <1340375468-22509-1-git-send-email-mgorman@suse.de>
	<1340375468-22509-11-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On Fri, 22 Jun 2012 15:31:06 +0100
Mel Gorman <mgorman@suse.de> wrote:

> Implement the new swapfile a_ops for NFS and hook up ->direct_IO. This
> will set the NFS socket to SOCK_MEMALLOC and run socket reconnect
> under PF_MEMALLOC as well as reset SOCK_MEMALLOC before engaging the
> protocol ->connect() method.
> 
> PF_MEMALLOC should allow the allocation of struct socket and related
> objects and the early (re)setting of SOCK_MEMALLOC should allow us
> to receive the packets required for the TCP connection buildup.
> 
> [dfeng@redhat.com: Fix handling of multiple swap files]
> [a.p.zijlstra@chello.nl: Original patch]
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
>  fs/nfs/Kconfig              |    8 +++++
>  fs/nfs/direct.c             |   82 ++++++++++++++++++++++++++++---------------
>  fs/nfs/file.c               |   22 ++++++++++--
>  include/linux/nfs_fs.h      |    4 +--
>  include/linux/sunrpc/xprt.h |    3 ++
>  net/sunrpc/Kconfig          |    5 +++
>  net/sunrpc/clnt.c           |    2 ++
>  net/sunrpc/sched.c          |    7 ++--
>  net/sunrpc/xprtsock.c       |   53 ++++++++++++++++++++++++++++
>  9 files changed, 152 insertions(+), 34 deletions(-)
> 

[...snip...]

> @@ -2108,11 +2156,15 @@ static void xs_tcp_setup_socket(struct work_struct *work)
>  		container_of(work, struct sock_xprt, connect_worker.work);
>  	struct socket *sock = transport->sock;
>  	struct rpc_xprt *xprt = &transport->xprt;
> +	unsigned long pflags = current->flags;
>  	int status = -EIO;
>  
>  	if (xprt->shutdown)
>  		goto out;
>  
> +	if (xprt->swapper)
> +		current->flags |= PF_MEMALLOC;
> +
>  	if (!sock) {
>  		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
>  		sock = xs_create_sock(xprt, transport,
> @@ -2174,6 +2226,7 @@ out_eagain:
>  out:
>  	xprt_clear_connecting(xprt);
>  	xprt_wake_pending_tasks(xprt, status);
> +	tsk_restore_flags(current, pflags, PF_MEMALLOC);
>  }
>  
>  /**

Apologies if this is fixed in another patch and I didn't see it...

There's a place in the above function that returns without going
through "out:". I think you also want to tsk_restore_flags() in that
spot too.

-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
