Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 438166B004D
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 19:25:23 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e49so29968eek.11
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 16:25:22 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q2si32403590eep.102.2014.04.16.16.25.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 16:25:21 -0700 (PDT)
Date: Thu, 17 Apr 2014 09:25:04 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 05/19] SUNRPC: track whether a request is coming from a
 loop-back interface.
Message-ID: <20140417092504.57a49f9d@notabene.brown>
In-Reply-To: <20140416104702.264cde48@tlielax.poochiereds.net>
References: <20140416033623.10604.69237.stgit@notabene.brown>
	<20140416040336.10604.14822.stgit@notabene.brown>
	<20140416104702.264cde48@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/CcwxN46Oguly3bCuijnuqE3"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, netdev@vger.kernel.org

--Sig_/CcwxN46Oguly3bCuijnuqE3
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 16 Apr 2014 10:47:02 -0400 Jeff Layton <jlayton@poochiereds.net>
wrote:

> On Wed, 16 Apr 2014 14:03:36 +1000
> NeilBrown <neilb@suse.de> wrote:
>=20
> > If an incoming NFS request is coming from the local host, then
> > nfsd will need to perform some special handling.  So detect that
> > possibility and make the source visible in rq_local.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > ---
> >  include/linux/sunrpc/svc.h      |    1 +
> >  include/linux/sunrpc/svc_xprt.h |    1 +
> >  net/sunrpc/svcsock.c            |   10 ++++++++++
> >  3 files changed, 12 insertions(+)
> >=20
> > diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> > index 04e763221246..a0dbbd1e00e9 100644
> > --- a/include/linux/sunrpc/svc.h
> > +++ b/include/linux/sunrpc/svc.h
> > @@ -254,6 +254,7 @@ struct svc_rqst {
> >  	u32			rq_prot;	/* IP protocol */
> >  	unsigned short
> >  				rq_secure  : 1;	/* secure port */
> > +	unsigned short		rq_local   : 1;	/* local request */
> > =20
> >  	void *			rq_argp;	/* decoded arguments */
> >  	void *			rq_resp;	/* xdr'd results */
> > diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc=
_xprt.h
> > index b05963f09ebf..b99bdfb0fcf9 100644
> > --- a/include/linux/sunrpc/svc_xprt.h
> > +++ b/include/linux/sunrpc/svc_xprt.h
> > @@ -63,6 +63,7 @@ struct svc_xprt {
> >  #define	XPT_DETACHED	10		/* detached from tempsocks list */
> >  #define XPT_LISTENER	11		/* listening endpoint */
> >  #define XPT_CACHE_AUTH	12		/* cache auth info */
> > +#define XPT_LOCAL	13		/* connection from loopback interface */
> > =20
> >  	struct svc_serv		*xpt_server;	/* service for transport */
> >  	atomic_t    	    	xpt_reserved;	/* space on outq that is rsvd */
> > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > index b6e59f0a9475..193115fe968c 100644
> > --- a/net/sunrpc/svcsock.c
> > +++ b/net/sunrpc/svcsock.c
> > @@ -811,6 +811,7 @@ static struct svc_xprt *svc_tcp_accept(struct svc_x=
prt *xprt)
> >  	struct socket	*newsock;
> >  	struct svc_sock	*newsvsk;
> >  	int		err, slen;
> > +	struct dst_entry *dst;
> >  	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
> > =20
> >  	dprintk("svc: tcp_accept %p sock %p\n", svsk, sock);
> > @@ -867,6 +868,14 @@ static struct svc_xprt *svc_tcp_accept(struct svc_=
xprt *xprt)
> >  	}
> >  	svc_xprt_set_local(&newsvsk->sk_xprt, sin, slen);
> > =20
> > +	clear_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
> > +	rcu_read_lock();
> > +	dst =3D rcu_dereference(newsock->sk->sk_dst_cache);
> > +	if (dst && dst->dev &&
> > +	    (dst->dev->features & NETIF_F_LOOPBACK))
> > +		set_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
> > +	rcu_read_unlock();
> > +
>=20
> In the use-case you describe, the client is unlikely to have mounted
> "localhost", but is more likely to be mounting a floating address in
> the cluster.
>=20
> Will this flag end up being set in such a situation? It looks like
> NETIF_F_LOOPBACK isn't set on all adapters -- mostly on "lo" and a few
> others that support MAC-LOOPBACK.

I was hoping someone on net-dev would have commented if it didn't work - I
probably should have explicitly asked.

My testing certainly suggests that this works if I use any local address to
perform the mount, not just 127.0.0.1.
I don't know enough about routing and neighbours and the dst cache to be
certain but my shallow understanding was always that traffic to any local
address was pseudo-routed through the lo interface and would never get
anywhere near e.g. the eth0 interface.

Can any network people confirm?

Thanks,
NeilBrown


>=20
>=20
> >  	if (serv->sv_stats)
> >  		serv->sv_stats->nettcpconn++;
> > =20
> > @@ -1112,6 +1121,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqst=
p)
> > =20
> >  	rqstp->rq_xprt_ctxt   =3D NULL;
> >  	rqstp->rq_prot	      =3D IPPROTO_TCP;
> > +	rqstp->rq_local	      =3D !!test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_fl=
ags);
> > =20
> >  	p =3D (__be32 *)rqstp->rq_arg.head[0].iov_base;
> >  	calldir =3D p[1];
> >=20
> >=20
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20


--Sig_/CcwxN46Oguly3bCuijnuqE3
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU08RVznsnt1WYoG5AQIqlxAAqLL4IuhcC8p8k8jWdErxWKT7tbRpFrbD
Wuek/KQQWWceJyhB6Px0x6PqyZcQki523xOvzVPDhwH1ox0i1B+N6gBB9yNbjejF
9SB+2M5iIWaTLmlJ4ikbTRqnymOabVxrq/wp8E32bB+x88s8KPg7/XUUeEDWmf2D
a/ls9dlVObBQXEHkaNor8p9VDG/4amI+Wrc/n4wcDHoUu1mgUd9fcEjuy15OHd58
jgni/EmCgDaAlVE/+rhgFeLuHzLcfgPB4Sr3oK7mCQR2YDJR7nKsfLIe6uJSvIOS
ZmcPo7SdRaQRn1YFt8fFRWxEeoJVayH5NmKqcqgoja7Bo5Tt+XDQ+F7XGQCvAkyX
0LzyMrm5o3qEky6HcsfpY/6bygcN7O+yuopeEUqIdvkZ4TupRs7WrabeJkAID238
c1trKdNVPVL5IvJijDv76BquDKTWNvLCpDV0wMWvavgy+KOEp94798xYMYm6cRaM
ttgqxcmCfhIZK5HbKSMO6ynqpln9HOioePR5FdhINRLw7Z1fP/2sgizDGKOeImea
nlmMdxJgYxSkGpmYOwmAJuL36Fl6jivQpZdq6EvdtJ0fxeO17CIS2ImU0tiPtH1e
cfb71+ISEIP0Y4GlV7D9dlqTXbw0wrno/84BJLjCTfUtPSzrA0KcqAOg6t+DbfHI
HB1epNHm5L8=
=3z3m
-----END PGP SIGNATURE-----

--Sig_/CcwxN46Oguly3bCuijnuqE3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
