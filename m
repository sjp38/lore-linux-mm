Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 024006B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:14:02 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <ecb7519b-669a-48e4-b217-a77ecb60afd4@default>
Date: Thu, 11 Apr 2013 10:13:42 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 02/10] staging: zcache: remove zcache_freeze
References: <<1365553560-32258-1-git-send-email-liwanp@linux.vnet.ibm.com>>
 <<1365553560-32258-3-git-send-email-liwanp@linux.vnet.ibm.com>>
In-Reply-To: <<1365553560-32258-3-git-send-email-liwanp@linux.vnet.ibm.com>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>

> From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
> Subject: [PATCH 02/10] staging: zcache: remove zcache_freeze
>=20
> The default value of zcache_freeze is false and it won't be modified by
> other codes. Remove zcache_freeze since no routine can disable zcache
> during system running.
>=20
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

I'd prefer to leave this code in place as it may be very useful
if/when zcache becomes more tightly integrated into the MM subsystem
and the rest of the kernel.  And the subtleties for temporarily disabling
zcache (which is what zcache_freeze does) are non-obvious and
may cause data loss so if someone wants to add this functionality
back in later and don't have this piece of code, it may take
a lot of pain to get it working.

Usage example: All CPUs are fully saturated so it is questionable
whether spending CPU cycles for compression is wise.  Kernel
could disable zcache using zcache_freeze.  (Yes, a new entry point
would need to be added to enable/disable zcache_freeze.)

My two cents... others are welcome to override.

> ---
>  drivers/staging/zcache/zcache-main.c |   55 +++++++++++-----------------=
------
>  1 file changed, 18 insertions(+), 37 deletions(-)
>=20
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcach=
e/zcache-main.c
> index e23d814..fe6801a 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -1118,15 +1118,6 @@ free_and_out:
>  #endif /* CONFIG_ZCACHE_WRITEBACK */
>=20
>  /*
> - * When zcache is disabled ("frozen"), pools can be created and destroye=
d,
> - * but all puts (and thus all other operations that require memory alloc=
ation)
> - * must fail.  If zcache is unfrozen, accepts puts, then frozen again,
> - * data consistency requires all puts while frozen to be converted into
> - * flushes.
> - */
> -static bool zcache_freeze;
> -
> -/*
>   * This zcache shrinker interface reduces the number of ephemeral pagefr=
ames
>   * used by zcache to approximately the same as the total number of LRU_F=
ILE
>   * pageframes in use, and now also reduces the number of persistent page=
frames
> @@ -1221,44 +1212,34 @@ int zcache_put_page(int cli_id, int pool_id, stru=
ct tmem_oid *oidp,
>  {
>  =09struct tmem_pool *pool;
>  =09struct tmem_handle th;
> -=09int ret =3D -1;
> +=09int ret =3D 0;
>  =09void *pampd =3D NULL;
>=20
>  =09BUG_ON(!irqs_disabled());
>  =09pool =3D zcache_get_pool_by_id(cli_id, pool_id);
>  =09if (unlikely(pool =3D=3D NULL))
>  =09=09goto out;
> -=09if (!zcache_freeze) {
> -=09=09ret =3D 0;
> -=09=09th.client_id =3D cli_id;
> -=09=09th.pool_id =3D pool_id;
> -=09=09th.oid =3D *oidp;
> -=09=09th.index =3D index;
> -=09=09pampd =3D zcache_pampd_create((char *)page, size, raw,
> -=09=09=09=09ephemeral, &th);
> -=09=09if (pampd =3D=3D NULL) {
> -=09=09=09ret =3D -ENOMEM;
> -=09=09=09if (ephemeral)
> -=09=09=09=09inc_zcache_failed_eph_puts();
> -=09=09=09else
> -=09=09=09=09inc_zcache_failed_pers_puts();
> -=09=09} else {
> -=09=09=09if (ramster_enabled)
> -=09=09=09=09ramster_do_preload_flnode(pool);
> -=09=09=09ret =3D tmem_put(pool, oidp, index, 0, pampd);
> -=09=09=09if (ret < 0)
> -=09=09=09=09BUG();
> -=09=09}
> -=09=09zcache_put_pool(pool);
> +
> +=09th.client_id =3D cli_id;
> +=09th.pool_id =3D pool_id;
> +=09th.oid =3D *oidp;
> +=09th.index =3D index;
> +=09pampd =3D zcache_pampd_create((char *)page, size, raw,
> +=09=09=09ephemeral, &th);
> +=09if (pampd =3D=3D NULL) {
> +=09=09ret =3D -ENOMEM;
> +=09=09if (ephemeral)
> +=09=09=09inc_zcache_failed_eph_puts();
> +=09=09else
> +=09=09=09inc_zcache_failed_pers_puts();
>  =09} else {
> -=09=09inc_zcache_put_to_flush();
>  =09=09if (ramster_enabled)
>  =09=09=09ramster_do_preload_flnode(pool);
> -=09=09if (atomic_read(&pool->obj_count) > 0)
> -=09=09=09/* the put fails whether the flush succeeds or not */
> -=09=09=09(void)tmem_flush_page(pool, oidp, index);
> -=09=09zcache_put_pool(pool);
> +=09=09ret =3D tmem_put(pool, oidp, index, 0, pampd);
> +=09=09if (ret < 0)
> +=09=09=09BUG();
>  =09}
> +=09zcache_put_pool(pool);
>  out:
>  =09return ret;
>  }
> --
> 1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
