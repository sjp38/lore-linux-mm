Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id A4FA56B0005
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 07:16:49 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id g18so80440030lfg.2
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 04:16:49 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20102.outbound.protection.outlook.com. [40.107.2.102])
        by mx.google.com with ESMTPS id w10si3154774wjc.97.2016.07.01.04.16.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 01 Jul 2016 04:16:48 -0700 (PDT)
Subject: Re: [PATCH] kasan/quarantine: fix NULL pointer dereference bug
References: <1467359628-8493-1-git-send-email-iamjoonsoo.kim@lge.com>
 <577625CC.8080907@virtuozzo.com>
 <CAHPzcFmZNZe62MFg0-iz1fJneFeG1w4nFFuG-xmpD2sJHovDgQ@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <57765157.8020909@virtuozzo.com>
Date: Fri, 1 Jul 2016 14:17:43 +0300
MIME-Version: 1.0
In-Reply-To: <CAHPzcFmZNZe62MFg0-iz1fJneFeG1w4nFFuG-xmpD2sJHovDgQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kuthonuzo Luruo <poll.stdin@gmail.com>
Cc: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>



On 07/01/2016 01:55 PM, Kuthonuzo Luruo wrote:
> On Fri, Jul 1, 2016 at 1:41 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>>
>>
>> On 07/01/2016 10:53 AM, js1304@gmail.com wrote:
>>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>>
>>> If we move an item on qlist's tail, we need to update qlist's tail
>>> properly. curr->next can be NULL since it is singly linked list
>>> so it is invalid for tail. curr is scheduled to be moved so
>>> using prev would be correct.
>>
>> Hmm.. prev may be the element that moved in 'to' list. We need to assign the last element
>> from which is in ther 'from' list.
> 
> something like this should handle qlink == head == tail:
> 
> --- a/mm/kasan/quarantine.c
> +++ b/mm/kasan/quarantine.c
> @@ -251,11 +251,11 @@ static void qlist_move_cache(struct qlist_head *from,
>                 if (obj_cache == cache) {
>                         if (unlikely(from->head == qlink)) {
>                                 from->head = curr->next;
> -                               prev = curr;
> +                               prev = from->head;

This will break 'to' list.

>                         } else
>                                 prev->next = curr->next;
>                         if (unlikely(from->tail == qlink))
> -                               from->tail = curr->next;
> +                               from->tail = prev;
>                         from->bytes -= cache->size;
>                         qlist_put(to, qlink, cache->size);
>                 } else {
> 
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
