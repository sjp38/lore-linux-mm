Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 4163E6B0039
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 01:13:12 -0400 (EDT)
Received: by mail-ve0-f180.google.com with SMTP id pb11so261590veb.39
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 22:13:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130814134710.ff123b0ea802efa7261d7e26@linux-foundation.org>
References: <1376476281-26559-1-git-send-email-avagin@openvz.org>
	<20130814134710.ff123b0ea802efa7261d7e26@linux-foundation.org>
Date: Thu, 15 Aug 2013 09:13:11 +0400
Message-ID: <CANaxB-x7-H6yeTJ4=F4bJW=UgvvyUD_200wZG-gz9-3wYSh4hg@mail.gmail.com>
Subject: Re: [PATCH] kmemcg: don't allocate extra memory for root memcg_cache_params
From: Andrey Wagin <avagin@gmail.com>
Content-Type: multipart/alternative; boundary=001a1130cec8c48a5b04e3f5871d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Glauber Costa <glommer@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--001a1130cec8c48a5b04e3f5871d
Content-Type: text/plain; charset=ISO-8859-1

2013/8/15 Andrew Morton <akpm@linux-foundation.org>

> On Wed, 14 Aug 2013 14:31:21 +0400 Andrey Vagin <avagin@openvz.org> wrote:
>
> > The memcg_cache_params structure contains the common part and the union,
> > which represents two different types of data: one for root cashes and
> > another for child caches.
> >
> > The size of child data is fixed. The size of the memcg_caches array is
> > calculated in runtime.
> >
> > Currently the size of memcg_cache_params for root caches is calculated
> > incorrectly, because it includes the size of parameters for child caches.
> >
> > ssize_t size = memcg_caches_array_size(num_groups);
> > size *= sizeof(void *);
> >
> > size += sizeof(struct memcg_cache_params);
> >
> > ...
> >
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -3140,7 +3140,7 @@ int memcg_update_cache_size(struct kmem_cache *s,
> int num_groups)
> >               ssize_t size = memcg_caches_array_size(num_groups);
> >
> >               size *= sizeof(void *);
> > -             size += sizeof(struct memcg_cache_params);
> > +             size += sizeof(offsetof(struct memcg_cache_params,
> memcg_caches));
>
> This looks wrong. offsetof() returns size_t, so this is equivalent to
>
>                 size += sizeof(size_t);
>

sizeof doesn't have to be here. I will resend this patch. Thanks.

size += offsetof(struct memcg_cache_params, memcg_caches)


> >               s->memcg_params = kzalloc(size, GFP_KERNEL);
> >               if (!s->memcg_params) {
> > @@ -3183,13 +3183,16 @@ int memcg_update_cache_size(struct kmem_cache
> *s, int num_groups)
> >  int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
> >                        struct kmem_cache *root_cache)
> >  {
> > -     size_t size = sizeof(struct memcg_cache_params);
> > +     size_t size;
> >
> >       if (!memcg_kmem_enabled())
> >               return 0;
> >
> > -     if (!memcg)
> > +     if (!memcg) {
> > +             size = offsetof(struct memcg_cache_params, memcg_caches);
> >               size += memcg_limited_groups_array_size * sizeof(void *);
> > +     } else
> > +             size = sizeof(struct memcg_cache_params);
> >
> >       s->memcg_params = kzalloc(size, GFP_KERNEL);
> >       if (!s->memcg_params)
>
>

--001a1130cec8c48a5b04e3f5871d
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">2013/8/15 Andrew Morton <span dir=3D"ltr">&lt;<a href=3D"mailto:akp=
m@linux-foundation.org" target=3D"_blank">akpm@linux-foundation.org</a>&gt;=
</span><br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex"><div class=3D"im">On Wed, 14 Aug 2013 14:31:21 +0400 Andre=
y Vagin &lt;<a href=3D"mailto:avagin@openvz.org">avagin@openvz.org</a>&gt; =
wrote:<br>

<br>
&gt; The memcg_cache_params structure contains the common part and the unio=
n,<br>
&gt; which represents two different types of data: one for root cashes and<=
br>
&gt; another for child caches.<br>
&gt;<br>
&gt; The size of child data is fixed. The size of the memcg_caches array is=
<br>
&gt; calculated in runtime.<br>
&gt;<br>
&gt; Currently the size of memcg_cache_params for root caches is calculated=
<br>
&gt; incorrectly, because it includes the size of parameters for child cach=
es.<br>
&gt;<br>
&gt; ssize_t size =3D memcg_caches_array_size(num_groups);<br>
&gt; size *=3D sizeof(void *);<br>
&gt;<br>
&gt; size +=3D sizeof(struct memcg_cache_params);<br>
&gt;<br>
</div>&gt; ...<br>
<div class=3D"im">&gt;<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -3140,7 +3140,7 @@ int memcg_update_cache_size(struct kmem_cache *s=
, int num_groups)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 ssize_t size =3D memcg_caches_array_size(n=
um_groups);<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 size *=3D sizeof(void *);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 size +=3D sizeof(struct memcg_cache_params);=
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 size +=3D sizeof(offsetof(struct memcg_cache=
_params, memcg_caches));<br>
<br>
</div>This looks wrong. offsetof() returns size_t, so this is equivalent to=
<br>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size +=3D sizeof(size_t);<br></blockquote><=
div><br></div><div>sizeof doesn&#39;t have to be here. I will resend this p=
atch. Thanks.</div><div><br></div><div>size +=3D offsetof(struct memcg_cach=
e_params, memcg_caches)<br>
</div><div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0px =
0px 0px 0.8ex;border-left-width:1px;border-left-color:rgb(204,204,204);bord=
er-left-style:solid;padding-left:1ex">
<div class=3D""><div class=3D"h5"><br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 s-&gt;memcg_params =3D kzalloc(size, GFP_K=
ERNEL);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!s-&gt;memcg_params) {<br>
&gt; @@ -3183,13 +3183,16 @@ int memcg_update_cache_size(struct kmem_cache =
*s, int num_groups)<br>
&gt; =A0int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cach=
e *s,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct kmem_cache *root=
_cache)<br>
&gt; =A0{<br>
&gt; - =A0 =A0 size_t size =3D sizeof(struct memcg_cache_params);<br>
&gt; + =A0 =A0 size_t size;<br>
&gt;<br>
&gt; =A0 =A0 =A0 if (!memcg_kmem_enabled())<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;<br>
&gt;<br>
&gt; - =A0 =A0 if (!memcg)<br>
&gt; + =A0 =A0 if (!memcg) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 size =3D offsetof(struct memcg_cache_params,=
 memcg_caches);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 size +=3D memcg_limited_groups_array_size =
* sizeof(void *);<br>
&gt; + =A0 =A0 } else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 size =3D sizeof(struct memcg_cache_params);<=
br>
&gt;<br>
&gt; =A0 =A0 =A0 s-&gt;memcg_params =3D kzalloc(size, GFP_KERNEL);<br>
&gt; =A0 =A0 =A0 if (!s-&gt;memcg_params)<br>
<br>
</div></div></blockquote></div><br></div></div>

--001a1130cec8c48a5b04e3f5871d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
