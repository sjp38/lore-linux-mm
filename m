Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 2B21B8D0001
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 11:52:33 -0400 (EDT)
Received: by eaan1 with SMTP id n1so2765243eaa.14
        for <linux-mm@kvack.org>; Wed, 06 Jun 2012 08:52:31 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH v9] mm: compaction: handle incorrect MIGRATE_UNMOVABLE
 type pageblocks
References: <201206041543.56917.b.zolnierkie@samsung.com>
 <op.wfdt8dh53l0zgt@mpn-glaptop> <201206061455.28980.b.zolnierkie@samsung.com>
Date: Wed, 06 Jun 2012 17:52:29 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.wfhnpri93l0zgt@mpn-glaptop>
In-Reply-To: <201206061455.28980.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew
 Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus
 Trippelsdorf <markus@trippelsdorf.de>

On Wed, 06 Jun 2012 14:55:28 +0200, Bartlomiej Zolnierkiewicz <b.zolnier=
kie@samsung.com> wrote:

> On Monday 04 June 2012 16:22:51 Michal Nazarewicz wrote:
>> On Mon, 04 Jun 2012 15:43:56 +0200, Bartlomiej Zolnierkiewicz <b.zoln=
ierkie@samsung.com> wrote:
>> > +/*
>> > + * Returns true if MIGRATE_UNMOVABLE pageblock can be successfully=

>> > + * converted to MIGRATE_MOVABLE type, false otherwise.
>> > + */
>> > +static bool can_rescue_unmovable_pageblock(struct page *page, bool=
 locked)
>> > +{
>> > +	unsigned long pfn, start_pfn, end_pfn;
>> > +	struct page *start_page, *end_page, *cursor_page;
>> > +
>> > +	pfn =3D page_to_pfn(page);
>> > +	start_pfn =3D pfn & ~(pageblock_nr_pages - 1);
>> > +	end_pfn =3D start_pfn + pageblock_nr_pages - 1;
>> > +
>> > +	start_page =3D pfn_to_page(start_pfn);
>> > +	end_page =3D pfn_to_page(end_pfn);
>> > +
>> > +	for (cursor_page =3D start_page, pfn =3D start_pfn; cursor_page <=
=3D end_page;
>> > +		pfn++, cursor_page++) {
>> > +		struct zone *zone =3D page_zone(start_page);
>> > +		unsigned long flags;
>> > +
>> > +		if (!pfn_valid_within(pfn))
>> > +			continue;
>> > +
>> > +		/* Do not deal with pageblocks that overlap zones */
>> > +		if (page_zone(cursor_page) !=3D zone)
>> > +			return false;
>> > +
>> > +		if (!locked)
>> > +			spin_lock_irqsave(&zone->lock, flags);
>> > +
>> > +		if (PageBuddy(cursor_page)) {
>> > +			int order =3D page_order(cursor_page);
>> >-/* Returns true if the page is within a block suitable for migratio=
n to */
>> > -static bool suitable_migration_target(struct page *page)
>> > +			pfn +=3D (1 << order) - 1;
>> > +			cursor_page +=3D (1 << order) - 1;
>> > +
>> > +			if (!locked)
>> > +				spin_unlock_irqrestore(&zone->lock, flags);
>> > +			continue;
>> > +		} else if (page_count(cursor_page) =3D=3D 0 ||
>> > +			   PageLRU(cursor_page)) {
>> > +			if (!locked)
>> > +				spin_unlock_irqrestore(&zone->lock, flags);
>> > +			continue;
>> > +		}
>> > +
>> > +		if (!locked)
>> > +			spin_unlock_irqrestore(&zone->lock, flags);
>>
>> spin_unlock in three spaces is ugly.  How about adding a flag that ho=
lds the
>> result of the function which you use as for loop condition and you se=
t it to
>> false inside an additional else clause?  Eg.:
>>
>> 	bool result =3D true;
>> 	for (...; result && cursor_page <=3D end_page; ...) {
>> 		...
>> 		if (!pfn_valid_within(pfn)) continue;
>> 		if (page_zone(cursor_page) !=3D zone) return false;
>> 		if (!locked) spin_lock_irqsave(...);
>> 		=

>> 		if (PageBuddy(...)) {
>> 			...
>> 		} else if (page_count(cursor_page) =3D=3D 0 ||
>> 			   PageLRU(cursor_page)) {
>> 			...
>> 		} else {
>> 			result =3D false;
>> 		}
>> 		if (!locked) spin_unlock_irqsave(...);
>> 	}
>> 	return result;
>
> Thanks, I'll use the hint (if still applicable) in the next patch vers=
ion.
>
>> > +		return false;
>> > +	}
>> > +
>> > +	return true;
>> > +}
>>
>> How do you make sure that a page is not allocated while this runs?  O=
r you just
>> don't care?  Not that even with zone lock, page may be allocated from=
 pcp list
>> on (another) CPU.
>
> Ok, I see the issue (i.e. pcp page can be returned by rmqueue_bulk() i=
n
> buffered_rmqueue() and its page count will be increased in prep_new_pa=
ge()
> a bit later with zone lock dropped so while we may not see the page as=

> "bad" one in can_rescue_unmovable_pageblock() it may end up as unmovab=
le
> one in a pageblock that was just changed to MIGRATE_MOVABLE type).

Allocating unmovable pages from movable pageblock is allowed though.  Bu=
t,
consider those two scenarios:

thread A                               thread B
                                        allocate page from pcp list
call can_rescue_unmovable_pageblock()
  iterate over all pages
   find that one of them is allocated
    so return false

Second one:

thread A                               thread B
call can_rescue_unmovable_pageblock()
  iterate over all pages
   find that all of them are free
                                        allocate page from pcp list
    return true

Note that the second scenario can happen even if zone lock is
held.  So, why in both the function returns different result?

> It is basically similar problem to page allocation vs alloc_contig_ran=
ge()
> races present in CMA so we may deal with it in a similar manner as
> CMA: isolate pageblock so no new allocations will be allowed from it,
> check if we can do pageblock transition to MIGRATE_MOVABLE type and do=

> it if so, drain pcp lists, check if the transition was successful and
> if there are some pages that slipped through just revert the operation=
..

To me this sounds like too much work.

I'm also not sure if you are not overthinking it, which is why I asked
at the beginning =E2=80=9Cor you just don't care?=E2=80=9D  I'm not enti=
rely sure that
you need to make sure that all pages in the pageblock are in fact free.
If some of them slip through, nothing catastrophic happens, does it?

> [*] BTW please see http://marc.info/?l=3Dlinux-mm&m=3D133775797022645&=
w=3D2
> for CMA related fixes

Could you mail it to me again, that would be great, thanks.


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
