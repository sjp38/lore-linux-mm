Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 95E256B025F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 03:18:29 -0400 (EDT)
Received: by qgev79 with SMTP id v79so135198011qge.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 00:18:29 -0700 (PDT)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id 143si15774459qhy.11.2015.09.15.00.18.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 00:18:28 -0700 (PDT)
Received: by qgev79 with SMTP id v79so135197796qge.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 00:18:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150915010043.GB1860@swordfish>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
	<20150914155036.7c90a8e313cb0ed4d4857934@gmail.com>
	<20150915010043.GB1860@swordfish>
Date: Tue, 15 Sep 2015 09:18:28 +0200
Message-ID: <CAMJBoFPynFJpu57Gftm6bbyGfdSK67y-HbvoQPwyuHS6+0tOyQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] zram: make max_zpage_size configurable
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: multipart/alternative; boundary=001a11376e5a10ee64051fc3fdec
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: minchan@kernel.org, linux-mm@kvack.org, sergey.senozhatsky@gmail.com, linux-kernel@vger.kernel.org, ddstreet@ieee.org

--001a11376e5a10ee64051fc3fdec
Content-Type: text/plain; charset=UTF-8

On Sep 15, 2015 2:59 AM, "Sergey Senozhatsky" <
sergey.senozhatsky.work@gmail.com> wrote:
>
> On (09/14/15 15:50), Vitaly Wool wrote:
> > It makes sense to have control over what compression ratios are
> > ok to store pages uncompressed and what not.
>
> um... I don't want this to be exported. this is very 'zram-internal'.
>
> besides, you remove the exsiting default value
> - static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
>
> so now people must provide this module param in order to make zram
> work the way it used to work for years?
>

I do not remove it, I move it :) May I ask to review the patch again please?

