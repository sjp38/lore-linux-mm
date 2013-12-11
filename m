Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 66CC16B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 20:40:17 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id g10so8572830pdj.1
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 17:40:16 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id ts1si11937764pbc.170.2013.12.10.17.40.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 17:40:15 -0800 (PST)
Message-ID: <52A7C16A.9040106@huawei.com>
Date: Wed, 11 Dec 2013 09:35:38 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm,x86: fix span coverage in e820_all_mapped()
References: <52A6D9B0.7040506@huawei.com> <CAE9FiQUd+sU4GEq0687u8+26jXJiJVboN90+L7svyosmm+V1Rg@mail.gmail.com>
In-Reply-To: <CAE9FiQUd+sU4GEq0687u8+26jXJiJVboN90+L7svyosmm+V1Rg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On 2013/12/11 5:06, Yinghai Lu wrote:

> On Tue, Dec 10, 2013 at 1:06 AM, Xishi Qiu <qiuxishi@huawei.com> wrote:
>> In the following case, e820_all_mapped() will return 1.
>> A < start < B-1 and B < end < C, it means <start, end> spans two regions.
>> <start, end>:           [start - end]
>> e820 addr:          ...[A - B-1][B - C]...
> 
> should be [start, end) right?
> and
> [A, B),[B, C)
> 

Hi Yinghai,

It is right, in this case the function will return 1.

>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>> ---
>>  arch/x86/kernel/e820.c |   15 +++------------
>>  1 files changed, 3 insertions(+), 12 deletions(-)
>>
>> diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
>> index 174da5f..31ecab2 100644
>> --- a/arch/x86/kernel/e820.c
>> +++ b/arch/x86/kernel/e820.c
>> @@ -85,20 +85,11 @@ int __init e820_all_mapped(u64 start, u64 end, unsigned type)
>>
>>                 if (type && ei->type != type)
>>                         continue;
>> -               /* is the region (part) in overlap with the current region ?*/
>> +               /* is the region (part) in overlap with the current region ? */
>>                 if (ei->addr >= end || ei->addr + ei->size <= start)
>>                         continue;
>> -
>> -               /* if the region is at the beginning of <start,end> we move
>> -                * start to the end of the region since it's ok until there
>> -                */
>> -               if (ei->addr <= start)
>> -                       start = ei->addr + ei->size;
> 
> so in your case new start will be B ?
> 
> next run will be C
> 
>> -               /*
>> -                * if start is now at or beyond end, we're done, full
>> -                * coverage
>> -                */
>> -               if (start >= end)
> 
> 
>> +               /* is the region full coverage of <start, end> ? */
>> +               if (ei->addr <= start && ei->addr + ei->size >= end)
>>                         return 1;
>>         }
>>         return 0;
> 
> also e820 should be sanitized already to have [A,C).
> 

Yes, it should be sanitized already, but maybe someone will change the e820
to support some feature, so this function will be a potential bomb.

> or you are talking about [A,B), [B+1, C)
> first run start will be B,  and next run with [B+1, ...), that will be
> skipped...
> will not return 1.
> 
> so old code should be ok.
> 

In this case, old code is right, but I discuss in another one that
you wrote above.

Thanks,
Xishi Qiu

> Thanks
> 
> Yinghai
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
