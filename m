Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id D3B356B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 08:34:51 -0400 (EDT)
Received: by iahk25 with SMTP id k25so200398iah.14
        for <linux-mm@kvack.org>; Wed, 15 Aug 2012 05:34:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344955130-29478-1-git-send-email-elezegarcia@gmail.com>
References: <1344955130-29478-1-git-send-email-elezegarcia@gmail.com>
Date: Wed, 15 Aug 2012 09:34:50 -0300
Message-ID: <CALF0-+VXA+4us1CSz5DGcSmKr37SnVF6ZMNbh8iLNsM7VYVnQQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm, slob: Prevent false positive trace upon
 allocation failure
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>

Pekka,

I'd like to bring your attention to this patch, and make a little question.


On Tue, Aug 14, 2012 at 11:38 AM, Ezequiel Garcia <elezegarcia@gmail.com> wrote:
> This patch changes the __kmalloc_node() logic to return NULL
> if alloc_pages() fails to return valid pages.
> This is done to avoid to trace a false positive kmalloc event.
>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Glauber Costa <glommer@parallels.com>
> Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
> ---
>  mm/slob.c |   11 ++++++-----
>  1 files changed, 6 insertions(+), 5 deletions(-)
>
> diff --git a/mm/slob.c b/mm/slob.c
> index 45d4ca7..686e98b 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -450,15 +450,16 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
>                                    size, size + align, gfp, node);
>         } else {
>                 unsigned int order = get_order(size);
> +               struct page *page;
>
>                 if (likely(order))
>                         gfp |= __GFP_COMP;
>                 ret = slob_new_pages(gfp, order, node);
> -               if (ret) {
> -                       struct page *page;
> -                       page = virt_to_page(ret);
> -                       page->private = size;
> -               }
> +               if (!ret)
> +                       return NULL;
> +
> +               page = virt_to_page(ret);
> +               page->private = size;
>
>                 trace_kmalloc_node(_RET_IP_, ret,
>                                    size, PAGE_SIZE << order, gfp, node);


As you can see this patch prevents to trace a kmem event if the allocation
fails.

I'm still unsure about tracing or not this ones, and I'm considering tracing
failures, perhaps with return=0 and allocated size=0.

In this case, it would be nice to have SLxB all do the same.
Right now, this is not the case.

You can see how slob::kmem_cache_alloc_node traces independently
of the allocation succeeding.
I have no problem trying a fix for this, but I don't now how to trace
this cases.

Although it is a corner case, I think it's important to define a clear
and consistent
behaviour to make tracing reliable.

Thanks,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
