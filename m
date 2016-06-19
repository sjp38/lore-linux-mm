Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A11DA6B007E
	for <linux-mm@kvack.org>; Sat, 18 Jun 2016 22:49:28 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id ru5so26001884obc.2
        for <linux-mm@kvack.org>; Sat, 18 Jun 2016 19:49:28 -0700 (PDT)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id y9si305510itc.49.2016.06.18.19.49.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 Jun 2016 19:49:27 -0700 (PDT)
Received: by mail-io0-x242.google.com with SMTP id 5so14673718ioy.0
        for <linux-mm@kvack.org>; Sat, 18 Jun 2016 19:49:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACygaLAU-PiB8UDR0i9FYbTuH8vBKJRFxufGOVoWCmqPad-XZQ@mail.gmail.com>
References: <1466242457-2440-1-git-send-email-wwtao0320@163.com>
 <57651F0F.2010506@suse.cz> <CACygaLAU-PiB8UDR0i9FYbTuH8vBKJRFxufGOVoWCmqPad-XZQ@mail.gmail.com>
From: Wenwei Tao <ww.tao0320@gmail.com>
Date: Sun, 19 Jun 2016 10:49:26 +0800
Message-ID: <CACygaLBJTcLvQVwzqADYtXNeYJQ77vMaghfezT_2ofB2NwaESg@mail.gmail.com>
Subject: Fwd: [RFC PATCH 1/3] mm, page_alloc: free HIGHATOMIC page directly to
 the allocator
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,
The original message is somehow determined to be junk mail and
rejected by the system.
Forward this message.

---------- Forwarded message ----------
From: Wenwei Tao <ww.tao0320@gmail.com>
Date: 2016-06-19 10:40 GMT+08:00
Subject: Re: [RFC PATCH 1/3] mm, page_alloc: free HIGHATOMIC page
directly to the allocator
To: Vlastimil Babka <vbabka@suse.cz>
=E6=8A=84=E9=80=81=EF=BC=9A Wenwei Tao <wwtao0320@163.com>, akpm@linux-foun=
dation.org,
mgorman@techsingularity.net, mhocko@suse.com, rientjes@google.com,
kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com,
izumi.taku@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>,
linux-kernel@vger.kernel.org, linux-mm@kvack.org


2016-06-18 18:14 GMT+08:00 Vlastimil Babka <vbabka@suse.cz>:
> On 06/18/2016 11:34 AM, Wenwei Tao wrote:
>> From: Wenwei Tao <ww.tao0320@gmail.com>
>>
>> Some pages might have already been allocated before reserve
>> the pageblock as HIGHATOMIC. When free these pages, put them
>> directly to the allocator instead of the pcp lists since they
>> might have the chance to be merged to high order pages.
>
> Are there some data showing the improvement, or just theoretical?
>

It's just theoretical. I read the mm code and try to understand it,
think this might be an optimization.

>> Signed-off-by: Wenwei Tao <ww.tao0320@gmail.com>
>> ---
>>  mm/page_alloc.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 6903b69..19f9e76 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2412,7 +2412,8 @@ void free_hot_cold_page(struct page *page, bool co=
ld)
>
> The full comment that's here for context:
>
> /*
>  * We only track unmovable, reclaimable and movable on pcp lists.
>  * Free ISOLATE pages back to the allocator because they are being
>  * offlined but treat RESERVE as movable pages so we can get those
>  * areas back if necessary. Otherwise, we may have to free
>  * excessively into the page allocator
>  */
>
> That comment looks outdated as it refers to RESERVE, which was replaced
> by HIGHATOMIC. But there's some reasoning why these pages go to
> pcplists. I'd expect the "free excessively" part isn't as bad as
> highatomic reserves are quite limited. They also shouldn't be used for
> order-0 allocations, which is what this function is about, so I would
> expect both the impact on "free excessively" and the improvement of
> merging to be minimal?
>
>>        * excessively into the page allocator
>>        */
>>       if (migratetype >=3D MIGRATE_PCPTYPES) {
>> -             if (unlikely(is_migrate_isolate(migratetype))) {
>> +             if (unlikely(is_migrate_isolate(migratetype) ||
>> +                             migratetype =3D=3D MIGRATE_HIGHATOMIC)) {
>>                       free_one_page(zone, page, pfn, 0, migratetype);
>>                       goto out;
>>               }
>
> In any case your patch highlighted that this code could be imho
> optimized like below.
>
> if (unlikely(migratetype >=3D MIGRATE_PCPTYPES))
>    if (is_migrate_cma(migratetype)) {
>        migratetype =3D MIGRATE_MOVABLE;
>    } else {
>        free_one_page(zone, page, pfn, 0, migratetype);
>        goto out;
>    }
> }
>
> That's less branches than your patch, and even less than originally if
> CMA is not enabled (or with ZONE_CMA).

Yeah, this looks better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
