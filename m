Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 3C94D6B0032
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 18:16:51 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id ha12so1680809vcb.23
        for <linux-mm@kvack.org>; Fri, 30 Aug 2013 15:16:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1375582645-29274-6-git-send-email-kirill.shutemov@linux.intel.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1375582645-29274-6-git-send-email-kirill.shutemov@linux.intel.com>
From: Ning Qu <quning@google.com>
Date: Fri, 30 Aug 2013 15:16:29 -0700
Message-ID: <CACz4_2eY3cniz6mV-Nwi6jBEEOfETJs1GXrjHBppr=Grjnwiqw@mail.gmail.com>
Subject: Re: [PATCH 05/23] thp: represent file thp pages in meminfo and friends
Content-Type: multipart/alternative; boundary=047d7bd7623e3d8a7a04e53194c6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

--047d7bd7623e3d8a7a04e53194c6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi, Kirill

I believe there is a typo in your previous commit, but you didn't include
it in this series of patch set. Below is the link for the commit. I think
you are trying to decrease the value NR_ANON_PAGES in page_remove_rmap, but
it is currently adding the value instead when using __mod_zone_page_state.L=
et
me know if you would like to fix it in your commit or you want another
patch from me. Thanks!

https://git.kernel.org/cgit/linux/kernel/git/kas/linux.git/commit/?h=3Dthp/=
pagecache&id=3D90ca9354b08a7b26ba468c7d2ea1229e93d67b92

@@ -1151,11 +1151,11 @@ void page_remove_rmap(struct page *page)
goto out;
if (anon) {
mem_cgroup_uncharge_page(page);
- if (!PageTransHuge(page))
- __dec_zone_page_state(page, NR_ANON_PAGES);
- else
+ if (PageTransHuge(page))
__dec_zone_page_state(page,
NR_ANON_TRANSPARENT_HUGEPAGES);
+ __mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
+ hpage_nr_pages(page));
} else {
__dec_zone_page_state(page, NR_FILE_MAPPED);
mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);


Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Sat, Aug 3, 2013 at 7:17 PM, Kirill A. Shutemov <
kirill.shutemov@linux.intel.com> wrote:

> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
> The patch adds new zone stat to count file transparent huge pages and
> adjust related places.
>
> For now we don't count mapped or dirty file thp pages separately.
>
> The patch depends on patch
>  thp: account anon transparent huge pages into NR_ANON_PAGES
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
> ---
>  drivers/base/node.c    | 4 ++++
>  fs/proc/meminfo.c      | 3 +++
>  include/linux/mmzone.h | 1 +
>  mm/vmstat.c            | 1 +
>  4 files changed, 9 insertions(+)
>
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index bc9f43b..de261f5 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -119,6 +119,7 @@ static ssize_t node_read_meminfo(struct device *dev,
>                        "Node %d SUnreclaim:     %8lu kB\n"
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>                        "Node %d AnonHugePages:  %8lu kB\n"
> +                      "Node %d FileHugePages:  %8lu kB\n"
>  #endif
>                         ,
>                        nid, K(node_page_state(nid, NR_FILE_DIRTY)),
> @@ -140,6 +141,9 @@ static ssize_t node_read_meminfo(struct device *dev,
>                        nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE)=
)
>                         , nid,
>                         K(node_page_state(nid,
> NR_ANON_TRANSPARENT_HUGEPAGES) *
> +                       HPAGE_PMD_NR)
> +                       , nid,
> +                       K(node_page_state(nid,
> NR_FILE_TRANSPARENT_HUGEPAGES) *
>                         HPAGE_PMD_NR));
>  #else
>                        nid, K(node_page_state(nid,
> NR_SLAB_UNRECLAIMABLE)));
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index 59d85d6..a62952c 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -104,6 +104,7 @@ static int meminfo_proc_show(struct seq_file *m, void
> *v)
>  #endif
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>                 "AnonHugePages:  %8lu kB\n"
> +               "FileHugePages:  %8lu kB\n"
>  #endif
>                 ,
>                 K(i.totalram),
> @@ -158,6 +159,8 @@ static int meminfo_proc_show(struct seq_file *m, void
> *v)
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>                 ,K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
>                    HPAGE_PMD_NR)
> +               ,K(global_page_state(NR_FILE_TRANSPARENT_HUGEPAGES) *
> +                  HPAGE_PMD_NR)
>  #endif
>                 );
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 0c41d59..ba81833 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -142,6 +142,7 @@ enum zone_stat_item {
>         NUMA_OTHER,             /* allocation from other node */
>  #endif
>         NR_ANON_TRANSPARENT_HUGEPAGES,
> +       NR_FILE_TRANSPARENT_HUGEPAGES,
>         NR_FREE_CMA_PAGES,
>         NR_VM_ZONE_STAT_ITEMS };
>
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 87228c5..ffe3fbd 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -739,6 +739,7 @@ const char * const vmstat_text[] =3D {
>         "numa_other",
>  #endif
>         "nr_anon_transparent_hugepages",
> +       "nr_file_transparent_hugepages",
>         "nr_free_cma",
>         "nr_dirty_threshold",
>         "nr_dirty_background_threshold",
> --
> 1.8.3.2
>
>

--047d7bd7623e3d8a7a04e53194c6
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi, Kirill<div><br></div><div>I believe there is a typo in=
 your previous commit, but you didn&#39;t include it in this series of patc=
h set. Below is the link for the commit. I think you are trying to decrease=
 the value=C2=A0<span style=3D"color:rgb(0,128,0);font-family:monospace;fon=
t-size:13px;white-space:pre">NR_ANON_PAGES</span>=C2=A0in page_remove_rmap,=
 but it is currently adding the value instead when using=C2=A0<span style=
=3D"font-size:13px;color:rgb(0,128,0);font-family:monospace;white-space:pre=
">__mod_zone_page_state.</span>Let me know if you would like to fix it in y=
our commit or you want another patch from me. Thanks!</div>

<div><br></div><div><a href=3D"https://git.kernel.org/cgit/linux/kernel/git=
/kas/linux.git/commit/?h=3Dthp/pagecache&amp;id=3D90ca9354b08a7b26ba468c7d2=
ea1229e93d67b92">https://git.kernel.org/cgit/linux/kernel/git/kas/linux.git=
/commit/?h=3Dthp/pagecache&amp;id=3D90ca9354b08a7b26ba468c7d2ea1229e93d67b9=
2</a><br>

</div><div><br></div><div><div class=3D"" style=3D"color:rgb(0,0,153);font-=
family:monospace;font-size:13px;white-space:pre">@@ -1151,11 +1151,11 @@ vo=
id page_remove_rmap(struct page *page)</div><div class=3D"" style=3D"color:=
rgb(51,51,51);font-family:monospace;font-size:13px;white-space:pre">

 		goto out;</div><div class=3D"" style=3D"color:rgb(51,51,51);font-family:=
monospace;font-size:13px;white-space:pre"> 	if (anon) {</div><div class=3D"=
" style=3D"color:rgb(51,51,51);font-family:monospace;font-size:13px;white-s=
pace:pre">

 		mem_cgroup_uncharge_page(page);</div><div class=3D"" style=3D"color:red;=
font-family:monospace;font-size:13px;white-space:pre">-		if (!PageTransHuge=
(page))</div><div class=3D"" style=3D"color:red;font-family:monospace;font-=
size:13px;white-space:pre">

-			__dec_zone_page_state(page, NR_ANON_PAGES);</div><div class=3D"" style=
=3D"color:red;font-family:monospace;font-size:13px;white-space:pre">-		else=
</div><div class=3D"" style=3D"color:green;font-family:monospace;font-size:=
13px;line-height:normal;white-space:pre">

+		if (PageTransHuge(page))</div><div class=3D"" style=3D"color:rgb(51,51,5=
1);font-family:monospace;font-size:13px;white-space:pre"> 			__dec_zone_pag=
e_state(page,</div><div class=3D"" style=3D"color:rgb(51,51,51);font-family=
:monospace;font-size:13px;white-space:pre">

 					      NR_ANON_TRANSPARENT_HUGEPAGES);</div><div class=3D"" style=3D"c=
olor:green;font-family:monospace;font-size:13px;line-height:normal;white-sp=
ace:pre">+		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,</div><div=
 class=3D"" style=3D"color:green;font-family:monospace;font-size:13px;line-=
height:normal;white-space:pre">

+				hpage_nr_pages(page));</div><div class=3D"" style=3D"color:rgb(51,51,5=
1);font-family:monospace;font-size:13px;white-space:pre"> 	} else {</div><d=
iv class=3D"" style=3D"color:rgb(51,51,51);font-family:monospace;font-size:=
13px;white-space:pre">

 		__dec_zone_page_state(page, NR_FILE_MAPPED);</div><div class=3D"" style=
