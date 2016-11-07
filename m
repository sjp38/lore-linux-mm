Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD5DF6B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 11:50:48 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 23so122222161uat.4
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 08:50:48 -0800 (PST)
Received: from mail-ua0-x22f.google.com (mail-ua0-x22f.google.com. [2607:f8b0:400c:c08::22f])
        by mx.google.com with ESMTPS id g21si7686378vkc.113.2016.11.07.08.50.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 08:50:47 -0800 (PST)
Received: by mail-ua0-x22f.google.com with SMTP id b35so124519976uaa.3
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 08:50:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <a40cccff-3a6e-b0be-5d06-bac6cdb0e1e6@virtuozzo.com>
References: <1477149440-12478-1-git-send-email-hch@lst.de> <1477149440-12478-5-git-send-email-hch@lst.de>
 <25c117ae-6d06-9846-6a88-ae6221ad6bfe@virtuozzo.com> <CAJWu+oppRL5kD9qPcdCbFAbEkE7bN+kmrvTuaueVZnY+WtK_tg@mail.gmail.com>
 <a40cccff-3a6e-b0be-5d06-bac6cdb0e1e6@virtuozzo.com>
From: Joel Fernandes <joelaf@google.com>
Date: Mon, 7 Nov 2016 08:50:46 -0800
Message-ID: <CAJWu+ordN8eDodGYp8Bm_92U1NZmGJya5pGi3SSg3FvmciGzaw@mail.gmail.com>
Subject: Re: [PATCH 4/7] mm: defer vmalloc from atomic context
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Jisheng Zhang <jszhang@marvell.com>, Chris Wilson <chris@chris-wilson.co.uk>, John Dias <joaodias@google.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-rt-users@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>

On Mon, Nov 7, 2016 at 7:01 AM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> On 11/05/2016 06:43 AM, Joel Fernandes wrote:
>> On Mon, Oct 24, 2016 at 8:44 AM, Andrey Ryabinin
>> <aryabinin@virtuozzo.com> wrote:
>>>
>>>
>>> On 10/22/2016 06:17 PM, Christoph Hellwig wrote:
>>>> We want to be able to use a sleeping lock for freeing vmap to keep
>>>> latency down.  For this we need to use the deferred vfree mechanisms
>>>> no only from interrupt, but from any atomic context.
>>>>
>>>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>>>> ---
>>>>  mm/vmalloc.c | 2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>>>> index a4e2cec..bcc1a64 100644
>>>> --- a/mm/vmalloc.c
>>>> +++ b/mm/vmalloc.c
>>>> @@ -1509,7 +1509,7 @@ void vfree(const void *addr)
>>>>
>>>>       if (!addr)
>>>>               return;
>>>> -     if (unlikely(in_interrupt())) {
>>>> +     if (unlikely(in_atomic())) {
>>>
>>> in_atomic() cannot always detect atomic context, thus it shouldn't be used here.
>>> You can add something like vfree_in_atomic() and use it in atomic call sites.
>>>
>>
>> So because in_atomic doesn't work for !CONFIG_PREEMPT kernels, can we
>> always defer the work in these cases?
>>
>> So for non-preemptible kernels, we always defer:
>>
>> if (!IS_ENABLED(CONFIG_PREEMPT) || in_atomic()) {
>>   // defer
>> }
>>
>> Is this fine? Or any other ideas?
>>
>
> What's wrong with my idea?
> We can add vfree_in_atomic() and use it to free vmapped stacks
> and for any other places where vfree() used 'in_atomict() && !in_interrupt()' context.

Yes, this sounds like a better idea as there may not be that many
callers and my idea may hurt perf.

Thanks,

Joel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
