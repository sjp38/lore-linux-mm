Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f46.google.com (mail-oa0-f46.google.com [209.85.219.46])
	by kanga.kvack.org (Postfix) with ESMTP id 139436B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 21:06:55 -0500 (EST)
Received: by mail-oa0-f46.google.com with SMTP id i7so3543190oag.19
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 18:06:54 -0800 (PST)
Received: from snt0-omc3-s51.snt0.hotmail.com (snt0-omc3-s51.snt0.hotmail.com. [65.54.51.88])
        by mx.google.com with ESMTP id kb5si7282969obb.109.2014.03.06.18.06.54
        for <linux-mm@kvack.org>;
        Thu, 06 Mar 2014 18:06:54 -0800 (PST)
Message-ID: <SNT405-EAS28798B25DC755209EF9BAD4808B0@phx.gbl>
Date: Thu, 6 Mar 2014 20:06:54 -0600
From: TB Boxer <boxerspam1@outlook.com>
In-Reply-To: <SNT405-EAS16A6AFE222C189BC611B4F808B0@phx.gbl>
References: <742FF125-8DCE-41BB-932F-6A2F8FDF3583@outlook.com>
 <SNT405-EAS16A6AFE222C189BC611B4F808B0@phx.gbl>
Subject: Re: [PATCHv2] mm/compaction: Break out of loop on !PageBuddy in
 isolate_freepages_block
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="531929be_66ef438d_99a"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <lauraa@codeaurora.org>, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

--531929be_66ef438d_99a
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

TB Boxer liked your message with Boxer. On March 6, 2014 at 7:39:17 PM CS=
T, TB Boxer <boxerspam1=40outlook.com> wrote:TB Boxer liked your message =
with Boxer. On March 6, 2014 at 7:18:40 PM CST, TB Boxer <boxerspam1=40ou=
tlook.com> wrote:TB Boxer liked your message with Boxer. On March 6, 2014=
 at 6:33:49 PM CST, Andrew Morton <akpm=40linux-foundation.org> wrote:   =
   On Thu,=C2=A0 6 Mar 2014 10:21:32 -0800 Laura Abbott <lauraa=40codeaur=
ora.org> wrote:  > We received several reports of bad page state when fre=
eing CMA pages > previously allocated with alloc=5Fcontig=5Frange: >  > <=
1>=5B 1258.084111=5D BUG: Bad page state in process Binder=5FA=C2=A0 pfn:=
63202 > <1>=5B 1258.089763=5D page:d21130b0 count:0 mapcount:1 mapping:=C2=
=A0 (null) index:0x7dfbf > <1>=5B 1258.096109=5D page flags: 0x40080068(u=
ptodate=7Clru=7Cactive=7Cswapbacked) >  > Based on the page state, it loo=
ks like the page was still in use. The page > flags do not make sense for=
 the use case though. =46urther debugging showed > that despite alloc=5Fc=
ontig=5Frange returning success, at least one page in the > range still r=
emained in the buddy allocator. >  > There is an issue with isolate=5Ffre=
epages=5Fblock. In strict mode (which CMA > uses), if any pages in the ra=
nge cannot be isolated, > isolate=5Ffreepages=5Fblock should return failu=
re 0. The current check keeps > track of the total number of isolated pag=
es and compares against the size > of the range: >  >=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (strict && nr=5Fstrict=5Frequired > total=5F=
isolated) >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 total=5Fisolated =3D 0; >  > After taki=
ng the zone lock, if one of the pages in the range is not > in the buddy =
allocator, we continue through the loop and do not > increment total=5Fis=
olated. If in the last iteration of the loop we isolate > more than one p=
age (e.g. last page needed is a higher order page), the > check for total=
=5Fisolated may pass and we fail to detect that a page was > skipped. The=
 fix is to bail out if the loop immediately if we are in > strict mode. T=
here's no benfit to continuing anyway since we need all > pages to be iso=
lated. Additionally, drop the error checking based on > nr=5Fstrict=5Freq=
uired and just check the pfn ranges. This matches with > what isolate=5Ff=
reepages=5Frange does. >  > --- a/mm/compaction.c > +++ b/mm/compaction.c=
 > =40=40 -242,7 +242,6 =40=40 static unsigned long isolate=5Ffreepages=5F=
