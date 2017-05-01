Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC63A6B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 11:37:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c16so72219012pfl.21
        for <linux-mm@kvack.org>; Mon, 01 May 2017 08:37:56 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id t18si396992pgn.128.2017.05.01.08.37.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 08:37:55 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id v14so28176724pfd.3
        for <linux-mm@kvack.org>; Mon, 01 May 2017 08:37:55 -0700 (PDT)
Date: Mon, 1 May 2017 23:37:52 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 3/3] mm/slub: wrap kmem_cache->cpu_partial in config
 CONFIG_SLUB_CPU_PARTIAL
Message-ID: <20170501153752.GA1653@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170430113152.6590-1-richard.weiyang@gmail.com>
 <20170430113152.6590-4-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="qMm9M+Fa2AknHoGS"
Content-Disposition: inline
In-Reply-To: <20170430113152.6590-4-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>


--qMm9M+Fa2AknHoGS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Apr 30, 2017 at 07:31:52PM +0800, Wei Yang wrote:
>kmem_cache->cpu_partial is just used when CONFIG_SLUB_CPU_PARTIAL is set,
>so wrap it with config CONFIG_SLUB_CPU_PARTIAL will save some space
>on 32bit arch.
>
>This patch wrap kmem_cache->cpu_partial in config CONFIG_SLUB_CPU_PARTIAL
>and wrap its sysfs too.
>
>Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>---
> include/linux/slub_def.h |  2 ++
> mm/slub.c                | 72 +++++++++++++++++++++++++++++--------------=
-----
> 2 files changed, 46 insertions(+), 28 deletions(-)
>
>diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
>index 0debd8df1a7d..477ab99800ed 100644
>--- a/include/linux/slub_def.h
>+++ b/include/linux/slub_def.h
>@@ -69,7 +69,9 @@ struct kmem_cache {
> 	int size;		/* The size of an object including meta data */
> 	int object_size;	/* The size of an object without meta data */
> 	int offset;		/* Free pointer offset. */
>+#ifdef CONFIG_SLUB_CPU_PARTIAL
> 	int cpu_partial;	/* Number of per cpu partial objects to keep around */
>+#endif
> 	struct kmem_cache_order_objects oo;
>=20
> 	/* Allocation and freeing of slabs */
>diff --git a/mm/slub.c b/mm/slub.c
>index fde499b6dad8..94978f27882a 100644
>--- a/mm/slub.c
>+++ b/mm/slub.c
>@@ -1829,7 +1829,10 @@ static void *get_partial_node(struct kmem_cache *s,=
 struct kmem_cache_node *n,
> 			stat(s, CPU_PARTIAL_NODE);
> 		}
> 		if (!kmem_cache_has_cpu_partial(s)
>-			|| available > s->cpu_partial / 2)
>+#ifdef CONFIG_SLUB_CPU_PARTIAL
>+			|| available > s->cpu_partial / 2
>+#endif
>+			)
> 			break;

Matthew,

I plan to change this one with the same idea you mentioned in previous repl=
y.

While one special "technique" is how to name it.

How about name this one

    slub_cpu_partial()

And rename the previous one

   slub_percpu_partial()

