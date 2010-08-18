Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0800D6B01F2
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 15:31:45 -0400 (EDT)
Subject: Re: [PATCH] VM: kswapd should not do blocking memory allocations
From: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <AANLkTi=WkoxjwZbt6Vd0VhbuA7_k2WM-NUXZnrmzOOPy@mail.gmail.com>
References: <1282158241.8540.85.camel@heimdal.trondhjem.org>
	 <AANLkTi=WkoxjwZbt6Vd0VhbuA7_k2WM-NUXZnrmzOOPy@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 18 Aug 2010 15:31:12 -0400
Message-ID: <1282159872.8540.96.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Ram Pai <ram.n.pai@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2010-08-18 at 12:24 -0700, Ram Pai wrote:
>=20
>=20
> On Wed, Aug 18, 2010 at 12:04 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
>         From: Trond Myklebust <Trond.Myklebust@netapp.com>
>        =20
>         Allowing kswapd to do GFP_KERNEL memory allocations (or any
>         blocking memory
>         allocations) is wrong and can cause deadlocks in
>         try_to_release_page(), as
>         the filesystem believes it is safe to allocate new memory and
>         block,
>         whereas kswapd is there specifically to clear a low-memory
>         situation...
>        =20
>         Set the gfp_mask to GFP_IOFS instead.
>        =20
>         Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>         ---
>        =20
>          mm/vmscan.c |    2 +-
>          1 files changed, 1 insertions(+), 1 deletions(-)
>        =20
>        =20
>         diff --git a/mm/vmscan.c b/mm/vmscan.c
>         index ec5ddcc..716dd16 100644
>         --- a/mm/vmscan.c
>         +++ b/mm/vmscan.c
>         @@ -2095,7 +2095,7 @@ static unsigned long
>         balance_pgdat(pg_data_t *pgdat, int order)
>                unsigned long total_scanned;
>                struct reclaim_state *reclaim_state =3D
>         current->reclaim_state;
>                struct scan_control sc =3D {
>         -               .gfp_mask =3D GFP_KERNEL,
>         +               .gfp_mask =3D GFP_IOFS,
>                        .may_unmap =3D 1,
>                        .may_swap =3D 1,
>                        /*
>=20
> Trond,
>=20
>            Has anyone hit this issue? Or is this based on code
> inspection? =20
>=20
>            The reason I  ask is we are seeing a problem, similar to
> the symptom described, on RH based kernel but have not been able to
> reproduce on 2.6.35.

Hi Ram,

I was seeing it on NFS until I put in the following kswapd-specific hack
into nfs_release_page():

	/* Only do I/O if gfp is a superset of GFP_KERNEL */
	if (mapping && (gfp & GFP_KERNEL) =3D=3D GFP_KERNEL) {
		int how =3D FLUSH_SYNC;

		/* Don't let kswapd deadlock waiting for OOM RPC calls */
		if (current_is_kswapd())
			how =3D 0;
		nfs_commit_inode(mapping->host, how);
	}

Remove the 'if (current_is_kswapd())' line, and run an mmap() write
intensive workload, and it should hang pretty much every time.

Cheers
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
