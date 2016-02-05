Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id DCCFC440441
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 11:28:43 -0500 (EST)
Received: by mail-oi0-f53.google.com with SMTP id j125so44128765oih.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 08:28:43 -0800 (PST)
Received: from mail-ob0-x229.google.com (mail-ob0-x229.google.com. [2607:f8b0:4003:c01::229])
        by mx.google.com with ESMTPS id o64si8681880oih.12.2016.02.05.08.28.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 08:28:43 -0800 (PST)
Received: by mail-ob0-x229.google.com with SMTP id is5so92093890obc.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 08:28:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1602050300130.13917@east.gentwo.org>
References: <1454566550-28288-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20160204062140.GB14877@js1304-P5Q-DELUXE>
	<alpine.DEB.2.20.1602050300130.13917@east.gentwo.org>
Date: Sat, 6 Feb 2016 01:28:42 +0900
Message-ID: <CAAmzW4Otq7EaxyyPa7tJAjVp3JxdrH2+b+nP=wvffCNdpskC8w@mail.gmail.com>
Subject: Re: [PATCH] mm/slub: support left red zone
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2016-02-05 18:06 GMT+09:00 Christoph Lameter <cl@linux.com>:
> On Thu, 4 Feb 2016, Joonsoo Kim wrote:
>
>> On Thu, Feb 04, 2016 at 03:15:50PM +0900, Joonsoo Kim wrote:
>> > SLUB already has red zone debugging feature. But, it is only positioned
>> > at the end of object(aka right red zone) so it cannot catch left oob.
>> > Although current object's right red zone acts as left red zone of
>> > previous object, first object in a slab cannot take advantage of
>>
>> Oops... s/previous/next.
>>
>> > this effect. This patch explicitly add left red zone to each objects
>> > to detect left oob more precisely.
>
>
> An access before the first object is an access outside of the page
> boundaries of a page allocated by the page allocator for the slab
> allocator since the first object starts at offset 0.
>
>
>
> And the page allocator debugging methods can catch that case.
>
>
> Do we really need this code?

Someone complained to me that left OOB doesn't catched even if
KASAN is enabled which does page allocation debugging.
That page is out of our control so it would be allocated when left
OOB happens and, in this case, we can't find OOB.
Moreover, SLUB debugging feature can be enabled without page
allocator debugging and, in this case, we will miss that OOB.

Before trying to implement, I expected that changes would be
too complex, but, it doesn't look that complex to me now. Almost
changes are applied to debug specific functions so I feel okay.
It is just my feeling so if you think that it's complexity offsets benefit,
I will not strongly insist to merge this patch.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
