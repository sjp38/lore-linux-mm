Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id F07496B0190
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 05:53:05 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ld10so2046198pab.38
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 02:53:05 -0800 (PST)
Received: from psmtp.com ([74.125.245.161])
        by mx.google.com with SMTP id dj3si6086649pbc.220.2013.11.08.02.53.03
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 02:53:04 -0800 (PST)
Received: by mail-wi0-f172.google.com with SMTP id ez12so1962492wid.17
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 02:53:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <527CBCE4.3080106@oracle.com>
References: <1383904203.2715.2.camel@ubuntu>
	<527CBCE4.3080106@oracle.com>
Date: Fri, 8 Nov 2013 18:53:01 +0800
Message-ID: <CAEpV5diGfz9ekSAFCxJvte7giprNtF04pSKJLURVw=swKuJ2yw@mail.gmail.com>
Subject: Re: [Patch 3.11.7 1/1]mm: remove and free expired data in time in zswap
From: "changkun.li" <xfishcoder@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c350da9e580504eaa82f74
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: sjenning@linux.vnet.ibm.com, linux-mm@kvack.org, luyi@360.cn, lichangkun@360.cn, linux-kernel@vger.kernel.org

--001a11c350da9e580504eaa82f74
Content-Type: text/plain; charset=ISO-8859-1

I agree with you, I see the __frontswap_store in 'frontswap.c', it knows
the same offset entry exist in zswap. we could modify like this?:
int __frontswap_store(struct page *page)
{
    int ret = -1, dup = 0;
    swp_entry_t entry = { .val = page_private(page), };
    int type = swp_type(entry);
    struct swap_info_struct *sis = swap_info[type];
    pgoff_t offset = swp_offset(entry);

    /*
     * Return if no backend registed.
     * Don't need to inc frontswap_failed_stores here.
     */
    if (!frontswap_ops)
        return ret;

    BUG_ON(!PageLocked(page));
    BUG_ON(sis == NULL);
    if (__frontswap_test(sis, offset))
        dup = 1;
    ret = frontswap_ops->store(type, offset, page);
    if (ret == 0) {
        set_bit(offset, sis->frontswap_map);
        inc_frontswap_succ_stores();
        if (!dup)
            atomic_inc(&sis->frontswap_pages);
    } else {
        /*
          failed dup always results in automatic invalidate of
          the (older) page from frontswap
         */
        inc_frontswap_failed_stores();
++       if (dup) {
--         if (dup)
            __frontswap_clear(sis, offset);
++        __frontswap_invalidate_page(type, offset);
++       }
    }
    if (frontswap_writethrough_enabled)
        /* report failure so swap also writes to swap device */
        ret = -1;
    return ret;
}

but maybe the other frontswap modules is not space memory, they need not
call __frontswap_invalidate_page. so the code in here is only better for
zswap.



On Fri, Nov 8, 2013 at 6:28 PM, Bob Liu <bob.liu@oracle.com> wrote:

