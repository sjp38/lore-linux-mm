Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id B22FD6B0005
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 06:55:34 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id v6so272441072vkb.2
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 03:55:34 -0700 (PDT)
Received: from mail-vk0-x243.google.com (mail-vk0-x243.google.com. [2607:f8b0:400c:c05::243])
        by mx.google.com with ESMTPS id j89si328029uaj.158.2016.07.01.03.55.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 03:55:33 -0700 (PDT)
Received: by mail-vk0-x243.google.com with SMTP id v190so15010454vka.0
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 03:55:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <577625CC.8080907@virtuozzo.com>
References: <1467359628-8493-1-git-send-email-iamjoonsoo.kim@lge.com> <577625CC.8080907@virtuozzo.com>
From: Kuthonuzo Luruo <poll.stdin@gmail.com>
Date: Fri, 1 Jul 2016 16:25:32 +0530
Message-ID: <CAHPzcFmZNZe62MFg0-iz1fJneFeG1w4nFFuG-xmpD2sJHovDgQ@mail.gmail.com>
Subject: Re: [PATCH] kasan/quarantine: fix NULL pointer dereference bug
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, Jul 1, 2016 at 1:41 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>
>
> On 07/01/2016 10:53 AM, js1304@gmail.com wrote:
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> If we move an item on qlist's tail, we need to update qlist's tail
>> properly. curr->next can be NULL since it is singly linked list
>> so it is invalid for tail. curr is scheduled to be moved so
>> using prev would be correct.
>
> Hmm.. prev may be the element that moved in 'to' list. We need to assign the last element
> from which is in ther 'from' list.

something like this should handle qlink == head == tail:

--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -251,11 +251,11 @@ static void qlist_move_cache(struct qlist_head *from,
                if (obj_cache == cache) {
                        if (unlikely(from->head == qlink)) {
                                from->head = curr->next;
-                               prev = curr;
+                               prev = from->head;
                        } else
                                prev->next = curr->next;
                        if (unlikely(from->tail == qlink))
-                               from->tail = curr->next;
+                               from->tail = prev;
                        from->bytes -= cache->size;
                        qlist_put(to, qlink, cache->size);
                } else {

>>
>> Unfortunately, I got this bug sometime ago and lose oops message.
>> But, the bug looks trivial and no need to attach oops.
>>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> ---
>>  mm/kasan/quarantine.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
>> index 4973505..9a132fd 100644
>> --- a/mm/kasan/quarantine.c
>> +++ b/mm/kasan/quarantine.c
>> @@ -255,7 +255,7 @@ static void qlist_move_cache(struct qlist_head *from,
>>                       } else
>>                               prev->next = curr->next;
>>                       if (unlikely(from->tail == qlink))
>> -                             from->tail = curr->next;
>> +                             from->tail = prev;
>>                       from->bytes -= cache->size;
>>                       qlist_put(to, qlink, cache->size);
>>               } else {
>>
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/577625CC.8080907%40virtuozzo.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
