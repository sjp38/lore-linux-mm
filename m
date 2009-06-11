Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8362E6B0055
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 05:37:50 -0400 (EDT)
Received: by gxk28 with SMTP id 28so2142076gxk.14
        for <linux-mm@kvack.org>; Thu, 11 Jun 2009 02:39:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <28c262360906110237u1f3d1877hae54a51575955549@mail.gmail.com>
References: <20090611165535.cf46bf29.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090611170152.7a43b13b.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090611172249.6D3C.A69D9226@jp.fujitsu.com>
	 <20090611173819.0f76e431.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262360906110237u1f3d1877hae54a51575955549@mail.gmail.com>
Date: Thu, 11 Jun 2009 18:39:01 +0900
Message-ID: <28c262360906110239g1e4d0fabg15dc33111014e96a@mail.gmail.com>
Subject: Re: [PATCH 2/3] check unevictable flag in lumy reclaim v2
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, apw@canonical.com, riel@redhat.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Thu, Jun 11, 2009 at 6:37 PM, Minchan Kim<minchan.kim@gmail.com> wrote:
> On Thu, Jun 11, 2009 at 5:38 PM, KAMEZAWA
> Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> How about this ?
>>
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> Lumpy reclaim check pages from their pfn. Then, it can find unevictable =
pages
>> in its loop.
>> Abort lumpy reclaim when we find Unevictable page, we never get a lump
>> of pages for requested order.
>>
>> Changelog: v1->v2
>> =C2=A0- rewrote commet.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>> =C2=A0mm/vmscan.c | =C2=A0 =C2=A09 +++++++++
>> =C2=A01 file changed, 9 insertions(+)
>>
>> Index: lumpy-reclaim-trial/mm/vmscan.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- lumpy-reclaim-trial.orig/mm/vmscan.c
>> +++ lumpy-reclaim-trial/mm/vmscan.c
>> @@ -936,6 +936,15 @@ static unsigned long isolate_lru_pages(u
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0/* Check that we have not crossed a zone boundary. */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0if (unlikely(page_zone_id(cursor_page) !=3D zone_id))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* We tries to free all pages in this range to create
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* a free large page. Then, if the range includes a page
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* never be reclaimed, we have no reason to do more.
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* PageUnevictable page is not a page which can be
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* easily freed. Abort this scan now.
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (unlikely(PageUnevictable(cursor_page)))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>
> __isolate_lru_pages already checked PageUnevictable to return error.
> I want to remove repeated check although it is trivial.
>
> By your patch, It seems to remove PageUnevictable check in __isolate_lru_=
pages.

typo.

It seems we can remove PageUnevictable check in __isolate_lru_pages.
Sorry for noise.

> But I know that. If we remove PageUnevictable check in
> __isolate_lru_pages, it can't go into BUG in non-lumpy case. ( I
> mentioned following as code)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0case -EBUSY:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/* else it is being freed elsewhere */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0list_move(&page->lru, src);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0default:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0BUG();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
>
> It means we can remove BUG in non-lumpy case and then add BUG into
> __isolate_lru_pages directly.
>
> If we can do it, we can remove unnecessary PageUnevictable check in
> __isolate_lru_page.
>
> I am not sure this is right in case of memcg.
>
> --
> Kinds regards,
> Minchan Kim
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
