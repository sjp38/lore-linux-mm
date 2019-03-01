Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C373CC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 19:12:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 657732084F
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 19:12:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hoUX4+aA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 657732084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 041668E0003; Fri,  1 Mar 2019 14:12:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F340F8E0001; Fri,  1 Mar 2019 14:12:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E234D8E0003; Fri,  1 Mar 2019 14:12:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id B0D258E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 14:12:57 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 203so19415443qke.7
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 11:12:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2IDy1+JnazifkseAC7wCt+QbxwzYPyMdtElpePui2LE=;
        b=R6dueUB6g+B5FQdfOtl0+KNL6djGFOjFtPU98cwHPLJQR391+ZFwXro+8KCXi0G8fu
         B3f9S9K8RBgxl6bBBP9oUKrBQfKhti88ownB/LAFvJcaCyrHi28ayywcXx2lFX1iUN8K
         H4BNPjFing7oyEjK3Yj82k8MPdFYXZEehWhfKjw0Kk7Y+qxAtqFYSImS6Fc9zVZTCFFG
         zwk77Fk0pxw49+J4szM4GWg6Y0ehZSircvKqe5Wp26hNV+WFKrsNUGkCZuDGtCphaYdR
         la1NN0lFAWz+q4pNWA77qA6+1kk5IYcwux/AkA11vB/uEfiWZtUT+Yyf3feprH7vvrfM
         5/Zg==
X-Gm-Message-State: APjAAAVcqlbpEuNhxJR8OxF0MB3E4GeAZtcOdlPcEbJat4eqC6B8uotL
	2vCNYMqr74pHbonw/kCpWgehxXI1MRk9c39iZEZvSep/dpsbcHi93atOdSIGjySzkCMk2JPm/CD
	wsQACdWrKwC+S2d0WyowMzs40LARlJ4ax5g2QeF97NyCUYjcGXQKHo74k0g6haH/UX32SN66sJt
	oJau0mzBiOiCLR4AVDxgwCQ2KIgxiuG3drf8lJFQ5xW6pNnhdr3PKmqs+TJowDz2TqqADXKui/z
	P/ULejoYTayLqxd9U2u3ubZViTnK/HpBMGuru5zC2xPvOQ9yhj5PkVhdnSfZdRg8L2+7QmVAHtj
	X+ml7JPeOyNkhzWOE4qY6Qa7GzmvF3zm640hN4fHqlfhbmwjU2ihzS0vnsX12ata1cwjw6ZtJEW
	6
X-Received: by 2002:a0c:94b3:: with SMTP id j48mr5202762qvj.189.1551467577405;
        Fri, 01 Mar 2019 11:12:57 -0800 (PST)
X-Received: by 2002:a0c:94b3:: with SMTP id j48mr5202655qvj.189.1551467575525;
        Fri, 01 Mar 2019 11:12:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551467575; cv=none;
        d=google.com; s=arc-20160816;
        b=A2r3pJXz2/7F0sThnQSfbwoVaNUJwQ5ycVgwx0clpeEq0zCuki8fOucMZVIV9ockLT
         gTR0Q7kECrfDB9Mop8XtMK6fAB9/SLDxzyNZOshwfXStsQufAledZUaSPX/tVF3rbJsJ
         RrIN0m10K43C9XtBHI+yREddttKdmCzNQO+2bfdmcgTrk3KjmeSuyvEiDTdCX9SmRqV/
         CXNyIKbltvoFw5jTx5lCXY9t5LpSQFBOVnvcBdNYby4ImLAWo7xUcuq5BcMjf31feiiA
         7vGvrcFje7ZkeDlCLubvuJqnKfqFtS/Pk2/tC9zyI1xHa6JjrjkyP/khw6Km+U7eHmAS
         dQHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2IDy1+JnazifkseAC7wCt+QbxwzYPyMdtElpePui2LE=;
        b=Nhv4xU1i0yniVjzddwimS/5k4dmJX55qAPBsDwnl+8dVU/AbCoHW7s2yzYK3dCmTQm
         d1B6OJTF8AKPbyeQKzdifYwB0aAApZt0pIx5KCo2/O5wA0jIwmD7/RF/+AhywKzpvaes
         Z9HerAgUxRp4MEJXaXZBkzLo2Y0fkY8ILZ/VL7Novnh/SB74dmmHeUOgqZHlzp2eHxff
         598LYTbv3FytU87MYENZjh97qqJOtoh8wBKEfWXUzuLZrPQyrCiNiA5fouKpQFs/1pHv
         vWUWlPe0gfLXaJjRtJl23ehbbrtNKyi/nJPkmNW22rwymOo0IU7wA8t7v399YDoKovpe
         Px2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hoUX4+aA;
       spf=pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liu.song.a23@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p45sor28360206qtp.35.2019.03.01.11.12.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 11:12:55 -0800 (PST)
