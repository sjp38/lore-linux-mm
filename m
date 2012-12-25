Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 3729B8D0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2012 20:19:02 -0500 (EST)
Received: by mail-vc0-f199.google.com with SMTP id p16so11013563vcq.10
        for <linux-mm@kvack.org>; Mon, 24 Dec 2012 17:18:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAvDA15U=KCOujRYA5k3YkvC9Z=E6fcG5hopPUJNgULYj_MAJw@mail.gmail.com>
References: <CAAvDA15U=KCOujRYA5k3YkvC9Z=E6fcG5hopPUJNgULYj_MAJw@mail.gmail.com>
Date: Mon, 24 Dec 2012 17:18:20 -0800
Message-ID: <CAAvDA146NaWMpgZtMrDv-iFJfTF2DbGz9hHWnx9j_vC9heHjrw@mail.gmail.com>
Subject: Re: BUG: slub creates kmalloc slabs with refcount=0
From: Paul Hargrove <phhargrove@lbl.gov>
Content-Type: multipart/alternative; boundary=20cf307c9d64db9afa04d1a316af
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--20cf307c9d64db9afa04d1a316af
Content-Type: text/plain; charset=ISO-8859-1

Just to be clear the "BUG...." line I quoted contains an error of my own.

It should say "kmalloc-8" twice rather than having "kmalloc-96" toward the
end.  This is the result of a cut-and-paste error (and brain already on
vacation).  The module ALSO has a larger struct the cache for which gets
merged with the kmalloc-96 cache.  I grabbed the first BUG line from the
dmesg output and replaced "96" with "8" when composing the email, but
missed the second occurrence.

Merry Christmas,
-Paul


On Mon, Dec 24, 2012 at 4:55 PM, Paul Hargrove <phhargrove@lbl.gov> wrote:

>
> I have a 3.7.1 kernel on x86-86
> It is configured with
>   CONFIG_SLUB=y
>   CONFIG_SLUB_DEBUG=y
>
> I have an out-of-tree module calling KMEM_CACHE for an 8-byte struct:
>         cr_pdata_cachep = KMEM_CACHE(cr_pdata_s,0);
>         if (!cr_pdata_cachep) goto no_pdata_cachep;
>         printk(KERN_ERR "@ refcount = %d name = '%s'\n",
> cr_pdata_cachep->refcount, cr_pdata_cachep->name);
>
> The output of the printk, below, shows that the request has been merged
> with the built-in 8-byte kmalloc pool, BUT the resulting refcount is 1,
> rather than 2 (or more):
>     @ refcount = 1 name = 'kmalloc-8'
>
> This results in a very unhappy kernel when the module calls
>     kmem_cache_destroy(cr_pdata_cachep);
> at rmmod time, resulting is messages like
>     BUG kmalloc-8 (Tainted: G           O): Objects remaining in
> kmalloc-96 on kmem_cache_close()
>
> A quick look through mm/slub.c appears to confirm my suspicion that
> "s->refcount" is never incremented for the built-in kmalloc-* caches.
>  However, I leave it to the experts to determine where the increment
> belongs.
>
> FWIW: I am currently passing SLAB_POISON for the flags argument to
> KMEM_CACHE() as a work-around (it prevents merging and, if I understand
> correctly, has no overhead in a non-debug build).
>
> -Paul
>
> --
> Paul H. Hargrove                          PHHargrove@lbl.gov
> Future Technologies Group
> Computer and Data Sciences Department     Tel: +1-510-495-2352
> Lawrence Berkeley National Laboratory     Fax: +1-510-486-6900
>



-- 
Paul H. Hargrove                          PHHargrove@lbl.gov
Future Technologies Group
Computer and Data Sciences Department     Tel: +1-510-495-2352
Lawrence Berkeley National Laboratory     Fax: +1-510-486-6900

--20cf307c9d64db9afa04d1a316af
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Just to be clear the &quot;BUG....&quot; line I quoted con=
tains an error of my own.<div><br><div>It should say &quot;kmalloc-8&quot; =
twice rather than having &quot;kmalloc-96&quot; toward the end. =A0This is =
the result of a cut-and-paste error (and brain already on vacation). =A0The=
 module ALSO has a larger struct the cache for which gets merged with the k=
