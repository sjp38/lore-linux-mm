Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 7CE986B0069
	for <linux-mm@kvack.org>; Sun, 16 Sep 2012 06:14:51 -0400 (EDT)
Received: by qady1 with SMTP id y1so1063241qad.14
        for <linux-mm@kvack.org>; Sun, 16 Sep 2012 03:14:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120914131428.1f530681.akpm@linux-foundation.org>
References: <5052A7DF.4050301@gmail.com>
	<50530E39.5020100@jp.fujitsu.com>
	<20120914131428.1f530681.akpm@linux-foundation.org>
Date: Sun, 16 Sep 2012 18:14:50 +0800
Message-ID: <CAPSa4Adgsyekq__EVmiwTZU_2NPY+LxsnFOmEvnkt0XvuWtuKw@mail.gmail.com>
Subject: Re: [PATCH RESEND] memory hotplug: fix a double register section info bug
From: xishi qiu <qiuxishi@gmail.com>
Content-Type: multipart/alternative; boundary=0022158c0d1168e5a904c9ceed34
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, mgorman@suse.de, tony.luck@intel.com, Jiang Liu <jiang.liu@huawei.com>, qiuxishi@huawei.com, bessel.wang@huawei.com, wujianguo@huawei.com, paul.gortmaker@windriver.com, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, rientjes@google.com, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wen Congyang <wency@cn.fujitsu.com>

--0022158c0d1168e5a904c9ceed34
Content-Type: text/plain; charset=UTF-8

On Sat, Sep 15, 2012 at 4:14 AM, Andrew Morton <akpm@linux-foundation.org>wrote:

> On Fri, 14 Sep 2012 20:00:09 +0900
> Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> wrote:
>
> > > @@ -187,9 +184,10 @@ void register_page_bootmem_info_node(struct
> pglist_data *pgdat)
> > >     end_pfn = pfn + pgdat->node_spanned_pages;
> > >
> > >     /* register_section info */
> > > -   for (; pfn < end_pfn; pfn += PAGES_PER_SECTION)
> > > -           register_page_bootmem_info_section(pfn);
> > > -
> > > +   for (; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
> > > +           if (pfn_valid(pfn) && (pfn_to_nid(pfn) == node))
> >
> > I cannot judge whether your configuration is correct or not.
> > Thus if it is correct, I want a comment of why the node check is
> > needed. In usual configuration, a node does not span the other one.
> > So it is natural that "pfn_to_nid(pfn) is same as "pgdat->node_id".
> > Thus we may remove the node check in the future.
>
>

yup.  How does this look?
>

It looks fine to me. Some platforms can have this unusual  configuration,
not only in IA64.
And register_page_bootmem_info_section() is only called by
register_page_bootmem_info_node(),
so we can delete pfn_valid() check in register_page_bootmem_info_section()

Thanks
Xishi Qiu


> ---
> a/mm/memory_hotplug.c~memory-hotplug-fix-a-double-register-section-info-bug-fix
> +++ a/mm/memory_hotplug.c
> @@ -185,6 +185,12 @@ void register_page_bootmem_info_node(str
>
>         /* register_section info */
>         for (; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
> +               /*
> +                * Some platforms can assign the same pfn to multiple
> nodes - on
> +                * node0 as well as nodeN.  To avoid registering a pfn
> against
> +                * multiple nodes we check that this pfn does not already
> +                * reside in some other node.
> +                */
>                 if (pfn_valid(pfn) && (pfn_to_nid(pfn) == node))
>                         register_page_bootmem_info_section(pfn);
>         }
> _
>
>

--0022158c0d1168e5a904c9ceed34
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Sat, Sep 15, 2012 at 4:14 AM, Andrew =
Morton <span dir=3D"ltr">&lt;<a href=3D"mailto:akpm@linux-foundation.org" t=
arget=3D"_blank">akpm@linux-foundation.org</a>&gt;</span> wrote:<br><blockq=
uote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc =
solid;padding-left:1ex">



<div>On Fri, 14 Sep 2012 20:00:09 +0900<br>
Yasuaki Ishimatsu &lt;<a href=3D"mailto:isimatu.yasuaki@jp.fujitsu.com" tar=
get=3D"_blank">isimatu.yasuaki@jp.fujitsu.com</a>&gt; wrote:<br>
<br>
&gt; &gt; @@ -187,9 +184,10 @@ void register_page_bootmem_info_node(struct =
pglist_data *pgdat)<br>
&gt; &gt; =C2=A0 =C2=A0 end_pfn =3D pfn + pgdat-&gt;node_spanned_pages;<br>
&gt; &gt;<br>
&gt; &gt; =C2=A0 =C2=A0 /* register_section info */<br>
&gt; &gt; - =C2=A0 for (; pfn &lt; end_pfn; pfn +=3D PAGES_PER_SECTION)<br>
&gt; &gt; - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 register_page_bootmem_info_s=
ection(pfn);<br>
&gt; &gt; -<br>
&gt; &gt; + =C2=A0 for (; pfn &lt; end_pfn; pfn +=3D PAGES_PER_SECTION) {<b=
r>
&gt; &gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (pfn_valid(pfn) &amp;&amp=
; (pfn_to_nid(pfn) =3D=3D node))<br>
&gt;<br>
&gt; I cannot judge whether your configuration is correct or not.<br>
&gt; Thus if it is correct, I want a comment of why the node check is<br>
&gt; needed. In usual configuration, a node does not span the other one.<br=
>
&gt; So it is natural that &quot;pfn_to_nid(pfn) is same as &quot;pgdat-&gt=
;node_id&quot;.<br>
&gt; Thus we may remove the node check in the future.<br>
<br>
</div>=C2=A0</blockquote><blockquote class=3D"gmail_quote" style=3D"margin:=
0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">yup. =C2=A0How does=
 this look?<br></blockquote><div><br></div><div>It looks fine to me.=C2=A0S=
ome platforms can have this unusual=C2=A0 configuration, not only in IA64.<=
/div>


<div>And=C2=A0register_page_bootmem_info_section() is only called by regist=
er_page_bootmem_info_node(),</div><div>so we can delete pfn_valid() check i=
n register_page_bootmem_info_section()<br>=C2=A0          =C2=A0<br></div><=
div>Thanks=C2=A0</div>
<div>
Xishi Qiu</div><div><br></div><blockquote class=3D"gmail_quote" style=3D"ma=
rgin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">

<br>
--- a/mm/memory_hotplug.c~memory-hotplug-fix-a-double-register-section-info=
-bug-fix<br>
+++ a/mm/memory_hotplug.c<br>
@@ -185,6 +185,12 @@ void register_page_bootmem_info_node(str<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* register_section info */<br>
<div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 for (; pfn &lt; end_pfn; pfn +=3D PAGES_PE=
R_SECTION) {<br>
</div>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Some platforms c=
an assign the same pfn to multiple nodes - on<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* node0 as well as=
 nodeN. =C2=A0To avoid registering a pfn against<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* multiple nodes w=
e check that this pfn does not already<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* reside in some o=
ther node.<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
<div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (pfn_valid(=
pfn) &amp;&amp; (pfn_to_nid(pfn) =3D=3D node))<br>
</div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 register_page_bootmem_info_section(pfn);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
_<br>
<br>
</blockquote></div><br>

--0022158c0d1168e5a904c9ceed34--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