>
> > Moreover, if we end up using zbud allocator for zram, any attempt to
> > allocate a whole page will fail, so we may want to avoid this as much
> > as possible.
>
> so how does it help?
>
> > So, let's have max_zpage_size configurable as a module parameter.
> >
> > Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> > ---
> >  drivers/block/zram/zram_drv.c | 13 +++++++++++++
> >  drivers/block/zram/zram_drv.h | 16 ----------------
> >  2 files changed, 13 insertions(+), 16 deletions(-)
> >
> > diff --git a/drivers/block/zram/zram_drv.c
b/drivers/block/zram/zram_drv.c
> > index 9fa15bb..6d9f1d1 100644
> > --- a/drivers/block/zram/zram_drv.c
> > +++ b/drivers/block/zram/zram_drv.c
> > @@ -42,6 +42,7 @@ static const char *default_compressor = "lzo";
> >
> >  /* Module params (documentation at end) */
> >  static unsigned int num_devices = 1;
> > +static size_t max_zpage_size = PAGE_SIZE / 4 * 3;
> >
> >  static inline void deprecated_attr_warn(const char *name)
> >  {
> > @@ -1411,6 +1412,16 @@ static int __init zram_init(void)
> >               return ret;
> >       }
> >
> > +     /*
> > +      * max_zpage_size must be less than or equal to:
> > +      * ZS_MAX_ALLOC_SIZE. Otherwise, zs_malloc() would
> > +      * always return failure.
> > +      */
> > +     if (max_zpage_size > PAGE_SIZE) {
> > +             pr_err("Invalid max_zpage_size %ld\n", max_zpage_size);
>
> and how do people find out ZS_MAX_ALLOC_SIZE? this error message does not
> help.
>
> > +             return -EINVAL;
> > +     }
> > +
> >       zram_major = register_blkdev(0, "zram");
> >       if (zram_major <= 0) {
> >               pr_err("Unable to get major number\n");
> > @@ -1444,6 +1455,8 @@ module_exit(zram_exit);
> >
> >  module_param(num_devices, uint, 0);
> >  MODULE_PARM_DESC(num_devices, "Number of pre-created zram devices");
> > +module_param(max_zpage_size, ulong, 0);
> > +MODULE_PARM_DESC(max_zpage_size, "Threshold for storing compressed
pages");
>
> unclear description.
>
>
> >
> >  MODULE_LICENSE("Dual BSD/GPL");
> >  MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
> > diff --git a/drivers/block/zram/zram_drv.h
b/drivers/block/zram/zram_drv.h
> > index 8e92339..3a29c33 100644
> > --- a/drivers/block/zram/zram_drv.h
> > +++ b/drivers/block/zram/zram_drv.h
> > @@ -20,22 +20,6 @@
> >
> >  #include "zcomp.h"
> >
> > -/*-- Configurable parameters */
> > -
> > -/*
> > - * Pages that compress to size greater than this are stored
> > - * uncompressed in memory.
> > - */
> > -static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
> > -
> > -/*
> > - * NOTE: max_zpage_size must be less than or equal to:
> > - *   ZS_MAX_ALLOC_SIZE. Otherwise, zs_malloc() would
> > - * always return failure.
> > - */
> > -
> > -/*-- End of configurable params */
> > -
> >  #define SECTOR_SHIFT         9
> >  #define SECTORS_PER_PAGE_SHIFT       (PAGE_SHIFT - SECTOR_SHIFT)
> >  #define SECTORS_PER_PAGE     (1 << SECTORS_PER_PAGE_SHIFT)
> > --
> > 1.9.1
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >

--001a11376e5a10ee64051fc3fdec
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On Sep 15, 2015 2:59 AM, &quot;Sergey Senozhatsky&quot; &lt;<a href=3D"mail=
to:sergey.senozhatsky.work@gmail.com">sergey.senozhatsky.work@gmail.com</a>=
&gt; wrote:<br>
&gt;<br>
&gt; On (09/14/15 15:50), Vitaly Wool wrote:<br>
&gt; &gt; It makes sense to have control over what compression ratios are<b=
r>
&gt; &gt; ok to store pages uncompressed and what not.<br>
&gt;<br>
&gt; um... I don&#39;t want this to be exported. this is very &#39;zram-int=
ernal&#39;.<br>
&gt;<br>
&gt; besides, you remove the exsiting default value<br>
&gt; - static const size_t max_zpage_size =3D PAGE_SIZE / 4 * 3;<br>
&gt;<br>
&gt; so now people must provide this module param in order to make zram<br>
&gt; work the way it used to work for years?<br>
&gt;</p>
<p dir=3D"ltr">I do not remove it, I move it :) May I ask to review the pat=
ch again please?</p>
<p dir=3D"ltr">&gt;<br>
&gt; &gt; Moreover, if we end up using zbud allocator for zram, any attempt=
 to<br>
&gt; &gt; allocate a whole page will fail, so we may want to avoid this as =
much<br>
&gt; &gt; as possible.<br>
&gt;<br>
&gt; so how does it help?<br>
&gt;<br>
&gt; &gt; So, let&#39;s have max_zpage_size configurable as a module parame=
ter.<br>
&gt; &gt;<br>
&gt; &gt; Signed-off-by: Vitaly Wool &lt;<a href=3D"mailto:vitalywool@gmail=
.com">vitalywool@gmail.com</a>&gt;<br>
&gt; &gt; ---<br>
&gt; &gt;=C2=A0 drivers/block/zram/zram_drv.c | 13 +++++++++++++<br>
&gt; &gt;=C2=A0 drivers/block/zram/zram_drv.h | 16 ----------------<br>
&gt; &gt;=C2=A0 2 files changed, 13 insertions(+), 16 deletions(-)<br>
&gt; &gt;<br>
&gt; &gt; diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/z=
ram_drv.c<br>
&gt; &gt; index 9fa15bb..6d9f1d1 100644<br>
&gt; &gt; --- a/drivers/block/zram/zram_drv.c<br>
&gt; &gt; +++ b/drivers/block/zram/zram_drv.c<br>
&gt; &gt; @@ -42,6 +42,7 @@ static const char *default_compressor =3D &quot=
;lzo&quot;;<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 /* Module params (documentation at end) */<br>
&gt; &gt;=C2=A0 static unsigned int num_devices =3D 1;<br>
&gt; &gt; +static size_t max_zpage_size =3D PAGE_SIZE / 4 * 3;<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 static inline void deprecated_attr_warn(const char *name)<b=
r>
&gt; &gt;=C2=A0 {<br>
&gt; &gt; @@ -1411,6 +1412,16 @@ static int __init zram_init(void)<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;=
<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt;<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0/*<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 * max_zpage_size must be less than or equal=
 to:<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 * ZS_MAX_ALLOC_SIZE. Otherwise, zs_malloc()=
 would<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 * always return failure.<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 */<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0if (max_zpage_size &gt; PAGE_SIZE) {<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err(&quot;Inv=
alid max_zpage_size %ld\n&quot;, max_zpage_size);<br>
&gt;<br>
&gt; and how do people find out ZS_MAX_ALLOC_SIZE? this error message does =
not<br>
&gt; help.<br>
&gt;<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EINVAL;<=
br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt; +<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0zram_major =3D register_blkdev(0, &quot=
;zram&quot;);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0if (zram_major &lt;=3D 0) {<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err(&quo=
t;Unable to get major number\n&quot;);<br>
&gt; &gt; @@ -1444,6 +1455,8 @@ module_exit(zram_exit);<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 module_param(num_devices, uint, 0);<br>
&gt; &gt;=C2=A0 MODULE_PARM_DESC(num_devices, &quot;Number of pre-created z=
ram devices&quot;);<br>
&gt; &gt; +module_param(max_zpage_size, ulong, 0);<br>
&gt; &gt; +MODULE_PARM_DESC(max_zpage_size, &quot;Threshold for storing com=
pressed pages&quot;);<br>
&gt;<br>
&gt; unclear description.<br>
&gt;<br>
&gt;<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 MODULE_LICENSE(&quot;Dual BSD/GPL&quot;);<br>
&gt; &gt;=C2=A0 MODULE_AUTHOR(&quot;Nitin Gupta &lt;<a href=3D"mailto:ngupt=
a@vflare.org">ngupta@vflare.org</a>&gt;&quot;);<br>
&gt; &gt; diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/z=
ram_drv.h<br>
&gt; &gt; index 8e92339..3a29c33 100644<br>
&gt; &gt; --- a/drivers/block/zram/zram_drv.h<br>
&gt; &gt; +++ b/drivers/block/zram/zram_drv.h<br>
&gt; &gt; @@ -20,22 +20,6 @@<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 #include &quot;zcomp.h&quot;<br>
&gt; &gt;<br>
&gt; &gt; -/*-- Configurable parameters */<br>
&gt; &gt; -<br>
&gt; &gt; -/*<br>
&gt; &gt; - * Pages that compress to size greater than this are stored<br>
&gt; &gt; - * uncompressed in memory.<br>
&gt; &gt; - */<br>
&gt; &gt; -static const size_t max_zpage_size =3D PAGE_SIZE / 4 * 3;<br>
&gt; &gt; -<br>
&gt; &gt; -/*<br>
&gt; &gt; - * NOTE: max_zpage_size must be less than or equal to:<br>
&gt; &gt; - *=C2=A0 =C2=A0ZS_MAX_ALLOC_SIZE. Otherwise, zs_malloc() would<b=
r>
&gt; &gt; - * always return failure.<br>
&gt; &gt; - */<br>
&gt; &gt; -<br>
&gt; &gt; -/*-- End of configurable params */<br>
&gt; &gt; -<br>
&gt; &gt;=C2=A0 #define SECTOR_SHIFT=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A09<br>
&gt; &gt;=C2=A0 #define SECTORS_PER_PAGE_SHIFT=C2=A0 =C2=A0 =C2=A0 =C2=A0(P=
AGE_SHIFT - SECTOR_SHIFT)<br>
&gt; &gt;=C2=A0 #define SECTORS_PER_PAGE=C2=A0 =C2=A0 =C2=A0(1 &lt;&lt; SEC=
TORS_PER_PAGE_SHIFT)<br>
&gt; &gt; --<br>
&gt; &gt; 1.9.1<br>
&gt; &gt;<br>
&gt; &gt; --<br>
&gt; &gt; To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39=
; in<br>
&gt; &gt; the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvac=
k.org</a>.=C2=A0 For more info on Linux MM,<br>
&gt; &gt; see: <a href=3D"http://www.linux-mm.org/">http://www.linux-mm.org=
/</a> .<br>
&gt; &gt; Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont=
@kvack.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org"=
>email@kvack.org</a> &lt;/a&gt;<br>
&gt; &gt;<br>
</p>

--001a11376e5a10ee64051fc3fdec--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
