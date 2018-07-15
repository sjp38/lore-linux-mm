Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5CFC46B0010
	for <linux-mm@kvack.org>; Sun, 15 Jul 2018 00:22:07 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p5-v6so5625191edh.16
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 21:22:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c25-v6sor639732eds.7.2018.07.14.21.22.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Jul 2018 21:22:05 -0700 (PDT)
MIME-Version: 1.0
References: <20180701065616.3512-1-wdignazio@gmail.com>
In-Reply-To: <20180701065616.3512-1-wdignazio@gmail.com>
From: Will Dignazio <wdignazio@gmail.com>
Date: Sat, 14 Jul 2018 21:21:47 -0700
Message-ID: <CAH9O0xF8bL+DdQyPV8LeorxjVESB6ehXxAJBmm39veQ0aqmbCQ@mail.gmail.com>
Subject: Re: [PATCH] Add option to configure default zswap compressor algorithm.
Content-Type: multipart/alternative; boundary="0000000000002c41c60571020e42"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@redhat.com
Cc: ddstreet@ieee.org, linux-mm@kvack.org

--0000000000002c41c60571020e42
Content-Type: text/plain; charset="UTF-8"

Apologies for bumping. I also should give a better description:

This patch introduces a configuration option for the default cryptographic
compression algorithm used by zswap. Previous to this patch, one would use
the default compression algorithm until changed from userspace. This patch
allows a compilation time change, which will remain the default from boot
until changed.

On Sat, Jun 30, 2018 at 11:56 PM Will Ziener-Dignazio <wdignazio@gmail.com>
wrote:

