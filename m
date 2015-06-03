Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id CD823900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 16:26:38 -0400 (EDT)
Received: by qcmi9 with SMTP id i9so9545045qcm.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 13:26:38 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 184si1747327qhu.27.2015.06.03.13.26.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 13:26:37 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v3 5/5] sunrpc: turn swapper_enable/disable functions into rpc_xprt_ops
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1433362469-2615-6-git-send-email-jeff.layton@primarydata.com>
Date: Wed, 3 Jun 2015 16:28:52 -0400
Content-Transfer-Encoding: quoted-printable
Message-Id: <FE4614A3-C538-48E0-A094-C004899A0BBD@oracle.com>
References: <1433362469-2615-1-git-send-email-jeff.layton@primarydata.com> <1433362469-2615-6-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, linux-mm@kvack.org, LKML Kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Jerome Marchand <jmarchan@redhat.com>


On Jun 3, 2015, at 4:14 PM, Jeff Layton <jlayton@poochiereds.net> wrote:

> RDMA xprts don't have a sock_xprt, but an rdma_xprt, so the
> xs_swapper_enable/disable functions will likely oops when fed an RDMA
> xprt. Turn these functions into rpc_xprt_ops so that that doesn't
> occur. For now the RDMA versions are no-ops that just return -EINVAL
> on an attempt to swapon.
>=20
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>

