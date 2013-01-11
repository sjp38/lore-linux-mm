Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 19A606B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 23:47:52 -0500 (EST)
Received: by mail-qc0-f199.google.com with SMTP id b40so2403055qcq.6
        for <linux-mm@kvack.org>; Thu, 10 Jan 2013 20:47:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAmzW4Nz6if==JjxLQGYwwQwKPDXfUbeioyPHWZQQFNu=xXUeQ@mail.gmail.com>
References: <CAAvDA15U=KCOujRYA5k3YkvC9Z=E6fcG5hopPUJNgULYj_MAJw@mail.gmail.com>
	<1356449082-3016-1-git-send-email-js1304@gmail.com>
	<CAAmzW4Nz6if==JjxLQGYwwQwKPDXfUbeioyPHWZQQFNu=xXUeQ@mail.gmail.com>
Date: Thu, 10 Jan 2013 20:47:39 -0800
Message-ID: <CAAvDA17eH0A_pr9siX7PTipe=Jd7WFZxR7mkUi6K0_djkH=FPA@mail.gmail.com>
Subject: Re: [PATCH] slub: assign refcount for kmalloc_caches
From: Paul Hargrove <phhargrove@lbl.gov>
Content-Type: multipart/alternative; boundary=20cf3071c8aac8813304d2fbfee9
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

--20cf3071c8aac8813304d2fbfee9
Content-Type: text/plain; charset=ISO-8859-1

I just had a look at patch-3.7.2-rc1, and this change doesn't appear to
have made it in yet.
Am I missing something?

-Paul


On Tue, Dec 25, 2012 at 7:30 AM, JoonSoo Kim <js1304@gmail.com> wrote:

