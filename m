Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1139D6B0055
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 06:55:39 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so2112157ywm.26
        for <linux-mm@kvack.org>; Tue, 09 Jun 2009 04:30:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <e8f208a7c6bec1818947c24658dc1561.squirrel@webmail-b.css.fujitsu.com>
References: <20090609181505.4083a213.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262360906090300s13f4ee09mcc9622c1e477eaad@mail.gmail.com>
	 <e8f208a7c6bec1818947c24658dc1561.squirrel@webmail-b.css.fujitsu.com>
Date: Tue, 9 Jun 2009 20:30:00 +0900
Message-ID: <28c262360906090430p21125c51g10cfdc377a78d07b@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] fix wrong lru rotate back at lumpty reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, riel@redhat.com
List-ID: <linux-mm.kvack.org>

2009/6/9 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
>
> Minchan Kim wrote:
>> On Tue, Jun 9, 2009 at 6:15 PM, KAMEZAWA
>> Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>>
>>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>>
>>> In lumpty reclaim, "cursor_page" is found just by pfn. Then, we don't
>>> know
>>> from which LRU "cursor" page came from. Then, putback it to "src" list
>>> is BUG.
>>> Just leave it as it is.
>>> (And I think rotate here is overkilling even if "src" is correct.)
>>>
>>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>> ---
>>> mm/vmscan.c | 5 ++---
>>> 1 file changed, 2 insertions(+), 3 deletions(-)
>>>
>>> Index: mmotm-2.6.30-Jun4/mm/vmscan.c
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>> --- mmotm-2.6.30-Jun4.orig/mm/vmscan.c
>>> +++ mmotm-2.6.30-Jun4/mm/vmscan.c
>>> @@ -940,10 +940,9 @@ static unsigned long isolate_lru_pages(u
>>> nr_taken++;
>>> scan++;
>>> break;
>>> -
>>>case -EBUSY:
>>
>> We can remove case -EBUSY itself, too.
>> It is meaningless.
>>
> Sure, will post v2 and remove EBUSY case.
> (I'm sorry my webmail system converts a space to a multibyte char...
> =C2=A0then I cut some.)
>
>>> - /* else it is being freed
>>> elsewhere */
>>> -
>>> list_move(&cursor_page->lru, src);
>>> + =C2=A0/* Do nothing because we
>>> don't know where
>>> + cusrsor_page comes
>>> from */
>>>default:
>>> break; /* ! on LRU or
>>> wrong list */
>>
>> Hmm.. what meaning of this break ?
>> We are in switch case.
>> This "break" can't go out of loop.
> yes.
>
>> But comment said "abort this block scan".
>>
> Where ? the comment says the cursor_page is not on lru (PG_lru is unset)

I mean follow as
 908         /*
 909          * Attempt to take all pages in the order aligned region
 910          * surrounding the tag page.  Only take those pages of
 911          * the same active state as that tag page.  We may safely
 912          * round the target page pfn down to the requested order
 913          * as the mem_map is guarenteed valid out to MAX_ORDER,
 914          * where that page is in a different zone we will detect
 915          * it from its zone id and abort this block scan.
 916          */
 917         zone_id =3D page_zone_id(page);


>> If I understand it properly , don't we add goto phrase ?
>>
> No.

If it is so, the break also is meaningless.

> Just try next page on list.
>
> Thank you for review, I'll post updated one tomorrow.
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
