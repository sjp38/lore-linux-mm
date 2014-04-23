Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id D9A926B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 19:14:31 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so1222289eei.5
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 16:14:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z42si5370470eel.2.2014.04.23.16.14.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 16:14:30 -0700 (PDT)
Date: Thu, 24 Apr 2014 09:14:19 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 4/5] SUNRPC: track when a client connection is routed to
 the local host.
Message-ID: <20140424091419.0ba0cfd3@notabene.brown>
In-Reply-To: <5357C3AC.9090203@netapp.com>
References: <20140423022441.4725.89693.stgit@notabene.brown>
	<20140423024058.4725.7703.stgit@notabene.brown>
	<5357C3AC.9090203@netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/cOLNjfjwl9x5Dua.BH=I80E"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, Mel
 Gorman <mgorman@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

--Sig_/cOLNjfjwl9x5Dua.BH=I80E
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 23 Apr 2014 09:44:12 -0400 Anna Schumaker <Anna.Schumaker@netapp.co=
m>
wrote:

> On 04/22/2014 10:40 PM, NeilBrown wrote:
> > If requests are being sent to the local host, then NFS will
> > need to take care to avoid deadlocks.
> >
> > So keep track when accepting a connection or sending a UDP request
> > and set a flag in the svc_xprt when the peer connected to is local.
> >
> > The interface rpc_is_foreign() is provided to check is a given client
> > is connected to a foreign server.  When it returns zero it is either
> > not connected or connected to a local server and in either case
> > greater care is needed.
> >
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > ---
> >  include/linux/sunrpc/clnt.h |    1 +
> >  include/linux/sunrpc/xprt.h |    1 +
> >  net/sunrpc/clnt.c           |   25 +++++++++++++++++++++++++
> >  net/sunrpc/xprtsock.c       |   17 +++++++++++++++++
> >  4 files changed, 44 insertions(+)
> >
> > diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> > index 8af2804bab16..5d626cc5ab01 100644
> > --- a/include/linux/sunrpc/clnt.h
> > +++ b/include/linux/sunrpc/clnt.h
> > @@ -173,6 +173,7 @@ void		rpc_force_rebind(struct rpc_clnt *);
> >  size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
> >  const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_forma=
t_t);
> >  int		rpc_localaddr(struct rpc_clnt *, struct sockaddr *, size_t);
> > +int		rpc_is_foreign(struct rpc_clnt *);
> > =20
> >  #endif /* __KERNEL__ */
> >  #endif /* _LINUX_SUNRPC_CLNT_H */
> > diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> > index 8097b9df6773..318ee37bc358 100644
> > --- a/include/linux/sunrpc/xprt.h
> > +++ b/include/linux/sunrpc/xprt.h
> > @@ -340,6 +340,7 @@ int			xs_swapper(struct rpc_xprt *xprt, int enable);
> >  #define XPRT_CONNECTION_ABORT	(7)
> >  #define XPRT_CONNECTION_CLOSE	(8)
> >  #define XPRT_CONGESTED		(9)
> > +#define XPRT_LOCAL		(10)
> > =20
> >  static inline void xprt_set_connected(struct rpc_xprt *xprt)
> >  {
> > diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> > index 0edada973434..454cea69b373 100644
> > --- a/net/sunrpc/clnt.c
> > +++ b/net/sunrpc/clnt.c
> > @@ -1109,6 +1109,31 @@ const char *rpc_peeraddr2str(struct rpc_clnt *cl=
nt,
> >  }
> >  EXPORT_SYMBOL_GPL(rpc_peeraddr2str);
> > =20
> > +/**
> > + * rpc_is_foreign - report is rpc client was recently connected to
> > + *                  remote host
> > + * @clnt: RPC client structure
> > + *
> > + * If the client is not connected, or connected to the local host
> > + * (any IP address), then return 0.  Only return non-zero if the
> > + * most recent state was a connection to a remote host.
> > + * For UDP the client always appears to be connected, and the
> > + * remoteness of the host is of the destination of the last transmissi=
on.
> > + */
> > +int rpc_is_foreign(struct rpc_clnt *clnt)
> > +{
> > +	struct rpc_xprt *xprt;
> > +	int conn_foreign;
> > +
> > +	rcu_read_lock();
> > +	xprt =3D rcu_dereference(clnt->cl_xprt);
> > +	conn_foreign =3D (xprt && xprt_connected(xprt)
> > +			&& !test_bit(XPRT_LOCAL, &xprt->state));
> > +	rcu_read_unlock();
> > +	return conn_foreign;
> > +}
> > +EXPORT_SYMBOL_GPL(rpc_is_foreign);
> > +
> >  static const struct sockaddr_in rpc_inaddr_loopback =3D {
> >  	.sin_family		=3D AF_INET,
> >  	.sin_addr.s_addr	=3D htonl(INADDR_ANY),
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 0addefca8e77..74796cf37d5b 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -642,6 +642,15 @@ static int xs_udp_send_request(struct rpc_task *ta=
sk)
> >  			xdr->len - req->rq_bytes_sent, status);
> > =20
> >  	if (status >=3D 0) {
> > +		struct dst_entry *dst;
> > +		rcu_read_lock();
> > +		dst =3D rcu_dereference(transport->sock->sk->sk_dst_cache);
> > +		if (dst && dst->dev && (dst->dev->features & NETIF_F_LOOPBACK))
> > +			set_bit(XPRT_LOCAL, &xprt->state);
> > +		else
> > +			clear_bit(XPRT_LOCAL, &xprt->state);
> > +		rcu_read_unlock();
> > +
> You repeat this block of code a bit later.  Can you please make it an inl=
ine helper function?

Thanks for the suggestion.
I've put

static inline int sock_is_loopback(struct sock *sk)
{
	struct dst_entry *dst;
	int loopback =3D 0;
	rcu_read_lock();
	dst =3D rcu_dereference(sk->sk_dst_cache);
	if (dst && dst->dev &&
	    (dst->dev->features & NETIF_F_LOOPBACK))
		loopback =3D 1;
	rcu_read_unlock();
	return loopback;
}


in sunrpc.h, and used it for both the server-side and the client side.

NeilBrown

--Sig_/cOLNjfjwl9x5Dua.BH=I80E
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU1hJSznsnt1WYoG5AQIuPg/9EScpKqpA9AEORKfK9w/MreIQOaHAPItr
2ZAoUbPa6N0aoSWZBLk4GA9oPZLvDMi/3gDbWpGjJoAR4osi+PSA8f078GNnSAFM
JGsuO+xnP1HMQAd2QjEY3fDg+ns9si2BORfWtpebDmTqZNjxiP0VyeBJEvTfR97I
w48aD4cJn8VGi4bs7kqa7fBPBktenUAD1/I9pQCK3gjfFuOkUjCDEGD8Uj+aWb12
5hT+adr+Z1y/c35J45AG86YKQQDdUIib1nMELwQ/RwrJoC3qkaudkyJNROUqUot1
tH1jHl5DClMvWzbIdEUNh2SRoQ13tbvile3N32oN3rDmRHiHM3eYOwc9GFgLFent
xlLB73fbJLvO8lnRqsWdXwLtM9BCCN+t6yzDWnCHD1bTTxs+rMbfx+UWKI98bsPF
NOUuVr0c0UD3HTM2GsKrR91lb7ZBZcTdwJIhswaSq0ZTjmkTiQC7Y7UC1MfXVBlA
pO6PvEQUQXKcoVKVHBqv2VmZLD1ll2PDhh010dg4iwVTPLUCT+Zt/JkHbvV+rD9L
sSiHXzdVGWPft5W1d1zZkRXwDA34e1cCp2JibBrsKIXMcUp7zksuN23kPwJFVdPl
GznVzho/oGIanVF8QhHO219zD2/+x65OG8iDH27SFJjVvpcyRVfM3xOx7DqD6m9W
LpXIcr1FmSE=
=mIQG
-----END PGP SIGNATURE-----

--Sig_/cOLNjfjwl9x5Dua.BH=I80E--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
