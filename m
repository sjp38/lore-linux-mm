Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4AC6B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 18:03:24 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id ga2so65526596lbc.0
        for <linux-mm@kvack.org>; Mon, 16 May 2016 15:03:24 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id b187si22380741wmh.51.2016.05.16.15.03.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 15:03:22 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id e201so105595wme.2
        for <linux-mm@kvack.org>; Mon, 16 May 2016 15:03:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1462987130-144092-1-git-send-email-glider@google.com>
References: <1462987130-144092-1-git-send-email-glider@google.com>
Date: Mon, 16 May 2016 23:03:21 +0100
Message-ID: <CALW4P+JNmSVg351vwZ410JxDxuqZ7unou+wWJm2+_Ugp4tE2JQ@mail.gmail.com>
Subject: Re: [PATCH v9] mm: kasan: Initial memory quarantine implementation
From: Alexey Klimov <klimov.linux@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, cl@linux.com, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Alexander,

On Wed, May 11, 2016 at 6:18 PM, Alexander Potapenko <glider@google.com> wrote:
> Quarantine isolates freed objects in a separate queue. The objects are
> returned to the allocator later, which helps to detect use-after-free
> errors.
>
> Freed objects are first added to per-cpu quarantine queues.
> When a cache is destroyed or memory shrinking is requested, the objects
> are moved into the global quarantine queue. Whenever a kmalloc call
> allows memory reclaiming, the oldest objects are popped out of the
> global queue until the total size of objects in quarantine is less than
> 3/4 of the maximum quarantine size (which is a fraction of installed
> physical memory).
>
> As long as an object remains in the quarantine, KASAN is able to report
> accesses to it, so the chance of reporting a use-after-free is increased.
> Once the object leaves quarantine, the allocator may reuse it, in which
> case the object is unpoisoned and KASAN can't detect incorrect accesses
> to it.
>
> Right now quarantine support is only enabled in SLAB allocator.
> Unification of KASAN features in SLAB and SLUB will be done later.
>
> This patch is based on the "mm: kasan: quarantine" patch originally
> prepared by Dmitry Chernenkov. A number of improvements have been
> suggested by Andrey Ryabinin.
>
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
> v2: - added copyright comments
>     - per request from Joonsoo Kim made __cache_free() more straightforward
>     - added comments for smp_load_acquire()/smp_store_release()
>
> v3: - incorporate changes introduced by the "mm, kasan: SLAB support" patch
>
> v4: - fix kbuild compile-time error (missing ___cache_free() declaration)
>       and a warning (wrong format specifier)
>
> v6: - extended the patch description
>     - dropped the unused qlist_remove() function
>
> v9: - incorporate the fixes by Andrey Ryabinin:
>       * Fix comment styles,
>       * Get rid of some ifdefs
>       * Revert needless functions renames in quarantine patch
>       * Remove needless local_irq_save()/restore() in
>         per_cpu_remove_cache()
>       * Add new 'struct qlist_node' instead of 'void **' types. This makes
>         code a bit more redable.
>     - remove the non-deterministic quarantine test
>     - dropped smp_load_acquire()/smp_store_release()
> ---
>  include/linux/kasan.h |  13 ++-
>  mm/kasan/Makefile     |   1 +
>  mm/kasan/kasan.c      |  57 ++++++++--
>  mm/kasan/kasan.h      |  21 +++-
>  mm/kasan/quarantine.c | 291 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/kasan/report.c     |   1 +
>  mm/mempool.c          |   2 +-
>  mm/slab.c             |  12 ++-
>  mm/slab.h             |   2 +
>  mm/slab_common.c      |   2 +
>  10 files changed, 387 insertions(+), 15 deletions(-)
>  create mode 100644 mm/kasan/quarantine.c
>
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index 737371b..611927f 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -50,6 +50,8 @@ void kasan_free_pages(struct page *page, unsigned int order);
>

[...]

> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> new file mode 100644
> index 0000000..4973505
> --- /dev/null
> +++ b/mm/kasan/quarantine.c
> @@ -0,0 +1,291 @@
> +/*
> + * KASAN quarantine.
> + *
> + * Author: Alexander Potapenko <glider@google.com>
> + * Copyright (C) 2016 Google, Inc.
> + *
> + * Based on code by Dmitry Chernenkov.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * version 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + * General Public License for more details.
> + *
> + */
> +
> +#include <linux/gfp.h>
> +#include <linux/hash.h>
> +#include <linux/kernel.h>
> +#include <linux/mm.h>
> +#include <linux/percpu.h>
> +#include <linux/printk.h>
> +#include <linux/shrinker.h>
> +#include <linux/slab.h>
> +#include <linux/string.h>
> +#include <linux/types.h>
> +
> +#include "../slab.h"
> +#include "kasan.h"
> +
> +/* Data structure and operations for quarantine queues. */
> +
> +/*
> + * Each queue is a signle-linked list, which also stores the total size of
> + * objects inside of it.
> + */
> +struct qlist_head {
> +       struct qlist_node *head;
> +       struct qlist_node *tail;
> +       size_t bytes;
> +};
> +
> +#define QLIST_INIT { NULL, NULL, 0 }
> +
> +static bool qlist_empty(struct qlist_head *q)
> +{
> +       return !q->head;
> +}
> +
> +static void qlist_init(struct qlist_head *q)
> +{
> +       q->head = q->tail = NULL;
> +       q->bytes = 0;
> +}
> +
> +static void qlist_put(struct qlist_head *q, struct qlist_node *qlink,
> +               size_t size)
> +{
> +       if (unlikely(qlist_empty(q)))
> +               q->head = qlink;
> +       else
> +               q->tail->next = qlink;
> +       q->tail = qlink;
> +       qlink->next = NULL;
> +       q->bytes += size;
> +}
> +
> +static void qlist_move_all(struct qlist_head *from, struct qlist_head *to)
> +{
> +       if (unlikely(qlist_empty(from)))
> +               return;
> +
> +       if (qlist_empty(to)) {
> +               *to = *from;
> +               qlist_init(from);
> +               return;
> +       }
> +
> +       to->tail->next = from->head;
> +       to->tail = from->tail;
> +       to->bytes += from->bytes;
> +
> +       qlist_init(from);
> +}
> +
> +static void qlist_move(struct qlist_head *from, struct qlist_node *last,
> +               struct qlist_head *to, size_t size)
> +{
> +       if (unlikely(last == from->tail)) {
> +               qlist_move_all(from, to);
> +               return;
> +       }
> +       if (qlist_empty(to))
> +               to->head = from->head;
> +       else
> +               to->tail->next = from->head;
> +       to->tail = last;
> +       from->head = last->next;
> +       last->next = NULL;
> +       from->bytes -= size;
> +       to->bytes += size;
> +}

I see conversation with Andrew in previous emails about moving this
code above into generic library facility but I don't anything is going
on here. I also feel like this belongs to lib/*.
Do I miss something or did you decide to do it later?

[...]

-- 
Best regards, Klimov Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
