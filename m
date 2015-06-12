Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9CDF96B0083
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 06:11:41 -0400 (EDT)
Received: by wgez8 with SMTP id z8so21280028wge.0
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 03:11:41 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id ly8si6302673wjb.40.2015.06.12.03.11.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jun 2015 03:11:40 -0700 (PDT)
Received: by wibut5 with SMTP id ut5so13775710wib.1
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 03:11:39 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 4/6] mm, compaction: always skip compound pages by order in migrate scanner
In-Reply-To: <1433928754-966-5-git-send-email-vbabka@suse.cz>
References: <1433928754-966-1-git-send-email-vbabka@suse.cz> <1433928754-966-5-git-send-email-vbabka@suse.cz>
Date: Fri, 12 Jun 2015 12:11:35 +0200
Message-ID: <xa1toaklp76w.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Wed, Jun 10 2015, Vlastimil Babka wrote:
> The compaction migrate scanner tries to skip compound pages by their orde=
r, to
> reduce number of iterations for pages it cannot isolate. The check is onl=
y done
> if PageLRU() is true, which means it applies to THP pages, but not e.g.
> hugetlbfs pages or any other non-LRU compound pages, which we have to ite=
rate
> by base pages.
>
> This limitation comes from the assumption that it's only safe to read
> compound_order() when we have the zone's lru_lock and THP cannot be split=
 under
> us. But the only danger (after filtering out order values that are not be=
low
> MAX_ORDER, to prevent overflows) is that we skip too much or too little a=
fter
> reading a bogus compound_order() due to a rare race. This is the same rea=
soning
> as patch 99c0fd5e51c4 ("mm, compaction: skip buddy pages by their order i=
n the
> migrate scanner") introduced for unsafely reading PageBuddy() order.
>
> After this patch, all pages are tested for PageCompound() and we skip the=
m by
> compound_order().  The test is done after the test for balloon_page_movab=
le()
> as we don't want to assume if balloon pages (or other pages with own isol=
ation
> and migration implementation if a generic API gets implemented) are compo=
und
> or not.
>
> When tested with stress-highalloc from mmtests on 4GB system with 1GB hug=
etlbfs
> pages, the vmstat compact_migrate_scanned count decreased by 15%.
>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  mm/compaction.c | 36 +++++++++++++++++-------------------
>  1 file changed, 17 insertions(+), 19 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index d334bb3..e37d361 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -680,6 +680,8 @@ isolate_migratepages_block(struct compact_control *cc=
, unsigned long low_pfn,
>=20=20
>  	/* Time to isolate some pages for migration */
>  	for (; low_pfn < end_pfn; low_pfn++) {
> +		bool is_lru;
> +
>  		/*
>  		 * Periodically drop the lock (if held) regardless of its
>  		 * contention, to give chance to IRQs. Abort async compaction
> @@ -723,39 +725,35 @@ isolate_migratepages_block(struct compact_control *=
cc, unsigned long low_pfn,
>  		 * It's possible to migrate LRU pages and balloon pages
>  		 * Skip any other type of page
>  		 */
> -		if (!PageLRU(page)) {
> +		is_lru =3D PageLRU(page);
> +		if (!is_lru) {
>  			if (unlikely(balloon_page_movable(page))) {
>  				if (balloon_page_isolate(page)) {
>  					/* Successfully isolated */
>  					goto isolate_success;
>  				}
>  			}
> -			continue;
>  		}
>=20=20
>  		/*
> -		 * PageLRU is set. lru_lock normally excludes isolation
> -		 * splitting and collapsing (collapsing has already happened
> -		 * if PageLRU is set) but the lock is not necessarily taken
> -		 * here and it is wasteful to take it just to check transhuge.
> -		 * Check PageCompound without lock and skip the whole pageblock
> -		 * if it's a transhuge page, as calling compound_order()
> -		 * without preventing THP from splitting the page underneath us
> -		 * may return surprising results.
> -		 * If we happen to check a THP tail page, compound_order()
> -		 * returns 0. It should be rare enough to not bother with
> -		 * using compound_head() in that case.
> +		 * Regardless of being on LRU, compound pages such as THP and
> +		 * hugetlbfs are not to be compacted. We can potentially save
> +		 * a lot of iterations if we skip them at once. The check is
> +		 * racy, but we can consider only valid values and the only
> +		 * danger is skipping too much.
>  		 */
>  		if (PageCompound(page)) {
> -			int nr;
> -			if (locked)
> -				nr =3D 1 << compound_order(page);
> -			else
> -				nr =3D pageblock_nr_pages;
> -			low_pfn +=3D nr - 1;
> +			unsigned int comp_order =3D compound_order(page);
> +
> +			if (comp_order > 0 && comp_order < MAX_ORDER)
> +				low_pfn +=3D (1UL << comp_order) - 1;
> +
>  			continue;
>  		}
>=20=20
> +		if (!is_lru)
> +			continue;
> +
>  		/*
>  		 * Migration will fail if an anonymous page is pinned in memory,
>  		 * so avoid taking lru_lock and isolating it unnecessarily in an
> --=20
> 2.1.4
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
