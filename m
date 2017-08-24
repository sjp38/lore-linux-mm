Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 715EA28084D
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 03:36:22 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b8so33449539pgn.10
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 00:36:22 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id 101si2524646ple.136.2017.08.24.00.36.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 00:36:21 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH 3/4] mm: soft-offline: retry to split and
 soft-offline the raw error if the original THP offlining fails.
Date: Thu, 24 Aug 2017 07:31:52 +0000
Message-ID: <4c271e6e-c25a-8ce6-0765-20f93c21eb44@ah.jp.nec.com>
References: <20170815015216.31827-1-zi.yan@sent.com>
 <20170815015216.31827-4-zi.yan@sent.com>
In-Reply-To: <20170815015216.31827-4-zi.yan@sent.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <477FE2A80605E8439919A83D44C3C048@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zi Yan <zi.yan@cs.rutgers.edu>

On Mon, Aug 14, 2017 at 09:52:15PM -0400, Zi Yan wrote:
> From: Zi Yan <zi.yan@cs.rutgers.edu>
>=20
> For THP soft-offline support, we first try to migrate a THP without
> splitting. If the migration fails, we split the THP and migrate the
> raw error page.
>=20
> migrate_pages() does not split a THP if the migration reason is
> MR_MEMORY_FAILURE.
>=20
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  mm/memory-failure.c | 77 +++++++++++++++++++++++++++++++++++++----------=
------
>  mm/migrate.c        | 16 +++++++++++
>  2 files changed, 70 insertions(+), 23 deletions(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 8a9ac6f9e1b0..c05107548d72 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c

...

> @@ -1657,23 +1658,53 @@ static int __soft_offline_page(struct page *page,=
 int flags)
>  		 * cannot have PAGE_MAPPING_MOVABLE.
>  		 */
>  		if (!__PageMovable(page))
> -			inc_node_page_state(page, NR_ISOLATED_ANON +
> -						page_is_file_cache(page));
> -		list_add(&page->lru, &pagelist);
> +			mod_node_page_state(page_pgdat(hpage), NR_ISOLATED_ANON +
> +					page_is_file_cache(hpage), hpage_nr_pages(hpage));
> +retry_subpage:
> +		list_add(&hpage->lru, &pagelist);
>  		ret =3D migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
>  					MIGRATE_SYNC, MR_MEMORY_FAILURE);
>  		if (ret) {
> -			if (!list_empty(&pagelist))
> -				putback_movable_pages(&pagelist);
> -
> +			if (!list_empty(&pagelist)) {
> +				if (!PageTransHuge(hpage))
> +					putback_movable_pages(&pagelist);
> +				else {
> +					lock_page(hpage);
> +					if (split_huge_page_to_list(hpage, &pagelist)) {
> +						unlock_page(hpage);
> +						goto failed;

Don't you need to call putback_movable_pages() before returning?

> +					}
> +					unlock_page(hpage);
> +
> +					if (split)
> +						*split =3D 1;
> +					/*
> +					 * Pull the raw error page out and put back other subpages.
> +					 * Then retry the raw error page.
> +					 */
> +					list_del(&page->lru);
> +					putback_movable_pages(&pagelist);

If putback_movable_pages() is not called for the raw error page,
NR_ISOLATED_ANON or NR_ISOLATED_FILE stat remains incremented by 1 after re=
turn?

> +					hpage =3D page;
> +					goto retry_subpage;
> +				}
> +			}
> +failed:
>  			pr_info("soft offline: %#lx: migration failed %d, type %lx (%pGp)\n",
> -				pfn, ret, page->flags, &page->flags);
> +				pfn, ret, hpage->flags, &hpage->flags);
>  			if (ret > 0)
>  				ret =3D -EIO;
>  		}
> +		/*
> +		 * Set PageHWPoison on the raw error page.
> +		 *
> +		 * If the page is a THP, PageHWPoison is set then cleared
> +		 * in its head page in migrate_pages(). So we need to set the raw erro=
r
> +		 * page here. Otherwise, setting PageHWPoison again is fine.
> +		 */
> +		SetPageHWPoison(page);

When we failed to migrate the page, we don't have to set PageHWPoison
because we can still continue to use the page (which tends to cause correct=
ed
error but is still usable) and we have a chance to retry soft-offline later=
.
So please set the flag only when page/thp migration succeeds.

...

> diff --git a/mm/migrate.c b/mm/migrate.c
> index f7b69282d216..b44df9cf72fd 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1118,6 +1118,15 @@ static ICE_noinline int unmap_and_move(new_page_t =
get_new_page,
>  	}
> =20
>  	if (unlikely(PageTransHuge(page) && !PageTransHuge(newpage))) {
> +		/*
> +		 * soft-offline wants to retry the raw error subpage, if the THP
> +		 * migration fails. So we do not split the THP here and exit directly.
> +		 */
> +		if (reason =3D=3D MR_MEMORY_FAILURE) {
> +			rc =3D -ENOMEM;
> +			goto put_new;
> +		}
> +

This might imply that existing thp migration code have a room for improvmen=
t.

>  		lock_page(page);
>  		rc =3D split_huge_page(page);
>  		unlock_page(page);

This code maybe doesn't work. Even when split_huge_page() succeeds (rc =3D =
0),
__unmap_and_move() migrates only the head page and all tail pages are ignor=
ed
(note that split_huge_page_to_list() sends tail pages to LRU list when
parameter 'list' is NULL.)  IOW, the retry logic in migrate_pages() doesn't
work for thp migration.

What I think is OK is that
  - when thp migration from soft offline fails,
    1. split the thp
    2. send only raw error page to migration page list and send the other
       healthy subpages to LRU list
    3. retry loop in migrate_pages()

  - when thp migration from other callers fails,
    1. split the thp
    2. send all subpages to migration page list
    3. retry loop in migrate_pages()


> @@ -1164,6 +1173,13 @@ static ICE_noinline int unmap_and_move(new_page_t =
get_new_page,
>  			 */
>  			if (!test_set_page_hwpoison(page))
>  				num_poisoned_pages_inc();
> +
> +			/*
> +			 * Clear PageHWPoison in the head page. The caller
> +			 * is responsible for setting the raw error page.
> +			 */
> +			if (PageTransHuge(page))
> +				ClearPageHWPoison(page);

I think that you can write more simply with passing the pointer to
the raw error page from caller. It is also helpful for above-mentioned
split-retry issue.
unmap_and_move() has a parameter 'private' which is now only used
for get/put_new_page(), so I think we can extend it for our purpose.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
