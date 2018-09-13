Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 170E88E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 23:20:21 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id m4-v6so1869951pgq.19
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 20:20:21 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id w1-v6si3142401pgt.629.2018.09.12.20.20.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 12 Sep 2018 20:20:19 -0700 (PDT)
Date: Thu, 13 Sep 2018 13:20:12 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2018-09-12-16-40 uploaded (psi)
Message-ID: <20180913132012.1506f0da@canb.auug.org.au>
In-Reply-To: <20180913014222.GA2370@cmpxchg.org>
References: <20180912234039.Xa5RS%akpm@linux-foundation.org>
	<a9bef471-ac93-2983-618b-ffee65f01e0b@infradead.org>
	<20180913014222.GA2370@cmpxchg.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/A0EZjjD/ORosSL0xF1vKrbv"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

--Sig_/A0EZjjD/ORosSL0xF1vKrbv
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Johannes,

On Wed, 12 Sep 2018 21:42:22 -0400 Johannes Weiner <hannes@cmpxchg.org> wro=
te:
>
> Thanks for the report.
>=20
> On Wed, Sep 12, 2018 at 05:45:08PM -0700, Randy Dunlap wrote:
> > Multiple build errors when CONFIG_SMP is not set: (this is on i386 fwiw)
> >=20
> > in the psi (pressure) patches, I guess:
> >=20
> > In file included from ../kernel/sched/sched.h:1367:0,
> >                  from ../kernel/sched/core.c:8:
> > ../kernel/sched/stats.h: In function 'psi_task_tick':
> > ../kernel/sched/stats.h:135:33: error: 'struct rq' has no member named =
'cpu'
> >    psi_memstall_tick(rq->curr, rq->cpu); =20
>=20
> This needs to use the SMP/UP config-aware accessor.
>=20
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>=20
> diff --git a/kernel/sched/stats.h b/kernel/sched/stats.h
> index 2e07d8f59b3e..4904c4677000 100644
> --- a/kernel/sched/stats.h
> +++ b/kernel/sched/stats.h
> @@ -132,7 +132,7 @@ static inline void psi_task_tick(struct rq *rq)
>  		return;
> =20
>  	if (unlikely(rq->curr->flags & PF_MEMSTALL))
> -		psi_memstall_tick(rq->curr, rq->cpu);
> +		psi_memstall_tick(rq->curr, cpu_of(rq));
>  }
>  #else /* CONFIG_PSI */
>  static inline void psi_enqueue(struct task_struct *p, bool wakeup) {}

I will add this to linux-next today.

--=20
Cheers,
Stephen Rothwell

--Sig_/A0EZjjD/ORosSL0xF1vKrbv
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAluZ12wACgkQAVBC80lX
0GyQDgf/R2XVV++XEvoRc1HlT8r5XB6DziGyJq2s5SGzvzF4nqVChOYkL7aEBpxZ
qr5DVdFGqZigJ0eT8SWLGhNoYFyg9QOBIk3t4JNlDENfWIyQl6LPAPMo0AmtHKDK
mkJfpt9pk2Gn4s64xvtjHuW9fmBP+DIP5GxDhAa7/K3LRFZO92FnG961/yauZBXy
PWg90KvKpkbhPIV0xbr40WiY7JDC7hdPoLIBofdmLgMI5rijwcdD2lTIUoF3hPW6
NQ/0eoUv8wml4XcedidUV0jSuDC+ohfifD1n8OH4xUvJTYpgiH0pGhERrrm+msBF
AAJU5BRC8YDJNnwJQyg3Qj0+bZs4qw==
=Fhk5
-----END PGP SIGNATURE-----

--Sig_/A0EZjjD/ORosSL0xF1vKrbv--
