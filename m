Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB5D8D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 16:40:27 -0500 (EST)
Received: by vxc38 with SMTP id 38so540023vxc.14
        for <linux-mm@kvack.org>; Wed, 02 Mar 2011 13:40:25 -0800 (PST)
Date: Wed, 2 Mar 2011 16:40:19 -0500
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCHv2 13/24] sys_swapon: separate bdev claim and inode lock
Message-ID: <20110302214019.GB2864@mgebm.net>
References: <4D6D7FEA.80800@cesarb.net>
 <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
 <1299022128-6239-14-git-send-email-cesarb@cesarb.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xgyAXRrhYN0wYx8y"
Content-Disposition: inline
In-Reply-To: <1299022128-6239-14-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org


--xgyAXRrhYN0wYx8y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Nit pick below

On Tue, 01 Mar 2011, Cesar Eduardo Barros wrote:

> Move the code which claims the bdev (S_ISBLK) or locks the inode
> (S_ISREG) to a separate function. Only code movement, no functional
> changes.
>=20
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
> ---
>  mm/swapfile.c |   64 ++++++++++++++++++++++++++++++++++-----------------=
-----
>  1 files changed, 39 insertions(+), 25 deletions(-)
>=20
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 96be104..27faeec 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1889,6 +1889,43 @@ static struct swap_info_struct *alloc_swap_info(vo=
id)
>  	return p;
>  }
> =20
> +static int claim_swapfile(struct swap_info_struct *p, struct inode *inod=
e)
> +{
> +	int error;
> +
> +	if (S_ISBLK(inode->i_mode)) {
> +		p->bdev =3D bdgrab(I_BDEV(inode));
> +		error =3D blkdev_get(p->bdev,
> +				   FMODE_READ | FMODE_WRITE | FMODE_EXCL,
> +				   sys_swapon);
> +		if (error < 0) {
> +			p->bdev =3D NULL;
> +			error =3D -EINVAL;
> +			goto bad_swap;
> +		}
> +		p->old_block_size =3D block_size(p->bdev);
> +		error =3D set_blocksize(p->bdev, PAGE_SIZE);
> +		if (error < 0)
> +			goto bad_swap;
> +		p->flags |=3D SWP_BLKDEV;
> +	} else if (S_ISREG(inode->i_mode)) {
> +		p->bdev =3D inode->i_sb->s_bdev;
> +		mutex_lock(&inode->i_mutex);
> +		if (IS_SWAPFILE(inode)) {
> +			error =3D -EBUSY;
> +			goto bad_swap;
> +		}
> +	} else {
> +		error =3D -EINVAL;
> +		goto bad_swap;
> +	}
> +
> +	return 0;
> +
> +bad_swap:
> +	return error;
> +}
> +
>  SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flag=
s)
>  {
>  	struct swap_info_struct *p;
> @@ -1942,32 +1979,9 @@ SYSCALL_DEFINE2(swapon, const char __user *, speci=
alfile, int, swap_flags)
>  		}
>  	}
> =20
> -	if (S_ISBLK(inode->i_mode)) {
> -		p->bdev =3D bdgrab(I_BDEV(inode));
> -		error =3D blkdev_get(p->bdev,
> -				   FMODE_READ | FMODE_WRITE | FMODE_EXCL,
> -				   sys_swapon);
> -		if (error < 0) {
> -			p->bdev =3D NULL;
> -			error =3D -EINVAL;
> -			goto bad_swap;
> -		}
> -		p->old_block_size =3D block_size(p->bdev);
> -		error =3D set_blocksize(p->bdev, PAGE_SIZE);
> -		if (error < 0)
> -			goto bad_swap;
> -		p->flags |=3D SWP_BLKDEV;
> -	} else if (S_ISREG(inode->i_mode)) {
> -		p->bdev =3D inode->i_sb->s_bdev;
> -		mutex_lock(&inode->i_mutex);
> -		if (IS_SWAPFILE(inode)) {
> -			error =3D -EBUSY;
> -			goto bad_swap;
> -		}
> -	} else {
> -		error =3D -EINVAL;
> +	error =3D claim_swapfile(p, inode);
> +	if (unlikely(error))

As a personal preference, I don't use likely/unlikley unless I have a profi=
ler
telling me that the compiler got it wrong.  Just a suggestion.

>  		goto bad_swap;
> -	}
> =20
>  	swapfilepages =3D i_size_read(inode) >> PAGE_SHIFT;
> =20
> --=20
> 1.7.4
>=20

--xgyAXRrhYN0wYx8y
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNbrlDAAoJEH65iIruGRnNLkwH/iLm8zOMD8rDwJF/DCGRTisv
UiI/sJfbA6P+OJsEidIgJsDdPdCV7EKhA93h04LaefF9xcURxPXu0wHxSJ1X/L+x
OOb5U3BLLKzeauC1JX9DZiHaBUs5EC+l//Szj9TxegOmSAyutcyiD/FltaRh7VdR
ZeGISLwp/63eCXYIU1Xqd9GE6PlSiUIgWheCrLPPCL0Qe+oUBfdlT0BUsn51V2T8
OZ/9Ra27xZ2YAon0Gj4V7n800AkjQ28eR9cNoa7AeYH4n3PPzcdQZzW4L5sTbVls
agVaz0MiA7QLYmdqaMjHeASm1JkLFnp1zd50OPc2JgLsMAuRSzE+fJrMU4tarpY=
=so1B
-----END PGP SIGNATURE-----

--xgyAXRrhYN0wYx8y--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
