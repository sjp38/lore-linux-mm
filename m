Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A84926B007E
	for <linux-mm@kvack.org>; Fri,  6 May 2016 00:25:19 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r12so31902898wme.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 21:25:19 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id n9si15807748wjv.201.2016.05.05.21.25.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 21:25:18 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id w143so7064423wmw.3
        for <linux-mm@kvack.org>; Thu, 05 May 2016 21:25:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160506030935.GA18573@bbox>
References: <1462425447-13385-1-git-send-email-opensource.ganesh@gmail.com>
	<20160505100329.GA497@swordfish>
	<20160506030935.GA18573@bbox>
Date: Fri, 6 May 2016 12:25:18 +0800
Message-ID: <CADAEsF9S4GQE6V+zsvRRVYjdbfN3VRQFcTiN5E_MWw60bfk0Zw@mail.gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: avoid unnecessary iteration in get_pages_per_zspage()
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Hi, Minchan:

2016-05-06 11:09 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> On Thu, May 05, 2016 at 07:03:29PM +0900, Sergey Senozhatsky wrote:
>> On (05/05/16 13:17), Ganesh Mahendran wrote:
>> > if we find a zspage with usage == 100%, there is no need to
>> > try other zspages.
>>
>> Hello,
>>
>> well... we iterate there from 0 to 1<<2, which is not awfully
>> a lot to break it in the middle, and we do this only when we
>> initialize a new pool (for every size class).
>>
>> the check is
>>  - true   15 times
>>  - false  492 times
>
> Thanks for the data, Sergey!
>
>>
>> so it _sort of_ feels like this new if-condition doesn't
>> buy us a lot, and most of the time it just sits there with
>> no particular gain. let's hear from Minchan.
>>
>
> I agree with Sergey.
> First of al, I appreciates your patch, Ganesh! But as Sergey pointed
> out, I don't see why it improves current zsmalloc.

This patch does not obviously improve zsmalloc.
It just reduces unnecessary code path.

>From data provided by Sergey, 15 * (4 -  1) = 45 times loop will be avoided.
So 45 times of below caculation will be reduced:
---
zspage_size = i * PAGE_SIZE;
waste = zspage_size % class_size;
usedpc = (zspage_size - waste) * 100 / zspage_size;

if (usedpc > max_usedpc) {
---

Thanks.

> If you want to merge strongly, please convince me with more detail
> reason.
>
> Thanks.
>
>
>>       -ss
>>
>> > Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
>> > Cc: Minchan Kim <minchan@kernel.org>
>> > Cc: Nitin Gupta <ngupta@vflare.org>
>> > Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
>> > ---
>> >  mm/zsmalloc.c |    3 +++
>> >  1 file changed, 3 insertions(+)
>> >
>> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> > index fda7177..310c7b0 100644
>> > --- a/mm/zsmalloc.c
>> > +++ b/mm/zsmalloc.c
>> > @@ -765,6 +765,9 @@ static int get_pages_per_zspage(int class_size)
>> >             if (usedpc > max_usedpc) {
>> >                     max_usedpc = usedpc;
>> >                     max_usedpc_order = i;
>> > +
>> > +                   if (max_usedpc == 100)
>> > +                           break;
>> >             }
>> >     }
>> >
>> > --
>> > 1.7.9.5
>> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
