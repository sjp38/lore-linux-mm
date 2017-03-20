Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 88E1F6B0388
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 11:38:28 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g2so287607019pge.7
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 08:38:28 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10103.outbound.protection.outlook.com. [40.107.1.103])
        by mx.google.com with ESMTPS id q2si17897434pge.319.2017.03.20.08.38.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 20 Mar 2017 08:38:27 -0700 (PDT)
Subject: Re: [PATCH v2 6/9] kasan: improve slab object description
References: <20170302134851.101218-1-andreyknvl@google.com>
 <20170302134851.101218-7-andreyknvl@google.com>
 <db0b6605-32bc-4c7a-0c99-2e60e4bdb11f@virtuozzo.com>
 <CAG_fn=Vn1tWsRbt4ohkE0E2ijAZsBvVuPS-Ond2KHVh9WK1zkg@mail.gmail.com>
 <2bbe7bdc-8842-8ec0-4b5a-6a8dce39216d@virtuozzo.com>
 <CAAeHK+xnHx5fvhq158+oxMxieG7a+gG7i0MQS92DqxYGe0O=Ww@mail.gmail.com>
 <576aeb81-9408-13fa-041d-a6bd1e2cf895@virtuozzo.com>
 <CAAeHK+w087z_pEWN=ZBDZN=XqqQMFZ9eevX44LERFV-d=G3F8g@mail.gmail.com>
 <CAAeHK+xCo+JcFstGz+xhgX2qvkP1zpwOg9VD0N-oD4Q=YcSi7A@mail.gmail.com>
 <69679f30-e502-d2cf-8dee-4ee88f64f887@virtuozzo.com>
 <CAAeHK+yMCqcLW1UbJ+iEG5628wO6j=d9a7cRdPTbZTBoK-CfbQ@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <4220fac8-b193-e1f7-5f31-3614ce4bef9e@virtuozzo.com>
Date: Mon, 20 Mar 2017 18:39:42 +0300
MIME-Version: 1.0
In-Reply-To: <CAAeHK+yMCqcLW1UbJ+iEG5628wO6j=d9a7cRdPTbZTBoK-CfbQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 03/14/2017 08:15 PM, Andrey Konovalov wrote:
> On Thu, Mar 9, 2017 at 1:56 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>> On 03/06/2017 08:16 PM, Andrey Konovalov wrote:
>>
>>>>
>>>> What about
>>>>
>>>> Object at ffff880068388540 belongs to cache kmalloc-128 of size 128
>>>> Accessed address is 123 bytes inside of [ffff880068388540, ffff8800683885c0)
>>>>
>>>> ?
>>>
>>> Another alternative:
>>>
>>> Accessed address is 123 bytes inside of [ffff880068388540, ffff8800683885c0)
>>> Object belongs to cache kmalloc-128 of size 128
>>>
>>
>> Is it something wrong with just printing offset at the end as I suggested earlier?
>> It's more compact and also more clear IMO.
> 
> This is what you suggested:
> 
> Object at ffff880068388540, in cache kmalloc-128 size: 128 accessed at
> offset 123
> 
> After minor reworking of punctuation, etc, we get:
> 
> Object at ffff880068388540, in cache kmalloc-128 of size 128, accessed
> at offset 123
> 
> It's good, but I still don't like two things:
> 
> 1. The line is quite long. Over 84 characters in this example, but
> might be longer for different cache names. The solution would be to
> split it into two lines.

One line slightly larger than 80 chars is easier to read than
two IMO.

> 
> 2. The access might be within the object (for example use-after-free),
> or outside the object (slab-out-of-bounds). In this case just saying
> "accessed at offset X" might be confusing, since the offset might be
> from the start of the object, or might be from the end. The solution
> would be to specifically describe this.
> 

It's not confusing IMO.
It's pretty obvious that offset in the message "Object at <addr> ... accessed at offset <x>" 
specifies the offset from the start of the object.


> Out of all options above this one I like the most:
>
>>> Accessed address is 123 bytes inside of [ffff880068388540, ffff8800683885c0)
>>> Object belongs to cache kmalloc-128 of size 128
> 
> as:
> 
> 1. It specifies whether the offset is inside or outside the object.

It doesn't really matter much whether is offset inside or outside.
Offset is only useful to identify what exactly struct/field accessed in situation like this:
  x = a->b->c->d;
In other cases it usually just useless. 

Also, note that you comparing access_addr against cache->object_size (which may be not equal to
the size requested by kmalloc)

+	if (access_addr < object_addr) {
+		rel_type = "to the left";
+		rel_bytes = object_addr - access_addr;
+	} else if (access_addr >= object_addr + cache->object_size) {
+		rel_type = "to the right";
+		rel_bytes = access_addr - (object_addr + cache->object_size);
+	} else {
+		rel_type = "inside";
+		rel_bytes = access_addr - object_addr;
+	}
+

So let's say we did kmalloc(100, GFP_KERNEL); This would mean that allocation
was from kmalloc-128 cache.

 a) If we have off-by-one OOB access, we would see:
	Accessed address is 100 bytes inside of [<start>, <start> + 128)
	belongs to cache kmalloc-128 of size 128

 b) And for the off-by-28 OOB, we would see:
	Accessed address is 0 bytes to the right [<start>, <start> + 128)
	belongs to cache kmalloc-128 of size 128

But I don't really see why we supposed to have different message for case a) b).

Comparing against requested size is possible only by looking into shadow. However that would
be complicated and also racy which means that you occasionally end up with some random numbers.

Also, I couldn't imagine why would anyone need to know the offset from the end of the object.

> 2. The lines are not too long (the first one is 76 chars).
> 3. Accounts for larger cache names (the second line has some spare space).
> 4. Shows exact addresses of start and end of the object (it's possible
> to calculate the end address using the start and the size, but it's
> nicer to have it already calculated and shown).

Come on we can do the simple math if needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
