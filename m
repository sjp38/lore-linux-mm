Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA05900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 11:02:09 -0400 (EDT)
Received: by wibdt2 with SMTP id dt2so16492740wib.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 08:02:08 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id wk1si1703148wjb.120.2015.06.03.08.02.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 08:02:07 -0700 (PDT)
Received: by wibut5 with SMTP id ut5so105938788wib.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 08:02:06 -0700 (PDT)
Date: Wed, 3 Jun 2015 11:01:58 -0400
From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH v2 5/5] sunrpc: turn swapper_enable/disable functions
 into rpc_xprt_ops
Message-ID: <20150603110158.0d21844d@synchrony.poochiereds.net>
In-Reply-To: <CAHQdGtQGeVRTfv-hvZj_bHqgb5Cs84TY-ScFqzJ3qQOZy2qLcQ@mail.gmail.com>
References: <1433342632-16173-1-git-send-email-jeff.layton@primarydata.com>
	<1433342632-16173-6-git-send-email-jeff.layton@primarydata.com>
	<CAHQdGtQGeVRTfv-hvZj_bHqgb5Cs84TY-ScFqzJ3qQOZy2qLcQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Jerome Marchand <jmarchan@redhat.com>, Chuck Lever <chuck.lever@oracle.com>

On Wed, 3 Jun 2015 10:48:10 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Wed, Jun 3, 2015 at 10:43 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
> > RDMA xprts don't have a sock_xprt, but an rdma_xprt, so the
> > xs_swapper_enable/disable functions will likely oops when fed an RDMA
> > xprt. Turn these functions into rpc_xprt_ops so that that doesn't
> > occur. For now the RDMA versions are no-ops.
> >
> > Cc: Chuck Lever <chuck.lever@oracle.com>
> > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > ---
> >  include/linux/sunrpc/xprt.h     | 16 ++++++++++++++--
> >  net/sunrpc/clnt.c               |  4 ++--
> >  net/sunrpc/xprtrdma/transport.c | 15 ++++++++++++++-
> >  net/sunrpc/xprtsock.c           | 31 +++++++++++++++++++++++++------
> >  4 files changed, 55 insertions(+), 11 deletions(-)
> >
> > diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> > index 26b1624128ec..7eb58610eb94 100644
> > --- a/include/linux/sunrpc/xprt.h
> > +++ b/include/linux/sunrpc/xprt.h
> > @@ -133,6 +133,8 @@ struct rpc_xprt_ops {
> >         void            (*close)(struct rpc_xprt *xprt);
> >         void            (*destroy)(struct rpc_xprt *xprt);
> >         void            (*print_stats)(struct rpc_xprt *xprt, struct seq_file *seq);
> > +       int             (*enable_swap)(struct rpc_xprt *xprt);
> > +       void            (*disable_swap)(struct rpc_xprt *xprt);
> >  };
> >
> >  /*
> > @@ -327,6 +329,18 @@ static inline __be32 *xprt_skip_transport_header(struct rpc_xprt *xprt, __be32 *
> >         return p + xprt->tsh_size;
> >  }
> >
> > +static inline int
> > +xprt_enable_swap(struct rpc_xprt *xprt)
> > +{
> > +       return xprt->ops->enable_swap(xprt);
> > +}
> > +
> > +static inline void
> > +xprt_disable_swap(struct rpc_xprt *xprt)
> > +{
> > +       xprt->ops->disable_swap(xprt);
> > +}
> > +
> >  /*
> >   * Transport switch helper functions
> >   */
> > @@ -345,8 +359,6 @@ void                        xprt_release_rqst_cong(struct rpc_task *task);
> >  void                   xprt_disconnect_done(struct rpc_xprt *xprt);
> >  void                   xprt_force_disconnect(struct rpc_xprt *xprt);
> >  void                   xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
> > -int                    xs_swapper_enable(struct rpc_xprt *xprt);
> > -void                   xs_swapper_disable(struct rpc_xprt *xprt);
> >
> >  bool                   xprt_lock_connect(struct rpc_xprt *, struct rpc_task *, void *);
> >  void                   xprt_unlock_connect(struct rpc_xprt *, void *);
> > diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> > index 804a75e71e84..60d1835edb26 100644
> > --- a/net/sunrpc/clnt.c
> > +++ b/net/sunrpc/clnt.c
> > @@ -2492,7 +2492,7 @@ retry:
> >                         goto retry;
> >                 }
> >
> > -               ret = xs_swapper_enable(xprt);
> > +               ret = xprt_enable_swap(xprt);
> >                 xprt_put(xprt);
> >         }
> >         return ret;
> > @@ -2519,7 +2519,7 @@ retry:
> >                         goto retry;
> >                 }
> >
> > -               xs_swapper_disable(xprt);
> > +               xprt_disable_swap(xprt);
> >                 xprt_put(xprt);
> >         }
> >  }
> > diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> > index 54f23b1be986..e7a157754095 100644
> > --- a/net/sunrpc/xprtrdma/transport.c
> > +++ b/net/sunrpc/xprtrdma/transport.c
> > @@ -682,6 +682,17 @@ static void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
> >            r_xprt->rx_stats.bad_reply_count);
> >  }
> >
> > +static int
> > +xprt_rdma_enable_swap(struct rpc_xprt *xprt)
> > +{
> > +       return 0;
> 
> Shouldn't the function be returning an error here? What does swapon
> expect if the device you are trying to enable doesn't support swap?
> 


Chuck suggested making these no-ops for RDMA for now. I'm fine with
returning an error, but is it really an error? Maybe RDMA doesn't need
any special setup for swapping?

> > +}
> > +
> > +static void
> > +xprt_rdma_disable_swap(struct rpc_xprt *xprt)
> > +{
> > +}
> > +
> >  /*
> >   * Plumbing for rpc transport switch and kernel module
> >   */
> > @@ -700,7 +711,9 @@ static struct rpc_xprt_ops xprt_rdma_procs = {
> >         .send_request           = xprt_rdma_send_request,
> >         .close                  = xprt_rdma_close,
> >         .destroy                = xprt_rdma_destroy,
> > -       .print_stats            = xprt_rdma_print_stats
> > +       .print_stats            = xprt_rdma_print_stats,
> > +       .enable_swap            = xprt_rdma_enable_swap,
> > +       .disable_swap           = xprt_rdma_disable_swap,
> >  };
> >
> >  static struct xprt_class xprt_rdma = {
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 16aa5dad41b2..b8aaf20aea96 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -1985,14 +1985,14 @@ static void xs_set_memalloc(struct rpc_xprt *xprt)
> >  }
> >
> >  /**
> > - * xs_swapper_enable - Tag this transport as being used for swap.
> > + * xs_enable_swap - Tag this transport as being used for swap.
> >   * @xprt: transport to tag
> >   *
> >   * Take a reference to this transport on behalf of the rpc_clnt, and
> >   * optionally mark it for swapping if it wasn't already.
> >   */
> > -int
> > -xs_swapper_enable(struct rpc_xprt *xprt)
> > +static int
> > +xs_enable_swap(struct rpc_xprt *xprt)
> >  {
> >         struct sock_xprt *xs = container_of(xprt, struct sock_xprt, xprt);
> >
> > @@ -2007,14 +2007,14 @@ xs_swapper_enable(struct rpc_xprt *xprt)
> >  }
> >
> >  /**
> > - * xs_swapper_disable - Untag this transport as being used for swap.
> > + * xs_disable_swap - Untag this transport as being used for swap.
> >   * @xprt: transport to tag
> >   *
> >   * Drop a "swapper" reference to this xprt on behalf of the rpc_clnt. If the
> >   * swapper refcount goes to 0, untag the socket as a memalloc socket.
> >   */
> > -void
> > -xs_swapper_disable(struct rpc_xprt *xprt)
> > +static void
> > +xs_disable_swap(struct rpc_xprt *xprt)
> >  {
> >         struct sock_xprt *xs = container_of(xprt, struct sock_xprt, xprt);
> >
> > @@ -2030,6 +2030,17 @@ xs_swapper_disable(struct rpc_xprt *xprt)
> >  static void xs_set_memalloc(struct rpc_xprt *xprt)
> >  {
> >  }
> > +
> > +static int
> > +xs_enable_swap(struct rpc_xprt *xprt)
> > +{
> > +       return 0;
> 
> Ditto.
> 

This just mirrors what the existing code already does. When swap over
NFS is Kconfig'ed off, it returns 0 here. AIUI, swapon will then fail
at the NFS layer though, so you'd never see this.

> > +}
> > +
> > +static void
> > +xs_disable_swap(struct rpc_xprt *xprt)
> > +{
> > +}
> >  #endif
> >
> >  static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
> > @@ -2496,6 +2507,8 @@ static struct rpc_xprt_ops xs_local_ops = {
> >         .close                  = xs_close,
> >         .destroy                = xs_destroy,
> >         .print_stats            = xs_local_print_stats,
> > +       .enable_swap            = xs_enable_swap,
> > +       .disable_swap           = xs_disable_swap,
> >  };
> >
> >  static struct rpc_xprt_ops xs_udp_ops = {
> > @@ -2515,6 +2528,8 @@ static struct rpc_xprt_ops xs_udp_ops = {
> >         .close                  = xs_close,
> >         .destroy                = xs_destroy,
> >         .print_stats            = xs_udp_print_stats,
> > +       .enable_swap            = xs_enable_swap,
> > +       .disable_swap           = xs_disable_swap,
> >  };
> >
> >  static struct rpc_xprt_ops xs_tcp_ops = {
> > @@ -2531,6 +2546,8 @@ static struct rpc_xprt_ops xs_tcp_ops = {
> >         .close                  = xs_tcp_shutdown,
> >         .destroy                = xs_destroy,
> >         .print_stats            = xs_tcp_print_stats,
> > +       .enable_swap            = xs_enable_swap,
> > +       .disable_swap           = xs_disable_swap,
> >  };
> >
> >  /*
> > @@ -2548,6 +2565,8 @@ static struct rpc_xprt_ops bc_tcp_ops = {
> >         .close                  = bc_close,
> >         .destroy                = bc_destroy,
> >         .print_stats            = xs_tcp_print_stats,
> > +       .enable_swap            = xs_enable_swap,
> > +       .disable_swap           = xs_disable_swap,
> >  };
> >
> >  static int xs_init_anyaddr(const int family, struct sockaddr *sap)
> > --
> > 2.4.2
> >


-- 
Jeff Layton <jlayton@poochiereds.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
