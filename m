Received: by rv-out-0910.google.com with SMTP id l15so2207561rvb
        for <linux-mm@kvack.org>; Sun, 02 Dec 2007 08:30:07 -0800 (PST)
Message-ID: <19f34abd0712020830y4825691atdfc9dac07ce4cb35@mail.gmail.com>
Date: Sun, 2 Dec 2007 17:30:07 +0100
From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [BUG 2.6.24-rc3-git6] SLUB's ksize() fails for size > 2048.
In-Reply-To: <200712021939.HHH18792.FLQSOOtFOFJVHM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200712021939.HHH18792.FLQSOOtFOFJVHM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Dec 2, 2007 11:39 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Hello.
>
> I can't pass memory allocated by kmalloc() to ksize()
> if it is allocated by SLUB allocator and
> size is larger than (I guess) PAGE_SIZE / 2.
>
> Regards.

Take a look at mm/slub.c around line 2560, in __kmalloc:
        if (unlikely(size > PAGE_SIZE / 2))
                return (void *)__get_free_pages(flags | __GFP_COMP,
                                                        get_order(size));


So it seems that kmalloc simply returns pages from the page allocator
in this case. Therefore no SLUB metadata will be available for the
allocation.

The error of ksize() seems to be that it does not check if the
allocation was made by SLUB or the page allocator. Maybe something
like this will fix it? (completely untested)

diff --git a/mm/slub.c b/mm/slub.c
index 9acb413..1cdca59 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2552,6 +2552,7 @@ EXPORT_SYMBOL(__kmalloc_node);
 size_t ksize(const void *object)
 {
        struct page *page;
+       struct page *head;
        struct kmem_cache *s;

        BUG_ON(!object);
@@ -2560,6 +2561,13 @@ size_t ksize(const void *object)

        page = get_object_page(object);
        BUG_ON(!page);
+
+       head = compound_head(page);
+       BUG_ON(!head);
+
+       if (unlikely(!(head->flags & PG_slab)))
+               return PAGE_SIZE << compound_order(head);
+
        s = page->slab;
        BUG_ON(!s);



It's going to round up, though, so you would get ksize(kmalloc(2049))
= PAGE_SIZE.


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