Received-SPF: pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hoUX4+aA;
       spf=pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liu.song.a23@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2IDy1+JnazifkseAC7wCt+QbxwzYPyMdtElpePui2LE=;
        b=hoUX4+aAZMvr3dEyjlosuWn4jHBvrLetJZ04MM9LCP9KUDNe8vu+donW5bAk9AnHOu
         iXO1wGtiZkZqLMNXCDTeiLiZUDTWCYLIlhNkvE7CiiwgQNwgGuHFYLF/MD8VRVCHdIq1
         wKwvaf44hgjSVQirfzv3QG95OICXAfTxGvUrQTG+wUrtV3oRCE76Pr7KhxBb0u/b5yjH
         53DsFICd9RjlskgSsEKhm2wLh1oczV7W3qj4QP2kCzYkKXZ5GdpE52Zpdn1TeThmgARo
         gGs0/JGHvT34Frrr9eJKiqf/O4Z/nTamr6KrHn0gB5tgmSrUgNtzjWRK9HqnqCa9sb28
         icgQ==
X-Google-Smtp-Source: APXvYqzWJzcWA1Qeg55wEjT1goyG+JoHcWFUl1kz67AK3gbTONi2yHzpRoaP/SeYP57BF0ddXRKizISSZDN1aDGCnRU=
X-Received: by 2002:ac8:3011:: with SMTP id f17mr5174674qte.268.1551467575060;
 Fri, 01 Mar 2019 11:12:55 -0800 (PST)
MIME-Version: 1.0
References: <20190215222525.17802-1-willy@infradead.org>
In-Reply-To: <20190215222525.17802-1-willy@infradead.org>
From: Song Liu <liu.song.a23@gmail.com>
Date: Fri, 1 Mar 2019 11:12:44 -0800
Message-ID: <CAPhsuW7Hu6jBn-ti7S2cJhO1YQYg_RDZUgkqtgFO8zpBMV_9LA@mail.gmail.com>
Subject: Re: [PATCH v3] page cache: Store only head pages in i_pages
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, 
	open list <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, 
	William Kucharski <william.kucharski@oracle.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 2:25 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> Transparent Huge Pages are currently stored in i_pages as pointers to
