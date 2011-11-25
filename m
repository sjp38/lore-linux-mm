Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0DDE76B002D
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 16:08:21 -0500 (EST)
Received: by bke17 with SMTP id 17so6133186bke.14
        for <linux-mm@kvack.org>; Fri, 25 Nov 2011 13:08:19 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH] mm: cma: hack/workaround for some allocation issues
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
 <1322239387-31394-1-git-send-email-m.szyprowski@samsung.com>
Date: Fri, 25 Nov 2011 22:08:16 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v5isz2nh3l0zgt@mpn-glaptop>
In-Reply-To: <1322239387-31394-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang
 Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Fri, 25 Nov 2011 17:43:07 +0100, Marek Szyprowski <m.szyprowski@samsu=
ng.com> wrote:
> This is a quick and dirty patch and hack to solve some memory allocati=
on
> issues that appeared at CMA v17 after switching migration code from
> hotplug to memory compaction. Especially the issue with watermark
> adjustment need a real fix instead of disabling the code.
>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> ---
>
> Hello,
>
> This patch fixes the issues that have been reported recently. It shoul=
d
> be considered only as a temporary solution until a new version of CMA
> patches is ready.
>
> Best regards
> --
> Marek Szyprowski
> Samsung Poland R&D Center
>
> ---
>  mm/compaction.c |    5 ++++-
>  mm/page_alloc.c |   12 +++++++++---
>  2 files changed, 13 insertions(+), 4 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 3e07341..41976f8 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -79,8 +79,9 @@ isolate_freepages_range(struct zone *zone,
>  skip:
>  			if (freelist)
>  				goto next;
> +failed:
>  			for (; start < pfn; ++start)
> -				__free_page(pfn_to_page(pfn));
> +				__free_page(pfn_to_page(start));
>  			return 0;
>  		}

Yeah, my mistake, sorry about that. ;)


> @@ -91,6 +92,8 @@ skip:
>  			struct page *p =3D page;
>  			for (i =3D isolated; i; --i, ++p)
>  				list_add(&p->lru, freelist);
> +		} else if (!isolated) {
> +			goto failed;
>  		}
> next:
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 714b1c1..b4a46c7 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1303,12 +1303,12 @@ int split_free_page(struct page *page)
> 	zone =3D page_zone(page);
>  	order =3D page_order(page);
> -
> +#if 0
>  	/* Obey watermarks as if the page was being allocated */
>  	watermark =3D low_wmark_pages(zone) + (1 << order);
>  	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
>  		return 0;
> -
> +#endif
>  	/* Remove page from free list */
>  	list_del(&page->lru);
>  	zone->free_area[order].nr_free--;

Come to think of it, this watermark check seem a little meaningless in c=
ase of
CMA.  With CMA the pages that we are splitting here have migrate type IS=
OLATE
so they aren't =E2=80=9Cfree=E2=80=9D at all.  Buddy will never use them=
 for allocation.  That
means that we don't really allocate any pages, we just want to split the=
m into
order-0 pages.

Also, if we bail out now, it's a huge waste of time and efforts.

So, if the watermarks need to be checked, they should somewhere before w=
e do
migration and stuff.  This may be due to my ignorance, but I don't know =
whether
we really need the watermark check if we decide to use plain alloc_page(=
) as
allocator for migrate_pages() rather then compaction_alloc().

> @@ -5734,6 +5734,12 @@ static unsigned long pfn_align_to_maxpage_up(un=
signed long pfn)
>  	return ALIGN(pfn, MAX_ORDER_NR_PAGES);
>  }
>+static struct page *
> +cma_migrate_alloc(struct page *page, unsigned long private, int **x)
> +{
> +	return alloc_page(GFP_HIGHUSER_MOVABLE);
> +}
> +
>  static int __alloc_contig_migrate_range(unsigned long start, unsigned=
 long end)
>  {
>  	/* This function is based on compact_zone() from compaction.c. */
> @@ -5801,7 +5807,7 @@ static int __alloc_contig_migrate_range(unsigned=
 long start, unsigned long end)
>  		}
> 		/* Try to migrate. */
> -		ret =3D migrate_pages(&cc.migratepages, compaction_alloc,
> +		ret =3D migrate_pages(&cc.migratepages, cma_migrate_alloc,
>  				    (unsigned long)&cc, false, cc.sync);
> 		/* Migrated all of them? Great! */

Yep, that makes sense to me.  compaction_alloc() takes only free pages (=
ie. pages
 from buddy system) from given zone.  This means that no pages get disca=
rded or
swapped to disk.  This makes sense for compaction since it's opportunist=
ic in its
nature.  We, however, want pages to be discarded/swapped if that's the o=
nly way of
getting pages to migrate to.

Of course, with this change the =E2=80=9C(unsigneg long)&cc=E2=80=9D par=
t can be safely replaced
with =E2=80=9CNULL=E2=80=9D and =E2=80=9Ccc.nr_freepages -=3D release_fr=
eepages(&cc.freepages);=E2=80=9D at the end
of the function (not visible in this patch) with the next line removed.

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
