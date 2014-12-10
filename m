Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 028916B008A
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 11:54:48 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id h11so5839758wiw.9
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:54:47 -0800 (PST)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com. [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id er1si8359748wjd.152.2014.12.10.08.54.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 08:54:47 -0800 (PST)
Received: by mail-wg0-f42.google.com with SMTP id z12so4199952wgg.29
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:54:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141210163033.717707217@linux.com>
References: <20141210163017.092096069@linux.com>
	<20141210163033.717707217@linux.com>
Date: Wed, 10 Dec 2014 18:54:47 +0200
Message-ID: <CAOJsxLFEN_w7q6NvbxkH2KTujB9auLkQgskLnGtN9iBQ4hV9sw@mail.gmail.com>
Subject: Re: [PATCH 3/7] slub: Do not use c->page on free
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm <akpm@linuxfoundation.org>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Dec 10, 2014 at 6:30 PM, Christoph Lameter <cl@linux.com> wrote:
> Avoid using the page struct address on free by just doing an
> address comparison. That is easily doable now that the page address
> is available in the page struct and we already have the page struct
> address of the object to be freed calculated.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>
>
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c        2014-12-09 12:25:45.770405462 -0600
> +++ linux/mm/slub.c     2014-12-09 12:25:45.766405582 -0600
> @@ -2625,6 +2625,13 @@ slab_empty:
>         discard_slab(s, page);
>  }
>
> +static bool same_slab_page(struct kmem_cache *s, struct page *page, void *p)

Why are you passing a pointer to struct kmem_cache here? You don't
seem to use it.

> +{
> +       long d = p - page->address;
> +
> +       return d > 0 && d < (1 << MAX_ORDER) && d < (compound_order(page) << PAGE_SHIFT);
> +}

Can you elaborate on what this is doing? I don't really understand it.

- Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
