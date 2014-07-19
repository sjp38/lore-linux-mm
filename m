Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 92BCE6B0035
	for <linux-mm@kvack.org>; Sat, 19 Jul 2014 09:51:19 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id n12so4704660wgh.9
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 06:51:19 -0700 (PDT)
Received: from mail-we0-x22f.google.com (mail-we0-x22f.google.com [2a00:1450:400c:c03::22f])
        by mx.google.com with ESMTPS id k10si16996152wjf.110.2014.07.19.06.51.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Jul 2014 06:51:18 -0700 (PDT)
Received: by mail-we0-f175.google.com with SMTP id t60so5584160wes.6
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 06:51:17 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] CMA/HOTPLUG: clear buffer-head lru before page migration
In-Reply-To: <53C8D970.4000908@lge.com>
References: <53C8C290.90503@lge.com> <53C8D1CA.9070102@samsung.com> <53C8D970.4000908@lge.com>
Date: Sat, 19 Jul 2014 15:51:13 +0200
Message-ID: <xa1tmwc578z2.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, =?utf-8?B?J+q5gOykgOyImCc=?= <iamjoonsoo.kim@lge.com>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, 'Chanho Min' <chanho.min@lge.com>

>> On 2014-07-18 08:45, Gioh Kim wrote:
>>> From: Gioh Kim <gioh.kim@lge.com>
>>> Date: Fri, 18 Jul 2014 13:40:01 +0900
>>> Subject: [PATCH] CMA/HOTPLUG: clear buffer-head lru before page migrati=
on
>>>
>>> The bh must be free to migrate a page at which bh is mapped.
>>> The reference count of bh is increased when it is installed
>>> into lru so that the bh of lru must be freed before migrating the page.
>>>
>>> This frees every bh of lru. We could free only bh of migrating page.
>>> But searching lru costs more than invalidating entire lru.
>>>
>>> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
>>> Acked-by: Laura Abbott <lauraa@codeaurora.org>

With the if removed:

Acked-by: Michal Nazarewicz <mina86@mina86.com>

>>> ---
>>>   mm/page_alloc.c |    3 +++
>>>   1 file changed, 3 insertions(+)
>>>
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index b99643d4..3b474e0 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -6369,6 +6369,9 @@ int alloc_contig_range(unsigned long start, unsig=
ned long end,
>>>          if (ret)
>>>                  return ret;
>>>
>>> +       if (migratetype =3D=3D MIGRATE_CMA || migratetype =3D=3D MIGRAT=
E_MOVABLE)

On Fri, Jul 18 2014, Gioh Kim <gioh.kim@lge.com> wrote:
> I agree. I cannot understand why alloc_contig_range has an argument of
> migratetype.  Can the alloc_contig_range is called for other migrate
> type than CMA/MOVABLE?

It has migratetype argument precisely because it can be CMA or MOVABLE.
If alloc_contig_range was called always with the same migrate type, the
argument would not be necessary, but because it isn't, it is.

> What do you think about removing the argument of migratetype and
> checking migratetype (if (migratetype =3D=3D MIGRATE_CMA || migratetype =
=3D=3D
> MIGRATE_MOVABLE))?

If you remove the argument, the function would have to read migrate type
of the pageblock and that's just waste of time, since the migrate type
can be passed to the function from its caller, so the argument should
remain.

>>> +               invalidate_bh_lrus();
>>> +
>>>          ret =3D __alloc_contig_migrate_range(&cc, start, end);
>>>          if (ret)
>>>                  goto done;

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