malloc-96 cache. =A0I grabbed the first BUG line from the dmesg output and =
replaced &quot;96&quot; with &quot;8&quot; when composing the email, but mi=
ssed the second=A0occurrence.<div>
<br></div><div style>Merry Christmas,</div><div><div>-Paul</div></div></div=
></div></div><div class=3D"gmail_extra"><br><br><div class=3D"gmail_quote">=
On Mon, Dec 24, 2012 at 4:55 PM, Paul Hargrove <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:phhargrove@lbl.gov" target=3D"_blank">phhargrove@lbl.gov</a>&gt=
;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div dir=3D"ltr"><div><br></div>I have a 3.7=
.1 kernel on x86-86<div>It is configured with</div><div>=A0 CONFIG_SLUB=3Dy=
</div>
<div>=A0 CONFIG_SLUB_DEBUG=3Dy</div><div><br></div><div>I have an out-of-tr=
ee module calling KMEM_CACHE for an 8-byte struct:</div>
<div><div>=A0 =A0 =A0 =A0 cr_pdata_cachep =3D KMEM_CACHE(cr_pdata_s,0);</di=
v><div>=A0 =A0 =A0 =A0 if (!cr_pdata_cachep) goto no_pdata_cachep;</div><di=
v>=A0 =A0 =A0 =A0 printk(KERN_ERR &quot;@ refcount =3D %d name =3D &#39;%s&=
#39;\n&quot;, cr_pdata_cachep-&gt;refcount, cr_pdata_cachep-&gt;name);=A0</=
div>

<div><br></div><div>The output of the printk, below, shows that the request=
 has been merged with the built-in 8-byte kmalloc pool, BUT the resulting r=
efcount is 1, rather than 2 (or more): =A0</div></div><div>=A0 =A0 @ refcou=
nt =3D 1 name =3D &#39;kmalloc-8&#39;<br>

</div><div><div><br></div><div>This results in a very unhappy kernel when t=
he module calls</div><div>=A0=A0 =A0kmem_cache_destroy(cr_pdata_cachep);</d=
iv><div>at rmmod time, resulting is messages like</div><div>
=A0 =A0=A0BUG kmalloc-8 (Tainted: G =A0 =A0 =A0 =A0 =A0 O): Objects remaini=
ng in kmalloc-96 on kmem_cache_close()</div><div><br></div><div>A quick loo=
k through mm/slub.c appears to confirm my=A0suspicion=A0that &quot;s-&gt;re=
fcount&quot; is never incremented for the built-in kmalloc-* caches. =A0How=
ever, I leave it to the experts to determine where the increment belongs.</=
div>

<div><br></div><div>FWIW: I am currently passing SLAB_POISON for the flags =
argument to KMEM_CACHE() as a work-around (it prevents merging and, if I un=
derstand correctly, has no overhead in a non-debug build).</div><span class=
=3D"HOEnZb"><font color=3D"#888888">
<div><br></div><div>-Paul</div><div><br></div>-- <br><font face=3D"courier =
new, monospace"><div>Paul H. Hargrove =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0<a href=3D"mailto:PHHargrove@lbl.gov" target=3D"_blank">PHHa=
rgrove@lbl.gov</a></div>
<div>Future Technologies Group</div><div>Computer and Data Sciences Departm=
ent =A0 =A0 Tel: <a href=3D"tel:%2B1-510-495-2352" value=3D"+15104952352" t=
arget=3D"_blank">+1-510-495-2352</a></div><div>Lawrence Berkeley National L=
aboratory =A0 =A0 Fax: <a href=3D"tel:%2B1-510-486-6900" value=3D"+15104866=
900" target=3D"_blank">+1-510-486-6900</a></div>
</font>
</font></span></div></div>
</blockquote></div><br><br clear=3D"all"><div><br></div>-- <br><font face=
=3D"courier new, monospace"><div>Paul H. Hargrove =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0<a href=3D"mailto:PHHargrove@lbl.gov" target=3D"=
_blank">PHHargrove@lbl.gov</a></div>
<div>Future Technologies Group</div><div>Computer and Data Sciences Departm=
ent =A0 =A0 Tel: +1-510-495-2352</div><div>Lawrence Berkeley National Labor=
atory =A0 =A0 Fax: +1-510-486-6900</div></font>
</div>

--20cf307c9d64db9afa04d1a316af--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
