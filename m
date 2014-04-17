Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id E0ABE6B0069
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 21:04:00 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so65798eek.2
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 18:04:00 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q2si32613700eep.282.2014.04.16.18.03.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 18:03:59 -0700 (PDT)
Date: Thu, 17 Apr 2014 11:03:50 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 04/19] Make effect of PF_FSTRANS to disable __GFP_FS
 universal.
Message-ID: <20140417110350.0470feba@notabene.brown>
In-Reply-To: <20140416161726.51b506e2@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
	<20140416040336.10604.58240.stgit@notabene.brown>
	<20140416053756.GC15995@dastard>
	<20140416161726.51b506e2@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/adF=M005=1pA2q4e/57yzVC"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Ming Lei <ming.lei@canonical.com>, xfs@oss.sgi.com

--Sig_/adF=M005=1pA2q4e/57yzVC
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 16 Apr 2014 16:17:26 +1000 NeilBrown <neilb@suse.de> wrote:

> On Wed, 16 Apr 2014 15:37:56 +1000 Dave Chinner <david@fromorbit.com> wro=
te:
>=20
> > On Wed, Apr 16, 2014 at 02:03:36PM +1000, NeilBrown wrote:

> > > -	/*
> > > -	 * Given that we do not allow direct reclaim to call us, we should
> > > -	 * never be called while in a filesystem transaction.
> > > -	 */
> > > -	if (WARN_ON(current->flags & PF_FSTRANS))
> > > -		goto redirty;
> >=20
> > We still need to ensure this rule isn't broken. If it is, the
> > filesystem will silently deadlock in delayed allocation rather than
> > gracefully handle the problem with a warning....
>=20
> Hmm... that might be tricky.  The 'new' PF_FSTRANS can definitely be set =
when
> xfs_vm_writepage is called and we really want the write to happen.
> I don't suppose there is any other way to detect if a transaction is
> happening?

I've been thinking about this some more....

That code is in xfs_vm_writepage which is only called as ->writepage.
xfs never calls that directly so it could only possibly be called during
reclaim?

We know that doesn't happen, but if it does then PF_MEMALLOC would be set,
but PF_KSWAPD would not... and you already have a test for that.

How about every time we set PF_FSTRANS, we store the corresponding
xfs_trans_t in current->journal_info, and clear that field when PF_FSTRANS =
is
cleared.  Then xfs_vm_writepage can test for current->journal_info being
clear.
That is the field that several other filesystems use to keep track of the
'current' transaction.
??

I don't know what xfs_trans_t we would use in xfs_bmapi_allocate_worker, but
I suspect you do :-)

Thanks,
NeilBrown

--Sig_/adF=M005=1pA2q4e/57yzVC
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU08odjnsnt1WYoG5AQKlChAAtwOt5vnmgGZoKPVxl0nE3BD+JkYt5gYE
xPlrWpCzoazarfKoC66zfad9ldRYo6FjPlvoiKgO+hdQedc3C47rWrmuahe1S4Wl
0Ernd5J8XmInWsL1pobaEQf8b9XnzZ0Bs4GfEnE0WuABblVF1T6hN8eBVqVev+gK
uwT0QOmFxsoxaTvlS4Y9sKEJ98+k9zfg4rvYptEUCUkDwz6IoqqbtCzmsA6WhCUu
p9ZzFa9CCPIvA8zoWFS6mOHgC8YWubWPfpbWg7TT4PnAtq597NhyV1k2LbS7aErR
r7X3jr9hqpV+nz25Nqe4oNo+VCcDI5PypNr8uUdXpAWdRrexeRXCLyye21TFtKnS
WY7VLyLFGyZD3G2t1rT23MN0BepEOErZNanTUoMJgxsbbQGoKKbnaJeWiQLzSH6F
pgfRYuUAgYCnlrYKLxKVOSfjtfQVzBc9BzHRyWD1SdAmnbxxdCq2n9wyMCwx7yf8
pYqru1nk67lPV8gvNgkpes0G3Ooxf6E0cu74DeUPsTrC16gK1iE/qs2LTmuAmT7f
M1//LfAwyxLXaZ64ZQNObcG5J3gsqALtT3eiBUsAK2D8D80m5pR1LmSHgXy8qVs5
I1FN9OvpV6toEw5iAX9bwagB2zzTiJvTS2qHHMeJ2AqQriN5jMrpeud4QasyBxCr
KjIpmijtXwI=
=OIdO
-----END PGP SIGNATURE-----

--Sig_/adF=M005=1pA2q4e/57yzVC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
