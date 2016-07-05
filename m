Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D24C6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 00:35:47 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u128so65752009qkd.0
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 21:35:47 -0700 (PDT)
Received: from mail-vk0-x230.google.com (mail-vk0-x230.google.com. [2607:f8b0:400c:c05::230])
        by mx.google.com with ESMTPS id 96si2078611uar.238.2016.07.04.21.35.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 21:35:46 -0700 (PDT)
Received: by mail-vk0-x230.google.com with SMTP id i63so80815102vkb.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 21:35:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPAsAGxj61=trcAAPqODX1Z7vV=7-faG1oJBL5WCn=rBXAsvNA@mail.gmail.com>
References: <1467394698-142163-1-git-send-email-dvyukov@google.com> <CAPAsAGxj61=trcAAPqODX1Z7vV=7-faG1oJBL5WCn=rBXAsvNA@mail.gmail.com>
From: Kuthonuzo Luruo <poll.stdin@gmail.com>
Date: Tue, 5 Jul 2016 10:05:45 +0530
Message-ID: <CAHPzcFkCSG03+HkW=owM7WqOJ1J9-Zo7wL3raQTxEmce+uAfpg@mail.gmail.com>
Subject: Re: [PATCH] kasan: make depot_fetch_stack more robust
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>

On Mon, Jul 4, 2016 at 8:11 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
> 2016-07-01 20:38 GMT+03:00 Dmitry Vyukov <dvyukov@google.com>:
>> I've hit a GPF in depot_fetch_stack when it was given
>> bogus stack handle. I think it was caused by a distant
>> out-of-bounds that hit a different object, as the result
>> we treated uninit garbage as stack handle. Maybe there is
>> something to fix in KASAN logic, but I think it makes
>> sense to make depot_fetch_stack more robust as well.
>>
>> Verify that the provided stack handle looks correct.
>>

> I don't think that adding the kernel code to work around bugs in the
> kernel code makes a lot of sense.
> depot_fetch_stack() fails if invalid handler is passed, and that is a
> bug. You can just add WARN_ON() in
> depot_fetch_stack() if you want to detect such cases..

In this case, the code happens to be a debugging tool that actively anticipates
bad memory accesses. If the tool can reliably detect bad input that could
potentially cause a crash inside the debugger itself, and take actions
to prevent it,
I believe that's a good thing.

> Note that KASAN detects corruption of object's metadata, so such check
> may help only in case of
> corruption page owner's data.

It will also help in case of bad access by non-instrumented code.

>
>>         if (page_ext->last_migrate_reason != -1) {
>>                 ret += snprintf(kbuf + ret, count - ret,
>> @@ -307,12 +308,11 @@ void __dump_page_owner(struct page *page)
>>         }
>>
>>         handle = READ_ONCE(page_ext->handle);
>> -       if (!handle) {
>> +       if (!depot_fetch_stack(handle, &trace)) {
>>                 pr_alert("page_owner info is not active (free page?)\n");
>>                 return;
>>         }
>>
>> -       depot_fetch_stack(handle, &trace);
>>         pr_alert("page allocated via order %u, migratetype %s, gfp_mask %#x(%pGg)\n",
>>                  page_ext->order, migratetype_names[mt], gfp_mask, &gfp_mask);
>>         print_stack_trace(&trace, 0);
>> --
>> 2.8.0.rc3.226.g39d4020
>>
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/CAPAsAGxj61%3DtrcAAPqODX1Z7vV%3D7-faG1oJBL5WCn%3DrBXAsvNA%40mail.gmail.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
