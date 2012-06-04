Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 1E33A6B005C
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 10:22:55 -0400 (EDT)
Received: by eaan1 with SMTP id n1so1602196eaa.14
        for <linux-mm@kvack.org>; Mon, 04 Jun 2012 07:22:53 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH v9] mm: compaction: handle incorrect MIGRATE_UNMOVABLE
 type pageblocks
References: <201206041543.56917.b.zolnierkie@samsung.com>
Date: Mon, 04 Jun 2012 16:22:51 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.wfdt8dh53l0zgt@mpn-glaptop>
In-Reply-To: <201206041543.56917.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bartlomiej
 Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>

On Mon, 04 Jun 2012 15:43:56 +0200, Bartlomiej Zolnierkiewicz <b.zolnier=
kie@samsung.com> wrote:
> +/*
> + * Returns true if MIGRATE_UNMOVABLE pageblock can be successfully
> + * converted to MIGRATE_MOVABLE type, false otherwise.
> + */
> +static bool can_rescue_unmovable_pageblock(struct page *page, bool lo=
cked)
> +{
> +	unsigned long pfn, start_pfn, end_pfn;
> +	struct page *start_page, *end_page, *cursor_page;
> +
> +	pfn =3D page_to_pfn(page);
> +	start_pfn =3D pfn & ~(pageblock_nr_pages - 1);
> +	end_pfn =3D start_pfn + pageblock_nr_pages - 1;
> +
> +	start_page =3D pfn_to_page(start_pfn);
> +	end_page =3D pfn_to_page(end_pfn);
> +
> +	for (cursor_page =3D start_page, pfn =3D start_pfn; cursor_page <=3D=
 end_page;
> +		pfn++, cursor_page++) {
> +		struct zone *zone =3D page_zone(start_page);
> +		unsigned long flags;
> +
> +		if (!pfn_valid_within(pfn))
> +			continue;
> +
> +		/* Do not deal with pageblocks that overlap zones */
> +		if (page_zone(cursor_page) !=3D zone)
> +			return false;
> +
> +		if (!locked)
> +			spin_lock_irqsave(&zone->lock, flags);
> +
> +		if (PageBuddy(cursor_page)) {
> +			int order =3D page_order(cursor_page);
>-/* Returns true if the page is within a block suitable for migration t=
o */
> -static bool suitable_migration_target(struct page *page)
> +			pfn +=3D (1 << order) - 1;
> +			cursor_page +=3D (1 << order) - 1;
> +
> +			if (!locked)
> +				spin_unlock_irqrestore(&zone->lock, flags);
> +			continue;
> +		} else if (page_count(cursor_page) =3D=3D 0 ||
> +			   PageLRU(cursor_page)) {
> +			if (!locked)
> +				spin_unlock_irqrestore(&zone->lock, flags);
> +			continue;
> +		}
> +
> +		if (!locked)
> +			spin_unlock_irqrestore(&zone->lock, flags);

spin_unlock in three spaces is ugly.  How about adding a flag that holds=
 the
result of the function which you use as for loop condition and you set i=
t to
false inside an additional else clause?  Eg.:

	bool result =3D true;
	for (...; result && cursor_page <=3D end_page; ...) {
		...
		if (!pfn_valid_within(pfn)) continue;
		if (page_zone(cursor_page) !=3D zone) return false;
		if (!locked) spin_lock_irqsave(...);
		=

		if (PageBuddy(...)) {
			...
		} else if (page_count(cursor_page) =3D=3D 0 ||
			   PageLRU(cursor_page)) {
			...
		} else {
			result =3D false;
		}
		if (!locked) spin_unlock_irqsave(...);
	}
	return result;

> +		return false;
> +	}
> +
> +	return true;
> +}

How do you make sure that a page is not allocated while this runs?  Or y=
ou just
don't care?  Not that even with zone lock, page may be allocated from pc=
p list
on (another) CPU.

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
