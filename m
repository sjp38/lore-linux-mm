Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CA6216B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 18:54:03 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so876612ywm.26
        for <linux-mm@kvack.org>; Thu, 11 Jun 2009 15:55:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d3a71da3a374d278e5fb0b1f2cdff71e.squirrel@webmail-b.css.fujitsu.com>
References: <20090611165535.cf46bf29.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090611170152.7a43b13b.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090611172249.6D3C.A69D9226@jp.fujitsu.com>
	 <20090611173819.0f76e431.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262360906110237u1f3d1877hae54a51575955549@mail.gmail.com>
	 <9d4a7c0691aa5e13247f694f2dfe55ad.squirrel@webmail-b.css.fujitsu.com>
	 <28c262360906110459s923d7a6p4e555344e8bbd265@mail.gmail.com>
	 <d3a71da3a374d278e5fb0b1f2cdff71e.squirrel@webmail-b.css.fujitsu.com>
Date: Fri, 12 Jun 2009 07:55:44 +0900
Message-ID: <28c262360906111555p19ca20b1m2785abddb41678dc@mail.gmail.com>
Subject: Re: [PATCH 2/3] check unevictable flag in lumy reclaim v2
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, apw@canonical.com, riel@redhat.com, mel@csn.ul.ie, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

2009/6/11 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
> Minchan Kim wrote:
>> 2009/6/11 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
>>> Minchan Kim =E3=81=95=E3=82=93 wrote:
>>>> On Thu, Jun 11, 2009 at 5:38 PM, KAMEZAWA
>>>> Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>>>> How about this ?
>>>>>
>>>>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>>>>
>>>>> Lumpy reclaim check pages from their pfn. Then, it can find
>>>>> unevictable
>>>>> pages
>>>>> in its loop.
>>>>> Abort lumpy reclaim when we find Unevictable page, we never get a lum=
p
>>>>> of pages for requested order.
>>>>>
>>>>> Changelog: v1->v2
>>>>> ?- rewrote commet.
>>>>>
>>>>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>>>> ---
>>>>> ?mm/vmscan.c | ? ?9 +++++++++
>>>>> ?1 file changed, 9 insertions(+)
>>>>>
>>>>> Index: lumpy-reclaim-trial/mm/vmscan.c
>>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>>> --- lumpy-reclaim-trial.orig/mm/vmscan.c
>>>>> +++ lumpy-reclaim-trial/mm/vmscan.c
>>>>> @@ -936,6 +936,15 @@ static unsigned long isolate_lru_pages(u
>>>>> ? ? ? ? ? ? ? ? ? ? ? ?/* Check that we have not crossed a zone
>>>>> boundary. */
>>>>> ? ? ? ? ? ? ? ? ? ? ? ?if (unlikely(page_zone_id(cursor_page) !=3D
>>>>> zone_id))
>>>>> ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?continue;
>>>>> + ? ? ? ? ? ? ? ? ? ? ? /*
>>>>> + ? ? ? ? ? ? ? ? ? ? ? ?* We tries to free all pages in this range t=
o
>>>>> create
>>>>> + ? ? ? ? ? ? ? ? ? ? ? ?* a free large page. Then, if the range
>>>>> includes a page
>>>>> + ? ? ? ? ? ? ? ? ? ? ? ?* never be reclaimed, we have no reason to d=
o
>>>>> more.
>>>>> + ? ? ? ? ? ? ? ? ? ? ? ?* PageUnevictable page is not a page which
>>>>> can
>>>>> be
>>>>> + ? ? ? ? ? ? ? ? ? ? ? ?* easily freed. Abort this scan now.
>>>>> + ? ? ? ? ? ? ? ? ? ? ? ?*/
>>>>> + ? ? ? ? ? ? ? ? ? ? ? if (unlikely(PageUnevictable(cursor_page)))
>>>>> + ? ? ? ? ? ? ? ? ? ? ? ? ? ? ? break;
>>>>
>>>> __isolate_lru_pages already checked PageUnevictable to return error.
>>>> I want to remove repeated check although it is trivial.
>>>>
>>>> By your patch, It seems to remove PageUnevictable check in
>>>> __isolate_lru_pages.
>>>>
>>> yes.
>>>
>>>> But I know that. If we remove PageUnevictable check in
>>>> __isolate_lru_pages, it can't go into BUG in non-lumpy case. ( I
>>>> mentioned following as code)
>>>>
>>> In non-lumpy case, we'll never see Unevictable, maybe.
>>
>> I think so if it doesn't happen RAM failure.
>> AFAIK, Unevictable check didn't related with RAM failure.
>>
>>>
>>>> ? ? ? ? ? ? ? ? case -EBUSY:
>>>> ? ? ? ? ? ? ? ? ? ? ? ? /* else it is being freed elsewhere */
>>>> ? ? ? ? ? ? ? ? ? ? ? ? list_move(&page->lru, src);
>>>> ? ? ? ? ? ? ? ? ? ? ? ? continue;
>>>>
>>>> ? ? ? ? ? ? ? ? default:
>>>> ? ? ? ? ? ? ? ? ? ? ? ? BUG();
>>>> ? ? ? ? ? ? ? ? }
>>>>
>>>>
>>>> It means we can remove BUG in non-lumpy case and then add BUG into
>>>> __isolate_lru_pages directly.
>>>>
>>>> If we can do it, we can remove unnecessary PageUnevictable check in
>>>> __isolate_lru_page.
>>>>
>>> Hmm, but Unevicable check had tons of troubles at its implementation
>>> and I don't want to do it at once.
>>
>> I think it's not a big problem.
>> As comment said, the check's goal is to prevent in lumpy case.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* When this function is being called f=
or lumpy reclaim, we
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* initially look into all LRU pages, a=
ctive, inactive and
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* unevictable; only give shrink_page_l=
ist evictable pages.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageUnevictable(page))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
>>
>> So I think we can remove this check.
>>
> agreed.
>
>>>> I am not sure this is right in case of memcg.
>>>>
>>> I think we don't see Unevictable in memcg's path if my memcg-lru code
>>> works as designed.
>>>
>>> I'll postpone this patch for a while until my brain works well.
>>
>> If you have a concern about that, how about this ?
>> (This code will be hunk since gmail webserver always mangle. Pz,forgive
>> me)
>> Also, we can CC original authors.
>>
> I'll schedule this optimization/clean up for unevictable case in queue.
> Thank you for inputs.
>
> But it's now merge-window, I'd like to push bugfix first.(1/3 and 3/3)

I agree. It's more important now.

> I'd like to scheule Unevictable case fix after rc1(when mmotm stack seems
> to be pushed out to Linus.)
> And I'll add
> int __isolate_lru_page(...)
> {
> =C2=A0 =C2=A0 VM_BUG_ON(PageUnevictable(page));
> }
> as sanity check for mmotm test time.
>
> Thank you for all your help.

I also thanks you for considering my comment.

You may add my review sign. :)
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

> -Kame
>
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
