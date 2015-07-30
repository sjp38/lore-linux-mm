Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id D49369003C7
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:07:24 -0400 (EDT)
Received: by wicgb10 with SMTP id gb10so245762252wic.1
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 07:07:24 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id m7si33551149wiy.82.2015.07.30.07.07.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jul 2015 07:07:23 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so22749784wib.1
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 07:07:22 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 1/2] mm, page_isolation: remove bogus tests for isolated pages
In-Reply-To: <1437483218-18703-1-git-send-email-vbabka@suse.cz>
References: <55969822.9060907@suse.cz> <1437483218-18703-1-git-send-email-vbabka@suse.cz>
Date: Thu, 30 Jul 2015 16:07:18 +0200
Message-ID: <xa1th9oleo2x.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, "minkyung88.kim" <minkyung88.kim@lge.com>, kmk3210@gmail.com, Seungho Park <seungho1.park@lge.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Laura Abbott <lauraa@codeaurora.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Tue, Jul 21 2015, Vlastimil Babka wrote:
> The __test_page_isolated_in_pageblock() is used to verify whether all pag=
es
> in pageblock were either successfully isolated, or are hwpoisoned. Two of=
 the
> possible state of pages, that are tested, are however bogus and misleadin=
g.
>
> Both tests rely on get_freepage_migratetype(page), which however has no
> guarantees about pages on freelists. Specifically, it doesn't guarantee t=
hat
> the migratetype returned by the function actually matches the migratetype=
 of
> the freelist that the page is on. Such guarantee is not its purpose and w=
ould
> have negative impact on allocator performance.
>
> The first test checks whether the freepage_migratetype equals MIGRATE_ISO=
LATE,
> supposedly to catch races between page isolation and allocator activity. =
These
> races should be fixed nowadays with 51bb1a4093 ("mm/page_alloc: add freep=
age
> on isolate pageblock to correct buddy list") and related patches. As expl=
ained
> above, the check wouldn't be able to catch them reliably anyway. For the =
same
> reason false positives can happen, although they are harmless, as the
> move_freepages() call would just move the page to the same freelist it's
> already on. So removing the test is not a bug fix, just cleanup. After th=
is
> patch, we assume that all PageBuddy pages are on the correct freelist and=
 that
> the races were really fixed. A truly reliable verification in the form of=
 e.g.
> VM_BUG_ON() would be complicated and is arguably not needed.
>
> The second test (page_count(page) =3D=3D 0 && get_freepage_migratetype(pa=
ge)
> =3D=3D MIGRATE_ISOLATE) is probably supposed (the code comes from a big m=
emory
> isolation patch from 2007) to catch pages on MIGRATE_ISOLATE pcplists.
> However, pcplists don't contain MIGRATE_ISOLATE freepages nowadays, those=
 are
> freed directly to free lists, so the check is obsolete. Remove it as well.
>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> Cc: Laura Abbott <lauraa@codeaurora.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/page_isolation.c | 30 ++++++------------------------
>  1 file changed, 6 insertions(+), 24 deletions(-)
>
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 0e69d25..9eaa489c 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -226,34 +226,16 @@ __test_page_isolated_in_pageblock(unsigned long pfn=
, unsigned long end_pfn,
>  			continue;
>  		}
>  		page =3D pfn_to_page(pfn);
> -		if (PageBuddy(page)) {
> +		if (PageBuddy(page))
>  			/*
> -			 * If race between isolatation and allocation happens,
> -			 * some free pages could be in MIGRATE_MOVABLE list
> -			 * although pageblock's migratation type of the page
> -			 * is MIGRATE_ISOLATE. Catch it and move the page into
> -			 * MIGRATE_ISOLATE list.
> +			 * If the page is on a free list, it has to be on
> +			 * the correct MIGRATE_ISOLATE freelist. There is no
> +			 * simple way to verify that as VM_BUG_ON(), though.
>  			 */
> -			if (get_freepage_migratetype(page) !=3D MIGRATE_ISOLATE) {
> -				struct page *end_page;
> -
> -				end_page =3D page + (1 << page_order(page)) - 1;
> -				move_freepages(page_zone(page), page, end_page,
> -						MIGRATE_ISOLATE);
> -			}
>  			pfn +=3D 1 << page_order(page);
> -		}
> -		else if (page_count(page) =3D=3D 0 &&
> -			get_freepage_migratetype(page) =3D=3D MIGRATE_ISOLATE)
> -			pfn +=3D 1;
> -		else if (skip_hwpoisoned_pages && PageHWPoison(page)) {
> -			/*
> -			 * The HWPoisoned page may be not in buddy
> -			 * system, and page_count() is not 0.
> -			 */
> +		else if (skip_hwpoisoned_pages && PageHWPoison(page))
> +			/* A HWPoisoned page cannot be also PageBuddy */
>  			pfn++;
> -			continue;
> -		}
>  		else
>  			break;
>  	}
> --=20
> 2.4.5
>

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
