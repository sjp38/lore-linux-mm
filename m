Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6CDB56B038E
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:11:35 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id r141so80364566ita.6
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:11:35 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0118.outbound.protection.outlook.com. [104.47.1.118])
        by mx.google.com with ESMTPS id 125si11261313ite.70.2017.03.06.08.11.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Mar 2017 08:11:34 -0800 (PST)
Subject: Re: [PATCH v2 6/9] kasan: improve slab object description
References: <20170302134851.101218-1-andreyknvl@google.com>
 <20170302134851.101218-7-andreyknvl@google.com>
 <db0b6605-32bc-4c7a-0c99-2e60e4bdb11f@virtuozzo.com>
 <CAG_fn=Vn1tWsRbt4ohkE0E2ijAZsBvVuPS-Ond2KHVh9WK1zkg@mail.gmail.com>
 <2bbe7bdc-8842-8ec0-4b5a-6a8dce39216d@virtuozzo.com>
 <CAAeHK+xnHx5fvhq158+oxMxieG7a+gG7i0MQS92DqxYGe0O=Ww@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <576aeb81-9408-13fa-041d-a6bd1e2cf895@virtuozzo.com>
Date: Mon, 6 Mar 2017 19:12:41 +0300
MIME-Version: 1.0
In-Reply-To: <CAAeHK+xnHx5fvhq158+oxMxieG7a+gG7i0MQS92DqxYGe0O=Ww@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 03/06/2017 04:45 PM, Andrey Konovalov wrote:
> On Fri, Mar 3, 2017 at 3:39 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>>
>>
>> On 03/03/2017 04:52 PM, Alexander Potapenko wrote:
>>> On Fri, Mar 3, 2017 at 2:31 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>>>> On 03/02/2017 04:48 PM, Andrey Konovalov wrote:
>>>>> Changes slab object description from:
>>>>>
>>>>> Object at ffff880068388540, in cache kmalloc-128 size: 128
>>>>>
>>>>> to:
>>>>>
>>>>> The buggy address belongs to the object at ffff880068388540
>>>>>  which belongs to the cache kmalloc-128 of size 128
>>>>> The buggy address is located 123 bytes inside of
>>>>>  128-byte region [ffff880068388540, ffff8800683885c0)
>>>>>
>>>>> Makes it more explanatory and adds information about relative offset
>>>>> of the accessed address to the start of the object.
>>>>>
>>>>
>>>> I don't think that this is an improvement. You replaced one simple line with a huge
>>>> and hard to parse text without giving any new/useful information.
>>>> Except maybe offset, it useful sometimes, so wouldn't mind adding it to description.
>>> Agreed.
>>> How about:
>>> ===========
>>> Access 123 bytes inside of 128-byte region [ffff880068388540, ffff8800683885c0)
>>> Object at ffff880068388540 belongs to the cache kmalloc-128
>>> ===========
>>> ?
>>>
>>
>> I would just add the offset in the end:
>>         Object at ffff880068388540, in cache kmalloc-128 size: 128 accessed at offset y
> 
> Access can be inside or outside the object, so it's better to
> specifically say that.
> 

That what access offset and object's size tells us.


> I think we can do (basically what Alexander suggested):
> 
> Object at ffff880068388540 belongs to the cache kmalloc-128 of size 128
> Access 123 bytes inside of 128-byte region [ffff880068388540, ffff8800683885c0)

This is just wrong and therefore very confusing. The message says that we access 123 bytes,
while in fact we access x-bytes at offset 123. IOW 123 sounds like access size here not the offset.


> What do you think?
> 

Not better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