> consecutive subpages.  This patch changes that to storing consecutive
> pointers to the head page in preparation for storing huge pages more
> efficiently in i_pages.
>
> Large parts of this are "inspired" by Kirill's patch
> https://lore.kernel.org/lkml/20170126115819.58875-2-kirill.shutemov@linux.intel.com/
>
> Signed-off-by: Matthew Wilcox <willy@infradead.org>
> Acked-by: Jan Kara <jack@suse.cz>
> Reviewed-by: Kirill Shutemov <kirill@shutemov.name>
> ---
>  include/linux/pagemap.h |   9 +++
>  mm/filemap.c            | 158 ++++++++++++++++------------------------
>  mm/huge_memory.c        |   3 +
>  mm/khugepaged.c         |   4 +-
>  mm/memfd.c              |   2 +
>  mm/migrate.c            |   2 +-
>  mm/shmem.c              |   2 +-
>  mm/swap_state.c         |   4 +-
>  8 files changed, 81 insertions(+), 103 deletions(-)
>
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index bcf909d0de5f..7d58e4e0b68e 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -333,6 +333,15 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
>                         mapping_gfp_mask(mapping));
>  }
>
> +static inline struct page *find_subpage(struct page *page, pgoff_t offset)
> +{
> +       VM_BUG_ON_PAGE(PageTail(page), page);
> +       VM_BUG_ON_PAGE(page->index > offset, page);
> +       VM_BUG_ON_PAGE(page->index + (1 << compound_order(page)) <= offset,
> +                       page);
> +       return page - page->index + offset;
> +}
> +
>  struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);
>  struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset);
>  unsigned find_get_entries(struct address_space *mapping, pgoff_t start,
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 5673672fd444..d9161cae11b5 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -279,11 +279,11 @@ EXPORT_SYMBOL(delete_from_page_cache);
>   * @pvec: pagevec with pages to delete
>   *
>   * The function walks over mapping->i_pages and removes pages passed in @pvec
> - * from the mapping. The function expects @pvec to be sorted by page index.
> + * from the mapping. The function expects @pvec to be sorted by page index
> + * and is optimised for it to be dense.
>   * It tolerates holes in @pvec (mapping entries at those indices are not
>   * modified). The function expects only THP head pages to be present in the
> - * @pvec and takes care to delete all corresponding tail pages from the
> - * mapping as well.
> + * @pvec.
>   *
>   * The function expects the i_pages lock to be held.
>   */
> @@ -292,40 +292,43 @@ static void page_cache_delete_batch(struct address_space *mapping,
>  {
>         XA_STATE(xas, &mapping->i_pages, pvec->pages[0]->index);
>         int total_pages = 0;
> -       int i = 0, tail_pages = 0;
> +       int i = 0;
>         struct page *page;
>
>         mapping_set_update(&xas, mapping);
>         xas_for_each(&xas, page, ULONG_MAX) {
> -               if (i >= pagevec_count(pvec) && !tail_pages)
> +               if (i >= pagevec_count(pvec))
>                         break;
> +
> +               /* A swap/dax/shadow entry got inserted? Skip it. */
>                 if (xa_is_value(page))
>                         continue;
> -               if (!tail_pages) {
> -                       /*
> -                        * Some page got inserted in our range? Skip it. We
> -                        * have our pages locked so they are protected from
> -                        * being removed.
> -                        */
> -                       if (page != pvec->pages[i]) {
> -                               VM_BUG_ON_PAGE(page->index >
> -                                               pvec->pages[i]->index, page);
> -                               continue;
> -                       }
> -                       WARN_ON_ONCE(!PageLocked(page));
> -                       if (PageTransHuge(page) && !PageHuge(page))
> -                               tail_pages = HPAGE_PMD_NR - 1;
> +               /*
> +                * A page got inserted in our range? Skip it. We have our
> +                * pages locked so they are protected from being removed.
> +                * If we see a page whose index is higher than ours, it
> +                * means our page has been removed, which shouldn't be
> +                * possible because we're holding the PageLock.
> +                */
> +               if (page != pvec->pages[i]) {
> +                       VM_BUG_ON_PAGE(page->index > pvec->pages[i]->index,
> +                                       page);
> +                       continue;
> +               }
> +
> +               WARN_ON_ONCE(!PageLocked(page));
> +
> +               if (page->index == xas.xa_index)
>                         page->mapping = NULL;
> -                       /*
> -                        * Leave page->index set: truncation lookup relies
> -                        * upon it
> -                        */
> +               /* Leave page->index set: truncation lookup relies on it */
> +
> +               /*
> +                * Move to the next page in the vector if this is a small page
> +                * or the index is of the last page in this compound page).
> +                */
> +               if (page->index + (1UL << compound_order(page)) - 1 ==
> +                               xas.xa_index)
>                         i++;
> -               } else {
> -                       VM_BUG_ON_PAGE(page->index + HPAGE_PMD_NR - tail_pages
> -                                       != pvec->pages[i]->index, page);
> -                       tail_pages--;
> -               }
>                 xas_store(&xas, NULL);
>                 total_pages++;
>         }
> @@ -1491,7 +1494,7 @@ EXPORT_SYMBOL(page_cache_prev_miss);
>  struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
>  {
>         XA_STATE(xas, &mapping->i_pages, offset);
> -       struct page *head, *page;
> +       struct page *page;
>
>         rcu_read_lock();
>  repeat:
> @@ -1506,25 +1509,19 @@ struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
>         if (!page || xa_is_value(page))
>                 goto out;
>
> -       head = compound_head(page);
> -       if (!page_cache_get_speculative(head))
> +       if (!page_cache_get_speculative(page))
>                 goto repeat;
>
> -       /* The page was split under us? */
> -       if (compound_head(page) != head) {
> -               put_page(head);
> -               goto repeat;
> -       }
> -
>         /*
> -        * Has the page moved?
> +        * Has the page moved or been split?
>          * This is part of the lockless pagecache protocol. See
>          * include/linux/pagemap.h for details.
>          */
>         if (unlikely(page != xas_reload(&xas))) {
> -               put_page(head);
> +               put_page(page);
>                 goto repeat;
>         }
> +       page = find_subpage(page, offset);
>  out:
>         rcu_read_unlock();
>
> @@ -1706,7 +1703,6 @@ unsigned find_get_entries(struct address_space *mapping,
>
>         rcu_read_lock();
>         xas_for_each(&xas, page, ULONG_MAX) {
> -               struct page *head;
>                 if (xas_retry(&xas, page))
>                         continue;
>                 /*
> @@ -1717,17 +1713,13 @@ unsigned find_get_entries(struct address_space *mapping,
>                 if (xa_is_value(page))
>                         goto export;
>
> -               head = compound_head(page);
> -               if (!page_cache_get_speculative(head))
> +               if (!page_cache_get_speculative(page))
>                         goto retry;
>
> -               /* The page was split under us? */
> -               if (compound_head(page) != head)
> -                       goto put_page;
> -
> -               /* Has the page moved? */
> +               /* Has the page moved or been split? */
>                 if (unlikely(page != xas_reload(&xas)))
>                         goto put_page;
> +               page = find_subpage(page, xas.xa_index);
>
>  export:
>                 indices[ret] = xas.xa_index;
> @@ -1736,7 +1728,7 @@ unsigned find_get_entries(struct address_space *mapping,
>                         break;
>                 continue;
>  put_page:
> -               put_page(head);
> +               put_page(page);
>  retry:
>                 xas_reset(&xas);
>         }
> @@ -1778,33 +1770,27 @@ unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
>
>         rcu_read_lock();
>         xas_for_each(&xas, page, end) {
> -               struct page *head;
>                 if (xas_retry(&xas, page))
>                         continue;
>                 /* Skip over shadow, swap and DAX entries */
>                 if (xa_is_value(page))
>                         continue;
>
> -               head = compound_head(page);
> -               if (!page_cache_get_speculative(head))
> +               if (!page_cache_get_speculative(page))
>                         goto retry;
>
> -               /* The page was split under us? */
> -               if (compound_head(page) != head)
> -                       goto put_page;
> -
> -               /* Has the page moved? */
> +               /* Has the page moved or been split? */
>                 if (unlikely(page != xas_reload(&xas)))
>                         goto put_page;
>
> -               pages[ret] = page;
> +               pages[ret] = find_subpage(page, xas.xa_index);
>                 if (++ret == nr_pages) {
>                         *start = page->index + 1;
>                         goto out;
>                 }
>                 continue;
>  put_page:
> -               put_page(head);
> +               put_page(page);
>  retry:
>                 xas_reset(&xas);
>         }
> @@ -1849,7 +1835,6 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
>
>         rcu_read_lock();
>         for (page = xas_load(&xas); page; page = xas_next(&xas)) {
> -               struct page *head;
>                 if (xas_retry(&xas, page))
>                         continue;
>                 /*
> @@ -1859,24 +1844,19 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
>                 if (xa_is_value(page))
>                         break;
>
> -               head = compound_head(page);
> -               if (!page_cache_get_speculative(head))
> +               if (!page_cache_get_speculative(page))
>                         goto retry;
>
> -               /* The page was split under us? */
> -               if (compound_head(page) != head)
> -                       goto put_page;
> -
> -               /* Has the page moved? */
> +               /* Has the page moved or been split? */
>                 if (unlikely(page != xas_reload(&xas)))
>                         goto put_page;
>
> -               pages[ret] = page;
> +               pages[ret] = find_subpage(page, xas.xa_index);
>                 if (++ret == nr_pages)
>                         break;
>                 continue;
>  put_page:
> -               put_page(head);
> +               put_page(page);
>  retry:
>                 xas_reset(&xas);
>         }
> @@ -1912,7 +1892,6 @@ unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
>
>         rcu_read_lock();
>         xas_for_each_marked(&xas, page, end, tag) {
> -               struct page *head;
>                 if (xas_retry(&xas, page))
>                         continue;
>                 /*
> @@ -1923,26 +1902,21 @@ unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
>                 if (xa_is_value(page))
>                         continue;
>
> -               head = compound_head(page);
> -               if (!page_cache_get_speculative(head))
> +               if (!page_cache_get_speculative(page))
>                         goto retry;
>
> -               /* The page was split under us? */
> -               if (compound_head(page) != head)
> -                       goto put_page;
> -
> -               /* Has the page moved? */
> +               /* Has the page moved or been split? */
>                 if (unlikely(page != xas_reload(&xas)))
>                         goto put_page;
>
> -               pages[ret] = page;
> +               pages[ret] = find_subpage(page, xas.xa_index);
>                 if (++ret == nr_pages) {
>                         *index = page->index + 1;
>                         goto out;
>                 }
>                 continue;
>  put_page:
> -               put_page(head);
> +               put_page(page);
>  retry:
>                 xas_reset(&xas);
>         }
> @@ -1991,7 +1965,6 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
>
>         rcu_read_lock();
>         xas_for_each_marked(&xas, page, ULONG_MAX, tag) {
> -               struct page *head;
>                 if (xas_retry(&xas, page))
>                         continue;
>                 /*
> @@ -2002,17 +1975,13 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
>                 if (xa_is_value(page))
>                         goto export;
>
> -               head = compound_head(page);
> -               if (!page_cache_get_speculative(head))
> +               if (!page_cache_get_speculative(page))
>                         goto retry;
>
> -               /* The page was split under us? */
> -               if (compound_head(page) != head)
> -                       goto put_page;
> -
> -               /* Has the page moved? */
> +               /* Has the page moved or been split? */
>                 if (unlikely(page != xas_reload(&xas)))
>                         goto put_page;
> +               page = find_subpage(page, xas.xa_index);
>
>  export:
>                 indices[ret] = xas.xa_index;
> @@ -2021,7 +1990,7 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
>                         break;
>                 continue;
>  put_page:
> -               put_page(head);
> +               put_page(page);
>  retry:
>                 xas_reset(&xas);
>         }
> @@ -2686,7 +2655,7 @@ void filemap_map_pages(struct vm_fault *vmf,
>         pgoff_t last_pgoff = start_pgoff;
>         unsigned long max_idx;
>         XA_STATE(xas, &mapping->i_pages, start_pgoff);
> -       struct page *head, *page;
> +       struct page *page;
>
>         rcu_read_lock();
>         xas_for_each(&xas, page, end_pgoff) {
> @@ -2695,24 +2664,19 @@ void filemap_map_pages(struct vm_fault *vmf,
>                 if (xa_is_value(page))
>                         goto next;
>
> -               head = compound_head(page);
> -
>                 /*
>                  * Check for a locked page first, as a speculative
>                  * reference may adversely influence page migration.
>                  */
> -               if (PageLocked(head))
> +               if (PageLocked(page))
>                         goto next;
> -               if (!page_cache_get_speculative(head))
> +               if (!page_cache_get_speculative(page))
>                         goto next;
>
> -               /* The page was split under us? */
> -               if (compound_head(page) != head)
> -                       goto skip;
> -
> -               /* Has the page moved? */
> +               /* Has the page moved or been split? */
>                 if (unlikely(page != xas_reload(&xas)))
>                         goto skip;
> +               page = find_subpage(page, xas.xa_index);
>
>                 if (!PageUptodate(page) ||
>                                 PageReadahead(page) ||
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index d4847026d4b1..7008174c033b 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2458,6 +2458,9 @@ static void __split_huge_page(struct page *page, struct list_head *list,
>                         if (IS_ENABLED(CONFIG_SHMEM) && PageSwapBacked(head))
>                                 shmem_uncharge(head->mapping->host, 1);
>                         put_page(head + i);
> +               } else if (!PageAnon(page)) {
> +                       __xa_store(&head->mapping->i_pages, head[i].index,
> +                                       head + i, 0);
>                 }
>         }
>
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 449044378782..7ba7a1e4fa79 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1374,7 +1374,7 @@ static void collapse_shmem(struct mm_struct *mm,
>                                 result = SCAN_FAIL;
>                                 goto xa_locked;
>                         }
> -                       xas_store(&xas, new_page + (index % HPAGE_PMD_NR));
> +                       xas_store(&xas, new_page);
>                         nr_none++;
>                         continue;
>                 }
> @@ -1450,7 +1450,7 @@ static void collapse_shmem(struct mm_struct *mm,
>                 list_add_tail(&page->lru, &pagelist);
>
>                 /* Finally, replace with the new page. */
> -               xas_store(&xas, new_page + (index % HPAGE_PMD_NR));
> +               xas_store(&xas, new_page);
>                 continue;
>  out_unlock:
>                 unlock_page(page);
> diff --git a/mm/memfd.c b/mm/memfd.c
> index 650e65a46b9c..bccbf7dff050 100644
> --- a/mm/memfd.c
> +++ b/mm/memfd.c
> @@ -39,6 +39,7 @@ static void memfd_tag_pins(struct xa_state *xas)
>         xas_for_each(xas, page, ULONG_MAX) {
>                 if (xa_is_value(page))
>                         continue;
> +               page = find_subpage(page, xas.xa_index);

This should be xas->xa_index.

I fixed this and am trying to test the patch.

Thanks,
Song

>                 if (page_count(page) - page_mapcount(page) > 1)
>                         xas_set_mark(xas, MEMFD_TAG_PINNED);
>
> @@ -88,6 +89,7 @@ static int memfd_wait_for_pins(struct address_space *mapping)
>                         bool clear = true;
>                         if (xa_is_value(page))
>                                 continue;
> +                       page = find_subpage(page, xas.xa_index);
>                         if (page_count(page) - page_mapcount(page) != 1) {
>                                 /*
>                                  * On the last scan, we clean up all those tags
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 412d5fff78d4..8cb55dd69b9c 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -465,7 +465,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
>
>                 for (i = 1; i < HPAGE_PMD_NR; i++) {
>                         xas_next(&xas);
> -                       xas_store(&xas, newpage + i);
> +                       xas_store(&xas, newpage);
>                 }
>         }
>
> diff --git a/mm/shmem.c b/mm/shmem.c
> index c8cdaa012f18..a78d4f05a51f 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -614,7 +614,7 @@ static int shmem_add_to_page_cache(struct page *page,
>                 if (xas_error(&xas))
>                         goto unlock;
>  next:
> -               xas_store(&xas, page + i);
> +               xas_store(&xas, page);
>                 if (++i < nr) {
>                         xas_next(&xas);
>                         goto next;
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 85245fdec8d9..eb714165afd2 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -132,7 +132,7 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp)
>                 for (i = 0; i < nr; i++) {
>                         VM_BUG_ON_PAGE(xas.xa_index != idx + i, page);
>                         set_page_private(page + i, entry.val + i);
> -                       xas_store(&xas, page + i);
> +                       xas_store(&xas, page);
>                         xas_next(&xas);
>                 }
>                 address_space->nrpages += nr;
> @@ -167,7 +167,7 @@ void __delete_from_swap_cache(struct page *page, swp_entry_t entry)
>
>         for (i = 0; i < nr; i++) {
>                 void *entry = xas_store(&xas, NULL);
> -               VM_BUG_ON_PAGE(entry != page + i, entry);
> +               VM_BUG_ON_PAGE(entry != page, entry);
>                 set_page_private(page + i, 0);
>                 xas_next(&xas);
>         }
> --
> 2.20.1
>

