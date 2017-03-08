Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1436B03D9
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 16:24:00 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id h188so15431795wma.4
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 13:24:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o104si5899424wrc.239.2017.03.08.13.23.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 13:23:58 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Thu, 09 Mar 2017 08:23:43 +1100
Subject: Re: [PATCH v2 3/9] mm: clear any AS_* errors when returning error on any fsync or close
In-Reply-To: <20170308162934.21989-4-jlayton@redhat.com>
References: <20170308162934.21989-1-jlayton@redhat.com> <20170308162934.21989-4-jlayton@redhat.com>
Message-ID: <8760jjv4ww.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk, akpm@linux-foundation.org
Cc: konishi.ryusuke@lab.ntt.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org, ross.zwisler@linux.intel.com, jack@suse.cz, openosd@gmail.com, adilger@dilger.ca, James.Bottomley@HansenPartnership.com

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 09 2017, Jeff Layton wrote:

> Currently we don't clear the address space error when there is a -EIO
> error on fsynci, due to writeback initiation failure. If writes fail
> with -EIO and the mapping is flagged with an AS_EIO or AS_ENOSPC error,
> then we can end up returning errors on two fsync calls, even when a
> write between them succeeded (or there was no write).
>
> Ensure that we also clear out any mapping errors when initiating
> writeback fails with -EIO in filemap_write_and_wait and
> filemap_write_and_wait_range.

This change appears to assume that filemap_write_and_wait* is only
called from fsync() (or similar) and the return status is always
checked.

A __must_check annotation might be helpful.

It would catch v9_fs_file_lock(), afs_setattr() and others.

While I think your change is probably heading in the right direction,
there seem to be some loose ends still.

Thanks,
NeilBrown


>
> Suggested-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  mm/filemap.c | 20 ++++++++++++++++++--
>  1 file changed, 18 insertions(+), 2 deletions(-)
>
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 1694623a6289..fc123b9833e1 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -488,7 +488,7 @@ EXPORT_SYMBOL(filemap_fdatawait);
>=20=20
>  int filemap_write_and_wait(struct address_space *mapping)
>  {
> -	int err =3D 0;
> +	int err;
>=20=20
>  	if ((!dax_mapping(mapping) && mapping->nrpages) ||
>  	    (dax_mapping(mapping) && mapping->nrexceptional)) {
> @@ -499,10 +499,18 @@ int filemap_write_and_wait(struct address_space *ma=
pping)
>  		 * But the -EIO is special case, it may indicate the worst
>  		 * thing (e.g. bug) happened, so we avoid waiting for it.
>  		 */
> -		if (err !=3D -EIO) {
> +		if (likely(err !=3D -EIO)) {
>  			int err2 =3D filemap_fdatawait(mapping);
>  			if (!err)
>  				err =3D err2;
> +		} else {
> +			/*
> +			 * Clear the error in the address space since we're
> +			 * returning an error here. -EIO takes precedence over
> +			 * everything else though, so we can just discard
> +			 * the return here.
> +			 */
> +			filemap_check_errors(mapping);
>  		}
>  	} else {
>  		err =3D filemap_check_errors(mapping);
> @@ -537,6 +545,14 @@ int filemap_write_and_wait_range(struct address_spac=
e *mapping,
>  						lstart, lend);
>  			if (!err)
>  				err =3D err2;
> +		} else {
> +			/*
> +			 * Clear the error in the address space since we're
> +			 * returning an error here. -EIO takes precedence over
> +			 * everything else though, so we can just discard
> +			 * the return here.
> +			 */
> +			filemap_check_errors(mapping);
>  		}
>  	} else {
>  		err =3D filemap_check_errors(mapping);
> --=20
> 2.9.3

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljAdl8ACgkQOeye3VZi
gbl3eA/+MHlvrAE/RoCtylFQeUKXcIJwyWqCGL5/a9GFsx4b7ThrjUDLSSn4O3Gz
sqtpmMfUiFp+1f0P+R/khbRx52i29fPQ2oQEhcCtz/2RwDMsWqD1GzT6gZRt+zSs
ez8CnRf4xPsI7HlY64nEj9XspXkGsqx88hamQuuB+jfiNUVPIxn9Oh18JZf6A1UD
Seb38eTEt9DAZUQKaDdT36lsIEEqNNW/CdGwJoVQg75R4lubYngFi/PgJy4eQULp
OSwB1i8aIFTEU0qMjkJH2uD60KA8jwhKZWWW8SKUsgehzfjKT928ScHmKnE3KU44
zg0klEdPQe/L5DAMnzTkH4p7cT7cFo2bx6a8jVjgAPsOgYfmLe1GpFcRUjW/CbZw
MPmE0OYFjLb07DbKqRrwP7z6raS6IN2/Gp3jQe/ijfG0/BqqSvaZcgG3zGkqkrp6
sVAo1VvQv5fVpefXJ6VFFLN1yK/V6nOHuBA+Gi5YEgNBgV4DVEmGLTrT/Mwouoxn
zgjhJsCnsy9rE8bAB6G8w2dFD+p3rHuH41rr+NygHEcFgnPK6O0WGFp97I9E4mN+
JiD7Eh0GODBhvjDraTDKuwSBiSIj0/FtzbQyQYetGZm8guig4AB69s/1iNj+Tf14
oT/26tlpK5GDYoYwMVW/7Hvq40FTFjpiADVkqWDHHoarP2I+szY=
=5okT
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
