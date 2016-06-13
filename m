Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0386B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 05:11:03 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r5so25752872wmr.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 02:11:03 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id c83si7190508wme.91.2016.06.13.02.11.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 02:11:01 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id n184so13184744wmn.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 02:11:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALZtONBj0a06T5pxu0AxnyQX8VreuhGxmdg-oMv6w6SJom9wpQ@mail.gmail.com>
References: <d2a7edd5e1f37d9daf4536927d1439df6f9dbd0a.1465378622.git.geliangtang@gmail.com>
	<CALZtONBj0a06T5pxu0AxnyQX8VreuhGxmdg-oMv6w6SJom9wpQ@mail.gmail.com>
Date: Mon, 13 Jun 2016 11:11:00 +0200
Message-ID: <CAMJBoFPA_7G4nEeaPzL6uAvewpvgAYMmJ-A2FwfDSYVyOBfShA@mail.gmail.com>
Subject: Re: [PATCH] zram: add zpool support
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b86c4825b8a6505352544b3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, Geliang Tang <geliangtang@gmail.com>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Nitin Gupta <ngupta@vflare.org>

--047d7b86c4825b8a6505352544b3
Content-Type: text/plain; charset=UTF-8

Den 8 juni 2016 6:33 em skrev "Dan Streetman" <ddstreet@ieee.org>:
>
> On Wed, Jun 8, 2016 at 5:39 AM, Geliang Tang <geliangtang@gmail.com>
wrote:
> > This patch adds zpool support for zram, it will allow us to use both
> > the zpool api and directly zsmalloc api in zram.
>
> besides the problems below, this was discussed a while ago and I
> believe Minchan is still against it, as nobody has so far shown what
> the benefit to zram would be; zram doesn't need the predictability, or
> evictability, of zbud or z3fold.

Well, I believe I have something to say here. z3fold is generally faster
than zsmalloc which makes it a better choice for zram sometimes, e.g. when
zram device is used for swap. Also,  z3fold and zbud do not require MMU so
zram over these can be used on small Linux powered MMU-less IoT devices, as
opposed to the traditional zram over zsmalloc. Otherwise I do agree with
Dan.

