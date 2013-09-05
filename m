Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 089276B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 17:53:45 -0400 (EDT)
Received: by mail-vb0-f48.google.com with SMTP id w16so1607476vbf.35
        for <linux-mm@kvack.org>; Thu, 05 Sep 2013 14:53:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1375582645-29274-4-git-send-email-kirill.shutemov@linux.intel.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1375582645-29274-4-git-send-email-kirill.shutemov@linux.intel.com>
From: Ning Qu <quning@google.com>
Date: Thu, 5 Sep 2013 14:53:24 -0700
Message-ID: <CACz4_2fJPngXwijEQcmVYB67u_4QDDJkpiyCv4K0iCFdmPsDuA@mail.gmail.com>
Subject: Re: [PATCH 03/23] thp: compile-time and sysfs knob for thp pagecache
Content-Type: multipart/alternative; boundary=001a11c2c158ba3eed04e5a9f455
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

--001a11c2c158ba3eed04e5a9f455
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

One minor question inline.

Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Sat, Aug 3, 2013 at 7:17 PM, Kirill A. Shutemov <
kirill.shutemov@linux.intel.com> wrote:

> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
> For now, TRANSPARENT_HUGEPAGE_PAGECACHE is only implemented for x86_64.
>
> Radix tree perload overhead can be significant on BASE_SMALL systems, so
> let's add dependency on !BASE_SMALL.
>
> /sys/kernel/mm/transparent_hugepage/page_cache is runtime knob for the
> feature. It's enabled by default if TRANSPARENT_HUGEPAGE_PAGECACHE is
> enabled.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  Documentation/vm/transhuge.txt |  9 +++++++++
>  include/linux/huge_mm.h        |  9 +++++++++
>  mm/Kconfig                     | 12 ++++++++++++
>  mm/huge_memory.c               | 23 +++++++++++++++++++++++
>  4 files changed, 53 insertions(+)
>
> diff --git a/Documentation/vm/transhuge.txt
> b/Documentation/vm/transhuge.txt
> index 4a63953..4cc15c4 100644
> --- a/Documentation/vm/transhuge.txt
> +++ b/Documentation/vm/transhuge.txt
> @@ -103,6 +103,15 @@ echo always
> >/sys/kernel/mm/transparent_hugepage/enabled
>  echo madvise >/sys/kernel/mm/transparent_hugepage/enabled
>  echo never >/sys/kernel/mm/transparent_hugepage/enabled
>
> +If TRANSPARENT_HUGEPAGE_PAGECACHE is enabled kernel will use huge pages =
in
> +page cache if possible. It can be disable and re-enabled via sysfs:
> +
> +echo 0 >/sys/kernel/mm/transparent_hugepage/page_cache
> +echo 1 >/sys/kernel/mm/transparent_hugepage/page_cache
> +
> +If it's disabled kernel will not add new huge pages to page cache and
> +split them on mapping, but already mapped pages will stay intakt.
> +
>  It's also possible to limit defrag efforts in the VM to generate
>  hugepages in case they're not immediately free to madvise regions or
>  to never try to defrag memory and simply fallback to regular pages
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 3935428..1534e1e 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -40,6 +40,7 @@ enum transparent_hugepage_flag {
>         TRANSPARENT_HUGEPAGE_DEFRAG_FLAG,
>         TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
>         TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG,
> +       TRANSPARENT_HUGEPAGE_PAGECACHE,
>         TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG,
>  #ifdef CONFIG_DEBUG_VM
>         TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG,
> @@ -229,4 +230,12 @@ static inline int do_huge_pmd_numa_page(struct
> mm_struct *mm, struct vm_area_str
>
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>
> +static inline bool transparent_hugepage_pagecache(void)
> +{
> +       if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE))
> +               return false;
> +       if (!(transparent_hugepage_flags & (1<<TRANSPARENT_HUGEPAGE_FLAG)=
))
>

Here, I suppose we should test the  TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG as
well? E.g.
        if (!(transparent_hugepage_flags &
              ((1<<TRANSPARENT_HUGEPAGE_FLAG) |
               (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG))))

+               return false;
> +       return transparent_hugepage_flags &
> (1<<TRANSPARENT_HUGEPAGE_PAGECACHE);
> +}
>  #endif /* _LINUX_HUGE_MM_H */
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 256bfd0..1e30ee8 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -420,6 +420,18 @@ choice
>           benefit.
>  endchoice
>
> +config TRANSPARENT_HUGEPAGE_PAGECACHE
> +       bool "Transparent Hugepage Support for page cache"
> +       depends on X86_64 && TRANSPARENT_HUGEPAGE
> +       # avoid radix tree preload overhead
> +       depends on !BASE_SMALL
> +       default y
> +       help
> +         Enabling the option adds support hugepages for file-backed
> +         mappings. It requires transparent hugepage support from
> +         filesystem side. For now, the only filesystem which supports
> +         hugepages is ramfs.
> +
>  config CROSS_MEMORY_ATTACH
>         bool "Cross Memory Support"
>         depends on MMU
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index d96d921..523946c 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -42,6 +42,9 @@ unsigned long transparent_hugepage_flags __read_mostly =
=3D
>  #endif
>         (1<<TRANSPARENT_HUGEPAGE_DEFRAG_FLAG)|
>         (1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG)|
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
> +       (1<<TRANSPARENT_HUGEPAGE_PAGECACHE)|
> +#endif
>         (1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
>
>  /* default scan 8*512 pte (or vmas) every 30 second */
> @@ -362,6 +365,23 @@ static ssize_t defrag_store(struct kobject *kobj,
>  static struct kobj_attribute defrag_attr =3D
>         __ATTR(defrag, 0644, defrag_show, defrag_store);
>
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
> +static ssize_t page_cache_show(struct kobject *kobj,
> +               struct kobj_attribute *attr, char *buf)
> +{
> +       return single_flag_show(kobj, attr, buf,
> +                               TRANSPARENT_HUGEPAGE_PAGECACHE);
> +}
> +static ssize_t page_cache_store(struct kobject *kobj,
> +               struct kobj_attribute *attr, const char *buf, size_t coun=
t)
> +{
> +       return single_flag_store(kobj, attr, buf, count,
> +                                TRANSPARENT_HUGEPAGE_PAGECACHE);
> +}
> +static struct kobj_attribute page_cache_attr =3D
> +       __ATTR(page_cache, 0644, page_cache_show, page_cache_store);
> +#endif
> +
>  static ssize_t use_zero_page_show(struct kobject *kobj,
>                 struct kobj_attribute *attr, char *buf)
>  {
> @@ -397,6 +417,9 @@ static struct kobj_attribute debug_cow_attr =3D
>  static struct attribute *hugepage_attr[] =3D {
>         &enabled_attr.attr,
>         &defrag_attr.attr,
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
> +       &page_cache_attr.attr,
> +#endif
>         &use_zero_page_attr.attr,
>  #ifdef CONFIG_DEBUG_VM
>         &debug_cow_attr.attr,
> --
> 1.8.3.2
>
>

--001a11c2c158ba3eed04e5a9f455
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">One minor question inline.<br><div class=3D"gmail_extra"><=
br clear=3D"all"><div><div><div>Best wishes,<br></div><div><span style=3D"b=
order-collapse:collapse;font-family:arial,sans-serif;font-size:13px">--=C2=
=A0<br><span style=3D"border-collapse:collapse;font-family:sans-serif;line-=
height:19px"><span style=3D"border-width:2px 0px 0px;border-style:solid;bor=
der-color:rgb(213,15,37);padding-top:2px;margin-top:2px">Ning Qu (=E6=9B=B2=
=E5=AE=81)<font color=3D"#555555">=C2=A0|</font></span><span style=3D"color=
:rgb(85,85,85);border-width:2px 0px 0px;border-style:solid;border-color:rgb=
(51,105,232);padding-top:2px;margin-top:2px">=C2=A0Software Engineer |</spa=
n><span style=3D"color:rgb(85,85,85);border-width:2px 0px 0px;border-style:=
solid;border-color:rgb(0,153,57);padding-top:2px;margin-top:2px">=C2=A0<a h=
ref=3D"mailto:quning@google.com" style=3D"color:rgb(0,0,204)" target=3D"_bl=
ank">quning@google.com</a>=C2=A0|</span><span style=3D"color:rgb(85,85,85);=
border-width:2px 0px 0px;border-style:solid;border-color:rgb(238,178,17);pa=
dding-top:2px;margin-top:2px">=C2=A0<a value=3D"+16502143877" style=3D"colo=
r:rgb(0,0,204)">+1-408-418-6066</a></span></span></span></div>

</div></div>
<br><br><div class=3D"gmail_quote">On Sat, Aug 3, 2013 at 7:17 PM, Kirill A=
. Shutemov <span dir=3D"ltr">&lt;<a href=3D"mailto:kirill.shutemov@linux.in=
tel.com" target=3D"_blank">kirill.shutemov@linux.intel.com</a>&gt;</span> w=
rote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">From: &quot;Kirill A. Shutemov&quot; &lt;<a href=3D"mailto=
:kirill.shutemov@linux.intel.com">kirill.shutemov@linux.intel.com</a>&gt;<b=
r>


<br>
For now, TRANSPARENT_HUGEPAGE_PAGECACHE is only implemented for x86_64.<br>
<br>
Radix tree perload overhead can be significant on BASE_SMALL systems, so<br=
>
let&#39;s add dependency on !BASE_SMALL.<br>
<br>
/sys/kernel/mm/transparent_hugepage/page_cache is runtime knob for the<br>
feature. It&#39;s enabled by default if TRANSPARENT_HUGEPAGE_PAGECACHE is<b=
r>
enabled.<br>
<br>
Signed-off-by: Kirill A. Shutemov &lt;<a href=3D"mailto:kirill.shutemov@lin=
ux.intel.com">kirill.shutemov@linux.intel.com</a>&gt;<br>
---<br>
=C2=A0Documentation/vm/transhuge.txt | =C2=A09 +++++++++<br>
=C2=A0include/linux/huge_mm.h =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A09 ++++++++=
+<br>
=C2=A0mm/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 | 12 ++++++++++++<br>
=C2=A0mm/huge_memory.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 2=
3 +++++++++++++++++++++++<br>
=C2=A04 files changed, 53 insertions(+)<br>
<br>
diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.tx=
t<br>
index 4a63953..4cc15c4 100644<br>
--- a/Documentation/vm/transhuge.txt<br>
+++ b/Documentation/vm/transhuge.txt<br>
@@ -103,6 +103,15 @@ echo always &gt;/sys/kernel/mm/transparent_hugepage/en=
abled<br>
=C2=A0echo madvise &gt;/sys/kernel/mm/transparent_hugepage/enabled<br>
=C2=A0echo never &gt;/sys/kernel/mm/transparent_hugepage/enabled<br>
<br>
+If TRANSPARENT_HUGEPAGE_PAGECACHE is enabled kernel will use huge pages in=
<br>
+page cache if possible. It can be disable and re-enabled via sysfs:<br>
+<br>
+echo 0 &gt;/sys/kernel/mm/transparent_hugepage/page_cache<br>
+echo 1 &gt;/sys/kernel/mm/transparent_hugepage/page_cache<br>
+<br>
+If it&#39;s disabled kernel will not add new huge pages to page cache and<=
br>
+split them on mapping, but already mapped pages will stay intakt.<br>
+<br>
=C2=A0It&#39;s also possible to limit defrag efforts in the VM to generate<=
br>
=C2=A0hugepages in case they&#39;re not immediately free to madvise regions=
 or<br>
=C2=A0to never try to defrag memory and simply fallback to regular pages<br=
>
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h<br>
index 3935428..1534e1e 100644<br>
--- a/include/linux/huge_mm.h<br>
+++ b/include/linux/huge_mm.h<br>
@@ -40,6 +40,7 @@ enum transparent_hugepage_flag {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 TRANSPARENT_HUGEPAGE_DEFRAG_FLAG,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG,<br=
>
+ =C2=A0 =C2=A0 =C2=A0 TRANSPARENT_HUGEPAGE_PAGECACHE,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG,<br>
=C2=A0#ifdef CONFIG_DEBUG_VM<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG,<br>
@@ -229,4 +230,12 @@ static inline int do_huge_pmd_numa_page(struct mm_stru=
ct *mm, struct vm_area_str<br>
<br>
=C2=A0#endif /* CONFIG_TRANSPARENT_HUGEPAGE */<br>
<br>
+static inline bool transparent_hugepage_pagecache(void)<br>
+{<br>
+ =C2=A0 =C2=A0 =C2=A0 if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACH=
E))<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;<br>
+ =C2=A0 =C2=A0 =C2=A0 if (!(transparent_hugepage_flags &amp; (1&lt;&lt;TRA=
NSPARENT_HUGEPAGE_FLAG)))<br></blockquote><div><br></div><div>Here, I suppo=
se we should test the =C2=A0TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG as well? E.g=
.</div><div><div>

=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(transparent_hugepage_flags &amp;</div><di=
v>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ((1&lt;&lt;TRANSPARENT_H=
UGEPAGE_FLAG) |</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0(1&lt;&lt;TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG))))</div></div><div><br>=
</div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;b=
order-left-width:1px;border-left-color:rgb(204,204,204);border-left-style:s=
olid;padding-left:1ex">


+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;<br>
+ =C2=A0 =C2=A0 =C2=A0 return transparent_hugepage_flags &amp; (1&lt;&lt;TR=
ANSPARENT_HUGEPAGE_PAGECACHE);<br>
+}<br>
=C2=A0#endif /* _LINUX_HUGE_MM_H */<br>
diff --git a/mm/Kconfig b/mm/Kconfig<br>
index 256bfd0..1e30ee8 100644<br>
--- a/mm/Kconfig<br>
+++ b/mm/Kconfig<br>
@@ -420,6 +420,18 @@ choice<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 benefit.<br>
=C2=A0endchoice<br>
<br>
+config TRANSPARENT_HUGEPAGE_PAGECACHE<br>
+ =C2=A0 =C2=A0 =C2=A0 bool &quot;Transparent Hugepage Support for page cac=
he&quot;<br>
+ =C2=A0 =C2=A0 =C2=A0 depends on X86_64 &amp;&amp; TRANSPARENT_HUGEPAGE<br=
>
+ =C2=A0 =C2=A0 =C2=A0 # avoid radix tree preload overhead<br>
+ =C2=A0 =C2=A0 =C2=A0 depends on !BASE_SMALL<br>
+ =C2=A0 =C2=A0 =C2=A0 default y<br>
+ =C2=A0 =C2=A0 =C2=A0 help<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 Enabling the option adds support hugepages fo=
r file-backed<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 mappings. It requires transparent hugepage su=
pport from<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 filesystem side. For now, the only filesystem=
 which supports<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 hugepages is ramfs.<br>
+<br>
=C2=A0config CROSS_MEMORY_ATTACH<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 bool &quot;Cross Memory Support&quot;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 depends on MMU<br>
diff --git a/mm/huge_memory.c b/mm/huge_memory.c<br>
index d96d921..523946c 100644<br>
--- a/mm/huge_memory.c<br>
+++ b/mm/huge_memory.c<br>
@@ -42,6 +42,9 @@ unsigned long transparent_hugepage_flags __read_mostly =
=3D<br>
=C2=A0#endif<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 (1&lt;&lt;TRANSPARENT_HUGEPAGE_DEFRAG_FLAG)|<br=
>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 (1&lt;&lt;TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGE=
D_FLAG)|<br>
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE<br>
+ =C2=A0 =C2=A0 =C2=A0 (1&lt;&lt;TRANSPARENT_HUGEPAGE_PAGECACHE)|<br>
+#endif<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 (1&lt;&lt;TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FL=
AG);<br>
<br>
=C2=A0/* default scan 8*512 pte (or vmas) every 30 second */<br>
@@ -362,6 +365,23 @@ static ssize_t defrag_store(struct kobject *kobj,<br>
=C2=A0static struct kobj_attribute defrag_attr =3D<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 __ATTR(defrag, 0644, defrag_show, defrag_store)=
;<br>
<br>
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE<br>
+static ssize_t page_cache_show(struct kobject *kobj,<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct kobj_attribute *a=
ttr, char *buf)<br>
+{<br>
+ =C2=A0 =C2=A0 =C2=A0 return single_flag_show(kobj, attr, buf,<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 TRANSPARENT_HUGEPAGE_PAGECACHE);<br>
+}<br>
+static ssize_t page_cache_store(struct kobject *kobj,<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct kobj_attribute *a=
ttr, const char *buf, size_t count)<br>
+{<br>
+ =C2=A0 =C2=A0 =C2=A0 return single_flag_store(kobj, attr, buf, count,<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0TRANSPARENT_HUGEPAGE_PAGECACHE);<br>
+}<br>
+static struct kobj_attribute page_cache_attr =3D<br>
+ =C2=A0 =C2=A0 =C2=A0 __ATTR(page_cache, 0644, page_cache_show, page_cache=
_store);<br>
+#endif<br>
+<br>
=C2=A0static ssize_t use_zero_page_show(struct kobject *kobj,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct kobj_attribu=
te *attr, char *buf)<br>
=C2=A0{<br>
@@ -397,6 +417,9 @@ static struct kobj_attribute debug_cow_attr =3D<br>
=C2=A0static struct attribute *hugepage_attr[] =3D {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 &amp;enabled_attr.attr,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 &amp;defrag_attr.attr,<br>
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE<br>
+ =C2=A0 =C2=A0 =C2=A0 &amp;page_cache_attr.attr,<br>
+#endif<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 &amp;use_zero_page_attr.attr,<br>
=C2=A0#ifdef CONFIG_DEBUG_VM<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 &amp;debug_cow_attr.attr,<br>
<span class=3D""><font color=3D"#888888">--<br>
1.8.3.2<br>
<br>
</font></span></blockquote></div><br></div></div>

--001a11c2c158ba3eed04e5a9f455--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
