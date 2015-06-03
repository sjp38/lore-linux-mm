Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id B45E1900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 15:03:21 -0400 (EDT)
Received: by igbsb11 with SMTP id sb11so22349907igb.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 12:03:21 -0700 (PDT)
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com. [209.85.213.179])
        by mx.google.com with ESMTPS id b16si1548186igv.11.2015.06.03.12.03.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 12:03:19 -0700 (PDT)
Received: by igbpi8 with SMTP id pi8so120152798igb.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 12:03:18 -0700 (PDT)
Date: Wed, 3 Jun 2015 15:03:11 -0400
From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH v2 5/5] sunrpc: turn swapper_enable/disable functions
 into rpc_xprt_ops
Message-ID: <20150603150311.29688337@tlielax.poochiereds.net>
In-Reply-To: <C4DF995C-4064-4DFD-99DD-8F397D394334@oracle.com>
References: <1433342632-16173-1-git-send-email-jeff.layton@primarydata.com>
	<1433342632-16173-6-git-send-email-jeff.layton@primarydata.com>
	<CAHQdGtQGeVRTfv-hvZj_bHqgb5Cs84TY-ScFqzJ3qQOZy2qLcQ@mail.gmail.com>
	<20150603110158.0d21844d@synchrony.poochiereds.net>
	<C4DF995C-4064-4DFD-99DD-8F397D394334@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Jerome Marchand <jmarchan@redhat.com>

On Wed, 3 Jun 2015 13:07:34 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

>=20
> On Jun 3, 2015, at 11:01 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
>=20
> > On Wed, 3 Jun 2015 10:48:10 -0400
> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> >=20
> >> On Wed, Jun 3, 2015 at 10:43 AM, Jeff Layton <jlayton@poochiereds.net>=
 wrote:
