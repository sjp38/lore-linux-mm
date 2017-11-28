Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5B81E6B026B
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:05:58 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id n134so19726206itg.3
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 20:05:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a184sor1092729ith.137.2017.11.27.20.05.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 20:05:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1511841842-3786-1-git-send-email-zhouzhouyi@gmail.com>
References: <1511841842-3786-1-git-send-email-zhouzhouyi@gmail.com>
From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Date: Tue, 28 Nov 2017 12:05:56 +0800
Message-ID: <CAABZP2zEup53ZcNKOEUEMx_aRMLONZdYCLd7s5J4DLTccPxC-A@mail.gmail.com>
Subject: Re: [PATCH 1/1] kasan: fix livelock in qlist_move_cache
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Zhouyi Zhou <zhouzhouyi@gmail.com>

When there are huge amount of quarantined cache allocates in system,
number of entries in global_quarantine[i] will be great. Meanwhile,
there is no relax in while loop in function qlist_move_cache which
hold quarantine_lock. As a result, some userspace programs for example
libvirt will complain.

On Tue, Nov 28, 2017 at 12:04 PM,  <zhouzhouyi@gmail.com> wrote:
> From: Zhouyi Zhou <zhouzhouyi@gmail.com>
>
> This patch fix livelock by conditionally release cpu to let others
> has a chance to run.
>
> Tested on x86_64.
> Signed-off-by: Zhouyi Zhou <zhouzhouyi@gmail.com>
> ---
>  mm/kasan/quarantine.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
>
> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> index 3a8ddf8..33eeff4 100644
> --- a/mm/kasan/quarantine.c
> +++ b/mm/kasan/quarantine.c
> @@ -265,10 +265,13 @@ static void qlist_move_cache(struct qlist_head *from,
>                                    struct kmem_cache *cache)
>  {
>         struct qlist_node *curr;
> +       struct qlist_head tmp_head;
> +       unsigned long flags;
>
>         if (unlikely(qlist_empty(from)))
>                 return;
>
> +       qlist_init(&tmp_head);
>         curr = from->head;
>         qlist_init(from);
>         while (curr) {
> @@ -278,10 +281,17 @@ static void qlist_move_cache(struct qlist_head *from,
>                 if (obj_cache == cache)
>                         qlist_put(to, curr, obj_cache->size);
>                 else
> -                       qlist_put(from, curr, obj_cache->size);
> +                       qlist_put(&tmp_head, curr, obj_cache->size);
>
>                 curr = next;
> +
> +               if (need_resched()) {
> +                       spin_unlock_irqrestore(&quarantine_lock, flags);
> +                       cond_resched();
> +                       spin_lock_irqsave(&quarantine_lock, flags);
> +               }
>         }
> +       qlist_move_all(&tmp_head, from);
>  }
>
>  static void per_cpu_remove_cache(void *arg)
> --
> 2.1.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
