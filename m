Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 2CBFF6B0078
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 13:40:55 -0400 (EDT)
Received: by weys10 with SMTP id s10so3761452wey.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2012 10:40:53 -0700 (PDT)
From: Michal Nazarewicz <mina86@tlen.pl>
Subject: Re: [PATCH 2/3] mm: fix possible incorrect return value of migrate_pages() syscall
References: <1342455272-32703-1-git-send-email-js1304@gmail.com>
	<1342455272-32703-2-git-send-email-js1304@gmail.com>
Date: Mon, 16 Jul 2012 19:40:38 +0200
In-Reply-To: <1342455272-32703-2-git-send-email-js1304@gmail.com> (Joonsoo
	Kim's message of "Tue, 17 Jul 2012 01:14:31 +0900")
Message-ID: <87394rr4dl.fsf@erwin.mina86.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <levinsasha928@gmail.com>, Christoph Lameter <cl@linux.com>

--=-=-=
Content-Transfer-Encoding: quoted-printable

Joonsoo Kim <js1304@gmail.com> writes:
> do_migrate_pages() can return the number of pages not migrated.
> Because migrate_pages() syscall return this value directly,
> migrate_pages() syscall may return the number of pages not migrated.
> In fail case in migrate_pages() syscall, we should return error value.
> So change err to -EIO
>
> Additionally, Correct comment above do_migrate_pages()
>
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> Cc: Sasha Levin <levinsasha928@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 1d771e4..f7df271 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -948,7 +948,7 @@ static int migrate_to_node(struct mm_struct *mm, int =
source, int dest,
>   * Move pages between the two nodesets so as to preserve the physical
>   * layout as much as possible.
>   *
> - * Returns the number of page that could not be moved.
> + * Returns error or the number of pages not migrated.
>   */
>  int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
>  		     const nodemask_t *to, int flags)
> @@ -1382,6 +1382,8 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned=
 long, maxnode,
>=20=20
>  	err =3D do_migrate_pages(mm, old, new,
>  		capable(CAP_SYS_NICE) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
> +	if (err > 0)
> +		err =3D -EIO;
>=20=20
>  	mmput(mm);
>  out:

=2D-=20
Best regards,                                          _     _
 .o. | Liege of Serenly Enlightened Majesty of       o' \,=3D./ `o
 ..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
 ooo +-<mina86-mina86.com>-<jid:mina86-jabber.org>--ooO--(_)--Ooo--

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJQBFIWAAoJECBgQBJQdR/0VmoP/29TAo7BZJZ7bQeRHUiNscCn
iKRmMbiRaBmdJegPizzDmZytkzZaskM2raSycDHenuHBXcT9xfKN9atI/KrA1+h0
/wnu1ZwsLq7nCnBvVvBFqGepe98SISrhn2xb7o8/yvM+lB2XgqrDMam4BxBUNxs/
W9yhJ5HeBobEp9noO0r6y9eZhvjT7Sg4wSMgaP3bV2SeWHJT74oiOYxqxTupcpb6
aKptUCGyLFgq8o5XMG2Cm9X/sVJTDTqYd4w5d3RLqPQr8r/GumWiVc+2gRG044XJ
buECAEoiqoZNvnzaopfmTzh4yZy62faMTNo4GtQwhx+8zch98+rh9vfUzaNWrI/n
XPAFp7VLzoktomfKBvQKvLmEbORBIPcrwpz+Na+gTIdXpcW9Vkm3Yn6tX53HkWSd
tj8EsxyVPelwAn+NmPKCBdTqLe6DFsIyFTTfFdf+H5erMjiXLuhYpplJBouayGpc
J2SedhR5OvN3Fcn5gZl1Nl1ceHdACZtjK55xMwu55xlnjtEHYjFF8sI97nUPSeC1
HZ4akknU9Tgvz5Wt+riz9YJzsiHNCcsUTTFpBa76EeFVlKE0w4MF4gOYvXzoq3eN
gDKKbCBQFV3r2BLhZPck2V0QYJV33R8hUvsLDfIZTNDdlKkFSWNnRcHP+5XuPiqz
Ib1WgnmuUJsNEk5BJHRt
=GeRr
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
