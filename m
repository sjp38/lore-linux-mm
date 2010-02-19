Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 047676B0047
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 20:21:12 -0500 (EST)
Received: by pwj7 with SMTP id 7so1505328pwj.14
        for <linux-mm@kvack.org>; Thu, 18 Feb 2010 17:21:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100218173437.GA30258@csn.ul.ie>
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
	 <1265976059-7459-6-git-send-email-mel@csn.ul.ie>
	 <1266512324.1709.295.camel@barrios-desktop>
	 <20100218173437.GA30258@csn.ul.ie>
Date: Fri, 19 Feb 2010 10:21:10 +0900
Message-ID: <28c262361002181721k2c40854ah638eaaf2254e92a@mail.gmail.com>
Subject: Re: [PATCH 05/12] Memory compaction core
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 19, 2010 at 2:34 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Fri, Feb 19, 2010 at 01:58:44AM +0900, Minchan Kim wrote:
>> On Fri, 2010-02-12 at 12:00 +0000, Mel Gorman wrote:
>> > +/* Isolate free pages onto a private freelist. Must hold zone->lock *=
/
>> > +static int isolate_freepages_block(struct zone *zone,
>>
>> return type 'int'?
>> I think we can't return signed value.
>>
>
> I don't understand your query. What's wrong with returning int?

It's just nitpick. I mean this functions doesn't return minus value.
Never mind.

>
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long blockpfn,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 struct list_head *freelist)
>> > +{
>> > + =C2=A0 unsigned long zone_end_pfn, end_pfn;
>> > + =C2=A0 int total_isolated =3D 0;
>> > +
>> > + =C2=A0 /* Get the last PFN we should scan for free pages at */
>> > + =C2=A0 zone_end_pfn =3D zone->zone_start_pfn + zone->spanned_pages;
>> > + =C2=A0 end_pfn =3D blockpfn + pageblock_nr_pages;
>> > + =C2=A0 if (end_pfn > zone_end_pfn)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 end_pfn =3D zone_end_pfn;
>> > +
>> > + =C2=A0 /* Isolate free pages. This assumes the block is valid */
>> > + =C2=A0 for (; blockpfn < end_pfn; blockpfn++) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page *page;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int isolated, i;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!pfn_valid_within(blockpfn))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 conti=
nue;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D pfn_to_page(blockpfn);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!PageBuddy(page))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 conti=
nue;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Found a free page, break it in=
to order-0 pages */
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 isolated =3D split_free_page(page=
);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total_isolated +=3D isolated;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < isolated; i++) =
{
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_=
add(&page->lru, freelist);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page+=
+;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 blockpfn +=3D isolated - 1;
>
> Incidentally, this line is wrong but will be fixed in line 3. If
> split_free_page() fails, it causes an infinite loop.
>
>> > + =C2=A0 }
>> > +
>> > + =C2=A0 return total_isolated;
>> > +}
>> > +
>> > +/* Returns 1 if the page is within a block suitable for migration to =
*/
>> > +static int suitable_migration_target(struct page *page)
>> > +{
>> > + =C2=A0 /* If the page is a large free page, then allow migration */
>> > + =C2=A0 if (PageBuddy(page) && page_order(page) >=3D pageblock_order)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1;
>> > +
>> > + =C2=A0 /* If the block is MIGRATE_MOVABLE, allow migration */
>> > + =C2=A0 if (get_pageblock_migratetype(page) =3D=3D MIGRATE_MOVABLE)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1;
>> > +
>> > + =C2=A0 /* Otherwise skip the block */
>> > + =C2=A0 return 0;
>> > +}
>> > +
>> > +/*
>> > + * Based on information in the current compact_control, find blocks
>> > + * suitable for isolating free pages from
>> > + */
>> > +static void isolate_freepages(struct zone *zone,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 struct compact_control *cc)
>> > +{
>> > + =C2=A0 struct page *page;
>> > + =C2=A0 unsigned long high_pfn, low_pfn, pfn;
>> > + =C2=A0 unsigned long flags;
>> > + =C2=A0 int nr_freepages =3D cc->nr_freepages;
>> > + =C2=A0 struct list_head *freelist =3D &cc->freepages;
>> > +
>> > + =C2=A0 pfn =3D cc->free_pfn;
>> > + =C2=A0 low_pfn =3D cc->migrate_pfn + pageblock_nr_pages;
>> > + =C2=A0 high_pfn =3D low_pfn;
>> > +
>> > + =C2=A0 /*
>> > + =C2=A0 =C2=A0* Isolate free pages until enough are available to migr=
ate the
>> > + =C2=A0 =C2=A0* pages on cc->migratepages. We stop searching if the m=
igrate
>> > + =C2=A0 =C2=A0* and free page scanners meet or enough free pages are =
isolated.
>> > + =C2=A0 =C2=A0*/
>> > + =C2=A0 spin_lock_irqsave(&zone->lock, flags);
>> > + =C2=A0 for (; pfn > low_pfn && cc->nr_migratepages > nr_freepages;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pfn -=3D pageblock_nr_=
pages) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int isolated;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!pfn_valid(pfn))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 conti=
nue;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Check for overlapping nodes/zo=
nes */
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D pfn_to_page(pfn);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (page_zone(page) !=3D zone)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 conti=
nue;
>>
>> We are progressing backward by physical page order in a zone.
>> If we meet crossover between zone, Why are we going backward
>> continuously? Before it happens, migration and free scanner would meet.
>> Am I miss something?
>>
>
> I was considering a situation like the following
>
>
> Node-0 =C2=A0 =C2=A0 Node-1 =C2=A0 =C2=A0 =C2=A0 Node-0
> DMA =C2=A0 =C2=A0 =C2=A0 =C2=A0DMA =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0DMA
> 0-1023 =C2=A0 =C2=A0 1024-2047 =C2=A0 =C2=A02048-4096
>
> In that case, a PFN scanner can enter a new node and zone but the migrate
> and free scanners have not necessarily met. This configuration is *extrem=
ely*
> rare but it happens on messed-up LPAR configurations on POWER.

I don't know such architecture until now.
Thanks for telling me.
How about adding the comment about that?

>
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Check the block is suitable fo=
r migration */
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!suitable_migration_target(pa=
ge))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 conti=
nue;
>>
>> Dumb question.
>> suitable_migration_target considers three type's pages
>>
>> 1. free page and page's order >=3D pageblock_order
>> 2. free pages and pages's order < pageblock_order with movable page
>> 3. used page with movable
>>
>> I can understand 1 and 2 but can't 3. This function is for gathering
>> free page. How do you handle used page as free one?
>>
>> In addition, as I looked into isolate_freepages_block, it doesn't
>> consider 3 by PageBuddy check.
>>
>> I am confusing. Pz, correct me.
>>
>
> I'm afraid I don't understand your question. At the point
> suitable_migration_target() is called, the only concern is finding a page=
block
> of pages that should be scanned for free pages by isolate_freepages_block=
().
> What do you mean by "used page with movable" ?

After I looked into code, I understand it.
Thanks.

<snip>
>>> +/* Similar to split_page except the page is already free */
>> Sometime, this function changes pages's type to MIGRATE_MOVABLE.
>> I hope adding comment about that.
>>
>
> There is a comment within the function about it. Do you want it moved to
> here?

If you don't mind, I hope so. :)

That's because you wrote down only "except the page is already free" in
function description. So I thought it's only difference with split_page at =
first
glance. I think information that setting MIGRATE_MOVABLE is important.

Pz, thinks it as just nitpick.
Thanks, Mel.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