> 2012/12/26 Joonsoo Kim <js1304@gmail.com>:
> > commit cce89f4f6911286500cf7be0363f46c9b0a12ce0('Move kmem_cache
> > refcounting to common code') moves some refcount manipulation code to
> > common code. Unfortunately, it also removed refcount assignment for
> > kmalloc_caches. So, kmalloc_caches's refcount is initially 0.
> > This makes errornous situation.
> >
> > Paul Hargrove report that when he create a 8-byte kmem_cache and
> > destory it, he encounter below message.
> > 'Objects remaining in kmalloc-8 on kmem_cache_close()'
> >
> > 8-byte kmem_cache merge with 8-byte kmalloc cache and refcount is
> > increased by one. So, resulting refcount is 1. When destory it, it hit
> > refcount = 0, then kmem_cache_close() is executed and error message is
> > printed.
> >
> > This patch assign initial refcount 1 to kmalloc_caches, so fix this
> > errornous situtation.
> >
> > Cc: <stable@vger.kernel.org> # v3.7
> > Cc: Christoph Lameter <cl@linux.com>
> > Reported-by: Paul Hargrove <phhargrove@lbl.gov>
> > Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> >
> > diff --git a/mm/slub.c b/mm/slub.c
> > index a0d6984..321afab 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -3279,6 +3279,7 @@ static struct kmem_cache *__init
> create_kmalloc_cache(const char *name,
> >         if (kmem_cache_open(s, flags))
> >                 goto panic;
> >
> > +       s->refcount = 1;
> >         list_add(&s->list, &slab_caches);
> >         return s;
> >
> > --
> > 1.7.9.5
> >
>
> I missed some explanation.
> In v3.8-rc1, this problem is already solved.
> See create_kmalloc_cache() in mm/slab_common.c.
> So this patch is just for v3.7 stable.
>



-- 
Paul H. Hargrove                          PHHargrove@lbl.gov
Future Technologies Group
Computer and Data Sciences Department     Tel: +1-510-495-2352
Lawrence Berkeley National Laboratory     Fax: +1-510-486-6900

--20cf3071c8aac8813304d2fbfee9
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">I just had a look at=A0patch-3.7.2-rc1, and this change do=
esn&#39;t appear to have made it in yet.<div>Am I missing something?<br><di=
v><br></div><div style>-Paul</div></div></div><div class=3D"gmail_extra"><b=
r><br>
<div class=3D"gmail_quote">On Tue, Dec 25, 2012 at 7:30 AM, JoonSoo Kim <sp=
an dir=3D"ltr">&lt;<a href=3D"mailto:js1304@gmail.com" target=3D"_blank">js=
1304@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
2012/12/26 Joonsoo Kim &lt;<a href=3D"mailto:js1304@gmail.com">js1304@gmail=
.com</a>&gt;:<br>
&gt; commit cce89f4f6911286500cf7be0363f46c9b0a12ce0(&#39;Move kmem_cache<b=
r>
&gt; refcounting to common code&#39;) moves some refcount manipulation code=
 to<br>
&gt; common code. Unfortunately, it also removed refcount assignment for<br=
>
&gt; kmalloc_caches. So, kmalloc_caches&#39;s refcount is initially 0.<br>
&gt; This makes errornous situation.<br>
&gt;<br>
&gt; Paul Hargrove report that when he create a 8-byte kmem_cache and<br>
&gt; destory it, he encounter below message.<br>
&gt; &#39;Objects remaining in kmalloc-8 on kmem_cache_close()&#39;<br>
&gt;<br>
&gt; 8-byte kmem_cache merge with 8-byte kmalloc cache and refcount is<br>
&gt; increased by one. So, resulting refcount is 1. When destory it, it hit=
<br>
&gt; refcount =3D 0, then kmem_cache_close() is executed and error message =
is<br>
&gt; printed.<br>
&gt;<br>
&gt; This patch assign initial refcount 1 to kmalloc_caches, so fix this<br=
>
&gt; errornous situtation.<br>
&gt;<br>
&gt; Cc: &lt;<a href=3D"mailto:stable@vger.kernel.org">stable@vger.kernel.o=
rg</a>&gt; # v3.7<br>
&gt; Cc: Christoph Lameter &lt;<a href=3D"mailto:cl@linux.com">cl@linux.com=
</a>&gt;<br>
&gt; Reported-by: Paul Hargrove &lt;<a href=3D"mailto:phhargrove@lbl.gov">p=
hhargrove@lbl.gov</a>&gt;<br>
&gt; Signed-off-by: Joonsoo Kim &lt;<a href=3D"mailto:js1304@gmail.com">js1=
304@gmail.com</a>&gt;<br>
&gt;<br>
&gt; diff --git a/mm/slub.c b/mm/slub.c<br>
&gt; index a0d6984..321afab 100644<br>
&gt; --- a/mm/slub.c<br>
&gt; +++ b/mm/slub.c<br>
&gt; @@ -3279,6 +3279,7 @@ static struct kmem_cache *__init create_kmalloc_=
cache(const char *name,<br>
&gt; =A0 =A0 =A0 =A0 if (kmem_cache_open(s, flags))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto panic;<br>
&gt;<br>
&gt; + =A0 =A0 =A0 s-&gt;refcount =3D 1;<br>
&gt; =A0 =A0 =A0 =A0 list_add(&amp;s-&gt;list, &amp;slab_caches);<br>
&gt; =A0 =A0 =A0 =A0 return s;<br>
&gt;<br>
&gt; --<br>
&gt; 1.7.9.5<br>
&gt;<br>
<br>
I missed some explanation.<br>
In v3.8-rc1, this problem is already solved.<br>
See create_kmalloc_cache() in mm/slab_common.c.<br>
So this patch is just for v3.7 stable.<br>
</blockquote></div><br><br clear=3D"all"><div><br></div>-- <br><font face=
=3D"courier new, monospace"><div>Paul H. Hargrove =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0<a href=3D"mailto:PHHargrove@lbl.gov" target=3D"=
_blank">PHHargrove@lbl.gov</a></div>
<div>Future Technologies Group</div><div>Computer and Data Sciences Departm=
ent =A0 =A0 Tel: +1-510-495-2352</div><div>Lawrence Berkeley National Labor=
atory =A0 =A0 Fax: +1-510-486-6900</div></font>
</div>

--20cf3071c8aac8813304d2fbfee9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
