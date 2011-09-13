Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C416C900136
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 16:56:23 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <a7d17e7e-c6a1-448e-b60f-b79a4ae0c3ba@default>
Date: Tue, 13 Sep 2011 13:56:00 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] staging: zcache: fix cleancache crash
References: <4E6FA75A.8060308@linux.vnet.ibm.com
 1315941562-25422-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1315941562-25422-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, gregkh@suse.de
Cc: devel@driverdev.osuosl.org, linux-mm@kvack.org, ngupta@vflare.org, linux-kernel@vger.kernel.org, francis.moro@gmail.com

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Sent: Tuesday, September 13, 2011 1:19 PM
> To: gregkh@suse.de
> Cc: devel@driverdev.osuosl.org; linux-mm@kvack.org; ngupta@vflare.org; li=
nux-kernel@vger.kernel.org;
> francis.moro@gmail.com; Dan Magenheimer; Seth Jennings
> Subject: [PATCH] staging: zcache: fix cleancache crash
>=20
> After commit, c5f5c4db, cleancache crashes on the first
> successful get. This was caused by a remaining virt_to_page()
> call in zcache_pampd_get_data_and_free() that only gets
> run in the cleancache path.
>=20
> The patch converts the virt_to_page() to struct page
> casting like was done for other instances in c5f5c4db.
>=20
> Based on 3.1-rc4
>=20
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

Yep, this appears to fix it!  Hopefully Francis can confirm.

Greg, ideally apply this additional fix rather than do the revert
of the original patch suggested in https://lkml.org/lkml/2011/9/13/234=20

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>

> ---
>  drivers/staging/zcache/zcache-main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcach=
e/zcache-main.c
> index a3f5162..462fbc2 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -1242,7 +1242,7 @@ static int zcache_pampd_get_data_and_free(char *dat=
a, size_t *bufsize, bool raw,
>  =09int ret =3D 0;
>=20
>  =09BUG_ON(!is_ephemeral(pool));
> -=09zbud_decompress(virt_to_page(data), pampd);
> +=09zbud_decompress((struct page *)(data), pampd);
>  =09zbud_free_and_delist((struct zbud_hdr *)pampd);
>  =09atomic_dec(&zcache_curr_eph_pampd_count);
>  =09return ret;
> --
> 1.7.4.1
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
