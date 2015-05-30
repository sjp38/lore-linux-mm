Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5BE0B6B0032
	for <linux-mm@kvack.org>; Sat, 30 May 2015 15:39:00 -0400 (EDT)
Received: by wgez8 with SMTP id z8so85996917wge.0
        for <linux-mm@kvack.org>; Sat, 30 May 2015 12:38:59 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id i18si16386055wjs.183.2015.05.30.12.38.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 May 2015 12:38:57 -0700 (PDT)
Received: by wicmx19 with SMTP id mx19so40221561wic.0
        for <linux-mm@kvack.org>; Sat, 30 May 2015 12:38:56 -0700 (PDT)
Date: Sat, 30 May 2015 15:38:49 -0400
From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH 2/4] sunrpc: make xprt->swapper an atomic_t
Message-ID: <20150530153849.03d0f1e7@tlielax.poochiereds.net>
In-Reply-To: <12BA87C5-89D9-4244-B2D1-CB18ABBB705F@oracle.com>
References: <1432987393-15604-1-git-send-email-jeff.layton@primarydata.com>
	<1432987393-15604-3-git-send-email-jeff.layton@primarydata.com>
	<12BA87C5-89D9-4244-B2D1-CB18ABBB705F@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Jerome Marchand <jmarchan@redhat.com>

On Sat, 30 May 2015 13:55:44 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> Hi Jeff-
>=20
> On May 30, 2015, at 8:03 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
>=20
> > Split xs_swapper into enable/disable functions and eliminate the
> > "enable" flag.
> >=20
> > Currently, it's racy if you have multiple swapon/swapoff operations
> > running in parallel over the same xprt. Also fix it so that we only
> > set it to a memalloc socket on a 0->1 transition and only clear it
> > on a 1->0 transition.
> >=20
> > Cc: Mel Gorman <mgorman@suse.de>
> > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > ---
> > include/linux/sunrpc/xprt.h |  5 +++--
> > net/sunrpc/clnt.c           |  4 ++--
> > net/sunrpc/xprtsock.c       | 38 +++++++++++++++++++++++++-------------
> > 3 files changed, 30 insertions(+), 17 deletions(-)
> >=20
> > diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> > index 8b93ef53df3c..26b1624128ec 100644
> > --- a/include/linux/sunrpc/xprt.h
> > +++ b/include/linux/sunrpc/xprt.h
> > @@ -180,7 +180,7 @@ struct rpc_xprt {
> > 	atomic_t		num_reqs;	/* total slots */
> > 	unsigned long		state;		/* transport state */
> > 	unsigned char		resvport   : 1; /* use a reserved port */
> > -	unsigned int		swapper;	/* we're swapping over this
> > +	atomic_t		swapper;	/* we're swapping over this
> > 						   transport */
> > 	unsigned int		bind_index;	/* bind function index */
> >=20
> > @@ -345,7 +345,8 @@ void			xprt_release_rqst_cong(struct rpc_task *task=
);
> > void			xprt_disconnect_done(struct rpc_xprt *xprt);
> > void			xprt_force_disconnect(struct rpc_xprt *xprt);
> > void			xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int =
cookie);
> > -int			xs_swapper(struct rpc_xprt *xprt, int enable);
> > +int			xs_swapper_enable(struct rpc_xprt *xprt);
> > +void			xs_swapper_disable(struct rpc_xprt *xprt);
> >=20
> > bool			xprt_lock_connect(struct rpc_xprt *, struct rpc_task *, void *);
> > void			xprt_unlock_connect(struct rpc_xprt *, void *);
> > diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> > index 383cb778179f..804a75e71e84 100644
> > --- a/net/sunrpc/clnt.c
> > +++ b/net/sunrpc/clnt.c
> > @@ -2492,7 +2492,7 @@ retry:
> > 			goto retry;
> > 		}
> >=20
> > -		ret =3D xs_swapper(xprt, 1);
> > +		ret =3D xs_swapper_enable(xprt);
> > 		xprt_put(xprt);
> > 	}
> > 	return ret;
> > @@ -2519,7 +2519,7 @@ retry:
> > 			goto retry;
> > 		}
> >=20
> > -		xs_swapper(xprt, 0);
> > +		xs_swapper_disable(xprt);
> > 		xprt_put(xprt);
> > 	}
> > }
>=20
> Seems like xs_swapper() is specific to socket-based transports.
>=20
> There=E2=80=99s no struct sock * to use as an argument with RDMA, so xs_s=
wapper()
> would probably dereference garbage if =E2=80=9Cswapon=E2=80=9D was invoke=
d on a
> proto=3Drdma mount point.
>=20
> Should these new functions be made members of the rpc_xprt_ops? The
> RDMA version of the methods can be made no-ops for now.
>=20

Oh, right -- rdma uses rpcrdma_xprt instead. Yeah, adding a new ops to
handle this sounds like the right thing to do. I'll roll that into the
v2 set.

Thanks!
Jeff

>=20
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index b29703996028..a2861bbfd319 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -1966,31 +1966,43 @@ static void xs_set_memalloc(struct rpc_xprt
> > *xprt) struct sock_xprt *transport =3D container_of(xprt, struct
> > sock_xprt, xprt);
> >=20
> > -	if (xprt->swapper)
> > +	if (atomic_read(&xprt->swapper))
> > 		sk_set_memalloc(transport->inet);
> > }
> >=20
> > /**
> > - * xs_swapper - Tag this transport as being used for swap.
> > + * xs_swapper_enable - Tag this transport as being used for swap.
> >  * @xprt: transport to tag
> > - * @enable: enable/disable
> >  *
> > + * Take a reference to this transport on behalf of the rpc_clnt,
> > and
> > + * optionally mark it for swapping if it wasn't already.
> >  */
> > -int xs_swapper(struct rpc_xprt *xprt, int enable)
> > +int
> > +xs_swapper_enable(struct rpc_xprt *xprt)
> > {
> > 	struct sock_xprt *transport =3D container_of(xprt, struct
> > sock_xprt, xprt);
> > -	int err =3D 0;
> >=20
> > -	if (enable) {
> > -		xprt->swapper++;
> > -		xs_set_memalloc(xprt);
> > -	} else if (xprt->swapper) {
> > -		xprt->swapper--;
> > -		sk_clear_memalloc(transport->inet);
> > -	}
> > +	if (atomic_inc_return(&xprt->swapper) =3D=3D 1)
> > +		sk_set_memalloc(transport->inet);
> > +	return 0;
> > +}
> >=20
> > -	return err;
> > +/**
> > + * xs_swapper_disable - Untag this transport as being used for
> > swap.
> > + * @xprt: transport to tag
> > + *
> > + * Drop a "swapper" reference to this xprt on behalf of the
> > rpc_clnt. If the
> > + * swapper refcount goes to 0, untag the socket as a memalloc
> > socket.
> > + */
> > +void
> > +xs_swapper_disable(struct rpc_xprt *xprt)
> > +{
> > +	struct sock_xprt *transport =3D container_of(xprt, struct
> > sock_xprt,
> > +			xprt);
> > +
> > +	if (atomic_dec_and_test(&xprt->swapper))
> > +		sk_clear_memalloc(transport->inet);
> > }
> > #else
> > static void xs_set_memalloc(struct rpc_xprt *xprt)
> > --=20
> > 2.4.1
> >=20
> > --
> > To unsubscribe from this list: send the line "unsubscribe
> > linux-nfs" in the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>=20
>=20
>=20


--=20
Jeff Layton <jlayton@poochiereds.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
