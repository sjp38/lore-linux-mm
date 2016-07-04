Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8937C6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 05:48:22 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id g18so118809768lfg.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 02:48:22 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0122.outbound.protection.outlook.com. [104.47.1.122])
        by mx.google.com with ESMTPS id s188si2635083wme.29.2016.07.04.02.48.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Jul 2016 02:48:20 -0700 (PDT)
Subject: Re: [PATCH v4] kasan/quarantine: fix bugs on qlist_move_cache()
References: <1467606714-30231-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <577A3114.9080008@virtuozzo.com>
Date: Mon, 4 Jul 2016 12:49:08 +0300
MIME-Version: 1.0
In-Reply-To: <1467606714-30231-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, Kuthonuzo Luruo <poll.stdin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>



On 07/04/2016 07:31 AM, js1304@gmail.com wrote:
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
> v4: fix cache size bug s/cache->size/obj_cache->size/
> v3: fix build warning
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/kasan/quarantine.c | 21 +++++++--------------
>  1 file changed, 7 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> index 4973505..b2e1827 100644
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

Nit: Wouldn't be more appropriate to swap 'curr' and 'qlink' variable names?
Because now qlink is acts as a "current" pointer.

> +
> +		if (obj_cache == cache)
> +			qlist_put(to, qlink, obj_cache->size);
> +		else
> +			qlist_put(from, qlink, obj_cache->size);
>  	}
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
