Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f54.google.com (mail-lf0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6BB1B6B0255
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 09:34:46 -0500 (EST)
Received: by mail-lf0-f54.google.com with SMTP id j186so40120842lfg.2
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 06:34:46 -0800 (PST)
Received: from mail-lf0-x234.google.com (mail-lf0-x234.google.com. [2a00:1450:4010:c07::234])
        by mx.google.com with ESMTPS id av2si14483457lbc.8.2016.03.01.06.34.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 06:34:44 -0800 (PST)
Received: by mail-lf0-x234.google.com with SMTP id l13so2512168lfb.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 06:34:44 -0800 (PST)
Subject: Re: [PATCH v4 2/7] mm, kasan: SLAB support
References: <cover.1456504662.git.glider@google.com>
 <5c5a22a3daee19ff5940605b946dc144515ebd63.1456504662.git.glider@google.com>
 <56D45F67.8050508@gmail.com>
 <CAG_fn=X29ejm6dBQKhu6i41aY6cf-DCdyL7D8qEwrAKbH+z1+A@mail.gmail.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <56D5A884.5000803@gmail.com>
Date: Tue, 1 Mar 2016 17:34:44 +0300
MIME-Version: 1.0
In-Reply-To: <CAG_fn=X29ejm6dBQKhu6i41aY6cf-DCdyL7D8qEwrAKbH+z1+A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev@googlegroups.com, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>



On 02/29/2016 09:28 PM, Alexander Potapenko wrote:

>>>  static void print_address_description(struct kasan_access_info *info)
>>>  {
>>>       const void *addr = info->access_addr;
>>> @@ -126,17 +164,14 @@ static void print_address_description(struct kasan_access_info *info)
>>>               if (PageSlab(page)) {
>>>                       void *object;
>>>                       struct kmem_cache *cache = page->slab_cache;
>>> -                     void *last_object;
>>> -
>>> -                     object = virt_to_obj(cache, page_address(page), addr);
>>> -                     last_object = page_address(page) +
>>> -                             page->objects * cache->size;
>>> -
>>> -                     if (unlikely(object > last_object))
>>> -                             object = last_object; /* we hit into padding */
>>> -
>>> +                     object = nearest_obj(cache, page,
>>> +                                             (void *)info->access_addr);
>>> +#ifdef CONFIG_SLAB
>>> +                     print_object(cache, object);
>>> +#else
>>
>> Instead of these ifdefs, please, make universal API for printing object's information.
> My intention here was to touch the SLUB functionality as little as
> possible to avoid the mess and feature regressions.
> I'll be happy to refactor the code in the upcoming patches once this
> one is landed.
> 

Avoid mess? You create one.
Although I don't understand that don't touch slub thing, but you can just
have object_err(cache, page, str) for slab without touching slub.

>>>                       object_err(cache, page, object,
>>> -                             "kasan: bad access detected");
>>> +                                     "kasan: bad access detected");
>>> +#endif
>>>                       return;
>>>               }
>>>               dump_page(page, "kasan: bad access detected");
>>> @@ -146,8 +181,9 @@ static void print_address_description(struct kasan_access_info *info)
>>>               if (!init_task_stack_addr(addr))
>>>                       pr_err("Address belongs to variable %pS\n", addr);
>>>       }
>>> -
>>> +#ifdef CONFIG_SLUB
>>
>> ???
> Not sure what did you mean here, assuming this comment is related to
> the next one.
>>
>>>       dump_stack();
>>> +#endif
>>>  }
>>>
>>>  static bool row_is_guilty(const void *row, const void *guilty)
>>> @@ -233,6 +269,9 @@ static void kasan_report_error(struct kasan_access_info *info)
>>>               dump_stack();
>>>       } else {
>>>               print_error_description(info);
>>> +#ifdef CONFIG_SLAB
>>
>> I'm lost here. What's the point of reordering dump_stack() for CONFIG_SLAB=y?
> I should have documented this in the patch description properly.
> My intention is to make the KASAN reports look more like those in the
> userspace AddressSanitizer, so I'm moving the memory access stack to
> the top of the report.
> Having seen hundreds and hundreds of ASan reports, we believe that
> important information must go at the beginning of the error report.
> First, people usually do not need to read further once they see the
> access stack.
> Second, the whole report may simply not make it to the log (e.g. in
> the case of a premature shutdown or remote log collection).
>
> As said before, I wasn't going to touch the SLUB output format in this
> patch set, but that also needs to be fixed (I'd also remove some
> unnecessary info, e.g. the memory dump).
>

That's all sounds fine, but this doesn't explain:
a) How this change related to this patch? (the answer is - it doesn't).
b) Why the output of non sl[a,u]b bugs depends on CONFIG_SL[A,U]B ?
 
So, in SLAB's print_objects() you can print stacks in whatever order you like.
That's it, don't change anything else here.

If you are not satisfied with current format output, change it, but in separate patch[es],
with reasoning described in changelog and without weird config dependencies.




>>> +             dump_stack();
>>> +#endif
>>>               print_address_description(info);
>>>               print_shadow_for_address(info->first_bad_addr);
>>>       }
>>> diff --git a/mm/slab.c b/mm/slab.c
>>> index 621fbcb..805b39b 100644
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
