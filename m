Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4340C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 22:20:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F37A2083D
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 22:20:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cqXcy1MS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F37A2083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E06E58E0005; Fri,  1 Mar 2019 17:20:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8D7C8E0001; Fri,  1 Mar 2019 17:20:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7B348E0005; Fri,  1 Mar 2019 17:20:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 94D5B8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 17:20:41 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id p40so1970776qtb.10
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 14:20:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=i+9qVo3On16b5aa2xbAF9qmtndSmDUVGGh1Q+Udsgjg=;
        b=LugR/fwqwtJaX/Eiqhxv3D06hsq8Qz7PSujM8LtiSPa5d6CgS1guWg2XnfrPp8SdU8
         tUZSORsqoOHbGT0g3s3TSop4v3cX9+F7GjroWdBwwvvi+eDXsz1xqlaQJAWTyc+HbiDB
         SpBtmbGPd5igpVKN5OEJvkfCzAHdTev8NQPbSrOHcGVK83Rrwylwe9ihjt6ciQgR2Aqs
         4Er88Ss0I76hPaSSylMjmnq8yij7l8wSuWSibMJ4Ox0dAhxzcZr9P3fqwLto2deHL/zM
         7fw7WvhQPmb20eZM8L7ATG3IwlhFmdyohDtaa95AZrpEuRKLARS9xY+E8A2EqeJVnFaB
         ugiA==
X-Gm-Message-State: APjAAAVspNAOL3fGiyyiVtILgPew7H9geYCVixbCqYAQWutiSL+A0anQ
	68kswBZEfYzKZoTR2OB3nSgNaAkDV9jvhyEAatoGi+hE8YdEDxJXscNRfmX7P/H1P7R7NdE3gtO
	PtnNlKDpCyRFEUrshqxz900Ra6rDcEeWSUUnl0D04pe0iPt9BRqkOIAzy5XA7FvWykAAW4DOh1L
	a0dgvO3cd5DT36OAb5CLI18MJRsUDFvSQhU7SGGVgfxw6uupeoxyg1R5j3r7AIE2Djcb7bnsyHn
	kLHxdw6WhEfUf0QiBS059BYWMezgD9j7b+TNXwO6IzyKHhfVueUGD19z067JeCbvkPBsCj4vUKW
	BDlvMPzvW8OzuHs9olukPo9gGQ75dvLNYtTpVw6SVEQ1WkYZSAVdmKrf2NUu8ecTVp/OZWRSw3U
	v
X-Received: by 2002:a37:340c:: with SMTP id b12mr5721566qka.144.1551478841322;
        Fri, 01 Mar 2019 14:20:41 -0800 (PST)
X-Received: by 2002:a37:340c:: with SMTP id b12mr5721501qka.144.1551478840010;
        Fri, 01 Mar 2019 14:20:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551478840; cv=none;
        d=google.com; s=arc-20160816;
        b=fd2co4I26ytbXm3iAAdRQrojkwTU9BPwXYRek97Y6HuJvIYMFSzdrhmAHpHXM/6ZJz
         cdTGbFfjGRratyrftI4Wr9dQxz1EnLJdNKM4CsfNo2641y/iVu4oRO/6UFwjsQEcX+KM
         atqcBVRAzLqRDbg6xW/sStBHQ4HWVFUmbURl6yHmS+ZV5iF0xmZxz1k66jHn8PLXdT8h
         QO489bSdlvKpL73vyX3lkiDk3OV5iuf/3dO1J/F7TykFtQViAw0rEBk8vOVfm5B27IfW
         /viNDhDlGUjyOLH1Ih8V+DFuSQzt9xNdDmS5OHBLOzOuhuMIWPAFv8lb1t0EHl6EBawr
         0yvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=i+9qVo3On16b5aa2xbAF9qmtndSmDUVGGh1Q+Udsgjg=;
        b=s9kOu+5HOH1i67j+K40bk9Ur/XRgvTvxkuCZtSWE4vU6LFoY49O0eaPgTkE8v3/DK0
         QQBmz5vpsHbHLOJzMy7a3Ds7iGpt8klXaBLWFXfjDQnSzA2iEvhSvdSvSzPYMIWtThXe
         f91+SQaOnlLxX+krZoKhnv+opvjAoBVrdXR/WwencZ7MM04FmNivF94zsixc+HX748f4
         ZwptSu2bIQLqBsCOjw9KLYJi8lkzUFUpHZUl3IjoCgjTNL7BCjVujs+cZkvHI1tagAHz
         54wBemIrZdL8L/bftNL7+avJ0c2Chm46mzl4FTP7ONqdGbHZI48vLkanzJbPOFpbGf3d
         LmVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cqXcy1MS;
       spf=pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liu.song.a23@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y190sor13075222qka.113.2019.03.01.14.20.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 14:20:39 -0800 (PST)
