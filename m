Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id F10AF6B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 03:58:58 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so147911489pab.3
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 00:58:58 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id io6si15608749pbc.166.2015.10.12.00.58.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 00:58:58 -0700 (PDT)
Received: by palb17 with SMTP id b17so18247586pal.2
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 00:58:58 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [RFC] mm: fix a BUG, the page is allocated 2 times
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <561B6379.2070407@suse.cz>
Date: Mon, 12 Oct 2015 15:58:51 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <4D925B19-2187-4892-A99A-E59D575C2147@gmail.com>
References: <1444617606-8685-1-git-send-email-yalin.wang2010@gmail.com> <561B6379.2070407@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, mhocko@suse.com, David Rientjes <rientjes@google.com>, js1304@gmail.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> On Oct 12, 2015, at 15:38, Vlastimil Babka <vbabka@suse.cz> wrote:
>=20
> On 10/12/2015 04:40 AM, yalin wang wrote:
>> Remove unlikely(order), because we are sure order is not zero if
>> code reach here, also add if (page =3D=3D NULL), only allocate page =
again if
>> __rmqueue_smallest() failed or alloc_flags & ALLOC_HARDER =3D=3D 0
>=20
> The second mentioned change is actually more important as it removes a =
memory leak! Thanks for catching this. The problem is in patch =
mm-page_alloc-reserve-pageblocks-for-high-order-atomic-allocations-on-dema=
nd.patch and seems to have been due to a change in the last submitted =
version to make sure the tracepoint is called.
>=20
>> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
>> ---
>>  mm/page_alloc.c | 6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>=20
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 0d6f540..de82e2c 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2241,13 +2241,13 @@ struct page *buffered_rmqueue(struct zone =
*preferred_zone,
>>  		spin_lock_irqsave(&zone->lock, flags);
>>=20
>>  		page =3D NULL;
>> -		if (unlikely(order) && (alloc_flags & ALLOC_HARDER)) {
>> +		if (alloc_flags & ALLOC_HARDER) {
>>  			page =3D __rmqueue_smallest(zone, order, =
MIGRATE_HIGHATOMIC);
>>  			if (page)
>>  				trace_mm_page_alloc_zone_locked(page, =
order, migratetype);
>>  		}
>> -
>> -		page =3D __rmqueue(zone, order, migratetype, gfp_flags);
>> +		if (page =3D=3D NULL)
>=20
> "if (!page)" is more common and already used below.
> We could skip the check for !page in case we don't go through the =
ALLOC_HARDER branch, but I guess it's not worth the goto, and hopefully =
the compiler is smart enough anyway=E2=80=A6
agree with your comments,
do i need send a new patch for this ?

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