>     - Add Kconfig option for default compressor algorithm
>     - Add the deflate and LZ4 algorithms as default options
>
> Signed-off-by: Will Ziener-Dignazio <wdignazio@gmail.com>
> ---
>  mm/Kconfig | 35 ++++++++++++++++++++++++++++++++++-
>  mm/zswap.c | 11 ++++++++++-
>  2 files changed, 44 insertions(+), 2 deletions(-)
>
> diff --git a/mm/Kconfig b/mm/Kconfig
> index ce95491abd6a..09df6650e96a 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -535,7 +535,6 @@ config MEM_SOFT_DIRTY
>  config ZSWAP
>         bool "Compressed cache for swap pages (EXPERIMENTAL)"
>         depends on FRONTSWAP && CRYPTO=y
> -       select CRYPTO_LZO
>         select ZPOOL
>         default n
>         help
> @@ -552,6 +551,40 @@ config ZSWAP
>           they have not be fully explored on the large set of potential
>           configurations and workloads that exist.
>
> +choice
> +       prompt "Compressed cache cryptographic compression algorithm"
> +       default ZSWAP_COMPRESSOR_DEFAULT_LZO
> +       depends on ZSWAP
> +       help
> +         The default cyptrographic compression algorithm to use for
> +         compressed swap pages.
> +
> +config ZSWAP_COMPRESSOR_DEFAULT_LZO
> +       bool "lzo"
> +       select CRYPTO_LZO
> +       help
> +         This option sets the default zswap compression algorithm to LZO,
> +         the Lempel-Ziv-Oberhumer algorithm. This algorthm focuses on
> +         decompression speed, but has a lower compression ratio.
> +
> +config ZSWAP_COMPRESSOR_DEFAULT_DEFLATE
> +       bool "deflate"
> +       select CRYPTO_DEFLATE
> +       help
> +         This option sets the default zswap compression algorithm to
> DEFLATE.
> +         This algorithm balances compression and decompression speed to
> +         compresstion ratio.
> +
> +config ZSWAP_COMPRESSOR_DEFAULT_LZ4
> +       bool "lz4"
> +       select CRYPTO_LZ4
> +       help
> +         This option sets the default zswap compression algorithm to LZ4.
> +         This algorithm focuses on high compression speed, but has a lower
> +         compression ratio and decompression speed.
> +
> +endchoice
> +
>  config ZPOOL
>         tristate "Common API for compressed memory storage"
>         default n
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 7d34e69507e3..30f9f25da4d0 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -91,7 +91,16 @@ static struct kernel_param_ops zswap_enabled_param_ops
> = {
>  module_param_cb(enabled, &zswap_enabled_param_ops, &zswap_enabled, 0644);
>
>  /* Crypto compressor to use */
> -#define ZSWAP_COMPRESSOR_DEFAULT "lzo"
> +#if defined(CONFIG_ZSWAP_COMPRESSOR_DEFAULT_LZO)
> +  #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
> +#elif defined(CONFIG_ZSWAP_COMPRESSOR_DEFAULT_DEFLATE)
> +  #define ZSWAP_COMPRESSOR_DEFAULT "deflate"
> +#elif defined(CONFIG_ZSWAP_COMPRESSOR_DEFAULT_LZ4)
> +  #define ZSWAP_COMPRESSOR_DEFAULT "lz4"
> +#else
> +  #error "Default zswap compression algorithm not defined."
> +#endif
> +
>  static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
>  static int zswap_compressor_param_set(const char *,
>                                       const struct kernel_param *);
> --
> 2.18.0
>
> --
Bytes Go In, Words Go Out

--0000000000002c41c60571020e42
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Apologies for bumping. I also should give a better de=
scription:</div><div><br></div><div>This patch introduces a configuration o=
ption for the default cryptographic compression algorithm used by zswap. Pr=
evious to this patch, one would use the default compression algorithm until=
 changed from userspace. This patch allows a compilation time change, which=
 will remain the default from boot until changed.</div></div><br><div class=
=3D"gmail_quote"><div dir=3D"ltr">On Sat, Jun 30, 2018 at 11:56 PM Will Zie=
ner-Dignazio &lt;<a href=3D"mailto:wdignazio@gmail.com">wdignazio@gmail.com=
</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:=
0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">=C2=A0 =C2=A0 - Add=
 Kconfig option for default compressor algorithm<br>
=C2=A0 =C2=A0 - Add the deflate and LZ4 algorithms as default options<br>
<br>
Signed-off-by: Will Ziener-Dignazio &lt;<a href=3D"mailto:wdignazio@gmail.c=
om" target=3D"_blank">wdignazio@gmail.com</a>&gt;<br>
---<br>
=C2=A0mm/Kconfig | 35 ++++++++++++++++++++++++++++++++++-<br>
=C2=A0mm/zswap.c | 11 ++++++++++-<br>
=C2=A02 files changed, 44 insertions(+), 2 deletions(-)<br>
<br>
diff --git a/mm/Kconfig b/mm/Kconfig<br>
index ce95491abd6a..09df6650e96a 100644<br>
--- a/mm/Kconfig<br>
+++ b/mm/Kconfig<br>
@@ -535,7 +535,6 @@ config MEM_SOFT_DIRTY<br>
=C2=A0config ZSWAP<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 bool &quot;Compressed cache for swap pages (EXP=
ERIMENTAL)&quot;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 depends on FRONTSWAP &amp;&amp; CRYPTO=3Dy<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0select CRYPTO_LZO<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 select ZPOOL<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 default n<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 help<br>
@@ -552,6 +551,40 @@ config ZSWAP<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 they have not be fully explored on the l=
arge set of potential<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 configurations and workloads that exist.=
<br>
<br>
+choice<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0prompt &quot;Compressed cache cryptographic com=
pression algorithm&quot;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0default ZSWAP_COMPRESSOR_DEFAULT_LZO<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0depends on ZSWAP<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0help<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0The default cyptrographic compression al=
gorithm to use for<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0compressed swap pages.<br>
+<br>
+config ZSWAP_COMPRESSOR_DEFAULT_LZO<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0bool &quot;lzo&quot;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0select CRYPTO_LZO<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0help<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0This option sets the default zswap compr=
ession algorithm to LZO,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0the Lempel-Ziv-Oberhumer algorithm. This=
 algorthm focuses on<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0decompression speed, but has a lower com=
pression ratio.<br>
+<br>
+config ZSWAP_COMPRESSOR_DEFAULT_DEFLATE<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0bool &quot;deflate&quot;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0select CRYPTO_DEFLATE<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0help<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0This option sets the default zswap compr=
ession algorithm to DEFLATE.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0This algorithm balances compression and =
decompression speed to<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0compresstion ratio.<br>
+<br>
+config ZSWAP_COMPRESSOR_DEFAULT_LZ4<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0bool &quot;lz4&quot;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0select CRYPTO_LZ4<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0help<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0This option sets the default zswap compr=
ession algorithm to LZ4.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0This algorithm focuses on high compressi=
on speed, but has a lower<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0compression ratio and decompression spee=
d.<br>
+<br>
+endchoice<br>
+<br>
=C2=A0config ZPOOL<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 tristate &quot;Common API for compressed memory=
 storage&quot;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 default n<br>
diff --git a/mm/zswap.c b/mm/zswap.c<br>
index 7d34e69507e3..30f9f25da4d0 100644<br>
--- a/mm/zswap.c<br>
+++ b/mm/zswap.c<br>
@@ -91,7 +91,16 @@ static struct kernel_param_ops zswap_enabled_param_ops =
=3D {<br>
=C2=A0module_param_cb(enabled, &amp;zswap_enabled_param_ops, &amp;zswap_ena=
bled, 0644);<br>
<br>
=C2=A0/* Crypto compressor to use */<br>
-#define ZSWAP_COMPRESSOR_DEFAULT &quot;lzo&quot;<br>
+#if defined(CONFIG_ZSWAP_COMPRESSOR_DEFAULT_LZO)<br>
+=C2=A0 #define ZSWAP_COMPRESSOR_DEFAULT &quot;lzo&quot;<br>
+#elif defined(CONFIG_ZSWAP_COMPRESSOR_DEFAULT_DEFLATE)<br>
+=C2=A0 #define ZSWAP_COMPRESSOR_DEFAULT &quot;deflate&quot;<br>
+#elif defined(CONFIG_ZSWAP_COMPRESSOR_DEFAULT_LZ4)<br>
+=C2=A0 #define ZSWAP_COMPRESSOR_DEFAULT &quot;lz4&quot;<br>
+#else<br>
+=C2=A0 #error &quot;Default zswap compression algorithm not defined.&quot;=
<br>
+#endif<br>
+<br>
=C2=A0static char *zswap_compressor =3D ZSWAP_COMPRESSOR_DEFAULT;<br>
=C2=A0static int zswap_compressor_param_set(const char *,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct ke=
rnel_param *);<br>
-- <br>
2.18.0<br>
<br>
</blockquote></div>-- <br><div dir=3D"ltr" class=3D"gmail_signature" data-s=
martmail=3D"gmail_signature"><div dir=3D"ltr">Bytes Go In, Words Go Out</di=
v></div>

--0000000000002c41c60571020e42--