=3D"color:rgb(51,51,51);font-family:monospace;font-size:13px;white-space:pr=
e"> 		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);</div></div><div=
 class=3D"" style=3D"color:rgb(51,51,51);font-family:monospace;font-size:13=
px;white-space:pre">

<br></div></div><div class=3D"gmail_extra"><br clear=3D"all"><div><div><div=
>Best wishes,<br></div><div><span style=3D"border-collapse:collapse;font-fa=
mily:arial,sans-serif;font-size:13px">--=C2=A0<br><span style=3D"border-col=
lapse:collapse;font-family:sans-serif;line-height:19px"><span style=3D"bord=
er-top-width:2px;border-right-width:0px;border-bottom-width:0px;border-left=
-width:0px;border-top-style:solid;border-right-style:solid;border-bottom-st=
yle:solid;border-left-style:solid;border-top-color:rgb(213,15,37);border-ri=
ght-color:rgb(213,15,37);border-bottom-color:rgb(213,15,37);border-left-col=
or:rgb(213,15,37);padding-top:2px;margin-top:2px">Ning Qu (=E6=9B=B2=E5=AE=
=81)<font color=3D"#555555">=C2=A0|</font></span><span style=3D"color:rgb(8=
5,85,85);border-top-width:2px;border-right-width:0px;border-bottom-width:0p=
x;border-left-width:0px;border-top-style:solid;border-right-style:solid;bor=
der-bottom-style:solid;border-left-style:solid;border-top-color:rgb(51,105,=
232);border-right-color:rgb(51,105,232);border-bottom-color:rgb(51,105,232)=
;border-left-color:rgb(51,105,232);padding-top:2px;margin-top:2px">=C2=A0So=
ftware Engineer |</span><span style=3D"color:rgb(85,85,85);border-top-width=
:2px;border-right-width:0px;border-bottom-width:0px;border-left-width:0px;b=
order-top-style:solid;border-right-style:solid;border-bottom-style:solid;bo=
rder-left-style:solid;border-top-color:rgb(0,153,57);border-right-color:rgb=
(0,153,57);border-bottom-color:rgb(0,153,57);border-left-color:rgb(0,153,57=
);padding-top:2px;margin-top:2px">=C2=A0<a href=3D"mailto:quning@google.com=
" style=3D"color:rgb(0,0,204)" target=3D"_blank">quning@google.com</a>=C2=
=A0|</span><span style=3D"color:rgb(85,85,85);border-top-width:2px;border-r=
ight-width:0px;border-bottom-width:0px;border-left-width:0px;border-top-sty=
le:solid;border-right-style:solid;border-bottom-style:solid;border-left-sty=
le:solid;border-top-color:rgb(238,178,17);border-right-color:rgb(238,178,17=
);border-bottom-color:rgb(238,178,17);border-left-color:rgb(238,178,17);pad=
ding-top:2px;margin-top:2px">=C2=A0<a value=3D"+16502143877" style=3D"color=
:rgb(0,0,204)">+1-408-418-6066</a></span></span></span></div>

</div></div>
<br><br><div class=3D"gmail_quote">On Sat, Aug 3, 2013 at 7:17 PM, Kirill A=
. Shutemov <span dir=3D"ltr">&lt;<a href=3D"mailto:kirill.shutemov@linux.in=
tel.com" target=3D"_blank">kirill.shutemov@linux.intel.com</a>&gt;</span> w=
rote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">From: &quot;Kirill A. Shutemov&quot; &lt;<a =
href=3D"mailto:kirill.shutemov@linux.intel.com">kirill.shutemov@linux.intel=
.com</a>&gt;<br>


