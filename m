Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 133746B0068
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 02:17:36 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so8279776eek.18
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 23:17:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si28590223eei.145.2014.04.15.23.17.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 23:17:35 -0700 (PDT)
Date: Wed, 16 Apr 2014 16:17:26 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 04/19] Make effect of PF_FSTRANS to disable __GFP_FS
 universal.
Message-ID: <20140416161726.51b506e2@notabene.brown>
In-Reply-To: <20140416053756.GC15995@dastard>
References: <20140416033623.10604.69237.stgit@notabene.brown>
	<20140416040336.10604.58240.stgit@notabene.brown>
	<20140416053756.GC15995@dastard>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Oo0=qxWoYRMUFxVoAOmvLbc"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Ming Lei <ming.lei@canonical.com>, xfs@oss.sgi.com

--Sig_/Oo0=qxWoYRMUFxVoAOmvLbc
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 16 Apr 2014 15:37:56 +1000 Dave Chinner <david@fromorbit.com> wrote:

> On Wed, Apr 16, 2014 at 02:03:36PM +1000, NeilBrown wrote:
> > Currently both xfs and nfs will handle PF_FSTRANS by disabling
> > __GFP_FS.
> >=20
> > Make this effect global by repurposing memalloc_noio_flags (which
> > does the same thing for PF_MEMALLOC_NOIO and __GFP_IO) to generally
> > impost the task flags on a gfp_t.
> > Due to this repurposing we change the name of memalloc_noio_flags
> > to gfp_from_current().
> >=20
> > As PF_FSTRANS now uniformly removes __GFP_FS we can remove special
> > code for this from xfs and nfs.
> >=20
> > As we can now expect other code to set PF_FSTRANS, its meaning is more
> > general, so the WARN_ON in xfs_vm_writepage() which checks PF_FSTRANS
> > is not set is no longer appropriate.  PF_FSTRANS may be set for other
> > reasons than an XFS transaction.
>=20
> So PF_FSTRANS no longer means "filesystem in transaction context".
> Are you going to rename to match whatever it's meaning is now?
> I'm not exactly clear on what it means now...

I did consider renaming it to "PF_MEMALLOC_NOFS" as it is similar to
"PF_MEMALLOC_NOIO", except that it disables __GFP_FS rather than __GFP_IO.
Maybe I should go ahead with that.

>=20
>=20
> > As lockdep cares about __GFP_FS, we need to translate PF_FSTRANS to
> > __GFP_FS before calling lockdep_alloc_trace() in various places.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> ....
> > diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
> > index 64db0e53edea..882b86270ebe 100644
> > --- a/fs/xfs/kmem.h
> > +++ b/fs/xfs/kmem.h
> > @@ -50,8 +50,6 @@ kmem_flags_convert(xfs_km_flags_t flags)
> >  		lflags =3D GFP_ATOMIC | __GFP_NOWARN;
> >  	} else {
> >  		lflags =3D GFP_KERNEL | __GFP_NOWARN;
> > -		if ((current->flags & PF_FSTRANS) || (flags & KM_NOFS))
> > -			lflags &=3D ~__GFP_FS;
> >  	}
>=20
> I think KM_NOFS needs to remain here, as it has use outside of
> transaction contexts that set PF_FSTRANS....

Argh, yes of course.
I'll have to re-test the other xfs changes now to see if they are really
needed.

Thanks!


>=20
> >  	if (flags & KM_ZERO)
> > diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> > index db2cfb067d0b..207a7f86d5d7 100644
> > --- a/fs/xfs/xfs_aops.c
> > +++ b/fs/xfs/xfs_aops.c
> > @@ -952,13 +952,6 @@ xfs_vm_writepage(
> >  			PF_MEMALLOC))
> >  		goto redirty;
> > =20
> > -	/*
> > -	 * Given that we do not allow direct reclaim to call us, we should
> > -	 * never be called while in a filesystem transaction.
> > -	 */
> > -	if (WARN_ON(current->flags & PF_FSTRANS))
> > -		goto redirty;
>=20
> We still need to ensure this rule isn't broken. If it is, the
> filesystem will silently deadlock in delayed allocation rather than
> gracefully handle the problem with a warning....

Hmm... that might be tricky.  The 'new' PF_FSTRANS can definitely be set wh=
en
xfs_vm_writepage is called and we really want the write to happen.
I don't suppose there is any other way to detect if a transaction is
happening?

Thanks,
NeilBrown


--Sig_/Oo0=qxWoYRMUFxVoAOmvLbc
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU04gdjnsnt1WYoG5AQJjow//evh86FCU/MZNvwJIfgaA7CJS8ZBO2vac
JkRsYYSmmSyFY4gWC9gDQfRJD01TaQRR55toAqxbZg8L1HbbL5i4ZBEpJQVYel8Y
pdI2N75oZ6GCufLuivZ0hw6TGotfcwtGQFXjewpcpBDrx2Dr0+yxhObkKAh8W1ae
f5dvKrZ0sYAaEGYj+XHzPb6STEYspdmnflzOOzRXLsCWOeM/uKEt9Cv0l12TXvyr
kBYoY3HBMnKCBsvJPakCGZB+eSyR9PKLL5t846/ZL0Pfwic8OdCU6nBTncGbf2w/
TCWWLxF2trF2f1aMx9TZef+IulH2KdZm5s1HALZ/edGnto8Wz2wgMGNpoj95rhT1
3n5Qn7+P+B491bBGNVbbw2ObPl+aB1k5FgDwy++M7wSBUVjqqGaGAjqEXcgQJ9RV
zBM6mMZyICqnSqy/3h5ACDK9xmCcb/lVXscSMFuGlEIcqiz9ehnmZWWJrsWjvLa7
gOpO51fbFepKaA6MbhGlyOiOLH3XOpwuGQcsvpxCgT6vRs8C2yRutFbtbtVliaPQ
I+g/hpkMJEqUvsRu/Dk44ndA3U64gnQuoFzgcYxZoFdCbzq/xP7w5LH7MbNeSSvH
SvgiEpGCVhHsOfP8Z1pt01kCsnONRkMTQP8KxGDycDLnKAEC1YPvWCFB0Za5acJ6
YVnpDRofW5g=
=0rPl
-----END PGP SIGNATURE-----

--Sig_/Oo0=qxWoYRMUFxVoAOmvLbc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