Thanks, Jeff, that works for me.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> ---
> include/linux/sunrpc/xprt.h     | 16 ++++++++++++++--
> net/sunrpc/clnt.c               |  4 ++--
> net/sunrpc/xprtrdma/transport.c | 15 ++++++++++++++-
> net/sunrpc/xprtsock.c           | 31 +++++++++++++++++++++++++------
> 4 files changed, 55 insertions(+), 11 deletions(-)
>=20
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index 26b1624128ec..7eb58610eb94 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -133,6 +133,8 @@ struct rpc_xprt_ops {
> 	void		(*close)(struct rpc_xprt *xprt);
> 	void		(*destroy)(struct rpc_xprt *xprt);
> 	void		(*print_stats)(struct rpc_xprt *xprt, struct =
seq_file *seq);
> +	int		(*enable_swap)(struct rpc_xprt *xprt);
> +	void		(*disable_swap)(struct rpc_xprt *xprt);
> };
>=20
> /*
> @@ -327,6 +329,18 @@ static inline __be32 =
*xprt_skip_transport_header(struct rpc_xprt *xprt, __be32 *
> 	return p + xprt->tsh_size;
> }
>=20
> +static inline int
> +xprt_enable_swap(struct rpc_xprt *xprt)
> +{
> +	return xprt->ops->enable_swap(xprt);
> +}
> +
> +static inline void
> +xprt_disable_swap(struct rpc_xprt *xprt)
> +{
> +	xprt->ops->disable_swap(xprt);
> +}
> +
> /*
>  * Transport switch helper functions
>  */
> @@ -345,8 +359,6 @@ void			=
xprt_release_rqst_cong(struct rpc_task *task);
> void			xprt_disconnect_done(struct rpc_xprt *xprt);
> void			xprt_force_disconnect(struct rpc_xprt *xprt);
> void			xprt_conditional_disconnect(struct rpc_xprt =
*xprt, unsigned int cookie);
> -int			xs_swapper_enable(struct rpc_xprt *xprt);
> -void			xs_swapper_disable(struct rpc_xprt *xprt);
>=20
> bool			xprt_lock_connect(struct rpc_xprt *, struct =
rpc_task *, void *);
> void			xprt_unlock_connect(struct rpc_xprt *, void *);
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 804a75e71e84..60d1835edb26 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -2492,7 +2492,7 @@ retry:
> 			goto retry;
> 		}
>=20
> -		ret =3D xs_swapper_enable(xprt);
> +		ret =3D xprt_enable_swap(xprt);
> 		xprt_put(xprt);
> 	}
> 	return ret;
> @@ -2519,7 +2519,7 @@ retry:
> 			goto retry;
> 		}
>=20
> -		xs_swapper_disable(xprt);
> +		xprt_disable_swap(xprt);
> 		xprt_put(xprt);
> 	}
> }
> diff --git a/net/sunrpc/xprtrdma/transport.c =
b/net/sunrpc/xprtrdma/transport.c
> index 54f23b1be986..ebf6fe759f0e 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -682,6 +682,17 @@ static void xprt_rdma_print_stats(struct rpc_xprt =
*xprt, struct seq_file *seq)
> 	   r_xprt->rx_stats.bad_reply_count);
> }
>=20
> +static int
> +xprt_rdma_enable_swap(struct rpc_xprt *xprt)
> +{
> +	return -EINVAL;
> +}
> +
> +static void
> +xprt_rdma_disable_swap(struct rpc_xprt *xprt)
> +{
> +}
> +
> /*
>  * Plumbing for rpc transport switch and kernel module
>  */
> @@ -700,7 +711,9 @@ static struct rpc_xprt_ops xprt_rdma_procs =3D {
> 	.send_request		=3D xprt_rdma_send_request,
> 	.close			=3D xprt_rdma_close,
> 	.destroy		=3D xprt_rdma_destroy,
> -	.print_stats		=3D xprt_rdma_print_stats
> +	.print_stats		=3D xprt_rdma_print_stats,
> +	.enable_swap		=3D xprt_rdma_enable_swap,
> +	.disable_swap		=3D xprt_rdma_disable_swap,
> };
>=20
> static struct xprt_class xprt_rdma =3D {
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index e3596fe184a0..600194bfdbce 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1985,14 +1985,14 @@ static void xs_set_memalloc(struct rpc_xprt =
*xprt)
> }
>=20
> /**
> - * xs_swapper_enable - Tag this transport as being used for swap.
> + * xs_enable_swap - Tag this transport as being used for swap.
>  * @xprt: transport to tag
>  *
>  * Take a reference to this transport on behalf of the rpc_clnt, and
>  * optionally mark it for swapping if it wasn't already.
>  */
> -int
> -xs_swapper_enable(struct rpc_xprt *xprt)
> +static int
> +xs_enable_swap(struct rpc_xprt *xprt)
> {
> 	struct sock_xprt *xs =3D container_of(xprt, struct sock_xprt, =
xprt);
>=20
> @@ -2007,14 +2007,14 @@ xs_swapper_enable(struct rpc_xprt *xprt)
> }
>=20
> /**
> - * xs_swapper_disable - Untag this transport as being used for swap.
> + * xs_disable_swap - Untag this transport as being used for swap.
>  * @xprt: transport to tag
>  *
>  * Drop a "swapper" reference to this xprt on behalf of the rpc_clnt. =
If the
>  * swapper refcount goes to 0, untag the socket as a memalloc socket.
>  */
> -void
> -xs_swapper_disable(struct rpc_xprt *xprt)
> +static void
> +xs_disable_swap(struct rpc_xprt *xprt)
> {
> 	struct sock_xprt *xs =3D container_of(xprt, struct sock_xprt, =
xprt);
>=20
> @@ -2030,6 +2030,17 @@ xs_swapper_disable(struct rpc_xprt *xprt)
> static void xs_set_memalloc(struct rpc_xprt *xprt)
> {
> }
> +
> +static int
> +xs_enable_swap(struct rpc_xprt *xprt)
> +{
> +	return -EINVAL;
> +}
> +
> +static void
> +xs_disable_swap(struct rpc_xprt *xprt)
> +{
> +}
> #endif
>=20
> static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct =
socket *sock)
> @@ -2496,6 +2507,8 @@ static struct rpc_xprt_ops xs_local_ops =3D {
> 	.close			=3D xs_close,
> 	.destroy		=3D xs_destroy,
> 	.print_stats		=3D xs_local_print_stats,
> +	.enable_swap		=3D xs_enable_swap,
> +	.disable_swap		=3D xs_disable_swap,
> };
>=20
> static struct rpc_xprt_ops xs_udp_ops =3D {
> @@ -2515,6 +2528,8 @@ static struct rpc_xprt_ops xs_udp_ops =3D {
> 	.close			=3D xs_close,
> 	.destroy		=3D xs_destroy,
> 	.print_stats		=3D xs_udp_print_stats,
> +	.enable_swap		=3D xs_enable_swap,
> +	.disable_swap		=3D xs_disable_swap,
> };
>=20
> static struct rpc_xprt_ops xs_tcp_ops =3D {
> @@ -2531,6 +2546,8 @@ static struct rpc_xprt_ops xs_tcp_ops =3D {
> 	.close			=3D xs_tcp_shutdown,
> 	.destroy		=3D xs_destroy,
> 	.print_stats		=3D xs_tcp_print_stats,
> +	.enable_swap		=3D xs_enable_swap,
> +	.disable_swap		=3D xs_disable_swap,
> };
>=20
> /*
> @@ -2548,6 +2565,8 @@ static struct rpc_xprt_ops bc_tcp_ops =3D {
> 	.close			=3D bc_close,
> 	.destroy		=3D bc_destroy,
> 	.print_stats		=3D xs_tcp_print_stats,
> +	.enable_swap		=3D xs_enable_swap,
> +	.disable_swap		=3D xs_disable_swap,
> };
>=20
> static int xs_init_anyaddr(const int family, struct sockaddr *sap)
> --=20
> 2.4.2
>=20

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
