Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 3C81F6B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 09:00:51 -0400 (EDT)
Received: by ggm4 with SMTP id 4so7916141ggm.14
        for <linux-mm@kvack.org>; Wed, 04 Jul 2012 06:00:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1340390729-2821-1-git-send-email-js1304@gmail.com>
References: <1340389359-2407-1-git-send-email-js1304@gmail.com>
	<1340390729-2821-1-git-send-email-js1304@gmail.com>
Date: Wed, 4 Jul 2012 16:00:49 +0300
Message-ID: <CAOJsxLHSboF0rQdGv8bdgGtinBz5dTo+omQbUnj9on_ewzgNAQ@mail.gmail.com>
Subject: Re: [PATCH 1/3 v2] slub: prefetch next freelist pointer in __slab_alloc()
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>

On Fri, Jun 22, 2012 at 9:45 PM, Joonsoo Kim <js1304@gmail.com> wrote:
> Commit 0ad9500e16fe24aa55809a2b00e0d2d0e658fc71 ('slub: prefetch
> next freelist pointer in slab_alloc') add prefetch instruction to
> fast path of allocation.
>
> Same benefit is also available in slow path of allocation, but it is not
> large portion of overall allocation. Nevertheless we could get
> some benifit from it, so prefetch next freelist pointer in __slab_alloc.
>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> ---
> Add 'Cc: Eric Dumazet <eric.dumazet@gmail.com>'
>
> diff --git a/mm/slub.c b/mm/slub.c
> index f96d8bc..92f1c0e 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2248,6 +2248,7 @@ load_freelist:
>         VM_BUG_ON(!c->page->frozen);
>         c->freelist = get_freepointer(s, freelist);
>         c->tid = next_tid(c->tid);
> +       prefetch_freepointer(s, c->freelist);
>         local_irq_restore(flags);
>         return freelist;

Well, can you show improvement in any benchmark or workload?
Prefetching is not always an obvious win and the reason we merged
Eric's patch was that he was able to show an improvement in hackbench.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
