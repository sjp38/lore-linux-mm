Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0AB936B008A
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 11:56:35 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id x13so4181740wgg.5
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:56:34 -0800 (PST)
Received: from mail-wg0-x235.google.com (mail-wg0-x235.google.com. [2a00:1450:400c:c00::235])
        by mx.google.com with ESMTPS id xt3si8547242wjc.27.2014.12.10.08.56.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 08:56:34 -0800 (PST)
Received: by mail-wg0-f53.google.com with SMTP id l18so4096636wgh.26
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:56:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141210163033.841468065@linux.com>
References: <20141210163017.092096069@linux.com>
	<20141210163033.841468065@linux.com>
Date: Wed, 10 Dec 2014 18:56:33 +0200
Message-ID: <CAOJsxLG2vyY-c08_Jj+Nq+dUoRkiq1TGdpxPaAtDadWY_XBj6A@mail.gmail.com>
Subject: Re: [PATCH 4/7] slub: Avoid using the page struct address in
 allocation fastpath
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm <akpm@linuxfoundation.org>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Dec 10, 2014 at 6:30 PM, Christoph Lameter <cl@linux.com> wrote:
> We can use virt_to_page there and only invoke the costly function if
> actually a node is specified and we have to check the NUMA locality.
>
> Increases the cost of allocating on a specific NUMA node but then that
> was never cheap since we may have to dump our caches and retrieve memory
> from the correct node.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>
>
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c        2014-12-09 12:27:49.414686959 -0600
> +++ linux/mm/slub.c     2014-12-09 12:27:49.414686959 -0600
> @@ -2097,6 +2097,15 @@ static inline int node_match(struct page
>         return 1;
>  }
>
> +static inline int node_match_ptr(void *p, int node)
> +{
> +#ifdef CONFIG_NUMA
> +       if (!p || (node != NUMA_NO_NODE && page_to_nid(virt_to_page(p)) != node))

You already test that object != NULL before calling node_match_ptr().

> +               return 0;
> +#endif
> +       return 1;
> +}
> +
>  #ifdef CONFIG_SLUB_DEBUG
>  static int count_free(struct page *page)
>  {
> @@ -2410,7 +2419,7 @@ redo:
>
>         object = c->freelist;
>         page = c->page;
> -       if (unlikely(!object || !node_match(page, node))) {
> +       if (unlikely(!object || !node_match_ptr(object, node))) {
>                 object = __slab_alloc(s, gfpflags, node, addr, c);
>                 stat(s, ALLOC_SLOWPATH);
>         } else {
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
