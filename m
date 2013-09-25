Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9BC3F6B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:03:00 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so300408pad.9
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 13:03:00 -0700 (PDT)
Received: by mail-ve0-f173.google.com with SMTP id cz12so155289veb.18
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 13:02:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1379937950-8411-11-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com> <1379937950-8411-11-git-send-email-kirill.shutemov@linux.intel.com>
From: Ning Qu <quning@google.com>
Date: Wed, 25 Sep 2013 13:02:36 -0700
Message-ID: <CACz4_2cGS0avYGLTZn2kWbuv9qNi_PJVzwnKHftXLSyF-Pr6jA@mail.gmail.com>
Subject: Re: [PATCHv6 10/22] thp, mm: rewrite delete_from_page_cache() to
 support huge pages
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Mon, Sep 23, 2013 at 5:05 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> As with add_to_page_cache_locked() we handle HPAGE_CACHE_NR pages a
> time.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/filemap.c | 20 ++++++++++++++------
>  1 file changed, 14 insertions(+), 6 deletions(-)
>
> diff --git a/mm/filemap.c b/mm/filemap.c
> index d2d6c0ebe9..60478ebeda 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -115,6 +115,7 @@
>  void __delete_from_page_cache(struct page *page)
>  {
>         struct address_space *mapping =3D page->mapping;
> +       int i, nr;
>
>         trace_mm_filemap_delete_from_page_cache(page);
>         /*
> @@ -127,13 +128,20 @@ void __delete_from_page_cache(struct page *page)
>         else
>                 cleancache_invalidate_page(mapping, page);
>
> -       radix_tree_delete(&mapping->page_tree, page->index);
> +       page->mapping =3D NULL;
Seems with this line added, we clear the page->mapping twice? Once
here and another one after radix_tree_delete. Is this necessary here?

>
> +       nr =3D hpagecache_nr_pages(page);
> +       for (i =3D 0; i < nr; i++)
> +               radix_tree_delete(&mapping->page_tree, page->index + i);
> +       /* thp */
> +       if (nr > 1)
> +               __dec_zone_page_state(page, NR_FILE_TRANSPARENT_HUGEPAGES=
);
> +
>         page->mapping =3D NULL;
>         /* Leave page->index set: truncation lookup relies upon it */
> -       mapping->nrpages--;
> -       __dec_zone_page_state(page, NR_FILE_PAGES);
> +       mapping->nrpages -=3D nr;
> +       __mod_zone_page_state(page_zone(page), NR_FILE_PAGES, -nr);
>         if (PageSwapBacked(page))
> -               __dec_zone_page_state(page, NR_SHMEM);
> +               __mod_zone_page_state(page_zone(page), NR_SHMEM, -nr);
>         BUG_ON(page_mapped(page));
>
>         /*
> @@ -144,8 +152,8 @@ void __delete_from_page_cache(struct page *page)
>          * having removed the page entirely.
>          */
>         if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
> -               dec_zone_page_state(page, NR_FILE_DIRTY);
> -               dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
> +               mod_zone_page_state(page_zone(page), NR_FILE_DIRTY, -nr);
> +               add_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE, =
-nr);
>         }
>  }
>
> --
> 1.8.4.rc3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
