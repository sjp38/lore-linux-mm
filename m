Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 055D86B0073
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 02:27:54 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so8324059eek.6
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 23:27:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si28633557eer.117.2014.04.15.23.27.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 23:27:53 -0700 (PDT)
Date: Wed, 16 Apr 2014 16:27:45 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 09/19] XFS: ensure xfs_file_*_read cannot deadlock in
 memory allocation.
Message-ID: <20140416162745.67442b07@notabene.brown>
In-Reply-To: <20140416060459.GE15995@dastard>
References: <20140416033623.10604.69237.stgit@notabene.brown>
	<20140416040336.10604.90380.stgit@notabene.brown>
	<20140416060459.GE15995@dastard>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/MvhSwDVhkQM3eTbru=iHpwX"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com

--Sig_/MvhSwDVhkQM3eTbru=iHpwX
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 16 Apr 2014 16:04:59 +1000 Dave Chinner <david@fromorbit.com> wrote:

> On Wed, Apr 16, 2014 at 02:03:36PM +1000, NeilBrown wrote:
> > xfs_file_*_read holds an inode lock while calling a generic 'read'
> > function.  These functions perform read-ahead and are quite likely to
> > allocate memory.
>=20
> Yes, that's what reading data from disk requires.
>=20
> > So set PF_FSTRANS to ensure they avoid __GFP_FS and so don't recurse
> > into a filesystem to free memory.
>=20
> We already have that protection via the
> >=20
> > This can be a problem with loop-back NFS mounts, if free_pages ends up
> > wating in nfs_release_page(), and nfsd is blocked waiting for the lock
> > that this code holds.
> >=20
> > This was found both by lockdep and as a real deadlock during testing.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > ---
> >  fs/xfs/xfs_file.c |   12 ++++++++++++
> >  1 file changed, 12 insertions(+)
> >=20
> > diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> > index 64b48eade91d..88b33ef64668 100644
> > --- a/fs/xfs/xfs_file.c
> > +++ b/fs/xfs/xfs_file.c
> > @@ -243,6 +243,7 @@ xfs_file_aio_read(
> >  	ssize_t			ret =3D 0;
> >  	int			ioflags =3D 0;
> >  	xfs_fsize_t		n;
> > +	unsigned int		pflags;
> > =20
> >  	XFS_STATS_INC(xs_read_calls);
> > =20
> > @@ -290,6 +291,10 @@ xfs_file_aio_read(
> >  	 * proceeed concurrently without serialisation.
> >  	 */
> >  	xfs_rw_ilock(ip, XFS_IOLOCK_SHARED);
> > +	/* As we hold a lock, we must ensure that any allocation
> > +	 * in generic_file_aio_read avoid __GFP_FS
> > +	 */
> > +	current_set_flags_nested(&pflags, PF_FSTRANS);
>=20
> Ugh. No. This is Simply Wrong.
>=20
> We handle the memory allocations in the IO path with
> GFP_NOFS/KM_NOFS where necessary.
>=20
> We also do this when setting up regular file inodes in
> xfs_setup_inode():
>=20
>         /*
>          * Ensure all page cache allocations are done from GFP_NOFS conte=
xt to
>          * prevent direct reclaim recursion back into the filesystem and =
blowing
>          * stacks or deadlocking.
>          */
>         gfp_mask =3D mapping_gfp_mask(inode->i_mapping);
>         mapping_set_gfp_mask(inode->i_mapping, (gfp_mask & ~(__GFP_FS)));
>=20
> Which handles all of the mapping allocations that occur within the
> page cache read/write paths.
>=20
> Remember, you removed the KM_NOFS code from the XFS allocator that
> caused it to clear __GFP_FS in an earlier patch - the read Io path
> is one of the things you broke by doing that....
>=20
> If there are places where we don't use GFP_NOFS context allocations
> that we should, then we need to fix them individually....
>=20
> Cheers,
>=20
> Dave.

Thanks Dave.  Having fixed the KM_NOFS error I'll start retesting with all
the other xfs patches removed.

NeilBrown

--Sig_/MvhSwDVhkQM3eTbru=iHpwX
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU04i4Tnsnt1WYoG5AQLIng//dBc4GkVWQndYfJfRIYKQW2/Qp2VQNTrH
QwogU8BASNXT5qpc1XzaQYOxkK09+w+6QiWjUGdtmxeca4vNynxYEVsVosaUPzPY
0YgVm+0k4xBCGRhZZ8y5YWqizoYR2chAlE6gIIzFaNRCHajzP8Xet09XxNTR9tYi
EcxV88isRZ8zKGmXnu5emZxq+XdZmf3yjD9YsRlidhny2AnIs5bcjhDad87njled
knLHfb2oDGwZqvjE6giqHoCRwUodRXHzPQ3yKG9YMuzvp6/DKe5Zp4R4byUcwWNk
mngvZ9K82T1D8o6Q7t6GsiwszXF0VIhl4eP2Og4hlhPWd777WR/fCFqumJqrFCEW
UyrRvTUoY2zr8b9SRIEXKaK5BslTkoaQxTBodLmb2x/BtnpyTWXmF8ProhEEgTcl
rbS42PSuxrrjCvoxcM/PTeUeErwb4m16laziroWfx4WblVrtcKB1Zjvnt03N/zRf
2sE9WOqxtP4nZmOiQaLyMeto7QOwUWTS1BcpzUQ1/bqh18u91odzQqFA5dozTg6a
5kX2sujAyBb++B0ixYhBkjAaSTE6KgShEsCit+VcefOEYm3nHvOM4a7A+dIrlaes
PN6E0STK5yi+ZOgKIQpU0uh1JNLOR0Rmu2/6/Hrizpt6OUGpMrtKAfnxRgpPg2Ha
l67YsKqaHVI=
=Ny7o
-----END PGP SIGNATURE-----

--Sig_/MvhSwDVhkQM3eTbru=iHpwX--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