Received-SPF: pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cqXcy1MS;
       spf=pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liu.song.a23@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=i+9qVo3On16b5aa2xbAF9qmtndSmDUVGGh1Q+Udsgjg=;
        b=cqXcy1MSPin3CVj2ylRNgSqOS5Y7nQ1TgPxOv/gfn/5NHWdTngKPlbLAsZ46V6vBUf
         YdA2osl5T9TgCyGkhlpc5lh9WsZlUvnODc4ruCSBrvMg6z7ok9G8t+SEUUpcATI9eiPc
         /8tQBw01HdmsxCYrT+xKjx1Rlom2fX/VrdUEVPjVR9sqzCZOKQPIMvYSyw8wQw6Dr6Ua
         cTtR6RRPFNWYv0zdH+V/nrNQcvsrkBR3V9PVVyQNc2frHVgr8Xyd0Byh1p1x/6q/ppNn
         LjmubpEllec5DzcahN0W53HwC4EuquKY/Zd0pNV7OJsh38qX7gmUDEbvEZHyPuANfwzX
         hfCg==
X-Google-Smtp-Source: APXvYqyPVqB5chZF/I9XoNAT6eEPfApvxGoX7bVH55ZaPOs7JTZp4bQ6Ng13wx4lEih2T6nzimrgm54IpoSl8XFRMkI=
X-Received: by 2002:a37:bc04:: with SMTP id m4mr5644239qkf.41.1551478839615;
 Fri, 01 Mar 2019 14:20:39 -0800 (PST)
MIME-Version: 1.0
References: <20190215222525.17802-1-willy@infradead.org> <CAPhsuW7Hu6jBn-ti7S2cJhO1YQYg_RDZUgkqtgFO8zpBMV_9LA@mail.gmail.com>
In-Reply-To: <CAPhsuW7Hu6jBn-ti7S2cJhO1YQYg_RDZUgkqtgFO8zpBMV_9LA@mail.gmail.com>
From: Song Liu <liu.song.a23@gmail.com>
Date: Fri, 1 Mar 2019 14:20:27 -0800
Message-ID: <CAPhsuW5a8=QJe2acWXQGWic1a=CJigwPR6BxSu2O2vg4W1mhzA@mail.gmail.com>
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

On Fri, Mar 1, 2019 at 11:12 AM Song Liu <liu.song.a23@gmail.com> wrote:
>
> On Fri, Feb 15, 2019 at 2:25 PM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > Transparent Huge Pages are currently stored in i_pages as pointers to
> > consecutive subpages.  This patch changes that to storing consecutive
> > pointers to the head page in preparation for storing huge pages more
> > efficiently in i_pages.
> >
> > Large parts of this are "inspired" by Kirill's patch
> > https://lore.kernel.org/lkml/20170126115819.58875-2-kirill.shutemov@linux.intel.com/
> >
> > Signed-off-by: Matthew Wilcox <willy@infradead.org>
> > Acked-by: Jan Kara <jack@suse.cz>
> > Reviewed-by: Kirill Shutemov <kirill@shutemov.name>

I tested with shmem with huge=always and huge=advise. Both works fine.
I also run some stress tests with CONFIG_DEBUG_VM, nothing breaks.

Other than the minor fix in memfd_tag_pins(),

Reviewed-and-tested-by: Song Liu <songliubraving@fb.com>

