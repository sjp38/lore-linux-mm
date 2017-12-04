Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB0EF6B0033
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 09:56:05 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id g69so11971002ita.9
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 06:56:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v125sor4197731ith.29.2017.12.04.06.56.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Dec 2017 06:56:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171002125858.12751-1-nefelim4ag@gmail.com>
References: <20171002125858.12751-1-nefelim4ag@gmail.com>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Mon, 4 Dec 2017 17:55:23 +0300
Message-ID: <CAGqmi77_xuk+0XK==51BaAQLt0-kMYrbhx_ikoJFYLnmdRfX7A@mail.gmail.com>
Subject: Re: [RFC v2 PATCH] ksm: add offset arg to memcmp_pages() to speedup comparing
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, kvm@vger.kernel.org, Timofey Titovets <nefelim4ag@gmail.com>

Gentle ping.

P.S.
If someone can tests that on "big" machine, that will be cool (i just
have not one).
I think may be, that need more tuning, as example set max_offset_error
to 128, instead of 8, to trade off precision with performance.
I'm also wander that possible of more profit on machines with "big pages (64k)".

Thanks!

2017-10-02 15:58 GMT+03:00 Timofey Titovets <nefelim4ag@gmail.com>:
> Currently while search/inserting in RB tree,
> memcmp used for comparing out of tree pages with in tree pages.
>
> But on each compare step memcmp for pages start at
> zero offset, i.e. that just ignore forward progress.
>
> That make some overhead for search in deep RB tree and/or with
> bit pages (4KiB+), so store last start offset where no diff in page content.
>
> Added: memcmpe()
> iter 1024 -  that a some type of magic value
> max_offset_error - 8 - acceptable error level for offset.
>
> With that patch i get ~ same performance in bad case (where offset useless)
> on tiny tree and default 4KiB pages.
>
> So that just RFC, i.e. does that type of optimization make a sense?
>
> Thanks.
>
> Changes:
>         v1 -> v2:
>                 Add: configurable max_offset_error
>                 Move logic to memcmpe()
>
> Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
> ---
>  mm/ksm.c | 61 +++++++++++++++++++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 55 insertions(+), 6 deletions(-)
>
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 15dd7415f7b3..780630498de8 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -991,14 +991,58 @@ static u32 calc_checksum(struct page *page)
>         return checksum;
>  }
>
> -static int memcmp_pages(struct page *page1, struct page *page2)
> +
> +/*
> + * memcmp used to compare pages in RB-tree
> + * but on every step down the tree forward progress
> + * just has been ignored, that make performance pitfall
> + * on deep tree and/or big pages (ex. 4KiB+)
> + *
> + * Fix that by add memcmp wrapper that will try to guess
> + * where difference happens, to only scan from that offset against
> + * next pages
> + */
> +
> +static int memcmpe(const void *p, const void *q, const u32 len,
> +                  u32 *offset)
> +{
> +       const u32 max_offset_error = 8;
> +       u32 iter = 1024, i = 0;
> +       int ret;
> +
> +       if (offset == NULL)
> +               return memcmp(p, q, len);
> +
> +       if (*offset < len)
> +               i = *offset;
> +
> +       while (i < len) {
> +               iter = min_t(u32, iter, len - i);
> +               ret = memcmp(p, q, iter);
> +
> +               if (ret) {
> +                       iter = iter >> 1;
> +                       if (iter < max_offset_error)
> +                               break;
> +                       continue;
> +               }
> +
> +               i += iter;
> +       }
> +
> +       *offset = i;
> +
> +       return ret;
> +}
> +
> +static int memcmp_pages(struct page *page1, struct page *page2, u32 *offset)
>  {
>         char *addr1, *addr2;
>         int ret;
>
>         addr1 = kmap_atomic(page1);
>         addr2 = kmap_atomic(page2);
> -       ret = memcmp(addr1, addr2, PAGE_SIZE);
> +       ret = memcmpe(addr1, addr2, PAGE_SIZE, offset);
>         kunmap_atomic(addr2);
>         kunmap_atomic(addr1);
>         return ret;
> @@ -1006,7 +1050,7 @@ static int memcmp_pages(struct page *page1, struct page *page2)
>
>  static inline int pages_identical(struct page *page1, struct page *page2)
>  {
> -       return !memcmp_pages(page1, page2);
> +       return !memcmp_pages(page1, page2, NULL);
>  }
>
>  static int write_protect_page(struct vm_area_struct *vma, struct page *page,
> @@ -1514,6 +1558,7 @@ static __always_inline struct page *chain(struct stable_node **s_n_d,
>  static struct page *stable_tree_search(struct page *page)
>  {
>         int nid;
> +       u32 diff_offset;
>         struct rb_root *root;
>         struct rb_node **new;
>         struct rb_node *parent;
> @@ -1532,6 +1577,7 @@ static struct page *stable_tree_search(struct page *page)
>  again:
>         new = &root->rb_node;
>         parent = NULL;
> +       diff_offset = 0;
>
>         while (*new) {
>                 struct page *tree_page;
> @@ -1590,7 +1636,7 @@ static struct page *stable_tree_search(struct page *page)
>                         goto again;
>                 }
>
> -               ret = memcmp_pages(page, tree_page);
> +               ret = memcmp_pages(page, tree_page, &diff_offset);
>                 put_page(tree_page);
>
>                 parent = *new;
> @@ -1760,6 +1806,7 @@ static struct page *stable_tree_search(struct page *page)
>  static struct stable_node *stable_tree_insert(struct page *kpage)
>  {
>         int nid;
> +       u32 diff_offset;
>         unsigned long kpfn;
>         struct rb_root *root;
>         struct rb_node **new;
> @@ -1773,6 +1820,7 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
>  again:
>         parent = NULL;
>         new = &root->rb_node;
> +       diff_offset = 0;
>
>         while (*new) {
>                 struct page *tree_page;
> @@ -1819,7 +1867,7 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
>                         goto again;
>                 }
>
> -               ret = memcmp_pages(kpage, tree_page);
> +               ret = memcmp_pages(kpage, tree_page, &diff_offset);
>                 put_page(tree_page);
>
>                 parent = *new;
> @@ -1884,6 +1932,7 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
>         struct rb_root *root;
>         struct rb_node *parent = NULL;
>         int nid;
> +       u32 diff_offset = 0;
>
>         nid = get_kpfn_nid(page_to_pfn(page));
>         root = root_unstable_tree + nid;
> @@ -1908,7 +1957,7 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
>                         return NULL;
>                 }
>
> -               ret = memcmp_pages(page, tree_page);
> +               ret = memcmp_pages(page, tree_page, &diff_offset);
>
>                 parent = *new;
>                 if (ret < 0) {
> --
> 2.14.2
>



-- 
Have a nice day,
Timofey.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
