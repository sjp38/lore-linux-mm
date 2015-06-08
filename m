Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 641006B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 01:15:05 -0400 (EDT)
Received: by padev16 with SMTP id ev16so31000304pad.0
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 22:15:05 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id pp3si2269842pac.191.2015.06.07.22.15.04
        for <linux-mm@kvack.org>;
        Sun, 07 Jun 2015 22:15:04 -0700 (PDT)
From: "Liu, XinwuX" <xinwux.liu@intel.com>
Subject: [PATCH] slub/slab: fix kmemleak didn't work on some case
Date: Mon, 8 Jun 2015 05:14:32 +0000
Message-ID: <99C214DF91337140A8D774E25DF6CD5FC89DA2@shsmsx102.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_99C214DF91337140A8D774E25DF6CD5FC89DA2shsmsx102ccrcorpi_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "yanmin_zhang@linux.intel.com" <yanmin_zhang@linux.intel.com>, "He, Bo" <bo.he@intel.com>, "Chen, Lin Z" <lin.z.chen@intel.com>

--_000_99C214DF91337140A8D774E25DF6CD5FC89DA2shsmsx102ccrcorpi_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

when kernel uses kmalloc to allocate memory, slub/slab will find
a suitable kmem_cache. Ususally the cache's object size is often
greater than requested size. There is unused space which contains
dirty data. These dirty data might have pointers pointing to a block
of leaked memory. Kernel wouldn't consider this memory as leaked when
scanning kmemleak object.

The patch fixes it by clearing the unused memory.

Signed-off-by: Liu, XinwuX <xinwux.liu@intel.com>
Signed-off-by: Chen Lin Z <lin.z.chen@intel.com>
---
mm/slab.c | 22 +++++++++++++++++++++-
mm/slub.c | 35 +++++++++++++++++++++++++++++++++++
2 files changed, 56 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 7eb38dd..ef25e7d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3423,6 +3423,12 @@ kmem_cache_alloc_trace(struct kmem_cache *cachep, gf=
p_t flags, size_t size)
                ret =3D slab_alloc(cachep, flags, _RET_IP_);
+#ifdef CONFIG_DEBUG_KMEMLEAK
+             int delta =3D cachep->object_size - size;
+
+             if (ret && likely(!(flags & __GFP_ZERO)) && (delta > 0))
+                             memset((void *)((char *)ret + size), 0, delta=
);
+#endif
               trace_kmalloc(_RET_IP_, ret,
                                     size, cachep->size, flags);
               return ret;
@@ -3476,11 +3482,19 @@ static __always_inline void *
__do_kmalloc_node(size_t size, gfp_t flags, int node, unsigned long caller)
{
               struct kmem_cache *cachep;
+             void *ret;
                cachep =3D kmalloc_slab(size, flags);
               if (unlikely(ZERO_OR_NULL_PTR(cachep)))
                               return cachep;
-              return kmem_cache_alloc_node_trace(cachep, flags, node, size=
);
+             ret =3D kmem_cache_alloc_node_trace(cachep, flags, node, size=
);
+#ifdef CONFIG_DEBUG_KMEMLEAK
+             int delta =3D cachep->object_size - size;
+
+             if (ret && likely(!(flags & __GFP_ZERO)) && (delta > 0))
+                             memset((void *)((char *)ret + size), 0, delta=
);
+#endif
+             return ret;
}
 void *__kmalloc_node(size_t size, gfp_t flags, int node)
