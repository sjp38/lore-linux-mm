Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 105CF6B0032
	for <linux-mm@kvack.org>; Sat, 30 May 2015 13:54:13 -0400 (EDT)
Received: by qkhg32 with SMTP id g32so62524224qkh.0
        for <linux-mm@kvack.org>; Sat, 30 May 2015 10:54:12 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 8si9007240qgl.61.2015.05.30.10.54.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 May 2015 10:54:11 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH 2/4] sunrpc: make xprt->swapper an atomic_t
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1432987393-15604-3-git-send-email-jeff.layton@primarydata.com>
Date: Sat, 30 May 2015 13:55:44 -0400
Content-Transfer-Encoding: quoted-printable
Message-Id: <12BA87C5-89D9-4244-B2D1-CB18ABBB705F@oracle.com>
References: <1432987393-15604-1-git-send-email-jeff.layton@primarydata.com> <1432987393-15604-3-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Jerome Marchand <jmarchan@redhat.com>

Hi Jeff-

On May 30, 2015, at 8:03 AM, Jeff Layton <jlayton@poochiereds.net> =
wrote:

> Split xs_swapper into enable/disable functions and eliminate the
> "enable" flag.
>=20
> Currently, it's racy if you have multiple swapon/swapoff operations
> running in parallel over the same xprt. Also fix it so that we only
> set it to a memalloc socket on a 0->1 transition and only clear it
> on a 1->0 transition.
>=20
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
> include/linux/sunrpc/xprt.h |  5 +++--
> net/sunrpc/clnt.c           |  4 ++--
> net/sunrpc/xprtsock.c       | 38 =
+++++++++++++++++++++++++-------------
> 3 files changed, 30 insertions(+), 17 deletions(-)
>=20
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index 8b93ef53df3c..26b1624128ec 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -180,7 +180,7 @@ struct rpc_xprt {
> 	atomic_t		num_reqs;	/* total slots */
> 	unsigned long		state;		/* transport state */
> 	unsigned char		resvport   : 1; /* use a reserved port =
*/
> -	unsigned int		swapper;	/* we're swapping over =
this
> +	atomic_t		swapper;	/* we're swapping over =
this
> 						   transport */
> 	unsigned int		bind_index;	/* bind function index =
*/
>=20
> @@ -345,7 +345,8 @@ void			=
xprt_release_rqst_cong(struct rpc_task *task);
> void			xprt_disconnect_done(struct rpc_xprt *xprt);
> void			xprt_force_disconnect(struct rpc_xprt *xprt);
> void			xprt_conditional_disconnect(struct rpc_xprt =
*xprt, unsigned int cookie);
> -int			xs_swapper(struct rpc_xprt *xprt, int enable);
> +int			xs_swapper_enable(struct rpc_xprt *xprt);
> +void			xs_swapper_disable(struct rpc_xprt *xprt);
>=20
> bool			xprt_lock_connect(struct rpc_xprt *, struct =
rpc_task *, void *);
> void			xprt_unlock_connect(struct rpc_xprt *, void *);
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 383cb778179f..804a75e71e84 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -2492,7 +2492,7 @@ retry:
> 			goto retry;
> 		}
>=20
> -		ret =3D xs_swapper(xprt, 1);
> +		ret =3D xs_swapper_enable(xprt);
> 		xprt_put(xprt);
> 	}
> 	return ret;
> @@ -2519,7 +2519,7 @@ retry:
> 			goto retry;
> 		}
>=20
> -		xs_swapper(xprt, 0);
> +		xs_swapper_disable(xprt);
> 		xprt_put(xprt);
> 	}
> }

Seems like xs_swapper() is specific to socket-based transports.

There=92s no struct sock * to use as an argument with RDMA, so =
xs_swapper()
would probably dereference garbage if =93swapon=94 was invoked on a
proto=3Drdma mount point.

Should these new functions be made members of the rpc_xprt_ops? The
RDMA version of the methods can be made no-ops for now.


> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index b29703996028..a2861bbfd319 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1966,31 +1966,43 @@ static void xs_set_memalloc(struct rpc_xprt =
*xprt)
> 	struct sock_xprt *transport =3D container_of(xprt, struct =
sock_xprt,
> 			xprt);
>=20
> -	if (xprt->swapper)
> +	if (atomic_read(&xprt->swapper))
> 		sk_set_memalloc(transport->inet);
> }
>=20
> /**
> - * xs_swapper - Tag this transport as being used for swap.
> + * xs_swapper_enable - Tag this transport as being used for swap.
>  * @xprt: transport to tag
> - * @enable: enable/disable
>  *
> + * Take a reference to this transport on behalf of the rpc_clnt, and
> + * optionally mark it for swapping if it wasn't already.
>  */
> -int xs_swapper(struct rpc_xprt *xprt, int enable)
> +int
> +xs_swapper_enable(struct rpc_xprt *xprt)
> {
> 	struct sock_xprt *transport =3D container_of(xprt, struct =
sock_xprt,
> 			xprt);
> -	int err =3D 0;
>=20
> -	if (enable) {
> -		xprt->swapper++;
> -		xs_set_memalloc(xprt);
> -	} else if (xprt->swapper) {
> -		xprt->swapper--;
> -		sk_clear_memalloc(transport->inet);
> -	}
> +	if (atomic_inc_return(&xprt->swapper) =3D=3D 1)
> +		sk_set_memalloc(transport->inet);
> +	return 0;
> +}
>=20
> -	return err;
> +/**
> + * xs_swapper_disable - Untag this transport as being used for swap.
> + * @xprt: transport to tag
> + *
> + * Drop a "swapper" reference to this xprt on behalf of the rpc_clnt. =
If the
> + * swapper refcount goes to 0, untag the socket as a memalloc socket.
> + */
> +void
> +xs_swapper_disable(struct rpc_xprt *xprt)
> +{
> +	struct sock_xprt *transport =3D container_of(xprt, struct =
sock_xprt,
> +			xprt);
> +
> +	if (atomic_dec_and_test(&xprt->swapper))
> +		sk_clear_memalloc(transport->inet);
> }
> #else
> static void xs_set_memalloc(struct rpc_xprt *xprt)
> --=20
> 2.4.1
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
