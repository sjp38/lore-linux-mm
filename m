Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 85C586B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 12:42:52 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <634487ea-fbbd-4eb9-9a18-9206edc4e0d2@default>
Date: Wed, 13 Mar 2013 09:42:16 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 4/4] zcache: add pageframes count once compress
 zero-filled pages twice
References: <<1363158321-20790-1-git-send-email-liwanp@linux.vnet.ibm.com>>
 <<1363158321-20790-5-git-send-email-liwanp@linux.vnet.ibm.com>>
In-Reply-To: <<1363158321-20790-5-git-send-email-liwanp@linux.vnet.ibm.com>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
> Sent: Wednesday, March 13, 2013 1:05 AM
> To: Andrew Morton
> Cc: Greg Kroah-Hartman; Dan Magenheimer; Seth Jennings; Konrad Rzeszutek =
Wilk; Minchan Kim; linux-
> mm@kvack.org; linux-kernel@vger.kernel.org; Wanpeng Li
> Subject: [PATCH 4/4] zcache: add pageframes count once compress zero-fill=
ed pages twice

Hi Wanpeng --

Thanks for taking on this task from the drivers/staging/zcache TODO list!

> Since zbudpage consist of two zpages, two zero-filled pages compression
> contribute to one [eph|pers]pageframe count accumulated.

I'm not sure why this is necessary.  The [eph|pers]pageframe count
is supposed to be counting actual pageframes used by zcache.  Since
your patch eliminates the need to store zero pages, no pageframes
are needed at all to store zero pages, so it's not necessary
to increment zcache_[eph|pers]_pageframes when storing zero
pages.

Or am I misunderstanding your intent?

Thanks,
Dan
=20
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  drivers/staging/zcache/zcache-main.c |   25 +++++++++++++++++++++++--
>  1 files changed, 23 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcach=
e/zcache-main.c
> index dd52975..7860ff0 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -544,6 +544,8 @@ static struct page *zcache_evict_eph_pageframe(void);
>  static void *zcache_pampd_eph_create(char *data, size_t size, bool raw,
>  =09=09=09=09=09struct tmem_handle *th)
>  {
> +=09static ssize_t second_eph_zero_page;
> +=09static atomic_t second_eph_zero_page_atomic =3D ATOMIC_INIT(0);
>  =09void *pampd =3D NULL, *cdata =3D data;
>  =09unsigned clen =3D size;
>  =09bool zero_filled =3D false;
> @@ -561,7 +563,14 @@ static void *zcache_pampd_eph_create(char *data, siz=
e_t size, bool raw,
>  =09=09clen =3D 0;
>  =09=09zero_filled =3D true;
>  =09=09zcache_pages_zero++;
> -=09=09goto got_pampd;
> +=09=09second_eph_zero_page =3D atomic_inc_return(
> +=09=09=09=09&second_eph_zero_page_atomic);
> +=09=09if (second_eph_zero_page % 2 =3D=3D 1)
> +=09=09=09goto got_pampd;
> +=09=09else {
> +=09=09=09atomic_sub(2, &second_eph_zero_page_atomic);
> +=09=09=09goto count_zero_page;
> +=09=09}
>  =09}
>  =09kunmap_atomic(user_mem);
>=20
> @@ -597,6 +606,7 @@ static void *zcache_pampd_eph_create(char *data, size=
_t size, bool raw,
>  create_in_new_page:
>  =09pampd =3D (void *)zbud_create_prep(th, true, cdata, clen, newpage);
>  =09BUG_ON(pampd =3D=3D NULL);
> +count_zero_page:
>  =09zcache_eph_pageframes =3D
>  =09=09atomic_inc_return(&zcache_eph_pageframes_atomic);
>  =09if (zcache_eph_pageframes > zcache_eph_pageframes_max)
> @@ -621,6 +631,8 @@ out:
>  static void *zcache_pampd_pers_create(char *data, size_t size, bool raw,
>  =09=09=09=09=09struct tmem_handle *th)
>  {
> +=09static ssize_t second_pers_zero_page;
> +=09static atomic_t second_pers_zero_page_atomic =3D ATOMIC_INIT(0);
>  =09void *pampd =3D NULL, *cdata =3D data;
>  =09unsigned clen =3D size, zero_filled =3D 0;
>  =09struct page *page =3D (struct page *)(data), *newpage;
> @@ -644,7 +656,15 @@ static void *zcache_pampd_pers_create(char *data, si=
ze_t size, bool raw,
>  =09=09clen =3D 0;
>  =09=09zero_filled =3D 1;
>  =09=09zcache_pages_zero++;
> -=09=09goto got_pampd;
> +=09=09second_pers_zero_page =3D atomic_inc_return(
> +=09=09=09=09&second_pers_zero_page_atomic);
> +=09=09if (second_pers_zero_page % 2 =3D=3D 1)
> +=09=09=09goto got_pampd;
> +=09=09else {
> +=09=09=09atomic_sub(2, &second_pers_zero_page_atomic);
> +=09=09=09goto count_zero_page;
> +=09=09}
> +
>  =09}
>  =09kunmap_atomic(user_mem);
>=20
> @@ -698,6 +718,7 @@ create_pampd:
>  create_in_new_page:
>  =09pampd =3D (void *)zbud_create_prep(th, false, cdata, clen, newpage);
>  =09BUG_ON(pampd =3D=3D NULL);
> +count_zero_page:
>  =09zcache_pers_pageframes =3D
>  =09=09atomic_inc_return(&zcache_pers_pageframes_atomic);
>  =09if (zcache_pers_pageframes > zcache_pers_pageframes_max)
> --
> 1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