> >>> RDMA xprts don't have a sock_xprt, but an rdma_xprt, so the
> >>> xs_swapper_enable/disable functions will likely oops when fed an RDMA
> >>> xprt. Turn these functions into rpc_xprt_ops so that that doesn't
> >>> occur. For now the RDMA versions are no-ops.
> >>>=20
> >>> Cc: Chuck Lever <chuck.lever@oracle.com>
> >>> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> >>> ---
> >>> include/linux/sunrpc/xprt.h     | 16 ++++++++++++++--
> >>> net/sunrpc/clnt.c               |  4 ++--
> >>> net/sunrpc/xprtrdma/transport.c | 15 ++++++++++++++-
> >>> net/sunrpc/xprtsock.c           | 31 +++++++++++++++++++++++++------
> >>> 4 files changed, 55 insertions(+), 11 deletions(-)
> >>>=20
> >>> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> >>> index 26b1624128ec..7eb58610eb94 100644
> >>> --- a/include/linux/sunrpc/xprt.h
> >>> +++ b/include/linux/sunrpc/xprt.h
> >>> @@ -133,6 +133,8 @@ struct rpc_xprt_ops {
> >>>        void            (*close)(struct rpc_xprt *xprt);
> >>>        void            (*destroy)(struct rpc_xprt *xprt);
> >>>        void            (*print_stats)(struct rpc_xprt *xprt, struct s=
eq_file *seq);
> >>> +       int             (*enable_swap)(struct rpc_xprt *xprt);
> >>> +       void            (*disable_swap)(struct rpc_xprt *xprt);
> >>> };
> >>>=20
> >>> /*
> >>> @@ -327,6 +329,18 @@ static inline __be32 *xprt_skip_transport_header=
(struct rpc_xprt *xprt, __be32 *
> >>>        return p + xprt->tsh_size;
> >>> }
> >>>=20
> >>> +static inline int
> >>> +xprt_enable_swap(struct rpc_xprt *xprt)
> >>> +{
> >>> +       return xprt->ops->enable_swap(xprt);
> >>> +}
> >>> +
> >>> +static inline void
> >>> +xprt_disable_swap(struct rpc_xprt *xprt)
> >>> +{
> >>> +       xprt->ops->disable_swap(xprt);
> >>> +}
> >>> +
> >>> /*
> >>>  * Transport switch helper functions
> >>>  */
> >>> @@ -345,8 +359,6 @@ void                        xprt_release_rqst_con=
g(struct rpc_task *task);
> >>> void                   xprt_disconnect_done(struct rpc_xprt *xprt);
> >>> void                   xprt_force_disconnect(struct rpc_xprt *xprt);
> >>> void                   xprt_conditional_disconnect(struct rpc_xprt *x=
prt, unsigned int cookie);
> >>> -int                    xs_swapper_enable(struct rpc_xprt *xprt);
> >>> -void                   xs_swapper_disable(struct rpc_xprt *xprt);
> >>>=20
> >>> bool                   xprt_lock_connect(struct rpc_xprt *, struct rp=
c_task *, void *);
> >>> void                   xprt_unlock_connect(struct rpc_xprt *, void *);
> >>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> >>> index 804a75e71e84..60d1835edb26 100644
> >>> --- a/net/sunrpc/clnt.c
> >>> +++ b/net/sunrpc/clnt.c
> >>> @@ -2492,7 +2492,7 @@ retry:
> >>>                        goto retry;
> >>>                }
> >>>=20
> >>> -               ret =3D xs_swapper_enable(xprt);
> >>> +               ret =3D xprt_enable_swap(xprt);
> >>>                xprt_put(xprt);
> >>>        }
> >>>        return ret;
> >>> @@ -2519,7 +2519,7 @@ retry:
> >>>                        goto retry;
> >>>                }
> >>>=20
> >>> -               xs_swapper_disable(xprt);
> >>> +               xprt_disable_swap(xprt);
> >>>                xprt_put(xprt);
> >>>        }
> >>> }
> >>> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/tr=
ansport.c
> >>> index 54f23b1be986..e7a157754095 100644
> >>> --- a/net/sunrpc/xprtrdma/transport.c
> >>> +++ b/net/sunrpc/xprtrdma/transport.c
> >>> @@ -682,6 +682,17 @@ static void xprt_rdma_print_stats(struct rpc_xpr=
t *xprt, struct seq_file *seq)
> >>>           r_xprt->rx_stats.bad_reply_count);
> >>> }
> >>>=20
> >>> +static int
> >>> +xprt_rdma_enable_swap(struct rpc_xprt *xprt)
> >>> +{
> >>> +       return 0;
> >>=20
> >> Shouldn't the function be returning an error here? What does swapon
> >> expect if the device you are trying to enable doesn't support swap?
> >>=20
> >=20
> >=20
> > Chuck suggested making these no-ops for RDMA for now.
>=20
> I did indeed. What I meant was that you needn=E2=80=99t worry too much ri=
ght now
> about how swap-on-NFS/RDMA is supposed to work, just make it not crash, a=
nd
> someone (maybe me) will look at it later to ensure it is working correctly
> and then we can claim it is supported. Sorry I was not clear.
>=20
> > I'm fine with
> > returning an error, but is it really an error? Maybe RDMA doesn't need
> > any special setup for swapping?
>=20
> This sounds a little snarky, but we don=E2=80=99t know for sure that noth=
ing is
> needed until it is tested and reviewed. I think it=E2=80=99s reasonable t=
o assume
> it doesn=E2=80=99t work 100% until we have positive confirmation that it =
does work.
>=20
> Maybe add a comment to that effect in these new xprt methods? And I would
> have it return something like ENOSYS.=20
>=20
> Likewise, consider the same return code here:
>=20
> +#if IS_ENABLED(CONFIG_SUNRPC_SWAP)
> +int rpc_clnt_swap_activate(struct rpc_clnt *clnt);
> +void rpc_clnt_swap_deactivate(struct rpc_clnt *clnt);
> +#else
> +static inline int
> +rpc_clnt_swap_activate(struct rpc_clnt *clnt)
> +{
> +	return 0;
>               ^^^^
> +}
>=20
> I=E2=80=99m not familiar enough with the swapon administrative interface =
to know if
> =E2=80=9Cswapping on this device is not supported=E2=80=9D is a reasonabl=
e and expected
> failure mode for swapon. So maybe I=E2=80=99m just full of turtles.
>=20

No worries. I'm fine with returning an error if this stuff is disabled.
The manpage seems to indicate that EINVAL is the right error code to
use, but I'll see if I can verify that.

I'll need to look over the code a little more...
--=20
Jeff Layton <jlayton@poochiereds.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
