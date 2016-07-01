Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF6546B0005
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 04:11:00 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id f6so26247921ith.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 01:11:00 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0109.outbound.protection.outlook.com. [104.47.0.109])
        by mx.google.com with ESMTPS id g16si1061453otd.237.2016.07.01.01.10.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 01 Jul 2016 01:11:00 -0700 (PDT)
Subject: Re: [PATCH] kasan/quarantine: fix NULL pointer dereference bug
References: <1467359628-8493-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <577625CC.8080907@virtuozzo.com>
Date: Fri, 1 Jul 2016 11:11:56 +0300
MIME-Version: 1.0
In-Reply-To: <1467359628-8493-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>



On 07/01/2016 10:53 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> If we move an item on qlist's tail, we need to update qlist's tail
> properly. curr->next can be NULL since it is singly linked list
> so it is invalid for tail. curr is scheduled to be moved so
> using prev would be correct.

Hmm.. prev may be the element that moved in 'to' list. We need to assign the last element 
from which is in ther 'from' list.
> 
> Unfortunately, I got this bug sometime ago and lose oops message.
> But, the bug looks trivial and no need to attach oops.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/kasan/quarantine.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> index 4973505..9a132fd 100644
> --- a/mm/kasan/quarantine.c
> +++ b/mm/kasan/quarantine.c
> @@ -255,7 +255,7 @@ static void qlist_move_cache(struct qlist_head *from,
>  			} else
>  				prev->next = curr->next;
>  			if (unlikely(from->tail == qlink))
> -				from->tail = curr->next;
> +				from->tail = prev;
>  			from->bytes -= cache->size;
>  			qlist_put(to, qlink, cache->size);
>  		} else {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
