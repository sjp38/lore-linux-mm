Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 60326828E2
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 10:16:16 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g13so204951148ioj.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 07:16:16 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40096.outbound.protection.outlook.com. [40.107.4.96])
        by mx.google.com with ESMTPS id j27si189646otb.283.2016.07.01.07.16.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 01 Jul 2016 07:16:15 -0700 (PDT)
Subject: Re: [PATCH v3] kasan/quarantine: fix bugs on qlist_move_cache()
References: <1467381733-18314-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <57767B66.7070904@virtuozzo.com>
Date: Fri, 1 Jul 2016 17:17:10 +0300
MIME-Version: 1.0
In-Reply-To: <1467381733-18314-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>



On 07/01/2016 05:02 PM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> There are two bugs on qlist_move_cache(). One is that qlist's tail
> isn't set properly. curr->next can be NULL since it is singly linked
> list and NULL value on tail is invalid if there is one item on qlist.
> Another one is that if cache is matched, qlist_put() is called and
> it will set curr->next to NULL. It would cause to stop the loop
> prematurely.
> 
> These problems come from complicated implementation so I'd like to
> re-implement it completely. Implementation in this patch is really
> simple. Iterate all qlist_nodes and put them to appropriate list.
> 
> Unfortunately, I got this bug sometime ago and lose oops message.
> But, the bug looks trivial and no need to attach oops.
> 
> v3: fix build warning
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/kasan/quarantine.c | 21 +++++++--------------
>  1 file changed, 7 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> index 4973505..cf92494 100644
> --- a/mm/kasan/quarantine.c
> +++ b/mm/kasan/quarantine.c
> @@ -238,30 +238,23 @@ static void qlist_move_cache(struct qlist_head *from,
>  				   struct qlist_head *to,
>  				   struct kmem_cache *cache)
>  {
> -	struct qlist_node *prev = NULL, *curr;
> +	struct qlist_node *curr;
>  
>  	if (unlikely(qlist_empty(from)))
>  		return;
>  
>  	curr = from->head;
> +	qlist_init(from);
>  	while (curr) {
>  		struct qlist_node *qlink = curr;

Can you please also get rid of either qlink or curr.
Those are essentially the same pointers.

>  		struct kmem_cache *obj_cache = qlink_to_cache(qlink);
>  
> -		if (obj_cache == cache) {
> -			if (unlikely(from->head == qlink)) {
> -				from->head = curr->next;
> -				prev = curr;
> -			} else
> -				prev->next = curr->next;
> -			if (unlikely(from->tail == qlink))
> -				from->tail = curr->next;
> -			from->bytes -= cache->size;
> -			qlist_put(to, qlink, cache->size);
> -		} else {
> -			prev = curr;
> -		}
>  		curr = curr->next;
> +
> +		if (obj_cache == cache)
> +			qlist_put(to, qlink, cache->size);
> +		else
> +			qlist_put(from, qlink, cache->size);
>  	}
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