This is really hard to say which one is better :-(
Not sure whether you have some insight in this.

>=20
> 	}
>@@ -3418,6 +3421,39 @@ static void set_min_partial(struct kmem_cache *s, u=
nsigned long min)
> 	s->min_partial =3D min;
> }
>=20
>+static void set_cpu_partial(struct kmem_cache *s)
>+{
>+#ifdef CONFIG_SLUB_CPU_PARTIAL
>+	/*
>+	 * cpu_partial determined the maximum number of objects kept in the
>+	 * per cpu partial lists of a processor.
>+	 *
>+	 * Per cpu partial lists mainly contain slabs that just have one
>+	 * object freed. If they are used for allocation then they can be
>+	 * filled up again with minimal effort. The slab will never hit the
>+	 * per node partial lists and therefore no locking will be required.
>+	 *
>+	 * This setting also determines
>+	 *
>+	 * A) The number of objects from per cpu partial slabs dumped to the
>+	 *    per node list when we reach the limit.
>+	 * B) The number of objects in cpu partial slabs to extract from the
>+	 *    per node list when we run out of per cpu objects. We only fetch
>+	 *    50% to keep some capacity around for frees.
>+	 */
>+	if (!kmem_cache_has_cpu_partial(s))
>+		s->cpu_partial =3D 0;
>+	else if (s->size >=3D PAGE_SIZE)
>+		s->cpu_partial =3D 2;
>+	else if (s->size >=3D 1024)
>+		s->cpu_partial =3D 6;
>+	else if (s->size >=3D 256)
>+		s->cpu_partial =3D 13;
>+	else
>+		s->cpu_partial =3D 30;
>+#endif
>+}
>+
> /*
>  * calculate_sizes() determines the order and the distribution of data wi=
thin
>  * a slab object.
>@@ -3576,33 +3612,7 @@ static int kmem_cache_open(struct kmem_cache *s, un=
signed long flags)
> 	 */
> 	set_min_partial(s, ilog2(s->size) / 2);
>=20
>-	/*
>-	 * cpu_partial determined the maximum number of objects kept in the
>-	 * per cpu partial lists of a processor.
>-	 *
>-	 * Per cpu partial lists mainly contain slabs that just have one
>-	 * object freed. If they are used for allocation then they can be
>-	 * filled up again with minimal effort. The slab will never hit the
>-	 * per node partial lists and therefore no locking will be required.
>-	 *
>-	 * This setting also determines
>-	 *
>-	 * A) The number of objects from per cpu partial slabs dumped to the
>-	 *    per node list when we reach the limit.
>-	 * B) The number of objects in cpu partial slabs to extract from the
>-	 *    per node list when we run out of per cpu objects. We only fetch
>-	 *    50% to keep some capacity around for frees.
>-	 */
>-	if (!kmem_cache_has_cpu_partial(s))
>-		s->cpu_partial =3D 0;
>-	else if (s->size >=3D PAGE_SIZE)
>-		s->cpu_partial =3D 2;
>-	else if (s->size >=3D 1024)
>-		s->cpu_partial =3D 6;
>-	else if (s->size >=3D 256)
>-		s->cpu_partial =3D 13;
>-	else
>-		s->cpu_partial =3D 30;
>+	set_cpu_partial(s);
>=20
> #ifdef CONFIG_NUMA
> 	s->remote_node_defrag_ratio =3D 1000;
>@@ -3989,7 +3999,9 @@ void __kmemcg_cache_deactivate(struct kmem_cache *s)
> 	 * Disable empty slabs caching. Used to avoid pinning offline
> 	 * memory cgroups by kmem pages that can be freed.
> 	 */
>+#ifdef CONFIG_SLUB_CPU_PARTIAL
> 	s->cpu_partial =3D 0;
>+#endif
> 	s->min_partial =3D 0;
>=20
> 	/*
>@@ -4929,6 +4941,7 @@ static ssize_t min_partial_store(struct kmem_cache *=
s, const char *buf,
> }
> SLAB_ATTR(min_partial);
>=20
>+#ifdef CONFIG_SLUB_CPU_PARTIAL
> static ssize_t cpu_partial_show(struct kmem_cache *s, char *buf)
> {
> 	return sprintf(buf, "%u\n", s->cpu_partial);
>@@ -4951,6 +4964,7 @@ static ssize_t cpu_partial_store(struct kmem_cache *=
s, const char *buf,
> 	return length;
> }
> SLAB_ATTR(cpu_partial);
>+#endif
>=20
> static ssize_t ctor_show(struct kmem_cache *s, char *buf)
> {
>@@ -5363,7 +5377,9 @@ static struct attribute *slab_attrs[] =3D {
> 	&objs_per_slab_attr.attr,
> 	&order_attr.attr,
> 	&min_partial_attr.attr,
>+#ifdef CONFIG_SLUB_CPU_PARTIAL
> 	&cpu_partial_attr.attr,
>+#endif
> 	&objects_attr.attr,
> 	&objects_partial_attr.attr,
> 	&partial_attr.attr,
>--=20
>2.11.0

--=20
Wei Yang
Help you, Help me

--qMm9M+Fa2AknHoGS
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZB1ZQAAoJEKcLNpZP5cTdQrMQALH55R3OVfHfC0csUi8/l9iw
Bx6JkzK2amxoL2xWlwr7dhogxN8Bqie4oNMcMyQqVtssd4J6j4P5LM784nmR9E5F
hvNWV8vwdTqL69qjwZHBy3zZ2+PtHT/9aahVOlPl/uYs35ijjc03htNbYTMY0fG6
caRhSv7xzqOkrPN5ogA1z4jzT1wKooEcOoaPDoB5diElyiy1CaJWxX1WWBNoY/VL
oJqI2OnOW1PHFSAWX6kCn2xa1agehnQzx7UYFcLdr+WO/aDN1BgFMeT/EAi6x96k
hGrIQOPKrWtQnf07uQOsxqGMEx2dF9vUHvlzui/TapPX9KqArUPBuLB0nBDxPL+L
EwBZb1baclC6Yytc8i6RxEkLZjC17OcSFD9wcqXwGCWQHxY0uUiea5QjZqHmOLhK
70yKbtXN996AEz4xoiiytXaRLau1Y1ZXZ7gke0hxoeYOVKQyiV5exbOm+OI36RFF
YfuINUHBbicaiXv+ZVrEvjjPxT5FKtwU4TakozVkqlL7d3+MeuGw1biFPMQJdbq9
UlUfiAs8u0aM1MYQDFQR1jqAbdFWGiDNAQnRsOQrmeOXVP3qAAfqUTL8yxZxgnrM
p7O0Z2Ab5L2oYmrmfxEPQdeWoylSAZjVOk3ueX1Ku6+i6wxnl2nFn40lPPjmwgYb
5WCqETbHD+bKOW29TbLT
=Nuth
-----END PGP SIGNATURE-----

--qMm9M+Fa2AknHoGS--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
