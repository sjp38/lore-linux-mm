Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4936B0031
	for <linux-mm@kvack.org>; Sun,  6 Oct 2013 07:26:54 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so6071015pad.5
        for <linux-mm@kvack.org>; Sun, 06 Oct 2013 04:26:53 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so6094003pab.17
        for <linux-mm@kvack.org>; Sun, 06 Oct 2013 04:26:51 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 6 Oct 2013 19:26:51 +0800
Message-ID: <CAADRoS2rZEpk1eCzjo=_GPGcR56AgNYOTjz0WCSq3V7-hOJ2Xw@mail.gmail.com>
Subject: a bug report for function move_freepages_block
From: martin zhang <martinbj2008@gmail.com>
Content-Type: multipart/alternative; boundary=001a113322d4dbc1e004e810cfd0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a113322d4dbc1e004e810cfd0
Content-Type: text/plain; charset=UTF-8

HI all,
I think there is a bug in function move_freepages_block.

 981 int move_freepages_block(struct zone *zone, struct page *page,
...
 987         start_pfn = page_to_pfn(page);
 988         start_pfn = start_pfn & ~(pageblock_nr_pages-1);
 989         start_page = pfn_to_page(start_pfn);
 990         end_page = start_page + pageblock_nr_pages - 1;
 991         end_pfn = start_pfn + pageblock_nr_pages - 1;
 992
 993         /* Do not cross zone boundaries */
 994         if (!zone_spans_pfn(zone, start_pfn))
 995                 start_page = page;

The line 988 will align start_pfn with pageblock_nr_pages,
thus after line988, start_pfn maybe less than zone->pageblock_nr_pages,
in the worst case, start_pfn maybe outof the range of zone->node pfn.
and becomes a invalid pfn.
in this case, line 989 will be wrong.

so I think the check for start_pfn should be done before line 989, just
like:
    start_pfn = start_pfn & ~(pageblock_nr_pages-1); <== line 988
    if (!zone_spans_pfn(zone, start_pfn))
    start_pfn = page_to_pfn(page);

Regards,
Martin

--001a113322d4dbc1e004e810cfd0
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">HI all,<div>I think there is a bug in function=C2=A0move_f=
reepages_block.</div><div><br></div><div><div>=C2=A0981 int move_freepages_=
block(struct zone *zone, struct page *page,</div><div>...<br></div><div>=C2=
=A0987 =C2=A0 =C2=A0 =C2=A0 =C2=A0 start_pfn =3D page_to_pfn(page);<br>

</div><div>=C2=A0988 =C2=A0 =C2=A0 =C2=A0 =C2=A0 start_pfn =3D start_pfn &a=
mp; ~(pageblock_nr_pages-1);</div><div>=C2=A0989 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 start_page =3D pfn_to_page(start_pfn);</div><div>=C2=A0990 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 end_page =3D start_page + pageblock_nr_pages - 1;</div><d=
iv>=C2=A0991 =C2=A0 =C2=A0 =C2=A0 =C2=A0 end_pfn =3D start_pfn + pageblock_=
nr_pages - 1;</div>

<div>=C2=A0992=C2=A0</div><div>=C2=A0993 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Do =
not cross zone boundaries */</div><div>=C2=A0994 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (!zone_spans_pfn(zone, start_pfn))</div><div>=C2=A0995 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 start_page =3D page;</div></div>=
<div><br></div><div>The line 988 will align start_pfn with pageblock_nr_pag=
es,</div>

<div>thus after line988, start_pfn maybe less than=C2=A0zone-&gt;pageblock_=
nr_pages,</div><div>in the worst case, start_pfn maybe outof the range of z=
one-&gt;node pfn.</div><div>and becomes a invalid pfn.</div><div>in this ca=
se, line 989 will be wrong.</div>

<div><br></div><div>so I think the check for start_pfn should be done befor=
e line 989, just like:</div><div><div>=C2=A0 =C2=A0<span style=3D"white-spa=
ce:pre-wrap">		</span>start_pfn =3D start_pfn &amp; ~(pageblock_nr_pages-1)=
; &lt;=3D=3D line 988</div>

<div>=C2=A0 =C2=A0<span style=3D"white-space:pre-wrap">	 	</span>if (!zone_=
spans_pfn(zone, start_pfn))<br></div><div>=C2=A0 =C2=A0<span style=3D"white=
-space:pre-wrap">			</span>start_pfn =3D page_to_pfn(page);</div>
</div><div><br></div><div>Regards,</div><div>Martin</div></div>

--001a113322d4dbc1e004e810cfd0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
