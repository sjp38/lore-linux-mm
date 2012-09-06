Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id C23A36B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 13:16:42 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <8d085295-c15d-441c-8463-58cfc7ffc139@default>
Date: Thu, 6 Sep 2012 10:15:48 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [patch] staging: ramster: fix range checks in
 zcache_autocreate_pool()
References: <20120906124020.GA28946@elgon.mountain>
In-Reply-To: <20120906124020.GA28946@elgon.mountain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, devel@driverdev.osuosl.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

> From: Dan Carpenter
> Sent: Thursday, September 06, 2012 6:40 AM
> To: Greg Kroah-Hartman
> Cc: Dan Magenheimer; Konrad Rzeszutek Wilk; devel@driverdev.osuosl.org; l=
inux-mm@kvack.org; kernel-
> janitors@vger.kernel.org
> Subject: [patch] staging: ramster: fix range checks in zcache_autocreate_=
pool()
>=20
> If "pool_id" is negative then it leads to a read before the start of the
> array.  If "cli_id" is out of bounds then it leads to a NULL dereference
> of "cli".  GCC would have warned about that bug except that we
> initialized the warning message away.
>=20
> Also it's better to put the parameter names into the function
> declaration in the .h file.  It serves as a kind of documentation.
>=20
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Self-flagellated-by: Dan Magenheimer <dan.magenheimer@oracle.com>=20

> ---
> BTW, This file has a ton of GCC warnings.  This function returns -1
> on error which is a nonsense return code but the return value is not
> checked anyway.  *Grumble*.
>=20
> diff --git a/drivers/staging/ramster/zcache.h b/drivers/staging/ramster/z=
cache.h
> index c59666e..81722b3 100644
> --- a/drivers/staging/ramster/zcache.h
> +++ b/drivers/staging/ramster/zcache.h
> @@ -42,7 +42,7 @@ extern void zcache_decompress_to_page(char *, unsigned =
int, struct page *);
>  #ifdef CONFIG_RAMSTER
>  extern void *zcache_pampd_create(char *, unsigned int, bool, int,
>  =09=09=09=09struct tmem_handle *);
> -extern int zcache_autocreate_pool(int, int, bool);
> +int zcache_autocreate_pool(unsigned int cli_id, unsigned int pool_id, bo=
ol eph);
>  #endif
>=20
>  #define MAX_POOLS_PER_CLIENT 16
> diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/rams=
ter/zcache-main.c
> index 24b3d4a..86e19d6 100644
> --- a/drivers/staging/ramster/zcache-main.c
> +++ b/drivers/staging/ramster/zcache-main.c
> @@ -1338,10 +1338,10 @@ static int zcache_local_new_pool(uint32_t flags)
>  =09return zcache_new_pool(LOCAL_CLIENT, flags);
>  }
>=20
> -int zcache_autocreate_pool(int cli_id, int pool_id, bool eph)
> +int zcache_autocreate_pool(unsigned int cli_id, unsigned int pool_id, bo=
ol eph)
>  {
>  =09struct tmem_pool *pool;
> -=09struct zcache_client *cli =3D NULL;
> +=09struct zcache_client *cli;
>  =09uint32_t flags =3D eph ? 0 : TMEM_POOL_PERSIST;
>  =09int ret =3D -1;
>=20
> @@ -1350,8 +1350,10 @@ int zcache_autocreate_pool(int cli_id, int pool_id=
, bool eph)
>  =09=09goto out;
>  =09if (pool_id >=3D MAX_POOLS_PER_CLIENT)
>  =09=09goto out;
> -=09else if ((unsigned int)cli_id < MAX_CLIENTS)
> -=09=09cli =3D &zcache_clients[cli_id];
> +=09if (cli_id >=3D MAX_CLIENTS)
> +=09=09goto out;
> +
> +=09cli =3D &zcache_clients[cli_id];
>  =09if ((eph && disable_cleancache) || (!eph && disable_frontswap)) {
>  =09=09pr_err("zcache_autocreate_pool: pool type disabled\n");
>  =09=09goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
