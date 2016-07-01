Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B62496B0005
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 10:04:07 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r190so19330321wmr.0
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 07:04:07 -0700 (PDT)
Received: from mail-lf0-x22b.google.com (mail-lf0-x22b.google.com. [2a00:1450:4010:c07::22b])
        by mx.google.com with ESMTPS id e81si2329638lfi.136.2016.07.01.07.04.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 07:04:06 -0700 (PDT)
Received: by mail-lf0-x22b.google.com with SMTP id h129so78006203lfh.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 07:04:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1467381733-18314-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1467381733-18314-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 1 Jul 2016 16:03:46 +0200
Message-ID: <CACT4Y+ZgmmizB209CUMOnq_p=2=__Y8AH4qsq1SG0RYk2kvxbQ@mail.gmail.com>
Subject: Re: [PATCH v3] kasan/quarantine: fix bugs on qlist_move_cache()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, Jul 1, 2016 at 4:02 PM,  <js1304@gmail.com> wrote:
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
>                                    struct qlist_head *to,
>                                    struct kmem_cache *cache)
>  {
> -       struct qlist_node *prev = NULL, *curr;
> +       struct qlist_node *curr;
>
>         if (unlikely(qlist_empty(from)))
>                 return;
>
>         curr = from->head;
> +       qlist_init(from);
>         while (curr) {
>                 struct qlist_node *qlink = curr;
>                 struct kmem_cache *obj_cache = qlink_to_cache(qlink);
>
> -               if (obj_cache == cache) {
> -                       if (unlikely(from->head == qlink)) {
> -                               from->head = curr->next;
> -                               prev = curr;
> -                       } else
> -                               prev->next = curr->next;
> -                       if (unlikely(from->tail == qlink))
> -                               from->tail = curr->next;
> -                       from->bytes -= cache->size;
> -                       qlist_put(to, qlink, cache->size);
> -               } else {
> -                       prev = curr;
> -               }
>                 curr = curr->next;
> +
> +               if (obj_cache == cache)
> +                       qlist_put(to, qlink, cache->size);
> +               else
> +                       qlist_put(from, qlink, cache->size);

This line is wrong. If obj_cache != cache, object size != cache->size.
Quarantine contains objects of different sizes.

>         }
>  }
>
> --
> 1.9.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