>
> >
> > Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> > ---
> >  drivers/block/zram/zram_drv.c | 97
+++++++++++++++++++++++++++++++++++++++++++
> >  drivers/block/zram/zram_drv.h |  5 +++
> >  2 files changed, 102 insertions(+)
> >
> > diff --git a/drivers/block/zram/zram_drv.c
b/drivers/block/zram/zram_drv.c
> > index 9e2a83c..1f90bd0 100644
> > --- a/drivers/block/zram/zram_drv.c
> > +++ b/drivers/block/zram/zram_drv.c
> > @@ -43,6 +43,11 @@ static const char *default_compressor = "lzo";
> >  /* Module params (documentation at end) */
> >  static unsigned int num_devices = 1;
> >
> > +#ifdef CONFIG_ZPOOL
> > +/* Compressed storage zpool to use */
> > +#define ZRAM_ZPOOL_DEFAULT "zsmalloc"
> > +#endif
>
> It doesn't make sense for zram to conditionally use zpool; either it
> uses it and thus has 'select ZPOOL' in its Kconfig entry, or it
> doesn't use it at all.
>
> > +
> >  static inline void deprecated_attr_warn(const char *name)
> >  {
> >         pr_warn_once("%d (%s) Attribute %s (and others) will be
removed. %s\n",
> > @@ -228,7 +233,11 @@ static ssize_t mem_used_total_show(struct device
*dev,
> >         down_read(&zram->init_lock);
> >         if (init_done(zram)) {
> >                 struct zram_meta *meta = zram->meta;
> > +#ifdef CONFIG_ZPOOL
> > +               val = zpool_get_total_size(meta->mem_pool) >>
PAGE_SHIFT;
> > +#else
> >                 val = zs_get_total_pages(meta->mem_pool);
> > +#endif
> >         }
> >         up_read(&zram->init_lock);
> >
> > @@ -296,8 +305,14 @@ static ssize_t mem_used_max_store(struct device
*dev,
> >         down_read(&zram->init_lock);
> >         if (init_done(zram)) {
> >                 struct zram_meta *meta = zram->meta;
> > +#ifdef CONFIG_ZPOOL
> > +               atomic_long_set(&zram->stats.max_used_pages,
> > +                               zpool_get_total_size(meta->mem_pool)
> > +                               >> PAGE_SHIFT);
> > +#else
> >                 atomic_long_set(&zram->stats.max_used_pages,
> >                                 zs_get_total_pages(meta->mem_pool));
> > +#endif
> >         }
> >         up_read(&zram->init_lock);
> >
> > @@ -366,6 +381,18 @@ static ssize_t comp_algorithm_store(struct device
*dev,
> >         return len;
> >  }
> >
> > +#ifdef CONFIG_ZPOOL
> > +static void zpool_compact(void *pool)
> > +{
> > +       zs_compact(pool);
> > +}
> > +
> > +static void zpool_stats(void *pool, struct zs_pool_stats *stats)
> > +{
> > +       zs_pool_stats(pool, stats);
> > +}
> > +#endif
>
> first, no.  this obviously makes using zpool in zram completely pointless.
>
> second, did you test this?  the pool you're passing is the zpool, not
> the zs_pool.  quite bad things will happen when this code runs.  There
> is no way to get the zs_pool from the zpool object (that's the point
> of abstraction, of course).
>
> The fact zpool doesn't have these apis (currently) is one of the
> reasons against changing zram to use zpool.
>
> > +
> >  static ssize_t compact_store(struct device *dev,
> >                 struct device_attribute *attr, const char *buf, size_t
len)
> >  {
> > @@ -379,7 +406,11 @@ static ssize_t compact_store(struct device *dev,
> >         }
> >
> >         meta = zram->meta;
> > +#ifdef CONFIG_ZPOOL
> > +       zpool_compact(meta->mem_pool);
> > +#else
> >         zs_compact(meta->mem_pool);
> > +#endif
> >         up_read(&zram->init_lock);
> >
> >         return len;
> > @@ -416,8 +447,14 @@ static ssize_t mm_stat_show(struct device *dev,
> >
> >         down_read(&zram->init_lock);
> >         if (init_done(zram)) {
> > +#ifdef CONFIG_ZPOOL
> > +               mem_used = zpool_get_total_size(zram->meta->mem_pool)
> > +                               >> PAGE_SHIFT;
> > +               zpool_stats(zram->meta->mem_pool, &pool_stats);
> > +#else
> >                 mem_used = zs_get_total_pages(zram->meta->mem_pool);
> >                 zs_pool_stats(zram->meta->mem_pool, &pool_stats);
> > +#endif
> >         }
> >
> >         orig_size = atomic64_read(&zram->stats.pages_stored);
> > @@ -490,10 +527,18 @@ static void zram_meta_free(struct zram_meta
*meta, u64 disksize)
> >                 if (!handle)
> >                         continue;
> >
> > +#ifdef CONFIG_ZPOOL
> > +               zpool_free(meta->mem_pool, handle);
> > +#else
> >                 zs_free(meta->mem_pool, handle);
> > +#endif
> >         }
> >
> > +#ifdef CONFIG_ZPOOL
> > +       zpool_destroy_pool(meta->mem_pool);
> > +#else
> >         zs_destroy_pool(meta->mem_pool);
> > +#endif
> >         vfree(meta->table);
> >         kfree(meta);
> >  }
> > @@ -513,7 +558,17 @@ static struct zram_meta *zram_meta_alloc(char
*pool_name, u64 disksize)
> >                 goto out_error;
> >         }
> >
> > +#ifdef CONFIG_ZPOOL
> > +       if (!zpool_has_pool(ZRAM_ZPOOL_DEFAULT)) {
> > +               pr_err("zpool %s not available\n", ZRAM_ZPOOL_DEFAULT);
> > +               goto out_error;
> > +       }
> > +
> > +       meta->mem_pool = zpool_create_pool(ZRAM_ZPOOL_DEFAULT,
> > +                                       pool_name, 0, NULL);
> > +#else
> >         meta->mem_pool = zs_create_pool(pool_name);
> > +#endif
> >         if (!meta->mem_pool) {
> >                 pr_err("Error creating memory pool\n");
> >                 goto out_error;
> > @@ -549,7 +604,11 @@ static void zram_free_page(struct zram *zram,
size_t index)
> >                 return;
> >         }
> >
> > +#ifdef CONFIG_ZPOOL
> > +       zpool_free(meta->mem_pool, handle);
> > +#else
> >         zs_free(meta->mem_pool, handle);
> > +#endif
> >
> >         atomic64_sub(zram_get_obj_size(meta, index),
> >                         &zram->stats.compr_data_size);
> > @@ -577,7 +636,11 @@ static int zram_decompress_page(struct zram *zram,
char *mem, u32 index)
> >                 return 0;
> >         }
> >
> > +#ifdef CONFIG_ZPOOL
> > +       cmem = zpool_map_handle(meta->mem_pool, handle, ZPOOL_MM_RO);
> > +#else
> >         cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_RO);
> > +#endif
> >         if (size == PAGE_SIZE) {
> >                 copy_page(mem, cmem);
> >         } else {
> > @@ -586,7 +649,11 @@ static int zram_decompress_page(struct zram *zram,
char *mem, u32 index)
> >                 ret = zcomp_decompress(zstrm, cmem, size, mem);
> >                 zcomp_stream_put(zram->comp);
> >         }
> > +#ifdef CONFIG_ZPOOL
> > +       zpool_unmap_handle(meta->mem_pool, handle);
> > +#else
> >         zs_unmap_object(meta->mem_pool, handle);
> > +#endif
> >         bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
> >
> >         /* Should NEVER happen. Return bio error if it does. */
> > @@ -735,20 +802,34 @@ compress_again:
> >          * from the slow path and handle has already been allocated.
> >          */
> >         if (!handle)
> > +#ifdef CONFIG_ZPOOL
> > +               ret = zpool_malloc(meta->mem_pool, clen,
> > +                               __GFP_KSWAPD_RECLAIM |
> > +                               __GFP_NOWARN |
> > +                               __GFP_HIGHMEM |
> > +                               __GFP_MOVABLE, &handle);
> > +#else
> >                 handle = zs_malloc(meta->mem_pool, clen,
> >                                 __GFP_KSWAPD_RECLAIM |
> >                                 __GFP_NOWARN |
> >                                 __GFP_HIGHMEM |
> >                                 __GFP_MOVABLE);
> > +#endif
> >         if (!handle) {
> >                 zcomp_stream_put(zram->comp);
> >                 zstrm = NULL;
> >
> >                 atomic64_inc(&zram->stats.writestall);
> >
> > +#ifdef CONFIG_ZPOOL
> > +               ret = zpool_malloc(meta->mem_pool, clen,
> > +                               GFP_NOIO | __GFP_HIGHMEM |
> > +                               __GFP_MOVABLE, &handle);
> > +#else
> >                 handle = zs_malloc(meta->mem_pool, clen,
> >                                 GFP_NOIO | __GFP_HIGHMEM |
> >                                 __GFP_MOVABLE);
> > +#endif
> >                 if (handle)
> >                         goto compress_again;
> >
> > @@ -758,16 +839,28 @@ compress_again:
> >                 goto out;
> >         }
> >
> > +#ifdef CONFIG_ZPOOL
> > +       alloced_pages = zpool_get_total_size(meta->mem_pool) >>
PAGE_SHIFT;
> > +#else
> >         alloced_pages = zs_get_total_pages(meta->mem_pool);
> > +#endif
> >         update_used_max(zram, alloced_pages);
> >
> >         if (zram->limit_pages && alloced_pages > zram->limit_pages) {
> > +#ifdef CONFIG_ZPOOL
> > +               zpool_free(meta->mem_pool, handle);
> > +#else
> >                 zs_free(meta->mem_pool, handle);
> > +#endif
> >                 ret = -ENOMEM;
> >                 goto out;
> >         }
> >
> > +#ifdef CONFIG_ZPOOL
> > +       cmem = zpool_map_handle(meta->mem_pool, handle, ZPOOL_MM_WO);
> > +#else
> >         cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
> > +#endif
> >
> >         if ((clen == PAGE_SIZE) && !is_partial_io(bvec)) {
> >                 src = kmap_atomic(page);
> > @@ -779,7 +872,11 @@ compress_again:
> >
> >         zcomp_stream_put(zram->comp);
> >         zstrm = NULL;
> > +#ifdef CONFIG_ZPOOL
> > +       zpool_unmap_handle(meta->mem_pool, handle);
> > +#else
> >         zs_unmap_object(meta->mem_pool, handle);
> > +#endif
> >
> >         /*
> >          * Free memory associated with this sector
> > diff --git a/drivers/block/zram/zram_drv.h
b/drivers/block/zram/zram_drv.h
> > index 74fcf10..68f1222 100644
> > --- a/drivers/block/zram/zram_drv.h
> > +++ b/drivers/block/zram/zram_drv.h
> > @@ -17,6 +17,7 @@
> >
> >  #include <linux/rwsem.h>
> >  #include <linux/zsmalloc.h>
> > +#include <linux/zpool.h>
> >  #include <linux/crypto.h>
> >
> >  #include "zcomp.h"
> > @@ -91,7 +92,11 @@ struct zram_stats {
> >
> >  struct zram_meta {
> >         struct zram_table_entry *table;
> > +#ifdef CONFIG_ZPOOL
> > +       struct zpool *mem_pool;
> > +#else
> >         struct zs_pool *mem_pool;
> > +#endif
> >  };
> >
> >  struct zram {
> > --
> > 1.9.1
> >

Best regards,
Vitaly

--047d7b86c4825b8a6505352544b3
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
Den 8 juni 2016 6:33 em skrev &quot;Dan Streetman&quot; &lt;<a href=3D"mail=
to:ddstreet@ieee.org">ddstreet@ieee.org</a>&gt;:<br>
&gt;<br>
&gt; On Wed, Jun 8, 2016 at 5:39 AM, Geliang Tang &lt;<a href=3D"mailto:gel=
iangtang@gmail.com">geliangtang@gmail.com</a>&gt; wrote:<br>
&gt; &gt; This patch adds zpool support for zram, it will allow us to use b=
oth<br>
&gt; &gt; the zpool api and directly zsmalloc api in zram.<br>
&gt;<br>
&gt; besides the problems below, this was discussed a while ago and I<br>
&gt; believe Minchan is still against it, as nobody has so far shown what<b=
r>
&gt; the benefit to zram would be; zram doesn&#39;t need the predictability=
, or<br>
&gt; evictability, of zbud or z3fold.</p>
<p dir=3D"ltr">Well, I believe I have something to say here. z3fold is gene=
rally faster than zsmalloc which makes it a better choice for zram sometime=
s, e.g. when zram device is used for swap. Also,=C2=A0 z3fold and zbud do n=
ot require MMU so zram over these can be used on small Linux powered MMU-le=
ss IoT devices, as opposed to the traditional zram over zsmalloc. Otherwise=
 I do agree with Dan. </p>
<p dir=3D"ltr">&gt;<br>
&gt; &gt;<br>
&gt; &gt; Signed-off-by: Geliang Tang &lt;<a href=3D"mailto:geliangtang@gma=
il.com">geliangtang@gmail.com</a>&gt;<br>
&gt; &gt; ---<br>
&gt; &gt;=C2=A0 drivers/block/zram/zram_drv.c | 97 ++++++++++++++++++++++++=
+++++++++++++++++++<br>
&gt; &gt;=C2=A0 drivers/block/zram/zram_drv.h |=C2=A0 5 +++<br>
&gt; &gt;=C2=A0 2 files changed, 102 insertions(+)<br>
&gt; &gt;<br>
&gt; &gt; diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/z=
ram_drv.c<br>
&gt; &gt; index 9e2a83c..1f90bd0 100644<br>
&gt; &gt; --- a/drivers/block/zram/zram_drv.c<br>
&gt; &gt; +++ b/drivers/block/zram/zram_drv.c<br>
&gt; &gt; @@ -43,6 +43,11 @@ static const char *default_compressor =3D &quo=
t;lzo&quot;;<br>
&gt; &gt;=C2=A0 /* Module params (documentation at end) */<br>
&gt; &gt;=C2=A0 static unsigned int num_devices =3D 1;<br>
&gt; &gt;<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +/* Compressed storage zpool to use */<br>
&gt; &gt; +#define ZRAM_ZPOOL_DEFAULT &quot;zsmalloc&quot;<br>
&gt; &gt; +#endif<br>
&gt;<br>
&gt; It doesn&#39;t make sense for zram to conditionally use zpool; either =
it<br>
&gt; uses it and thus has &#39;select ZPOOL&#39; in its Kconfig entry, or i=
t<br>
&gt; doesn&#39;t use it at all.<br>
&gt;<br>
&gt; &gt; +<br>
&gt; &gt;=C2=A0 static inline void deprecated_attr_warn(const char *name)<b=
r>
&gt; &gt;=C2=A0 {<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_warn_once(&quot;%d (%s) Attri=
bute %s (and others) will be removed. %s\n&quot;,<br>
&gt; &gt; @@ -228,7 +233,11 @@ static ssize_t mem_used_total_show(struct de=
vice *dev,<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0down_read(&amp;zram-&gt;init_loc=
k);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (init_done(zram)) {<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0stru=
ct zram_meta *meta =3D zram-&gt;meta;<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0val =3D z=
pool_get_total_size(meta-&gt;mem_pool) &gt;&gt; PAGE_SHIFT;<br>
&gt; &gt; +#else<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0val =
=3D zs_get_total_pages(meta-&gt;mem_pool);<br>
&gt; &gt; +#endif<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0up_read(&amp;zram-&gt;init_lock)=
;<br>
&gt; &gt;<br>
&gt; &gt; @@ -296,8 +305,14 @@ static ssize_t mem_used_max_store(struct dev=
ice *dev,<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0down_read(&amp;zram-&gt;init_loc=
k);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (init_done(zram)) {<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0stru=
ct zram_meta *meta =3D zram-&gt;meta;<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_lo=
ng_set(&amp;zram-&gt;stats.max_used_pages,<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zpool_get_total_size(meta-&=
gt;mem_pool)<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&gt;&gt; PAGE_SHIFT);<br>
&gt; &gt; +#else<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0atom=
ic_long_set(&amp;zram-&gt;stats.max_used_pages,<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zs_get_total_pages(meta=
-&gt;mem_pool));<br>
&gt; &gt; +#endif<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0up_read(&amp;zram-&gt;init_lock)=
;<br>
&gt; &gt;<br>
&gt; &gt; @@ -366,6 +381,18 @@ static ssize_t comp_algorithm_store(struct d=
evice *dev,<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return len;<br>
&gt; &gt;=C2=A0 }<br>
&gt; &gt;<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +static void zpool_compact(void *pool)<br>
&gt; &gt; +{<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0zs_compact(pool);<br>
&gt; &gt; +}<br>
&gt; &gt; +<br>
&gt; &gt; +static void zpool_stats(void *pool, struct zs_pool_stats *stats)=
<br>
&gt; &gt; +{<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0zs_pool_stats(pool, stats);<br>
&gt; &gt; +}<br>
&gt; &gt; +#endif<br>
&gt;<br>
&gt; first, no.=C2=A0 this obviously makes using zpool in zram completely p=
ointless.<br>
&gt;<br>
&gt; second, did you test this?=C2=A0 the pool you&#39;re passing is the zp=
ool, not<br>
&gt; the zs_pool.=C2=A0 quite bad things will happen when this code runs.=
=C2=A0 There<br>
&gt; is no way to get the zs_pool from the zpool object (that&#39;s the poi=
nt<br>
&gt; of abstraction, of course).<br>
&gt;<br>
&gt; The fact zpool doesn&#39;t have these apis (currently) is one of the<b=
r>
&gt; reasons against changing zram to use zpool.<br>
&gt;<br>
&gt; &gt; +<br>
&gt; &gt;=C2=A0 static ssize_t compact_store(struct device *dev,<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0stru=
ct device_attribute *attr, const char *buf, size_t len)<br>
&gt; &gt;=C2=A0 {<br>
&gt; &gt; @@ -379,7 +406,11 @@ static ssize_t compact_store(struct device *=
dev,<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0meta =3D zram-&gt;meta;<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0zpool_compact(meta-&gt;mem_pool);<br>
&gt; &gt; +#else<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zs_compact(meta-&gt;mem_pool);<b=
r>
&gt; &gt; +#endif<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0up_read(&amp;zram-&gt;init_lock)=
;<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return len;<br>
&gt; &gt; @@ -416,8 +447,14 @@ static ssize_t mm_stat_show(struct device *d=
ev,<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0down_read(&amp;zram-&gt;init_loc=
k);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (init_done(zram)) {<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_used =
=3D zpool_get_total_size(zram-&gt;meta-&gt;mem_pool)<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&gt;&gt; PAGE_SHIFT;<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zpool_sta=
ts(zram-&gt;meta-&gt;mem_pool, &amp;pool_stats);<br>
&gt; &gt; +#else<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_=
used =3D zs_get_total_pages(zram-&gt;meta-&gt;mem_pool);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zs_p=
ool_stats(zram-&gt;meta-&gt;mem_pool, &amp;pool_stats);<br>
&gt; &gt; +#endif<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0orig_size =3D atomic64_read(&amp=
;zram-&gt;stats.pages_stored);<br>
&gt; &gt; @@ -490,10 +527,18 @@ static void zram_meta_free(struct zram_meta=
 *meta, u64 disksize)<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (=
!handle)<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0continue;<br>
&gt; &gt;<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zpool_fre=
e(meta-&gt;mem_pool, handle);<br>
&gt; &gt; +#else<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zs_f=
ree(meta-&gt;mem_pool, handle);<br>
&gt; &gt; +#endif<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt;<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0zpool_destroy_pool(meta-&gt;mem_pool)=
;<br>
&gt; &gt; +#else<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zs_destroy_pool(meta-&gt;mem_poo=
l);<br>
&gt; &gt; +#endif<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0vfree(meta-&gt;table);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0kfree(meta);<br>
&gt; &gt;=C2=A0 }<br>
&gt; &gt; @@ -513,7 +558,17 @@ static struct zram_meta *zram_meta_alloc(cha=
r *pool_name, u64 disksize)<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto=
 out_error;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt;<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!zpool_has_pool(ZRAM_ZPOOL_DEFAUL=
T)) {<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err(&q=
uot;zpool %s not available\n&quot;, ZRAM_ZPOOL_DEFAULT);<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out_=
error;<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt; +<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0meta-&gt;mem_pool =3D zpool_create_po=
ol(ZRAM_ZPOOL_DEFAULT,<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0pool_name, 0, NULL);<br>
&gt; &gt; +#else<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0meta-&gt;mem_pool =3D zs_create_=
pool(pool_name);<br>
&gt; &gt; +#endif<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!meta-&gt;mem_pool) {<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_e=
rr(&quot;Error creating memory pool\n&quot;);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto=
 out_error;<br>
&gt; &gt; @@ -549,7 +604,11 @@ static void zram_free_page(struct zram *zram=
, size_t index)<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0retu=
rn;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt;<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0zpool_free(meta-&gt;mem_pool, handle)=
;<br>
&gt; &gt; +#else<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zs_free(meta-&gt;mem_pool, handl=
e);<br>
&gt; &gt; +#endif<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0atomic64_sub(zram_get_obj_size(m=
eta, index),<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0&amp;zram-&gt;stats.compr_data_size);<br>
&gt; &gt; @@ -577,7 +636,11 @@ static int zram_decompress_page(struct zram =
*zram, char *mem, u32 index)<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0retu=
rn 0;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt;<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0cmem =3D zpool_map_handle(meta-&gt;me=
m_pool, handle, ZPOOL_MM_RO);<br>
&gt; &gt; +#else<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cmem =3D zs_map_object(meta-&gt;=
mem_pool, handle, ZS_MM_RO);<br>
&gt; &gt; +#endif<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (size =3D=3D PAGE_SIZE) {<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0copy=
_page(mem, cmem);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {<br>
&gt; &gt; @@ -586,7 +649,11 @@ static int zram_decompress_page(struct zram =
*zram, char *mem, u32 index)<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =
=3D zcomp_decompress(zstrm, cmem, size, mem);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zcom=
p_stream_put(zram-&gt;comp);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0zpool_unmap_handle(meta-&gt;mem_pool,=
 handle);<br>
&gt; &gt; +#else<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zs_unmap_object(meta-&gt;mem_poo=
l, handle);<br>
&gt; &gt; +#endif<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bit_spin_unlock(ZRAM_ACCESS, &am=
p;meta-&gt;table[index].value);<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Should NEVER happen. Return b=
io error if it does. */<br>
&gt; &gt; @@ -735,20 +802,34 @@ compress_again:<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * from the slow path and handle=
 has already been allocated.<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!handle)<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D z=
pool_malloc(meta-&gt;mem_pool, clen,<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__GFP_KSWAPD_RECLAIM |<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__GFP_NOWARN |<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__GFP_HIGHMEM |<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__GFP_MOVABLE, &amp;handle)=
;<br>
&gt; &gt; +#else<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hand=
le =3D zs_malloc(meta-&gt;mem_pool, clen,<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__GFP_KSWAPD_RECLAIM |<=
br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__GFP_NOWARN |<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__GFP_HIGHMEM |<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__GFP_MOVABLE);<br>
&gt; &gt; +#endif<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!handle) {<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zcom=
p_stream_put(zram-&gt;comp);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zstr=
m =3D NULL;<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0atom=
ic64_inc(&amp;zram-&gt;stats.writestall);<br>
&gt; &gt;<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D z=
pool_malloc(meta-&gt;mem_pool, clen,<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0GFP_NOIO | __GFP_HIGHMEM |<=
br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__GFP_MOVABLE, &amp;handle)=
;<br>
&gt; &gt; +#else<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hand=
le =3D zs_malloc(meta-&gt;mem_pool, clen,<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0GFP_NOIO | __GFP_HIGHME=
M |<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__GFP_MOVABLE);<br>
&gt; &gt; +#endif<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (=
handle)<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0goto compress_again;<br>
&gt; &gt;<br>
&gt; &gt; @@ -758,16 +839,28 @@ compress_again:<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto=
 out;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt;<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0alloced_pages =3D zpool_get_total_siz=
e(meta-&gt;mem_pool) &gt;&gt; PAGE_SHIFT;<br>
&gt; &gt; +#else<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0alloced_pages =3D zs_get_total_p=
ages(meta-&gt;mem_pool);<br>
&gt; &gt; +#endif<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0update_used_max(zram, alloced_pa=
ges);<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (zram-&gt;limit_pages &amp;&a=
mp; alloced_pages &gt; zram-&gt;limit_pages) {<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zpool_fre=
e(meta-&gt;mem_pool, handle);<br>
&gt; &gt; +#else<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zs_f=
ree(meta-&gt;mem_pool, handle);<br>
&gt; &gt; +#endif<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =
=3D -ENOMEM;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto=
 out;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt;<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0cmem =3D zpool_map_handle(meta-&gt;me=
m_pool, handle, ZPOOL_MM_WO);<br>
&gt; &gt; +#else<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cmem =3D zs_map_object(meta-&gt;=
mem_pool, handle, ZS_MM_WO);<br>
&gt; &gt; +#endif<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((clen =3D=3D PAGE_SIZE) &amp=
;&amp; !is_partial_io(bvec)) {<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0src =
=3D kmap_atomic(page);<br>
&gt; &gt; @@ -779,7 +872,11 @@ compress_again:<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zcomp_stream_put(zram-&gt;comp);=
<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zstrm =3D NULL;<br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0zpool_unmap_handle(meta-&gt;mem_pool,=
 handle);<br>
&gt; &gt; +#else<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zs_unmap_object(meta-&gt;mem_poo=
l, handle);<br>
&gt; &gt; +#endif<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Free memory associated with t=
his sector<br>
&gt; &gt; diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/z=
ram_drv.h<br>
&gt; &gt; index 74fcf10..68f1222 100644<br>
&gt; &gt; --- a/drivers/block/zram/zram_drv.h<br>
&gt; &gt; +++ b/drivers/block/zram/zram_drv.h<br>
&gt; &gt; @@ -17,6 +17,7 @@<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 #include &lt;linux/rwsem.h&gt;<br>
&gt; &gt;=C2=A0 #include &lt;linux/zsmalloc.h&gt;<br>
&gt; &gt; +#include &lt;linux/zpool.h&gt;<br>
&gt; &gt;=C2=A0 #include &lt;linux/crypto.h&gt;<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 #include &quot;zcomp.h&quot;<br>
&gt; &gt; @@ -91,7 +92,11 @@ struct zram_stats {<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 struct zram_meta {<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zram_table_entry *table;<=
br>
&gt; &gt; +#ifdef CONFIG_ZPOOL<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0struct zpool *mem_pool;<br>
&gt; &gt; +#else<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zs_pool *mem_pool;<br>
&gt; &gt; +#endif<br>
&gt; &gt;=C2=A0 };<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 struct zram {<br>
&gt; &gt; --<br>
&gt; &gt; 1.9.1<br>
&gt; &gt;</p>
<p dir=3D"ltr">Best regards, <br>
 Vitaly </p>

--047d7b86c4825b8a6505352544b3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