> On 11/08/2013 05:50 PM, changkun.li wrote:
> > In zswap, store page A to zbud if the compression ratio is high, insert
> > its entry into rbtree. if there is a entry B which has the same offset
> > in the rbtree.Remove and free B before insert the entry of A.
> >
> > case:
> > if the compression ratio of page A is not high, return without checking
> > the same offset one in rbtree.
> >
> > if there is a entry B which has the same offset in the rbtree. Now, we
> > make sure B is invalid or expired. But the entry and compressed memory
> > of B are not freed in time.
> >
> > Because zswap spaces data in memory, it makes the utilization of memory
> > lower. the other valid data in zbud is writeback to swap device more
> > possibility, when zswap is full.
> >
> > So if we make sure a entry is expired, free it in time.
> >
> > Signed-off-by: changkun.li<xfishcoder@gmail.com>
> > ---
> >  mm/zswap.c |    5 ++++-
> >  1 files changed, 4 insertions(+), 1 deletions(-)
> >
> > diff --git a/mm/zswap.c b/mm/zswap.c
> > index cbd9578..90a2813 100644
> > --- a/mm/zswap.c
> > +++ b/mm/zswap.c
> > @@ -596,6 +596,7 @@ fail:
> >       return ret;
> >  }
> >
> > +static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t
> > offset);
> >  /*********************************
> >  * frontswap hooks
> >  **********************************/
> > @@ -614,7 +615,7 @@ static int zswap_frontswap_store(unsigned type,
> > pgoff_t offset,
> >
> >       if (!tree) {
> >               ret = -ENODEV;
> > -             goto reject;
> > +             goto nodev;
> >       }
> >
> >       /* reclaim space if needed */
> > @@ -695,6 +696,8 @@ freepage:
> >       put_cpu_var(zswap_dstmem);
> >       zswap_entry_cache_free(entry);
> >  reject:
> > +     zswap_frontswap_invalidate_page(type, offset);
>
> I'm afraid when arrives here zswap_rb_search(offset) will always return
> NULL entry. So most of the time, it's just waste time to call
> zswap_frontswap_invalidate_page() to search rbtree.
>
> --
> Regards,
> -Bob
>

--001a11c350da9e580504eaa82f74
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">I agree with you, I see the __frontswap_store in &#39;fron=
tswap.c&#39;, it knows the same offset entry exist in zswap. we could modif=
y like this?:<br>int __frontswap_store(struct page *page)<br>{<br>=A0=A0=A0=
 int ret =3D -1, dup =3D 0;<br>
=A0=A0=A0 swp_entry_t entry =3D { .val =3D page_private(page), };<br>=A0=A0=
=A0 int type =3D swp_type(entry);<br>=A0=A0=A0 struct swap_info_struct *sis=
 =3D swap_info[type];<br>=A0=A0=A0 pgoff_t offset =3D swp_offset(entry);<br=
><br>=A0=A0=A0 /*<br>=A0=A0=A0 =A0* Return if no backend registed.<br>
=A0=A0=A0 =A0* Don&#39;t need to inc frontswap_failed_stores here.<br>=A0=
=A0=A0 =A0*/<br>=A0=A0=A0 if (!frontswap_ops)<br>=A0=A0=A0 =A0=A0=A0 return=
 ret;<br><br>=A0=A0=A0 BUG_ON(!PageLocked(page));<br>=A0=A0=A0 BUG_ON(sis =
=3D=3D NULL);<br>=A0=A0=A0 if (__frontswap_test(sis, offset))<br>
=A0=A0=A0 =A0=A0=A0 dup =3D 1;<br>=A0=A0=A0 ret =3D frontswap_ops-&gt;store=
(type, offset, page);<br>=A0=A0=A0 if (ret =3D=3D 0) {<br>=A0=A0=A0 =A0=A0=
=A0 set_bit(offset, sis-&gt;frontswap_map);<br>=A0=A0=A0 =A0=A0=A0 inc_fron=
tswap_succ_stores();<br>=A0=A0=A0 =A0=A0=A0 if (!dup)<br>=A0=A0=A0 =A0=A0=
=A0 =A0=A0=A0 atomic_inc(&amp;sis-&gt;frontswap_pages);<br>
=A0=A0=A0 } else {<br>=A0=A0=A0 =A0=A0=A0 /*<br>=A0=A0=A0 =A0=A0=A0 =A0 fai=
led dup always results in automatic invalidate of<br>=A0=A0=A0 =A0=A0=A0 =
=A0 the (older) page from frontswap<br>=A0=A0=A0 =A0=A0=A0 =A0*/<br>=A0=A0=
=A0 =A0=A0=A0 inc_frontswap_failed_stores();<br>++ =A0 =A0=A0=A0 if (dup) {=
<br>
--=A0=A0=A0=A0=A0=A0=A0=A0 if (dup)<br>=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 __fron=
tswap_clear(sis, offset);<br>++=A0=A0=A0=A0=A0=A0=A0 __frontswap_invalidate=
_page(type, offset);<br>++ =A0=A0=A0=A0=A0 }<br>=A0=A0=A0 }<br>=A0=A0=A0 if=
 (frontswap_writethrough_enabled)<br>=A0=A0=A0 =A0=A0=A0 /* report failure =
so swap also writes to swap device */<br>
=A0=A0=A0 =A0=A0=A0 ret =3D -1;<br>=A0=A0=A0 return ret;<br>}<br><br>but ma=
ybe the other frontswap modules is not space memory, they need not call  __=
frontswap_invalidate_page. so the code in here is only better for zswap.<br=
><br></div><div class=3D"gmail_extra">
<br><br><div class=3D"gmail_quote">On Fri, Nov 8, 2013 at 6:28 PM, Bob Liu =
<span dir=3D"ltr">&lt;<a href=3D"mailto:bob.liu@oracle.com" target=3D"_blan=
k">bob.liu@oracle.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_q=
uote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1e=
x">
<div class=3D"HOEnZb"><div class=3D"h5">On 11/08/2013 05:50 PM, <a href=3D"=
http://changkun.li" target=3D"_blank">changkun.li</a> wrote:<br>
&gt; In zswap, store page A to zbud if the compression ratio is high, inser=
t<br>
&gt; its entry into rbtree. if there is a entry B which has the same offset=
<br>
&gt; in the rbtree.Remove and free B before insert the entry of A.<br>
&gt;<br>
&gt; case:<br>
&gt; if the compression ratio of page A is not high, return without checkin=
g<br>
&gt; the same offset one in rbtree.<br>
&gt;<br>
&gt; if there is a entry B which has the same offset in the rbtree. Now, we=
<br>
&gt; make sure B is invalid or expired. But the entry and compressed memory=
<br>
&gt; of B are not freed in time.<br>
&gt;<br>
&gt; Because zswap spaces data in memory, it makes the utilization of memor=
y<br>
&gt; lower. the other valid data in zbud is writeback to swap device more<b=
r>
&gt; possibility, when zswap is full.<br>
&gt;<br>
&gt; So if we make sure a entry is expired, free it in time.<br>
&gt;<br>
&gt; Signed-off-by: <a href=3D"http://changkun.li" target=3D"_blank">changk=
un.li</a>&lt;<a href=3D"mailto:xfishcoder@gmail.com">xfishcoder@gmail.com</=
a>&gt;<br>
&gt; ---<br>
&gt; =A0mm/zswap.c | =A0 =A05 ++++-<br>
&gt; =A01 files changed, 4 insertions(+), 1 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/zswap.c b/mm/zswap.c<br>
&gt; index cbd9578..90a2813 100644<br>
&gt; --- a/mm/zswap.c<br>
&gt; +++ b/mm/zswap.c<br>
&gt; @@ -596,6 +596,7 @@ fail:<br>
&gt; =A0 =A0 =A0 return ret;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t<br=
>
&gt; offset);<br>
&gt; =A0/*********************************<br>
&gt; =A0* frontswap hooks<br>
&gt; =A0**********************************/<br>
&gt; @@ -614,7 +615,7 @@ static int zswap_frontswap_store(unsigned type,<br=
>
&gt; pgoff_t offset,<br>
&gt;<br>
&gt; =A0 =A0 =A0 if (!tree) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENODEV;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 goto reject;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 goto nodev;<br>
&gt; =A0 =A0 =A0 }<br>
&gt;<br>
&gt; =A0 =A0 =A0 /* reclaim space if needed */<br>
&gt; @@ -695,6 +696,8 @@ freepage:<br>
&gt; =A0 =A0 =A0 put_cpu_var(zswap_dstmem);<br>
&gt; =A0 =A0 =A0 zswap_entry_cache_free(entry);<br>
&gt; =A0reject:<br>
&gt; + =A0 =A0 zswap_frontswap_invalidate_page(type, offset);<br>
<br>
</div></div>I&#39;m afraid when arrives here zswap_rb_search(offset) will a=
lways return<br>
NULL entry. So most of the time, it&#39;s just waste time to call<br>
zswap_frontswap_invalidate_page() to search rbtree.<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
Regards,<br>
-Bob<br>
</font></span></blockquote></div><br></div>

--001a11c350da9e580504eaa82f74--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
