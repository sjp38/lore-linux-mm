Subject: Re: [PATCH 11/23] mm: bdi init hooks
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070817161055.GE24323@filer.fsl.cs.sunysb.edu>
References: <20070816074525.065850000@chello.nl>
	 <20070816074627.235952000@chello.nl>
	 <20070817161055.GE24323@filer.fsl.cs.sunysb.edu>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-wwiR1msXhF1K3hk1Dp5Z"
Date: Fri, 17 Aug 2007 18:15:07 +0200
Message-Id: <1187367307.6114.129.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Josef Sipek <jsipek@fsl.cs.sunysb.edu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

--=-wwiR1msXhF1K3hk1Dp5Z
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-08-17 at 12:10 -0400, Josef Sipek wrote:
> On Thu, Aug 16, 2007 at 09:45:36AM +0200, Peter Zijlstra wrote:
> > provide BDI constructor/destructor hooks
> ....
> > Index: linux-2.6/drivers/block/rd.c
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- linux-2.6.orig/drivers/block/rd.c
> > +++ linux-2.6/drivers/block/rd.c
> ....
> > @@ -419,7 +422,19 @@ static void __exit rd_cleanup(void)
> >  static int __init rd_init(void)
> >  {
> >  	int i;
> > -	int err =3D -ENOMEM;
> > +	int err;
> > +
> > +	err =3D bdi_init(&rd_backing_dev_info);
> > +	if (err)
> > +		goto out2;
> > +
> > +	err =3D bdi_init(&rd_file_backing_dev_info);
> > +	if (err) {
> > +		bdi_destroy(&rd_backing_dev_info);
> > +		goto out2;
>=20
> How about this...

seems like a sane idea.

> if (err)
> 	goto out3;
>=20
> > +	}
> > +
> > +	err =3D -ENOMEM;
> > =20
> >  	if (rd_blocksize > PAGE_SIZE || rd_blocksize < 512 ||
> >  			(rd_blocksize & (rd_blocksize-1))) {
> > @@ -473,6 +488,9 @@ out:
> >  		put_disk(rd_disks[i]);
> >  		blk_cleanup_queue(rd_queue[i]);
> >  	}
> > +	bdi_destroy(&rd_backing_dev_info);
> > +	bdi_destroy(&rd_file_backing_dev_info);
>=20
> 	bdi_destroy(&rd_file_backing_dev_info);
> out3:
> 	bdi_destroy(&rd_backing_dev_info);
>=20
> Sure you might want to switch from numbered labels to something a bit mor=
e
> descriptive.

I was just keeping in style here.

Thanks for looking this over, all these error paths did make my head
spin a little.

--=-wwiR1msXhF1K3hk1Dp5Z
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGxcmLXA2jU0ANEf4RAn7mAJ4+1ikx8tsJI2SMt2VxXPp9La9MdACcD3sk
A6MNRImxz9iCKiPaXDiCAUs=
=CLRJ
-----END PGP SIGNATURE-----

--=-wwiR1msXhF1K3hk1Dp5Z--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