<br>
The patch adds new zone stat to count file transparent huge pages and<br>
adjust related places.<br>
<br>
For now we don&#39;t count mapped or dirty file thp pages separately.<br>
<br>
The patch depends on patch<br>
=C2=A0thp: account anon transparent huge pages into NR_ANON_PAGES<br>
<br>
Signed-off-by: Kirill A. Shutemov &lt;<a href=3D"mailto:kirill.shutemov@lin=
ux.intel.com">kirill.shutemov@linux.intel.com</a>&gt;<br>
Acked-by: Dave Hansen &lt;<a href=3D"mailto:dave.hansen@linux.intel.com">da=
ve.hansen@linux.intel.com</a>&gt;<br>
---<br>
=C2=A0drivers/base/node.c =C2=A0 =C2=A0| 4 ++++<br>
=C2=A0fs/proc/meminfo.c =C2=A0 =C2=A0 =C2=A0| 3 +++<br>
=C2=A0include/linux/mmzone.h | 1 +<br>
=C2=A0mm/vmstat.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 1 +<br>
=C2=A04 files changed, 9 insertions(+)<br>
<br>
diff --git a/drivers/base/node.c b/drivers/base/node.c<br>
index bc9f43b..de261f5 100644<br>
--- a/drivers/base/node.c<br>
+++ b/drivers/base/node.c<br>
@@ -119,6 +119,7 @@ static ssize_t node_read_meminfo(struct device *dev,<br=
>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0&quot;Node %d SUnreclaim: =C2=A0 =C2=A0 %8lu kB\n&quot;<br>
=C2=A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0&quot;Node %d AnonHugePages: =C2=A0%8lu kB\n&quot;<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0&quot;Node %d FileHugePages: =C2=A0%8lu kB\n&quot;<br>
=C2=A0#endif<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 ,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0nid, K(node_page_state(nid, NR_FILE_DIRTY)),<br>
@@ -140,6 +141,9 @@ static ssize_t node_read_meminfo(struct device *dev,<br=
>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 , nid,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 K(node_page_state(nid, NR_ANON_TRANSPARENT_HUGEPAGES) *<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 HPAGE_PMD_NR)<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 , nid,<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 K(node_page_state(nid, NR_FILE_TRANSPARENT_HUGEPAGES) *<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 HPAGE_PMD_NR));<br>
=C2=A0#else<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));<br>
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c<br>
index 59d85d6..a62952c 100644<br>
--- a/fs/proc/meminfo.c<br>
+++ b/fs/proc/meminfo.c<br>
@@ -104,6 +104,7 @@ static int meminfo_proc_show(struct seq_file *m, void *=
v)<br>
=C2=A0#endif<br>
=C2=A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &quot;AnonHugePages=
: =C2=A0%8lu kB\n&quot;<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &quot;FileHugePages: =C2=
=A0%8lu kB\n&quot;<br>
=C2=A0#endif<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 K(i.totalram),<br>
@@ -158,6 +159,8 @@ static int meminfo_proc_show(struct seq_file *m, void *=
v)<br>
=C2=A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ,K(global_page_stat=
e(NR_ANON_TRANSPARENT_HUGEPAGES) *<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0HPAGE_=
PMD_NR)<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ,K(global_page_state(NR_=
FILE_TRANSPARENT_HUGEPAGES) *<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0HPAGE_PMD_N=
R)<br>
=C2=A0#endif<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 );<br>
<br>
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h<br>
index 0c41d59..ba81833 100644<br>
--- a/include/linux/mmzone.h<br>
+++ b/include/linux/mmzone.h<br>
@@ -142,6 +142,7 @@ enum zone_stat_item {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 NUMA_OTHER, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /* allocation from other node */<br>
=C2=A0#endif<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 NR_ANON_TRANSPARENT_HUGEPAGES,<br>
+ =C2=A0 =C2=A0 =C2=A0 NR_FILE_TRANSPARENT_HUGEPAGES,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 NR_FREE_CMA_PAGES,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 NR_VM_ZONE_STAT_ITEMS };<br>
<br>
diff --git a/mm/vmstat.c b/mm/vmstat.c<br>
index 87228c5..ffe3fbd 100644<br>
--- a/mm/vmstat.c<br>
+++ b/mm/vmstat.c<br>
@@ -739,6 +739,7 @@ const char * const vmstat_text[] =3D {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 &quot;numa_other&quot;,<br>
=C2=A0#endif<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 &quot;nr_anon_transparent_hugepages&quot;,<br>
+ =C2=A0 =C2=A0 =C2=A0 &quot;nr_file_transparent_hugepages&quot;,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 &quot;nr_free_cma&quot;,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 &quot;nr_dirty_threshold&quot;,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 &quot;nr_dirty_background_threshold&quot;,<br>
<span class=3D"HOEnZb"><font color=3D"#888888">--<br>
1.8.3.2<br>
<br>
</font></span></blockquote></div><br></div>

--047d7bd7623e3d8a7a04e53194c6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
