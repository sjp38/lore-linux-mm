Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 0C7C76B0032
	for <linux-mm@kvack.org>; Sat, 25 May 2013 00:32:02 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id 16so14216234iea.17
        for <linux-mm@kvack.org>; Fri, 24 May 2013 21:32:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <519FCC46.2000703@codeaurora.org>
References: <518B5556.4010005@samsung.com>
	<519FCC46.2000703@codeaurora.org>
Date: Sat, 25 May 2013 13:32:02 +0900
Message-ID: <CAH9JG2U7787jzqdnr1Z7kZbyEUvHZJG_XZiPENGJQVENsqVDTA@mail.gmail.com>
Subject: Re: [PATCH] mm: page_alloc: fix watermark check in __zone_watermark_ok()
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: multipart/alternative; boundary=089e01182f669ee7b204dd83659a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Tomasz Stanislawski <t.stanislaws@samsung.com>, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, minchan@kernel.org, mgorman@suse.de, 'Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

--089e01182f669ee7b204dd83659a
Content-Type: text/plain; charset=ISO-8859-1

On Sat, May 25, 2013 at 5:23 AM, Laura Abbott <lauraa@codeaurora.org> wrote:

> On 5/9/2013 12:50 AM, Tomasz Stanislawski wrote:
>
>> The watermark check consists of two sub-checks.
>> The first one is:
>>
>>         if (free_pages <= min + lowmem_reserve)
>>                 return false;
>>
>> The check assures that there is minimal amount of RAM in the zone.  If
>> CMA is
>> used then the free_pages is reduced by the number of free pages in CMA
>> prior
>> to the over-mentioned check.
>>
>>         if (!(alloc_flags & ALLOC_CMA))
>>                 free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
>>
>> This prevents the zone from being drained from pages available for
>> non-movable
>> allocations.
>>
>> The second check prevents the zone from getting too fragmented.
>>
>>         for (o = 0; o < order; o++) {
>>                 free_pages -= z->free_area[o].nr_free << o;
>>                 min >>= 1;
>>                 if (free_pages <= min)
>>                         return false;
>>         }
>>
>> The field z->free_area[o].nr_free is equal to the number of free pages
>> including free CMA pages.  Therefore the CMA pages are subtracted twice.
>>  This
>> may cause a false positive fail of __zone_watermark_ok() if the CMA area
>> gets
>> strongly fragmented.  In such a case there are many 0-order free pages
>> located
>> in CMA. Those pages are subtracted twice therefore they will quickly drain
>> free_pages during the check against fragmentation.  The test fails even
>> though
>> there are many free non-cma pages in the zone.
>>
>> This patch fixes this issue by subtracting CMA pages only for a purpose of
>> (free_pages <= min + lowmem_reserve) check.
>>
>> Signed-off-by: Tomasz Stanislawski <t.stanislaws@samsung.com>
>> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
>> ---
>>   mm/page_alloc.c |    6 ++++--
>>   1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 8fcced7..0d4fef2 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1626,6 +1626,7 @@ static bool __zone_watermark_ok(struct zone *z, int
>> order, unsigned long mark,
>>         long min = mark;
>>         long lowmem_reserve = z->lowmem_reserve[classzone_**idx];
>>         int o;
>> +       long free_cma = 0;
>>
>>         free_pages -= (1 << order) - 1;
>>         if (alloc_flags & ALLOC_HIGH)
>> @@ -1635,9 +1636,10 @@ static bool __zone_watermark_ok(struct zone *z,
>> int order, unsigned long mark,
>>   #ifdef CONFIG_CMA
>>         /* If allocation can't use CMA areas don't use free CMA pages */
>>         if (!(alloc_flags & ALLOC_CMA))
>> -               free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
>> +               free_cma = zone_page_state(z, NR_FREE_CMA_PAGES);
>>   #endif
>> -       if (free_pages <= min + lowmem_reserve)
>> +
>> +       if (free_pages - free_cma <= min + lowmem_reserve)
>>                 return false;
>>         for (o = 0; o < order; o++) {
>>                 /* At the next order, this order's pages become
>> unavailable */
>>
>>
> I haven't seen any response to this patch but it has been of some benefit
> to some of our use cases. You're welcome to add
>
> Tested-by: Laura Abbott <lauraa@codeaurora.org>
>

Thanks Laura,
We already got mail from Andrew, it's merged mm tree.

Thank you,
Kyungmin Park


>
> if the patch hasn't been  picked up yet.
>
>

--089e01182f669ee7b204dd83659a
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Sat, May 25, 2013 at 5:23 AM, Laura A=
bbott <span dir=3D"ltr">&lt;<a href=3D"mailto:lauraa@codeaurora.org" target=
=3D"_blank">lauraa@codeaurora.org</a>&gt;</span> wrote:<br><blockquote styl=
e=3D"margin:0px 0px 0px 0.8ex;padding-left:1ex;border-left-color:rgb(204,20=
4,204);border-left-width:1px;border-left-style:solid" class=3D"gmail_quote"=
>
<div class=3D"HOEnZb"><div class=3D"h5">On 5/9/2013 12:50 AM, Tomasz Stanis=
lawski wrote:<br>
<blockquote style=3D"margin:0px 0px 0px 0.8ex;padding-left:1ex;border-left-=
color:rgb(204,204,204);border-left-width:1px;border-left-style:solid" class=
=3D"gmail_quote">
The watermark check consists of two sub-checks.<br>
The first one is:<br>
<br>
=A0 =A0 =A0 =A0 if (free_pages &lt;=3D min + lowmem_reserve)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;<br>
<br>
The check assures that there is minimal amount of RAM in the zone. =A0If CM=
A is<br>
used then the free_pages is reduced by the number of free pages in CMA prio=
r<br>
to the over-mentioned check.<br>
<br>
=A0 =A0 =A0 =A0 if (!(alloc_flags &amp; ALLOC_CMA))<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_pages -=3D zone_page_state(z, NR_FREE_=
CMA_PAGES);<br>
<br>
This prevents the zone from being drained from pages available for non-mova=
ble<br>
allocations.<br>
<br>
The second check prevents the zone from getting too fragmented.<br>
<br>
=A0 =A0 =A0 =A0 for (o =3D 0; o &lt; order; o++) {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_pages -=3D z-&gt;free_area[o].nr_free =
&lt;&lt; o;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 min &gt;&gt;=3D 1;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (free_pages &lt;=3D min)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;<br>
=A0 =A0 =A0 =A0 }<br>
<br>
The field z-&gt;free_area[o].nr_free is equal to the number of free pages<b=
r>
including free CMA pages. =A0Therefore the CMA pages are subtracted twice. =
=A0This<br>
may cause a false positive fail of __zone_watermark_ok() if the CMA area ge=
ts<br>
strongly fragmented. =A0In such a case there are many 0-order free pages lo=
cated<br>
in CMA. Those pages are subtracted twice therefore they will quickly drain<=
br>
free_pages during the check against fragmentation. =A0The test fails even t=
hough<br>
there are many free non-cma pages in the zone.<br>
<br>
This patch fixes this issue by subtracting CMA pages only for a purpose of<=
br>
(free_pages &lt;=3D min + lowmem_reserve) check.<br>
<br>
Signed-off-by: Tomasz Stanislawski &lt;<a href=3D"mailto:t.stanislaws@samsu=
ng.com" target=3D"_blank">t.stanislaws@samsung.com</a>&gt;<br>
Signed-off-by: Kyungmin Park &lt;<a href=3D"mailto:kyungmin.park@samsung.co=
m" target=3D"_blank">kyungmin.park@samsung.com</a>&gt;<br>
---<br>
=A0 mm/page_alloc.c | =A0 =A06 ++++--<br>
=A0 1 file changed, 4 insertions(+), 2 deletions(-)<br>
<br>
diff --git a/mm/page_alloc.c b/mm/page_alloc.c<br>
index 8fcced7..0d4fef2 100644<br>
--- a/mm/page_alloc.c<br>
+++ b/mm/page_alloc.c<br>
@@ -1626,6 +1626,7 @@ static bool __zone_watermark_ok(struct zone *z, int o=
rder, unsigned long mark,<br>
=A0 =A0 =A0 =A0 long min =3D mark;<br>
=A0 =A0 =A0 =A0 long lowmem_reserve =3D z-&gt;lowmem_reserve[classzone_<u><=
/u>idx];<br>
=A0 =A0 =A0 =A0 int o;<br>
+ =A0 =A0 =A0 long free_cma =3D 0;<br>
<br>
=A0 =A0 =A0 =A0 free_pages -=3D (1 &lt;&lt; order) - 1;<br>
=A0 =A0 =A0 =A0 if (alloc_flags &amp; ALLOC_HIGH)<br>
@@ -1635,9 +1636,10 @@ static bool __zone_watermark_ok(struct zone *z, int =
order, unsigned long mark,<br>
=A0 #ifdef CONFIG_CMA<br>
=A0 =A0 =A0 =A0 /* If allocation can&#39;t use CMA areas don&#39;t use free=
 CMA pages */<br>
=A0 =A0 =A0 =A0 if (!(alloc_flags &amp; ALLOC_CMA))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_pages -=3D zone_page_state(z, NR_FREE_CM=
A_PAGES);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_cma =3D zone_page_state(z, NR_FREE_CMA_P=
AGES);<br>
=A0 #endif<br>
- =A0 =A0 =A0 if (free_pages &lt;=3D min + lowmem_reserve)<br>
+<br>
+ =A0 =A0 =A0 if (free_pages - free_cma &lt;=3D min + lowmem_reserve)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;<br>
=A0 =A0 =A0 =A0 for (o =3D 0; o &lt; order; o++) {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* At the next order, this order&#39;s page=
s become unavailable */<br>
<br>
</blockquote>
<br></div></div>
I haven&#39;t seen any response to this patch but it has been of some benef=
it to some of our use cases. You&#39;re welcome to add<br>
<br>
Tested-by: Laura Abbott &lt;<a href=3D"mailto:lauraa@codeaurora.org" target=
=3D"_blank">lauraa@codeaurora.org</a>&gt;<br></blockquote><div>=A0</div><di=
v>Thanks Laura,</div><div>We already got mail from Andrew, it&#39;s merged =
mm tree. </div>
<div>=A0</div><div>Thank you,</div><div>Kyungmin Park</div><div>=A0</div><b=
lockquote style=3D"margin:0px 0px 0px 0.8ex;padding-left:1ex;border-left-co=
lor:rgb(204,204,204);border-left-width:1px;border-left-style:solid" class=
=3D"gmail_quote">

<br>
if the patch hasn&#39;t been =A0picked up yet.<br>
<div class=3D"HOEnZb"><div class=3D"h5">=A0</div></div></blockquote></div>

--089e01182f669ee7b204dd83659a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