block(struct compact=5Fcontrol *cc, >=C2=A0 =7B >=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 int nr=5Fscanned =3D 0, total=5Fisolated =3D 0; >=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 struct page *cursor, *valid=5Fpage =3D=
 NULL; > -=C2=A0=C2=A0=C2=A0=C2=A0 unsigned long nr=5Fstrict=5Frequired =3D=
 end=5Fpfn - blockpfn; >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 unsign=
ed long flags; >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 bool locked =3D=
 false; >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 bool checked=5Fpagebl=
ock =3D false; > =40=40 -256,11 +255,12 =40=40 static unsigned long isola=
te=5Ffreepages=5Fblock(struct compact=5Fcontrol *cc, >=C2=A0  >=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 nr=5Fscanned++; >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (=21pfn=5Fvalid=5Fwithin(blockpfn=
)) > -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 continue; > +=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 goto isolate=5Ffail; > + >=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 if (=21valid=5Fpage) >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 valid=5Fpage =3D page; >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (=21PageBudd=
y(page)) > -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 continue; > +=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 goto isolate=5Ffail; >=C2=A0  =
>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 /* >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 * The zone lock must be hel=
d to isolate freepages. > =40=40 -289,12 +289,10 =40=40 static unsigned l=
ong isolate=5Ffreepages=5Fblock(struct compact=5Fcontrol *cc, >=C2=A0  >=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 /* Recheck this is a buddy page under lock */ >=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 if (=21PageBuddy(page)) > -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 continue; > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 goto isolate=
=5Ffail; >=C2=A0  >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 /* =46ound a free page, break it int=
o order-0 pages */ >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 isolated =3D split=5Ffree=5Fpage(pag=
e); > -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 if (=21isolated && strict) > -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 break; >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 total=5Fisolated +=3D isolated; >=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 for (i =3D 0; i < isolated; i++) =7B >=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 list=5Fadd(&page->lru, freelist); > =
=40=40 -305,7 +303,15 =40=40 static unsigned long isolate=5Ffreepages=5Fb=
lock(struct compact=5Fcontrol *cc, >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (isolated) =7B >=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 blockpfn +=3D=
 isolated - 1; >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 cursor +=3D isolated - 1; > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 continue; >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =7D  We can make the code a little more=
 efficient and (I think) clearer by moving that =60if (isolated)' test.  =
> + > +isolate=5Ffail: > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 if (strict) > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 break; > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 else > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 continue; > +  And I don't think this =60continue' has any benefit.   --=
- a/mm/compaction.c=7Emm-compaction-break-out-of-loop-on-pagebuddy-in-iso=
late=5Ffreepages=5Fblock-fix +++ a/mm/compaction.c =40=40 -293,14 +293,14=
 =40=40 static unsigned long isolate=5Ffreepages=5Fb =C2=A0 =C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 /* =46ound a free page, break it into order-0 pages */ =C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 isolated =3D split=5Ffree=5Fpage(page); -=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 total=5Fisol=
ated +=3D isolated; -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for (i =3D 0; i < isolated; i++) =7B -=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 list=5Fadd(&page->lru=
, freelist); -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =
page++; -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 =7D - -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 /* If a page was split, advance to t=
he end of it */ =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (isolated) =7B +=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 total=5Fisolated +=3D isolated=
; +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for (i =3D 0=
; i < isolated; i++) =7B +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 list=5Fadd(&pag=
e->lru, freelist); +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 page++; +=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =7D + +=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 /* If a page was split, advance to t=
he end of it */ =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 blockpfn +=3D isolated - 1; =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 cursor +=3D isolated - 1; =C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 continue; =40=40=
 -309,9 +309,6 =40=40 static unsigned long isolate=5Ffreepages=5Fb =C2=A0=
isolate=5Ffail: =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (strict) =C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 break; -=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 else -=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 continue; - =C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =7D =C2=A0 =C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 trace=5Fmm=5Fcompaction=5Fisolate=5Ffreepa=
ges(nr=5Fscanned, total=5Fisolated);   Problem is, I can't be bothered te=
sting this.  -- To unsubscribe from this list: send the line =22unsubscri=
be linux-kernel=22 in the body of a message to majordomo=40vger.kernel.or=
g More majordomo info at=C2=A0 http://vger.kernel.org/majordomo-info.html=
 Please read the =46AQ at=C2=A0 http://www.tux.org/lkml/                 =
     
--531929be_66ef438d_99a
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<html><body><div>TB Boxer liked your message with <a href=3D=22http://ad.=
apps.fm/x3NHJParL2cT9cQ9WcgT1xM8G1T=5FLUvoWYXredpuoYBLq62ptJqsuhqD23uAmN=5F=
ARL=5FcKzXIyDOjqo=5F2b16qX20uaphn=46WU7uPwUiYWuOAT=46UAGQB7Cox3TWT3ZKjzWy=
P=46IlhepnEZcRklQejqpibw=22>Boxer</a>.</div><br/><br/><div><div class=3D=22=
quote=22>On March 6, 2014 at 7:39:17 PM CST, TB Boxer &lt;boxerspam1=40ou=
tlook.com&gt; wrote:<br/><blockquote type=3D=22cite=22 style=3D=22border-=
left-style:solid;border-width:1px;margin-left:0px;padding-left:10px;=22><=
html><body><div>TB Boxer liked your message with <a href=3D=22http://ad.a=
pps.fm/x3NHJParL2cT9cQ9WcgT1xM8G1T=5FLUvoWYXredpuoYBLq62ptJqsuhqD23uAmN=5F=
ARL=5FcKzXIyDOjqo=5F2b16qX20uaphn=46WU7uPwUiYWuOAT=46UAGQB7Cox3TWT3ZKjzWy=
P=46IlhepnEZcRklQejqpibw=22>Boxer</a>.</div><br/><br/><div><div class=3D=22=
quote=22>On March 6, 2014 at 7:18:40 PM CST, TB Boxer &lt;boxerspam1=40ou=
tlook.com&gt; wrote:<br/><blockquote type=3D=22cite=22 style=3D=22border-=
left-style:solid;border-width:1px;margin-left:0px;padding-left:10px;=22><=
html><body><div>TB Boxer liked your message with <a href=3D=22http://ad.a=
pps.fm/x3NHJParL2cT9cQ9WcgT1xM8G1T=5FLUvoWYXredpuoYBLq62ptJqsuhqD23uAmN=5F=
ARL=5FcKzXIyDOjqo=5F2b16qX20uaphn=46WU7uPwUiYWuOAT=46UAGQB7Cox3TWT3ZKjzWy=
P=46IlhepnEZcRklQejqpibw=22>Boxer</a>.</div><br/><br/><div><div class=3D=22=
quote=22>On March 6, 2014 at 6:33:49 PM CST, Andrew Morton &lt;akpm=40lin=
ux-foundation.org&gt; wrote:<br/><blockquote type=3D=22cite=22 style=3D=22=
border-left-style:solid;border-width:1px;margin-left:0px;padding-left:10p=
x;=22><html><head><meta http-equiv=3D=22Content-Type=22 content=3D=22text=
/html; charset=3Dutf-8=22>



<meta name=3D=22Generator=22 content=3D=22Microsoft Exchange Server=22>



<=21-- converted from text -->



<style><=21-- .EmailQuote =7B margin-left: 1pt; padding-left: 4pt; border=
-left: =23800000 2px solid; =7D --></style></head>



<body>



<div class=3D=22PlainText=22>On Thu,&nbsp; 6 Mar 2014 10:21:32 -0800 Laur=
a Abbott &lt;lauraa=40codeaurora.org&gt; wrote:<br>



<br>



&gt; We received several reports of bad page state when freeing CMA pages=
<br>



&gt; previously allocated with alloc=5Fcontig=5Frange:<br>



&gt; <br>



&gt; &lt;1&gt;=5B 1258.084111=5D BUG: Bad page state in process Binder=5F=
A&nbsp; pfn:63202<br>



&gt; &lt;1&gt;=5B 1258.089763=5D page:d21130b0 count:0 mapcount:1 mapping=
:&nbsp; (null) index:0x7dfbf<br>



&gt; &lt;1&gt;=5B 1258.096109=5D page flags: 0x40080068(uptodate=7Clru=7C=
active=7Cswapbacked)<br>



&gt; <br>



&gt; Based on the page state, it looks like the page was still in use. Th=
e page<br>



&gt; flags do not make sense for the use case though. =46urther debugging=
 showed<br>



&gt; that despite alloc=5Fcontig=5Frange returning success, at least one =
page in the<br>



&gt; range still remained in the buddy allocator.<br>



&gt; <br>



&gt; There is an issue with isolate=5Ffreepages=5Fblock. In strict mode (=
which CMA<br>



&gt; uses), if any pages in the range cannot be isolated,<br>



&gt; isolate=5Ffreepages=5Fblock should return failure 0. The current che=
ck keeps<br>



&gt; track of the total number of isolated pages and compares against the=
 size<br>



&gt; of the range:<br>



&gt; <br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (strict &amp;&amp=
; nr=5Fstrict=5Frequired &gt; total=5Fisolated)<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp; total=5Fisolated =3D 0;<br>



&gt; <br>



&gt; After taking the zone lock, if one of the pages in the range is not<=
br>



&gt; in the buddy allocator, we continue through the loop and do not<br>
=



&gt; increment total=5Fisolated. If in the last iteration of the loop we =
isolate<br>



&gt; more than one page (e.g. last page needed is a higher order page), t=
he<br>



&gt; check for total=5Fisolated may pass and we fail to detect that a pag=
e was<br>



&gt; skipped. The fix is to bail out if the loop immediately if we are in=
<br>



&gt; strict mode. There's no benfit to continuing anyway since we need al=
l<br>



&gt; pages to be isolated. Additionally, drop the error checking based on=
<br>



&gt; nr=5Fstrict=5Frequired and just check the pfn ranges. This matches w=
ith<br>



&gt; what isolate=5Ffreepages=5Frange does.<br>



&gt; <br>



&gt; --- a/mm/compaction.c<br>



&gt; &=2343;&=2343;&=2343; b/mm/compaction.c<br>



&gt; =40=40 -242,7 &=2343;242,6 =40=40 static unsigned long isolate=5Ffre=
epages=5Fblock(struct compact=5Fcontrol *cc,<br>



&gt;&nbsp; =7B<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int nr=5Fscanned =3D 0, to=
tal=5Fisolated =3D 0;<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct page *cursor, *vali=
d=5Fpage =3D NULL;<br>



&gt; -&nbsp;&nbsp;&nbsp;&nbsp; unsigned long nr=5Fstrict=5Frequired =3D e=
nd=5Fpfn - blockpfn;<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; unsigned long flags;<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bool locked =3D false;<br>=




&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bool checked=5Fpageblock =3D=
 false;<br>



&gt; =40=40 -256,11 &=2343;255,12 =40=40 static unsigned long isolate=5Ff=
reepages=5Fblock(struct compact=5Fcontrol *cc,<br>



&gt;&nbsp; <br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; nr=5Fscanned&=2343;&=2343;;<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; if (=21pfn=5Fvalid=5Fwithin(blockpfn))<br>



&gt; -&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; continue;<br>



&gt; &=2343;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; goto isolate=5F=
fail;<br>



&gt; &=2343;<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; if (=21valid=5Fpage)<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; val=
id=5Fpage =3D page;<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; if (=21PageBuddy(page))<br>



&gt; -&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; continue;<br>



&gt; &=2343;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; goto isolate=5F=
fail;<br>



&gt;&nbsp; <br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; /*<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp; * The zone lock must be held to isolate freep=
ages.<br>



&gt; =40=40 -289,12 &=2343;289,10 =40=40 static unsigned long isolate=5Ff=
reepages=5Fblock(struct compact=5Fcontrol *cc,<br>



&gt;&nbsp; <br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; /* Recheck this is a buddy page under lock */<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; if (=21PageBuddy(page))<br>



&gt; -&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; continue;<br>



&gt; &=2343;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; goto isolate=5F=
fail;<br>



&gt;&nbsp; <br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; /* =46ound a free page, break it into order-0 pages=
 */<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; isolated =3D split=5Ffree=5Fpage(page);<br>



&gt; -&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; if (=21isolated &amp;&amp; strict)<br>



&gt; -&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; break;<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; total=5Fisolated &=2343;=3D isolated;<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; for (i =3D 0; i &lt; isolated; i&=2343;&=2343;) =7B=
<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; lis=
t=5Fadd(&amp;page-&gt;lru, freelist);<br>



&gt; =40=40 -305,7 &=2343;303,15 =40=40 static unsigned long isolate=5Ffr=
eepages=5Fblock(struct compact=5Fcontrol *cc,<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; if (isolated) =7B<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; blo=
ckpfn &=2343;=3D isolated - 1;<br>



&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; cur=
sor &=2343;=3D isolated - 1;<br>



&gt; &=2343;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; continue;<br>=




&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; =7D<br>



<br>



We can make the code a little more efficient and (I think) clearer by<br>=




moving that =60if (isolated)' test.<br>



<br>



&gt; &=2343;<br>



&gt; &=2343;isolate=5Ffail:<br>



&gt; &=2343;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; if (strict)<br>



&gt; &=2343;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; break;<br>



&gt; &=2343;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; else<br>



&gt; &=2343;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; continue;<br>=




&gt; &=2343;<br>



<br>



And I don't think this =60continue' has any benefit.<br>



<br>



<br>



--- a/mm/compaction.c=7Emm-compaction-break-out-of-loop-on-pagebuddy-in-i=
solate=5Ffreepages=5Fblock-fix<br>



&=2343;&=2343;&=2343; a/mm/compaction.c<br>



=40=40 -293,14 &=2343;293,14 =40=40 static unsigned long isolate=5Ffreepa=
ges=5Fb<br>



&nbsp;<br>



&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp; /* =46ound a free page, break it into order-0 pag=
es */<br>



&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp; isolated =3D split=5Ffree=5Fpage(page);<br>



-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; total=5Fisolated &=2343;=3D isolated;<br>



-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; for (i =3D 0; i &lt; isolated; i&=2343;&=2343;) =7B<br>



-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; list=5Fadd(&=
amp;page-&gt;lru, freelist);<br>



-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; page&=2343;&=
=2343;;<br>



-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; =7D<br>



-<br>



-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; /* If a page was split, advance to the end of it */<br>



&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp; if (isolated) =7B<br>



&=2343;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; total=5F=
isolated &=2343;=3D isolated;<br>



&=2343;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; for (i=
 =3D 0; i &lt; isolated; i&=2343;&=2343;) =7B<br>



&=2343;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; list=5Fadd(&amp;page-&gt;lru, f=
reelist);<br>



&=2343;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; page&=2343;&=2343;;<br>



&=2343;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =7D<br=
>



&=2343;<br>



&=2343;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* If =
a page was split, advance to the end of it */<br>



&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; b=
lockpfn &=2343;=3D isolated - 1;<br>



&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; c=
ursor &=2343;=3D isolated - 1;<br>



&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; c=
ontinue;<br>



=40=40 -309,9 &=2343;309,6 =40=40 static unsigned long isolate=5Ffreepage=
s=5Fb<br>



&nbsp;isolate=5Ffail:<br>



&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp; if (strict)<br>



&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; b=
reak;<br>



-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; else<br>



-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; continue;<br=
>



-<br>



&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =7D<br>



&nbsp;<br>



&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; trace=5Fmm=5Fcompaction=5F=
isolate=5Ffreepages(nr=5Fscanned, total=5Fisolated);<br>



<br>



<br>



Problem is, I can't be bothered testing this.<br>



<br>



--<br>



To unsubscribe from this list: send the line &quot;unsubscribe linux-kern=
el&quot; in<br>



the body of a message to majordomo=40vger.kernel.org<br>



More majordomo info at&nbsp; <a href=3D=22http://vger.kernel.org/majordom=
o-info.html=22>http://vger.kernel.org/majordomo-info.html</a><br>



Please read the =46AQ at&nbsp; <a href=3D=22http://www.tux.org/lkml/=22>h=
ttp://www.tux.org/lkml/</a><br>



</div>



</body>



</html>



</blockquote></div></div></body></html></blockquote></div></div></body></=
html></blockquote></div></div></body></html>
--531929be_66ef438d_99a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
