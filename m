Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id A09406B0044
	for <linux-mm@kvack.org>; Mon, 24 Dec 2012 19:55:33 -0500 (EST)
Received: by mail-vc0-f200.google.com with SMTP id f13so11001093vcb.3
        for <linux-mm@kvack.org>; Mon, 24 Dec 2012 16:55:21 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 24 Dec 2012 16:55:21 -0800
Message-ID: <CAAvDA15U=KCOujRYA5k3YkvC9Z=E6fcG5hopPUJNgULYj_MAJw@mail.gmail.com>
Subject: BUG: slub creates kmalloc slabs with refcount=0
From: Paul Hargrove <phhargrove@lbl.gov>
Content-Type: multipart/alternative; boundary=bcaec54fbbb8adeb8604d1a2c47c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--bcaec54fbbb8adeb8604d1a2c47c
Content-Type: text/plain; charset=ISO-8859-1

I have a 3.7.1 kernel on x86-86
It is configured with
  CONFIG_SLUB=y
  CONFIG_SLUB_DEBUG=y

I have an out-of-tree module calling KMEM_CACHE for an 8-byte struct:
        cr_pdata_cachep = KMEM_CACHE(cr_pdata_s,0);
        if (!cr_pdata_cachep) goto no_pdata_cachep;
        printk(KERN_ERR "@ refcount = %d name = '%s'\n",
cr_pdata_cachep->refcount, cr_pdata_cachep->name);

The output of the printk, below, shows that the request has been merged
with the built-in 8-byte kmalloc pool, BUT the resulting refcount is 1,
rather than 2 (or more):
    @ refcount = 1 name = 'kmalloc-8'

This results in a very unhappy kernel when the module calls
    kmem_cache_destroy(cr_pdata_cachep);
at rmmod time, resulting is messages like
    BUG kmalloc-8 (Tainted: G           O): Objects remaining in kmalloc-96
on kmem_cache_close()

A quick look through mm/slub.c appears to confirm my suspicion that
"s->refcount" is never incremented for the built-in kmalloc-* caches.
 However, I leave it to the experts to determine where the increment
belongs.

FWIW: I am currently passing SLAB_POISON for the flags argument to
KMEM_CACHE() as a work-around (it prevents merging and, if I understand
correctly, has no overhead in a non-debug build).

-Paul

-- 
Paul H. Hargrove                          PHHargrove@lbl.gov
Future Technologies Group
Computer and Data Sciences Department     Tel: +1-510-495-2352
Lawrence Berkeley National Laboratory     Fax: +1-510-486-6900

--bcaec54fbbb8adeb8604d1a2c47c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><br></div>I have a 3.7.1 kernel on x86-86<div>It is c=
onfigured with</div><div style>=A0 CONFIG_SLUB=3Dy</div><div style>=A0 CONF=
IG_SLUB_DEBUG=3Dy</div><div style><br></div><div style>I have an out-of-tre=
e module calling KMEM_CACHE for an 8-byte struct:</div>
<div style><div>=A0 =A0 =A0 =A0 cr_pdata_cachep =3D KMEM_CACHE(cr_pdata_s,0=
);</div><div>=A0 =A0 =A0 =A0 if (!cr_pdata_cachep) goto no_pdata_cachep;</d=
iv><div>=A0 =A0 =A0 =A0 printk(KERN_ERR &quot;@ refcount =3D %d name =3D &#=
39;%s&#39;\n&quot;, cr_pdata_cachep-&gt;refcount, cr_pdata_cachep-&gt;name)=
;=A0</div>
<div><br></div><div style>The output of the printk, below, shows that the r=
equest has been merged with the built-in 8-byte kmalloc pool, BUT the resul=
ting refcount is 1, rather than 2 (or more): =A0</div></div><div style>=A0 =
=A0 @ refcount =3D 1 name =3D &#39;kmalloc-8&#39;<br>
</div><div><div><br></div><div style>This results in a very unhappy kernel =
when the module calls</div><div style>=A0=A0 =A0kmem_cache_destroy(cr_pdata=
_cachep);</div><div style>at rmmod time, resulting is messages like</div><d=
iv style>
=A0 =A0=A0BUG kmalloc-8 (Tainted: G =A0 =A0 =A0 =A0 =A0 O): Objects remaini=
ng in kmalloc-96 on kmem_cache_close()</div><div style><br></div><div style=
>A quick look through mm/slub.c appears to confirm my=A0suspicion=A0that &q=
uot;s-&gt;refcount&quot; is never incremented for the built-in kmalloc-* ca=
ches. =A0However, I leave it to the experts to determine where the incremen=
t belongs.</div>
<div style><br></div><div style>FWIW: I am currently passing SLAB_POISON fo=
r the flags argument to KMEM_CACHE() as a work-around (it prevents merging =
and, if I understand correctly, has no overhead in a non-debug build).</div=
>
<div style><br></div><div style>-Paul</div><div style><br></div>-- <br><fon=
t face=3D"courier new, monospace"><div>Paul H. Hargrove =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0<a href=3D"mailto:PHHargrove@lbl.gov" targe=
t=3D"_blank">PHHargrove@lbl.gov</a></div>
<div>Future Technologies Group</div><div>Computer and Data Sciences Departm=
ent =A0 =A0 Tel: +1-510-495-2352</div><div>Lawrence Berkeley National Labor=
atory =A0 =A0 Fax: +1-510-486-6900</div></font>
</div></div>

--bcaec54fbbb8adeb8604d1a2c47c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
