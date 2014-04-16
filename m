Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8EB9D6B0080
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 02:49:51 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so8357853eek.17
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 23:49:50 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si28667317eep.317.2014.04.15.23.49.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 23:49:49 -0700 (PDT)
Date: Wed, 16 Apr 2014 16:49:41 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 16/19] VFS: use GFP_NOFS rather than GFP_KERNEL in
 __d_alloc.
Message-ID: <20140416164941.37587da6@notabene.brown>
In-Reply-To: <20140416062520.GG15995@dastard>
References: <20140416033623.10604.69237.stgit@notabene.brown>
	<20140416040337.10604.61837.stgit@notabene.brown>
	<20140416062520.GG15995@dastard>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/EPq.7eSTqOBYBZMF/T4NZ0K"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com

--Sig_/EPq.7eSTqOBYBZMF/T4NZ0K
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 16 Apr 2014 16:25:20 +1000 Dave Chinner <david@fromorbit.com> wrote:

> On Wed, Apr 16, 2014 at 02:03:37PM +1000, NeilBrown wrote:
> > __d_alloc can be called with i_mutex held, so it is safer to
> > use GFP_NOFS.
> >=20
> > lockdep reports this can deadlock when loop-back NFS is in use,
> > as nfsd may be required to write out for reclaim, and nfsd certainly
> > takes i_mutex.
>=20
> But not the same i_mutex as is currently held. To me, this seems
> like a false positive? If you are holding the i_mutex on an inode,
> then you have a reference to the inode and hence memory reclaim
> won't ever take the i_mutex on that inode.
>=20
> FWIW, this sort of false positive was a long stabding problem for
> XFS - we managed to get rid of most of the false positives like this
> by ensuring that only the ilock is taken within memory reclaim and
> memory reclaim can't be entered while we hold the ilock.
>=20
> You can't do that with the i_mutex, though....
>=20
> Cheers,
>=20
> Dave.

I'm not sure this is a false positive.
You can call __d_alloc when creating a file and so are holding i_mutex on t=
he
directory.
nfsd might also want to access that directory.

If there was only 1 nfsd thread, it would need to get i_mutex and do it's
thing before replying to that request and so before it could handle the
COMMIT which __d_alloc is waiting for.

Obviously we would normally have multiple nfsd threads but if they were all
blocked on an i_mutex which itself was blocked on nfs_release_page which was
waiting for an nfsd thread to handling its COMMIT request, this could be a
real deadlock.

Thanks,
NeilBrown

--Sig_/EPq.7eSTqOBYBZMF/T4NZ0K
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU04oBTnsnt1WYoG5AQIv2A/+JHPHOXvvSEvBvND3/I/bvU7038Xt9P09
ROQ9m01KrCbUdCBztnzYFBBQRHb+TGX7/oqNbgR5xz5xQp5udSIOGfW50DvPsmRj
evA2RwwB24XWG4TpZcfAnZXNXNGmjNXYzKcSrrD3Jr1hh54BnYkSmvxk1rjZb77V
lPAtmazM12wyG3OTAP9iKMeNohqzKmL8ZAF3NXBtA7VvAx3Q/bW5Ouk3NDO9sMjP
fP9rvVgZqGBGraTBp/j7hAliuwMdR47OvUvtmlj2Yu8BLwWdmK4uLcgCtiASvhox
IOCQQ/mKw8d0c/vC1kl759kwgXuK87rRQ136xBpcgogBd7g8ER9Z+WmfBHUVndg6
9HjduCoAju0ruvnfHD3Ky4GcMEPPmbwe7nV7LMY8VkLTDjUBLLnoBROdgsbLL2bj
at1fyaeJxQ/lRt3FzQ3ep0n4n366FM1kyHs84J3EiRMImrxAedb/wdZmDN7rQi0s
g4ubAThts0zmUrYsTO+beqxVGNYqmnUdJVWMBX513HBGZ6kZ+sjFIpD2sBkCRIgK
98bXu9ZEz2ZqAACq42uYdNvEIgPrcog80+yLZJQ7GJaPHsdfOWEMrAJPrO5iaSQH
vUbfbjwe722ZicSNlEgw5b5ZWMGb9ssZVeP28fJt0i8k5XNBa13+svkK+6ITOoJz
FZOwEWIhv2A=
=6+ZP
-----END PGP SIGNATURE-----

--Sig_/EPq.7eSTqOBYBZMF/T4NZ0K--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
