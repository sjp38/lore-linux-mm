Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C3CF46B0010
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 10:16:37 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <8cb0f464-7e39-4294-9f98-c4c5a66110ba@default>
Date: Thu, 15 Sep 2011 07:16:10 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] staging: zcache: fix cleancache crash
References: <4E6FA75A.8060308@linux.vnet.ibm.com
 1315941562-25422-1-git-send-email-sjenning@linux.vnet.ibm.com
 a7d17e7e-c6a1-448e-b60f-b79a4ae0c3ba@default>
In-Reply-To: <a7d17e7e-c6a1-448e-b60f-b79a4ae0c3ba@default>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@suse.de
Cc: devel@driverdev.osuosl.org, linux-mm@kvack.org, ngupta@vflare.org, linux-kernel@vger.kernel.org, francis.moro@gmail.com, Seth Jennings <sjenning@linux.vnet.ibm.com>

> From: Dan Magenheimer
> Sent: Tuesday, September 13, 2011 2:56 PM
> To: Seth Jennings; gregkh@suse.de
> Cc: devel@driverdev.osuosl.org; linux-mm@kvack.org; ngupta@vflare.org; li=
nux-kernel@vger.kernel.org;
> francis.moro@gmail.com
> Subject: RE: [PATCH] staging: zcache: fix cleancache crash
>=20
> > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > Sent: Tuesday, September 13, 2011 1:19 PM
> > To: gregkh@suse.de
> > Cc: devel@driverdev.osuosl.org; linux-mm@kvack.org; ngupta@vflare.org; =
linux-kernel@vger.kernel.org;
> > francis.moro@gmail.com; Dan Magenheimer; Seth Jennings
> > Subject: [PATCH] staging: zcache: fix cleancache crash
> >
> > After commit, c5f5c4db, cleancache crashes on the first
> > successful get. This was caused by a remaining virt_to_page()
> > call in zcache_pampd_get_data_and_free() that only gets
> > run in the cleancache path.
> >
> > The patch converts the virt_to_page() to struct page
> > casting like was done for other instances in c5f5c4db.
> >
> > Based on 3.1-rc4
> >
> > Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>=20
> Yep, this appears to fix it!  Hopefully Francis can confirm.
>=20
> Greg, ideally apply this additional fix rather than do the revert
> of the original patch suggested in https://lkml.org/lkml/2011/9/13/234
>=20
> Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>


Greg, Francis has confirmed offlist that Seth's fix below
has fixed his issue as well.  Please apply, hopefully as
soon as possible and before 3.1 goes final!

Thanks,
Dan

=20
> > ---
> >  drivers/staging/zcache/zcache-main.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >
> > diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zca=
che/zcache-main.c
> > index a3f5162..462fbc2 100644
> > --- a/drivers/staging/zcache/zcache-main.c
> > +++ b/drivers/staging/zcache/zcache-main.c
> > @@ -1242,7 +1242,7 @@ static int zcache_pampd_get_data_and_free(char *d=
ata, size_t *bufsize, bool
> raw,
> >  =09int ret =3D 0;
> >
> >  =09BUG_ON(!is_ephemeral(pool));
> > -=09zbud_decompress(virt_to_page(data), pampd);
> > +=09zbud_decompress((struct page *)(data), pampd);
> >  =09zbud_free_and_delist((struct zbud_hdr *)pampd);
> >  =09atomic_dec(&zcache_curr_eph_pampd_count);
> >  =09return ret;
> > --
> > 1.7.4.1
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