> > ---
> >  include/linux/pagemap.h |   9 +++
> >  mm/filemap.c            | 158 ++++++++++++++++------------------------
> >  mm/huge_memory.c        |   3 +
> >  mm/khugepaged.c         |   4 +-
> >  mm/memfd.c              |   2 +
> >  mm/migrate.c            |   2 +-
> >  mm/shmem.c              |   2 +-
> >  mm/swap_state.c         |   4 +-
> >  8 files changed, 81 insertions(+), 103 deletions(-)
> >
> > diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> > index bcf909d0de5f..7d58e4e0b68e 100644
> > --- a/include/linux/pagemap.h
> > +++ b/include/linux/pagemap.h
> > @@ -333,6 +333,15 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
> >                         mapping_gfp_mask(mapping));
> >  }
> >
> > +static inline struct page *find_subpage(struct page *page, pgoff_t offset)
> > +{
> > +       VM_BUG_ON_PAGE(PageTail(page), page);
> > +       VM_BUG_ON_PAGE(page->index > offset, page);
> > +       VM_BUG_ON_PAGE(page->index + (1 << compound_order(page)) <= offset,
> > +                       page);
> > +       return page - page->index + offset;
> > +}
> > +
> >  struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);
> >  struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset);
> >  unsigned find_get_entries(struct address_space *mapping, pgoff_t start,
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 5673672fd444..d9161cae11b5 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -279,11 +279,11 @@ EXPORT_SYMBOL(delete_from_page_cache);
> >   * @pvec: pagevec with pages to delete
> >   *
> >   * The function walks over mapping->i_pages and removes pages passed in @pvec
> > - * from the mapping. The function expects @pvec to be sorted by page index.
> > + * from the mapping. The function expects @pvec to be sorted by page index
> > + * and is optimised for it to be dense.
> >   * It tolerates holes in @pvec (mapping entries at those indices are not
> >   * modified). The function expects only THP head pages to be present in the
> > - * @pvec and takes care to delete all corresponding tail pages from the
> > - * mapping as well.
> > + * @pvec.
> >   *
> >   * The function expects the i_pages lock to be held.
> >   */
> > @@ -292,40 +292,43 @@ static void page_cache_delete_batch(struct address_space *mapping,
> >  {
> >         XA_STATE(xas, &mapping->i_pages, pvec->pages[0]->index);
> >         int total_pages = 0;
> > -       int i = 0, tail_pages = 0;
> > +       int i = 0;
> >         struct page *page;
> >
> >         mapping_set_update(&xas, mapping);
> >         xas_for_each(&xas, page, ULONG_MAX) {
> > -               if (i >= pagevec_count(pvec) && !tail_pages)
> > +               if (i >= pagevec_count(pvec))
> >                         break;
> > +
> > +               /* A swap/dax/shadow entry got inserted? Skip it. */
> >                 if (xa_is_value(page))
> >                         continue;
> > -               if (!tail_pages) {
> > -                       /*
> > -                        * Some page got inserted in our range? Skip it. We
> > -                        * have our pages locked so they are protected from
> > -                        * being removed.
> > -                        */
> > -                       if (page != pvec->pages[i]) {
> > -                               VM_BUG_ON_PAGE(page->index >
> > -                                               pvec->pages[i]->index, page);
> > -                               continue;
> > -                       }
> > -                       WARN_ON_ONCE(!PageLocked(page));
> > -                       if (PageTransHuge(page) && !PageHuge(page))
> > -                               tail_pages = HPAGE_PMD_NR - 1;
> > +               /*
> > +                * A page got inserted in our range? Skip it. We have our
> > +                * pages locked so they are protected from being removed.
> > +                * If we see a page whose index is higher than ours, it
> > +                * means our page has been removed, which shouldn't be
> > +                * possible because we're holding the PageLock.
> > +                */
> > +               if (page != pvec->pages[i]) {
> > +                       VM_BUG_ON_PAGE(page->index > pvec->pages[i]->index,
> > +                                       page);
> > +                       continue;
> > +               }
> > +
> > +               WARN_ON_ONCE(!PageLocked(page));
> > +
> > +               if (page->index == xas.xa_index)
> >                         page->mapping = NULL;
> > -                       /*
> > -                        * Leave page->index set: truncation lookup relies
> > -                        * upon it
> > -                        */
> > +               /* Leave page->index set: truncation lookup relies on it */
> > +
> > +               /*
> > +                * Move to the next page in the vector if this is a small page
> > +                * or the index is of the last page in this compound page).
> > +                */
> > +               if (page->index + (1UL << compound_order(page)) - 1 ==
> > +                               xas.xa_index)
> >                         i++;
> > -               } else {
> > -                       VM_BUG_ON_PAGE(page->index + HPAGE_PMD_NR - tail_pages
> > -                                       != pvec->pages[i]->index, page);
> > -                       tail_pages--;
> > -               }
> >                 xas_store(&xas, NULL);
> >                 total_pages++;
> >         }
> > @@ -1491,7 +1494,7 @@ EXPORT_SYMBOL(page_cache_prev_miss);
> >  struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
> >  {
> >         XA_STATE(xas, &mapping->i_pages, offset);
> > -       struct page *head, *page;
> > +       struct page *page;
> >
> >         rcu_read_lock();
> >  repeat:
> > @@ -1506,25 +1509,19 @@ struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
> >         if (!page || xa_is_value(page))
> >                 goto out;
> >
> > -       head = compound_head(page);
> > -       if (!page_cache_get_speculative(head))
> > +       if (!page_cache_get_speculative(page))
> >                 goto repeat;
> >
> > -       /* The page was split under us? */
> > -       if (compound_head(page) != head) {
> > -               put_page(head);
> > -               goto repeat;
> > -       }
> > -
> >         /*
> > -        * Has the page moved?
> > +        * Has the page moved or been split?
> >          * This is part of the lockless pagecache protocol. See
> >          * include/linux/pagemap.h for details.
> >          */
> >         if (unlikely(page != xas_reload(&xas))) {
> > -               put_page(head);
> > +               put_page(page);
> >                 goto repeat;
> >         }
> > +       page = find_subpage(page, offset);
> >  out:
> >         rcu_read_unlock();
> >
> > @@ -1706,7 +1703,6 @@ unsigned find_get_entries(struct address_space *mapping,
> >
> >         rcu_read_lock();
> >         xas_for_each(&xas, page, ULONG_MAX) {
> > -               struct page *head;
> >                 if (xas_retry(&xas, page))
> >                         continue;
> >                 /*
> > @@ -1717,17 +1713,13 @@ unsigned find_get_entries(struct address_space *mapping,
> >                 if (xa_is_value(page))
> >                         goto export;
> >
> > -               head = compound_head(page);
> > -               if (!page_cache_get_speculative(head))
> > +               if (!page_cache_get_speculative(page))
> >                         goto retry;
> >
> > -               /* The page was split under us? */
> > -               if (compound_head(page) != head)
> > -                       goto put_page;
> > -
> > -               /* Has the page moved? */
> > +               /* Has the page moved or been split? */
> >                 if (unlikely(page != xas_reload(&xas)))
> >                         goto put_page;
> > +               page = find_subpage(page, xas.xa_index);
> >
> >  export:
> >                 indices[ret] = xas.xa_index;
> > @@ -1736,7 +1728,7 @@ unsigned find_get_entries(struct address_space *mapping,
> >                         break;
> >                 continue;
> >  put_page:
> > -               put_page(head);
> > +               put_page(page);
> >  retry:
> >                 xas_reset(&xas);
> >         }
> > @@ -1778,33 +1770,27 @@ unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
> >
> >         rcu_read_lock();
> >         xas_for_each(&xas, page, end) {
> > -               struct page *head;
> >                 if (xas_retry(&xas, page))
> >                         continue;
> >                 /* Skip over shadow, swap and DAX entries */
> >                 if (xa_is_value(page))
> >                         continue;
> >
> > -               head = compound_head(page);
> > -               if (!page_cache_get_speculative(head))
> > +               if (!page_cache_get_speculative(page))
> >                         goto retry;
> >
> > -               /* The page was split under us? */
> > -               if (compound_head(page) != head)
> > -                       goto put_page;
> > -
> > -               /* Has the page moved? */
> > +               /* Has the page moved or been split? */
> >                 if (unlikely(page != xas_reload(&xas)))
> >                         goto put_page;
> >
> > -               pages[ret] = page;
> > +               pages[ret] = find_subpage(page, xas.xa_index);
> >                 if (++ret == nr_pages) {
> >                         *start = page->index + 1;
> >                         goto out;
> >                 }
> >                 continue;
> >  put_page:
> > -               put_page(head);
> > +               put_page(page);
> >  retry:
> >                 xas_reset(&xas);
> >         }
> > @@ -1849,7 +1835,6 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
> >
> >         rcu_read_lock();
> >         for (page = xas_load(&xas); page; page = xas_next(&xas)) {
> > -               struct page *head;
> >                 if (xas_retry(&xas, page))
> >                         continue;
> >                 /*
> > @@ -1859,24 +1844,19 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
> >                 if (xa_is_value(page))
> >                         break;
> >
> > -               head = compound_head(page);
> > -               if (!page_cache_get_speculative(head))
> > +               if (!page_cache_get_speculative(page))
> >                         goto retry;
> >
> > -               /* The page was split under us? */
> > -               if (compound_head(page) != head)
> > -                       goto put_page;
> > -
> > -               /* Has the page moved? */
> > +               /* Has the page moved or been split? */
> >                 if (unlikely(page != xas_reload(&xas)))
> >                         goto put_page;
> >
> > -               pages[ret] = page;
> > +               pages[ret] = find_subpage(page, xas.xa_index);
> >                 if (++ret == nr_pages)
> >                         break;
> >                 continue;
> >  put_page:
> > -               put_page(head);
> > +               put_page(page);
> >  retry:
> >                 xas_reset(&xas);
> >         }
> > @@ -1912,7 +1892,6 @@ unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
> >
> >         rcu_read_lock();
> >         xas_for_each_marked(&xas, page, end, tag) {
> > -               struct page *head;
> >                 if (xas_retry(&xas, page))
> >                         continue;
> >                 /*
> > @@ -1923,26 +1902,21 @@ unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
> >                 if (xa_is_value(page))
> >                         continue;
> >
> > -               head = compound_head(page);
> > -               if (!page_cache_get_speculative(head))
> > +               if (!page_cache_get_speculative(page))
> >                         goto retry;
> >
> > -               /* The page was split under us? */
> > -               if (compound_head(page) != head)
> > -                       goto put_page;
> > -
> > -               /* Has the page moved? */
> > +               /* Has the page moved or been split? */
> >                 if (unlikely(page != xas_reload(&xas)))
> >                         goto put_page;
> >
> > -               pages[ret] = page;
> > +               pages[ret] = find_subpage(page, xas.xa_index);
> >                 if (++ret == nr_pages) {
> >                         *index = page->index + 1;
> >                         goto out;
> >                 }
> >                 continue;
> >  put_page:
> > -               put_page(head);
> > +               put_page(page);
> >  retry:
> >                 xas_reset(&xas);
> >         }
> > @@ -1991,7 +1965,6 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
> >
> >         rcu_read_lock();
> >         xas_for_each_marked(&xas, page, ULONG_MAX, tag) {
> > -               struct page *head;
> >                 if (xas_retry(&xas, page))
> >                         continue;
> >                 /*
> > @@ -2002,17 +1975,13 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
> >                 if (xa_is_value(page))
> >                         goto export;
> >
> > -               head = compound_head(page);
> > -               if (!page_cache_get_speculative(head))
> > +               if (!page_cache_get_speculative(page))
> >                         goto retry;
> >
> > -               /* The page was split under us? */
> > -               if (compound_head(page) != head)
> > -                       goto put_page;
> > -
> > -               /* Has the page moved? */
> > +               /* Has the page moved or been split? */
> >                 if (unlikely(page != xas_reload(&xas)))
> >                         goto put_page;
> > +               page = find_subpage(page, xas.xa_index);
> >
> >  export:
> >                 indices[ret] = xas.xa_index;
> > @@ -2021,7 +1990,7 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
> >                         break;
> >                 continue;
> >  put_page:
> > -               put_page(head);
> > +               put_page(page);
> >  retry:
> >                 xas_reset(&xas);
> >         }
> > @@ -2686,7 +2655,7 @@ void filemap_map_pages(struct vm_fault *vmf,
> >         pgoff_t last_pgoff = start_pgoff;
> >         unsigned long max_idx;
> >         XA_STATE(xas, &mapping->i_pages, start_pgoff);
> > -       struct page *head, *page;
> > +       struct page *page;
> >
> >         rcu_read_lock();
> >         xas_for_each(&xas, page, end_pgoff) {
> > @@ -2695,24 +2664,19 @@ void filemap_map_pages(struct vm_fault *vmf,
> >                 if (xa_is_value(page))
> >                         goto next;
> >
> > -               head = compound_head(page);
> > -
> >                 /*
> >                  * Check for a locked page first, as a speculative
> >                  * reference may adversely influence page migration.
> >                  */
> > -               if (PageLocked(head))
> > +               if (PageLocked(page))
> >                         goto next;
> > -               if (!page_cache_get_speculative(head))
> > +               if (!page_cache_get_speculative(page))
> >                         goto next;
> >
> > -               /* The page was split under us? */
> > -               if (compound_head(page) != head)
> > -                       goto skip;
> > -
> > -               /* Has the page moved? */
> > +               /* Has the page moved or been split? */
> >                 if (unlikely(page != xas_reload(&xas)))
> >                         goto skip;
> > +               page = find_subpage(page, xas.xa_index);
> >
> >                 if (!PageUptodate(page) ||
> >                                 PageReadahead(page) ||
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index d4847026d4b1..7008174c033b 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -2458,6 +2458,9 @@ static void __split_huge_page(struct page *page, struct list_head *list,
> >                         if (IS_ENABLED(CONFIG_SHMEM) && PageSwapBacked(head))
> >                                 shmem_uncharge(head->mapping->host, 1);
> >                         put_page(head + i);
> > +               } else if (!PageAnon(page)) {
> > +                       __xa_store(&head->mapping->i_pages, head[i].index,
> > +                                       head + i, 0);
> >                 }
> >         }
> >
> > diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> > index 449044378782..7ba7a1e4fa79 100644
> > --- a/mm/khugepaged.c
> > +++ b/mm/khugepaged.c
> > @@ -1374,7 +1374,7 @@ static void collapse_shmem(struct mm_struct *mm,
> >                                 result = SCAN_FAIL;
> >                                 goto xa_locked;
> >                         }
> > -                       xas_store(&xas, new_page + (index % HPAGE_PMD_NR));
> > +                       xas_store(&xas, new_page);
> >                         nr_none++;
> >                         continue;
> >                 }
> > @@ -1450,7 +1450,7 @@ static void collapse_shmem(struct mm_struct *mm,
> >                 list_add_tail(&page->lru, &pagelist);
> >
> >                 /* Finally, replace with the new page. */
> > -               xas_store(&xas, new_page + (index % HPAGE_PMD_NR));
> > +               xas_store(&xas, new_page);
> >                 continue;
> >  out_unlock:
> >                 unlock_page(page);
> > diff --git a/mm/memfd.c b/mm/memfd.c
> > index 650e65a46b9c..bccbf7dff050 100644
> > --- a/mm/memfd.c
> > +++ b/mm/memfd.c
> > @@ -39,6 +39,7 @@ static void memfd_tag_pins(struct xa_state *xas)
> >         xas_for_each(xas, page, ULONG_MAX) {
> >                 if (xa_is_value(page))
> >                         continue;
> > +               page = find_subpage(page, xas.xa_index);
>
> This should be xas->xa_index.
>
> I fixed this and am trying to test the patch.
>
> Thanks,
> Song
>
> >                 if (page_count(page) - page_mapcount(page) > 1)
> >                         xas_set_mark(xas, MEMFD_TAG_PINNED);
> >
> > @@ -88,6 +89,7 @@ static int memfd_wait_for_pins(struct address_space *mapping)
> >                         bool clear = true;
> >                         if (xa_is_value(page))
> >                                 continue;
> > +                       page = find_subpage(page, xas.xa_index);
> >                         if (page_count(page) - page_mapcount(page) != 1) {
> >                                 /*
> >                                  * On the last scan, we clean up all those tags
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 412d5fff78d4..8cb55dd69b9c 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -465,7 +465,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
> >
> >                 for (i = 1; i < HPAGE_PMD_NR; i++) {
> >                         xas_next(&xas);
> > -                       xas_store(&xas, newpage + i);
> > +                       xas_store(&xas, newpage);
> >                 }
> >         }
> >
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index c8cdaa012f18..a78d4f05a51f 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -614,7 +614,7 @@ static int shmem_add_to_page_cache(struct page *page,
> >                 if (xas_error(&xas))
> >                         goto unlock;
> >  next:
> > -               xas_store(&xas, page + i);
> > +               xas_store(&xas, page);
> >                 if (++i < nr) {
> >                         xas_next(&xas);
> >                         goto next;
> > diff --git a/mm/swap_state.c b/mm/swap_state.c
> > index 85245fdec8d9..eb714165afd2 100644
> > --- a/mm/swap_state.c
> > +++ b/mm/swap_state.c
> > @@ -132,7 +132,7 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp)
> >                 for (i = 0; i < nr; i++) {
> >                         VM_BUG_ON_PAGE(xas.xa_index != idx + i, page);
> >                         set_page_private(page + i, entry.val + i);
> > -                       xas_store(&xas, page + i);
> > +                       xas_store(&xas, page);
> >                         xas_next(&xas);
> >                 }
> >                 address_space->nrpages += nr;
> > @@ -167,7 +167,7 @@ void __delete_from_swap_cache(struct page *page, swp_entry_t entry)
> >
> >         for (i = 0; i < nr; i++) {
> >                 void *entry = xas_store(&xas, NULL);
> > -               VM_BUG_ON_PAGE(entry != page + i, entry);
> > +               VM_BUG_ON_PAGE(entry != page, entry);
> >                 set_page_private(page + i, 0);
> >                 xas_next(&xas);
> >         }
> > --
> > 2.20.1
> >

