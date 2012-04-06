Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 4927E6B004A
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 02:40:58 -0400 (EDT)
Received: by ggeq1 with SMTP id q1so1510909gge.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 23:40:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1333643534-1591-2-git-send-email-b.zolnierkie@samsung.com>
References: <1333643534-1591-1-git-send-email-b.zolnierkie@samsung.com>
	<1333643534-1591-2-git-send-email-b.zolnierkie@samsung.com>
Date: Fri, 6 Apr 2012 15:40:56 +0900
Message-ID: <CAEwNFnAtzd5GHKanNOafZhnc5xQJHgVZn6y93_+q4BJwRGqwsg@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: compaction: try harder to isolate free pages
From: Minchan Kim <minchan@kernel.org>
Content-Type: multipart/alternative; boundary=001636c5c28e59a56c04bcfcf03d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, Kyungmin Park <kyungmin.park@samsung.com>

--001636c5c28e59a56c04bcfcf03d
Content-Type: text/plain; charset=UTF-8

On Fri, Apr 6, 2012 at 1:32 AM, Bartlomiej Zolnierkiewicz <
b.zolnierkie@samsung.com> wrote:

> In isolate_freepages() check each page in a pageblock
> instead of checking only first pages of pageblock_nr_pages
> intervals (suitable_migration_target(page) is called before
> isolate_freepages_block() so if page is "unsuitable" whole
> pageblock_nr_pages pages will be ommited from the check).
> It greatly improves possibility of finding free pages to
> isolate during compaction_alloc() phase.
>

I doubt how this can help keeping free pages.
Now, compaction works by pageblock_nr_pages unit so although you work by
per page, all pages in a block would have same block type.
It means we can't pass suitable_migration_target. No?


> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  mm/compaction.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index d9ebebe..bc77135 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -65,7 +65,7 @@ static unsigned long isolate_freepages_block(struct zone
> *zone,
>
>        /* Get the last PFN we should scan for free pages at */
>        zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
> -       end_pfn = min(blockpfn + pageblock_nr_pages, zone_end_pfn);
> +       end_pfn = min(blockpfn + 1, zone_end_pfn);
>
>        /* Find the first usable PFN in the block to initialse page cursor
> */
>        for (; blockpfn < end_pfn; blockpfn++) {
> @@ -160,8 +160,7 @@ static void isolate_freepages(struct zone *zone,
>         * pages on cc->migratepages. We stop searching if the migrate
>         * and free page scanners meet or enough free pages are isolated.
>         */
> -       for (; pfn > low_pfn && cc->nr_migratepages > nr_freepages;
> -                                       pfn -= pageblock_nr_pages) {
> +       for (; pfn > low_pfn && cc->nr_migratepages > nr_freepages; pfn--)
> {
>                unsigned long isolated;
>
>                if (!pfn_valid(pfn))
> --
> 1.7.9.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>



-- 
Kind regards,
Minchan Kim

--001636c5c28e59a56c04bcfcf03d
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Apr 6, 2012 at 1:32 AM, Bartlomi=
ej Zolnierkiewicz <span dir=3D"ltr">&lt;<a href=3D"mailto:b.zolnierkie@sams=
ung.com">b.zolnierkie@samsung.com</a>&gt;</span> wrote:<br><blockquote clas=
s=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pad=
ding-left:1ex">
In isolate_freepages() check each page in a pageblock<br>
instead of checking only first pages of pageblock_nr_pages<br>
intervals (suitable_migration_target(page) is called before<br>
isolate_freepages_block() so if page is &quot;unsuitable&quot; whole<br>
pageblock_nr_pages pages will be ommited from the check).<br>
It greatly improves possibility of finding free pages to<br>
isolate during compaction_alloc() phase.<br></blockquote><div><br></div><di=
v>I doubt how this can help keeping free pages.</div><div>Now, compaction w=
orks by pageblock_nr_pages unit so although you work by per page, all pages=
 in a block would have same block type.</div>
<div>It means we can&#39;t pass suitable_migration_target. No?</div><div><b=
r></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border=
-left:1px #ccc solid;padding-left:1ex">
<br>
Cc: Mel Gorman &lt;<a href=3D"mailto:mgorman@suse.de">mgorman@suse.de</a>&g=
t;<br>
Signed-off-by: Bartlomiej Zolnierkiewicz &lt;<a href=3D"mailto:b.zolnierkie=
@samsung.com">b.zolnierkie@samsung.com</a>&gt;<br>
Signed-off-by: Kyungmin Park &lt;<a href=3D"mailto:kyungmin.park@samsung.co=
m">kyungmin.park@samsung.com</a>&gt;<br>
---<br>
=C2=A0mm/compaction.c | =C2=A0 =C2=A05 ++---<br>
=C2=A01 file changed, 2 insertions(+), 3 deletions(-)<br>
<br>
diff --git a/mm/compaction.c b/mm/compaction.c<br>
index d9ebebe..bc77135 100644<br>
--- a/mm/compaction.c<br>
+++ b/mm/compaction.c<br>
@@ -65,7 +65,7 @@ static unsigned long isolate_freepages_block(struct zone =
*zone,<br>
<br>
 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Get the last PFN we should scan for free pag=
es at */<br>
 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone_end_pfn =3D zone-&gt;zone_start_pfn + zone=
-&gt;spanned_pages;<br>
- =C2=A0 =C2=A0 =C2=A0 end_pfn =3D min(blockpfn + pageblock_nr_pages, zone_=
end_pfn);<br>
+ =C2=A0 =C2=A0 =C2=A0 end_pfn =3D min(blockpfn + 1, zone_end_pfn);<br>
<br>
 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Find the first usable PFN in the block to in=
itialse page cursor */<br>
 =C2=A0 =C2=A0 =C2=A0 =C2=A0for (; blockpfn &lt; end_pfn; blockpfn++) {<br>
@@ -160,8 +160,7 @@ static void isolate_freepages(struct zone *zone,<br>
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * pages on cc-&gt;migratepages. We stop search=
ing if the migrate<br>
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * and free page scanners meet or enough free p=
ages are isolated.<br>
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
- =C2=A0 =C2=A0 =C2=A0 for (; pfn &gt; low_pfn &amp;&amp; cc-&gt;nr_migrate=
pages &gt; nr_freepages;<br>
- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pfn -=3D pagebl=
ock_nr_pages) {<br>
+ =C2=A0 =C2=A0 =C2=A0 for (; pfn &gt; low_pfn &amp;&amp; cc-&gt;nr_migrate=
pages &gt; nr_freepages; pfn--) {<br>
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long isola=
ted;<br>
<br>
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!pfn_valid(pfn)=
)<br>
<span class=3D"HOEnZb"><font color=3D"#888888">--<br>
1.7.9.4<br>
<br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
 =C2=A0For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linu=
x-mm.org/</a> .<br>
Fight unfair telecom internet charges in Canada: sign <a href=3D"http://sto=
pthemeter.ca/" target=3D"_blank">http://stopthemeter.ca/</a><br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</font></span></blockquote></div><br><br clear=3D"all"><div><br></div>-- <b=
r>Kind regards,<br>Minchan Kim<br>

--001636c5c28e59a56c04bcfcf03d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