@@ -3513,6 +3527,12 @@ static __always_inline void *__do_kmalloc(size_t siz=
e, gfp_t flags,
               if (unlikely(ZERO_OR_NULL_PTR(cachep)))
                               return cachep;
               ret =3D slab_alloc(cachep, flags, caller);
+#ifdef CONFIG_DEBUG_KMEMLEAK
+             int delta =3D cachep->object_size - size;
+
+             if (ret && likely(!(flags & __GFP_ZERO)) && (delta > 0))
+                             memset((void *)((char *)ret + size), 0, delta=
);
+#endif
                trace_kmalloc(caller, ret,
                                     size, cachep->size, flags);
diff --git a/mm/slub.c b/mm/slub.c
index 54c0876..b53d9af 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2530,6 +2530,12 @@ EXPORT_SYMBOL(kmem_cache_alloc);
void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t s=
ize)
{
               void *ret =3D slab_alloc(s, gfpflags, _RET_IP_);
+#ifdef CONFIG_DEBUG_KMEMLEAK
+             int delta =3D s->object_size - size;
+
+             if (ret && likely(!(gfpflags & __GFP_ZERO)) && (delta > 0))
+                             memset((void *)((char *)ret + size), 0, delta=
);
+#endif
               trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
               kasan_kmalloc(s, ret, size);
               return ret;
@@ -2556,6 +2562,12 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache =
*s,
{
               void *ret =3D slab_alloc_node(s, gfpflags, node, _RET_IP_);
+#ifdef CONFIG_DEBUG_KMEMLEAK
+             int delta =3D s->object_size - size;
+
+             if (ret && likely(!(gfpflags & __GFP_ZERO)) && (delta > 0))
+                             memset((void *)((char *)ret + size), 0, delta=
);
+#endif
               trace_kmalloc_node(_RET_IP_, ret,
                                                  size, s->size, gfpflags, =
node);
@@ -3316,6 +3328,12 @@ void *__kmalloc(size_t size, gfp_t flags)
                               return s;
                ret =3D slab_alloc(s, flags, _RET_IP_);
+#ifdef CONFIG_DEBUG_KMEMLEAK
+             int delta =3D s->object_size - size;
+
+             if (ret && likely(!(flags & __GFP_ZERO)) && (delta > 0))
+                             memset((void *)((char *)ret + size), 0, delta=
);
+#endif
                trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
@@ -3361,6 +3379,12 @@ void *__kmalloc_node(size_t size, gfp_t flags, int n=
ode)
                               return s;
                ret =3D slab_alloc_node(s, flags, node, _RET_IP_);
+#ifdef CONFIG_DEBUG_KMEMLEAK
+             int delta =3D s->object_size - size;
+
+             if (ret && likely(!(flags & __GFP_ZERO)) && (delta > 0))
+                             memset((void *)((char *)ret + size), 0, delta=
);
+#endif
                trace_kmalloc_node(_RET_IP_, ret, size, s->size, flags, nod=
e);
@@ -3819,7 +3843,12 @@ void *__kmalloc_track_caller(size_t size, gfp_t gfpf=
lags, unsigned long caller)
                               return s;
                ret =3D slab_alloc(s, gfpflags, caller);
+#ifdef CONFIG_DEBUG_KMEMLEAK
+             int delta =3D s->object_size - size;
+             if (ret && likely(!(gfpflags & __GFP_ZERO)) && (delta > 0))
+                             memset((void *)((char *)ret + size), 0, delta=
);
+#endif
               /* Honor the call site pointer we received. */
               trace_kmalloc(caller, ret, size, s->size, gfpflags);
@@ -3849,6 +3878,12 @@ void *__kmalloc_node_track_caller(size_t size, gfp_t=
 gfpflags,
                               return s;
                ret =3D slab_alloc_node(s, gfpflags, node, caller);
+#ifdef CONFIG_DEBUG_KMEMLEAK
+             int delta =3D s->object_size - size;
+
+             if (ret && likely(!(gfpflags & __GFP_ZERO)) && (delta > 0))
+                             memset((void *)((char *)ret + size), 0, delta=
);
+#endif
                /* Honor the call site pointer we received. */
               trace_kmalloc_node(caller, ret, size, s->size, gfpflags, nod=
e);
--
1.9.1

--_000_99C214DF91337140A8D774E25DF6CD5FC89DA2shsmsx102ccrcorpi_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Word 14 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:SimSun;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:SimSun;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:"\@SimSun";
	panose-1:2 1 6 0 3 1 1 1 1 1;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:purple;
	text-decoration:underline;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri","sans-serif";
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-family:"Calibri","sans-serif";}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]-->
</head>
<body lang=3D"EN-US" link=3D"blue" vlink=3D"purple">
<div class=3D"WordSection1">
<p class=3D"MsoNormal">when kernel uses kmalloc to allocate memory, slub/sl=
ab will find<o:p></o:p></p>
<p class=3D"MsoNormal">a suitable kmem_cache. Ususally the cache's object s=
ize is often<o:p></o:p></p>
<p class=3D"MsoNormal">greater than requested size. There&nbsp;is unused sp=
ace which contains<o:p></o:p></p>
<p class=3D"MsoNormal">dirty data. These dirty data might have&nbsp;pointer=
s pointing to&nbsp;a block<o:p></o:p></p>
<p class=3D"MsoNormal">of&nbsp;leaked&nbsp;memory. Kernel wouldn't consider=
 this&nbsp;memory as leaked when<o:p></o:p></p>
<p class=3D"MsoNormal">scanning kmemleak object.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">The patch fixes it by clearing the unused memory.<o:=
p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Signed-off-by: Liu, XinwuX &lt;xinwux.liu@intel.com&=
gt;<o:p></o:p></p>
<p class=3D"MsoNormal">Signed-off-by: Chen Lin Z &lt;lin.z.chen@intel.com&g=
t;<o:p></o:p></p>
<p class=3D"MsoNormal">---<o:p></o:p></p>
<p class=3D"MsoNormal">mm/slab.c | 22 &#43;&#43;&#43;&#43;&#43;&#43;&#43;&#=
43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;-<o:p><=
/o:p></p>
<p class=3D"MsoNormal">mm/slub.c | 35 &#43;&#43;&#43;&#43;&#43;&#43;&#43;&#=
43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#=
43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;&#43;<o:p></o:p><=
/p>
<p class=3D"MsoNormal">2 files changed, 56 insertions(&#43;), 1 deletion(-)=
<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">diff --git a/mm/slab.c b/mm/slab.c<o:p></o:p></p>
<p class=3D"MsoNormal">index 7eb38dd..ef25e7d 100644<o:p></o:p></p>
<p class=3D"MsoNormal">--- a/mm/slab.c<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&#43;&#43; b/mm/slab.c<o:p></o:p></p>
<p class=3D"MsoNormal">@@ -3423,6 &#43;3423,12 @@ kmem_cache_alloc_trace(st=
ruct kmem_cache *cachep, gfp_t flags, size_t size)<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ret =3D slab_alloc(cachep, flags, _R=
ET_IP_);<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#ifdef CONFIG_DEBUG_KMEMLEAK<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; int delta =3D cachep-&gt;object_size - size;<o:p>=
</o:p></p>
<p class=3D"MsoNormal">&#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; if (ret &amp;&amp; likely(!(flags &amp; __GFP_ZER=
O)) &amp;&amp; (delta &gt; 0))<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memset((void *)((char *)ret =
&#43; size), 0, delta);<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#endif<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; trace_kmalloc(_RET_IP_, ret,<o:p></o:p></p=
>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;size, cachep-&gt;size, flags);<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return ret;<o:p></o:p></p>
<p class=3D"MsoNormal">@@ -3476,11 &#43;3482,19 @@ static __always_inline v=
oid *<o:p></o:p></p>
<p class=3D"MsoNormal">__do_kmalloc_node(size_t size, gfp_t flags, int node=
, unsigned long caller)<o:p></o:p></p>
<p class=3D"MsoNormal">{<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct kmem_cache *cachep;<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; void *ret;<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; cachep =3D kmalloc_slab(size, flags)=
;<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (unlikely(ZERO_OR_NULL_PTR(cachep)))<o:=
p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return cachep;<o:p></=
o:p></p>
<p class=3D"MsoNormal">-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp; return kmem_cache_alloc_node_trace(cachep, flag=
s, node, size);<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; ret =3D kmem_cache_alloc_node_trace(cachep, flags=
, node, size);<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#ifdef CONFIG_DEBUG_KMEMLEAK<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; int delta =3D cachep-&gt;object_size - size;<o:p>=
</o:p></p>
<p class=3D"MsoNormal">&#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; if (ret &amp;&amp; likely(!(flags &amp; __GFP_ZER=
O)) &amp;&amp; (delta &gt; 0))<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memset((void *)((char *)ret =
&#43; size), 0, delta);<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#endif<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; return ret;<o:p></o:p></p>
<p class=3D"MsoNormal">}<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;void *__kmalloc_node(size_t size, gfp_t flags,=
 int node)<o:p></o:p></p>
<p class=3D"MsoNormal">@@ -3513,6 &#43;3527,12 @@ static __always_inline vo=
id *__do_kmalloc(size_t size, gfp_t flags,<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (unlikely(ZERO_OR_NULL_PTR(cachep)))<o:=
p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return cachep;<o:p></=
o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ret =3D slab_alloc(cachep, flags, caller);=
<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#ifdef CONFIG_DEBUG_KMEMLEAK<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; int delta =3D cachep-&gt;object_size - size;<o:p>=
</o:p></p>
<p class=3D"MsoNormal">&#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; if (ret &amp;&amp; likely(!(flags &amp; __GFP_ZER=
O)) &amp;&amp; (delta &gt; 0))<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memset((void *)((char *)ret =
&#43; size), 0, delta);<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#endif<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; trace_kmalloc(caller, ret,<o:p></o:p=
></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;size, cachep-&gt;size, flags);<o:p></o:p></p>
<p class=3D"MsoNormal">diff --git a/mm/slub.c b/mm/slub.c<o:p></o:p></p>
<p class=3D"MsoNormal">index 54c0876..b53d9af 100644<o:p></o:p></p>
<p class=3D"MsoNormal">--- a/mm/slub.c<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&#43;&#43; b/mm/slub.c<o:p></o:p></p>
<p class=3D"MsoNormal">@@ -2530,6 &#43;2530,12 @@ EXPORT_SYMBOL(kmem_cache_=
alloc);<o:p></o:p></p>
<p class=3D"MsoNormal">void *kmem_cache_alloc_trace(struct kmem_cache *s, g=
fp_t gfpflags, size_t size)<o:p></o:p></p>
<p class=3D"MsoNormal">{<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; void *ret =3D slab_alloc(s, gfpflags, _RET=
_IP_);<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#ifdef CONFIG_DEBUG_KMEMLEAK<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; int delta =3D s-&gt;object_size - size;<o:p></o:p=
></p>
<p class=3D"MsoNormal">&#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; if (ret &amp;&amp; likely(!(gfpflags &amp; __GFP_=
ZERO)) &amp;&amp; (delta &gt; 0))<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memset((void *)((char *)ret =
&#43; size), 0, delta);<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#endif<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; trace_kmalloc(_RET_IP_, ret, size, s-&gt;s=
ize, gfpflags);<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; kasan_kmalloc(s, ret, size);<o:p></o:p></p=
>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return ret;<o:p></o:p></p>
<p class=3D"MsoNormal">@@ -2556,6 &#43;2562,12 @@ void *kmem_cache_alloc_no=
de_trace(struct kmem_cache *s,<o:p></o:p></p>
<p class=3D"MsoNormal">{<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; void *ret =3D slab_alloc_node(s, gfpflags,=
 node, _RET_IP_);<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#ifdef CONFIG_DEBUG_KMEMLEAK<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; int delta =3D s-&gt;object_size - size;<o:p></o:p=
></p>
<p class=3D"MsoNormal">&#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; if (ret &amp;&amp; likely(!(gfpflags &amp; __GFP_=
ZERO)) &amp;&amp; (delta &gt; 0))<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memset((void *)((char *)ret =
&#43; size), 0, delta);<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#endif<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; trace_kmalloc_node(_RET_IP_, ret,<o:p></o:=
p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;size, s-&gt;size, gfpflags, node);<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">@@ -3316,6 &#43;3328,12 @@ void *__kmalloc(size_t si=
ze, gfp_t flags)<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return s;<o:p></o:p><=
/p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ret =3D slab_alloc(s, flags, _RET_IP=
_);<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#ifdef CONFIG_DEBUG_KMEMLEAK<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; int delta =3D s-&gt;object_size - size;<o:p></o:p=
></p>
<p class=3D"MsoNormal">&#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; if (ret &amp;&amp; likely(!(flags &amp; __GFP_ZER=
O)) &amp;&amp; (delta &gt; 0))<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memset((void *)((char *)ret =
&#43; size), 0, delta);<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#endif<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; trace_kmalloc(_RET_IP_, ret, size, s=
-&gt;size, flags);<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">@@ -3361,6 &#43;3379,12 @@ void *__kmalloc_node(size=
_t size, gfp_t flags, int node)<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return s;<o:p></o:p><=
/p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ret =3D slab_alloc_node(s, flags, no=
de, _RET_IP_);<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#ifdef CONFIG_DEBUG_KMEMLEAK<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; int delta =3D s-&gt;object_size - size;<o:p></o:p=
></p>
<p class=3D"MsoNormal">&#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; if (ret &amp;&amp; likely(!(flags &amp; __GFP_ZER=
O)) &amp;&amp; (delta &gt; 0))<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memset((void *)((char *)ret =
&#43; size), 0, delta);<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#endif<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; trace_kmalloc_node(_RET_IP_, ret, si=
ze, s-&gt;size, flags, node);<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">@@ -3819,7 &#43;3843,12 @@ void *__kmalloc_track_cal=
ler(size_t size, gfp_t gfpflags, unsigned long caller)<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return s;<o:p></o:p><=
/p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ret =3D slab_alloc(s, gfpflags, call=
er);<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#ifdef CONFIG_DEBUG_KMEMLEAK<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; int delta =3D s-&gt;object_size - size;<o:p></o:p=
></p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; if (ret &amp;&amp; likely(!(gfpflags &amp; __GFP_=
ZERO)) &amp;&amp; (delta &gt; 0))<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memset((void *)((char *)ret =
&#43; size), 0, delta);<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#endif<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* Honor the call site pointer we received=
. */<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; trace_kmalloc(caller, ret, size, s-&gt;siz=
e, gfpflags);<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">@@ -3849,6 &#43;3878,12 @@ void *__kmalloc_node_trac=
k_caller(size_t size, gfp_t gfpflags,<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return s;<o:p></o:p><=
/p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ret =3D slab_alloc_node(s, gfpflags,=
 node, caller);<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#ifdef CONFIG_DEBUG_KMEMLEAK<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; int delta =3D s-&gt;object_size - size;<o:p></o:p=
></p>
<p class=3D"MsoNormal">&#43;<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; if (ret &amp;&amp; likely(!(gfpflags &amp; __GFP_=
ZERO)) &amp;&amp; (delta &gt; 0))<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memset((void *)((char *)ret =
&#43; size), 0, delta);<o:p></o:p></p>
<p class=3D"MsoNormal">&#43;#endif<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* Honor the call site pointer we re=
ceived. */<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; trace_kmalloc_node(caller, ret, size, s-&g=
t;size, gfpflags, node);<o:p></o:p></p>
<p class=3D"MsoNormal">-- <o:p></o:p></p>
<p class=3D"MsoNormal">1.9.1<o:p></o:p></p>
</div>
</body>
</html>

--_000_99C214DF91337140A8D774E25DF6CD5FC89DA2shsmsx102ccrcorpi_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
