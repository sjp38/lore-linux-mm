Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 6C6196B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 08:17:44 -0400 (EDT)
Date: Mon, 1 Apr 2013 08:17:36 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] staging: zcache: fix compile error
Message-ID: <20130401121736.GA11995@phenom.dumpdata.com>
References: <1364788247-30657-1-git-send-email-bob.liu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1364788247-30657-1-git-send-email-bob.liu@oracle.com>
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: gregkh@linuxfoundation.org, dan.magenheimer@oracle.com, fengguang.wu@intel.com, linux-mm@kvack.org, Bob Liu <bob.liu@oracle.com>

On Mon, Apr 01, 2013 at 11:50:47AM +0800, Bob Liu wrote:
> Because 'ramster_debugfs_init' is not defined if !CONFIG_DEBUG_FS, ther=
e is
> compile error like:
>=20
> $ make drivers/staging/zcache/
>=20
> staging/zcache/zbud.c:291:16: warning: =E2=80=98zbud_pers_evicted_pagef=
rames=E2=80=99 defined
> but not used [-Wunused-variable]
> staging/zcache/ramster/ramster.c: In function =E2=80=98ramster_init=E2=80=
=99:
> staging/zcache/ramster/ramster.c:981:2: error: implicit declaration of
> function =E2=80=98ramster_debugfs_init=E2=80=99 [-Werror=3Dimplicit-fun=
ction-declaration]
>=20
> This patch fix it and reduce some #ifdef CONFIG_DEBUG_FS in .c files wi=
th the
> same way.
>=20
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Bob Liu <bob.liu@oracle.com>
> ---
>  drivers/staging/zcache/ramster/ramster.c |    4 ++++
>  drivers/staging/zcache/zbud.c            |    6 ++++--
>  drivers/staging/zcache/zcache-main.c     |    2 --
>  3 files changed, 8 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/staging/zcache/ramster/ramster.c b/drivers/staging=
/zcache/ramster/ramster.c
> index 4f715c7..e562c14 100644
> --- a/drivers/staging/zcache/ramster/ramster.c
> +++ b/drivers/staging/zcache/ramster/ramster.c
> @@ -134,6 +134,10 @@ static int ramster_debugfs_init(void)
>  }
>  #undef	zdebugfs
>  #undef	zdfs64
> +#else
> +static int ramster_debugfs_init(void)
> +{
> +}

That is not going to work. It will complain about not returning a proper =
value.
Also you can use inline in it.
>  #endif
> =20
>  static LIST_HEAD(ramster_rem_op_list);
> diff --git a/drivers/staging/zcache/zbud.c b/drivers/staging/zcache/zbu=
d.c
> index fdff5c6..2d38c96 100644
> --- a/drivers/staging/zcache/zbud.c
> +++ b/drivers/staging/zcache/zbud.c
> @@ -342,6 +342,10 @@ static int zbud_debugfs_init(void)
>  }
>  #undef	zdfs
>  #undef	zdfs64
> +#else
> +static int zbud_debugfs_init(void)
> +{
> +}

Ditto. You need to return 0 and you can make it inline.

>  #endif
> =20
>  /* protects the buddied list and all unbuddied lists */
> @@ -1051,9 +1055,7 @@ void zbud_init(void)
>  {
>  	int i;
> =20
> -#ifdef CONFIG_DEBUG_FS
>  	zbud_debugfs_init();
> -#endif
>  	BUG_ON((sizeof(struct tmem_handle) * 2 > CHUNK_SIZE));
>  	BUG_ON(sizeof(struct zbudpage) > sizeof(struct page));
>  	for (i =3D 0; i < NCHUNKS; i++) {
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zca=
che/zcache-main.c
> index 4e52a94..ac75670 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -1753,9 +1753,7 @@ static int zcache_init(void)
>  		namestr =3D "ramster";
>  		ramster_register_pamops(&zcache_pamops);
>  	}
> -#ifdef CONFIG_DEBUG_FS
>  	zcache_debugfs_init();
> -#endif
>  	if (zcache_enabled) {
>  		unsigned int cpu;
> =20

That looks OK, and should be as a seperate patch - as there are no compil=
ation
failures with zcache-main.c

> --=20
> 1.7.10.4
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
