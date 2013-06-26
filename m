Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 6C4126B0038
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 11:01:23 -0400 (EDT)
Date: Wed, 26 Jun 2013 11:01:16 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] zcache: initialize module properly when zcache=FOO is
 given
Message-ID: <20130626150116.GA6004@phenom.dumpdata.com>
References: <1372258142-7019-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1372258142-7019-1-git-send-email-mhocko@suse.cz>
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, gregkh@linuxfoundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cristian =?iso-8859-1?Q?Rodr=EDguez?= <crrodriguez@opensuse.org>

On Wed, Jun 26, 2013 at 04:49:02PM +0200, Michal Hocko wrote:
> 835f2f51 (staging: zcache: enable zcache to be built/loaded as a module=
)
> introduced in 3.10-rc1 has introduced a bug for zcache=3DFOO module
> parameter processing.
>=20
> zcache_comp_init return code doesn't agree with crypto_has_comp which
> uses 1 for the success unlike zcache_comp_init which uses 0. This
> causes module loading failure even if the given algorithm is supported:
> [    0.815330] zcache: compressor initialization failed
>=20
> Reported-by: Cristian Rodr=EDguez <crrodriguez@opensuse.org>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Looks OK to me.

Cc-ing Greg.

> ---
>  drivers/staging/zcache/zcache-main.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zca=
che/zcache-main.c
> index dcceed2..0fe530b 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -1811,10 +1811,12 @@ static int zcache_comp_init(void)
>  #else
>  	if (*zcache_comp_name !=3D '\0') {
>  		ret =3D crypto_has_comp(zcache_comp_name, 0, 0);
> -		if (!ret)
> +		if (!ret) {
>  			pr_info("zcache: %s not supported\n",
>  					zcache_comp_name);
> -		goto out;
> +			goto out;
> +		}
> +		goto out_alloc;
>  	}
>  	if (!ret)
>  		strcpy(zcache_comp_name, "lzo");
> @@ -1827,6 +1829,7 @@ static int zcache_comp_init(void)
>  	pr_info("zcache: using %s compressor\n", zcache_comp_name);
> =20
>  	/* alloc percpu transforms */
> +out_alloc:
>  	ret =3D 0;
>  	zcache_comp_pcpu_tfms =3D alloc_percpu(struct crypto_comp *);
>  	if (!zcache_comp_pcpu_tfms)
> --=20
> 1.8.3.1
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
