Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 11D356B018A
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 10:22:46 -0500 (EST)
Received: by vcbfk26 with SMTP id fk26so5147568vcb.14
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 07:22:45 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 02/11] mm: compaction: introduce
 isolate_{free,migrate}pages_range().
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
 <1321634598-16859-3-git-send-email-m.szyprowski@samsung.com>
 <20111212140728.GC3277@csn.ul.ie>
Date: Mon, 12 Dec 2011 16:22:39 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v6dub1ms3l0zgt@mpn-glaptop>
In-Reply-To: <20111212140728.GC3277@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel
 Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse
 Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq
 Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

> On Fri, Nov 18, 2011 at 05:43:09PM +0100, Marek Szyprowski wrote:
>> From: Michal Nazarewicz <mina86@mina86.com>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 899d956..6afae0e 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -54,51 +54,64 @@ static unsigned long release_freepages(struct lis=
t_head *freelist)
>>  	return count;
>>  }
>>
>> -/* Isolate free pages onto a private freelist. Must hold zone->lock =
*/
>> -static unsigned long isolate_freepages_block(struct zone *zone,
>> -				unsigned long blockpfn,
>> -				struct list_head *freelist)
>> +/**
>> + * isolate_freepages_range() - isolate free pages, must hold zone->l=
ock.
>> + * @zone:	Zone pages are in.
>> + * @start:	The first PFN to start isolating.
>> + * @end:	The one-past-last PFN.
>> + * @freelist:	A list to save isolated pages to.
>> + *
>> + * If @freelist is not provided, holes in range (either non-free pag=
es
>> + * or invalid PFNs) are considered an error and function undos its
>> + * actions and returns zero.
>> + *
>> + * If @freelist is provided, function will simply skip non-free and
>> + * missing pages and put only the ones isolated on the list.
>> + *
>> + * Returns number of isolated pages.  This may be more then end-star=
t
>> + * if end fell in a middle of a free page.
>> + */
>> +static unsigned long
>> +isolate_freepages_range(struct zone *zone,
>> +			unsigned long start, unsigned long end,
>> +			struct list_head *freelist)

On Mon, 12 Dec 2011 15:07:28 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> Use start_pfn and end_pfn to keep it consistent with the rest of
> compaction.c.

Will do.

>>  {
>> -	unsigned long zone_end_pfn, end_pfn;
>> -	int nr_scanned =3D 0, total_isolated =3D 0;
>> -	struct page *cursor;
>> -
>> -	/* Get the last PFN we should scan for free pages at */
>> -	zone_end_pfn =3D zone->zone_start_pfn + zone->spanned_pages;
>> -	end_pfn =3D min(blockpfn + pageblock_nr_pages, zone_end_pfn);
>> +	unsigned long nr_scanned =3D 0, total_isolated =3D 0;
>> +	unsigned long pfn =3D start;
>> +	struct page *page;
>>
>> -	/* Find the first usable PFN in the block to initialse page cursor =
*/
>> -	for (; blockpfn < end_pfn; blockpfn++) {
>> -		if (pfn_valid_within(blockpfn))
>> -			break;
>> -	}
>> -	cursor =3D pfn_to_page(blockpfn);
>> +	VM_BUG_ON(!pfn_valid(pfn));
>> +	page =3D pfn_to_page(pfn);
>>
>>  	/* Isolate free pages. This assumes the block is valid */
>> -	for (; blockpfn < end_pfn; blockpfn++, cursor++) {
>> -		int isolated, i;
>> -		struct page *page =3D cursor;
>> -
>> -		if (!pfn_valid_within(blockpfn))
>> -			continue;
>> -		nr_scanned++;
>> -
>> -		if (!PageBuddy(page))
>> -			continue;
>> +	while (pfn < end) {
>> +		unsigned isolated =3D 1, i;
>> +

> Do not use implcit types. These are unsigned ints, call them unsigned
> ints.

Will do.

>
>> +		if (!pfn_valid_within(pfn))
>> +			goto skip;
>
> The flow of this function in general with gotos of skipped and next
> is confusing in comparison to the existing function. For example,
> if this PFN is not valid, and no freelist is provided, then we call
> __free_page() on a PFN that is known to be invalid.
>
>> +		++nr_scanned;
>> +
>> +		if (!PageBuddy(page)) {
>> +skip:
>> +			if (freelist)
>> +				goto next;
>> +			for (; start < pfn; ++start)
>> +				__free_page(pfn_to_page(pfn));
>> +			return 0;
>> +		}
>
> So if a PFN is valid and !PageBuddy and no freelist is provided, we
> call __free_page() on it regardless of reference count. That does not
> sound safe.

Sorry about that.  It's a bug in the code which was caught later on.  Th=
e
code should read =E2=80=9C__free_page(pfn_to_page(start))=E2=80=9D.

>>
>>  		/* Found a free page, break it into order-0 pages */
>>  		isolated =3D split_free_page(page);
>>  		total_isolated +=3D isolated;
>> -		for (i =3D 0; i < isolated; i++) {
>> -			list_add(&page->lru, freelist);
>> -			page++;
>> +		if (freelist) {
>> +			struct page *p =3D page;
>> +			for (i =3D isolated; i; --i, ++p)
>> +				list_add(&p->lru, freelist);
>>  		}
>>
>> -		/* If a page was split, advance to the end of it */
>> -		if (isolated) {
>> -			blockpfn +=3D isolated - 1;
>> -			cursor +=3D isolated - 1;
>> -		}
>> +next:
>> +		pfn +=3D isolated;
>> +		page +=3D isolated;
>
> The name isolated is now confusing because it can mean either
> pages isolated or pages scanned depending on context. Your patch
> appears to be doing a lot more than is necessary to convert
> isolate_freepages_block into isolate_freepages_range and at this point=
,
> it's unclear why you did that.

When CMA uses this function, it requires all pages in the range to be va=
lid
and free.  (Both conditions should be met but you never know.)  This cha=
nge
adds a second way isolate_freepages_range() works, which is when freelis=
t is
not specified, abort on invalid or non-free page, but continue as usual =
if
freelist is provided.

I can try and restructure this function a bit so that there are fewer =E2=
=80=9Cgotos=E2=80=9D,
but without the above change, CMA won't really be able to use it effecti=
vely
(it would have to provide a freelist and then validate if pages on it ar=
e
added in order).

>>  	}
>>
>>  	trace_mm_compaction_isolate_freepages(nr_scanned, total_isolated);

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
